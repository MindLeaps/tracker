import {ApplicationLoadBalancer, LoadBalancer} from "@pulumi/aws/alb";
import * as pulumi from "@pulumi/pulumi";
import {SecurityGroup, Subnet, Vpc} from "@pulumi/aws/ec2";
import {Bucket} from "@pulumi/aws/s3";
import {Listener, TargetGroup} from "@pulumi/aws/lb";
import {Certificate} from "@pulumi/aws/acm";

const config = new pulumi.Config();

const env = config.require('environment');

const MINDLEAPS_TRACKER_TARGET_GROUP_PULUMI_NAME = 'MINDLEAPS_TRACKER_TARGET_GROUP';
const MINDLEAPS_TRACKER_TARGET_GROUP_NAME = `target-group-${env}`;

const MAIN_LB_PULUMI_NAME = 'MAIN_LOAD_BALANCER';
const MAIN_LB_NAME = `alb-${env}-mindleaps-tracker`;

const LB_SECURITY_GROUP_PULUMI_NAME = 'MAIN_LOAD_BALANCER_SECURITY_GROUP';
const LB_SECURITY_GROUP_NAME = `security-group-lb-${env}-mindleaps-tracker`;

const HTTP_LISTENER_PULUMI_NAME = 'HTTP_LISTENER';
const HTTPS_LISTENER_PULUMI_NAME = 'HTTPS_LISTENER';

export interface LoadBalancerConfiguration {
    loadBalancer: LoadBalancer;
    securityGroup: SecurityGroup;
    targetGroup: TargetGroup;
    listeners: {http: Listener, https: Listener};
}

export function createApplicationLoadBalancer(vpc: Vpc, subnets: Subnet[], logBucket: Bucket, certificate: Certificate): LoadBalancerConfiguration {
    const targetGroup = new TargetGroup(MINDLEAPS_TRACKER_TARGET_GROUP_PULUMI_NAME, {
        name: MINDLEAPS_TRACKER_TARGET_GROUP_NAME,
        protocol: 'HTTP',
        healthCheck: {
            path: '/health',
            interval: 15
        },
        port: 3000,
        vpcId: vpc.id,
        targetType: 'ip',
        deregistrationDelay: 30,
        tags: {
            environment: env
        }
    });

    const securityGroup = createALBSecurityGroup(vpc);

    const loadBalancer = new LoadBalancer(MAIN_LB_PULUMI_NAME, {
        accessLogs: {
            enabled: true,
            bucket: logBucket.bucket,
            prefix: `${MAIN_LB_NAME}-access-logs`
        },

        loadBalancerType: ApplicationLoadBalancer,
        subnets: subnets.map(s => s.id),
        securityGroups: [securityGroup.id],
        name: MAIN_LB_NAME,
        tags: {
            environment: env
        }
    });

    const listeners = createALBListeners(loadBalancer, certificate, targetGroup)

    return {loadBalancer, targetGroup, listeners, securityGroup};
}

function createALBSecurityGroup(vpc: Vpc): SecurityGroup {
    return new SecurityGroup(LB_SECURITY_GROUP_PULUMI_NAME, {
        name: LB_SECURITY_GROUP_NAME,
        description: 'Security group for the Application Load Balancer',
        vpcId: vpc.id,
        ingress:[{
            cidrBlocks: ['0.0.0.0/0'],
            protocol: 'tcp',
            fromPort: 80,
            toPort: 80
        }, {
            cidrBlocks: ['0.0.0.0/0'],
            protocol: 'tcp',
            fromPort: 443,
            toPort: 443
        }],
        egress: [{
            cidrBlocks: ['0.0.0.0/0'],
            protocol: 'tcp',
            fromPort: 0,
            toPort: 65535
        }]
    })
}

function createALBListeners(lb: LoadBalancer, certificate: Certificate, targetGroup: TargetGroup): {http: Listener, https: Listener} {
    return {
        http: new Listener(HTTP_LISTENER_PULUMI_NAME, {
            loadBalancerArn: lb.arn,
            defaultActions: [{
                redirect: {
                    port: '443',
                    protocol: 'HTTPS',
                    statusCode: 'HTTP_301',
                },
                type: 'redirect'
            }],
            port: 80,
        }),
        https: new Listener(HTTPS_LISTENER_PULUMI_NAME, {
            certificateArn: certificate.arn,
            loadBalancerArn: lb.arn,
            defaultActions: [{
                type: 'forward',
                targetGroupArn: targetGroup.arn
            }],
            protocol: 'HTTPS',
            port: 443
        })
    };
}

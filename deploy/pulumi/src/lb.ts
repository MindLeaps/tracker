import {ApplicationLoadBalancer, LoadBalancer} from "@pulumi/aws/alb";
import * as pulumi from "@pulumi/pulumi";
import {Subnet} from "@pulumi/aws/ec2";
import {Bucket} from "@pulumi/aws/s3";
import {Listener} from "@pulumi/aws/lb";
import {Certificate} from "@pulumi/aws/acm";

const config = new pulumi.Config();

const env = config.require('environment');

const MAIN_LB_PULUMI_NAME = 'MAIN_LOAD_BALANCER';
const MAIN_LB_NAME = `alb-${env}-mindleaps-tracker`;

const HTTP_LISTENER_PULUMI_NAME = 'HTTP_LISTENER';
const HTTPS_LISTENER_PULUMI_NAME = 'HTTPS_LISTENER';

export function createApplicationLoadBalancer(subnets: Subnet[], logBucket: Bucket): LoadBalancer {
    return new LoadBalancer(MAIN_LB_PULUMI_NAME, {
        accessLogs: {
            enabled: true,
            bucket: logBucket.bucket,
            prefix: `${MAIN_LB_NAME}-access-logs`
        },

        loadBalancerType: ApplicationLoadBalancer,
        subnets: subnets.map(s => s.id),
        name: MAIN_LB_NAME,
        tags: {
            environment: env
        }
    })
}

export function createALBListeners(lb: LoadBalancer, certificate: Certificate): {http: Listener, https: Listener} {
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
            defaultActions: [],
            port: 443
        })
    }
}
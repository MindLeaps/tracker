import {SecurityGroup, Subnet, Vpc} from "@pulumi/aws/ec2";
import {Cluster, Service, TaskDefinition} from "@pulumi/aws/ecs";
import * as pulumi from "@pulumi/pulumi";
import {LoadBalancerConfiguration} from "./lb";
import {SsmParameters} from "./parameters";
import {Output} from "@pulumi/pulumi";
import {Role, RolePolicy} from "@pulumi/aws/iam";
import {getDatabaseFQDN} from "./util";

const config = new pulumi.Config();

const env = config.require('environment');

const MINDLEAPS_TRACKER_TASK_PULUMI_NAME = 'MINDLEAPS_TRACKER_TASK';
const MINDLEAPS_TRACKER_TASK_NAME = pulumi.interpolate `task-${env}-mindleaps-tracker`;

const TASK_EXECUTION_ROLE_PULUMI_NAME = 'TASK_EXECUTION_ROLE';
const TASK_EXECUTION_ROLE_NAME = pulumi.interpolate `role-${env}-mindleaps-tracker`;

const TASK_ROLE_POLICY_PULUMI_NAME = 'TASK_ROLE_POLICY';

const MINDLEAPS_TRACKER_ECS_CLUSTER_PULUMI_NAME = 'MINDLEAPS_TRACKER_ECS_CLUSTER';
const MINDLEAPS_TRACKER_ECS_CLUSTER_NAME = pulumi.interpolate `cluster-${env}-mindleaps-tracker`;

const MINDLEAPS_TRACKER_SERVICE_PULUMI_NAME = 'MINDLEAPS_TRACKER_SERVICE';
const MINDLEAPS_TRACKER_SERVICE_NAME = pulumi.interpolate `service-${env}-mindleaps-tracker`;

const SERVICE_SECURITY_GROUP_PULUMI_NAME = 'MINDLEAPS_TRACKER_SERVICE_SECURITY_GROUP';
const SERVICE_SECURITY_GROUP_NAME = pulumi.interpolate `security-group-service-${env}`;

export interface EcsConfiguration {
    cluster: Cluster;
    service: Service;
    taskDefinition: TaskDefinition;
}

export function createTrackerTask(parameters: SsmParameters): TaskDefinition {
    return new TaskDefinition(MINDLEAPS_TRACKER_TASK_PULUMI_NAME, {
        containerDefinitions: createContainerDefinitions(parameters),
        executionRoleArn: createTaskExecutionRole(parameters).arn,
        family: MINDLEAPS_TRACKER_TASK_NAME,
        networkMode: 'awsvpc',
        requiresCompatibilities: ['FARGATE'],
        cpu: '512',
        memory: '1024',
        tags: {
            environment: env
        }
    });
}

function createTaskExecutionRole(parameters: SsmParameters): Role {
    const role = new Role(TASK_EXECUTION_ROLE_PULUMI_NAME, {
        assumeRolePolicy: {
            Version: '2012-10-17',
            Statement: [{
                Action: 'sts:AssumeRole',
                Principal: {
                    Service: [
                        'ecs.amazonaws.com',
                        'ecs-tasks.amazonaws.com'
                  ]},
                Effect: 'Allow',
                Sid: ''
            }]
        },
        name: TASK_EXECUTION_ROLE_NAME,
        tags: {
            environment: env
        }
    });
    new RolePolicy(TASK_ROLE_POLICY_PULUMI_NAME, {
        name: TASK_EXECUTION_ROLE_NAME,
        role: role,
        policy: {
            Version: '2012-10-17',
            Statement: parameters.toArray().map(p => ({
                Action: 'ssm:GetParameters',
                Effect: 'Allow',
                Resource: p.arn
            }))
        }
    });
    return role;
}

export function createEcsCluster(): Cluster {
    return new Cluster(MINDLEAPS_TRACKER_ECS_CLUSTER_PULUMI_NAME, {
        capacityProviders: ['FARGATE'],
        name: MINDLEAPS_TRACKER_ECS_CLUSTER_NAME,
        tags: {
            environment: env
        }
    })
}

export function createTrackerEcsConfiguration(subnets: Subnet[], lb: LoadBalancerConfiguration, parameters: SsmParameters): EcsConfiguration {
    const cluster = createEcsCluster();
    const taskDefinition = createTrackerTask(parameters);
    const securityGroup = createServiceSecurityGroup(lb.securityGroup);
    const service = new Service(MINDLEAPS_TRACKER_SERVICE_PULUMI_NAME, {
        cluster: cluster.arn,
        name: MINDLEAPS_TRACKER_SERVICE_NAME,
        launchType: 'FARGATE',
        taskDefinition: taskDefinition.arn,
        desiredCount: 2,
        networkConfiguration: {
            assignPublicIp: true,
            subnets: subnets.map(s => s.id),
            securityGroups: [securityGroup.id]
        },
        loadBalancers: [{
            containerName: 'mindleaps-tracker',
            containerPort: 3000,
            targetGroupArn: lb.targetGroup.arn
        }],
        tags: {
            environment: env
        }
    });

    return {cluster, service, taskDefinition};
}


function createContainerDefinitions(parameters: SsmParameters): Output<string> {
    return pulumi.interpolate `[{
        "name": "mindleaps-tracker",
        "image": "mindleaps/tracker",
        "portMappings": [
            {
                "protocol": "tcp",
                "containerPort": 3000
            }
        ],
        "environment": [{
            "name": "DATABASE_HOST",
            "value": "${getDatabaseFQDN()}"
        }, {
            "name": "RAILS_ENV",
            "value": "production"
        }],
        "secrets": [{
            "name": "DOMAIN",
            "valueFrom": "${parameters.deployDomain.arn}"
        }, {
            "name": "SECRET_KEY_BASE",
            "valueFrom": "${parameters.secretKeyBase.arn}"
        }, {
            "name": "DEVISE_SECRET_KEY",
            "valueFrom": "${parameters.deviseSecretKey.arn}"
        }, {
            "name": "GOOGLE_CLIENT_ID",
            "valueFrom": "${parameters.googleClientId.arn}"
        }, {
            "name": "GOOGLE_CLIENT_SECRET",
            "valueFrom": "${parameters.googleClientSecret.arn}"
        }, {
            "name": "SKYLIGHT_AUTHENTICATION",
            "valueFrom": "${parameters.skylightAuthentication.arn}"
        }, {
            "name": "NEW_RELIC_LICENSE_KEY",
            "valueFrom": "${parameters.newRelicLicenseKey.arn}"
        }, {
            "name": "NEW_RELIC_APP_NAME",
            "valueFrom": "${parameters.newRelicAppName.arn}"
        }, {
            "name": "DATABASE_USER",
            "valueFrom": "${parameters.databaseUsername.arn}"
        }, {
            "name": "DATABASE_PASSWORD",
            "valueFrom": "${parameters.databasePassword.arn}"
        }]
    }]`;
}

function createServiceSecurityGroup(albSecurityGroup: SecurityGroup) {
    return new SecurityGroup(SERVICE_SECURITY_GROUP_PULUMI_NAME, {
        name: SERVICE_SECURITY_GROUP_NAME,
        description: 'Security group for the tracker service',
        vpcId: albSecurityGroup.vpcId,
        ingress: [{
            securityGroups: [albSecurityGroup.id],
            protocol: 'tcp',
            fromPort: 3000,
            toPort: 3000
        }],
        egress: [{
            cidrBlocks: ['0.0.0.0/0'],
            protocol: 'tcp',
            fromPort: 0,
            toPort: 65535
        }]
    })
}

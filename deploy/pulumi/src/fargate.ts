import {SecurityGroup, Subnet, Vpc} from "@pulumi/aws/ec2";
import {Cluster, Service, TaskDefinition} from "@pulumi/aws/ecs";
import * as pulumi from "@pulumi/pulumi";
import {LoadBalancerConfiguration} from "./lb";
import {
    createDatabasePasswordParameter,
    createDatabaseUserNameParameter,
    createDeployDomainSsmParameter,
    createDeviseSecretKey,
    createGoogleClientIdSsnParameter,
    createGoogleClientSecretSsnParameter,
    createNewRelicAppNameSsmParameter,
    createNewRelicLicenseKeySsmParameter,
    createSecretKeyBaseSsnParameter,
    createSkylightAuthenticationSsnParameter
} from "./parameters";
import {Output} from "@pulumi/pulumi";
import {Role} from "@pulumi/aws/iam";
import {getDatabaseFQDN} from "./util";

const config = new pulumi.Config();

const env = config.require('environment');

const MINDLEAPS_TRACKER_TASK_PULUMI_NAME = 'MINDLEAPS_TRACKER_TASK';
const MINDLEAPS_TRACKER_TASK_NAME = pulumi.interpolate `task-${env}-mindleaps-tracker`;

const TASK_EXECUTION_ROLE_PULUMI_NAME = 'TASK_EXECUTION_ROLE';
const TASK_EXECUTION_ROLE_NAME = pulumi.interpolate `role-${env}-mindleaps-tracker`;

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

export function createTrackerTask(): TaskDefinition {
    return new TaskDefinition(MINDLEAPS_TRACKER_TASK_PULUMI_NAME, {
        containerDefinitions: createContainerDefinitions(),
        executionRoleArn: createTaskExecutionRole().arn,
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

function createTaskExecutionRole(): Role {
    return new Role(TASK_EXECUTION_ROLE_PULUMI_NAME, {
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
    })
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

export function createTrackerEcsConfiguration(subnets: Subnet[], lb: LoadBalancerConfiguration): EcsConfiguration {
    const cluster = createEcsCluster();
    const taskDefinition = createTrackerTask();
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


function createContainerDefinitions(): Output<string> {
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
        }],
        "secrets": [{
            "name": "DOMAIN",
            "valueFrom": "${createDeployDomainSsmParameter().arn}"
        }, {
            "name": "SECRET_KEY_BASE",
            "valueFrom": "${createSecretKeyBaseSsnParameter().arn}"
        }, {
            "name": "DEVISE_SECRET_KEY",
            "valueFrom": "${createDeviseSecretKey().arn}"
        }, {
            "name": "GOOGLE_CLIENT_ID",
            "valueFrom": "${createGoogleClientIdSsnParameter().arn}"
        }, {
            "name": "GOOGLE_CLIENT_SECRET",
            "valueFrom": "${createGoogleClientSecretSsnParameter().arn}"
        }, {
            "name": "SKYLIGHT_AUTHENTICATION",
            "valueFrom": "${createSkylightAuthenticationSsnParameter().arn}"
        }, {
            "name": "NEW_RELIC_LICENSE_KEY",
            "valueFrom": "${createNewRelicLicenseKeySsmParameter().arn}"
        }, {
            "name": "NEW_RELIC_APP_NAME",
            "valueFrom": "${createNewRelicAppNameSsmParameter().arn}"
        }, {
            "name": "RAILS_ENV",
            "valueFrom": "production"
        }, {
            "name": "DATABASE_USER",
            "valueFrom": "${createDatabaseUserNameParameter().arn}"
        }, {
            "name": "DATABASE_PASSWORD",
            "valueFrom": "${createDatabasePasswordParameter().arn}"
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

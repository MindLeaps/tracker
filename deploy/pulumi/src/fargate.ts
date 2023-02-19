import {SecurityGroup, Subnet, Vpc} from "@pulumi/aws/ec2";
import {Cluster, Service, TaskDefinition} from "@pulumi/aws/ecs";
import * as pulumi from "@pulumi/pulumi";
import {LoadBalancerConfiguration} from "./lb";
import {SsmParameters} from "./parameters";
import {Output} from "@pulumi/pulumi";
import {Role, RolePolicy} from "@pulumi/aws/iam";
import {getDatabaseFQDN} from "./util";
import {LogGroup} from "@pulumi/aws/cloudwatch";

const config = new pulumi.Config();

const image = config.get('image') || 'mindleaps/tracker:latest';

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

const TASK_LOG_GROUP_PULUMI_NAME = 'TASK_LOG_GROUP';
const TASK_LOG_GROUP_NAME = pulumi.interpolate `tracker-task-logs-${env}`;

export interface EcsConfiguration {
    cluster: Cluster;
    service: Service;
    taskDefinition: TaskDefinition;
    serviceSecurityGroup: SecurityGroup;
}

export function createTrackerTask(parameters: SsmParameters, logGroup: LogGroup): TaskDefinition {
    return new TaskDefinition(MINDLEAPS_TRACKER_TASK_PULUMI_NAME, {
        containerDefinitions: createContainerDefinitions(parameters, logGroup),
        executionRoleArn: createTaskExecutionRole(parameters, logGroup).arn,
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

function createLogGroup():LogGroup {
    return new LogGroup(TASK_LOG_GROUP_PULUMI_NAME, {
        name: TASK_LOG_GROUP_NAME,
        retentionInDays: 14,
        tags: {
            environment: env
        }
    });
}

function createTaskExecutionRole(parameters: SsmParameters, logGroup: LogGroup): Role {
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
            Statement: [{
                Action: 'logs:*',
                Effect: 'Allow',
                Resource: pulumi.interpolate `${logGroup.arn}/*`
            }, ...parameters.toPolicyStatements()]
        }
    });
    return role;
}

export function createEcsCluster(): Cluster {
    return new Cluster(MINDLEAPS_TRACKER_ECS_CLUSTER_PULUMI_NAME, {
        name: MINDLEAPS_TRACKER_ECS_CLUSTER_NAME,
        tags: {
            environment: env
        }
    })
}

export function createTrackerEcsConfiguration(subnets: Subnet[], lb: LoadBalancerConfiguration, parameters: SsmParameters): EcsConfiguration {
    const cluster = createEcsCluster();
    const logGroup = createLogGroup();
    const taskDefinition = createTrackerTask(parameters, logGroup);
    const serviceSecurityGroup = createServiceSecurityGroup(lb.securityGroup);
    const service = new Service(MINDLEAPS_TRACKER_SERVICE_PULUMI_NAME, {
        cluster: cluster.arn,
        name: MINDLEAPS_TRACKER_SERVICE_NAME,
        launchType: 'FARGATE',
        taskDefinition: taskDefinition.arn,
        desiredCount: 2,
        networkConfiguration: {
            assignPublicIp: true,
            subnets: subnets.map(s => s.id),
            securityGroups: [serviceSecurityGroup.id]
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

    return {cluster, service, taskDefinition, serviceSecurityGroup};
}


function createContainerDefinitions(parameters: SsmParameters, logGroup: LogGroup): Output<string> {
    return pulumi.interpolate `[{
        "name": "mindleaps-tracker",
        "image": "${image}",
        "command": ["bundle", "exec", "rails", "server"],
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
        }, {
            "name": "RAILS_SERVE_STATIC_FILES",
            "value": "1"
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
        }, {
            "name": "AWS_ACCESS_KEY_ID",
            "valueFrom": "${parameters.awsAccessKeyId.arn}"
        }, {
            "name": "AWS_SECRET_ACCESS_KEY",
            "valueFrom": "${parameters.awsSecretAccessKey.arn}"
        }],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${logGroup.name}",
                "awslogs-region": "${config.require('region')}",
                "awslogs-stream-prefix": "tracker-logs-${env}"
            }
        }
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
            fromPort: 0,
            toPort: 65535
        }],
        egress: [{
            cidrBlocks: ['0.0.0.0/0'],
            protocol: 'tcp',
            fromPort: 0,
            toPort: 65535
        }],
        tags: {
            environment: env
        }
    })
}

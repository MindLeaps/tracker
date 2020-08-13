import {SecurityGroup, Subnet, Vpc} from "@pulumi/aws/ec2";
import {Cluster, Service, TaskDefinition} from "@pulumi/aws/ecs";
import * as pulumi from "@pulumi/pulumi";
import {LoadBalancerConfiguration} from "./lb";

const config = new pulumi.Config();

const env = config.require('environment');

const MINDLEAPS_TRACKER_TASK_PULUMI_NAME = 'MINDLEAPS_TRACKER_TASK';
const MINDLEAPS_TRACKER_TASK_NAME = pulumi.interpolate `task-${env}-mindleaps-tracker`;

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
        desiredCount: 0,
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


function createContainerDefinitions(): string {
    return `[{
        "name": "mindleaps-tracker",
        "image": "mindleaps/tracker",
        "portMappings": [
            {
                "protocol": "tcp",
                "containerPort": 3000
            }
        ]
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

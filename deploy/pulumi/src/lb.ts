import {ApplicationLoadBalancer, LoadBalancer} from "@pulumi/aws/alb";
import * as pulumi from "@pulumi/pulumi";
import {Subnet} from "@pulumi/aws/ec2";
import {Bucket} from "@pulumi/aws/s3";
import {Listener} from "@pulumi/aws/lb";

const config = new pulumi.Config();

const env = config.require('environment');

const MAIN_LB_PULUMI_NAME = 'MAIN_LOAD_BALANCER';
const MAIN_LB_NAME = `alb-${env}-mindleaps-tracker`;

function createApplicationLoadBalancer(subnets: Subnet[], logBucket: Bucket) {
    return new LoadBalancer(MAIN_LB_PULUMI_NAME, {
        accessLogs: {
            enabled: true,
            bucket: logBucket.bucket,
            prefix: `${MAIN_LB_NAME}-access-logs/`
        },
        loadBalancerType: ApplicationLoadBalancer,
        subnets: subnets.map(s => s.id),
        name: MAIN_LB_NAME
    })
}

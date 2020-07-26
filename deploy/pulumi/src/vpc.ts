import * as aws from "@pulumi/aws";
import * as pulumi from "@pulumi/pulumi";
import {InternetGateway, Subnet, Vpc} from "@pulumi/aws/ec2";
const config = new pulumi.Config();

const env = config.require('environment');
const mainVpcAzs = config.requireObject<string[]>('main_vpc_availability_zones');

const VPC_NAME_PULUMI_NAME = 'MINDLEAPS_TRACKER_MAIN_REGION_VPC';
const VPC_NAME = `vpc-main-${env}-mindleaps-tracker`;

const INTERNET_GATEWAY_PULUMI_NAME = 'INTERNET_GATEWAY_FOR_MAIN_VPC';
const INTERNET_GATEWAY_NAME = `igw-main-${env}-mindleaps-tracker`;

export interface SubnetConfig {
    privateSubnets: Subnet[];
    publicSubnets: Subnet[];
}

export interface VpcConfig {
    vpc: Vpc;
    subnets: SubnetConfig;
    internetGateway: InternetGateway;
}

export function createFullVpc(): VpcConfig {
    const vpc = createVpc();
    return {
        vpc: vpc,
        internetGateway: createInternetGateway(vpc),
        subnets: createSubnets(vpc),
    }
}

function createVpc() {
    return new aws.ec2.Vpc(VPC_NAME_PULUMI_NAME, {
        cidrBlock: '172.31.0.0/16',
        tags: {
            environment: env,
            Name: VPC_NAME
        }
    });
}

function createInternetGateway(vpc: Vpc): InternetGateway {
    return new InternetGateway(INTERNET_GATEWAY_PULUMI_NAME, {
        vpcId: vpc.id,
        tags: {
            environment: env,
            Name: INTERNET_GATEWAY_NAME
        }
    })
}

function createSubnets(vpc :Vpc): SubnetConfig {
    return mainVpcAzs.reduce((acc: SubnetConfig, azName, index): SubnetConfig => {
        // Subnets with an even third octet are considered private, while the ones with an odd third octet are public
        acc.privateSubnets.push(new Subnet(`private-${index}`, {
            vpcId: vpc.id,
            availabilityZone: azName,
            cidrBlock: `172.31.${index * 2}.0/24`,
            tags: {
                Name: `private-${index}-${env}-${azName}`,
                environment: env
            }
        }));
        acc.publicSubnets.push(new Subnet(`public-${index}`, {
            vpcId: vpc.id,
            availabilityZone: azName,
            cidrBlock: `172.31.${index * 2 + 1}.0/24`,
            tags: {
                Name: `public-${index}-${env}-${azName}`,
                environment: env
            }
        }));
        return acc;
    }, {
        privateSubnets: [],
        publicSubnets: []
    });
}

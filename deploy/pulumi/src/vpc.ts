import * as aws from "@pulumi/aws";
import * as pulumi from "@pulumi/pulumi";
import {InternetGateway, Route, RouteTable, RouteTableAssociation, Subnet, Vpc} from "@pulumi/aws/ec2";
const config = new pulumi.Config();

const env = config.require('environment');
const mainVpcAzs = config.requireObject<string[]>('main_vpc_availability_zones');

const VPC_NAME_PULUMI_NAME = 'MINDLEAPS_TRACKER_MAIN_REGION_VPC';
const VPC_NAME = `vpc-main-${env}-mindleaps-tracker`;

const INTERNET_GATEWAY_PULUMI_NAME = 'INTERNET_GATEWAY_FOR_MAIN_VPC';
const INTERNET_GATEWAY_NAME = `igw-main-${env}-mindleaps-tracker`;

const PUBLIC_ROUTE_TABLE_PULUMI_NAME = 'PUBLIC_ROUTE_TABLE_FOR_MAIN_VPC';
const PUBLIC_ROUTE_TABLE_NAME = `route-table-public-main-${env}-mindleaps-tracker`;

const PRIVATE_ROUTE_TABLE_PULUMI_NAME = 'PRIVATE_ROUTE_TABLE_FOR_MAIN_VPC';
const PRIVATE_ROUTE_TABLE_NAME = `route-table-private-main-${env}-mindleaps-tracker`;

const PRIVATE_ROUTE_TABLE_ASSOCIATION_PULUMI_NAME = 'PRIVATE_ROUTE_TABLE_ASSOCIATION_FOR_MAIN_VPC';
const PUBLIC_ROUTE_TABLE_ASSOCIATION_PULUMI_NAME = 'PUBLIC_ROUTE_TABLE_ASSOCIATION_FOR_MAIN_VPC';

export interface SubnetConfig {
    privateSubnets: Subnet[];
    publicSubnets: Subnet[];
}

export interface VpcConfig {
    vpc: Vpc;
    subnets: SubnetConfig;
    internetGateway: InternetGateway;
}

class PrivateRouteTable extends RouteTable {}
class PublicRouteTable extends RouteTable {}

export function createFullVpc(): VpcConfig {
    const vpc = createVpc();
    const internetGateway = createInternetGateway(vpc)
    return {
        vpc: vpc,
        internetGateway: internetGateway,
        subnets: createSubnets(vpc, createPrivateRouteTable(vpc), createPublicRouteTable(vpc, internetGateway))
    }
}

function createVpc(): Vpc {
    return new aws.ec2.Vpc(VPC_NAME_PULUMI_NAME, {
        cidrBlock: '172.31.0.0/16',
        enableDnsHostnames: true,
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

function createPublicRouteTable(vpc: Vpc, igw: InternetGateway): PublicRouteTable {
    return new PublicRouteTable(PUBLIC_ROUTE_TABLE_PULUMI_NAME, {
        vpcId: vpc.id,
        routes: [{
            cidrBlock: '0.0.0.0/0',
            gatewayId: igw.id,
        }],
        tags: {
            environment: env,
            Name: PUBLIC_ROUTE_TABLE_NAME
        }
    })
}

function createPrivateRouteTable(vpc:Vpc):PrivateRouteTable {
    return new RouteTable(PRIVATE_ROUTE_TABLE_PULUMI_NAME, {
        vpcId: vpc.id,
        routes: [],
        tags: {
            environment: env,
            Name: PRIVATE_ROUTE_TABLE_NAME
        }
    })
}

function createSubnets(vpc :Vpc, privateRouteTable: PrivateRouteTable, publicRouteTable: PublicRouteTable): SubnetConfig {
    return mainVpcAzs.reduce((acc: SubnetConfig, azName, index): SubnetConfig => {
        // Subnets with an even third octet are considered private, while the ones with an odd third octet are public
        const newPrivateSubnet = new Subnet(`private-${index}`, {
            vpcId: vpc.id,
            availabilityZone: azName,
            cidrBlock: `172.31.${index * 2}.0/24`,
            tags: {
                Name: `private-${index}-${env}-${azName}`,
                environment: env
            }
        });
        new RouteTableAssociation(`${PRIVATE_ROUTE_TABLE_ASSOCIATION_PULUMI_NAME}-${index}`, {
            routeTableId: privateRouteTable.id,
            subnetId: newPrivateSubnet.id
        });
        acc.privateSubnets.push(newPrivateSubnet);

        const newPublicSubnet = new Subnet(`public-${index}`, {
            vpcId: vpc.id,
            availabilityZone: azName,
            cidrBlock: `172.31.${index * 2 + 1}.0/24`,
            tags: {
                Name: `public-${index}-${env}-${azName}`,
                environment: env
            }
        });
        new RouteTableAssociation(`${PUBLIC_ROUTE_TABLE_ASSOCIATION_PULUMI_NAME}-${index}`, {
            routeTableId: publicRouteTable.id,
            subnetId: newPublicSubnet.id
        });
        acc.publicSubnets.push(newPublicSubnet);
        return acc;
    }, {
        privateSubnets: [],
        publicSubnets: []
    });
}

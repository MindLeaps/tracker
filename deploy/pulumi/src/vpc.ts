import * as awsx from "@pulumi/awsx";
import * as pulumi from "@pulumi/pulumi";
const config = new pulumi.Config();

const VPC_NAME = config.require('vpc_name');

export function createVpc() {
    return new awsx.ec2.Vpc(VPC_NAME, {
        cidrBlock: '172.31.0.0/16'
    });
}

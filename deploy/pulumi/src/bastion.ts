import {InstanceTypes, KeyPair, SecurityGroup, Subnet, Vpc} from "@pulumi/aws/ec2";
import {ec2, getAmi} from "@pulumi/aws";
import * as pulumi from "@pulumi/pulumi";
import T2_Nano = InstanceTypes.T2_Nano;

const config = new pulumi.Config();
const env = config.require('environment');
const publicKey = config.requireSecret('publicSSH');
const KEY_PULUMI_NAME = 'bastion-ssh-key';
const KEY_NAME = `bastion-${env}-ssh-key`;

const BASTION_PULUMI_NAME = 'BASTION';
const BASTION_NAME = `BASTION-${env}`;

// Fetch latest
const BASTION_AMI = pulumi.output(getAmi({
    filters: [{
        name: "name",
        values: ['amzn2-ami-hvm-*'],
    }],
    owners: ["137112412989"], // This owner ID is Amazon
    mostRecent: true,
}));

const BASTION_SECURITY_GROUP_PULUMI_NAME = 'BASTION_SECURITY_GROUP';
const BASTION_SECURITY_GROUP_NAME = `sg-bastion-${env}-mindleaps-tracker`;

export function createBastionSecurityGroup(vpc: Vpc): SecurityGroup {
    return new SecurityGroup(BASTION_SECURITY_GROUP_PULUMI_NAME, {
        name: BASTION_SECURITY_GROUP_NAME,
        ingress: [{
            cidrBlocks: ['0.0.0.0/0'],
            protocol: 'tcp',
            fromPort: 22,
            toPort: 22
        }],
        egress: [{
            cidrBlocks: [vpc.cidrBlock],
            protocol: 'all',
            fromPort: 0,
            toPort: 65535
        }],
        tags:{
            environment: env
        }
    })
}

export function createBastionSSHKey():KeyPair {
    return new KeyPair(KEY_PULUMI_NAME, {
        keyName: KEY_NAME,
        publicKey: publicKey,
        tags: {
            environment: env
        }
    })
}

export function createBastion(subnet: Subnet, securityGroup: SecurityGroup, keyPair: KeyPair) {
    return new ec2.Instance(BASTION_PULUMI_NAME, {
        ami: BASTION_AMI.id,
        associatePublicIpAddress: true,
        instanceType: T2_Nano,
        keyName: keyPair.keyName,
        vpcSecurityGroupIds: [securityGroup.id],
        subnetId: subnet.id,
        tags: {
            Name: BASTION_NAME,
            environment: env
        }
    })
}

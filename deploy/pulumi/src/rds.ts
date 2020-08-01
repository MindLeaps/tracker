import {rds} from "@pulumi/aws";
import {Subnet, Vpc} from "@pulumi/aws/ec2";
import * as pulumi from "@pulumi/pulumi";
import {Instance, SubnetGroup} from "@pulumi/aws/rds";

const config = new pulumi.Config();

const env = config.require('environment');
const pgVersion = config.require('postgres_version');
const rdsInstanceClass = config.requireSecret('rds_instance_class');
const rdsUsername = config.requireSecret('rds_username');
const rdsPassword = config.requireSecret('rds_password');

const DB_SUBNET_GROUP_PULUMI_NAME = 'SUBNET_GROUP_FOR_MINDLEAPS_TRACKER_RDS_DATABASE';
const DB_SUBNET_GROUP_NAME = `subnet-group-${env}-mindleaps-tracker`

const RDS_DB_MINDLEAPS_TRACKER_NAME = `rds-${env}-mindleaps-tracker`;

export function createRdsSubnetGroup(subnets: Subnet[]): SubnetGroup {
    return new rds.SubnetGroup(DB_SUBNET_GROUP_PULUMI_NAME, {
        name: DB_SUBNET_GROUP_NAME,
        description: 'Subnet Group of Private Subnets for use by the Tracker RDS Database. Managed by Pulumi.',
        subnetIds: subnets.map(subnet => subnet.id),
        tags: {
            environment: env
        }
    })
}

export function createTrackerDatabase(subnetGroup: SubnetGroup): Instance {
    return new rds.Instance(RDS_DB_MINDLEAPS_TRACKER_NAME, {
        allocatedStorage: 20,
        engine: 'postgres',
        engineVersion: pgVersion,
        dbSubnetGroupName: subnetGroup.name,
        instanceClass: rdsInstanceClass,
        password: rdsPassword,
        publiclyAccessible: false,
        storageType: 'gp2',
        username: rdsUsername,
        tags: {
            environment: env
        }
    });
}

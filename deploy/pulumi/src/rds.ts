import {rds} from "@pulumi/aws";
import {SecurityGroup, Subnet, Vpc} from "@pulumi/aws/ec2";
import * as pulumi from "@pulumi/pulumi";
import {Instance, SubnetGroup} from "@pulumi/aws/rds";
import {getPolicyDocument, PolicyAttachment, Role} from "@pulumi/aws/iam";
import {RecordTypes, Zone} from "@pulumi/aws/route53";
import * as aws from "@pulumi/aws";

const config = new pulumi.Config();

const env = config.require('environment');
const pgVersion = config.require('postgres_version');
const rdsInstanceClass = config.require('rds_instance_class');
const rdsUsername = config.requireSecret('rds_username');
const rdsPassword = config.requireSecret('rds_password');
const databaseName = config.require('rds_db_name');

const DB_SUBNET_GROUP_PULUMI_NAME = 'SUBNET_GROUP_FOR_MINDLEAPS_TRACKER_RDS_DATABASE';
const DB_SUBNET_GROUP_NAME = `subnet-group-${env}-mindleaps-tracker`

const DB_REPLICA_SUBNET_GROUP_PULUMI_NAME = 'SUBNET_GROUP_FOR_MINDLEAPS_TRACKER_RDS_REPLICA_DATABASE';
const DB_REPLICA_SUBNET_GROUP_NAME = `subnet-group-${env}-mindleaps-tracker-replica`

const RDS_SECURITY_GROUP_PULUMI_NAME = 'RDS_SECURITY_GROUP';
const RDS_SECURITY_GROUP_NAME = `security-group-rds-${env}-mindleaps-tracker`;

const RDS_DB_MINDLEAPS_TRACKER_NAME = `rds-${env}-mindleaps-tracker`;
const RDS_DB_REPLICA_MINDLEAPS_TRACKER_NAME = `rds-${env}-replica-mindleaps-tracker`;

const RDS_ENHANCED_MONITORING_ROLE_PULUMI_NAME = 'RDS_ENHANCED_MONITORING_ROLE';
const RDS_ENHANCED_MONITORING_ROLE_NAME = `role-${env}-rds-enhanced-monitoring`;
const RDS_ENHANCED_MONITORING_ROLE_ATTACHMENT_PULUMI_NAME = 'RDS_ENHANCED_MONITORING_ROLE_ATTACHMENT';

const TRACKER_DB_RECORD_PULUMI_NAME = 'TRACKER_DB_RECORD_PULUMI_NAME';
const trackerDbSubdomain = config.requireSecret('tracker_db_subdomain');

const TRACKER_DB_REPLICA_RECORD_PULUMI_NAME = 'TRACKER_DB_REPLICA_RECORD_PULUMI_NAME';

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

export function createRdsSecurityGroup(vpc: Vpc, bastionSecurityGroup: SecurityGroup, ecsServiceSecurityGroup: SecurityGroup): SecurityGroup {
    return new SecurityGroup(RDS_SECURITY_GROUP_PULUMI_NAME, {
        name: RDS_SECURITY_GROUP_NAME,
        description: 'Security Group for RDS should only allow tcp traffic over PG 5432 port for bastion and web app',
        vpcId: vpc.id,
        ingress:[{
            securityGroups: [bastionSecurityGroup.id, ecsServiceSecurityGroup.id],
            protocol: 'tcp',
            fromPort: 5432,
            toPort: 5432
        }]
    });
}

function getMonitoringRolePolicy() {
    return pulumi.output(getPolicyDocument({
        statements: [{
            actions: ['sts:AssumeRole'],
            principals:[{
                identifiers: ['monitoring.rds.amazonaws.com'],
                type: 'Service'
            }]
        }]
    }));
}

function createEnhancedMonitoringRole(): Role {
    const role = new Role(RDS_ENHANCED_MONITORING_ROLE_PULUMI_NAME, {
        assumeRolePolicy: getMonitoringRolePolicy().json,
        name: RDS_ENHANCED_MONITORING_ROLE_NAME,
        tags: {
            environment: env
        }
    });

    new PolicyAttachment(RDS_ENHANCED_MONITORING_ROLE_ATTACHMENT_PULUMI_NAME, {
        policyArn: 'arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole',
        roles: [role]
    })

    return role;
}

export function createTrackerDatabase(subnetGroup: SubnetGroup, securityGroup: SecurityGroup, zone: Zone): Instance {
    const multiAz = config.getBoolean('rds_multi_az') as boolean;
    const instance = new rds.Instance(RDS_DB_MINDLEAPS_TRACKER_NAME, {
        allocatedStorage: 20,
        allowMajorVersionUpgrade: true,
        autoMinorVersionUpgrade: true,
        caCertIdentifier: "rds-ca-rsa4096-g1",
        maintenanceWindow: 'Sun:01:00-Sun:04:00',
        backupRetentionPeriod: 35,
        monitoringInterval: 60,
        monitoringRoleArn: createEnhancedMonitoringRole().arn,
        performanceInsightsEnabled: true,
        enabledCloudwatchLogsExports: ['postgresql', 'upgrade'],
        performanceInsightsRetentionPeriod: 7,
        engine: 'postgres',
        engineVersion: pgVersion,
        multiAz: multiAz,
        dbSubnetGroupName: subnetGroup.name,
        vpcSecurityGroupIds: [securityGroup.id],
        instanceClass: rdsInstanceClass,
        password: rdsPassword,
        name: databaseName,
        publiclyAccessible: false,
        storageType: 'gp2',
        username: rdsUsername,
        tags: {
            environment: env
        }
    });

    new aws.route53.Record(TRACKER_DB_RECORD_PULUMI_NAME, {
        name: trackerDbSubdomain,
        records: [instance.address],
        ttl: 3600,
        type: RecordTypes.CNAME,
        zoneId: zone.zoneId,
    });

    return instance;
}

export function createTrackerDatabaseReplica(sourceDb: Instance, zone: Zone): Instance {
    const trackerReplicaDbSubdomain = config.requireSecret('tracker_db_replica_subdomain');

    const instance = new rds.Instance(RDS_DB_REPLICA_MINDLEAPS_TRACKER_NAME, {
        allocatedStorage: 20,
        allowMajorVersionUpgrade: true,
        autoMinorVersionUpgrade: true,
        maintenanceWindow: 'Sun:01:00-Sun:04:00',
        enabledCloudwatchLogsExports: ['postgresql', 'upgrade'],
        publiclyAccessible: true,
        instanceClass: 'db.t2.micro',
        replicateSourceDb: sourceDb.identifier,
        tags: {
            environment: env
        }
    });

    new aws.route53.Record(TRACKER_DB_REPLICA_RECORD_PULUMI_NAME, {
        name: trackerReplicaDbSubdomain,
        records: [instance.address],
        ttl: 3600,
        type: RecordTypes.CNAME,
        zoneId: zone.zoneId,
    });

    return instance;
}

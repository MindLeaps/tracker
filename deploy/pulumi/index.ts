import {createS3LogsBucket, createS3PhotoBucket} from "./src/s3";
import {createFullVpc} from "./src/vpc";
import {createCertificate, createHostedZone, createZoneRecords} from "./src/dns";
import {createRdsSecurityGroup, createRdsSubnetGroup, createTrackerDatabase} from "./src/rds";
import {createBastion, createBastionSecurityGroup, createBastionSSHKey} from "./src/bastion";
import {createApplicationLoadBalancer} from "./src/lb";
import {createEcsCluster, createTrackerEcsConfiguration} from "./src/fargate";

const loggingBucket = createS3LogsBucket();
const bucket = createS3PhotoBucket(loggingBucket.bucket);

const vpc = createFullVpc();

const bastionSecurityGroup = createBastionSecurityGroup(vpc.vpc);
const bastionSSHKey = createBastionSSHKey();
const bastion = createBastion(vpc.subnets.publicSubnets[0], bastionSecurityGroup, bastionSSHKey);

const rdsSubnetGroup = createRdsSubnetGroup(vpc.subnets.privateSubnets)
const rdsSecurityGroup = createRdsSecurityGroup(vpc.vpc, bastionSecurityGroup)
const rdsInstance = createTrackerDatabase(rdsSubnetGroup, rdsSecurityGroup);

const certificate = createCertificate();

const alb = createApplicationLoadBalancer(vpc.vpc, vpc.subnets.publicSubnets, loggingBucket.bucket, certificate);

const ecsCluster = createTrackerEcsConfiguration(vpc.subnets.publicSubnets, alb);

const zone = createHostedZone();
const zoneRecords = createZoneRecords(zone, bastion, certificate);

import {createS3LogsBucket, createS3PhotoBucket} from "./src/s3";
import {createFullVpc} from "./src/vpc";
import {createCertificate, createHostedZone, createZoneRecords} from "./src/dns";
import {createRdsSecurityGroup, createRdsSubnetGroup, createTrackerDatabase} from "./src/rds";
import {createBastion, createBastionSecurityGroup, createBastionSSHKey} from "./src/bastion";

const loggingBucket = createS3LogsBucket();
const bucket = createS3PhotoBucket(loggingBucket);

const vpc = createFullVpc();

const bastionSecurityGroup = createBastionSecurityGroup(vpc.vpc);
const bastionSSHKey = createBastionSSHKey();
const bastion = createBastion(vpc.subnets.publicSubnets[0], bastionSecurityGroup, bastionSSHKey);

const rdsSubnetGroup = createRdsSubnetGroup(vpc.subnets.privateSubnets)
const rdsSecurityGroup = createRdsSecurityGroup(vpc.vpc, bastionSecurityGroup)
export const rdsInstance = createTrackerDatabase(rdsSubnetGroup, rdsSecurityGroup);

const certificate = createCertificate();

const zone = createHostedZone();
const zoneRecords = createZoneRecords(zone, bastion, certificate);
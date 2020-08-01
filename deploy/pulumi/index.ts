import {createS3LogsBucket, createS3PhotoBucket} from "./src/s3";
import {createFullVpc} from "./src/vpc";
import {createHostedZone, createZoneRecords} from "./src/dns";
import {createRdsSubnetGroup, createTrackerDatabase} from "./src/rds";
import {createBastion, createBastionSecurityGroup, createBastionSSHKey} from "./src/bastion";

const loggingBucket = createS3LogsBucket();
const bucket = createS3PhotoBucket(loggingBucket);
const zone = createHostedZone();
const zoneRecords = createZoneRecords(zone);

export const vpc = createFullVpc();

// const rdsSubnetGroup = createRdsSubnetGroup(vpc.subnets.privateSubnets)
// export const rdsInstance = createTrackerDatabase(rdsSubnetGroup);

const bastionSecurityGroup = createBastionSecurityGroup(vpc.vpc);
const bastionSSHKey = createBastionSSHKey();
export const bastion = createBastion(vpc.subnets.publicSubnets[0], bastionSecurityGroup, bastionSSHKey);

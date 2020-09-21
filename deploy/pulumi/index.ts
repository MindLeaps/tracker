import {createS3LogsBucket, createS3PhotoBucket} from "./src/s3";
import {createFullVpc} from "./src/vpc";
import {createCertificate, createHostedZone, createZoneCertificateValidation, createZoneRecords} from "./src/dns";
import {createRdsSecurityGroup, createRdsSubnetGroup, createTrackerDatabase} from "./src/rds";
import {createBastion, createBastionSecurityGroup, createBastionSSHKey} from "./src/bastion";
import {createApplicationLoadBalancer} from "./src/lb";
import {createEcsCluster, createTrackerEcsConfiguration} from "./src/fargate";
import {SsmParameters} from "./src/parameters";

const loggingBucket = createS3LogsBucket();
const bucket = createS3PhotoBucket(loggingBucket.bucket);

const vpc = createFullVpc();

const bastionSecurityGroup = createBastionSecurityGroup(vpc.vpc);
const bastionSSHKey = createBastionSSHKey();
const bastion = createBastion(vpc.subnets.publicSubnets[0], bastionSecurityGroup, bastionSSHKey);

const certificate = createCertificate();
const zone = createHostedZone();
const certificateValidation = createZoneCertificateValidation(zone, certificate);

const alb = createApplicationLoadBalancer(vpc.vpc, vpc.subnets.publicSubnets, loggingBucket.bucket, certificate);

const ssmParameters = new SsmParameters();
const ecsCluster = createTrackerEcsConfiguration(vpc.subnets.publicSubnets, alb, ssmParameters);

const rdsSubnetGroup = createRdsSubnetGroup(vpc.subnets.privateSubnets);
const rdsSecurityGroup = createRdsSecurityGroup(vpc.vpc, bastionSecurityGroup, ecsCluster.serviceSecurityGroup);
const rdsInstance = createTrackerDatabase(rdsSubnetGroup, rdsSecurityGroup);

const zoneRecords = createZoneRecords(zone, bastion, rdsInstance, alb.loadBalancer);

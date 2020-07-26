import {createS3LogsBucket, createS3PhotoBucket} from "./src/s3";
import {createFullVpc} from "./src/vpc";
import {createHostedZone, createZoneRecords} from "./src/dns";

const loggingBucket = createS3LogsBucket();
const bucket = createS3PhotoBucket(loggingBucket);
const zone = createHostedZone();
const zoneRecords = createZoneRecords(zone);

export const vpc = createFullVpc();

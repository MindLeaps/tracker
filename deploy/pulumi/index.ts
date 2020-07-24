import {createS3LogsBucket, createS3PhotoBucket} from "./src/s3";
import {createVpc} from "./src/vpc";

const loggingBucket = createS3LogsBucket();
const bucket = createS3PhotoBucket(loggingBucket);

// const vpc = createVpc();

export const bucketName = bucket.id;
// export const vpcId = vpc.id;
// export const vpcPrivateSubnetIds = vpc.privateSubnetIds;
// export const vpcPublicSubnetIds = vpc.publicSubnetIds;

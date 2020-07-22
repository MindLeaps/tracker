import {createS3Bucket} from "./src/s3";
import {createVpc} from "./src/vpc";

const bucket = createS3Bucket();
// const vpc = createVpc();

export const bucketName = bucket.id;
// export const vpcId = vpc.id;
// export const vpcPrivateSubnetIds = vpc.privateSubnetIds;
// export const vpcPublicSubnetIds = vpc.publicSubnetIds;

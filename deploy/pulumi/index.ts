import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";
import * as awsx from "@pulumi/awsx";
import {createS3Bucket} from "./src/s3";

const bucket = createS3Bucket();

// Export the name of the bucket
export const bucketName = bucket.id;

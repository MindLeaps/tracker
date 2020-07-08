import * as aws from "@pulumi/aws";
import {Bucket} from "@pulumi/aws/s3";
import * as pulumi from "@pulumi/pulumi";
const config = new pulumi.Config();

const S3_BUCKET_NAME = config.require('s3_bucket_name');

export function createS3Bucket(): Bucket {
    return new aws.s3.Bucket('mindleaps-tracker-staging-s3-bucket', {
        bucket: S3_BUCKET_NAME,
        grants: [
            {
                id: '1d56e53e4b3aa87cb852387b8d86875246c76b45b5e9ad8ed5e53e80372bcbd6',
                type: 'CanonicalUser',
                permissions: ['FULL_CONTROL']
            },
            {
                permissions: ['READ_ACP', 'WRITE'],
                type: 'Group',
                uri: 'http://acs.amazonaws.com/groups/s3/LogDelivery'
            }
        ],
        loggings: [{
            targetBucket: S3_BUCKET_NAME,
            targetPrefix: 'logs/'
        }]
    }, { import: S3_BUCKET_NAME })
}

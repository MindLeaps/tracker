import * as aws from "@pulumi/aws";
import {Bucket, PrivateAcl, PublicReadAcl} from "@pulumi/aws/s3";
import * as pulumi from "@pulumi/pulumi";
const config = new pulumi.Config();
const region = config.require('region');
const env = config.require('environment');

const S3_PHOTO_BUCKET_PULUMI_NAME = 'S3_PHOTO_BUCKET_LOGS';
const S3_PHOTO_BUCKET_NAME = config.require('s3_photo_bucket_name');

const S3_LOGS_BUCKET_PULUMI_NAME = 'S3_BUCKET_LOGS';
const S3_LOGS_BUCKET_NAME = config.require('s3_logs_bucket_name');


export function createS3LogsBucket(): Bucket {
    return new aws.s3.Bucket(S3_LOGS_BUCKET_PULUMI_NAME, {
        bucket: S3_LOGS_BUCKET_NAME,
        grants: [
            {
                permissions: ['READ_ACP', 'WRITE'],
                type: 'Group',
                uri: 'http://acs.amazonaws.com/groups/s3/LogDelivery'
            }
        ],
        serverSideEncryptionConfiguration: { rule: { applyServerSideEncryptionByDefault: { sseAlgorithm: 'AES256' } } },
        region: region,
        lifecycleRules: [{
            enabled: true,
            transitions: [
                {
                    days: 30,
                    storageClass: 'ONEZONE_IA'
                }
            ]
        }],
        tags: {
            environment: env
        }
    })
}

export function createS3PhotoBucket(logsBucket: Bucket): Bucket {
    return new aws.s3.Bucket(S3_PHOTO_BUCKET_PULUMI_NAME, {
        bucket: S3_PHOTO_BUCKET_NAME,
        region: region,
        acl: PublicReadAcl,
        serverSideEncryptionConfiguration: { rule: { applyServerSideEncryptionByDefault: { sseAlgorithm: 'AES256' } } },
        loggings: [{
            targetBucket: logsBucket.bucket,
            targetPrefix: `${S3_PHOTO_BUCKET_NAME}/`
        }],
        tags: {
            environment: env
        }
    });
}

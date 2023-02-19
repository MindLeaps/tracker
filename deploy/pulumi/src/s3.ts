import * as aws from "@pulumi/aws";
import {Bucket, BucketPolicy, PrivateAcl, PublicReadAcl} from "@pulumi/aws/s3";
import * as pulumi from "@pulumi/pulumi";
const config = new pulumi.Config();
const env = config.require('environment');

const S3_PHOTO_BUCKET_PULUMI_NAME = 'S3_PHOTO_BUCKET_LOGS';
const S3_PHOTO_BUCKET_NAME = config.require('s3_photo_bucket_name');

const S3_LOGS_BUCKET_PULUMI_NAME = 'S3_BUCKET_LOGS';
const S3_LOGS_BUCKET_NAME = config.require('s3_logs_bucket_name');

const LOGGING_BUCKET_POLICY_PULUMI_NAME = 'LOGGING_BUCKET_POLICY';

function createLoggingBucketPolicy(bucket: Bucket): BucketPolicy {
    const elbAccountId = config.require('elb_account_id');
    return new BucketPolicy(LOGGING_BUCKET_POLICY_PULUMI_NAME, {
        bucket: bucket.id,
        policy: {
            Version: '2012-10-17',
            Statement: [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "AWS": pulumi.interpolate `arn:aws:iam::${elbAccountId}:root`
                    },
                    "Action": "s3:PutObject",
                    "Resource": pulumi.interpolate `arn:aws:s3:::${bucket.bucket}/*`
                },
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Service": "delivery.logs.amazonaws.com"
                    },
                    "Action": "s3:PutObject",
                    "Resource": pulumi.interpolate `arn:aws:s3:::${bucket.bucket}/*`
                },
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Service": "delivery.logs.amazonaws.com"
                    },
                    "Action": "s3:GetBucketAcl",
                    "Resource": pulumi.interpolate `arn:aws:s3:::${bucket.bucket}`
                }
            ]
        }
    });
}

export function createS3LogsBucket(): {bucket: Bucket, policy: BucketPolicy} {
    const bucket = new aws.s3.Bucket(S3_LOGS_BUCKET_PULUMI_NAME, {
        bucket: S3_LOGS_BUCKET_NAME,
        grants: [
            {
                permissions: ['READ_ACP', 'WRITE'],
                type: 'Group',
                uri: 'http://acs.amazonaws.com/groups/s3/LogDelivery'
            }
        ],
        serverSideEncryptionConfiguration: { rule: { applyServerSideEncryptionByDefault: { sseAlgorithm: 'AES256' } } },
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
    });
    const bucketPolicy = createLoggingBucketPolicy(bucket);
    return {bucket: bucket, policy: bucketPolicy};
}

export function createS3PhotoBucket(logsBucket: Bucket): Bucket {
    return new aws.s3.Bucket(S3_PHOTO_BUCKET_PULUMI_NAME, {
        bucket: S3_PHOTO_BUCKET_NAME,
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

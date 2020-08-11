import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";
import {RecordTypes, Zone} from "@pulumi/aws/route53";
import {Instance} from "@pulumi/aws/ec2";
import {Certificate} from "@pulumi/aws/acm";
import {getFQDN} from "./util";

const config = new pulumi.Config();
const env = config.require('environment');

const DOMAIN_PULUMI_NAME = 'MINDLEAPS_TRACKER_DOMAIN_NAME';
const domainName = config.requireSecret('domain_name');

const TRACKER_APP_A_RECORD_PULUMI_NAME = 'TRACKER_APP_A_RECORD_PULUMI_NAME';
const trackerAppSubdomain = config.requireSecret('tracker_app_subdomain');
const trackerAppDestination = config.requireSecret('tracker_app_destination')

const TRACKER_DB_RECORD_PULUMI_NAME = 'TRACKER_DB_RECORD_PULUMI_NAME';
const trackerDbSubdomain = config.requireSecret('tracker_db_subdomain');
const trackerDbDestination = config.requireSecret('tracker_db_destination')

const TRACKER_BASTION_RECORD_PULUMI_NAME = 'TRACKER_BASTION_RECORD_PULUMI_NAME';

const TRACKER_SSL_CERTIFICATE_PULUMI_NAME = 'TRACKER_SSL_CERTIFICATE';
const TRACKER_SSL_CERTIFICATE_VALIDATION_PULUMI_NAME = 'TRACKER_SSL_CERTIFICATE_VALIDATION';

export function createHostedZone(): Zone {
    return new aws.route53.Zone(DOMAIN_PULUMI_NAME, {
        name: domainName,
        tags: {
            environment: env
        }
    });
}

export function createZoneRecords(zone: Zone, bastionInstance: Instance, certificate: Certificate): aws.route53.Record[] {
    return [
        new aws.route53.Record(TRACKER_APP_A_RECORD_PULUMI_NAME, {
            name: trackerAppSubdomain,
            records: [trackerAppDestination],
            ttl: 3600,
            type: RecordTypes.A,
            zoneId: zone.zoneId,
        }),
        new aws.route53.Record(TRACKER_DB_RECORD_PULUMI_NAME, {
            name: trackerDbSubdomain,
            records: [trackerDbDestination],
            ttl: 3600,
            type: RecordTypes.CNAME,
            zoneId: zone.zoneId,
        }),
        new aws.route53.Record(TRACKER_BASTION_RECORD_PULUMI_NAME, {
            name: 'bastion',
            records: [bastionInstance.publicIp],
            ttl: 3600,
            type: RecordTypes.A,
            zoneId: zone.zoneId,
        }),
        new aws.route53.Record(TRACKER_SSL_CERTIFICATE_VALIDATION_PULUMI_NAME, {
            name: certificate.domainValidationOptions.apply(validations => validations[0].resourceRecordName),
            records: [certificate.domainValidationOptions.apply(validations => validations[0].resourceRecordValue)],
            type: certificate.domainValidationOptions.apply(validations => validations[0].resourceRecordType),
            ttl: 3600,
            zoneId: zone.zoneId
        })
    ];
}

export function createCertificate(): Certificate {
    return new Certificate(TRACKER_SSL_CERTIFICATE_PULUMI_NAME, {
        domainName: getFQDN(),
        validationMethod: 'DNS',
        tags: {
            environment: env
        }
    });
}

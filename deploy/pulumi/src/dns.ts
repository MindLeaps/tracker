import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";
import {RecordTypes, Zone} from "@pulumi/aws/route53";

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

export function createHostedZone(): Zone {
    return new aws.route53.Zone(DOMAIN_PULUMI_NAME, {
        name: domainName,
        tags: {
            environment: env
        }
    });
}

export function createZoneRecords(zone: Zone): aws.route53.Record[] {
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
    ];
}

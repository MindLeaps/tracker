import * as pulumi from "@pulumi/pulumi";
import {Output} from "@pulumi/pulumi";

const config = new pulumi.Config();

const domain = config.requireSecret('domain_name');
const subdomain = config.getSecret('tracker_app_subdomain');
const trackerDbSubdomain = config.requireSecret('tracker_db_subdomain');

export function getFQDN() {
    if (!subdomain) {
        return domain;
    }
    return subdomain.apply(sub => {
       if (!sub || sub.length === 0) {
           return domain;
       }
        return pulumi.interpolate `${sub}.${domain}`;
    });
}

export function getDatabaseFQDN(): Output<string> {
    return trackerDbSubdomain.apply(sub => pulumi.interpolate `${sub}.${domain}`);
}

export function getTrackerSubdomain(): string {
    if (!subdomain) {
        return '';
    }
    let result = '';
    subdomain.apply(sub => {
        if (sub && sub.length > 0) {
            result = sub;
        }
    });
    return result;
}
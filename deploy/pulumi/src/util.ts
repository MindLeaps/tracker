import * as pulumi from "@pulumi/pulumi";

const config = new pulumi.Config();

const domain = config.requireSecret('domain_name');
const subdomain = config.getSecret('tracker_app_subdomain');

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

import * as pulumi from "@pulumi/pulumi";

const config = new pulumi.Config();

const domain = config.requireSecret('domain_name');
const subdomain = config.getSecret('tracker_app_subdomain');

export function getFQDN() {
    return pulumi.interpolate `${subdomain}.${domain}`;
}

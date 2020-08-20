import * as pulumi from "@pulumi/pulumi";
import {getFQDN} from "./util";
import {Parameter, SecureStringParameter, StringParameter} from "@pulumi/aws/ssm";

const config = new pulumi.Config();
const env = config.require('environment');

const PARAMETER_PREFIX = `/mindleaps-tracker/${env}`;

const DEPLOY_DOMAIN_PARAM_PULUMI_NAME = 'DEPLOY_DOMAIN';
const DEPLOY_DOMAIN_PARAM_NAME = `${PARAMETER_PREFIX}/deploy_domain`;

const SECRET_KEY_BASE_PARAM_PULUMI_NAME = 'SECRET_KEY_BASE';
const SECRET_KEY_BASE_PARAM_NAME = `${PARAMETER_PREFIX}/secret_key_base`;

const DEVISE_SECRET_KEY_PARAM_PULUMI_NAME = 'DEVISE_SECRET_KEY';
const DEVISE_SECRET_KEY_PARAM_NAME = `${PARAMETER_PREFIX}/devise_secret_key`;

const GOOGLE_CLIENT_ID_PARAM_PULUMI_NAME = 'GOOGLE_CLIENT_ID';
const GOOGLE_CLIENT_ID_PARAM_NAME = `${PARAMETER_PREFIX}/google_client_id`;

const GOOGLE_CLIENT_SECRET_PARAM_PULUMI_NAME = 'GOOGLE_CLIENT_SECRET';
const GOOGLE_CLIENT_SECRET_PARAM_NAME = `${PARAMETER_PREFIX}/google_client_secret`;

const SKYLIGHT_AUTHENTICATION_PARAM_PULUMI_NAME = 'SKYLIGHT_AUTHENTICATION';
const SKYLIGHT_AUTHENTICATION_PARAM_NAME = `${PARAMETER_PREFIX}/skylight_authentication`;

const NEW_RELIC_LICENSE_KEY_PARAM_PULUMI_NAME = 'NEW_RELIC_LICENSE_KEY';
const NEW_RELIC_LICENSE_KEY_PARAM_NAME = `${PARAMETER_PREFIX}/new_relic_license_key`;

const NEW_RELIC_APP_NAME_PARAM_PULUMI_NAME = 'NEW_RELIC_APP_NAME';
const NEW_RELIC_APP_NAME_PARAM_NAME = `${PARAMETER_PREFIX}/new_relic_app_name`;

const RDS_USERNAME_PARAM_PULUMI_NAME = 'RDS_USERNAME';
const RDS_USERNAME_PARAM_NAME = `${PARAMETER_PREFIX}/rds_username`;

const RDS_PASSWORD_PARAM_PULUMI_NAME = 'RDS_PASSWORD';
const RDS_PASSWORD_PARAM_NAME = `${PARAMETER_PREFIX}/rds_password`;

export function createDeployDomainSsmParameter(): Parameter {
    return new Parameter(DEPLOY_DOMAIN_PARAM_PULUMI_NAME, {
        type: StringParameter,
        name: DEPLOY_DOMAIN_PARAM_NAME,
        value: getFQDN()
    });
}

export function createSecretKeyBaseSsnParameter(): Parameter {
    return new Parameter(SECRET_KEY_BASE_PARAM_PULUMI_NAME, {
        type: SecureStringParameter,
        name: SECRET_KEY_BASE_PARAM_NAME,
        value: config.requireSecret('secret_key_base')
    });
}

export function createDeviseSecretKey(): Parameter {
    return new Parameter(DEVISE_SECRET_KEY_PARAM_PULUMI_NAME, {
        type: SecureStringParameter,
        name: DEVISE_SECRET_KEY_PARAM_NAME,
        value: config.requireSecret('devise_secret_key')
    });
}

export function createGoogleClientIdSsnParameter(): Parameter {
    return new Parameter(GOOGLE_CLIENT_ID_PARAM_PULUMI_NAME, {
        type: SecureStringParameter,
        name: GOOGLE_CLIENT_ID_PARAM_NAME,
        value: config.requireSecret('google_client_id')
    });
}

export function createGoogleClientSecretSsnParameter(): Parameter {
    return new Parameter(GOOGLE_CLIENT_SECRET_PARAM_PULUMI_NAME, {
        type: SecureStringParameter,
        name: GOOGLE_CLIENT_SECRET_PARAM_NAME,
        value: config.requireSecret('google_client_secret')
    });
}

export function createSkylightAuthenticationSsnParameter(): Parameter {
    return new Parameter(SKYLIGHT_AUTHENTICATION_PARAM_PULUMI_NAME, {
        type: SecureStringParameter,
        name: SKYLIGHT_AUTHENTICATION_PARAM_NAME,
        value: config.requireSecret('skylight_authentication')
    });
}

export function createNewRelicLicenseKeySsmParameter(): Parameter {
    return new Parameter(NEW_RELIC_LICENSE_KEY_PARAM_PULUMI_NAME, {
        type: SecureStringParameter,
        name: NEW_RELIC_LICENSE_KEY_PARAM_NAME,
        value: config.requireSecret('new_relic_license_key')
    });
}

export function createNewRelicAppNameSsmParameter(): Parameter {
    return new Parameter(NEW_RELIC_APP_NAME_PARAM_PULUMI_NAME, {
        type: SecureStringParameter,
        name: NEW_RELIC_APP_NAME_PARAM_NAME,
        value: config.requireSecret('new_relic_app_name')
    });
}

export function createDatabaseUserNameParameter(): Parameter {
    return new Parameter(RDS_USERNAME_PARAM_PULUMI_NAME, {
        type: SecureStringParameter,
        name: RDS_USERNAME_PARAM_NAME,
        value: config.requireSecret('rds_username')
    });
}

export function createDatabasePasswordParameter(): Parameter {
    return new Parameter(RDS_PASSWORD_PARAM_PULUMI_NAME, {
        type: SecureStringParameter,
        name: RDS_PASSWORD_PARAM_NAME,
        value: config.requireSecret('rds_password')
    });
}

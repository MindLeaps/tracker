import * as pulumi from "@pulumi/pulumi";
import {getFQDN} from "./util";
import {Parameter, SecureStringParameter, StringParameter} from "@pulumi/aws/ssm";
import {PolicyStatement} from "@pulumi/aws/iam";

const config = new pulumi.Config();
const env = config.require('environment');

export const PARAMETER_PREFIX = `/mindleaps-tracker/${env}`;

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

const AWS_ACCESS_KEY_ID_PULUMI_NAME = 'ACCESS_KEY_ID';
const AWS_ACCESS_KEY_ID_NAME = `${PARAMETER_PREFIX}/aws_access_key_id`;

const AWS_SECRET_ACCESS_KEY_PULUMI_NAME = 'SECRET_ACCESS_KEY';
const AWS_SECRET_ACCESS_KEY_NAME = `${PARAMETER_PREFIX}/aws_secret_access_key`;

export class SsmParameters {
    deployDomain: Parameter;
    secretKeyBase: Parameter;
    deviseSecretKey: Parameter;
    googleClientId: Parameter;
    googleClientSecret: Parameter;
    skylightAuthentication: Parameter;
    newRelicLicenseKey: Parameter;
    newRelicAppName: Parameter;
    databaseUsername: Parameter;
    databasePassword: Parameter;
    awsAccessKeyId: Parameter;
    awsSecretAccessKey: Parameter;

    constructor() {
        this.deployDomain = this.createDeployDomainSsmParameter()
        this.secretKeyBase = this.createSecretKeyBaseSsnParameter()
        this.deviseSecretKey = this.createDeviseSecretKey()
        this.googleClientId = this.createGoogleClientIdSsnParameter()
        this.googleClientSecret = this.createGoogleClientSecretSsnParameter()
        this.skylightAuthentication = this.createSkylightAuthenticationSsnParameter()
        this.newRelicLicenseKey = this.createNewRelicLicenseKeySsmParameter()
        this.newRelicAppName = this.createNewRelicAppNameSsmParameter()
        this.databaseUsername = this.createDatabaseUserNameParameter()
        this.databasePassword = this.createDatabasePasswordParameter()
        this.awsAccessKeyId = this.createAwsAccessKeyId();
        this.awsSecretAccessKey = this.createAwsSecretAccessKey();
    }

    toArray(): Parameter[] {
        return [this.deployDomain, this.secretKeyBase, this.deviseSecretKey, this.googleClientId, this.googleClientSecret, this.skylightAuthentication, this.newRelicLicenseKey,
            this.newRelicAppName, this.databaseUsername, this.databasePassword, this.awsAccessKeyId, this.awsSecretAccessKey];
    }

    toPolicyStatements(): PolicyStatement[] {
        return this.toArray().map(p => ({
            Action: 'ssm:GetParameters',
            Effect: 'Allow',
            Resource: p.arn
        }));
    }

    private createDeployDomainSsmParameter(): Parameter {
        return new Parameter(DEPLOY_DOMAIN_PARAM_PULUMI_NAME, {
            type: StringParameter,
            name: DEPLOY_DOMAIN_PARAM_NAME,
            value: getFQDN()
        });
    }
    private createSecretKeyBaseSsnParameter(): Parameter {
        return new Parameter(SECRET_KEY_BASE_PARAM_PULUMI_NAME, {
            type: SecureStringParameter,
            name: SECRET_KEY_BASE_PARAM_NAME,
            value: config.requireSecret('secret_key_base')
        });
    }
    private createDeviseSecretKey(): Parameter {
        return new Parameter(DEVISE_SECRET_KEY_PARAM_PULUMI_NAME, {
            type: SecureStringParameter,
            name: DEVISE_SECRET_KEY_PARAM_NAME,
            value: config.requireSecret('devise_secret_key')
        });
    }
    private createGoogleClientIdSsnParameter(): Parameter {
        return new Parameter(GOOGLE_CLIENT_ID_PARAM_PULUMI_NAME, {
            type: SecureStringParameter,
            name: GOOGLE_CLIENT_ID_PARAM_NAME,
            value: config.requireSecret('google_client_id')
        });
    }
    private createGoogleClientSecretSsnParameter(): Parameter {
        return new Parameter(GOOGLE_CLIENT_SECRET_PARAM_PULUMI_NAME, {
            type: SecureStringParameter,
            name: GOOGLE_CLIENT_SECRET_PARAM_NAME,
            value: config.requireSecret('google_client_secret')
        });
    }
    private createSkylightAuthenticationSsnParameter(): Parameter {
        return new Parameter(SKYLIGHT_AUTHENTICATION_PARAM_PULUMI_NAME, {
            type: SecureStringParameter,
            name: SKYLIGHT_AUTHENTICATION_PARAM_NAME,
            value: config.requireSecret('skylight_authentication')
        });
    }
    private createNewRelicLicenseKeySsmParameter(): Parameter {
        return new Parameter(NEW_RELIC_LICENSE_KEY_PARAM_PULUMI_NAME, {
            type: SecureStringParameter,
            name: NEW_RELIC_LICENSE_KEY_PARAM_NAME,
            value: config.requireSecret('new_relic_license_key')
        });
    }
    private createNewRelicAppNameSsmParameter(): Parameter {
        return new Parameter(NEW_RELIC_APP_NAME_PARAM_PULUMI_NAME, {
            type: SecureStringParameter,
            name: NEW_RELIC_APP_NAME_PARAM_NAME,
            value: config.requireSecret('new_relic_app_name')
        });
    }
    private createDatabaseUserNameParameter(): Parameter {
        return new Parameter(RDS_USERNAME_PARAM_PULUMI_NAME, {
            type: SecureStringParameter,
            name: RDS_USERNAME_PARAM_NAME,
            value: config.requireSecret('rds_username')
        });
    }
    private createDatabasePasswordParameter(): Parameter {
        return new Parameter(RDS_PASSWORD_PARAM_PULUMI_NAME, {
            type: SecureStringParameter,
            name: RDS_PASSWORD_PARAM_NAME,
            value: config.requireSecret('rds_password')
        });
    }
    private createAwsAccessKeyId(): Parameter {
        return new Parameter(AWS_ACCESS_KEY_ID_PULUMI_NAME, {
            type: SecureStringParameter,
            name: AWS_ACCESS_KEY_ID_NAME,
            value: config.requireSecret('aws_access_key_id')
        });
    }
    private createAwsSecretAccessKey(): Parameter {
        return new Parameter(AWS_SECRET_ACCESS_KEY_PULUMI_NAME, {
            type: SecureStringParameter,
            name: AWS_SECRET_ACCESS_KEY_NAME,
            value: config.requireSecret('aws_secret_access_key')
        });
    }
}

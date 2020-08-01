import {SecurityGroup, Vpc} from "@pulumi/aws/ec2";
import * as pulumi from "@pulumi/pulumi";

const config = new pulumi.Config();
const env = config.require('environment');

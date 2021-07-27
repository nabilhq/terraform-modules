#!groovy

import jenkins.model.*
import hudson.security.*
import groovy.json.JsonSlurper

def instance = Jenkins.getInstance()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)

// retreive admin creds
def admin_creds = new ProcessBuilder( 'sh', '-c', 'aws secretsmanager get-secret-value --secret-id {service_name}-{environment}-admin-creds --region {aws_region}').redirectErrorStream(true).start().text
def admin_username  = new JsonSlurper().parseText(new JsonSlurper().parseText(admin_creds)['SecretString'])['username']
def admin_password  = new JsonSlurper().parseText(new JsonSlurper().parseText(admin_creds)['SecretString'])['password']

// create admin account
hudsonRealm.createAccount(admin_username,admin_password)
instance.setSecurityRealm(hudsonRealm)

// save changes
instance.save()
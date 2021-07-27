import json
import requests
import os
import boto3
import base64
import urllib.parse

def lambda_handler (event, context):
    if event["headers"]["X-GitHub-Event"]:
        return jenkins_github_webhook(event)
    elif event["queryStringParameters"]["verification_token"] == os.environ['jenkins_it_build_verification_token']:
        return new_jenkins_build(event)

def jenkins_github_webhook(event):
    uri = event["queryStringParameters"]["jenkins_host"] + "/github-webhook/"
    headers = {
        "Content-Type": "application/json",
        "X-GitHub-Delivery": event["headers"]["X-GitHub-Delivery"],
        "X-GitHub-Event": event["headers"]["X-GitHub-Event"],
        "X-Hub-Signature": event["headers"]["X-Hub-Signature"]
    }
    response = requests.post(uri, data=event["body"], headers=headers)
    return {
        "statusCode": response.status_code
    }

def new_jenkins_build(event):
    # build job build uri
    uri = (event["queryStringParameters"]["jenkins_host"] + "/job/" + event["queryStringParameters"]["project_name"] + "/job/" + event["queryStringParameters"]["job_name"] + "/build")
    # add the job's parameters to the uri
    if "parameters" in event["queryStringParameters"].keys():
        uri = uri + 'WithParameters?' + urllib.parse.unquote(event["queryStringParameters"]["parameters"])
    # get the jenkins api user secret
    jenkins_it_api_creds = get_secret(os.environ['jenkins_it_api_secret_name'],os.environ['aws_region'])
    # set the header to the base64 encoded username:password string
    headers = {
        "Authorization" : ("Basic " + base64.b64encode((jenkins_it_api_creds["username"] + ":" + jenkins_it_api_creds["token"]).encode()).decode())
    }
    # make post request to jenkins
    response = requests.post(uri, headers=headers)
    # return response startus code
    return {
        'statusCode': response.status_code
    }

def get_secret(secret_name, region_name):
    # create a secrets manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )
    # get secret value
    get_secret_value_response = client.get_secret_value(
        SecretId=secret_name
    )
    if 'SecretString' in get_secret_value_response:
        # return the secret value
        return json.loads(get_secret_value_response['SecretString'])
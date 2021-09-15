import json
import requests
import boto3
import hashlib
import hmac
import os

def get_secret(secret_name, region_name):
    # create a secrets manager client session
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )
    # get secret value
    get_secret_value_response = client.get_secret_value(
        SecretId=secret_name
    )
    # check if SecretString in response
    if "SecretString" in get_secret_value_response:
        # return the secret value
        return {
            "success": "true",
            "response": get_secret_value_response['SecretString']
        }
    else:
        # return failure
        return {
            "success": "false",
            "response": "failed to retrieve secret",
            "statusCode": 401
        }

def validate_github_signature(secret, event):
    incoming_signature = event["headers"]["X-Hub-Signature"].split("=")[1]
    calculated_signature = hmac.new(secret.encode('utf-8'), event["body"].encode('utf-8'), hashlib.sha1).hexdigest()
    sig_test = hmac.compare_digest(calculated_signature, incoming_signature)
    if sig_test == True:
        # return success
        return {
            "success": "true",
            "response": "Valid signature"
        }
    else: 
        # return failure
        return {
            "success": "false",
            "response": "Bad signature",
            "statusCode": 401
        }

def jenkins_github_webhook(event):
    # construct jenkins host url
    uri = event["queryStringParameters"]["jenkins_host"] + "/github-webhook/"
    # set headers
    headers = {
        "Content-Type": "application/json",
        "X-GitHub-Delivery": event["headers"]["X-GitHub-Delivery"],
        "X-GitHub-Event": event["headers"]["X-GitHub-Event"],
        "X-Hub-Signature": event["headers"]["X-Hub-Signature"]
    }
    # send request to jenkins
    response = requests.post(uri, data=event["body"], headers=headers)
    # return response
    return {
        "statusCode": response.status_code
    }

def lambda_handler (event, context):
    # get github webhook secret
    get_secret_response = get_secret(os.environ["github_webhook_secret_name"],os.environ["aws_region"])
    # check if secret was retrieved successfully
    if get_secret_response["success"] == "true":
        # validate github signature
        validate_github_signature_response = validate_github_signature(get_secret_response["response"], event)
        # check if validation was successful 
        if validate_github_signature_response["success"] == "true":
            # send github event to jenkins
            return jenkins_github_webhook(event)
        else:
            # return failure status code
            return validate_github_signature_response["statusCode"]
    else:
        # return failure status code
        return get_secret_response["statusCode"]
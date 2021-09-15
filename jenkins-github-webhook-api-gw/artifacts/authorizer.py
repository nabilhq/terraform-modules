import os

def generate_iam_policy(principalId, action, effect, resource, usageIdentifierKey):
    return {
        "principalId": principalId,
        "policyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": action,
                    "Effect": effect,
                    "Resource": resource
                }
            ]
        },
        "usageIdentifierKey": usageIdentifierKey
    }

def lambda_handler (event, context):
    # check if secret was retrieved successfully
    if event["queryStringParameters"]["verification_token"] == os.environ["github_webhook_verification_token"]:
        # generate allow iam policy
        return generate_iam_policy(event["requestContext"]["identity"]["sourceIp"], "execute-api:Invoke", "Allow", event["methodArn"], event["queryStringParameters"]["verification_token"])
    else:
        # generate deny iam policy
        return generate_iam_policy(event["requestContext"]["identity"]["sourceIp"], "execute-api:Invoke", "Deny", event["methodArn"], event["queryStringParameters"]["verification_token"])

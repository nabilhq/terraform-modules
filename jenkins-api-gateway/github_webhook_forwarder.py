import requests

def lambda_handler (event, context):
    return jenkinsGithubWebhook(event)

def jenkinsGithubWebhook(event):
    uri = event["queryStringParameters"]["hostname"] + "/github-webhook/"
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
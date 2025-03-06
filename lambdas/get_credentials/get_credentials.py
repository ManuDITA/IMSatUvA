import json
import boto3
import os

def lambda_handler(event, context):
    id_token = event["headers"]["Authorization"]
    aws_region = os.getenv("TF_AWS_REGION")
    identity_pool_id = os.getenv("IDENTITY_POOL_ID")

    # Initialize the Cognito Identity client
    identity_client = boto3.client("cognito-identity")

    # Get the identity id
    identity_response = identity_client.get_id(
        IdentityPoolId = identity_pool_id,
        Logins = {
            f"cognito-idp.{aws_region}.amazonaws.com/{identity_pool_id}": id_token
        }
    )
    identity_id = identity_response["IdentityId"]

    # Get the user's credentials from the identity pool
    credentials_response = identity_client.get_credentials_for_identity(
        IdentityId = identity_id,
        Logins = {
            f"cognito-idp.{aws_region}.amazonaws.com/{identity_pool_id}": id_token
        }
    )
    credentials = credentials_response["Credentials"]

    return {
        "statusCode" : 200,
        "headers" : {
            "Content-Type" : "application/json"
        },
        "body": json.dumps({
            "message": "Temporary AWS credentials granted!",
            "AccessKeyId": credentials["AccessKeyId"],
            "SecretKey": credentials["SecretKey"],
            "SessionToken": credentials["SessionToken"]
        })
    }
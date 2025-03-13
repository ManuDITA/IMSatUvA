import json

def generate_response(status_code, message):
    body = {}
    if type(message) == dict or type(message) == list:
        body = message
    else:
        body = {"message": message}

    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(body)
    }
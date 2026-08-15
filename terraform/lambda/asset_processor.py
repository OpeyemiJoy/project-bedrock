import json
import urllib.parse


def lambda_handler(event, context):
    for record in event.get("Records", []):
        key = urllib.parse.unquote_plus(record["s3"]["object"]["key"])

        print(f"Image received: {key}")

    return {
        "statusCode": 200,
        "body": json.dumps("Asset processed successfully")
    }

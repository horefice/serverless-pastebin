import json
import os
import time

import boto3

# print('Loading function')
table = boto3.resource("dynamodb").Table(os.environ.get("table"))
table_key_attribute = os.environ.get("table_key_attribute")
table_data_attribute = os.environ.get("table_data_attribute")
table_ttl_attribute = os.environ.get("table_ttl_attribute")
table_ttl_value = int(os.environ.get("table_ttl_value", 1209600))

operations = {
    "GET": lambda x: table.get_item(
        Key={table_key_attribute: x[table_key_attribute]},
        ProjectionExpression=f"#{table_key_attribute},#{table_data_attribute}",
        ExpressionAttributeNames={
            f"#{table_key_attribute}": table_key_attribute,
            f"#{table_data_attribute}": table_data_attribute,
        },
    ),
    "POST": lambda x: table.put_item(Item=(x | {table_ttl_attribute: int(time.time()) + table_ttl_value})),
}
headers = {
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Methods": "OPTIONS,POST,GET",
    "Access-Control-Allow-Origin": "*",
}


def lambda_handler(event, context):
    # print("Received event: " + json.dumps(event, indent=2))
    operation = event["httpMethod"]
    if operation == "OPTIONS":
        return {"statusCode": "200", "headers": headers}

    if operation in operations:
        payload = event["queryStringParameters"] if operation == "GET" else json.loads(event["body"] or "{}")
        response = operations[operation](payload)
        return {
            "statusCode": "200",
            "body": json.dumps(response["Item"] if "Item" in response else "OK"),
            "headers": headers | {"Content-Type": "application/json"},
        }
    else:
        return {"statusCode": "400", "body": f'Unsupported method "{operation}"', "headers": headers}

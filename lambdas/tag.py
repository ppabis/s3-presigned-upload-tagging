import boto3, os

TABLE_NAME = os.environ['TABLE_NAME']

dynamo = boto3.resource('dynamodb').Table(TABLE_NAME)
s3 = boto3.client('s3')

def get_from_dynamo(key):
    response = dynamo.get_item( Key={'uid': {'S': key}} )
    return response['Item']['title']['S'] if 'Item' in response else "Untitled"

def update_tagging(record):
    key = record['s3']['object']['key']
    bucket = record['s3']['bucket']['name']
    title = get_from_dynamo(key)

    print(f"Updating tagging for {bucket}/{key} to {title}")
    s3.put_object_tagging( Bucket=bucket, Key=key, Tagging={ 'TagSet': [ { 'Key': 'Title', 'Value': title } ] } )
    dynamo.delete_item( Key={'uid': {'S': key}} )


def lambda_handler(event, context):
    print(event)
    for record in event['Records']:
        if 's3' in record:
            update_tagging(record)
        else:
            print(f"Unexpected record: {record}")
    return { 'statusCode': 200, 'body': 'OK' }
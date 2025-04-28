import boto3, uuid, os, re, time
from urllib.parse import parse_qs

HTML_TEMPLATE = open('templates/upload.html').read()
BUCKET_NAME = os.environ['BUCKET_NAME']
REDIRECT = os.environ['REDIRECT']
TABLE_NAME = os.environ['TABLE_NAME']
s3 = boto3.client('s3')
dynamo = boto3.resource('dynamodb').Table(TABLE_NAME)

def clean_title(title):
    t = re.sub(r'[^a-zA-Z0-9\-\s]', '', title)
    return t if t else "Untitled"

def create_upload_form(event):
    body = parse_qs(event['body'])
    title = clean_title(body['title'][0])
    uid = str(uuid.uuid4())
    print(f"Title: {title}, UUID: {uid}")
    
    upload_form_fields = s3.generate_presigned_post(
        BUCKET_NAME,
        uid,
        ExpiresIn=600,
        Fields={"redirect": REDIRECT, "success_action_redirect": REDIRECT},
        Conditions=[
            ["starts-with", "$success_action_redirect", ""],
            ["starts-with", "$redirect", ""]
        ]
    )

    dynamo.put_item(
        Item={
            'uid': uid,
            'title': title,
            'expireAt': int(time.time()) + 600
        }
    )
    
    hidden_inputs = [
        f'<input type="hidden" name="{key}" value="{value}">'
        for (key, value) in upload_form_fields['fields'].items()
    ]
    
    return HTML_TEMPLATE.format(
        title=title,
        url=upload_form_fields['url'],
        hidden_inputs="\n".join(hidden_inputs)
    )
    

def lambda_handler(event, context):
    return {
        'statusCode': 201,
        'headers': { 'Content-Type': 'text/html' },
        'body': create_upload_form(event)
    }
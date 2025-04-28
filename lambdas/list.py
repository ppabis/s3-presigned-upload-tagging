import boto3, os

s3 = boto3.client('s3')
bucket_name = os.environ['BUCKET_NAME']
bucket_url = f"https://{bucket_name}.s3.amazonaws.com"

HTML_TEMPLATE = open("templates/index.html").read()
IMG_TEMPLATE = open("templates/image.html").read()

def get_object_title_tag(key):
    # Will return either the tag "Title" or the key name if no tag is found
    response = s3.get_object_tagging(Bucket=bucket_name, Key=key)
    if response and ('TagSet' in response):
        title_tag = list(filter(lambda t: t['Key'] == 'Title', response['TagSet']))
        return title_tag[0]['Value'] if len(title_tag) > 0 else key
    return key


def get_list_items():
    response = s3.list_objects_v2(Bucket=bucket_name)
    if 'Contents' not in response:
        return "<h3>No photos yet</h3>"

    return "\n".join( [
        IMG_TEMPLATE.format(
            title      = get_object_title_tag(item['Key']),
            bucket_url = bucket_url,
            key        = item['Key']
        )
        for item in response['Contents']
    ] )


def lambda_handler(event, context):
    return {
        'headers'    : { 'Content-Type': 'text/html' },
        'statusCode' : 200,
        'body'       : HTML_TEMPLATE.format(list_items=get_list_items())
    }
Upload images4 to S3 with presigned URL and add tags
============================

For more information, see this blog post:

- [https://pabis.eu/blog/2025-05-02-Tag-S3-Objects-Presigned-URL-Upload.html](https://pabis.eu/blog/2025-05-02-Tag-S3-Objects-Presigned-URL-Upload.html)
- [https://dev.to/aws-builders/s3-presigned-url-upload-with-tags-ohk](https://dev.to/aws-builders/s3-presigned-url-upload-with-tags-ohk)

In this project we explore how to upload files to an S3 bucket and add specified
tags to them.

I created this project previously but used ElastiCache as the temporary storage
for configuration. This time I am using DynamoDB with TTL. You might ask, why
then not just use DynamoDB to store all the information about uploaded images?
My answer is very simple: tags are free!

The previous version of this project is here:
[https://github.com/ppabis/s3-presigned-tagging](https://github.com/ppabis/s3-presigned-tagging).
But I decided to start a new repository to keep everything cleaner. Now you
don't have to install any requirements as we will be using only `boto3`.

"""Example S3-triggered handler. Replace with the function's real logic."""

import json
import logging
import os
import urllib.parse

logger = logging.getLogger()
logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))


def lambda_handler(event, context):
    environment = os.environ.get("ENVIRONMENT", "unknown")
    processed = []

    for record in event.get("Records", []):
        bucket = record["s3"]["bucket"]["name"]
        key = urllib.parse.unquote_plus(record["s3"]["object"]["key"])
        logger.info("[%s] received s3://%s/%s", environment, bucket, key)
        processed.append({"bucket": bucket, "key": key})

    return {"statusCode": 200, "body": json.dumps({"processed": processed})}

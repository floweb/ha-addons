#!/bin/bash

echo "Preparing..."
aws --version

# Reading config
KEY=`jq -r .aws_key_id /data/options.json`
SECRET=`jq -r .aws_key_secret /data/options.json`
BUCKET=`jq -r .bucket_name /data/options.json`
FOLDER=`jq -r .bucket_folder /data/options.json`
STORAGE_CLASS=`jq -r .storage_class /data/options.json`
DELETE=`jq -r .delete_if_missing /data/options.json`
ENDPOINT_URL=`jq -r .endpoint_url /data/options.json`
DEBUG=`jq -r .debug_mode /data/options.json`

# Setting up aws cli
aws configure set aws_access_key_id $KEY
aws configure set aws_secret_access_key $SECRET

# Prepare sync command
SOURCE="/backup/"
DESTINATION="s3://$BUCKET/$FOLDER"
OPTIONS="--storage-class $STORAGE_CLASS"

if [[ $DELETE == true ]]; then
    OPTIONS+=" --delete"
fi
if [[ -n "$ENDPOINT_URL" ]]; then
    OPTIONS+=" --endpoint-url $ENDPOINT_URL"
fi
if [[ $DEBUG == true ]]; then
    OPTIONS+=" --debug"
fi

echo "Compress started..."

find $SOURCE -type f -name "*.tar" -exec gzip -v {} \;

echo "Compress completed."

echo "Sync started..."

aws s3 sync $SOURCE $DESTINATION $OPTIONS

echo "Sync completed."

echo "Cleanup started..."

find $SOURCE -type f -mtime +3 -name "*.tar" -print -delete

echo "Cleanup completed."

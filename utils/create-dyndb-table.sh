#!/bin/bash

table_name="$1"

if [ "$table_name" == "" ]
then
  echo "Table name is required"
  exit 1
fi

aws dynamodb describe-table --table-name $table_name
if [ $? -eq 0 ]
then
  echo "Table $table_name exists"
  exit 0
fi

echo "Table $table_name will be created"

aws dynamodb create-table --table-name $table_name --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

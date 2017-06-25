#!/bin/bash
export AWS_REGION_ID=eu-west-1
component_id=$(cat component.json | jq -r -c ".id")

key_id=$(aws kms list-aliases | jq -r -c ".Aliases[] | select(.AliasName==\"alias/${component_id}\") | .TargetKeyId")
if [ -z "$key_id" ] 
then
  key_id=$(aws kms create-key | jq -r -c ".KeyMetadata.KeyId")
  aws kms create-alias --alias-name alias/${component_id} --target-key-id ${key_id}
fi

bucket_exists=$(aws s3api list-buckets | jq -r -c ".Buckets[] | select(.Name==\"${component_id}\") | .Name")
if [ -z "$bucket_exists" ] 
then
  aws s3api create-bucket --bucket ${component_id} --region eu-west-1 --create-bucket-configuration LocationConstraint=eu-west-1
fi

key_pair_exists=$(aws ec2 describe-key-pairs | jq -r -c ".KeyPairs[] | select(.KeyName==\"${component_id}\") | .KeyName")
if [ -z "$key_pair_exists" ] 
then
  aws ec2 create-key-pair --key-name ${component_id} | jq -r -c ".KeyMaterial">${component_id}.pem
  aws kms encrypt --key-id ${key_id} --plaintext fileb://${component_id}.pem | jq -r -c ".CiphertextBlob" | base64 --decode>${component_id}.key
  aws s3 cp --sse aws:kms ${component_id}.key s3://${component_id}/
  rm ${component_id}.*
fi

aws emr create-cluster --name "${component_id}" \
  --release-label emr-5.3.1 \
  --instance-groups InstanceGroupType=MASTER,InstanceCount=1,InstanceType=m3.xlarge InstanceGroupType=CORE,InstanceCount=2,InstanceType=m3.xlarge \
  --service-role EMR_DefaultRole \
  --ec2-attributes KeyName=${component_id},InstanceProfile=EMR_EC2_DefaultRole \
  --auto-scaling-role EMR_AutoScaling_DefaultRole  

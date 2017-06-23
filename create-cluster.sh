component_id=$(cat component.json | jq -r -c ".id")
key_id=$(aws kms list-aliases | jq -r -c ".Aliases[] | select(.AliasName==\"alias/${component_id}\") | .TargetKeyId")
if [ -z "$key_id" ] 
then
  key_id=$(aws kms create-key | jq -r -c ".KeyMetadata.KeyId")
  aws kms create-alias --alias-name alias/${component_id} --target-key-id ${key_id}
fi
ssh_key_id=$(cat /proc/sys/kernel/random/uuid)
aws ec2 create-key-pair --key-name ${ssh_key_id} | jq -r -c ".KeyMaterial">${ssh_key_id}.pem
spark_cluster_id=$(aws emr create-cluster --name "SPARK Streaming" --release-label emr-5.3.1 --instance-groups InstanceGroupType=MASTER,InstanceCount=1,InstanceType=m3.xlarge InstanceGroupType=CORE,InstanceCount=2,InstanceType=m3.xlarge --service-role EMR_DefaultRole --ec2-attributes KeyName=${ssh_key_id},InstanceProfile=EMR_EC2_DefaultRole --auto-scaling-role EMR_AutoScaling_DefaultRole  | jq -r -c ".ClusterId")
aws kms encrypt --key-id ${key_id} --plaintext fileb://${ssh_key_id}.pem | jq -r -c ".CiphertextBlob" | base64 --decode>${spark_cluster_id}.pem
aws s3api create-bucket --bucket ccp-${component_id} --region eu-west-1 --create-bucket-configuration LocationConstraint=eu-west-1
aws s3 cp --sse aws:kms ${spark_cluster_id}.pem s3://ccp-${component_id}/
rm ${ssh_key_id}.pem
rm ${spark_cluster_id}.*

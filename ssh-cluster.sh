component_id=$(cat component.json | jq -r -c ".id")
cluster_id=$(aws emr list-clusters | jq -r -c ".Clusters[] | select(.Name==\"${component_id}\" and .Status.State==\"WAITING\") | .Id")
aws emr ssh --cluster-id $cluster_id --key-pair-file $component_id.pem

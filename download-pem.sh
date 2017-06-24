component_id=$(cat component.json | jq -r -c ".id")
aws kms decrypt --ciphertext-blob fileb://${component_id}.key | jq -r -c ".Plaintext" | base64 --decode>${component_id}.pem
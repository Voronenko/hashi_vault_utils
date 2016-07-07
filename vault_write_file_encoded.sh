
#!/bin/sh
VAULT_BASE_URL=${VAULT_ADDR-http://localhost:8200}

if [ -z $1 ]
then
  echo provide secret key name
  exit 1
fi

if [ -z $2 ]
then
  echo provide path to file containing secret value
  exit 1
fi

echo "It's up to the caller to encode binary data as base64 before sending it in via the CLI, just like it's up to API users to base64 their data encoded in their POST calls."

echo vault write --address="$VAULT_BASE_URL" $1 @$2
vault write --address="$VAULT_BASE_URL" $1 @$2

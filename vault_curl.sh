#!/bin/sh
VAULT_BASE_URL=${VAULT_ADDR-http://localhost:8200}
if [ -z $1 ]
then
  echo please allocate vault token end export it as a VAULT_TOKEN
  exit 1
fi

if [ -z $2 ]
then
  echo please provide key name to read
  exit 1
fi


curl \
-H "X-Vault-Token: $1" \
-X GET \
$VAULT_BASE_URL/v1/$2

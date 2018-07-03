#!/bin/sh
VAULT_BASE_URL=${VAULT_ADDR-http://localhost:8200}
if [ -z $1 ]
then
  echo provide path to list keys/subkeys  as the parameter
  exit 1
fi


if [ -z "$VAULT_API_FAMILY" ]; then
echo vault policy list -address=$VAULT_BASE_URL $1
vault policy list -address=$VAULT_BASE_URL $1
else
echo vault list -address=$VAULT_BASE_URL $1
vault list -address=$VAULT_BASE_URL $1
fi



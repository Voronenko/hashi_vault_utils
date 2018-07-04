#!/bin/sh
VAULT_BASE_URL=${VAULT_ADDR-http://localhost:8200}
if [ -z $1 ]
then
  echo provide path to list keys/subkeys  as the parameter
  exit 1
fi

echo vault list -address=$VAULT_BASE_URL $1
vault list -address=$VAULT_BASE_URL $1


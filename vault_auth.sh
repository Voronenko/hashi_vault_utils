#!/bin/sh
VAULT_BASE_URL=${VAULT_ADDR-http://localhost:8200}
if [ -z $1 ]
then
  echo provide token as a param
  exit 1
fi
echo vault auth -address=$VAULT_BASE_URL $1
vault auth -address=$VAULT_BASE_URL $1

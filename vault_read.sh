#!/bin/sh
VAULT_BASE_URL=${VAULT_ADDR-http://localhost:8200}
if [ -z $1 ]
then
  echo provide key as a param in form  secret/project/keyname
  exit 1
fi
vault read -field=value -address=$VAULT_BASE_URL/ $1

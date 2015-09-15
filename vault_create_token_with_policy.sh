#!/bin/sh
VAULT_BASE_URL=${VAULT_ADDR-http://localhost:8200}
if [ -z $1 ]
then
 echo please provide policy name
 exit 1
fi
vault token-create -address=$VAULT_BASE_URL -policy="$1"

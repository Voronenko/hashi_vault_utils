#!/bin/sh
VAULT_BASE_URL=${VAULT_ADDR-http://localhost:8200}
if [ -z $1 ]
then
vault policies -address=$VAULT_BASE_URL
else
vault policies -address=$VAULT_BASE_URL $1
fi

#!/bin/sh
VAULT_BASE_URL=${VAULT_ADDR-http://localhost:8200}
if [ -z $1 ]
then
echo vault policies -address=$VAULT_BASE_URL
vault policies -address=$VAULT_BASE_URL
else
echo vault policies -address=$VAULT_BASE_URL $1 
vault policies -address=$VAULT_BASE_URL $1
fi

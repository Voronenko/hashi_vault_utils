#!/bin/sh
VAULT_BASE_URL=${VAULT_ADDR-http://localhost:8200}
if [ -z $1 ]
then

  if [ -z "$VAULT_API_FAMILY" ]; then
    echo vault policy list -address=$VAULT_BASE_URL
    vault policy list -address=$VAULT_BASE_URL
  else
    echo vault list -address=$VAULT_BASE_URL
    vault list -address=$VAULT_BASE_URL
  fi
else

  if [ -z "$VAULT_API_FAMILY" ]; then
    echo vault policy read $1 -address=$VAULT_BASE_URL
    vault policy read $1 -address=$VAULT_BASE_URL
  else
   echo vault list $1 -address=$VAULT_BASE_URL
   vault list $1 -address=$VAULT_BASE_URL
fi
fi

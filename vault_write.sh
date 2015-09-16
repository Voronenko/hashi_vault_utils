#!/bin/sh
VAULT_BASE_URL=${VAULT_ADDR-http://localhost:8200}
if [ -z $1 ]
then
  echo provide key as a param in form  secret/project/keyname
  exit 1
fi

if [ -z $2 ]
then
  echo provide value for $1
  exit 1
fi


vault write $1 -address=$VAULT_BASE_URL value=$2

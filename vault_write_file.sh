
#!/bin/sh
VAULT_BASE_URL=${VAULT_ADDR-http://localhost:8200}

if [ -z $1 ]
then
  echo provide secret key name
  exit 1
fi

if [ -z $2 ]
then
  echo provide path to file containing secret value
  exit 1
fi

VALUE=`cat $2`

vault write --address="$VAULT_BASE_URL" $1 value="$VALUE"


#!/bin/sh
VAULT_BASE_URL=${VAULT_ADDR-http://localhost:8200}

if [ -z $1 ]
then
  echo provide policy name
  exit 1
fi

if [ -z $2 ]
then
  echo provide path to file containing policy
  exit 1
fi

echo vault policy-write --address="$VAULT_BASE_URL" $1 $2
vault policy-write --address="$VAULT_BASE_URL" $1 $2

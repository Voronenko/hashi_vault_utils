#!/bin/sh
VAULT_BASE_URL=${VAULT_ADDR-http://localhost:8200}
VAULT_KEY_SHARES=${1-1}
VAULT_KEY_THRESHOLD=${2-1}

echo The number of key shares to split the master key into: $VAULT_KEY_SHARES
echo The number of key shares required to reconstruct the master key $VAULT_KEY_THRESHOLD

if [ -z "$VAULT_API_FAMILY" ]; then
echo vault operator init -address=$VAULT_BASE_URL -key-shares=$VAULT_KEY_SHARES -key-threshold=$VAULT_KEY_THRESHOLD
vault operator init -address=$VAULT_BASE_URL -key-shares=$VAULT_KEY_SHARES -key-threshold=$VAULT_KEY_THRESHOLD
else
echo vault init -address=$VAULT_BASE_URL -key-shares=$VAULT_KEY_SHARES -key-threshold=$VAULT_KEY_THRESHOLD 
vault init -address=$VAULT_BASE_URL -key-shares=$VAULT_KEY_SHARES -key-threshold=$VAULT_KEY_THRESHOLD
fi


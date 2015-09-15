#!/bin/sh
VAULT_BASE_URL=${VAULT_ADDR-http://localhost:8200}
vault status -address=$VAULT_BASE_URL


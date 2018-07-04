#!/bin/sh
vault_status.sh

vault_init.sh || true

vault_auth.sh abfd0e04-7922-6850-e1bd-f02c325f1e2c

vault_write.sh secret/test2 thetest2

vault_read.sh secret/test2

vault_policy.sh

vault_list.sh secret/

vault_policy_write.sh demo2 $HOME_DIR/demo/demo.hcl

vault_create_token_with_policy.sh demo2

vault_unseal.sh abfd0e04-7922-6850-e1bd-f02c325f1e2c

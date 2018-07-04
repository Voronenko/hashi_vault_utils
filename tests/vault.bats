#!/usr/bin/env bats

@test "vault_status.sh works " {
  result="$(vault_status.sh | grep Sealed)"
  [ "$result" == "Sealed          false" ]
}

@test "vault_init.sh works " {
  result="$(vault_init.sh 2>1 | grep split)"
  [ "$result" == "The number of key shares to split the master key into: 1" ]
}

@test "vault_auth.sh works " {
  result="$(vault_auth.sh abfd0e04-7922-6850-e1bd-f02c325f1e2c | grep Success)"
  echo "==== $result ===="
  [ "$result" == "Success! You are now authenticated. The token information displayed below" ]
}

@test "vault_write.sh works " {
  result="$(vault_write.sh secret/test thetest| grep Success)"
  [ "$result" == "Success! Data written to: secret/test" ]
}

@test "vault_read.sh works " {
  result="$(vault_read.sh secret/test | grep value)"
  [ "$result" == "value               thetest" ]
}

@test "vault_policy.sh works " {
  result="$(vault_policy.sh | grep root)"
  [ "$result" == "root" ]
}

@test "vault_list.sh works " {
  result="$(vault_list.sh secret/ | grep test)"
  [ "$result" == "test" ]
}

@test "vault_policy_write.sh works " {
  result="$(vault_policy_write.sh demo $HOME_DIR/demo/demo.hcl | grep written)"
  [ "$result" == "Policy 'demo' written." ]
}

@test "vault_create_token_with_policy.sh works " {
  result="$(vault_create_token_with_policy.sh demo | grep token_policies)"
  [ "$result" == "token_policies 	[default demo]" ]
}

@test "vault_unseal.sh works " {
  result="$(vault_unseal.sh abfd0e04-7922-6850-e1bd-f02c325f1e2c | grep already)"
  [ "$result" == "Vault is already unsealed." ]
}

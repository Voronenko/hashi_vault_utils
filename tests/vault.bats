#!/usr/bin/env bats

@test "vault_status.sh works " {
  result="$(vault_status.sh | grep Sealed)"
  [ "$result" == "Sealed: false" ]
}

@test "vault_init.sh works " {
  result="$(vault_init.sh 2>1 | grep split)"
  [ "$result" == "The number of key shares to split the master key into: 1" ]
}

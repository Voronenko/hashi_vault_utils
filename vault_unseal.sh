#!/bin/sh
VAULT_BASE_URL=${VAULT_ADDR-http://localhost:8200}
unseal_key=$1

# Read secret string
read_secret()
{
    # Disable echo.
    stty -echo

    # Set up trap to ensure echo is enabled before exiting if the script
    # is terminated while echo is disabled.
    trap 'stty echo' EXIT

    # Read secret.
    read "$@"

    # Enable echo.
    stty echo
    trap - EXIT

    # Print a newline because the newline entered by the user after
    # entering the passcode is not echoed. This ensures that the
    # next line of output begins at a new line.
    echo
}

if [ -z $1 ]
then

  echo "please enter unseal key"
  read_secret unseal_key

fi

if [ -z "$VAULT_API_FAMILY" ]; then
echo vault operator unseal -address=$VAULT_BASE_URL CENSORED
vault operator unseal -address=$VAULT_BASE_URL ${unseal_key}
else
echo vault unseal -address=$VAULT_BASE_URL CENSORED
vault unseal -address=$VAULT_BASE_URL ${unseal_key}
fi


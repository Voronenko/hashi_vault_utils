#!/bin/sh
VAULT_BASE_URL=${VAULT_ADDR-http://localhost:8200}

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


TOKEN=$1

if [ -z $1 ]
then
  echo enter token to auth
  read_secret TOKEN
fi


echo vault login -address=$VAULT_BASE_URL CENSORED
vault login -address=$VAULT_BASE_URL $TOKEN

#echo vault auth -address=$VAULT_BASE_URL CENSORED
#vault auth -address=$VAULT_BASE_URL $TOKEN

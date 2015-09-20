Using Vault by HashiCorp to secure your deployment secrets
=======================================

Educational repository demonstrating approaches for secure deployment passwords

#Background
"Don’t Check Passwords into Source Control or Hard-Code Them 
in Your Application
Operations staff will remove your eyes with a spoon if they catch you doing this. 
Don’t give them the pleasure Passwords should always be entered by the user performing the deployment. There are several acceptable ways to handle authentication for a multilayer system. You could use certificates, a directory service, or a single sign-on system". This quote is taken from Chapter 2 of the Continuous Delivery: Reliable Software Releases Through Build, Test, And Deployment Automation (Addison-Wesley Signature Series (Fowler)) book by and David Farley, Jez Humble 

Vault by HashiCorp is one of the tools that might provide acceptable level of security for devops engineers for enterprise scenarios as well as for smaller teams like startups.

## Challenges to address
  At the end of the article we should be able
  
- install vault on a ubuntu 14.04 :TS server
- initialize vault
- store secrets in vault 
- access secrets in vault

#Installing
Formal installation steps are covered by this article: [https://vaultproject.io/docs/install/](https://vaultproject.io/docs/install/)
For purposes of the demo article let me provide semi automated script, that installs vault *0.1.2* into /opt/vault_0.1.2 folder , configures it to listen on localhost port 8200 and registers it as a service called vault-server
<pre>
#!/bin/sh

VAULT_VERSION=${VAULT_VERSION-0.1.2}
VAULT_PATH=/opt/vault_$VAULT_VERSION
UNAME=`uname -m`

if [ "$UNAME" != "x86_64" ]; then
  PLATFORM=386
else
  PLATFORM=amd64
fi


if [ "$(id -u)" != "0" ]; then
	echo "Installation must be done under sudo"
	exit 1
fi

test -x $VAULT_PATH/vault
if [ $? -eq 0 ]; then
    echo vault already installed
    exit 1
fi

apt-get install -y curl unzip

rm /opt/vault_${VAULT_VERSION}_linux_${PLATFORM}.zip

curl -L "https://dl.bintray.com/mitchellh/vault/vault_${VAULT_VERSION}_linux_${PLATFORM}.zip" > /opt/vault_${VAULT_VERSION}_linux_${PLATFORM}.zip

mkdir -p $VAULT_PATH

unzip /opt/vault_${VAULT_VERSION}_linux_${PLATFORM}.zip -d $VAULT_PATH

chmod 0755 $VAULT_PATH/vault
chown root:root $VAULT_PATH/vault

echo create config

cat <<EOF >$VAULT_PATH/vault-config.hcl
backend "file" {
  path = "$VAULT_PATH/storage"
}

listener "tcp" {
  address = "127.0.0.1:8200"
  tls_disable = 1
}
EOF

echo create run script
cat <<EOF >$VAULT_PATH/vault-server
#!/bin/sh
if [ -z \$1 ]
then
  echo syntax: vault-server /PATH/TO/VAULT/HCL/CONFIG optional_flags
  exit 1
fi
vault server -config=\$1 \$2 \$3 \$4 \$5 \$6 \$7 \$8 \$9
EOF

chmod 0755 $VAULT_PATH/vault-server
chown root:root $VAULT_PATH/vault-server

echo create upstart script
cat <<EOF >/etc/init/vault-server.conf
description "Vault server"
start on runlevel [2345]
stop on runlevel [!2345]
respawn
script
  # Make sure to use all our CPUs, because Vault can block a scheduler thread
  export GOMAXPROCS=`nproc`
  exec $VAULT_PATH/vault-server ${VAULT_PATH}/vault-config.hcl >>/var/log/vault.log 2>&1
end script
EOF

service vault-server start
cat /var/log/vault.log
</pre>


#Code in action

Code can be downloaded from repository [https://github.com/Voronenko/hashi_vault_utils](https://github.com/Voronenko/hashi\_vault\_utils "https://github.com/Voronenko/hashi\_vault\_utils")

Some files just help using existing vault functionality in a more handy way:

- vault_status.sh - gets status of the vault
- vault_policy.sh - lists known policies, or shows details of the policy provided as a first parameter
- vault_create_token_with_policy.sh creates and returns token with policy provided as a first parameter.
- vault_read.sh reads secret by key (first parameter)
- vault_write.sh writes secret by key (first parameter) and set's it's value (second parameter)
- vault_write\_file.sh writes secret by key (first parameter) and stores content's of text file provided as second parameter 
- vault_curl.sh can be used to test http api. First parameter - access token, second parameter secret key to read

#Points of interest

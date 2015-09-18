#!/bin/sh
VAULT_VERSION=${VAULT_VERSION-0.1.2}
VAULT_PATH=/opt/vault_$VAULT_VERSION

if [ "$(id -u)" != "0" ]; then
	echo "Installation must be done under sudo"
	exit 1
fi

test -x $VAULT_PATH/vault
if [ $? -eq 0 ]; then
    echo vault already installed
    exit 1
fi

apt-get install unzip

rm /opt/vault_${VAULT_VERSION}_linux_amd64.zip

wget https://dl.bintray.com/mitchellh/vault/vault_${VAULT_VERSION}_linux_amd64.zip -P /opt/

mkdir -p $VAULT_PATH

unzip /opt/vault_${VAULT_VERSION}_linux_amd64.zip -d $VAULT_PATH

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
if [ -z $1 ]
then
  echo syntax: vault-server /PATH/TO/VAULT/HCL/CONFIG
  exit 1
fi
vault server -config=$1
EOF

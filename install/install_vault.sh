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

rm /opt/vault_${VAULT_VERSION}_linux_amd64.zip

curl -L "https://dl.bintray.com/mitchellh/vault/vault_${VAULT_VERSION}_linux_amd64.zip" > /opt/vault_${VAULT_VERSION}_linux_${PLATFORM}.zip

mkdir -p $VAULT_PATH

unzip /opt/vault_${VAULT_VERSION}_linux_amd64.zip -d $VAULT_PATH

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

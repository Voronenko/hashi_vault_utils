Using Vault by HashiCorp to secure your deployment secrets
=======================================

Educational repository demonstrating approaches for safe secure deployment of passwords, api keys etc

# Background
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

# Installing Manually

Formal installation steps are covered by this article: [https://vaultproject.io/docs/install/](https://vaultproject.io/docs/install/)
For purposes of the demo article let me provide semi automated script, that installs vault *0.1.2* into /opt/vault_0.1.2 folder , configures it to listen on localhost port 8200 and registers it as a service called vault-server
<pre>
#!/bin/sh

VAULT_VERSION=${VAULT_VERSION-0.5.2}
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

curl -L "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_${PLATFORM}.zip" > /opt/vault_${VAULT_VERSION}_linux_${PLATFORM}.zip

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
BASEDIR=\$(dirname \$0)
cd \$BASEDIR
./vault server -config=\$1 \$2 \$3 \$4 \$5 \$6 \$7 \$8 \$9
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

echo linking vault binary to /usr/local/bin/vault
sudo ln -s $VAULT_PATH/vault /usr/local/bin/vault

service vault-server start
cat /var/log/vault.log

</pre>


# Installing automatically with Ansible

See [https://github.com/softasap/sa-hashicorp-vault](https://github.com/softasap/sa-hashicorp-vault)  Ansible Role for unattended Vault installation

# Check the installation:
<pre>
./vault_status.sh
Error checking seal status: Error making API request.

URL: GET http://localhost:8200/v1/sys/seal-status
Code: 400. Errors:

* server is not yet initialized
</pre>
Message means, that vault was installed and configured correctly, but needs to be initialized. Initialization happens once when the server is started against a new backend that has never been used with Vault before. During initialization, the encryption keys are generated, unseal keys are created, and the initial root token is setup. To initialize Vault use vault init. This is an unauthenticated request, but it only works on brand new Vaults with no data

Let's init. Important influence on security has number of key shares to generate and number of key shares provided to unlock the seal.

How does it work: the key used to encrypt the data is also encrypted using 256-bit AES in GCM mode. This is known as the master key. The encrypted encryption key is stored in the backend storage. The master key is then split using Shamir's Secret Sharing. Shamir's Secret Sharing ensures that no single person (including Vault) has the ability to decrypt the data. To decrypt the data, a threshold number of keys (by default three, but configurable) are required to unseal the Vault. Thesekeys are expected to be with three different places / individuals.

It has full analogy to secure bank cell where one key has bank personnel and one is yours.In case of vault you might have much higher level of security.

For demo purposes I will use single key only.

<pre>
./vault_init.sh
The number of key shares to split the master key into: 1
The number of key shares required to reconstruct the master key 1
Key 1: af29615803fc23334c3a93f8ad58353b587f50eb0399d23a6950721cbae94948
Initial Root Token: 98df443c-65ee-d843-7f4b-9af8c426128a

Vault initialized with 1 keys and a key threshold of 1!

Please securely distribute the above keys. Whenever a Vault server
is started, it must be unsealed with 1 (the threshold) of the
keys above (any of the keys, as long as the total number equals
the threshold).

Vault does not store the original master key. If you lose the keys
above such that you no longer have the minimum number (the
threshold), then your Vault will not be able to be unsealed.
</pre>

Initial Root Token must be immediately saved in a secure location.

# Using vault

## Unsealing
When a Vault server is started, it starts in a sealed state. Unsealing is the process of constructing the master key necessary to read the decryption key to decrypt the data, thus prior to unsealing, almost no operations are possible with Vault.

Let's unseal:
<pre>
./vault_ unseal af29615803fc23334c3a93f8ad58353b587f50eb0399d23a6950721cbae94948
Sealed: false
Key Shares: 1
Key Threshold: 1
Unseal Progress: 0
</pre>

Note, if you had higher threshold set, all the key holders would need to perform unseal operation with their parts of the key.  That's provides additional level of security for accessing the data

## Authorization
In order to continue working with vault, you should first identify yourself.
Let's use auth command to do this by providing our initial root token

<pre>
./vault_ auth 98df443c-65ee-d843-7f4b-9af8c426128a
Successfully authenticated! The policies that are associated
with this token are listed below:

root

</pre>

## Policies

Access control policies in Vault control what a user can access.When initializing Vault, only the "root" policy is present. It gives superuser access to everything in Vault.

As we plan to store secrets for saying multiple projects, we should be able to clearly separate access to secrets that belong to different projects. And this is where policies do their job.


Policies in Vault are formatted with HCL. HCL is a human-readable configuration format that is also JSON-compatible, so you can use JSON as well. An example policy is shown below:

<pre>
path "secret/project/name" {
  policy = "read"
}
</pre>

It specify path, like we have in some tree structure, wildcards are supported.
If you provide access to specific part of the tree, you also provide the same access to all subnodes, unless you override it.

Policy is registered with *policy-write* command
<pre>
./vault_ policy-write demo demo.hcl
vault policy-write -address=http://localhost:8200 demo demo.hcl
Policy 'demo' written.
</pre>

## Deployment tokens

Now it is time to create deployment token. In our case, this is token that would allow us to read the secret deployment value from vault, and does not have any additional privileges except this.

In order to do so, we are using creating token with policy command

<pre>
./vault_create_token_with_policy.sh demo
vault token-create -address=http://localhost:8200 -policy=demo
4d79adad-a4ec-de8b-3f85-5467b3e8536a
</pre>


## Storing data

Now it is time to store some secrets for deployment. For purposes of the demo, let it be some api key and private key used for deployment.

Command write is used to write the secrets
<pre>
./vault_write.sh secret/project/name/apikey BLABLABLA
vault write -address=http://localhost:8200 secret/project/name/apikey value=BLABLABLA
Success! Data written to: secret/project/name/apikey

./vault_write_file.sh secret/project/name/id_rsa ./demo_rsa
Success! Data written to: secret/project/name/id_rsa
</pre>

### Important
Binary file storing is not supported as for now, but you always can store base64 encoded file, like the MIME attachments are stored in mails.
Fortunately, for most deployments we have api keys and private keys that are text files.

## Retrieving the data

There are two ways to access your data.
First is using vault client itself

<pre>
./vault_read.sh secret/project/name/apikey
vault read -address=http://localhost:8200 secret/project/name/apikey
Key            	Value
lease_id       	secret/project/name/apikey/a74dd189-de4b-1c98-ba24-6b29258c511b
lease_duration 	2592000
lease_renewable	false
value          	BLABLABLA

./vault_read.sh secret/project/name/id_rsa
vault read -address=http://localhost:8200 secret/project/name/id_rsa
Key            	Value
lease_id       	secret/project/name/id_rsa/204ba657-9648-4fa5-8f82-ede992a054b4
lease_duration 	2592000
lease_renewable	false
value          	-----BEGIN RSA PRIVATE KEY-----
MIIEpgIBAAKCAQEApiLCR2sgf5unedMk1a2maL22PsoPwQWpGTDFZgCvhSVWvnBs
...
</pre>

second is using http based API. For that scenario you will need to authorize via deployment token we allocated previously.
<pre>
./vault_curl.sh 4d79adad-a4ec-de8b-3f85-5467b3e8536a secret/project/name/apikey
curl -H X-Vault-Token: 4d79adad-a4ec-de8b-3f85-5467b3e8536a -X GET http://localhost:8200/v1/secret/project/name/apikey
{"lease_id":"secret/project/name/apikey/2189c6c4-1fa7-0f4d-2598-bded29a4ce6b","renewable":false,"lease_duration":2592000,"data":{"value":"BLABLABLA"},"auth":null}

./vault_curl.sh 4d79adad-a4ec-de8b-3f85-5467b3e8536a secret/project/name/id_rsa
curl -H X-Vault-Token: 4d79adad-a4ec-de8b-3f85-5467b3e8536a -X GET http://localhost:8200/v1/secret/project/name/id_rsa
{"lease_id":"secret/project/name/id_rsa/ec509e1f-09a7-6aee-54e2-f3364720c7de","renewable":false,"lease_duration":2592000,"data":{"value":"-----BEGIN RSA PRIVATE KEY-----\nMIIEpgI......-----END RSA PRIVATE KEY-----"},"auth":null}
</pre>


# Securing vault http api
Vault supports https itself, but I believe for production deployment it would be better to hide it behind web server as a proxy.

Below is an example of nginx configuration
<pre>
server {
  listen 443 ssl;
  server_name vault.YOURDOMAIN.COM;

  ssl_certificate YOUR_SSL_CERTIFICATE.crt;
  ssl_certificate_key YOUR_SSL_CERTIFICATE_KEY.key;

  location / {
    proxy_pass http://127.0.0.1:8200;
    proxy_set_header Host $host;
    expires -1;
  }

  #ssl config per https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

  ssl_ciphers "EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA256:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384:EDH+aRSA+AESGCM:EDH+aRSA+SHA256:EDH+aRSA:EECDH:!aNULL:!eNULL:!MEDIUM:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS:!RC4:!SEED";
  ssl_prefer_server_ciphers on;

  ssl_dhparam dhparam.pem;

  #only supported since 1.3.7
  ssl_stapling on;
  ssl_stapling_verify on;

  # Optimize SSL by caching session parameters for 10 minutes. This cuts down on the number of expensive SSL handshakes.
  # The handshake is the most CPU-intensive operation, and by default it is re-negotiated on every new/parallel connection.
  # By enabling a cache (of type "shared between all Nginx workers"), we tell the client to re-use the already negotiated state.
  # Further optimization can be achieved by raising keepalive_timeout, but that shouldn't be done unless you serve primarily HTTPS.
  ssl_session_cache    shared:SSL:10m; # a 1mb cache can hold about 4000 sessions, so we can hold 40000 sessions
  ssl_session_timeout  10m;

  add_header Strict-Transport-Security max-age=63072000;
  add_header X-Frame-Options DENY;
  add_header X-Content-Type-Options nosniff;
}
</pre>

# Code in action

Code can be downloaded from repository [https://github.com/Voronenko/hashi_vault_utils](https://github.com/Voronenko/hashi\_vault\_utils "https://github.com/Voronenko/hashi\_vault\_utils")

Some files just help using existing vault functionality in a more handy way:

- vault_status.sh - gets status of the vault
- vault_policy.sh - lists known policies, or shows details of the policy provided as a first parameter
- vault_create_token_with_policy.sh creates and returns token with policy provided as a first parameter.
- vault_read.sh reads secret by key (first parameter)
- vault_write.sh writes secret by key (first parameter) and set's it's value (second parameter)
- vault_write\_file.sh writes secret by key (first parameter) and stores content's of text file provided as second parameter
- vault_curl.sh can be used to test http api. First parameter - access token, second parameter secret key to read


# Devops: usage with ansible

Lookup plugin:
[github.com/Voronenko/ansible-developer_recipes/blob/master/ansible_extras/lookup_plugins/sa_hashi_vault.py](https://github.com/Voronenko/ansible-developer_recipes/blob/master/ansible_extras/lookup_plugins/sa_hashi_vault.py)


Action module:
[github.com/Voronenko/ansible-developer_recipes/blob/master/ansible_extras/action_plugins/sa_hashi_vault.py](https://github.com/Voronenko/ansible-developer_recipes/blob/master/ansible_extras/action_plugins/sa_hashi_vault.py)


# Points of interest

This covers only very basic aspects to start using vault in your organization, but could be a  nice first step to move forward.

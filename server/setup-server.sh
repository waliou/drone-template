#! /bin/bash

# Copy Env
cp .env.example .env.tmp

# Setup Github OAuth
echo -n "Enter Github Client ID: "
read -r gh_id
echo -n "Enter Github Client Secret: "
read -r gh_sec
sed -i -e "s/<GH_ID>/$gh_id/g" .env.tmp
sed -i -e "s/<GH_SECRET>/$gh_sec/g" .env.tmp
gh_sec=""


# Setup RPC Secret
echo -n "Enter RPC Secret(empty to generate new): "
read -r rpc_sec
if [[ -z $rpc_sec ]]; then
    rpc_sec=$(openssl rand -hex 16)
    echo "Your Secret is $rpc_sec"
fi
sed -i -e "s/<RPC_SECRET>/$rpc_sec/g" .env.tmp

# Set server host
while [[ 1 == 1 ]]; do
  # set host
  echo -n "Enter server domain: "
  read -r domain

  # set protocol
  proto="http"
  auto_tls="false"
  echo -n "Do you want to use https?? [Y/n] "
  read -r choice
  if [[ $choice == "N" || $choice == "n" ]]; then
    echo "Using http"
  else
    proto="https"
    echo -n "Do you want to use AutoTLS(by certbot)? [Y/n] "
    read -r choice
    if [[ $choice == "N" || $choice == "n" ]]; then
      echo -n "Enter path to tls-key: "
      read -r tls_key
      echo -n "Enter path to tls-cert: "
      read -r tls_cert
    else
      auto_tls="true"
    fi
  fi

  # checklist
  echo "===== Summary ====="
  echo "URI: $proto://$domain"
  echo "Protocol: $proto"

  if [[ $proto == "https" ]];then
    if [[ $auto_tls != "false" ]]; then
      echo "Auto TLS: true"
    else
      echo "TLS-Key: $tls_key"
      echo "TLS-Cert: $tls_cert" 
    fi
  fi
  echo "==================="

  echo -n "Use this configuration? [Y/n] "
  read -r choice
  if [[ $choice != "N" && $choice != "n" ]]; then
    sed -i -e "s/<SERVER_HOST>/$domain/g" .env.tmp
    sed -i -e "s/<SERVER_PROTO>/$proto/g" .env.tmp
    sed -i -e "s/<AUTO_TLS>/$auto_tls/g" .env.tmp
    if [[ ! -z $tls_key && ! -z $tls_cert ]]; then
      echo "DRONE_TLS_KEY=$tls_key" >> .env.tmp
      echo "DRONE_TLS_CERT=$tls_cert" >> .env.tmp
    fi
    break
  fi
done


echo -n "Enter admin username: "
read -r admin_name
sed -i -e "s/<ADMIN_NAME>/$admin_name/g" .env.tmp


echo -n "Enter user filter: "
read -r users
sed -i -e "s/<USER_LIST>/$users/g" .env.tmp


echo "--- Preview ---"
cat .env.tmp
echo "---------------"
echo -n "User this .env? [Y/n] "
read -r choice
if [[ $choice != "N" && $choice != "n" ]]; then
  cp .env.tmp .env
fi

rm .env.tmp

#! /bin/bash

cp .env.example .env.tmp

echo -n "Enter your server host: "
read -r rpc_host
sed -i -e  "s/<RPC_HOST>/$rpc_host/g" .env.tmp

echo -n "Use https? [Y/n] "
read -r choice
if [[ $choice != "N" && $choice != "n" ]]; then
  sed -i -e "s/<RPC_PROTO>/https/g" .env.tmp
else
  sed -i -e "s/<RPC_PROTO>/http/g" .env.tmp
fi

echo -n "Enter RPC Secret(same as server): "
read -r rpc_sec
sed -i -e "s/<RPC_SECRET>/$rpc_sec/g" .env.tmp

echo -n "Enter capacity(pipeline running simultaneously): "
read -r capacity
sed -i -e "s/<CAPACITY>/$capacity/g" .env.tmp

echo "--- Preiview ---"
cat .env.tmp
echo "----------------"

echo -n "Use this .env? [Y/n] "
read -r choice
if [[ $choice != "N" && $choice != "n" ]]; then
  cp .env.tmp .env
fi
rm .env.tmp

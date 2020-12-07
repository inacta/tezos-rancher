#!/bin/sh

set -ex

bin_dir="/usr/local/bin"

data_dir="/var/run/tezos"
node_dir="$data_dir/node"
client_dir="$data_dir/client"

printf "Writing custom configuration for public node\n"
rm -rvf ${node_dir}/data/config.json
mkdir -p ${node_dir}/data

${bin_dir}/tezos-node config init \
    --config-file ${node_dir}/data/config.json \
    --history-mode $history_mode\
    --network $TEZOS_NETWORK \
    $PRIVATE_PEER_LIST

cat ${node_dir}/data/config.json
echo ""
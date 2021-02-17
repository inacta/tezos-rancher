#!/bin/sh

cd /tezos/tezos-reward-distributor
python3 src/main.py -C 326 -M 2 -N MAINNET -P tzkt -A https://mainnet-tezos.giganode.io:443 -Ap https://mainnet-tezos.giganode.io -r /tezos/pymnt/reports -f /tezos/pymnt/cfg -E "$HOME/.tezos-client"
#!/bin/bash
set -euo pipefail
pushd $(dirname "$0")/..

export RPC_URL="http://localhost:5050";

# export WORLD_ADDRESS=$(cat ./manifests/dev/manifest.json | jq -r '.world.address')

# sozo execute --world <WORLD_ADDRESS> <CONTRACT> <ENTRYPOINT>
sozo execute --world 0x1ee592601cde2eb4147136aadf1f2f07d4519d510e0cd013a4339dd09a1e192 mancala::systems::actions::actions create_game --wait

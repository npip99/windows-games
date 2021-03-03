#!/bin/bash
set -e

cd ../setups
if [[ -d "$1" || -f "$1" ]]; then
  echo "./$1 already exists! Please delete it first."
  exit 1
fi
mkdir "$1"
curl -Ls "$2" | tar -xzv -C "./$1"

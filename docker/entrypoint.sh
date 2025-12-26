#!/bin/sh

echo "Starting local deployment..."

npx hardhat run scripts/deploy.js --network localhost

tail -f /dev/null

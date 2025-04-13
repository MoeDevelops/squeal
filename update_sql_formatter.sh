#!/bin/bash

# Requires:
# git
# esbuild
# yarn

mkdir temp
cd temp

# Update branch when updating
git clone https://github.com/sql-formatter-org/sql-formatter . --branch v15.5.2

yarn
yarn grammar
yarn build:esm
esbuild dist/esm/index.js --outdir=build --bundle --format=esm --minify

cd ..
mv temp/build/index.js src/sql-formatter.mjs
rm -rf temp

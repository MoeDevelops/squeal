#!/bin/bash

# Requires:
# git
# esbuild
# yarn

mkdir temp
cd temp

git clone https://github.com/sql-formatter-org/sql-formatter .

yarn
esbuild src/index.ts --outdir=build --bundle --format=esm --minify

cd ..
mv temp/build/index.js src/sql-formatter.mjs
rm -rf temp

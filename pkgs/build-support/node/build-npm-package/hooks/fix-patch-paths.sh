#!/usr/bin/env nix-shell
#!nix-shell -i bash -p gnused

sed -i "s| a/node_modules| a/lib/node_modules/npm/node_modules|" npm.patch
sed -i "s| b/node_modules| b/lib/node_modules/npm/node_modules|" npm.patch
sed -i "s| a/workspaces| a/lib/node_modules/npm/node_modules/@npmcli|" npm.patch
sed -i "s| b/workspaces| b/lib/node_modules/npm/node_modules/@npmcli|" npm.patch

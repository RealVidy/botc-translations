#! /usr/bin/env bash

cat "$1/$2" | jq '.' > "$1/_tmp.json"
mv "$1/_tmp.json" "$1/$2"

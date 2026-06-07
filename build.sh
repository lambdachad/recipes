#!/usr/bin/env sh

rm -rf docs
mkdir -p docs
cp recipes/*.jpg docs/

for recipe in recipes/*.cook; do
    name=$(basename "${recipe%.cook}")
    cook report --template recipe.html.jinja "$recipe" --datastore . > "docs/$name.html" 2>/dev/null
    echo "$name.html"
done

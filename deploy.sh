#!/bin/bash

rm -rf public/

hugo build

# Since firefox doesn't want to work
# ./compile-katex.sh

cd ../output
git rm -rf .
# git checkout HEAD -- .gitignore
git clean -fxd

cd ../src
cp -a ./public/. ../output

cd ../output
git add .
git commit -m "Deploy"
git push -f

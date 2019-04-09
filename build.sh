#!/bin/sh

cd ./3rd/skynet/

make linux

cd ../..

cd ./3rd/lua-cjson
make
cp ./cjson.so ../skynet/luaclib/cjson.so
#!/bin/sh

sudo mysql -uroot -phansen < ./01_init_db.sql

WEBENDPATH=`find ~ -name "z2o_webend" -type d | head -1`
rm -rf $WEBENDPATH/manager/*.pyc
rm -rf $WEBENDPATH/manager/migrations/*
rm -rf $WEBENDPATH/z2owebend/*.pyc

python $WEBENDPATH/manage.py makemigrations manager
python $WEBENDPATH/manage.py migrate


#mysql -usendy -psendy -Dz2oserver < ./03_proc_register.sql

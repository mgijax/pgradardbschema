#!/bin/sh

#
# Drop and re-create database triggers, stored procedures and views
#
#

cd `dirname $0` && source ./Configuration

rm -rf */logs/*/*log
./key/key_drop.sh
./key/key_create.sh
./index/index_drop.sh
./index/index_create.sh
./procedure/procedure_drop.sh
./procedure/procedure_create.sh
./trigger/trigger_drop.sh
./trigger/trigger_create.sh

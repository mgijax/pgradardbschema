#!/bin/csh -f

#
# Drop and re-create database triggers, stored procedures and views
#
#

cd `dirname $0` && source ./Configuration

rm -rf */logs/*/*log
./default/default_unbind.csh
./default/default_bind.csh
./key/key_drop.csh
./key/key_create.csh
./index/index_drop.csh
./index/index_create.csh
./procedure/procedure_drop.csh
./procedure/procedure_create.csh
./trigger/trigger_drop.csh
./trigger/trigger_create.csh

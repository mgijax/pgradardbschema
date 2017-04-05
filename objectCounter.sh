#!/bin/sh

# Count the number of create scripts for each type of object in the schema
# product and the number of objects that will be created by those scripts.

cd `dirname $0`
TOP=`pwd`
unset LC_ALL

echo "Object Type     Count"
echo "==============  ============"

cd ${TOP}/table
echo "Tables          `ls *_create.object | wc -l` scripts"
psql -h ${PG_DBSERVER} -U ${PG_DBUSER} -d ${PG_DBNAME} --command "select count(*) from pg_catalog.pg_tables where schemaname = 'radar'"

cd ${TOP}/key
echo "Primary Keys         `ls *_create.object | wc -l` scripts  (`grep -i 'ADD PRIMARY KEY' *_create.object | wc -l` primary keys)"
psql -h ${PG_DBSERVER} -U ${PG_DBUSER} -d ${PG_DBNAME} --command "select count(*) from pg_stat_user_indexes where schemaname = 'radar' and indexrelname like '%_pkey'" 

cd ${TOP}/index
echo "Indexes         `ls *_create.object | wc -l` scripts  (`grep -i '^create' *_create.object | wc -l` indexes)"
psql -h ${PG_DBSERVER} -U ${PG_DBUSER} -d ${PG_DBNAME} --command "select count(*) from pg_stat_user_indexes where schemaname = 'radar' and indexrelname not like '%_pkey'" 

cd ${TOP}/procedure
echo "Procedures      `ls *_create.object | wc -l` scripts (`grep -i '^CREATE OR REPLACE' *_create.object | wc -l` functios)"
psql -h ${PG_DBSERVER} -U ${PG_DBUSER} -d ${PG_DBNAME} --command "\df" | grep -i 'normal' | grep -i 'radar' | wc -l

#cd ${TOP}/trigger
#echo "Triggers        `ls *_create.object | wc -l` scripts  (`grep -i '^create trigger ' *_create.object | wc -l` triggers)"
#psql -h ${PG_DBSERVER} -U ${PG_DBUSER} -d ${PG_DBNAME} --command "select count(*) from pg_catalog.pg_trigger where tgname like '%_trigger'" 

#cd ${TOP}/view
#echo "Views           `ls *_create.object | wc -l` scripts"
#psql -h ${PG_DBSERVER} -U ${PG_DBUSER} -d ${PG_DBNAME} --command "select count(*) from pg_catalog.pg_views where schemaname = 'radar'" 

cd ${TOP}/key
echo "Keys            `ls *_create.object | wc -l` scripts  (`grep -i 'ADD PRIMARY' *_create.object | wc -l` primary keys)"


#!/bin/sh

# Count the number of create scripts for each type of object in the schema
# product and the number of objects that will be created by those scripts.

cd `dirname $0`
TOP=`pwd`

echo "Object Type     Count"
echo "==============  ============"

cd ${TOP}/table
echo "\nTables          `ls *_create.object | wc -l` scripts"
psql -h ${PG_DBSERVER} -U ${PG_DBUSER} -d ${PG_DBNAME} --command "select count(*) from pg_catalog.pg_tables where schemaname = 'mgd'"

cd ${TOP}/index
echo "\nIndexes         `ls *_create.object | wc -l` scripts  (`grep -i '^create .*index ' *_create.object | wc -l` indexes)"
psql -h ${PG_DBSERVER} -U ${PG_DBUSER} -d ${PG_DBNAME} --command "select count(*) from pg_stat_user_indexes where schemaname = 'mgd' and indexrelname like '%_idx%'" 

cd ${TOP}/procedure
echo "\nProcedures      `ls *_create.object | wc -l` scripts (`grep -i '^CREATE OR REPLACE' *_create.object | wc -l` functios)"
psql -h ${PG_DBSERVER} -U ${PG_DBUSER} -d ${PG_DBNAME} --command "\df" | grep -i 'normal' | wc -l

cd ${TOP}/key
echo "\nKeys            `ls *_create.object | wc -l` scripts  (`grep -i 'ADD PRIMARY' *_create.object | wc -l` primary keys)"


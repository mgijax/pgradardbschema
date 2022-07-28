#!/bin/sh
#
#  objectCounter.sh
###########################################################################
#
#  Purpose:  This script compares a list of objects in the database with
#            the ones defined in the pgradardbschema product to make sure
#            they are in sync. It prints the counts, along with any cases
#            where the lists are different.
#
#  Usage:
#
#      objectCounter.sh
#
#  Env Vars:
#
#      - PG_DBSERVER, PG_DBNAME and PG_DBUSER are used to connect to the
#        database. These should be set in the instance of mgiconfig that
#        is sourced via the Configuration file.
#
#  Inputs:  None
#
#  Outputs:  None
#
#  Exit Codes:
#
#      0:  Successful completion
#      1:  Fatal error occurred
#
#  Assumes:  Nothing
#
#  Implementation:
#
#  Notes:  None
#
###########################################################################

cd `dirname $0`; . ./Configuration
TOP=`pwd`

#
# Create temp files that will be removed when the script terminates.
#
TMP_SCHEMA=/tmp/tmp_schema_$$
TMP_DB=/tmp/tmp_db_$$
TMP_SORT=/tmp/tmp_sort_$$
TMP_DIFF=/tmp/tmp_diff_$$
trap "rm -f ${TMP_SCHEMA} ${TMP_DB} ${TMP_SORT} ${TMP_DIFF}" 0 1 2 15

#
# Print the schema product and database that are being compared.
#
echo ""
echo "Schema product: ${TOP}"
echo "Database:       ${PG_DBSERVER}.${PG_DBNAME}.radar"

#
# This function compares the contents of 2 temp files and prints the counts
# and object differences. One file contains a list of objects defined in the
# schema product and the other contains a list of objects from the database.
# This function is called for each type of object that needs to be compared.
#
do_diff ()
{
    echo ""
    echo ""
    echo $1
    echo "----------------------------------------"
    S_COUNT=`cat ${TMP_SCHEMA} | wc -l`
    D_COUNT=`cat ${TMP_DB} | wc -l`
    echo "Schema count: ${S_COUNT}    Database count: ${D_COUNT}"
    rm -f ${TMP_DIFF}
    diff -i ${TMP_SCHEMA} ${TMP_DB} > ${TMP_DIFF}
    if [ `cat ${TMP_DIFF} | wc -l` -eq 0 ]
    then
        echo ""
        echo "No difference"
    fi
    if [ `cat ${TMP_DIFF} | grep "^< " | wc -l` -gt 0 ]
    then
        if [ `cat ${TMP_DIFF} | grep "crs_typings__cross_key_fkey" | wc -l` -gt 0 ]
        then
                echo ""
                echo "No difference"
        else
                echo ""
                echo "Missing from the database:"
                cat ${TMP_DIFF} | grep "^< " | cut -c3-
        fi
    fi
    if [ `cat ${TMP_DIFF} | grep "^> " | wc -l` -gt 0 ]
    then
        echo ""
        echo "Missing from the schema product:"
        cat ${TMP_DIFF} | grep "^> " | cut -c3-
    fi
}

#
# Tables
#
# 1) Get a list of table names defined in the schema product.
#    - to derive the table name that should be in the database:
#        - use the table name in field 3
#        - remove the "radar." prefix from the table name
#        - remove any "(" at the end of the table name
# 2) Get a list of table names defined in the database.
# 3) Call the diff function.
#
cd ${TOP}/table
rm -f ${TMP_SCHEMA} ${TMP_DB}
grep -i "^CREATE TABLE " *_create.object | cut -d':' -f2 | cut -d' ' -f3 | sed 's/radar\.//' | sed 's/(//' | sed 's/./\L&/g' | sort > ${TMP_SCHEMA}
psql -h ${PG_DBSERVER} -d ${PG_DBNAME} -U ${PG_DBUSER} -t --command "select tablename from pg_catalog.pg_tables where schemaname = 'radar'" | sed "s/ //g" | grep -v "^$" | sort > ${TMP_DB}
do_diff Tables

#
# Indexes
#
# 1) Get a list of index names defined in the schema product.
#    - regular indexes and unique indexes are parsed separately
#    - ignore comment lines that start with "--"
#    - regular indexes are in field 3
#    - unique indexes are in field 4
# 2) Get a list of index names defined in the database.
# 3) Call the diff function.
#
cd ${TOP}/index
rm -f ${TMP_SCHEMA} ${TMP_DB} ${TMP_SORT}
grep -i "^CREATE INDEX " *_create.object | cut -d':' -f2 | grep -v "^\-\-" | cut -d' ' -f3 | sed 's/./\L&/g' > ${TMP_SORT}
grep -i "^CREATE UNIQUE INDEX " *_create.object | cut -d':' -f2 | grep -v "^\-\-" | cut -d' ' -f4 | sed 's/./\L&/g' >> ${TMP_SORT}
sort ${TMP_SORT} > ${TMP_SCHEMA}
psql -h ${PG_DBSERVER} -d ${PG_DBNAME} -U ${PG_DBUSER} -t --command "select indexrelname from pg_stat_user_indexes where schemaname = 'radar' and indexrelname not like '%_pkey'" | sed "s/ //g" | grep -v "^$" | sort > ${TMP_DB}
do_diff Indexes

#
# Stored procedures
#
# 1) Get a list of stored procedure names defined in the schema product.
#    - to derive the table name that should be in the database:
#        - use the procedure name in field 5
#        - remove any "(" at the end of the procedure name
# 2) Get a list of stored procedure names defined in the database.
# 3) Call the diff function.
#
#cd ${TOP}/procedure
#rm -f ${TMP_SCHEMA} ${TMP_DB}
#grep -i "^CREATE OR REPLACE FUNCTION " *_create.object | cut -d':' -f2 | cut -d' ' -f5 | sed 's/(//' | sed 's/./\L&/g' | sort > ${TMP_SCHEMA}
#psql -h ${PG_DBSERVER} -d ${PG_DBNAME} -U ${PG_DBUSER} -t --command "\df" | grep -i "^ radar " | grep -iv ' trigger ' | cut -d'|' -f2 | sed 's/ //g' | sort > ${TMP_DB}
#do_diff Procedures

#
# Primary keys
#
# 1) Get a list of primary key names defined in the schema product.
#    - ignore comment lines that start with "--"
#    - to derive the primary key name that should be in the database:
#        - use the table name in field 3
#        - remove the "radar." prefix from the table name
#        - append "_pkey" to the end off the table name
# 2) Get a list of primary key names defined in the database.
# 3) Call the diff function.
#
cd ${TOP}/key
rm -f ${TMP_SCHEMA} ${TMP_DB}
grep -i "ADD PRIMARY KEY" *_create.object | cut -d':' -f2 | grep -v "^\-\-" | cut -d' ' -f3 | sed 's/radar\.//' | sed 's/$/_pkey/' | sed 's/./\L&/g' | sort > ${TMP_SCHEMA}
psql -h ${PG_DBSERVER} -d ${PG_DBNAME} -U ${PG_DBUSER} -t --command "select indexrelname from pg_stat_user_indexes where schemaname = 'radar' and indexrelname like '%_pkey'" | sed "s/ //g" | grep -v "^$" | sort > ${TMP_DB}
do_diff "Primary Keys"

#
# Foreign keys
#
# 1) Get a list of foreign key names defined in the schema product.
#    - ignore comment lines that start with "--"
#    - to derive the foreign key name that should be in the database:
#        - use the table name in field 3 and the key column in field 7
#        - remove the "radar." prefix from the table name
#        - convert the "(" before the key column to an "_"
#        - convert the ")" or "," after the key column to "_fkey"
# 2) Get a list of foreign key names defined in the database.
# 3) Call the diff function.
#
cd ${TOP}/key
rm -f ${TMP_SCHEMA} ${TMP_DB}
grep -i "ADD FOREIGN KEY" *_create.object | cut -d':' -f2 | grep -v "^\-\-" | awk '{print $3 $7}' | sed 's/radar\.//' | sed 's/(/_/' | sed 's/[),]/_fkey/' | sed 's/./\L&/g' | sort > ${TMP_SCHEMA}
psql -h ${PG_DBSERVER} -d ${PG_DBNAME} -U ${PG_DBUSER} -t --command "select conname from pg_constraint c join pg_namespace n on n.oid = c.connamespace where c.contype in ('f') and n.nspname = 'radar' and conname != 'crs_typings__cross_key_rownumber_fkey'" | sed "s/ //g" | grep -v "^$" | sort > ${TMP_DB}
do_diff "Foreign Keys"

#
# Duplicate keys
#
# Print any duplicate primary/foreign keys in the database.
#
cd ${TOP}
rm -f ${TMP_DB}
psql -h ${PG_DBSERVER} -d ${PG_DBNAME} -U ${PG_DBUSER} -t --command "select c.conname as duplidateKeys from pg_constraint c join pg_namespace n on n.oid = c.connamespace where c.contype in ('f') and n.nspname = 'radar' and c.conname like '%fkey1%'" | grep -v "^$" | sort > ${TMP_DB}
echo ""
echo ""
echo "Duplicate Primary/Foreign Keys"
echo "----------------------------------------"
if [ `cat ${TMP_DB} | wc -l` -eq 0 ]
then
    echo ""
    echo "None"
else
    cat ${TMP_DB}
fi

exit 0

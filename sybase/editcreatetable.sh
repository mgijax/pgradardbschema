#!/bin/sh

#
# create 'table' scripts
#

cd `dirname $0` && . ../Configuration

if [ $# -eq 1 ]
then
    findObject=$1_create.object
else
    findObject=*_create.object
fi

#
# edit "create" tables from sybase to postgres
#

#
# copy radardbschema/table/*_create.object to postgres directory
#
cd ../table
cp ../../radardbschema/table/${findObject} .

#
# convert each radar-format table script to a postgres script
#

for i in ${findObject}
do

ed $i <<END
g/csh -f/s//sh/g
g/\&\& source/s//\&\& ./g
g/create table /s//create table radar./g
g/datetime/s//timestamp without time zone/g
g/bit/s//boolean/g
g/numeric(8,0)    identity/s//serial/g
g/^)/s//);/
/^cat
d
a
cat - <<EOSQL | \${PG_DBUTILS}/bin/doisql.csh \$0

.
/^use
d
d
d
.
/^go
;d
a
EOSQL
.
w
q
END

done


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
cd ${PG_RADAR_DBSCHEMADIR}/table
cp ../../radardbschema/table/${findObject} .

#
# convert each radar-format table script to a postgres script
#
#g/bit/s//boolean/g

for i in ${findObject}
do

ed $i <<END
g/csh -f/s//sh/g
g/ source/s// ./g
g/create table /s//create table radar./g
g/tinyint/s//smallint/g
g/datetime/s//timestamp DEFAULT now()/g
g/_CreatedBy_key.*int/s//_CreatedBy_key                 int DEFAULT 1001/g
g/_ModifiedBy_key.*int/s//_ModifiedBy_key                int DEFAULT 1001/g
g/bit/s//smallint/g
g/float/s//numeric/g
g/numericValue/s//floatValue/g
g/offset/s//cmOffset/g
g/varchar(255)/s//text/g
g/^)/s//);/
/cat
d
a
cat - <<EOSQL | \${PG_DBUTILS}/bin/doisql.csh \$0

.
/^use
d
d
d
.
/^on
;d
a
EOSQL
.
w
q
END

done


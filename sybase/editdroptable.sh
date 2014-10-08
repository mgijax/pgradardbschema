#!/bin/sh

cd `dirname $0` && . ../Configuration

if [ $# -eq 1 ]
then
    findObject=$1_drop.object
else
    findObject=*_drop.object
fi

#
# edit "drop" tables from sybase to postgres 
#

#
# copy radardbschema/table/*_drop.object to postgres directory
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
g/source/s//./g
g/drop table /s//drop table radar./g
/cat
d
a
cat - <<EOSQL | \${PG_DBUTILS}/bin/doisql.csh \$0

.
/^use
d
d
/go
d
a
CASCADE
;
.
/checkpoint
;d
a
EOSQL
.
w
q
END

done


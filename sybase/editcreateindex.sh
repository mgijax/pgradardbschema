#!/bin/sh

#
# for indexes that contain 'idx_primary'
#

cd `dirname $0` && . ../Configuration

if [ $# -eq 1 ]
then
    findObject=$1_create.object
else
    findObject=*_create.object
fi

#
# copy radardbschema/index/*_create.object to postgres directory
#
cd ../index
cp ${RADAR_DBSCHEMADIR}/index/${findObject} .

for i in ${findObject}
do

t=`basename $i _create.object`

ed $i <<END
g/csh -f/s//sh/g
g/ source/s// ./g
g/ nonclustered /s// /g
g/ clustered /s// /g
g/idx/s//${t}_idx/g
g/ on /s// on radar./g
g/^go/s//;/g
/cat
d
.
a
cat - <<EOSQL | \${PG_DBUTILS}/bin/doisql.csh \$0

.
/^use
d
d
d
.
/^checkpoint
;d
.
a

CLUSTER radar.${t} USING ${t}_pkey;
.
a

EOSQL
.
w
q
END

ed $i <<END
/idx_primary
d
d
d
.
w
q
END

done


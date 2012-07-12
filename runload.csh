!#/bin/csh

rm -rf runload.csh.log
touch runload.csh.log

${PG_DBUTILS}/bin/loadDB.csh ${PG_DBSERVER} ${PG_DBNAME} radar /backups/rohan/postgres/radar.postgres.dump | tee -a runload.csh.log


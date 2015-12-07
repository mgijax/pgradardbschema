#!/usr/local/bin/python

#
# create .txt file of:
#
#	MGI_Table.table_name
#	MGI_Tables.description
#

import sys 
import os
import pg_db

db = pg_db
#db.setTrace()

DIR = os.environ['PG_MGD_DBSCHEMADIR']
startScript = '''#!/bin/sh

cd `dirname $0` && . ./Configuration

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0

'''
endScript = 'EOSQL'

results = db.sql('select table_name, description from MGI_Tables', 'auto')

for r in results:

    tableName = r['table_name']
    description = r['description']

    if description != None:
    	description = description.replace("'", "''")

    fp = open(DIR + '/comments/' + tableName + '_create.object', 'w+')
    fp.write(startScript)
    fp.write("COMMENT ON TABLE radar." + tableName + " IS '" + str(description) + "';\n\n")

    cresults = db.sql('select table_name, column_name, description from MGI_Columns where table_name = \'%s\'' % (tableName), 'auto')

    for c in cresults:

        tableName = c['table_name']
        columnName = c['column_name']
        description = c['description']

        if description != None:
    	    description = description.replace("'", "''")
    	    description = description.replace("offset", "cmOffset")

        #columnName = columnName.replace("offset", "cmOffset")

        fp.write("COMMENT ON COLUMN " + tableName + "." + columnName + " IS '" + str(description) + "';\n\n")

    fp.write(endScript)
    fp.close()

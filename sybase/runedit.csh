#!/bin/sh

#
# 1) run all edits
# 2) cvs update : pgradardbschema
# 3) 
#

cd `dirname $0` && . ../Configuration

LOG=$0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

./editcreateindex.sh | tee -a ${LOG}
./editdropindex.sh | tee -a ${LOG}

./editcreatekey.sh | tee -a ${LOG}

./editcreatetable.sh | tee -a ${LOG}
./editdroptable.sh | tee -a ${LOG}
./edittruncatetable.sh | tee -a ${LOG}

date | tee -a ${LOG}


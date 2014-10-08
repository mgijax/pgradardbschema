#!/bin/sh

#
# text cleaner
#

cd `dirname $0` && . ../Configuration

# directory
cd $1

# bcp file you wish to clean
i=$2

cat $i.bcp | ${MGI_PYTHONLIB}/postgresTextCleaner.py > $i.new
rm $i.bcp
#mv $i.new $i.bcp

#
# leave this in as it translates the timestamp
# the 'exporter/postgresTestCleaner.py' does not do this
#
echo 'converting bcp using perl...', ${i} | tee -a ${LOG}
/usr/local/bin/perl -p -i -e 's/\t(... {1,2}\d{1,2} \d{4} {1,2}\d{1,2}:\d\d:\d\d):(.{5})/\t\1.\2/g' $i.new


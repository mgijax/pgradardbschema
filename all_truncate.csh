#!/bin/sh

#
# Script to call all truncate sh scripts
#

cd `dirname $0`

foreach i (table)
cd $i
foreach j (*_truncate.sh)
$j $*
end
cd ..
end


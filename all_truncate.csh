#!/bin/csh -f -x

#
# Script to call all truncate csh scripts
#

cd `dirname $0`

foreach i (table)
cd $i
foreach j (*_truncate.csh)
$j $*
end
cd ..
end


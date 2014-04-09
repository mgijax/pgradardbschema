#!/bin/csh -f

#
# Script to call all bind and create csh scripts
# Order is important!
#

cd `dirname $0`

foreach i (key index)
cd $i
foreach j (*_create.csh)
$j $*
end
cd ..
end


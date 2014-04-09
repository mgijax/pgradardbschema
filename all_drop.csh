#!/bin/csh -f

#
# Script to call all drop csh scripts
# Order is important!
#

cd `dirname $0`

foreach i (key index)
cd $i
foreach j (*_drop.csh)
$j $*
end
cd ..
end


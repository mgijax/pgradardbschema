#!/bin/sh

#
# Script to call all drop sh scripts
# Order is important!
#

cd `dirname $0`

foreach i (key index)
cd $i
foreach j (*_drop.sh)
$j $*
end
cd ..
end


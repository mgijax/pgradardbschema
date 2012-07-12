#!/bin/csh -f -x

#
# Object Group Script
#
# Executes all *_drop.logical scripts
#

cd `dirname $0`

foreach i (*_drop.logical)
$i $*
end


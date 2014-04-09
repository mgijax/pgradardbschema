#!/bin/csh -f

#
# Object Group Script
#
# Executes all *_create.logical scripts
#

cd `dirname $0`

foreach i (*_create.logical)
$i $*
end


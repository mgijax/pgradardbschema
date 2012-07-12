#!/bin/sh

#
# Object Group Script
#
# Executes all *_truncate.object scripts
#

cd `dirname $0` && . ./Configuration

for i in *_truncate.object
do
$i $*
done


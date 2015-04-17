#!/bin/sh

#
# Object Group Script
#
# Executes all *_create.object scripts
#
# Order is important!
#

cd `dirname $0` && . ./Configuration

for i in *create.object
do
$i $*
done


#!/bin/sh

#
# Object Group Script
#
# Executes all *_create.logical scripts
#
# Order is important!
#

cd `dirname $0` && . ./Configuration

for i in *drop.object
do
$i $*
done


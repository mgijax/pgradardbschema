#!/bin/sh

cd `dirname $0` && . ../Configuration

./comments.py
chmod 775 ${PG_RADAR_DBSCHEMADIR}/comments/*object


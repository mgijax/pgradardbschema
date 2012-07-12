#!/bin/sh

# Count the number of create scripts for each type of object in the schema
# product and the number of objects that will be created by those scripts.

cd `dirname $0`
TOP=`pwd`

echo "Object Type     Count"
echo "==============  ============"

cd ${TOP}/table
echo "Tables          `ls *_create.object | wc -l` scripts"

cd ${TOP}/index
echo "Indexes         `ls *_create.object | wc -l` scripts  (`grep -i '^create .* index ' *_create.object | wc -l` indexes)"

cd ${TOP}/key
echo "Keys            `ls *_create.object | wc -l` scripts  (`grep -i '^sp_primarykey ' *_create.object | wc -l` primary keys, `grep -i '^sp_foreignkey ' *_create.object | wc -l` foreign keys)"

cd ${TOP}/trigger
echo "Triggers        `ls *_create.object | wc -l` scripts  (`grep -i '^create trigger ' *_create.object | wc -l` triggers)"

cd ${TOP}/procedure
echo "Procedures      `ls *_create.object | wc -l` scripts"


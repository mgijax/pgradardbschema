#!/bin/csh

foreach i (*.object)
echo $i
ed $i <<END
g/\${PG_RADAR_DBSERVER} /s///g
g/\${PG_RADAR_DBNAME} /s///g
.
w
q
END
end


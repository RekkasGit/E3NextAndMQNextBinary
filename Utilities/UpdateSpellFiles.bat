powershell -Command "Invoke-WebRequest http://192.99.254.193:3000/api/v1/eqemuserver/export-client-file/spells -OutFile '.\spells_us.txt'"
powershell -Command "Invoke-WebRequest http://192.99.254.193:3000/api/v1/eqemuserver/export-client-file/dbstring -OutFile '.\dbstr_us.txt'"

powershell Copy-Item '.\spells_us.txt' -Destination 'C:\Project Lazarus\RoF2\' -force
powershell Copy-Item '.\spells_us.txt' -Destination 'C:\Project Lazarus\RoF3\' -force

powershell Copy-Item '.\dbstr_us.txt' -Destination 'C:\Project Lazarus\RoF2\' -force
powershell Copy-Item '.\dbstr_us.txt' -Destination 'C:\Project Lazarus\RoF3\' -force
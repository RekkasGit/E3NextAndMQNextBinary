powershell -Command "Invoke-WebRequest http://15.235.113.14:3000/api/v1/eqemuserver/export-client-file/spells -OutFile '.\spells_us.txt'"
powershell -Command "Invoke-WebRequest  http://15.235.113.14:3000/api/v1/eqemuserver/export-client-file/dbstring -OutFile '.\dbstr_us.txt'"

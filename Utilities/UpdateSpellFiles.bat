powershell -Command "Invoke-WebRequest http://192.99.254.193:3000/download/spells -OutFile '.\spells_us.zip'"
powershell Expand-Archive '.\spells_us.zip' -DestinationPath 'G:\EQ\Project Lazarus' -force
powershell Expand-Archive '.\spells_us.zip' -DestinationPath 'G:\EQ\Project_Lazarus_Bots' -force
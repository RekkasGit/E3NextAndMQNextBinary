REM launch eq without wineq
REM you can use multiple eq directory AND multiple eqclient.ini, though bugs exist with the eqclient.  see config\mq2autologin.ini
tasklist /nh /fi "WINDOWTITLE eq Rekken"| find /i "eqgame.exe" > nul ||(start "Rekken" /d "G:\EQ\Project Lazarus" "G:\EQ\Project Lazarus\eqgame.exe" patchme /Login:<AccountName>)  && (timeout /t 8)
tasklist /nh /fi "WINDOWTITLE eq Alara" | find /i "eqgame.exe" > nul ||(start "Alara" /d "G:\EQ\Project_Lazarus_Bots" "G:\EQ\Project_Lazarus_Bots\eqgame.exe" patchme /Login:<AccountName>) && (timeout /t 8)

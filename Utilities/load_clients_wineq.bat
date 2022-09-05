@ECHO OFF
D:
CHOICE /C YN /N /T 15 /D N /M "Do you wish to launch the WinEQ and MQ2?"
IF ERRORLEVEL 2 GOTO G1
@ECHO Launching EQBCS
CD D:\E3_RoF2
START D:\E3_RoF2\EQBCS2.exe
PING localhost -n 2 -w 500 >> NULL
@ECHO Launching MQ2
START D:\E3_RoF2\MacroQuest2.exe
PING localhost -n 2 -w 500 >> NULL
@ECHO Launching WinEQ
CD D:\WinEQ2_RoF2
START D:\WinEQ2_RoF2\WinEQ2.exe
PING localhost -n 4 -w 750 >> NULL
:G1
CD D:\WinEQ2_RoF2
CHOICE /C YN /N /T 15 /D Y /M "Do you wish to launch All Raid Groups?"
IF ERRORLEVEL 2 GOTO G3

@ECHO Launching Creamo
START D:\WinEQ2_RoF2\WinEQ2.exe /plugin:WinEQ2-EQ.dll "Creamo"
PING localhost -n 8 -w 300 >> NULL
@ECHO Launching Bosom
START D:\WinEQ2_RoF2\WinEQ2.exe /plugin:WinEQ2-EQ.dll "Bosom"
PING localhost -n 8 -w 300 >> NULL
@ECHO Launching Lush
START D:\WinEQ2_RoF2\WinEQ2.exe /plugin:WinEQ2-EQ.dll "Lush"
PING localhost -n 8 -w 300 >> NULL

@ECHO Launching Skinf
START D:\WinEQ2_RoF2\WinEQ2.exe /plugin:WinEQ2-EQ.dll "Skinf"
PING localhost -n 8 -w 300 >> NULL
@ECHO Launching Barrymanilow
START D:\WinEQ2_RoF2\WinEQ2.exe /plugin:WinEQ2-EQ.dll "Barrymanilow"
PING localhost -n 8 -w 300 >> NULL
@ECHO Launching Stefani
START D:\WinEQ2_RoF2\WinEQ2.exe /plugin:WinEQ2-EQ.dll "Stefani"
PING localhost -n 8 -w 300 >> NULL
@ECHO Launching Orbison
START D:\WinEQ2_RoF2\WinEQ2.exe /plugin:WinEQ2-EQ.dll "Orbison"
PING localhost -n 8 -w 300 >> NULL

@ECHO Launching Lawndart
START D:\WinEQ2_RoF2\WinEQ2.exe /plugin:WinEQ2-EQ.dll "Lawndart"
PING localhost -n 8 -w 300 >> NULL
@ECHO Launching Nramember
START D:\WinEQ2_RoF2\WinEQ2.exe /plugin:WinEQ2-EQ.dll "Nramember"
PING localhost -n 8 -w 300 >> NULL
@ECHO Launching Balron
START D:\WinEQ2_RoF2\WinEQ2.exe /plugin:WinEQ2-EQ.dll "Balron"
PING localhost -n 8 -w 300 >> NULL

@ECHO Launching Muddy
START D:\WinEQ2_RoF2\WinEQ2.exe /plugin:WinEQ2-EQ.dll "Muddy"
PING localhost -n 8 -w 300 >> NULL
@ECHO Launching Kalortpor
START D:\WinEQ2_RoF2\WinEQ2.exe /plugin:WinEQ2-EQ.dll "Kalortpor"
PING localhost -n 10 -w 1100 >> NULL
@ECHO Launching Pontoon
START D:\WinEQ2_RoF2\WinEQ2.exe /plugin:WinEQ2-EQ.dll "Pontoon"
PING localhost -n 10 -w 1100 >> NULL

@ECHO Launching Clasper
START D:\WinEQ2_RoF2\WinEQ2.exe /plugin:WinEQ2-EQ.dll "Clasper"
PING localhost -n 8 -w 300 >> NULL
@ECHO Launching Drzoidberg
START D:\WinEQ2_RoF2\WinEQ2.exe /plugin:WinEQ2-EQ.dll "Drzoidberg"
PING localhost -n 8 -w 300 >> NULL
@ECHO Launching Newskin
START D:\WinEQ2_RoF2\WinEQ2.exe /plugin:WinEQ2-EQ.dll "Newskin"
PING localhost -n 8 -w 300 >> NULL
@ECHO Launching Deodorant
START D:\WinEQ2_RoF2\WinEQ2.exe /plugin:WinEQ2-EQ.dll "Deodorant"
PING localhost -n 8 -w 300 >> NULL

@ECHO Launching Mammary
START D:\WinEQ2_RoF2\WinEQ2.exe /plugin:WinEQ2-EQ.dll "Mammary"
PING localhost -n 8 -w 300 >> NULL
@ECHO Launching Ointment
START D:\WinEQ2_RoF2\WinEQ2.exe /plugin:WinEQ2-EQ.dll "Ointment"
PING localhost -n 8 -w 300 >> NULL
@ECHO Launching Bushmills
START D:\WinEQ2_RoF2\WinEQ2.exe /plugin:WinEQ2-EQ.dll "Bushmills"
PING localhost -n 8 -w 300 >> NULL
@ECHO Launching Jamesons
START D:\WinEQ2_RoF2\WinEQ2.exe /plugin:WinEQ2-EQ.dll "Jamesons"
PING localhost -n 8 -w 300 >> NULL

@ECHO Launching Cremora
START D:\WinEQ2_RoF2\WinEQ2.exe /plugin:WinEQ2-EQ.dll "Cremora"
PING localhost -n 8 -w 300 >> NULL
@ECHO Launching Craic
START D:\WinEQ2_RoF2\WinEQ2.exe /plugin:WinEQ2-EQ.dll "Craic"
PING localhost -n 8 -w 300 >> NULL
@ECHO Launching Caryelwes
START D:\WinEQ2_RoF2\WinEQ2.exe /plugin:WinEQ2-EQ.dll "Caryelwes"
PING localhost -n 8 -w 300 >> NULL
@ECHO Launching Tuica
START D:\WinEQ2_RoF2\WinEQ2.exe /plugin:WinEQ2-EQ.dll "Tuica"
PING localhost -n 8 -w 300 >> NULL

:G3
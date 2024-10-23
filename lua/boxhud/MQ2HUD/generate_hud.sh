#!/bin/bash

# Defaults
NUM_CLIENTS=24
INITIAL_X_OFFSET=70
Y_OFFSET=190

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -x|--xoffset)
    INITIAL_X_OFFSET="$2"
    shift # past argument
    shift # past value
    ;;
    -y|--yoffset)
    Y_OFFSET="$2"
    shift # past argument
    shift # past value
    ;;
    -n|--numclients)
    NUM_CLIENTS="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

echo "Generating MQ2HUD.ini with the following parameters:"
echo "X Offset   = ${INITIAL_X_OFFSET}"
echo "Y Offset   = ${Y_OFFSET}"
echo "Clients    = ${NUM_CLIENTS}"

namexoffset=${INITIAL_X_OFFSET}
hpxoffset=150
manaxoffset=190
endxoffset=230
distxoffset=270
targetxoffset=310
castxoffset=410

cat << EOF > MQ2HUD.ini
[MQ2HUD]
Last=Elements
SkipParse=1
CheckINI=10
UpdateInBackground=on
ClassHUD=off
ZoneHUD=off
UseFontSize=on

[DynaHUD]
; ==== Headers ====
Header1=3,2,${namexoffset},${Y_OFFSET},255,255,255,Name (\${NetBots.Counts})
Header2=3,2,${hpxoffset},${Y_OFFSET},255,255,255,HP%
Header3=3,2,${manaxoffset},${Y_OFFSET},255,255,255,MP%
Header4=3,2,${endxoffset},${Y_OFFSET},255,255,255,EP%
Header5=3,2,${distxoffset},${Y_OFFSET},255,255,255,Dist
Header6=3,2,${targetxoffset},${Y_OFFSET},255,255,255,Target
Header7=3,2,${castxoffset},${Y_OFFSET},255,255,255,Casting
HeaderBG=3,2,${namexoffset},${Y_OFFSET},0,0,0,███████████████████████████████████████████████████

EOF

((Y_OFFSET+=15))

for ((index=1 ; index <= ${NUM_CLIENTS} ; index++)) ; do
  cat << EOF >> MQ2HUD.ini
;==== Character ${index} ====
IZNIC${index}=3,2,70,${Y_OFFSET},0,255,0,\${If[\${NetBots.Counts}>=${index},\${If[\${Bool[\${NetBots[\${NetBots.Client.Arg[${index}]}].InZone}]},\${If[\${Bool[\${NetBots[\${NetBots.Client.Arg[${index}]}].Invis}]},,\${NetBots.Client.Arg[${index}]}]}, ]}, ]}
IZIC${index}=3,2,70,${Y_OFFSET},25,250,250,\${If[\${NetBots.Counts}>=${index},\${If[\${Bool[\${NetBots[\${NetBots.Client.Arg[${index}]}].InZone}]},\${If[\${Bool[\${NetBots[\${NetBots.Client.Arg[${index}]}].Invis}]},(\${NetBots.Client.Arg[${index}]}),]}, ]}, ]}
NIZC${index}=3,2,70,${Y_OFFSET},255,0,0,\${If[\${NetBots.Counts}>=${index},\${If[\${Bool[\${NetBots[\${NetBots.Client.Arg[${index}]}].InZone}]},,\${NetBots.Client.Arg[${index}]}]}, ]}
HPGC${index}=3,2,150,${Y_OFFSET},0,255,0,\${If[\${NetBots.Counts}>=${index},\${If[\${NetBots[\${NetBots.Client.Arg[${index}]}].PctHPs}>70,\${NetBots[\${NetBots.Client.Arg[${index}]}].PctHPs}%,]}, ]}
HPRC${index}=3,2,150,${Y_OFFSET},255,0,0,\${If[\${NetBots.Counts}>=${index},\${If[\${NetBots[\${NetBots.Client.Arg[${index}]}].PctHPs}<=70,\${NetBots[\${NetBots.Client.Arg[${index}]}].PctHPs}%,]}, ]}
MPGC${index}=3,2,190,${Y_OFFSET},0,255,0,\${If[\${NetBots.Counts}>=${index},\${If[\${Select[\${NetBots[\${NetBots.Client.Arg[${index}]}].Class},Cleric,Druid,Shaman,Enchanter,Wizard,Necromancer,Magician,Ranger,Beastlord,Shadow Knight]},\${If[\${NetBots[\${NetBots.Client.Arg[${index}]}].PctMana}>50,\${NetBots[\${NetBots.Client.Arg[${index}]}].PctMana}%,]},\${If[\${NetBots[\${NetBots.Client.Arg[${index}]}].PctEndurance}>50,\${NetBots[\${NetBots.Client.Arg[${index}]}].PctEndurance}%,]}]},]}
MPRC${index}=3,2,190,${Y_OFFSET},255,0,0,\${If[\${NetBots.Counts}>=${index},\${If[\${Select[\${NetBots[\${NetBots.Client.Arg[${index}]}].Class},Cleric,Druid,Shaman,Enchanter,Wizard,Necromancer,Magician,Ranger,Beastlord,Shadow Knight]},\${If[\${NetBots[\${NetBots.Client.Arg[${index}]}].PctMana}<=50,\${NetBots[\${NetBots.Client.Arg[${index}]}].PctMana}%,]},\${If[\${NetBots[\${NetBots.Client.Arg[${index}]}].PctEndurance}<=50,\${NetBots[\${NetBots.Client.Arg[${index}]}].PctEndurance}%,]}]},]}
EPGC${index}=3,2,230,${Y_OFFSET},0,255,0,\${If[\${NetBots.Counts}>=${index},\${If[\${Select[\${NetBots[\${NetBots.Client.Arg[${index}]}].Class},Cleric,Druid,Shaman,Enchanter,Wizard,Necromancer,Magician,Ranger,Beastlord,Shadow Knight]},\${If[\${NetBots[\${NetBots.Client.Arg[${index}]}].PctMana}>50,\${NetBots[\${NetBots.Client.Arg[${index}]}].PctMana}%,]},\${If[\${NetBots[\${NetBots.Client.Arg[${index}]}].PctEndurance}>50,\${NetBots[\${NetBots.Client.Arg[${index}]}].PctEndurance}%,]}]},]}
EPRC${index}=3,2,230,${Y_OFFSET},255,0,0,\${If[\${NetBots.Counts}>=${index},\${If[\${Select[\${NetBots[\${NetBots.Client.Arg[${index}]}].Class},Cleric,Druid,Shaman,Enchanter,Wizard,Necromancer,Magician,Ranger,Beastlord,Shadow Knight]},\${If[\${NetBots[\${NetBots.Client.Arg[${index}]}].PctMana}<=50,\${NetBots[\${NetBots.Client.Arg[${index}]}].PctMana}%,]},\${If[\${NetBots[\${NetBots.Client.Arg[${index}]}].PctEndurance}<=50,\${NetBots[\${NetBots.Client.Arg[${index}]}].PctEndurance}%,]}]},]}
DCLSC${index}=3,2,270,${Y_OFFSET},0,255,0,\${If[\${NetBots.Counts}>=${index},\${If[\${NetBots[\${NetBots.Client.Arg[${index}]}].InZone}&&\${Spawn[\${NetBots[\${NetBots.Client.Arg[${index}]}].ID}].Distance3D}<=100,\${Spawn[\${NetBots[\${NetBots.Client.Arg[${index}]}].ID}].Distance3D},]},]}
DMIDC${index}=3,2,270,${Y_OFFSET},255,255,0,\${If[\${NetBots.Counts}>=${index},\${If[\${NetBots[\${NetBots.Client.Arg[${index}]}].InZone}&&(\${Spawn[\${NetBots[\${NetBots.Client.Arg[${index}]}].ID}].Distance3D}>100&&\${Spawn[\${NetBots[\${NetBots.Client.Arg[${index}]}].ID}].Distance3D}<=200),\${Spawn[\${NetBots[\${NetBots.Client.Arg[${index}]}].ID}].Distance3D},]},]}
DFARC${index}=3,2,270,${Y_OFFSET},255,0,0,\${If[\${NetBots.Counts}>=${index},\${If[\${NetBots[\${NetBots.Client.Arg[${index}]}].InZone}&&\${Spawn[\${NetBots[\${NetBots.Client.Arg[${index}]}].ID}].Distance3D}>200,\${Spawn[\${NetBots[\${NetBots.Client.Arg[${index}]}].ID}].Distance3D},]},]}
TGC${index}=3,2,310,${Y_OFFSET},0,255,0,\${If[\${NetBots.Counts}>=${index},\${If[\${Bool[\${NetBots[\${NetBots.Client.Arg[${index}]}].TargetID}]},\${Spawn[id \${NetBots[\${NetBots.Client.Arg[${index}]}].TargetID}].CleanName.Left[20]}, ]}, ]}
CSTC${index}=3,2,410,${Y_OFFSET},255,255,0,\${If[\${NetBots.Counts}>=${index},\${If[\${Bool[\${NetBots[\${NetBots.Client.Arg[${index}]}].Casting}]},\${NetBots[\${NetBots.Client.Arg[${index}]}].Casting}, ]}, ]}
Char${index}BG=3,2,70,${Y_OFFSET},0,0,0,\${If[\${NetBots.Counts}>=${index},███████████████████████████████████████████████████,]}

EOF
  ((Y_OFFSET+=15))
done

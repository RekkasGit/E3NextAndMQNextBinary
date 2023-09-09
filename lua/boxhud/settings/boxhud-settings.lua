--[[
Settings file for boxhud.lua script.

- PeerSource:           The source plugin to retrieve peers from. Either:
                          - dannet
                          - netbots

- DanNetPeerGroup:      DanNet group to load peer data from. Options:
  PeerGroup(deprecated)   - all: The All peer group
                          - zone: The zone_servername_zonename peer group
                        
- RefreshInterval:      Interval to poll observed data (separate from ImGui refresh rate)

- StaleDataTimeout:     Number of seconds before removing stale observed data.
                        This applies to toons which have left the peer group (zoned, logged, etc.)

- Tabs:                 Describe the input to each tab to be displayed. 
                        Properties:
                          - Name: (string)        Name of the tab
                          - Columns: (table)      Columns to display on the tab

- Columns:              Describe the input to each column to be displayed. 
                        Columns defined in the top level Columns setting will appear on all tabs.
                        Columns defined within a specific tab will appear only on that tab.
                        Properties:
                          - Name: (string)        Name of the column
                          - Type: (string)        The type of the column data. May be either:
                                                    - property: content is from an observed or spawn property
                                                    - button: content is a button with user defined action
                          - Properties: (table)   Table of properties for this column
                                                  Valid keys:
                                                    - all: read this property name for all classes
                                                    - caster: read this property name for caster classes
                                                    - melee: read this property name for melee classes
                                                  caster and melee properties take precedence over all
                          - Mappings: (table)     Map one value to another. For example, Macro.Paused
                                                  returns TRUE or FALSE, so this could be used to map
                                                  those to PAUSED and "". 
                                                  Does not apply to percentage values.
                          - Thresholds: (array)   1 threshold value for red/green coloring, or
                                                  2 threshold values for red/yellow/green coloring
                          - Percentage: (boolean) Is the property value a percentage
                          - Ascending: (boolean)  Set to true if higher value is better (green)
                                                  For example, PctHPs Ascending=true so 100% hp is green
                          - Inzone: (boolean)     Only use this property when BotInZone == true
                          - Action: (string)      The command to execute if the column type is button

- ObservedProperties:   List of properties to create observations for
                        Properties:
                          - Name: (string)
                          - DependsOnName: (string)  Name of observed property used to check whether this
                                                     observer should be added
                          - DependsOnValue: (string) Acceptable values of the depended upon property
                                                     for this observer to be added

- SpawnProperties:      List of Spawn properties which are based on spawn data of the observed Me.ID
                        Properties:
                          - Name: (string)        Name of the Spawn property
                          - FromIDProperty: (string) Name of ID property to use for spawn search

- NetBotsProperties:    List of NetBots properties to grab
                        Incase ya still want to use some info from MQ2NetBots instead of DanNet

--]]

return {
    SchemaVersion = 2,

    PeerSource = 'dannet',
    DanNetPeerGroup = 'zone',

    RefreshInterval = 250,

    StaleDataTimeout = 30,

    -- Global columns to display on all tabs
    Columns = {
        ['Name'] = { 
            Type='property',
            Properties=nil, 
            Thresholds=nil, 
            Percentage=false, 
            InZone=false
        },
        ['HP%'] = {
            Type='property',
            Properties={all='Me.PctHPs'}, 
            Thresholds={35,70}, 
            Percentage=true, 
            Ascending=true,
            InZone=false
        },
        ['MP%'] = {
            Type='property',
            Properties={all='Me.PctMana'}, 
            Thresholds={35,70}, 
            Percentage=true, 
            Ascending=true,
            InZone=false
        },
        ['EP%'] = {
            Type='property',
            Properties={all='Me.PctEndurance'}, 
            Thresholds={35,70}, 
            Percentage=true,
            Ascending=true,
            InZone=false
        },
        ['Distance'] = {
            Type='property',
            Properties={all='Distance3D'}, 
            Thresholds={100,200}, 
            Percentage=false, 
            Ascending=false,
            InZone=true
        },
        ['Target'] = {
            Type='property',
            Properties={all='Target.CleanName'}, 
            Thresholds=nil, 
            Percentage=false, 
            InZone=true
        },
        ['Spell/Disc'] = {
            Type='property',
            Properties={
                all='Me.Casting.Name',
                melee='Me.ActiveDisc.Name'
            }, 
            Thresholds=nil, 
            Percentage=false, 
            InZone=false
        },
        ['Macro'] = {
            Type='property',
            Properties={
                all='Macro.Name'
            },
            Thresholds=nil,
            Percentage=false,
            InZone=false
        },
        ['Paused'] = {
            Type='property',
            Properties={
                all='Macro.Paused'
            },
            Mappings={
                TRUE='PAUSED',
                FALSE=''
            },
            Thresholds=nil,
            Percentage=false,
            InZone=false
        },
        ['Pause'] = {
            Type='button',
            Action='/dex #botName# /mqp'
        },
        ['End'] = {
            Type='button',
            Action='/dex #botName# /end'
        },
        ['Exp%'] = {
            Type='property',
            Properties={
                all='Me.PctExp'
            },
            Thresholds={33,66},
            Percentage=true,
            Ascending=true,
            InZone=false
        },
        ['AA Unspent'] = {
            Type='property',
            Properties={
                all='Me.AAPoints'
            },
            Thresholds={50,100},
            Percentage=false,
            Ascending=false,
            InZone=false
        }
        --[[ Example columns
        ['Macro'] = {
            Type='property',
            Properties={
                all='Macro.Name',
                war='CWTN.Mode',
                ber='CWTN.Mode',
                bst='CWTN.Mode',
                shd='CWTN.Mode',
                clr='CWTN.Mode',
                shm='CWTN.Mode',
                rog='CWTN.Mode'
            },
            Thresholds=nil,
            Percentage=false,
            InZone=false
        },
        ['Paused'] = {
            Type='property',
            Properties={
                all='Macro.Paused',
                war='CWTN.Paused',
                ber='CWTN.Paused',
                bst='CWTN.Paused',
                shd='CWTN.Paused',
                clr='CWTN.Paused',
                shm='CWTN.Paused',
                rog='CWTN.Paused'
            },
            Mappings={
                TRUE='PAUSED',
                FALSE=''
            },
            Thresholds=nil,
            Percentage=false,
            InZone=false
        },
        ['CombatState'] = {
            Type='property',
            Properties={
                all='Me.CombatState'
            }, 
            Thresholds=nil, 
            Percentage=false, 
            InZone=false
        },
        ['Junk Drink'] = {
            Type='property',
            Properties={
                all='FindItemCount[=Water Flask]'
            }, 
            Thresholds=nil, 
            Percentage=false, 
            InZone=false
        },
        ['IVU'] = {
            Type='property',
            Properties={
                all='Me.Invis[UNDEAD]'
            }, 
            Thresholds=nil, 
            Percentage=false, 
            InZone=false
        }
        -- NetBots example columns
        ['InZone'] = {
            Type='property',
            Properties={
                all='InZone'
            }, 
            Thresholds=nil, 
            Percentage=false, 
            InZone=false
        },
        ['Casting'] = {
            Type='property',
            Properties={
                all='Casting'
            }, 
            Thresholds=nil, 
            Percentage=false, 
            InZone=false
        },
        ['Invis'] = {
            Type='property',
            Properties={
                all='Invis'
            }, 
            Thresholds=nil, 
            Percentage=false, 
            InZone=false
        }
        --]]
    },

    Tabs = {
        {
            Name='General',
            Columns={
                'Name',
                'HP%',
                'MP%',
                'EP%',
                'Distance',
                'Target',
                'Spell/Disc'
            }
        },
        {
            Name='Macros',
            Columns = {
                'Name',
                'Macro',
                'Paused',
                'Pause',
                'End'
            }
        },
        {
            Name='XP',
            Columns = {
                'Name',
                'Exp%',
                'AA Unspent'
            }
        }
        --[[
        {
            Name='Examples',
            Columns = {
                'CombatState',
                'Junk Drink',
                'IVU'
            }
        }
        --]]
        --[[
        {
            Name='NetBotsExamples',
            Columns = {
                'InZone',
                'Casting',
                'Invis'
            }
        }
        --]]
    },

    Properties = {
        -- Column specific
        ['Me.Class.ShortName'] = { Type='Observed' },
        ['Me.PctHPs'] = { Type='Observed' },
        ['Me.PctMana'] = { Type='Observed' },
        ['Me.PctEndurance'] = { Type='Observed' },
        ['Me.Casting.Name'] = { Type='Observed' },
        ['Me.ActiveDisc.Name'] = { Type='Observed' },
        ['Target.CleanName'] = { Type='Observed' },
        ['Macro.Name'] = { Type='Observed' },
        ['Macro.Paused'] = { Type='Observed' },
        ['Me.PctExp'] = { Type='Observed' },
        ['Me.AAPoints'] = { Type='Observed' },
        ['Distance3D'] = { Type='Spawn' }
        -- Other example properties
        --['CTWN.Paused'] = {
        --    Type='Observed',
        --    DependsOnName='Me.Class.ShortName',
        --    DependsOnValue='MNK,ROG,WAR,SHD,MAG,ENC,CLR,BST,SHM'
        --},
        --['CWTN.Mode'] = {
        --    Type='Observed',
        --    DependsOnName='Me.Class.ShortName',
        --    DependsOnValue='MNK,ROG,WAR,SHD,MAG,ENC,CLR,BST,SHM'
        --},
        --['Me.CombatState'] = { Type='Observed'},
        --['FindItemCount[=Water Flask]'] = { Type='Observed'] },
        --['Me.Invis[UNDEAD]'] = { Type='Observed' }
        -- Example netbots properties
        --['TargetID'} = { Type='NetBots' },
        --['InZone'} = { Type='NetBots' },
        --['Casting'} = { Type='NetBots' },
        --['Invis'] = { Type='NetBots' }
    }
}

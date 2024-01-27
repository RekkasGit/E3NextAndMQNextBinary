--[[
Test settings for schema validation.
Run with: /lua run boxhud boxhud-settings-testschema.lua
--]]
return {
    PeerSource = 'dannet',
    DanNetPeerGroup = 'zone',

    RefreshInterval = 250,

    StaleDataTimeout = 30,

    -- Global columns to display on all tabs
    Columns = {
        { 
            Name='Name',
            Type='property',
            Properties=nil, 
            Thresholds=nil, 
            Percentage=false, 
            InZone=false
        }
    },

    Tabs = {
        {
            Name='General',
            Columns={
                {
                    Type='property',
                    Properties={all='Me.PctHPs'}, 
                    Thresholds={35,70}, 
                    Percentage=true, 
                    Ascending=true,
                    InZone=false
                },
                { 
                    Name=1, 
                    Type='property',
                    Properties={all='Me.PctMana'}, 
                    Thresholds={35,70}, 
                    Percentage=true, 
                    Ascending=true,
                    InZone=false
                },
                { 
                    Name='EP%', 
                    Type='property',
                    Properties={all='Me.PctEndurance'}, 
                    Thresholds={35,70,80}, 
                    Percentage=true,
                    Ascending=true,
                    InZone=false
                },
                { 
                    Name='Distance', 
                    Type='property',
                    Properties={all='Distance3D'}, 
                    Thresholds={300,200}, 
                    Percentage=false, 
                    Ascending=false,
                    InZone=true
                },
                { 
                    Name='Target', 
                    Type='property',
                    Properties=nil, 
                    Thresholds=nil, 
                    Percentage=5, 
                    InZone=true
                },
                { 
                    Name='Spell/Disc', 
                    Type='property',
                    Properties={
                        all='badproperty',
                        melee='Me.ActiveDisc.Name'
                    }, 
                    Thresholds=nil, 
                    Percentage=false, 
                    InZone='yes'
                }
            }
        },
        {
            Name='Macros',
            Columns = {
                {
                    Name='Macro',
                    Type='property',
                    Properties={
                        all='Macro.Name'
                    },
                    Thresholds=nil,
                    Percentage=false,
                    InZone=false
                },
                {
                    Name='Paused',
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
                {
                    Name='Pause',
                    Type='button',
                    Action=nil
                },
                {
                    Name='End',
                    Type='button',
                    Action='/dex #botName# /end'
                }
                --[[
                {
                    Name='CWTN Paused',
                    Type='property',
                    Properties={
                        all='CWTN.Paused'
                    },
                    Thresholds=nil,
                    Percentage=false,
                    InZone=false
                }
                --]]
            }
        },
        {
            Name='XP',
            Columns = {
                {
                    Name='Exp%',
                    Type='property',
                    Properties={
                        all='Me.PctExp'
                    },
                    Thresholds={33,66},
                    Percentage=true,
                    Ascending=true,
                    InZone=false
                },
                {
                    Name='AA Unspent',
                    Type='badtype',
                    Properties={
                        all='Me.AAPoints'
                    },
                    Thresholds={50,100},
                    Percentage=false,
                    Ascending=false,
                    InZone=false
                }
            }
        }
        --[[
        {
            Name='Examples',
            Columns = {
                { 
                    Name='CombatState', 
                    Type='property',
                    Properties={
                        all='Me.CombatState'
                    }, 
                    Thresholds=nil, 
                    Percentage=false, 
                    InZone=false
                },
                { 
                    Name='Junk Drink', 
                    Type='property',
                    Properties={
                        all='FindItemCount[=Water Flask]'
                    }, 
                    Thresholds=nil, 
                    Percentage=false, 
                    InZone=false
                },
                { 
                    Name='IVU', 
                    Type='property',
                    Properties={
                        all='Me.Invis[UNDEAD]'
                    }, 
                    Thresholds=nil, 
                    Percentage=false, 
                    InZone=false
                }
            }
        }
        --]]
        --[[
        {
            Name='NetBotsExamples',
            Columns = {
                { 
                    Name='InZone', 
                    Type='property',
                    Properties={
                        all='InZone'
                    }, 
                    Thresholds=nil, 
                    Percentage=false, 
                    InZone=false
                },
                { 
                    Name='Casting', 
                    Type='property',
                    Properties={
                        all='Casting'
                    }, 
                    Thresholds=nil, 
                    Percentage=false, 
                    InZone=false
                },
                { 
                    Name='Invis', 
                    Type='property',
                    Properties={
                        all='Invis'
                    }, 
                    Thresholds=nil, 
                    Percentage=false, 
                    InZone=false
                }
            }
        }
        --]]
    },

    ObservedProperties = {
        -- Column specific
        {Name='Me.PctHPs'},
        {Name='Me.PctMana'},
        {Name='Me.PctEndurance'},
        {Name='Me.Casting.Name'},
        {Name='Me.ActiveDisc.Name'},
        {Name='BadTLO'},
        {Name='Macro.Name',DependsOnValue='NoDependsOnName'},
        {Name=5},
        {NotName='Me.PctExp'},
        {Name='Me.AAPoints',DependsOnName='doesnotexist'}
        -- Other example properties
        --{
        --    Name='CWTN.Paused', 
        --    DependsOnName='Me.Class.ShortName', 
        --    DependsOnValue='MNK,ROG,WAR,SHD,MAG,ENC,CLR'
        --}
        --{Name='Me.CombatState'}
        --{Name='FindItemCount[=Water Flask]'}
        --{Name='Me.Invis[UNDEAD]'}
    },

    SpawnProperties = {
        {Name='Distance3D'}
    },

    NetBotsProperties = {
        {Name='Me.PctHPs'}
        -- Example netbots properties
        --{Name='TargetID'},
        --{Name='InZone'},
        --{Name='Casting'},
        --{Name='Invis'}
    }
}

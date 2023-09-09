local Property = require 'classes.config.property'
local Column = require 'classes.config.column'
local Tab = require 'classes.config.tab'
local Window = require 'classes.config.window'
local utils = require 'utils.utils'
local state = require 'state'
local lfs = require 'lfs'

--- @type Mq
local mq = require 'mq'
require('boxhud.utils.persistence')

local s = {}

local settings_file = nil

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local function ValidateOptionalSettings()
    if not state.Settings['Windows'] then
        print_msg('No windows defined, adding default')
        state.Settings['Windows'] = {
            ['default'] = Window({Name='default',Tabs={},Transparency=false,TitleBar=false})
        }
        for _,tab in ipairs(state.Settings['Tabs']) do
            table.insert(state.Settings['Windows']['default']['Tabs'], tab['Name'])
        end
        if state.Settings['PeerSource'] and state.Settings['PeerSource'] == 'dannet' then
            print_msg('Setting default window peer group to '..state.Settings['DanNetPeerGroup'])
            state.Settings['Windows']['default']['PeerGroup'] = state.Settings['DanNetPeerGroup']
        end
    else
        for name,window in pairs(state.Settings['Windows']) do
            state.Settings['Windows'][name] = Window(window)
        end
    end

    if state.Settings['PeerSource'] then
        if state.Settings['PeerSource'] ~= 'dannet' and  state.Settings['PeerSource'] ~= 'netbots' then
            print_err('PeerSource must be either \'dannet\' or \'netbots\'')
            return false
        end
        state.PeerSource = state.Settings['PeerSource']
    end
    if state.PeerSource == 'dannet' then
        state.IsUsingDanNet = true
        local classPropertyFound = false
        local levelPropertyFound = false
        for propName, propSettings in pairs(state.Settings['Properties']) do
            if (propName == 'Me.Class' or propName == 'Me.Class.ShortName') and propSettings['Type'] == 'Observed' then
                classPropertyFound = true
                state.ClassVar = propName
            elseif propName == 'Me.Level' and propSettings['Type'] == 'Observed' then
                levelPropertyFound = true
            end
        end
        if not classPropertyFound then
            state.ClassVar = 'Me.Class.ShortName'
            state.Settings['Properties'][state.ClassVar] = { Type='Observed' }
        end
        if not levelPropertyFound then
            state.Settings['Properties']['Me.Level'] = { Type='Observed' }
        end
    elseif state.PeerSource == 'netbots' then
        state.IsUsingNetBots = true
        if table.getn(state.Settings['Windows']) > 1 then
            print_err('NetBots only supports 1 window')
            return false
        end
        local classPropertyFound = false
        local levelPropertyFound = false
        for propName, propSettings in pairs(state.Settings['Properties']) do
            if propName == 'Class' and propSettings['Type'] == 'NetBots' then
                classPropertyFound = true
                state.ClassVar = propName
            elseif propName == 'Level' and propSettings['Type'] == 'NetBots' then
                levelPropertyFound = true
            end
        end
        if not classPropertyFound then
            state.ClassVar = 'Class'
            state.Settings['Properties'][state.ClassVar] = { Type='NetBots' }
        end
        if not levelPropertyFound then
            state.Settings['Properties']['Level'] = { Type='NetBots' }
        end
    end
    if state.Settings['RefreshInterval'] and type(state.Settings['RefreshInterval']) == 'number' then
        state.RefreshInterval = state.Settings['RefreshInterval']
    end
    if state.Settings['StaleDataTimeout'] and type(state.Settings['StaleDataTimeout']) == 'number' then
        state.StaleDataTimeout = state.Settings['StaleDataTimeout']
    end
    if not state.Settings['Colors'] then
        state.Settings['Colors'] = {}
    end
    state.Settings['Colors']['Default'] = state.Settings['Colors']['Default'] or {1,1,1}
    state.Settings['Colors']['Low'] = state.Settings['Colors']['Low'] or {1,0,0}
    state.Settings['Colors']['Medium'] = state.Settings['Colors']['Medium'] or {1,1,0}
    state.Settings['Colors']['High'] = state.Settings['Colors']['High'] or  {0,1,0}
    state.Settings['Colors']['True'] = state.Settings['Colors']['True'] or {0,1,0}
    state.Settings['Colors']['False'] = state.Settings['Colors']['False'] or {1,0,0}
    state.Settings['Colors']['InZone'] = state.Settings['Colors']['InZone'] or {0,1,0}
    state.Settings['Colors']['Invis'] = state.Settings['Colors']['Invis'] or {0.26, 0.98, 0.98}
    state.Settings['Colors']['IVU'] = state.Settings['Colors']['IVU'] or {0.95, 0.98, 0.26}
    state.Settings['Colors']['DoubleInvis'] = state.Settings['Colors']['DoubleInvis'] or {0.68, 0.98, 0.98}
    state.Settings['Colors']['NotInZone'] = state.Settings['Colors']['NotInZone'] or {1,0,0}
    state.Settings['Transparency'] = state.Settings['Transparency'] or false
    state.Settings['TitleBar'] = state.Settings['TitleBar'] or false
    return true
end

local function ValidateSettings()
    local valid = true
    valid = valid and ValidateOptionalSettings()
    if not state.Settings['Properties'] then
        state.Settings['Properties'] = {}
    end
    for propName,propSettings in pairs(state.Settings['Properties']) do
        local property = Property(propSettings)
        property['Name'] = propName
        valid,_ = property:validate() and valid
        state.Settings['Properties'][propName] = property
    end
    if not state.Settings['Columns'] then
        state.Settings['Columns'] = {}
    end
    for columnName,columnSettings in pairs(state.Settings['Columns']) do
        local column = Column(columnSettings)
        column['Name'] = columnName
        valid,_ = column:validate() and valid
        state.Settings['Columns'][columnName] = column
    end
    if not state.Settings['Columns']['Name'] then
        state.Settings['Columns']['Name'] = {
            ["Name"] = "Name",
            ["Type"] = "property",
			["InZone"] = false,
			["Percentage"] = false,
            ["IncludeLevel"] = false,
        }
    else
        state.Settings['Columns']['Name']['IncludeLevel'] = state.Settings['Columns']['Name']['IncludeLevel'] or false
    end
    if not state.Settings['Tabs'] then
        state.Settings['Tabs'] = {}
    end
    for idx,tabSettings in pairs(state.Settings['Tabs']) do
        local tab = Tab(tabSettings)
        valid,_ = tab:validate() and valid
        state.Settings['Tabs'][idx] = tab
    end
    if not valid then
        print_err('Exiting due to invalid configuration. Review the output above.')
        mq.exit()
    end
end

s.LoadSettings = function(arg)
    -- cleanup files
    for file in lfs.dir(string.format('%s/boxhud/settings', mq.luaDir)) do
        if file ~= '.' and file ~= '..' and file:find('boxhud%-settings%-.*%.lua') then
            os.remove(string.format('%s/boxhud/settings/%s', mq.luaDir, file))
        end
    end
    settings_file = arg[1] or string.format('boxhud-settings-%s.lua', string.lower(mq.TLO.Me.Name()))
    local settings_path = string.format('%s/%s', mq.configDir, settings_file)
    local old_settings_path = string.format('%s/boxhud/settings/%s', mq.luaDir, settings_file)
    local default_settings_path = string.format('%s/boxhud/settings/%s', mq.luaDir, 'boxhud-settings.lua')

    if utils.FileExists(settings_path) then
        print_msg('Loading settings from file: ' .. settings_file)
        state.Settings = assert(loadfile(settings_path))()
    elseif utils.FileExists(old_settings_path) then
        -- copy old settings to new location in boxhud folder
        print_msg(string.format('Moving lua/boxhud/settings/%s to config/%s', settings_file, settings_file))
        utils.CopyFile(old_settings_path, settings_path)
        print_msg('Loading settings from file: ' .. settings_file)
        state.Settings = assert(loadfile(settings_path))()
    else
        print_msg('Loading default settings from file: boxhud-settings')
        -- Default settings
        state.Settings = require('boxhud.settings.boxhud-settings')
        -- Copy defaults into toon specific settings
        utils.CopyFile(default_settings_path, settings_path)
    end

    ValidateSettings()
end

s.SaveSettings = function()
    local settings_path = string.format('%s/%s', mq.configDir, settings_file)
    persistence.store(settings_path, state.Settings)
    return true
end

s.ImportSettings = function(new_settings)
    if new_settings['Properties'] then
        for propName,propSettings in pairs(new_settings['Properties']) do
            if propSettings.selected then
                if not state.Settings['Properties'][propName] then
                    local property = Property(propSettings)
                    property['Name'] = propName
                    local valid,_ = property:validate()
                    if valid then
                        state.Settings['Properties'][propName] = property
                    end
                else
                    print_err(string.format('Property \'%s\' already exists, skipping import.', propName))
                end
            end
        end
    end
    if new_settings['Columns'] then
        for columnName,columnSettings in pairs(new_settings['Columns']) do
            if columnSettings.selected then
                if not state.Settings['Columns'][columnName] then
                    local column = Column(columnSettings)
                    column['Name'] = columnName
                    local valid,_ = column:validate()
                    if valid then
                        state.Settings['Columns'][columnName] = column
                    end
                else
                    print_err(string.format('Column \'%s\' already exists. skipping import.', columnName))
                end
            end
        end
    end
end

return s

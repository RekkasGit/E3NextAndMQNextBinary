--[[
boxhud.lua 2.9.0 -- aquietone
https://www.redguides.com/community/resources/boxhud.2088/

Recreates the traditional MQ2NetBots/MQ2HUD based HUD with a DanNet observer
based lua/ImGui UI.

The tabs, columns and contents are all customizable through the included
boxhud-settings.lua file or individual characters boxhud-settings-name.lua files.
See boxhud-settings.lua for more information on configuration options.

The provided boxhud-settings.lua includes some tabs and columns to get started.

Individual character settings files will always take precedence over the default
settings file.
A specific settings file to use can also be passed in as an argument to the script.

Usage:  /lua run boxhud [settings.lua]
        /boxhud    - toggle the UI window
        /boxhudend - end the script
        /bhadmin   - toggle admin mode. Only purpose is to hide the UI so it
                    doesn't error when resetting observers.
        /bhadmin reset toonname - Reset observed properties for the specified toon.
        /bhadmin anon - toggle showing names or class names in the Name column
        /bhhelp    - Display help output
        /bhversion - Display the running version
--]]
--- @type Mq
local mq = require 'mq'
--- @type ImGui
require 'ImGui'

-- LFS must be downloaded from the luarocks server before anything can work
-- so do that first. This will open a dialog prompting to download lfs.dll
-- if not already present.
-- Include helper function so we can give user friendly messages
local PackageMan = require('mq.PackageMan')
local lfs = PackageMan.Require('luafilesystem', 'lfs')
if not lfs then
    print('\arError loading LuaFileSystem dependency, ending script\ax')
    mq.exit()
end

local WindowState = require 'classes.hud.windowstate'
local ConfigurationPanel = require 'classes.config.configurationpanel'
require 'impl.window'
require 'impl.windowstate'
require 'impl.character'
require 'impl.property'
require 'impl.column'
require 'impl.tab'
require 'impl.configurationpanel'

local utils = require 'utils.utils'
local settings = require 'settings.settings'
local state = require 'state'

local arg = {...}

-- GUI Control variables
local openGUI = true
local shouldDrawGUI = true
local terminate = false

-- Stores all live observed toon information that will be displayed
local adminMode = false

if utils.FileExists(mq.luaDir..'/boxhud.lua') then
    os.remove(mq.luaDir..'/boxhud.lua')
end

-- ImGui main function for rendering the UI window
local HUDGUI = function()
    if not openGUI then return end
    for _,window in pairs(state.Settings.Windows) do
        local flags = 0
        if not window.TitleBar then flags = ImGuiWindowFlags.NoTitleBar end
        if window.Transparency then flags = bit32.bor(flags, ImGuiWindowFlags.NoBackground) end
        if window.Locked then flags = bit32.bor(flags, ImGuiWindowFlags.NoMove) end
        if not ImGui.IsWindowDocked() and window.SavePos then
            if window.pos then ImGui.SetNextWindowPos(ImVec2(window.pos.x, window.pos.y), ImGuiCond.Once) end
            if window.size then ImGui.SetNextWindowSize(ImVec2(window.size.w, window.size.h), ImGuiCond.Once) end
        end
        local colorCount, styleCount = window:drawTheme()
        local doPopRounding = false
        if window.RoundedEdges then
            ImGui.PushStyleVar(ImGuiStyleVar.WindowRounding, 10)
            doPopRounding = true
        end
        if state.WindowStates[window.Name] and state.WindowStates[window.Name].Peers then
            local windowVisibleName = 'Box HUD'
            if window.Name ~= 'default' then
                windowVisibleName = window.Name
            end
            local windowName = windowVisibleName..'##'..state.MyName..window.Name
            if window.OverrideWindowName then
                windowName =  windowVisibleName
            end
            openGUI, shouldDrawGUI = ImGui.Begin(windowName, openGUI, flags)
            if shouldDrawGUI then
                local curWidth = ImGui.GetWindowWidth()
                local curHeight = ImGui.GetWindowHeight()
                if curWidth == 32 and curHeight == 32 then
                    ImGui.SetWindowSize(460, 177)
                    window.size = {w=460, h=177}
                else
                    if window.AutoScaleHeight then
                        local currentSize = ImGui.GetWindowWidth()
                        local height = math.max(160, 25*(#state.WindowStates[window.Name].Peers or 0)+40)
                        ImGui.SetWindowSize(currentSize, height)
                    end
                    window.size = {w=curWidth, h=curHeight}
                end
                local curPos = ImGui.GetWindowPosVec()
                window.pos = {x=curPos.x, y=curPos.y}
                window:drawTabs()
            end
            ImGui.End()
        end
        if colorCount > 0 then ImGui.PopStyleColor(colorCount) end
        if styleCount > 0 then ImGui.PopStyleVar(styleCount) end
        if doPopRounding then ImGui.PopStyleVar(1) end
    end
end

local Admin = function(action, name)
    if action == nil then
        adminMode = not adminMode
        openGUI = not adminMode
        print_msg('Setting \ayadminMode\ax = \ay%s', adminMode)
    elseif action == 'anon' then
        state.Anonymize = not state.Anonymize
    elseif action  == 'reset' then
        if not adminMode then
            print_err('\ayadminMode\ax must be enabled')
            return
        end
        if name == nil then
            print_msg('Resetting observed properties for: \ayALL')
            for _,char in pairs(state.Characters) do
                char:manageObservers(true)
                char:manageObservers(false)
            end
        else
            print_msg('Resetting observed properties for: \ay%s', name)
            state.Characters[name]:manageObservers(true)
            state.Characters[name]:manageObservers(false)
        end
    end
end

local Help = function()
    print_msg('Available commands:')
    print('\ao    /bhhelp\a-w -- Displays this help output')
    print('\ao    /bhversion\a-w -- Displays the version')
    print('\ao    /boxhud\a-w -- Toggle the display')
    print('\ao    /boxhudend\a-w -- End the script')
    print('\ao    /bhadmin\a-w -- Enable admin mode')
    print('\ao    /bhadmin anon\a-w -- Enable anon mode')
    print('\ao    /bhadmin reset all\a-w -- Reset DanNet Observed Properties for all toons')
    print('\ao    /bhadmin reset <name>\a-w -- Reset DanNet Observed Properties for <name>')
end

local ShowVersion = function()
    print_msg('Version %s', state.Version)
end

local function SetupBindings()
    mq.bind('/bhversion', ShowVersion)
    mq.bind('/bhhelp', Help)
    mq.bind('/boxhud', function()
        openGUI = not openGUI
    end)
    mq.bind('/boxhudend', function()
        mq.imgui.destroy('BOXHUDUI')
        shouldDrawGUI = false
        terminate = true
    end)
    mq.bind('/bhadmin', Admin)
end

local function CleanupStaleData(currTime)
    for name, char in pairs(state.Characters) do
        if os.difftime(currTime, char.Properties.lastUpdated) > state.StaleDataTimeout then
            print_msg('Removing stale toon data: \ay%s', name)
            state.Characters[name] = nil
        end
    end
end

local function SendCommand()
    mq.cmd(state.StoredCommand)
    state.StoredCommand = nil
end

local function SetupWindowStates()
    for _,window in pairs(state.Settings.Windows) do
        state.WindowStates[window.Name] = WindowState(window.Name, window.PeerGroup or utils.GetZonePeerGroup(), ConfigurationPanel(window.Name))
        state.WindowStates[window.Name]:refreshPeers()
    end
end

local function CheckGameState()
    if mq.TLO.MacroQuest.GameState() ~= 'INGAME' then
        print_err('\arNot in game, stopping boxhud.\ax')
        openGUI = false
        shouldDrawGUI = false
        mq.imgui.destroy('BOXHUDUI')
        mq.exit()
    end
end

local function main()
    settings.LoadSettings(arg)
    utils.PluginCheck()
    SetupBindings()
    SetupWindowStates()
    mq.imgui.init('BOXHUDUI', HUDGUI)

    -- Initial setup of observers
    if state.IsUsingDanNet then
        for _, char in pairs(state.Characters) do
            char:manageObservers(false)
        end
    end

    -- Main run loop to populate observed property data of toons
    while not terminate do
        CheckGameState()
        if state.StoredCommand then
            SendCommand()
        end
        local currTime = os.time()
        for windowName,window in pairs(state.Settings.Windows) do
            if not state.WindowStates[windowName] then
                state.WindowStates[windowName] = WindowState(windowName, window.PeerGroup or utils.GetZonePeerGroup(), ConfigurationPanel(windowName))
            end
            state.WindowStates[windowName]:refreshPeers()
            if state.WindowStates[windowName].Peers then
                for _, charName in pairs(state.WindowStates[windowName].Peers) do
                    local char = state.Characters[charName]
                    -- Ensure observers are set for the toon
                    if state.IsUsingDanNet then
                        if state.AdminPeerName == char.Name then
                            char:dannetAdminAction()
                        elseif not char:verifyObservers() then
                            char:manageObservers(false)
                        end
                    end
                    char:updateCharacterProperties(currTime, window.PeerGroup)
                end
            end
        end
        CleanupStaleData(currTime)
        mq.delay(state.RefreshInterval)
    end
end

main()

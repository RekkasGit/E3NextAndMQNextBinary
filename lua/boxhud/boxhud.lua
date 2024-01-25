local mq = require 'mq'
require 'ImGui'

local ok, state = pcall(require, 'state')
if not ok then
    print('require state failed')
    BOXHUD_REQUIRE_PREFIX = 'boxhud.boxhud.'
    state = require(BOXHUD_REQUIRE_PREFIX..'state')
    print(state)
else
    BOXHUD_REQUIRE_PREFIX = ''
end
local WindowState = require(BOXHUD_REQUIRE_PREFIX..'classes.hud.windowstate')
local ConfigurationPanel = require(BOXHUD_REQUIRE_PREFIX..'classes.config.configurationpanel')
require(BOXHUD_REQUIRE_PREFIX..'impl.window')
require(BOXHUD_REQUIRE_PREFIX..'impl.windowstate')
require(BOXHUD_REQUIRE_PREFIX..'impl.character')
require(BOXHUD_REQUIRE_PREFIX..'impl.property')
require(BOXHUD_REQUIRE_PREFIX..'impl.column')
require(BOXHUD_REQUIRE_PREFIX..'impl.tab')
require(BOXHUD_REQUIRE_PREFIX..'impl.configurationpanel')

local utils = require(BOXHUD_REQUIRE_PREFIX..'utils.utils')
local settings = require(BOXHUD_REQUIRE_PREFIX..'settings.settings')

local boxhud = {}

-- GUI Control variables
local openGUI = true
local shouldDrawGUI = true
boxhud.terminate = false

-- Stores all live observed toon information that will be displayed
local adminMode = false

function boxhud:RenderWindows()
    if not openGUI then return end
    for _,window in pairs(state.Settings.Windows) do
        local flags = 0
        if not window.TitleBar then flags = ImGuiWindowFlags.NoTitleBar end
        if window.Transparency then flags = bit32.bor(flags, ImGuiWindowFlags.NoBackground) end
        if window.Locked then flags = bit32.bor(flags, ImGuiWindowFlags.NoMove) end
        if window.pos then ImGui.SetNextWindowPos(ImVec2(window.pos.x, window.pos.y), ImGuiCond.Once) end
        if window.size then ImGui.SetNextWindowSize(ImVec2(window.size.w, window.size.h), ImGuiCond.Once) end
        if state.WindowStates[window.Name] and state.WindowStates[window.Name].Peers then
            local windowName = 'Box HUD##'..state.MyName..window.Name
            if window.Name ~= 'default' then windowName = window.Name..'###'..state.MyName..window.Name end
            openGUI, shouldDrawGUI = ImGui.Begin(windowName, openGUI, flags)
            if shouldDrawGUI then
                local curWidth = ImGui.GetWindowWidth()
                local curHeight = ImGui.GetWindowHeight()
                if curWidth == 32 and curHeight == 32 then
                    ImGui.SetWindowSize(460, 177)
                    window.size = {w=460, h=177}
                else
                    window.size = {w=curWidth, h=curHeight}
                end
                local curPos = ImGui.GetWindowPosVec()
                window.pos = {x=curPos.x, y=curPos.y}
                self:Render(window)
            end
            ImGui.End()
        end
    end
end

-- ImGui main function for rendering the UI window
function boxhud:Render(window)
    window:drawTabs()
end

local function Admin(action, name)
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

local function Help()
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

local function ShowVersion()
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
        boxhud.terminate = true
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

local function SetupWindowStates(embedded)
    if embedded then
        local window = state.Settings.Windows.default
        state.WindowStates.default = WindowState(window.Name, window.PeerGroup or utils.GetZonePeerGroup(), ConfigurationPanel(window.Name))
        state.WindowStates.default:refreshPeers()
    else
        for _,window in pairs(state.Settings.Windows) do
            state.WindowStates[window.Name] = WindowState(window.Name, window.PeerGroup or utils.GetZonePeerGroup(), ConfigurationPanel(window.Name))
            state.WindowStates[window.Name]:refreshPeers()
        end
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

local function ProcessWindow(window, windowName, currTime)
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

function boxhud:Process(window)
    CheckGameState()
    if state.StoredCommand then
        SendCommand()
    end
    local currTime = os.time()
    if window then
        ProcessWindow(window, window.Name, currTime)
    else
        for windowName,window in pairs(state.Settings.Windows) do
            ProcessWindow(window, windowName, currTime)
        end
    end
    CleanupStaleData(currTime)
end

function boxhud:GetDefaultWindow()
    return state.Settings.Windows.default
end

function boxhud:Init(arg, embedded)
    state.Embedded = embedded
    settings.LoadSettings(arg or {})
    utils.PluginCheck()
    SetupBindings()
    SetupWindowStates(embedded)
    if not embedded then
        mq.imgui.init('BOXHUDUI', function() boxhud:RenderWindows() end)
    end

    -- Initial setup of observers
    if state.IsUsingDanNet then
        for _, char in pairs(state.Characters) do
            char:manageObservers(false)
        end
    end
end

return boxhud
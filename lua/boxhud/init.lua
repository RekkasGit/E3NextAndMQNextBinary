--[[
boxhud.lua 2.8.0 -- aquietone
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

Running boxhud embedded:
0. git submodule add -b module -f git@github.com:aquietone/boxhud.git boxhud
1. require('boxhud.boxhud.boxhud') -- yes, boxhud repo contains a folder which contains a file named boxhud...
2. boxhud:Init(nil, true) -- arg1 == command line args, just pass nil. arg2 == boolean for embedded mode, pass true
3. boxhud:GetDefaultWindow() -- boxhud supports multiple windows. for embedded mode, get a reference to just the default window settings. must be called after Init so window settings are loaded
4. boxhud:Process(boxhudWindow) -- during each main loop, call Process to grab dannet observer data
5. boxhud:Render(boxhudWindow) -- during imgui callback, call Render to draw the main boxhud table
--]]
local mq = require 'mq'
local boxhud = require 'boxhud'
local state = require 'state'

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

local arg = {...}

boxhud:Init(arg, false)

while true do
    -- Main run loop to populate observed property data of toons
    while not boxhud.terminate do
        boxhud:Process()
        mq.delay(state.RefreshInterval)
    end
end
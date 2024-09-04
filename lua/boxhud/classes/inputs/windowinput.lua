--[[
The WindowInput class holds the inputs for creating a new Window
--]]
local BaseClass = require 'classes.base'
local Input = require 'classes.inputs.input'

local WindowInput = BaseClass(Input(), function(w)
    w.PeerGroup = ''
    w.Tabs = {}
    w.TabCount = 0
end)

return WindowInput
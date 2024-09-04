--[[
The PropertyInput class holds the inputs for creating a new Property
--]]
local BaseClass = require 'classes.base'
local Input = require 'classes.inputs.input'

local PropertyInput = BaseClass(Input(), function(p)
    p.Type=1
    p.DependsOnName=''
    p.DependsOnValue=''
    p.Inverse=false
    p.FromIDProperty=''
    p.showsavewarning = false
    p.savewarningname = ''
end)

return PropertyInput
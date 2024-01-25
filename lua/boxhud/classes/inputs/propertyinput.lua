--[[
The PropertyInput class holds the inputs for creating a new Property
--]]
local BaseClass = require(BOXHUD_REQUIRE_PREFIX..'classes.base')
local Input = require(BOXHUD_REQUIRE_PREFIX..'classes.inputs.input')

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
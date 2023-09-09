--[[
The TabInput class holds the inputs for creating a new Tab
--]]
local BaseClass = require 'classes.base'
local Input = require 'classes.inputs.input'

local TabInput = BaseClass(Input(), function(t)
    t.Columns = {[1]='Name'}
    t.ColumnCount = 1
end)

return TabInput
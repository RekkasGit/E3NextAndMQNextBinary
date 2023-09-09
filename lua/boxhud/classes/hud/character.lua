--[[
Stores all information about a given character to be displayed
in a boxhud window.
--]]
local BaseClass = require 'classes.base'

local Character = BaseClass(function(c, name, className)
    c.Name = name
    c.ClassName = className
    c.Properties = nil
    c.Observers = {}
end)

return Character
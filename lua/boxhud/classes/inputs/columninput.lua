--[[
The ColumnInput class holds the inputs for creating a new Column
--]]
local BaseClass = require 'classes.base'
local Input = require 'classes.inputs.input'

local ColumnInput = BaseClass(Input(), function(c)
    c.Type=1
    c.Properties={[1]={[1]='',[2]=''}}
    c.PropertyCount=1
    c.Mappings={}
    c.MappingCount=0
    c.Thresholds={}
    c.ThresholdCount=0
    c.Percentage=false
    c.Ascending=true
    c.InZone=true
    c.OwnColor=false
    c.Prettify=false
    c.Action=''
end)

return ColumnInput
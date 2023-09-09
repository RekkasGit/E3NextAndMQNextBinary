--[[
The ConfigurationPanel class stores the runtime settings of the configuration tab,
including what is selected, and the input objects for creating new configurations.
--]]
local BaseClass = require 'classes.base'

local ConfigurationPanel = BaseClass(function(c, name)
    c.Name = name
    c.Selected = false
    c.SelectedItem = nil
    c.SelectedItemType = nil
    c.NewProperty = nil
    c.NewColumn = nil
    c.NewTab = nil
    c.NewWindow = nil
    c.LeftPaneSize = 200
    c.BaseLeftPaneSize = 200
    c.ImportFileName = ''
    c.tmp_settings = nil
end)

function ConfigurationPanel:clearSelection()
    self.Selected = false
    self.SelectedItem = nil
    self.SelectedItemType = nil
end

function ConfigurationPanel:selectItem(item, itemType)
    self.SelectedItem = item
    self.SelectedItemType = itemType
end

return ConfigurationPanel
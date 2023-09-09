--[[
The Window class represents the static configuration of a window defined in boxhud-settings
--]]
local BaseClass = require 'classes.base'
local state = require 'state'

local Window = BaseClass(function(w,windowSettings)
    w.Name = windowSettings['Name']
    w.PeerGroup = windowSettings['PeerGroup']
    w.Tabs = windowSettings['Tabs']
    w.Transparency = windowSettings['Transparency']
    w.TitleBar = windowSettings['TitleBar']
end)

local function GetTabByName(tabName)
    for _,tab in ipairs(state.Settings['Tabs']) do
        if tab['Name'] == tabName then
            return tab
        end
    end
    return nil
end

function Window:validate()
    local message = nil
    local valid = true
    if not self.Name or type(self.Name) ~= 'string' or string.len(self.Name) == 0 then
        message = 'Window name is invalid. Name must be a non-empty string'
        print_err(string.format('[Window %s] %s', self.Name, message))
        return false, message
    end
    if self.Tabs then
        if type(self.Tabs) == 'table' then
            for _,tab in ipairs(self.Tabs) do
                if string.len(tab) > 0 then
                    if not GetTabByName(tab) then
                        message = string.format('Window references a tab which does not exist. Tab=%s', tab)
                        print_err(string.format('[Window %s] %s', self.Name, message))
                        valid = false
                    end
                else
                    message = 'Window \'Tab\' values must be non-empty \'string\''
                    print_err(string.format('[Window %s] %s', self.Name, message))
                    valid = false
                end
            end
        else
            message = 'Window \'Tab\' is an unexpected format. \'Tabs\' must be a table.'
            print_err(string.format('[Window %s] %s', self.Name, message))
            valid = false
        end
    end
    return valid, message
end

return Window
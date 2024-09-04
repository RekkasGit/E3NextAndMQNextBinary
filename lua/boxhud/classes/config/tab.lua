--[[
The Tab class represents the static configuration of a tab defined in boxhud-settings
--]]
local BaseClass = require 'classes.base'
local state = require 'state'

local Tab = BaseClass(function(t,tabSettings)
    t.Name = tabSettings['Name']
    t.Columns = tabSettings['Columns']
end)

function Tab:validate()
    local message = nil
    local valid = true
    if not self.Name or type(self.Name) ~= 'string' or string.len(self.Name) == 0 then
        message = string.format('Tabs \'Name\' must be a non-empty \'string\'. Name=%s', self.Name)
        print_err(string.format('[Tab %s] %s', self.Name, message))
        return false, message
    end
    if self.Columns then
        if type(self.Columns) == 'table' then
            for columnIdx,column in ipairs(self.Columns) do
                if string.len(column) > 0 then
                    if not state.Settings['Columns'][column] then
                        message = string.format('Tab references a column which does not exist. Column=%s', column)
                        print_err(string.format('[Tab %s] %s', self.Name, message))
                        valid = false
                    end
                else
                    message = 'Tab \'Column\' values must be non-empty \'string\''
                    print_err(string.format('[Tab %s] %s', self.Name, message))
                    valid = false
                end
            end
        else
            message = 'Tab \'Columns\' is an unexpected format. \'Columns\' must be a table.'
            print_err(string.format('[Tab %s] %s', self.Name, message))
            valid = false
        end
    end
    return valid, message
end

return Tab
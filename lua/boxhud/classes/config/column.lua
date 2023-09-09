--[[
The Column class represents the static configuration of a column defined in boxhud-settings
--]]
local BaseClass = require 'classes.base'
local state = require 'state'

local Column = BaseClass(function(c,columnSettings)
    c.Name = columnSettings['Name']
    c.Type = columnSettings['Type']
    c.Properties = columnSettings['Properties']
    c.Mappings = columnSettings['Mappings']
    c.Thresholds = columnSettings['Thresholds']
    c.Percentage = columnSettings['Percentage']
    c.Ascending = columnSettings['Ascending']
    c.InZone = columnSettings['InZone']
    c.Action = columnSettings['Action']
    c.IncludeLevel = columnSettings['IncludeLevel']
    c.OwnColor = columnSettings['OwnColor']
    c.Color = columnSettings['Color']
    c.Prettify = columnSettings['Prettify']
end)

function Column:validateProperties()
    local message = nil
    local valid = true
    for _,propName in pairs(self.Properties) do
        if string.len(propName) > 0 then
            if not state.Settings['Properties'][propName] then
                message = string.format('Column \'Properties\' must reference a valid \'Observed\', \'NetBots\' or \'Spawn\' property. Name=%s', propName)
                print_err(string.format('[Column %s] %s', self.Name, message))
                valid = false
            end
        else
            message = 'Column \'Properties\' must be non-empty \'string\''
            print_err(string.format('[Column %s] %s', self.Name, message))
            valid = false
        end
    end
    return valid, message
end

function Column:validateMappings()
    local valid = true
    -- what makes a mapping invalid?
    return valid
end

function Column:validateThresholds()
    local message = nil
    if #self.Thresholds > 2 then
        message = 'Column \'Thresholds\' may contain either 1 or 2 number values, no more'
        print_err(string.format('[Column %s] %s', self.Name, message))
        return false, message
    else
        for thresholdIdx, value in ipairs(self.Thresholds) do
            if type(value) ~= 'number' then
                message = 'Column \'Thresholds\' values must be numbers in ascending order'
                print_err(string.format('[Column %s] %s', self.Name, message))
                return false, message
            end
            if thresholdIdx == 2 and value < self.Thresholds[1] then
                message = 'Column \'Thresholds\' values must be numbers in ascending order'
                print_err(string.format('[Column %s] %s', self.Name, message))
                return false, message
            end
        end
    end
    return true, message
end

function Column:validate()
    local message = nil
    if not self.Name or type(self.Name) ~= 'string' or string.len(self.Name) == 0 then
        message = 'Columns name is invalid. Name must be a non-empty string.'
        print_err(string.format('[Column %s] %s', self.Name, message))
        return false, message
    elseif self.Name == 'Name' then
        -- special case name column
        return true, nil
    end
    if self.Type then
        if type(self.Type) ~= 'string' or (self.Type ~= 'button' and self.Type ~= 'property') then
            message = string.format('Column Type must be \'property\' or \'button\'. Type=%s', self.Type)
            print_err(string.format('[Column %s] %s', self.Name, message))
            return false, message
        end
    else
        self.Type = 'property'
    end
    local valid = true
    if self.Type == 'property' then
        if not self.Properties or type(self.Properties) ~= 'table' then
            message = 'Property Columns must have a \'Properties\' table'
            print_err(string.format('[Column %s] %s', self.Name, message))
            valid = false
        else
            local ok, m1 = self:validateProperties()
            if not ok then
                message = m1
                valid = false
            end
        end
        if self.Mappings then
            if type(self.Mappings) ~= 'table' then
                message = 'Column \'Mappings\' must be a table'
                print_err(string.format('[Column %s] %s', self.Name, message))
                valid = false
            else
                local ok, m1 = self:validateMappings()
                if not ok then
                    message = m1
                    valid = false
                end
            end
        end
        if self.Thresholds then 
            if type(self.Thresholds) ~= 'table' then
                message = 'Column \'Thresholds\' must be a table'
                print_err(string.format('[Column %s] %s', self.Name, message))
                valid = false
            else
                local ok, m1 = self:validateThresholds()
                if not ok then
                    message = m1
                    valid = false
                end
            end
        end
        if self.Percentage and type(self.Percentage) ~= 'boolean' then
            message = 'Columns \'Percentage\' must be true or false'
            print_err(string.format('[Column %s] %s', self.Name, message))
            valid = false
        end
        if self.Ascending and type(self.Ascending) ~= 'boolean' then
            message = 'Columns \'Ascending\' must be true or false'
            print_err(string.format('[Column %s] %s', self.Name, message))
            valid = false
        end
        if self.InZone and type(self.InZone) ~= 'boolean' then
            message = 'Column \'InZone\' must be true or false'
            print_err(string.format('[Column %s] %s', self.Name, message))
            valid = false
        end
    elseif self.Type == 'button' then
        if not self.Action or type(self.Action) ~= 'string' then
            message = 'Button Columns must have an \'Actions\' property'
            print_err(string.format('[Column %s] %s', self.Name, message))
            valid = false
        end
    end
    return valid, message
end

return Column
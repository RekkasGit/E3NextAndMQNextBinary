--[[
The Property class represents the static configuration of a property defined in boxhud-settings
--]]
local BaseClass = require 'classes.base'
local state = require 'state'

local Property = BaseClass(function(p,propSettings)
    p.Name = propSettings['Name']
    p.Type = propSettings['Type']
    p.DependsOnName = propSettings['DependsOnName']
    p.DependsOnValue = propSettings['DependsOnValue']
    p.Inverse = propSettings['Inverse']
    p.FromIDProperty = propSettings['FromIDProperty']
end)

function Property:validate()
    local message = nil
    if not self.Name or type(self.Name) ~= 'string' or string.len(self.Name) == 0 then
        message = 'Property name is invalid. Name must be a non-empty string'
        print_err(string.format('[%s %s] %s', self.Type, self.Name, message))
        return false, message
    else
        if self.Type == 'Observed' then
            if self.Name:find('CWTN.') then
                if not self.DependsOnName and not self.DependsOnValue then
                    print_err('Adding CWTN properties without limiting the classes they apply to will almost certainly break macros on non-CWTN boxes!')
                end
            end
            if self.DependsOnName and not state.Settings['Properties'][self.DependsOnName] then
                message = string.format(
                        '[Properties %s] \'DependsOnName\' must refer to another observed property name. DependsOnName=%s', 
                        self.Name, self.DependsOnName)
                print_err(message)
                return false, message
            end
            if self.DependsOnValue and not self.DependsOnName then
                message = string.format('[Properties %s] \'DependsOnValue\' requires \'DependsOnName\' to also be set', self.Name)
                print_err(message)
                return false, message
            end
            if self.Inverse and type(self.Inverse) ~= 'boolean' then
                message = string.format('[Properties %s] \'Inverse\' must be a boolean.', self.Name)
                print_err(message)
                return false, message
            end
            state.IsUsingDanNet = true
        elseif self.Type == 'Spawn' then
            if self.FromIDProperty and not state.Settings['Properties'][self.FromIDProperty] then
                message = string.format(
                        '[Properties %s] \'FromIDProperty\' must refer to a valid Observed or NetBots property. FromIDProperty=%s',
                        self.Name, self.FromIDProperty)
                print_err(message)
                return false, message
            end
        elseif self.Type == 'NetBots' then
            state.IsUsingNetBots = true
        else
            message = string.format('[Properties %s] Property type not supported. Type=%s', self.Name, self.Type)
            print_err(message)
            return false, message
        end
    end
    return true, nil
end

return Property
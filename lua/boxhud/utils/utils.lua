--- @type Mq
local mq = require 'mq'
local state = require 'state'

function print_msg(msg) print('\at[\ayBOXHUD\at] \at' .. msg) end
function print_err(msg) print('\at[\ayBOXHUD\at] \ar' .. msg) end

local utils = {}

utils.FileExists = function(path)
    local f = io.open(path, "r")
    if f ~= nil then io.close(f) return true else return false end
end

utils.CopyFile = function(source, dest)
    local f = io.open(source, 'r')
    local contents = f:read('*a')
    io.close(f)
    f = io.open(dest, 'w')
    f:write(contents)
    io.close(f)
end

-- Split a string using the provided separator, | by default
utils.Split = function(input, sep)
    if sep == nil then
        sep = "|"
    end
    local t={}
    for str in string.gmatch(input, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

-- Create a table of {key:true, ..} from a list for checking a value is in the list 
utils.Set = function(list)
    local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set
end

utils.TitleCase = function(phrase)
    local result = string.gsub( phrase, "(%a)([%w_']*)",
        function(first, rest)
            return first:upper() .. rest:lower()
        end
    )
    return result
end

utils.TableConcat = function(t1, t2)
    local t = {}
    for k,v in ipairs(t1) do
        table.insert(t, v)
    end
    for k,v in ipairs(t2) do
        table.insert(t, v)
    end
    return t
end

utils.TableClone = function(org)
    return {unpack(org)}
end

utils.DoTablesMatch = function(a, b)
    return table.concat(a) == table.concat(b)
end

-- Load required plugins
utils.PluginCheck = function()
    if state.IsUsingDanNet then
        if not mq.TLO.Plugin('mq2dannet').IsLoaded() then
            print_msg("Plugin \ayMQ2DanNet\ax is required. Loading it now.")
            mq.cmd('/plugin mq2dannet noauto')
        end
        -- turn off fullname mode in DanNet
        if mq.TLO.DanNet.FullNames() then
            mq.cmd('/dnet fullnames off')
        end
    end
    if state.IsUsingNetBots then
        if not mq.TLO.Plugin('mq2eqbc').IsLoaded() then
            print_msg("Plugin \ayMQ2EQBC\ax is required. Loading it now.")
            mq.cmd('/plugin mq2eqbc noauto')
        end
        if not mq.TLO.Plugin('mq2netbots').IsLoaded() then
            print_msg("Plugin \ayMQ2NetBots\ax is required. Loading it now.")
            mq.cmd('/plugin mq2netbots noauto')
        end
    end
end

utils.GetZonePeerGroup = function()
    local zoneName = mq.TLO.Zone.ShortName()
    if zoneName:find('_') then
        return string.format('zone_%s', zoneName)
    else
        return string.format('zone_%s_%s', mq.TLO.EverQuest.Server(), zoneName)
    end
end

utils.GetGroupPeerGroup = function ()
    return ('group_%s_%s'):format(mq.TLO.EverQuest.Server(), (mq.TLO.Group.Leader() or ''):lower())
end

utils.GetTabByName = function(tabName)
    for _,tab in ipairs(state.Settings['Tabs']) do
        if tab['Name'] == tabName then
            return tab
        end
    end
    return nil
end

return utils
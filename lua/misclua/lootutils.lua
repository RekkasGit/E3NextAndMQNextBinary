--[[
lootutils.lua v0.3 - aquietone
This is a port of the RedGuides copy of ninjadvloot.inc with some updates as well.
I may have glossed over some of the events or edge cases so it may have some issues
around things like:
- lore items
- full inventory
- not full inventory but no slot large enough for an item
- ...
Or those things might just work, I just haven't tested it very much using lvl 1 toons
on project lazarus.

This script can be used in two ways:
    1. Included within a larger script using require, for example if you have some KissAssist-like lua script:
        To loot mobs, call lootutils.lootMobs():

            local mq = require 'mq'
            local lootutils = require 'lootutils'
            while true do
                lootutils.lootMobs()
                mq.delay(1000)
            end
        
        lootUtils.lootMobs() will run until it has attempted to loot all corpses within the defined radius.

        To sell to a vendor, call lootutils.sellStuff():

            local mq = require 'mq'
            local lootutils = require 'lootutils'
            local doSell = false
            local function binds(...)
                local args = {...}
                if args[1] == 'sell' then doSell = true end
            end
            mq.bind('/myscript', binds)
            while true do
                lootutils.lootMobs()
                if doSell then lootutils.sellStuff() doSell = false end
                mq.delay(1000)
            end

        lootutils.sellStuff() will run until it has attempted to sell all items marked as sell to the targeted vendor.

        Note that in the above example, loot.sellStuff() isn't being called directly from the bind callback.
        Selling may take some time and includes delays, so it is best to be called from your main loop.

        Optionally, configure settings using:
            Set the radius within which corpses should be looted (radius from you, not a camp location)
                lootutils.CorpseRadius = number
            Set whether loot.ini should be updated based off of sell item events to add manually sold items.
                lootutils.AddNewSales = boolean
            Set your own instance of Write.lua to configure a different prefix, log level, etc.
                lootutils.logger = Write
            Several other settings can be found in the "loot" table defined in the code.

    2. Run as a standalone script:
        /lua run lootutils standalone
            Will keep the script running, checking for corpses once per second.
        /lua run lootutils once
            Will run one iteration of loot.lootMobs().
        /lua run lootutils sell
            Will run one iteration of loot.sellStuff().

The script will setup a bind for "/lootutils":
    /lootutils <action> "${Cursor.Name}"
        Set the loot rule for an item. "action" may be one of:
            - Keep
            - Bank
            - Sell
            - Ignore
            - Destroy
            - Quest|#

    /lootutils reload
        Reload the contents of Loot.ini
    /lootutils bank
        Put all items from inventory marked as Bank into the bank
    /lootutils tsbank
        Mark all tradeskill items in inventory as Bank

If running in standalone mode, the bind also supports:
    /lootutils sell
        Runs lootutils.sellStuff() one time

The following events are used:
    - eventCantLoot - #*#may not loot this corpse#*#
        Add corpse to list of corpses to avoid for a few minutes if someone is already looting it.
    - eventSell - #*#You receive#*# for the #1#(s)#*#
        Set item rule to Sell when an item is manually sold to a vendor
    - eventInventoryFull - #*#Your inventory appears full!#*#
        Stop attempting to loot once inventory is full. Note that currently this never gets set back to false
        even if inventory space is made available.
    - eventNovalue - #*#give you absolutely nothing for the #1#.#*#
        Warn and move on when attempting to sell an item which the merchant will not buy.

This script depends on having Write.lua in your lua/lib folder.
    https://gitlab.com/Knightly1/knightlinc/-/blob/master/Write.lua 

This does not include the buy routines from ninjadvloot. It does include the sell routines
but lootly sell routines seem more robust than the code that was in ninjadvloot.inc.
The forage event handling also does not handle fishing events like ninjadvloot did.
There is also no flag for combat looting. It will only loot if no mobs are within the radius.

]]

---@type Mq
local mq = require 'mq'
local success, Write = pcall(require, 'lib.Write')
if not success then printf('\arERROR: Write.lua could not be loaded\n%s\ax', Write) return end

-- Public default settings, also read in from Loot.ini [Settings] section
local loot = {
    logger = Write,
    Version = "0.2",
    LootFile = mq.configDir .. '/Loot.ini',
    AddNewSales = true,
    LootForage = true,
    DoLoot = true,
    CorpseRadius = 100,
    MobsTooClose = 40,
    ReportLoot = true,
    LootChannel = "dgt",
    SpamLootInfo = false,
    LootForageSpam = false,
    GlobalLootOn = true,
    CombatLooting = true,
    GMLSelect = true,
    ExcludeBag1 = "Extraplanar Trade Satchel",
    QuestKeep = 10,
    StackPlatValue = 0,
    NoDropDefaults = "Quest|Keep|Ignore",
    LootLagDelay = 0,
    SaveBagSlots = 3,
    MinSellPrice = -1,
    StackableOnly = false,
    CorpseRotTime = "440s",
    Terminate = true,
}
loot.logger.prefix = 'lootutils'

-- Internal settings
local lootData = {}
local doSell = false
local cantLootList = {}
local cantLootID = 0

-- Constants
local spawnSearch = '%s radius %d zradius 50'
local shouldLootActions = {Keep=true, Bank=true, Sell=true, Destroy=true, Ignore=false}
local validActions = {keep='Keep',bank='Bank',sell='Sell',ignore='Ignore',destroy='Destroy'}
local saveOptionTypes = {string=1,number=1,boolean=1}

-- FORWARD DECLARATIONS

local eventForage, eventSell, eventCantLoot

-- UTILITIES

local function writeSettings()
    for option,value in pairs(loot) do
        local valueType = type(value)
        if saveOptionTypes[valueType] then
            mq.cmdf('/ini "%s" "%s" "%s" "%s"', loot.LootFile, 'Settings', option, value)
        end
    end
end

local function split(input, sep)
    if sep == nil then
        sep = "|"
    end
    local t={}
    for str in string.gmatch(input, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

local function loadSettings()
    local iniSettings = mq.TLO.Ini.File(loot.LootFile).Section('Settings')
    local keyCount = iniSettings.Key.Count()
    for i=1,keyCount do
        local key = iniSettings.Key.KeyAtIndex(i)()
        local value = iniSettings.Key(key).Value()
        if key == 'Version' then
            loot[key] = value
        elseif value == 'true' or value == 'false' then
            loot[key] = value == 'true' and true or false
        elseif tonumber(value) then
            loot[key] = tonumber(value)
        else
            loot[key] = value
        end
    end
end

local function checkCursor()
    local currentItem = nil
    while mq.TLO.Cursor() do
        -- can't do anything if there's nowhere to put the item, either due to no free inventory space
        -- or no slot of appropriate size
        if mq.TLO.Me.FreeInventory() == 0 or mq.TLO.Cursor() == currentItem then
            if loot.SpamLootInfo then loot.logger.Debug('Inventory full, item stuck on cursor') end
            mq.cmd('/autoinv')
            return
        end
        currentItem = mq.TLO.Cursor()
        mq.cmd('/autoinv')
        mq.delay(100)
    end
end

local function navToID(spawnID)
    mq.cmdf('/nav id %d log=off', spawnID)
    mq.delay(50)
    if mq.TLO.Navigation.Active() then
        local startTime = os.time()
        while mq.TLO.Navigation.Active() do
            mq.delay(100)
            if os.difftime(os.time(), startTime) > 5 then
                break
            end
        end
    end
end

local function addRule(itemName, section, rule)
    if not lootData[section] then
        lootData[section] = {}
    end
    lootData[section][itemName] = rule
    mq.cmdf('/ini "%s" "%s" "%s" "%s"', loot.LootFile, section, itemName, rule)
end

local function lookupIniLootRule(section, key)
    return mq.TLO.Ini.File(loot.LootFile).Section(section).Key(key).Value()
end

local function getRule(item)
    local itemName = item.Name()
    local lootDecision = 'Keep'
    local tradeskill = item.Tradeskills()
    local sellPrice = item.Value() and item.Value()/1000 or 0
    local stackable = item.Stackable()
    local firstLetter = itemName:sub(1,1):upper()
    local stackSize = item.StackSize()

    lootData[firstLetter] = lootData[firstLetter] or {}
    lootData[firstLetter][itemName] = lootData[firstLetter][itemName] or lookupIniLootRule(firstLetter, itemName)
    if lootData[firstLetter][itemName] == 'NULL' then
        if tradeskill then lootDecision = 'Bank' end
        if sellPrice < loot.MinSellPrice then lootDecision = 'Ignore' end
        if not stackable and loot.StackableOnly then lootDecision = 'Ignore' end
        if loot.StackPlatValue > 0 and sellPrice*stackSize < loot.StackPlatValue then lootDecision = 'Ignore' end
        addRule(itemName, firstLetter, lootDecision)
    end
    return lootData[firstLetter][itemName]
end

-- EVENTS

local function eventInventoryFull()
    shouldLootMobs = false
end

local itemNoValue = nil
local function eventNovalue(line, item)
    itemNoValue = item
end

local function setupEvents()
    mq.event("CantLoot", "#*#may not loot this corpse#*#", eventCantLoot)
    mq.event("InventoryFull", "#*#Your inventory appears full!#*#", eventInventoryFull)
    mq.event("Sell", "#*#You receive#*# for the #1#(s)#*#", eventSell)
    if loot.LootForage then
        mq.event("ForageExtras", "Your forage mastery has enabled you to find something else!", eventForage)
        mq.event("Forage", "You have scrounged up #*#", eventForage)
    end
    mq.event("Novalue", "#*#give you absolutely nothing for the #1#.#*#", eventNovalue)
    --[[mq.event("Lore", "#*#You cannot loot this Lore Item.#*#", eventHandler)]]--
end

-- BINDS

local function commandHandler(...)
    local args = {...}
    if #args == 1 then
        if args[1] == 'sell' and not loot.Terminate then
            doSell = true
        elseif args[1] == 'reload' then
            lootData = {}
            loot.logger.Info("Reloaded Loot File")
        elseif args[1] == 'bank' then
            loot.bankStuff()
        elseif args[1] == 'tsbank' then
            loot.markTradeSkillAsBank()
        end
    elseif #args == 2 then
        if validActions[args[1]] and args[2] ~= 'NULL' then
            addRule(args[2], args[2]:sub(1,1), validActions[args[1]])
            loot.logger.Info(string.format("Setting \ay%s\ax to \ay%s\ax", args[2], validActions[args[1]]))
        end
    elseif #args == 3 then
        if args[1] == 'quest' and args[2] ~= 'NULL' then
            addRule(args[2], args[2]:sub(1,1), 'Quest|'..args[3])
            loot.logger.Info(string.format("Setting \ay%s\ax to \ayQuest|%s\ax", args[2], args[3]))
        end
    end
end

local function setupBinds()
    mq.bind('/lootutils', commandHandler)
end

-- LOOTING

eventCantLoot = function()
    cantLootID = mq.TLO.Target.ID()
end

local function lootItem(index, doWhat, button)
    loot.logger.Debug('Enter lootItem')
    if not shouldLootActions[doWhat] then return end
    local corpseItemID = mq.TLO.Corpse.Item(index).ID()
    local itemName = mq.TLO.Corpse.Item(index).Name()
    mq.cmdf('/nomodkey /shift /itemnotify loot%s %s', index, button)
    mq.delay(5000, function() return mq.TLO.Window('ConfirmationDialogBox').Open() or not mq.TLO.Corpse.Item(index).NoDrop() end)
    if mq.TLO.Window('ConfirmationDialogBox').Open() then mq.cmd('/nomodkey /notify ConfirmationDialogBox Yes_Button leftmouseup') end
    mq.delay(5000, function() return mq.TLO.Cursor() ~= nil or not mq.TLO.Window('LootWnd').Open() end)
    mq.delay(100)
    if not mq.TLO.Window('LootWnd').Open() then return end
    if loot.ReportLoot then mq.cmdf('/%s \a-t[\ax\aylootutils\ax\a-t]\ax %sing \ay%s\ax', loot.LootChannel, doWhat, itemName) end
    if doWhat == 'Destroy' and mq.TLO.Cursor.ID() == corpseItemID then mq.cmd('/destroy') end
    if mq.TLO.Cursor() then checkCursor() end
end

local function lootCorpse(corpseID)
    loot.logger.Debug('Enter lootCorpse')
    if mq.TLO.Cursor() then checkCursor() end
    if mq.TLO.Me.FreeInventory() <= loot.SaveBagSlots and loot.ReportLoot then mq.cmdf('/%s \a-t[\ax\aylootutils\ax\a-t]\ax My bags are full, I can\'t loot anymore!', loot.LootChannel) end
    mq.cmd('/loot')
    mq.delay(3000, function() return mq.TLO.Window('LootWnd').Open() end)
    mq.doevents('CantLoot')
    mq.delay(3000, function() return cantLootID > 0 or mq.TLO.Window('LootWnd').Open() end)
    if not mq.TLO.Window('LootWnd').Open() then
        loot.logger.Warn(('Can\'t loot %s right now'):format(mq.TLO.Target.CleanName()))
        cantLootList[corpseID] = os.time()
        return
    end
    mq.delay(1000, function() return (mq.TLO.Corpse.Items() or 0) > 0 end)
    local items = mq.TLO.Corpse.Items() or 0
    loot.logger.Debug(('Loot window open. Items: %s'):format(items))
    local corpseName = mq.TLO.Corpse.Name()
    if mq.TLO.Window('LootWnd').Open() and items > 0 then
        local noDropItems = {}
        for i=1,items do
            local freeSpace = mq.TLO.Me.FreeInventory()
            local corpseItem = mq.TLO.Corpse.Item(i)
            local stackable = corpseItem.Stackable()
            local freeStack = corpseItem.FreeStack()
            if not corpseItem.NoDrop() then
                if corpseItem() and not corpseItem.Lore() and (freeSpace > loot.SaveBagSlots or (stackable and freeStack > 0)) then
                    lootItem(i, getRule(corpseItem), 'leftmouseup')
                end
            else
                table.insert(noDropItems, corpseItem.ItemLink('CLICKABLE')())
            end
            if not mq.TLO.Window('LootWnd').Open() then break end
        end
        for i=1,items do
            local freeSpace = mq.TLO.Me.FreeInventory()
            local corpseItem = mq.TLO.Corpse.Item(i)
            if corpseItem() then
                local haveItem = mq.TLO.FindItem(('=%s'):format(corpseItem.Name()))()
                local haveItemBank = mq.TLO.FindItemBank(('=%s'):format(corpseItem.Name()))()
                if not corpseItem.NoDrop() then
                    if corpseItem.Lore() and (haveItem or haveItemBank or freeSpace <= loot.SaveBagSlots) then
                        if loot.ReportLoot then
                            mq.cmdf('/%s \a-t[\ax\aylootutils\ax\a-t]\ax I already have lore item %s, I can\'t loot another!', loot.LootChannel, corpseItem.Name())
                        else
                            loot.logger.Warn('Cannot loot lore item')
                        end
                    elseif freeSpace <= loot.SaveBagSlots then
                        if loot.ReportLoot then
                            mq.cmdf('/%s \a-t[\ax\aylootutils\ax\a-t]\ax My bags are full, I can\'t loot anymore! \ay%s\ax', loot.LootChannel, corpseItem.Name())
                        else
                            if loot.SpamLootInfo then loot.logger.Warn('Inventory full, cannot loot anymore') end
                        end
                    else
                        lootItem(i, getRule(corpseItem), 'leftmouseup')
                    end
                else
                    table.insert(noDropItems, corpseItem.ItemLink('CLICKABLE')())
                end
            end
            if not mq.TLO.Window('LootWnd').Open() then break end
        end
        if #noDropItems > 0 then
            local noDropList = '/%s NoDrop Items (%s - %s)'
            for _,noDropItem in ipairs(noDropItems) do
                noDropList = noDropList .. noDropItem
            end
            mq.cmdf(noDropList, loot.LootChannel, corpseName, corpseID)
        end
    end
    mq.cmd('/nomodkey /notify LootWnd LW_DoneButton leftmouseup')
    mq.delay(3000, function() return not mq.TLO.Window('LootWnd').Open() end)
    -- if the corpse doesn't poof after looting, there may have been something we weren't able to loot or ignored
    -- mark the corpse as not lootable for a bit so we don't keep trying
    if mq.TLO.Spawn(('corpse id %s'):format(corpseID))() then
        cantLootList[corpseID] = os.time()
    end
end

local function corpseLocked(corpseID)
    if not cantLootList[corpseID] then return false end
    if os.difftime(os.time(), cantLootList[corpseID]) > 60 then
        cantLootList[corpseID] = nil
        return false
    end
    return true
end

loot.lootMobs = function(limit)
    loot.logger.Debug('Enter lootMobs')
    --if mq.TLO.Me.FreeInventory() > 0 then shouldLootMobs = true end
    --if not shouldLootMobs then return false end
    local deadCount = mq.TLO.SpawnCount(spawnSearch:format('npccorpse', loot.CorpseRadius))()
    loot.logger.Debug(string.format('There are %s corpses in range.', deadCount))
    local mobsNearby = mq.TLO.SpawnCount(spawnSearch:format('xtarhater', loot.MobsTooClose))()
    -- options for combat looting or looting disabled
    if deadCount == 0 or ((mobsNearby > 0 or mq.TLO.Me.Combat()) and not loot.CombatLooting) then return false end
    local corpseList = {}
    for i=1,math.max(deadCount, limit or 0) do
        local corpse = mq.TLO.NearestSpawn(('%d,'..spawnSearch):format(i, 'npccorpse', loot.CorpseRadius))
        table.insert(corpseList, corpse)
        -- why is there a deity check?
    end
    local didLoot = false
    loot.logger.Debug(string.format('Trying to loot %d corpses.', #corpseList))
    for i=1,#corpseList do
        local corpse = corpseList[i]
        local corpseID = corpse.ID()
        if corpseID and corpseID > 0 and not corpseLocked(corpseID) and (mq.TLO.Navigation.PathLength('spawn id '..tostring(corpseID))() or 100) < 60 then
            loot.logger.Debug('Moving to corpse ID='..tostring(corpseID))
            navToID(corpseID)
            corpse.DoTarget()
            mq.delay(100, function() return mq.TLO.Target.ID() == corpseID end)
            lootCorpse(corpseID)
            didLoot = true
            mq.doevents('InventoryFull')
        end
    end
    loot.logger.Debug('Done with corpse list.')
    return didLoot
end

-- SELLING

eventSell = function(line, itemName)
    local firstLetter = itemName:sub(1,1):upper()
    if lootData[firstLetter] and lootData[firstLetter][itemName] == 'Sell' then return end
    if lookupIniLootRule(firstLetter, itemName) == 'Sell' then
        lootData[firstLetter] = lootData[firstLetter] or {}
        lootData[firstLetter][itemName] = 'Sell'
        return
    end
    if loot.AddNewSales then
        loot.logger.Info(string.format('Setting %s to Sell', itemName))
        if not lootData[firstLetter] then lootData[firstLetter] = {} end
        lootData[firstLetter][itemName] = 'Sell'
        mq.cmdf('/ini "%s" "%s" "%s" "%s"', loot.LootFile, firstLetter, itemName, 'Sell')
    end
end

local function goToVendor()
    if not mq.TLO.Target() then
        loot.logger.Warn('Please target a vendor')
        return false
    end
    local vendorName = mq.TLO.Target.CleanName()

    loot.logger.Info('Doing business with '..vendorName)
    if mq.TLO.Target.Distance() > 15 then
        navToID(mq.TLO.Target.ID())
    end
    return true
end

local function openVendor()
    loot.logger.Debug('Opening merchant window')
    mq.cmd('/nomodkey /click right target')
    loot.logger.Debug('Waiting for merchant window to populate')
    mq.delay(1000, function() return mq.TLO.Window('MerchantWnd').Open() end)
    if not mq.TLO.Window('MerchantWnd').Open() then return false end
    mq.delay(5000, function() return mq.TLO.Merchant.ItemsReceived() end)
    return mq.TLO.Merchant.ItemsReceived()
end

local NEVER_SELL = {['Diamond Coin']=true, ['Celestial Crest']=true, ['Gold Coin']=true, ['Taelosian Symbols']=true, ['Planar Symbols']=true}
local function sellToVendor(itemToSell)
    if NEVER_SELL[itemToSell] then return end
    while mq.TLO.FindItemCount('='..itemToSell)() > 0 do
        if mq.TLO.Window('MerchantWnd').Open() then
            loot.logger.Info('Selling '..itemToSell)
            mq.cmdf('/nomodkey /itemnotify "%s" leftmouseup', itemToSell)
            mq.delay(1000, function() return mq.TLO.Window('MerchantWnd/MW_SelectedItemLabel').Text() == itemToSell end)
            mq.cmd('/nomodkey /shiftkey /notify merchantwnd MW_Sell_Button leftmouseup')
            mq.doevents('eventNovalue')
            if itemNoValue == itemToSell then
                addRule(itemToSell, itemToSell:sub(1,1), 'Ignore')
                itemNoValue = nil
                break
            end
            -- TODO: handle vendor not wanting item / item can't be sold
            mq.delay(1000, function() return mq.TLO.Window('MerchantWnd/MW_SelectedItemLabel').Text() == '' end)
        end
    end
end

loot.sellStuff = function()
    if not mq.TLO.Window('MerchantWnd').Open() then
        if not goToVendor() then return end
        if not openVendor() then return end
    end

    local totalPlat = mq.TLO.Me.Platinum()
    -- sell any top level inventory items that are marked as well, which aren't bags
    for i=1,10 do
        local bagSlot = mq.TLO.InvSlot('pack'..i).Item
        if bagSlot.Container() == 0 then
            if bagSlot.ID() then
                local itemToSell = bagSlot.Name()
                local sellRule = getRule(bagSlot)
                if sellRule == 'Sell' then sellToVendor(itemToSell) end
            end
        end
    end
    -- sell any items in bags which are marked as sell
    for i=1,10 do
        local bagSlot = mq.TLO.InvSlot('pack'..i).Item
        local containerSize = bagSlot.Container()
        if containerSize and containerSize > 0 then
            for j=1,containerSize do
                local itemToSell = bagSlot.Item(j).Name()
                if itemToSell then
                    local sellRule = getRule(bagSlot.Item(j))
                    if sellRule == 'Sell' then
                        local sellPrice = bagSlot.Item(j).Value() and bagSlot.Item(j).Value()/1000 or 0
                        if sellPrice == 0 then
                            loot.logger.Warn(string.format('Item \ay%s\ax is set to Sell but has no sell value!', itemToSell))
                        else
                            sellToVendor(itemToSell)
                        end
                    end
                end
            end
        end
    end
    mq.flushevents('Sell')
    if mq.TLO.Window('MerchantWnd').Open() then mq.cmd('/nomodkey /notify MerchantWnd MW_Done_Button leftmouseup') end
    local newTotalPlat = mq.TLO.Me.Platinum() - totalPlat
    loot.logger.Info(string.format('Total plat value sold: \ag%s\ax', newTotalPlat))
end

-- BANKING

loot.markTradeSkillAsBank = function()
    for i=1,10 do
        local bagSlot = mq.TLO.InvSlot('pack'..i).Item
        if bagSlot.Container() == 0 then
            if bagSlot.ID() then
                if bagSlot.Tradeskills() then
                    local itemToMark = bagSlot.Name()
                    addRule(itemToMark, itemToMark:sub(1,1), 'Bank')
                end
            end
        end
    end
    -- sell any items in bags which are marked as sell
    for i=1,10 do
        local bagSlot = mq.TLO.InvSlot('pack'..i).Item
        local containerSize = bagSlot.Container()
        if containerSize and containerSize > 0 then
            for j=1,containerSize do
                local item = bagSlot.Item(j)
                if item.ID() and item.Tradeskills() then
                    local itemToMark = bagSlot.Item(j).Name()
                    addRule(itemToMark, itemToMark:sub(1,1), 'Bank')
                end
            end
        end
    end
end

local function bankItem(itemName)
    mq.cmdf('/nomodkey /shiftkey /itemnotify "%s" leftmouseup', itemName)
    mq.delay(100, function() return mq.TLO.Cursor() end)
    mq.cmd('/notify BigBankWnd BIGB_AutoButton leftmouseup')
    mq.delay(100, function() return not mq.TLO.Cursor() end)
end

loot.bankStuff = function()
    if not mq.TLO.Window('BigBankWnd').Open() then
        loot.logger.Warn('Bank window must be open!')
        return
    end
    for i=1,10 do
        local bagSlot = mq.TLO.InvSlot('pack'..i).Item
        if bagSlot.Container() == 0 then
            if bagSlot.ID() then
                local itemToBank = bagSlot.Name()
                local bankRule = getRule(bagSlot)
                if bankRule == 'Bank' then bankItem(itemToBank) end
            end
        end
    end
    -- sell any items in bags which are marked as sell
    for i=1,10 do
        local bagSlot = mq.TLO.InvSlot('pack'..i).Item
        local containerSize = bagSlot.Container()
        if containerSize and containerSize > 0 then
            for j=1,containerSize do
                local itemToBank = bagSlot.Item(j).Name()
                if itemToBank then
                    local bankRule = getRule(bagSlot.Item(j))
                    if bankRule == 'Bank' then bankItem(itemToBank) end
                end
            end
        end
    end
end

-- FORAGING

eventForage = function()
    loot.logger.Debug('Enter eventForage')
    -- allow time for item to be on cursor incase message is faster or something?
    mq.delay(1000, function() return mq.TLO.Cursor() end)
    -- there may be more than one item on cursor so go until its cleared
    while mq.TLO.Cursor() do
        local cursorItem = mq.TLO.Cursor
        local foragedItem = cursorItem.Name()
        local forageRule = split(getRule(cursorItem))
        local ruleAction = forageRule[1] -- what to do with the item
        local ruleAmount = forageRule[2] -- how many of the item should be kept
        local currentItemAmount = mq.TLO.FindItemCount('='..foragedItem)()
        -- >= because .. does finditemcount not count the item on the cursor?
        if not shouldLootActions[ruleAction] or (ruleAction == 'Quest' and currentItemAmount >= ruleAmount) then
            if mq.TLO.Cursor.Name() == foragedItem then
                if loot.LootForageSpam then loot.logger.Info('Destroying foraged item '..foragedItem) end
                mq.cmd('/destroy')
                mq.delay(500)
            end
        -- will a lore item we already have even show up on cursor?
        -- free inventory check won't cover an item too big for any container so may need some extra check related to that?
        elseif (shouldLootActions[ruleAction] or currentItemAmount < ruleAmount) and (not cursorItem.Lore() or currentItemAmount == 0) and (mq.TLO.Me.FreeInventory() or (cursorItem.Stackable() and cursorItem.FreeStack())) then
            if loot.LootForageSpam then loot.logger.Info('Keeping foraged item '..foragedItem) end
            mq.cmd('/autoinv')
        else
            if loot.LootForageSpam then loot.logger.Warn('Unable to process item '..foragedItem) end
            break
        end
        mq.delay(50)
    end
end

--

local function processArgs(args)
    if #args == 1 then
        if args[1] == 'sell' then
            loot.sellStuff()
        elseif args[1] == 'once' then
            loot.lootMobs()
        elseif args[1] == 'standalone' then
            loot.Terminate = false
        end
    end
end

local function init(args)
    local iniFile = mq.TLO.Ini.File(loot.LootFile)
    if not (iniFile.Exists() and iniFile.Section('Settings').Exists()) then
        writeSettings()
    else
        loadSettings()
    end

    setupEvents()
    setupBinds()
    processArgs(args)
end

init({...})

while not loot.Terminate do
    if loot.DoLoot then loot.lootMobs() end
    if doSell then loot.sellStuff() doSell = false end
    mq.delay(1000)
end

return loot
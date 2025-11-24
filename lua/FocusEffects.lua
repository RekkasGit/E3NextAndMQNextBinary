local mq = require('mq')
local imgui = require('ImGui')

require 'ImGui'

local TEXT_BASE_WIDTH, _ = ImGui.CalcTextSize("A")
local TEXT_BASE_HEIGHT = ImGui.GetTextLineHeightWithSpacing();

local openGUI = true
local shouldDrawGUI = true
local isDebug = true

-- SPA_FOCUS_DAMAGE_MOD                    = 124,
-- 	SPA_FOCUS_HEAL_MOD                      = 125,
-- 	SPA_FOCUS_RESIST_MOD                    = 126,
-- 	SPA_FOCUS_CAST_TIME_MOD                 = 127,
-- 	SPA_FOCUS_DURATION_MOD                  = 128,
-- 	SPA_FOCUS_RANGE_MOD                     = 129,
-- 	SPA_FOCUS_HATE_MOD                      = 130,
-- 	SPA_FOCUS_REAGENT_MOD                   = 131,
-- 	SPA_FOCUS_MANACOST_MOD                  = 132,
-- 	SPA_FOCUS_STUNTIME_MOD                  = 133,
focusTypeLookup = {
    [1] = { ["name"] = "Cleave", ["items"] = {}},
    [2] = { ["name"] = "Ferocity", ["items"] = {}},
    [3] = { ["name"] = "Dodge", ["items"] = {}},
    [4] = { ["name"] = "Parry", ["items"] = {}},
    [124] = { ["name"] = "Spell Damage", ["items"] = {}},
    [125] = { ["name"] = "Healing", ["items"] = {}},
    [126] = { ["name"] = "Resist", ["items"] = {}},
    [127] = { ["name"] = "Cast Time", ["items"] = {}},
    [128] = { ["name"] = "Duration", ["items"] = {}},
    [129] = { ["name"] = "Range", ["items"] = {}},
    [130] = { ["name"] = "Hate", ["items"] = {}},
    [131] = { ["name"] = "Reagent", ["items"] = {}},
    [132] = { ["name"] = "Mana Cost", ["items"] = {}},
    [133] = { ["name"] = "Stun Time", ["items"] = {}},
    [167] = { ["name"] = "Pet Power", ["items"] = {}}
}

warnItemLookup = {"Cleave", "Ferocity", "Dodge", "Parry"}

resistLookup = { "Magic", "Fire", "Cold", "Poison", "Disease", "Chromatic", "Prismatic", "Physical", "Corruption"}

function ShowFocusEffects()

-- First, create a sorted list of indices based on the names of the focus types
local sortedIndices = {}
for index, focusType in pairs(focusTypeLookup) do
    table.insert(sortedIndices, index)
end
table.sort(sortedIndices, function(a, b)
    return focusTypeLookup[a].name < focusTypeLookup[b].name
end)

-- Sort items within each focus type based on their properties using sorted indices
for _, index in ipairs(sortedIndices) do
    local focusType = focusTypeLookup[index]
    table.sort(focusType.items, function(a, b)
        if (a.resist or "") == (b.resist or "") then
            if (a.max or 0) == (b.max or 0) then
                return a.itemName < b.itemName
            else
                return (a.max or 0) < (b.max or 0)
            end
        else
            return (a.resist or "") < (b.resist or "")
        end
    end)
end

-- Iterate over the sorted focus types and display their items
for _, index in ipairs(sortedIndices) do
    local focusType = focusTypeLookup[index]
    if (ImGui.CollapsingHeader(focusType.name)) then
        ImGui.PushID(focusType.name)

        for _, item in pairs(focusType.items) do
            ImGui.Text(item.itemName)
            
            if (item.rank ~= nil and item.rank ~= 0) then
                ImGui.Text("Rank: " .. item.rank)
            end

            if (item.description ~= nil) then
                ImGui.Text("Description: " .. item.description)
            end

            if (item.max ~= nil and item.level ~= nil) then
                ImGui.Text("Effect value: " .. item.max .. " Effective Level: " .. item.level)    
            end
            
            if (item.spellType ~= nil) then
                ImGui.Text("SpellType: " .. item.spellType)
            end
            
            if (item.resist ~= "" and item.resist ~= nil) then
                ImGui.Text("(" .. item.resist .. ")")
            end

            ImGui.Separator()
        end
        
        ImGui.PopID()
    end
end
end

function processFocusSpell(spell)
    local effectiveLevel = 0
    local focusType = 0
    local maxEffect = 0
    local resistType = ""
    local spellType = ""
    for effect = 1, spell.NumEffects() do
        if (spell.Attrib(effect)() == 134) then
            effectiveLevel = spell.Base(effect)()
        else
            if (spell.Attrib(effect)() >= 124 and spell.Attrib(effect)() <= 133) or (spell.Attrib(effect)() == 167) or (spell.Attrib(effect)() == 174) or (spell.Attrib(effect)() == 175) then
                focusType = spell.Attrib(effect)()
                maxEffect = spell.Base(effect)()
                debugPrint("Focus type " .. focusType)
                if (spell.Base2(effect)() ~= 0) then
                    maxEffect = spell.Base2(effect)()
                end
            else
                if (spell.Attrib(effect)() == 135) then
                    resistType = resistLookup[spell.Base(effect)()]
                    debugPrint("Effect " .. effect)
                    debugPrint("Resist Type " .. resistType)
                elseif spell.Attrib(effect)() == 138 then
                    if spell.Base(effect)() == 0 then 
                        spellType = "Detrimental"
                    elseif spell.Base(effect)() == 1 then
                        spellType = "Beneficial"
                    elseif spell.Base(effect)() ~= nil then 
                        spellType = "Unknown"
                    end
                else
                    debugPrint("processFocusSpell fall through" .. spell.Attrib(effect)())
                end
            end
        end
    end
    return effectiveLevel, focusType, maxEffect, resistType, spellType
end

function CalculateFocusItems()
    for slot = 0, 22 do
        local currentSlot = mq.TLO.InvSlot(slot).Item
        if (currentSlot.Worn.Spell.ID()) then
            debugPrint("-----Worn ----")
            debugPrint(currentSlot)
            local spell = currentSlot.Worn.Spell.Name
            for index, value in ipairs(warnItemLookup) do
                if (string.match(spell(), value)) then
                    debugPrint("Found " .. value)
                    table.insert(focusTypeLookup[index]["items"], { ["itemName"] = currentSlot(), ["rank"] = currentSlot.Worn.Spell.Rank(), ["description"] = spell()})
                end
            end
            debugPrint(spell)
        end

        if (currentSlot.Focus.Spell.Attrib(1)()) then
            debugPrint("---------")
            debugPrint(currentSlot)
            local spell = currentSlot.Focus.Spell
            debugPrint(spell)
            
            local effectiveLevel, focusType, maxEffect, resistType, spellType = processFocusSpell(spell)
            if (focusType ~= 0) then
                table.insert(focusTypeLookup[focusType]["items"], { ["itemName"] = currentSlot(), ["level"] = effectiveLevel, ["max"] = maxEffect, ["resist"] = resistType, ["spellType"] = spellType})
            end
        end
        if (currentSlot.Augs()) then
            debugPrint("-----Augs------")
            debugPrint(currentSlot)
        -- Max number of augs = 5
            for augIndex = 1, 5 do
                local aug = currentSlot.AugSlot(augIndex)
                if (currentSlot.AugSlot(augIndex)()) then
                    local aug = currentSlot.AugSlot(augIndex).Item
                    if (aug.Focus.Spell.Name()) then
                        local effectiveLevel, focusType, maxEffect, resistType, spellType = processFocusSpell(aug.Focus.Spell)
                        if (focusType ~= 0) then
                            table.insert(focusTypeLookup[focusType]["items"], { ["itemName"] = currentSlot() .. " (" .. aug() .. ")", ["level"] = effectiveLevel, ["max"] = maxEffect, ["resist"] = resistType, ["spellType"] = spellType})
                        end
                    end
                    if (aug.Worn.Spell.Name()) then 
                        local spell = aug.Worn.Spell.Name
                        for index, value in ipairs(warnItemLookup) do
                            if (string.match(spell(), value)) then
                                print("Begin")
                                print("value " .. value)
                                print("index " .. index)
                                print("aug " .. aug())
                                print("itemname " .. currentSlot() .. " (" .. aug() ..")")
                                print(aug.Worn.Spell.Name())
                                print(focusTypeLookup[index])
                                table.insert(focusTypeLookup[index]["items"], { ["itemName"] = currentSlot() .. " (" .. aug() ..")", ["rank"] = aug.Worn.Spell.Rank(), ["description"] = aug.Worn.Spell.Name()})
                            end
                        end            
                    end
                end
            end    
        end
        
    end

end

function debugPrint(text)
    if (isDebug) then
        print(text)
    end
end 

function FocusEffectsGUI()
    if not openGUI then return end
    openGUI, shouldDrawGUI = ImGui.Begin('Focus Effects', openGUI)
    if shouldDrawGUI then
        ShowFocusEffects()
    end
    ImGui.End()
end

ImGui.Register('FocusEffectsGUI', FocusEffectsGUI)

CalculateFocusItems()

while openGUI do
    mq.delay(1000) -- equivalent to '1s'
end
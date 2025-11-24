--Strumm Dischord (v1.01 /w Update Acoda
-- Uses single NPC: Wimbie Litto
-- Turns in selected items from main inventory for Nightveil Scrip

local mq = require('mq')

-- configure NPC and items here
local NPC = "Wimbie Litto"
local turnInItems = {
    "Charred Obulus Relic",
    "Glass Key to the Nowhere Door",
    "Blacksalt Compass",
    "Coldfire Lantern",
    "Fragment of the Maestra",
    "The Bone Violin",
    "Phantom's Bride Doll",
    "Eternal Jack-o-Lantern",
    "Shroud of the Forgotten King",
    "Withered Rose",
    "Map of Midnight",
    "The Ash Crown",
    "The Witch's Bell",
    "Fragment of Vzith",
    "Crown of Radiant Dominion",
    "Hat of the Forsaken Jester",
    "Obsidian Chalice",
    "The Crimson Dice",
    "Death Quill",
    "Mirror of the Last Gaze",
    "Scythe of Silence",
    "Remains of the Ancient Lich",
    "Sword of the Celestial Dawn",
    "Quill of Tomorrow",
    "Ancient Alpha Skull",
}

-- items we want to allow even if NoTrade
local noTradeExemptions = {
    ["Remains of the Ancient Lich"] = true,
}

local running = true
local open, show = true, true
local doTurnIns = false
local selectableItems = {}

local function findItems()
    -- Find all items in bags that match our list, allow exemptions
    selectableItems = {}
    for _,item in ipairs(turnInItems) do
        local itemRef = mq.TLO.FindItem('='..item)
        if itemRef() and (not itemRef.NoTrade() or noTradeExemptions[item]) 
           and itemRef.ItemSlot() > 22 and itemRef.ItemSlot() < 33 then
            table.insert(selectableItems, {
                Name=item,
                ItemSlot=itemRef.ItemSlot(),
                ItemSlot2=itemRef.ItemSlot2(),
                Count=itemRef.Stack() or 1,
                Selected=false
            })
        end
    end
end

local function selectAll()
    for _,item in ipairs(selectableItems) do
        item.Selected = true
    end
end

local function totalItemCount()
    local total = 0
    for _,item in ipairs(selectableItems) do
        total = total + (item.Count or 1)
    end
    return total
end

local function draw()
    if not open then running = false return end
    ImGui.SetNextWindowSize(300, 400)
    open, show = ImGui.Begin('Nightveil Scrip Handin', open)
    if show then
        local gainedNightveil = mq.TLO.FindItemCount('Nightveil Scrip')()
        ImGui.Text('Nightveil Scrip: ') ImGui.SameLine()
        ImGui.TextColored(1,1,0,1,'%s', gainedNightveil)

        ImGui.Text('Turn-in Loots: ') ImGui.SameLine()
        ImGui.TextColored(1,1,0,1,'%s', #selectableItems)

        local total = totalItemCount()
        ImGui.Text('Total Items Available: ') 
        ImGui.SameLine()
        ImGui.TextColored(0,1,0,1,'%s', total)

        ImGui.BeginDisabled(doTurnIns)
        if ImGui.Button('Select All') then
            selectAll()
        end
        ImGui.SameLine()
        if ImGui.Button('Turn In Selected Items') then
            doTurnIns = true
        end
        for _,item in ipairs(selectableItems) do
            local label = string.format("%s (x%d)", item.Name, item.Count)
            item.Selected = ImGui.Checkbox(label, item.Selected)
        end
        ImGui.EndDisabled()
    end
    ImGui.End()
end

mq.imgui.init('nightveilhandinui', draw)

local function handin(item)
    while true do
        local itemRef = mq.TLO.FindItem('='..item.Name)
        if not itemRef() then break end  -- stop when no more found

        mq.cmdf('/ctrl /itemnotify "%s" leftmouseup', item.Name)

        local startTime = mq.gettime()
        while not mq.TLO.Cursor() do
            if mq.gettime() - startTime > 5000 then break end
            mq.delay(10)
        end
        mq.delay(100)
        if not mq.TLO.Cursor() then break end

        mq.cmd('/click left target')

        startTime = mq.gettime()
        while mq.TLO.Cursor() do
            if mq.gettime() - startTime > 3000 then break end
            mq.delay(10)
        end
        mq.delay(100)
        if mq.TLO.Cursor() then break end

        mq.cmd('/notify GiveWnd GVW_Give_Button leftmouseup')
        startTime = mq.gettime()
        while not mq.TLO.Cursor() do
            if mq.gettime() - startTime > 2000 then break end
            mq.delay(10)
        end

        while mq.TLO.Cursor() do
            mq.cmd('/autoinv')
            mq.delay(10)
        end
        mq.delay(300, function() return not mq.TLO.Cursor() end)
    end
end

findItems()
while running do
    if doTurnIns then
        mq.cmdf('/mqt npc %s', NPC)
        for _,item in ipairs(selectableItems) do
            if item.Selected then
                handin(item)
            end
        end
        findItems()
        doTurnIns = false
    end
    mq.delay(300)
end

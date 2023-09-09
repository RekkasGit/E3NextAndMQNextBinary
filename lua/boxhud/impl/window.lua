--- @type Mq
local mq = require 'mq'
local Window = require 'classes.config.window'
local WindowInput = require 'classes.inputs.windowinput'
local helpers = require 'utils.uihelpers'
local utils = require 'utils.utils'
local state = require 'state'
local settings = require 'settings.settings'

local adminPeerSelected = 0
math.randomseed(os.time())
local tableRandom = math.random(1,100)

local current_sort_specs = {}
local current_columns = {}
local function CompareWithSortSpecs(a, b)
    for n = 1, current_sort_specs.SpecsCount, 1 do
        -- Here we identify columns using the ColumnUserID value that we ourselves passed to TableSetupColumn()
        -- We could also choose to identify columns based on their index (sort_spec.ColumnIndex), which is simpler!
        local sort_spec = current_sort_specs:Specs(n)
        local delta = 0

        local columnName = current_columns[sort_spec.ColumnUserID]
        local column = state.Settings.Columns[columnName]
        if not column then
            return a < b
        end
        local aVal = nil
        local bVal = nil
        if column.Name == 'Name' or not column.Properties or not column.Properties.all then
            aVal = tostring(a)
            bVal = tostring(b)
        elseif (state.Characters[a] and state.Characters[a].Properties) and (state.Characters[b] and state.Characters[b].Properties) then
            aVal = tostring((state.Characters[a] and state.Characters[a].Properties[column.Properties.all]) or -1)
            bVal = tostring((state.Characters[b] and state.Characters[b].Properties[column.Properties.all]) or -1)
        else
            aVal = tostring(a)
            bVal = tostring(b)
        end
        if tonumber(aVal) ~= nil and tonumber(bVal) ~= nil then
            if tonumber(aVal) < tonumber(bVal) then
                delta = -1
            elseif tonumber(bVal) < tonumber(aVal) then
                delta = 1
            else
                delta = 0
            end
        else
            if aVal < bVal then
                delta = -1
            elseif bVal < aVal then
                delta = 1
            else
                delta = 0
            end
        end
        if delta ~= 0 then
            if sort_spec.SortDirection == ImGuiSortDirection.Ascending then
                return delta < 0
            end
            return delta > 0
        end
    end

    -- Always return a way to differentiate items.
    -- Your own compare function may want to avoid fallback on implicit sort specs e.g. a Name compare if it wasn't already part of the sort specs.
    return a < b
end

function Window:drawTableTab(columns, tabName)
    local flags = bit32.bor(ImGuiTableFlags.Resizable, ImGuiTableFlags.Reorderable, ImGuiTableFlags.Hideable, ImGuiTableFlags.Sortable, ImGuiTableFlags.MultiSortable,
            ImGuiTableFlags.RowBg, ImGuiTableFlags.BordersOuter, ImGuiTableFlags.BordersV, ImGuiTableFlags.ScrollY, ImGuiTableFlags.NoSavedSettings)
    if ImGui.BeginTable('##bhtable'..tabName..tostring(tableRandom), #columns, flags, 0, 0, 0.0) then
        for i, columnName in ipairs(columns) do
            local column = state.Settings['Columns'][columnName]
            if columnName == 'Name' then
                local name = ('Name (%s)###Name'):format(#state.WindowStates[self.Name].Peers)
                ImGui.TableSetupColumn(name,       bit32.bor(ImGuiTableColumnFlags.DefaultSort, ImGuiTableColumnFlags.WidthFixed),   -1.0, i)
            elseif column['Type'] ~= 'button' then
                ImGui.TableSetupColumn(columnName, ImGuiTableColumnFlags.WidthFixed,                                                 -1.0, i)
            else
                ImGui.TableSetupColumn(columnName, bit32.bor(ImGuiTableColumnFlags.NoSort, ImGuiTableColumnFlags.WidthFixed),        -1.0, i)
            end
        end
        ImGui.TableSetupScrollFreeze(0, 1) -- Make row always visible
        local sort_specs = ImGui.TableGetSortSpecs()
        if sort_specs then
            if sort_specs.SpecsDirty or state.WindowStates[self.Name].PeersDirty or self.SortDirty then
                if #state.WindowStates[self.Name].Peers > 0 then
                    current_sort_specs = sort_specs
                    current_columns = columns
                    state.WindowStates[self.Name].SortedPeers = utils.TableClone(state.WindowStates[self.Name].Peers)
                    table.sort(state.WindowStates[self.Name].SortedPeers, CompareWithSortSpecs)
                    current_sort_specs = nil
                    current_columns = nil
                end
                sort_specs.SpecsDirty = false
                self.SortDirty = true
                state.WindowStates[self.Name].PeersDirty = false
            end
        end

        -- Display data
        ImGui.TableHeadersRow()
        local clipper = ImGuiListClipper.new()
        if state.WindowStates[self.Name].SortedPeers == nil then
            state.WindowStates[self.Name].SortedPeers = utils.TableClone(state.WindowStates[self.Name].Peers)
        end
        clipper:Begin(#state.WindowStates[self.Name].SortedPeers)
        while clipper:Step() do
            for row_n = clipper.DisplayStart, clipper.DisplayEnd - 1, 1 do
                local clipName = state.WindowStates[self.Name].SortedPeers[row_n+1]
                local char = state.Characters[clipName]
                if char and char.Properties then
                    ImGui.PushID(clipName)
                    ImGui.TableNextRow()
                    ImGui.TableNextColumn()
                    for i,columnName in ipairs(columns) do
                        local column = state.Settings['Columns'][columnName]
                        if columnName == 'Name' then
                            char:drawNameButton()
                        else
                            -- Default column type is property (observed or spawn properties)
                            if not column['Type'] or column['Type'] == 'property' then
                                char:drawColumnProperty(column)
                            elseif column['Type'] == 'button' then
                                char:drawColumnButton(columnName, column['Action'])
                            end
                        end
                        if i < #columns then
                            ImGui.TableNextColumn()
                        end
                    end
                    ImGui.PopID()
                end
            end
        end
        clipper:End()
        ImGui.EndTable()
    end
end

function Window:getPeerNameForIndex(index)
    return state.WindowStates[self.Name].Peers[adminPeerSelected]
end

function Window:drawTabs()
    if ImGui.BeginTabBar('BOXHUDTABS##'..self.Name, ImGuiTabBarFlags.Reorderable) then
        for _,tabName in ipairs(self.Tabs) do
            local tab = utils.GetTabByName(tabName)
            if ImGui.BeginTabItem(tab['Name']) then
                if self.currentTab ~= tab.Name then
                    self.SortDirty = true
                    self.CurrentTab = tab.Name
                end
                if tab['Columns'] and #tab['Columns'] > 0 then
                    self:drawTableTab(tab['Columns'], tab['Name'])
                    ImGui.EndTabItem()
                else
                    ImGui.Text('No columns defined for tab')
                    ImGui.EndTabItem()
                end
            end
        end

        -- Admin tab only allows resetting observers, so only show if dannet is being used
        if state.IsUsingDanNet then
            if ImGui.BeginTabItem('Admin') then
                ImGui.Text('DanNet Peer Group: ')
                ImGui.SameLine()
                ImGui.TextColored(0, 1, 0, 1, state.WindowStates[self.Name].PeerGroup)
                ImGui.Text('Administer Observers for:')
                adminPeerSelected, _ = ImGui.Combo("##combo", adminPeerSelected, state.WindowStates[self.Name].Peers, #state.WindowStates[self.Name].Peers, 5)
                ImGui.SameLine()
                if ImGui.Button('Reset All Observers') then
                    state.AdminPeerAction = 'reset'
                    state.AdminPeerName = self:getPeerNameForIndex(adminPeerSelected)
                    print_msg('Resetting observed properties for: \ay'..state.AdminPeerName)
                end
                ImGui.Text('Enter an observed property to check or drop:')
                state.AdminPeerItem = ImGui.InputText('##checkobs', state.AdminPeerItem)
                ImGui.SameLine()
                if ImGui.Button('Check') then
                    state.AdminPeerAction = 'check'
                    state.AdminPeerName = self:getPeerNameForIndex(adminPeerSelected)
                    print_msg('Check observed property \ay'..state.AdminPeerItem..'\ax for: \ay'..state.AdminPeerName)
                end
                ImGui.SameLine()
                if ImGui.Button('Drop') then
                    state.AdminPeerAction = 'drop'
                    state.AdminPeerName = self:getPeerNameForIndex(adminPeerSelected)
                    print_msg('Drop observed property \ay'..state.AdminPeerItem..'\ax for: \ay'..state.AdminPeerName)
                end
                ImGui.Separator()
                ImGui.TextColored(1, 0, 0, 1, 'BEWARE!')
                if ImGui.Button('Restart Boxhud and Reload DanNet') then
                    mq.cmdf('/multiline | /dga %s /multiline ; /plugin dannet unload noauto; /timed 10 /plugin dannet load noauto ; | /lua stop boxhud | /timed 20 /lua run boxhud |', state.WindowStates[self.Name].PeerGroup)
                end
                ImGui.EndTabItem()
            end
        end

        if ImGui.BeginTabItem('Configuration##'..self.Name) then
            state.WindowStates[self.Name].ConfigPanel:draw()
            ImGui.EndTabItem()
        end
        ImGui.EndTabBar()
    end
end

local function TableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function WindowInput:toWindow()
    local window  = Window({})
    window.Name = self.Name
    window.PeerGroup = self.PeerGroup
    window.Tabs = {}
    for idx,tab in ipairs(self.Tabs) do
        window.Tabs[idx] = tab
    end
    return window
end

function WindowInput:fromWindow(window)
    local o = WindowInput()
    o.Name = window.Name
    o.PeerGroup = window.PeerGroup
    for idx,tab in ipairs(window.Tabs) do
        o.Tabs[idx] = tab
    end
    o.TabCount = #window['Tabs']
    return o
end

function WindowInput:draw(width, configPanel)
    ImGui.TextColored(1, 0, 1, 1, "Add New Window")
    ImGui.Separator()
    self.Name = helpers.DrawLabelAndTextInput('Name(*): ', '##newwindowname', self.Name, 'The name of the window to be added.')
    if state.Settings['PeerSource'] == 'dannet' then
        local peerGroupSelection = self.PeerGroup
        if self.PeerGroup ~= 'all' and self.PeerGroup ~= 'zone' and self.PeerGroup ~= 'group' then
            peerGroupSelection = 'other'
        end
        local currentSelection = peerGroupSelection
        peerGroupSelection = helpers.DrawComboBox('Peer Group', peerGroupSelection, { 'all', 'group', 'zone', 'other' }, false)
        if peerGroupSelection == 'other' then
            if currentSelection ~= peerGroupSelection then self.PeerGroup = '' end
            self.PeerGroup = helpers.DrawLabelAndTextInput('Enter a peer group name:', '##peergroup', self.PeerGroup, 'The DanNet Peer Group to source peers from. For a list of groups, use "/dnet info".')
        else
            self.PeerGroup = peerGroupSelection
        end
    end

    ImGui.Text('Tabs: ')
    ImGui.SameLine()
    helpers.HelpMarker('The list of tabs which will be displayed in the window.')
    for tabIdx, _ in ipairs(self.Tabs) do
        if self.Tabs[tabIdx] ~= nil then
            local tabNameList = {}
            for _,tab in ipairs(state.Settings['Tabs']) do
                table.insert(tabNameList, tab['Name'])
            end
            self.Tabs[tabIdx] = helpers.DrawComboBox("##tabcombo"..tabIdx, self.Tabs[tabIdx], tabNameList, false)
            ImGui.SameLine()
            if ImGui.Button('X##deleteRow'..tabIdx) then
                local tabIter = tabIdx
                for tabs = tabIdx+1, #self.Tabs do
                    self.Tabs[tabIter] = self.Tabs[tabs]
                    tabIter = tabIter+1
                end
                self.Tabs[tabIter] = nil
                self.TabCount = self.TabCount - 1
            end
        end
    end
    if ImGui.Button('+') then
        self.TabCount = self.TabCount + 1
        self.Tabs[self.TabCount] = ''
    end

    ImGui.Separator()
    if ImGui.Button('Save##newwindow'..configPanel.Name) then
        local ok = false
        local window = self:toWindow()
        ok, self.Message = window:validate()
        if ok then
            if state.Settings.Windows[self.Name] then
                state.Settings.Windows[self.Name].Tabs = window.Tabs
                state.Settings.Windows[self.Name].PeerGroup = window.PeerGroup
            else
                state.Settings.Windows[self.Name] = window
            end
            settings.SaveSettings()
            configPanel:clearSelection()
        else
            self.Valid = false
        end
    end
    if not self.Valid then
        ImGui.SameLine()
        ImGui.PushTextWrapPos(width-10)
        ImGui.TextColored(1, 0, 0, 1, string.format('Invalid input! %s', self.Message))
        ImGui.PopTextWrapPos()
    end
end

function Window:draw(configPanel)
    ImGui.TextColored(1, 0, 1, 1, self.Name)
    ImGui.Separator()
    if ImGui.SmallButton('Edit##'..self.Name) then
        configPanel.NewWindow = WindowInput:fromWindow(self)
        configPanel:selectItem(nil, 'addnewwindow')
    end
    if TableLength(state.Settings['Windows']) > 1 then
        ImGui.SameLine()
        if ImGui.SmallButton('Delete##'..self.Name) then
            state.Settings['Windows'][self.Name] = nil
            settings.SaveSettings()
            configPanel:clearSelection()
        end
    end
    helpers.DrawLabelAndTextValue('Peer Group: ', self.PeerGroup)
    ImGui.Text('Tabs:')
    if self.Tabs then
        for tabIdx,tab in ipairs(self.Tabs) do
            ImGui.Text(string.format('%d: ', tabIdx))
            ImGui.SameLine()
            ImGui.TextColored(0, 1, 0, 1, tab)
        end
    end
end

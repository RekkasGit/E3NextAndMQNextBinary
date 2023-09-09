local Tab = require 'classes.config.tab'
local TabInput = require 'classes.inputs.tabinput'
local helpers = require 'utils.uihelpers'
local state = require 'state'
local settings = require 'settings.settings'

function TabInput:toTab()
    local tab = Tab({})
    tab.Name = self.Name
    tab.Columns = {}
    for idx,column in ipairs(self.Columns) do
        tab.Columns[idx] = column
    end
    return tab
end

function TabInput:fromTab(tab)
    local o = TabInput()
    o.Name = tab['Name']
    o.Columns = {}
    for idx,column in ipairs(tab.Columns) do
        o.Columns[idx] = column
    end
    o.ColumnCount = #tab['Columns']
    return o
end

function TabInput:draw(width, configPanel)
    ImGui.TextColored(1, 0, 1, 1, "Add New Tab")
    ImGui.Separator()
    self.Name = helpers.DrawLabelAndTextInput('Name(*): ', '##newtabname', self.Name, 'The name of the tab which will be displayed in the Tab bar.')
    ImGui.Text('Columns: ')
    ImGui.SameLine()
    helpers.HelpMarker('The list of columns which will be displayed in the tab.')
    for columnIdx, columnName in ipairs(self.Columns) do 
        if self.Columns[columnIdx] ~= nil then
            ImGui.BeginGroup()
            self.Columns[columnIdx] = helpers.DrawComboBox("##columncombo"..columnIdx, self.Columns[columnIdx], state.Settings['Columns'], true)
            ImGui.SameLine()
            if ImGui.Button('X##deleteRow'..columnIdx) then
                local columnIter = columnIdx
                for columns = columnIdx+1, #self.Columns do
                    self.Columns[columnIter] = self.Columns[columns]
                    columnIter = columnIter+1
                end
                self.Columns[columnIter] = nil
                self.ColumnCount = self.ColumnCount - 1
            end
            ImGui.EndGroup()
            if ImGui.BeginDragDropSource() then
                ImGui.SetDragDropPayload("ColumnIdx", columnIdx)
                ImGui.Text(self.Columns[columnIdx])
                ImGui.EndDragDropSource()
            end
            if ImGui.BeginDragDropTarget() then
                local payload = ImGui.AcceptDragDropPayload("ColumnIdx")
                if payload ~= nil then
                    local num = payload.Data;
                    -- swap the list entries
                    self.Columns[num], self.Columns[columnIdx] = self.Columns[columnIdx], self.Columns[num]
                end
                ImGui.EndDragDropTarget()
            end
        end
    end
    if ImGui.Button('+') then
        self.ColumnCount = self.ColumnCount + 1
        self.Columns[self.ColumnCount] = ''
    end
    ImGui.Separator()
    if ImGui.Button('Save##newtab'..configPanel.Name) then
        local ok = false
        local tab = self:toTab()
        ok, self.Message = tab:validate()
        if ok then
            local foundExisting = false
            for tabIdx,existingTab in ipairs(state.Settings['Tabs']) do
                if existingTab['Name'] == self.Name then
                    -- replace existing tab
                    existingTab['Columns'] = self.Columns
                    foundExisting = true
                end
            end
            if not foundExisting then
                table.insert(state.Settings['Tabs'], tab)
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

function Tab:references(draw)
    local refFound = false
    for _,window in pairs(state.Settings['Windows']) do
        if window['Tabs'] then
            for _,tabNameIter in pairs(window['Tabs']) do
                if self.Name == tabNameIter then
                    refFound = true
                    if draw then
                        helpers.DrawReferenceText('Window: ', window['Name'], nil, nil)
                    end
                end
            end
        end
    end
    return refFound
end

function Tab:draw(configPanel)
    ImGui.TextColored(1, 0, 1, 1, self.Name)
    ImGui.Separator()
    if ImGui.SmallButton('Edit##'..self.Name) then
        configPanel.NewTab = TabInput:fromTab(self)
        configPanel:selectItem(nil, 'addnewtab')
    end
    ImGui.SameLine()
    if ImGui.SmallButton('Delete##'..self.Name) then
        if not self:references(false) then
            local tabIter = configPanel.SelectedItem
            for tabIdx = tabIter+1, #state.Settings['Tabs'] do
                state.Settings['Tabs'][tabIter] = state.Settings['Tabs'][tabIdx]
                tabIter = tabIter+1
            end
            state.Settings['Tabs'][tabIter] = nil
            settings.SaveSettings()
            configPanel:clearSelection()
        end
    end
    ImGui.Text('Columns:')
    if self.Columns then
        for columnIdx,column in ipairs(self.Columns) do
            ImGui.Text(string.format('%d: ', columnIdx))
            ImGui.SameLine()
            ImGui.TextColored(0, 1, 0, 1, column)
        end
    end
    ImGui.Separator()
    ImGui.Text('References:')
    ImGui.Indent(10)
    self:references(true)
    ImGui.Indent(-10)
end

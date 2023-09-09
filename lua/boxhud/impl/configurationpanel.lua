--- @type Mq
local mq = require 'mq'
local helpers = require 'utils.uihelpers'
local PropertyInput = require 'classes.inputs.propertyinput'
local ColumnInput = require 'classes.inputs.columninput'
local TabInput = require  'classes.inputs.tabinput'
local WindowInput = require 'classes.inputs.windowinput'
local ConfigurationPanel = require 'classes.config.configurationpanel'
local state = require 'state'
local settings = require 'settings.settings'
local library = require 'library'
local filedialog = require 'utils.imguifiledialog'

function ConfigurationPanel:drawDisplaySettingsSelector()
    ImGui.PushStyleColor(ImGuiCol.Text, 1, 1, 1, 1)
    self.Selected = ImGui.Selectable('Display Settings', self.SelectedItemType == 'displaysettings')
    ImGui.PopStyleColor(1)
    if self.Selected then
        self:selectItem(nil, 'displaysettings')
    end
end

function ConfigurationPanel:drawPropertiesTreeSelector()
    ImGui.PushStyleColor(ImGuiCol.Text, 1, 1, 1, 1)
    if ImGui.TreeNodeEx('Properties##'..self.Name, ImGuiTreeNodeFlags.SpanFullWidth) then
        ImGui.PopStyleColor(1)
        ImGui.TableNextRow()
        ImGui.TableNextColumn()
        self.Selected = ImGui.Selectable('Add new property...', self.SelectedItemType == 'addnewproperty')
        if self.Selected then
            if self.SelectedItemType ~= 'addnewproperty' then
                self.NewProperty = PropertyInput()
            end
            self:selectItem(nil, 'addnewproperty')
        end
        self.Selected = ImGui.Selectable('Add from library...##property', self.SelectedItemType == 'addpfromlibrary')
        if self.Selected then
            if self.SelectedItemType ~= 'addpfromlibrary' then
                self:selectItem(nil, 'addpfromlibrary')
            else
                self:selectItem(self.SelectedItem, 'addpfromlibrary')
            end
            
        end
        for propName, _ in pairs(state.Settings['Properties']) do
            ImGui.TableNextRow()
            ImGui.TableNextColumn()
            ImGui.PushStyleColor(ImGuiCol.Text, 1, 1, 0, 1)
            self.Selected = ImGui.Selectable(propName, self.SelectedItem == propName and self.SelectedItemType == 'property')
            if self.Selected then
                self:selectItem(propName, 'property')
            end
            ImGui.PopStyleColor(1)
        end
        ImGui.TreePop()
    else
        ImGui.PopStyleColor(1)
        if self.SelectedItemType == 'property' or self.SelectedItemType == 'addnewproperty' then
            self:selectItem(nil, nil)
        end
    end
end

function ConfigurationPanel:drawColumnTreeSelector()
    ImGui.PushStyleColor(ImGuiCol.Text, 1, 1, 1, 1)
    if ImGui.TreeNodeEx('Columns##'..self.Name, ImGuiTreeNodeFlags.SpanFullWidth) then
        ImGui.PopStyleColor(1)
        ImGui.TableNextRow()
        ImGui.TableNextColumn()
        self.Selected = ImGui.Selectable('Add new column...', self.SelectedItemType == 'addnewcolumn')
        if self.Selected then
            if self.SelectedItemType ~= 'addnewcolumn' then
                self.NewColumn = ColumnInput()
            end
            self:selectItem(nil, 'addnewcolumn')
        end
        self.Selected = ImGui.Selectable('Add from library...##column', self.SelectedItemType == 'addcfromlibrary')
        if self.Selected then
            if self.SelectedItemType ~= 'addcfromlibrary' then
                self:selectItem(nil, 'addcfromlibrary')
            else
                self:selectItem(self.SelectedItem, 'addcfromlibrary')
            end
        end
        for columnName, _ in pairs(state.Settings['Columns']) do
            ImGui.TableNextRow()
            ImGui.TableNextColumn()
            ImGui.PushStyleColor(ImGuiCol.Text, 1, 1, 0, 1)
            self.Selected = ImGui.Selectable(columnName, self.SelectedItem == columnName and self.SelectedItemType == 'column')
            if self.Selected then
                self:selectItem(columnName, 'column')
            end
            ImGui.PopStyleColor(1)
        end
        ImGui.TreePop()
    else
        ImGui.PopStyleColor(1)
        if self.SelectedItemType == 'column' or self.SelectedItemType == 'addnewcolumn' then
            self:selectItem(nil, nil)
        end
    end
end

function ConfigurationPanel:drawTabTreeSelector()
    ImGui.PushStyleColor(ImGuiCol.Text, 1, 1, 1, 1)
    if ImGui.TreeNodeEx('Tabs##'..self.Name, ImGuiTreeNodeFlags.SpanFullWidth) then
        ImGui.PopStyleColor(1)
        ImGui.TableNextRow()
        ImGui.TableNextColumn()
        self.Selected = ImGui.Selectable('Add new tab...', self.SelectedItemType == 'addnewtab')
        if self.Selected then
            if self.SelectedItemType ~= 'addnewtab' then
                self.NewTab = TabInput()
            end
            self:selectItem(nil, 'addnewtab')
        end
        for tabIdx, tab in pairs(state.Settings['Tabs']) do
            ImGui.TableNextRow()
            ImGui.TableNextColumn()
            ImGui.PushStyleColor(ImGuiCol.Text, 1, 1, 0, 1)
            self.Selected = ImGui.Selectable(tab['Name'], self.SelectedItem == tabIdx and self.SelectedItemType == 'tab')
            if self.Selected then
                self:selectItem(tabIdx, 'tab')
            end
            ImGui.PopStyleColor(1)
        end
        ImGui.TreePop()
    else
        ImGui.PopStyleColor(1)
        if self.SelectedItemType == 'tab' or self.SelectedItemType == 'addnewtab' then
            self:selectItem(nil, nil)
        end
    end
end

function ConfigurationPanel:drawWindowTreeSelector()
    ImGui.PushStyleColor(ImGuiCol.Text, 1, 1, 1, 1)
    if ImGui.TreeNodeEx('Windows##'..self.Name, ImGuiTreeNodeFlags.SpanAvailWidth) then
        ImGui.PopStyleColor(1)
        ImGui.TableNextRow()
        ImGui.TableNextColumn()
        self.Selected = ImGui.Selectable('Add new window...', self.SelectedItemType == 'addnewwindow')
        if self.Selected then
            if self.SelectedItemType ~= 'addnewwindow' then
                self.NewWindow = WindowInput()
            end
            self:selectItem(nil, 'addnewwindow')
        end
        for windowName, _ in pairs(state.Settings['Windows']) do
            ImGui.TableNextRow()
            ImGui.TableNextColumn()
            ImGui.PushStyleColor(ImGuiCol.Text, 1, 1, 0, 1)
            self.Selected = ImGui.Selectable(windowName, self.SelectedItem == windowName and self.SelectedItemType == 'window')
            if self.Selected then
                self:selectItem(windowName, 'window')
            end
            ImGui.PopStyleColor(1)
        end
        ImGui.TreePop()
    else
        ImGui.PopStyleColor(1)
        if self.SelectedItemType == 'window' or self.SelectedItemType == 'addnewwindow' then
            self:selectItem(nil, nil)
        end
    end
end

function ConfigurationPanel:drawImportSelector()
    ImGui.PushStyleColor(ImGuiCol.Text, 1, 1, 1, 1)
    self.Selected = ImGui.Selectable('Import Configuration', self.selectedItemType == 'import')
    ImGui.PopStyleColor(1)
    if self.Selected then
        self:selectItem(nil, 'import')
    end
end

function ConfigurationPanel:drawAboutSelector()
    ImGui.PushStyleColor(ImGuiCol.Text, 1, 1, 1, 1)
    self.Selected = ImGui.Selectable('About', self.SelectedItemType == 'about')
    ImGui.PopStyleColor(1)
    if self.Selected then
        self:selectItem(nil, 'about')
    end
end

function ConfigurationPanel:drawLeftPaneWindow()
    local _,y = ImGui.GetContentRegionAvail()
    if ImGui.BeginChild("left##"..self.Name, self.LeftPaneSize, y-1, true) then
        local flags = bit32.bor(ImGuiTableFlags.RowBg, ImGuiTableFlags.BordersOuter, ImGuiTableFlags.BordersV, ImGuiTableFlags.ScrollY)
        if ImGui.BeginTable('##configmenu'..self.Name, 1, flags, 0, 0, 0.0) then
            ImGui.TableNextRow()
            ImGui.TableNextColumn()
            self:drawDisplaySettingsSelector()
            ImGui.TableNextRow()
            ImGui.TableNextColumn()
            self:drawPropertiesTreeSelector()
            ImGui.TableNextRow()
            ImGui.TableNextColumn()
            self:drawColumnTreeSelector()
            ImGui.TableNextRow()
            ImGui.TableNextColumn()
            self:drawTabTreeSelector()
            if state.PeerSource == 'dannet' then
                ImGui.TableNextRow()
                ImGui.TableNextColumn()
                self:drawWindowTreeSelector()
            end
            ImGui.TableNextRow()
            ImGui.TableNextColumn()
            self:drawImportSelector()
            ImGui.TableNextRow()
            ImGui.TableNextColumn()
            self:drawAboutSelector()

            ImGui.EndTable()
        end
    end
    ImGui.EndChild()
end

function ConfigurationPanel:drawDisplaySettings()
    ImGui.TextColored(1, 0, 1, 1, 'Window Settings')
    ImGui.Separator()
    state.Settings.Windows[self.Name].Transparency = helpers.DrawCheckBox('Transparent Window: ', '##transparency', state.Settings.Windows[self.Name].Transparency, 'Check this box to toggle transparency of the window.')
    state.Settings.Windows[self.Name].TitleBar = helpers.DrawCheckBox('Show Title Bar: ', '##titlebar', state.Settings.Windows[self.Name].TitleBar, 'Check this box to toggle showing the title bar.')
    state.Settings.Columns['Name']['IncludeLevel'] = helpers.DrawCheckBox('Name includes Level: ', '##namewithlevel', state.Settings.Columns['Name']['IncludeLevel'], 'Check this box to toggle showing name and level together in the Name column.')
    ImGui.Separator()
    ImGui.Text('Column Text Colors:')
    state.Settings['Colors']['Default'] = helpers.DrawColorEditor("Default Color", state.Settings['Colors']['Default'])
    ImGui.SameLine()
    ImGui.SetCursorPosX(175)
    state.Settings['Colors']['InZone'] = helpers.DrawColorEditor("Character names in zone", state.Settings['Colors']['InZone'])
    state.Settings['Colors']['Low'] = helpers.DrawColorEditor("Below Threshold", state.Settings['Colors']['Low'])
    ImGui.SameLine()
    ImGui.SetCursorPosX(175)
    state.Settings['Colors']['Invis'] = helpers.DrawColorEditor("Invis characters in zone", state.Settings['Colors']['Invis'])
    state.Settings['Colors']['Medium'] = helpers.DrawColorEditor("Medium Threshold", state.Settings['Colors']['Medium'])
    ImGui.SameLine()
    ImGui.SetCursorPosX(175)
    state.Settings['Colors']['IVU'] = helpers.DrawColorEditor("IVU characters in zone", state.Settings['Colors']['IVU'])
    state.Settings['Colors']['High'] = helpers.DrawColorEditor("Above Threshold", state.Settings['Colors']['High'])
    ImGui.SameLine()
    ImGui.SetCursorPosX(175)
    state.Settings['Colors']['DoubleInvis'] = helpers.DrawColorEditor("Double Invis characters in zone", state.Settings['Colors']['DoubleInvis'])
    state.Settings['Colors']['True'] = helpers.DrawColorEditor("True values", state.Settings['Colors']['True'])
    ImGui.SameLine()
    ImGui.SetCursorPosX(175)
    state.Settings['Colors']['NotInZone'] = helpers.DrawColorEditor("Characters not in zone", state.Settings['Colors']['NotInZone'])
    state.Settings['Colors']['False'] = helpers.DrawColorEditor("False values", state.Settings['Colors']['False'])
    ImGui.Separator()
    if ImGui.Button('Save##displaysettings') then
        settings.SaveSettings()
        self:clearSelection()
    end
end

function ConfigurationPanel:drawPropertyLibrary()
    ImGui.Text('Property Library:')
    ImGui.SameLine()
    if ImGui.Button('Add Selected Property') and self.SelectedItem then
        self.NewProperty = PropertyInput:fromProperty(library.Properties[self.SelectedItem])
        self:selectItem(nil, 'addnewproperty')
        return
    end
    local flags = bit32.bor(ImGuiTableFlags.RowBg, ImGuiTableFlags.BordersOuter, ImGuiTableFlags.BordersV, ImGuiTableFlags.ScrollY)
    if ImGui.BeginTable('##proplibrary'..self.Name, 1, flags, 0, 0, 0.0) then
        for idx,property in ipairs(library.Properties) do
            ImGui.TableNextRow()
            ImGui.TableNextColumn()
            self.Selected = ImGui.Selectable(property.Name, self.SelectedItem == idx)
            if self.Selected then
                self:selectItem(idx, 'addpfromlibrary')
            end
        end
        ImGui.EndTable()
    end
end

function ConfigurationPanel:drawColumnLibrary()
    ImGui.Text('Column Library:')
    ImGui.SameLine()
    if ImGui.Button('Add Selected Column') and self.SelectedItem then
        self.NewColumn = ColumnInput:fromColumn(library.Columns[self.SelectedItem])
        self:selectItem(nil, 'addnewcolumn')
        return
    end
    local flags = bit32.bor(ImGuiTableFlags.RowBg, ImGuiTableFlags.BordersOuter, ImGuiTableFlags.BordersV, ImGuiTableFlags.ScrollY)
    if ImGui.BeginTable('##columnlibrary'..self.Name, 1, flags, 0, 0, 0.0) then
        for idx,column in ipairs(library.Columns) do
            ImGui.TableNextRow()
            ImGui.TableNextColumn()
            self.Selected = ImGui.Selectable(column.Name, self.SelectedItem == idx)
            if self.Selected then
                self:selectItem(idx, 'addcfromlibrary')
            end
        end
        ImGui.EndTable()
    end
end

function ConfigurationPanel:drawImport()
    if ImGui.Button('Choose...') then
        filedialog.set_file_selector_open(true)
    end
    ImGui.SameLine()
    if ImGui.Button('Import') then
        if self.tmp_settings then
            settings.ImportSettings(self.tmp_settings)
            self.tmp_settings = nil
            self.ImportFileName = ''
            settings.SaveSettings()
        end
    end
    if filedialog.is_file_selector_open() then
        filedialog.draw_file_selector(mq.configDir, '.lua')
    end
    if not filedialog.is_file_selector_open() and filedialog.get_filename() ~= '' then
        self.ImportFileName = filedialog.get_filename()
        filedialog:reset_filename()
        self.tmp_settings = nil
    end
    ImGui.Text('Import settings from: ' .. self.ImportFileName)
    if not self.tmp_settings and self.ImportFileName ~= '' then
        self.tmp_settings = assert(loadfile(mq.configDir..'/'..self.ImportFileName))()
        -- validate settings file
    end
    if self.tmp_settings then
        local flags = bit32.bor(ImGuiTableFlags.RowBg, ImGuiTableFlags.BordersOuter, ImGuiTableFlags.BordersV, ImGuiTableFlags.ScrollY)
        if self.tmp_settings['Properties'] then
            if ImGui.BeginTable('Import Properties', 2, flags, ImGui.GetContentRegionAvail() - 100, 200, 0.0) then
                ImGui.TableSetupColumn('Select',        bit32.bor(ImGuiTableColumnFlags.NoSort, ImGuiTableColumnFlags.WidthFixed),   -1.0, 0)
                ImGui.TableSetupColumn('Property Name', bit32.bor(ImGuiTableColumnFlags.NoSort, ImGuiTableColumnFlags.WidthFixed),   -1.0, 1)
                ImGui.TableSetupScrollFreeze(0, 1) -- Make row always visible
                ImGui.TableHeadersRow()
                for i,j in pairs(self.tmp_settings['Properties']) do
                    ImGui.TableNextRow()
                    ImGui.TableNextColumn()
                    self.tmp_settings['Properties'][i].selected = ImGui.Checkbox('##'..i, self.tmp_settings['Properties'][i].selected or false)
                    ImGui.TableNextColumn()
                    ImGui.Text(i)
                    ImGui.TableNextColumn()
                end
                ImGui.EndTable()
            end
        end
        if self.tmp_settings['Columns'] then
            if ImGui.BeginTable('Import Columns', 2, flags, ImGui.GetContentRegionAvail() - 100, 200, 0.0) then
                ImGui.TableSetupColumn('Select',        bit32.bor(ImGuiTableColumnFlags.NoSort, ImGuiTableColumnFlags.WidthFixed),   -1.0, 0)
                ImGui.TableSetupColumn('Column Name', bit32.bor(ImGuiTableColumnFlags.NoSort, ImGuiTableColumnFlags.WidthFixed),   -1.0, 1)
                ImGui.TableSetupScrollFreeze(0, 1) -- Make row always visible
                ImGui.TableHeadersRow()
                for i,j in pairs(self.tmp_settings['Columns']) do
                    ImGui.TableNextRow()
                    ImGui.TableNextColumn()
                    self.tmp_settings['Columns'][i].selected = ImGui.Checkbox('##'..i, self.tmp_settings['Columns'][i].selected or false)
                    ImGui.TableNextColumn()
                    ImGui.Text(i)
                    ImGui.TableNextColumn()
                end
                ImGui.EndTable()
            end
        end
    end
end

function ConfigurationPanel:drawAbout()
    ImGui.TextColored(1, 0, 1, 1, 'About')
    ImGui.Separator()
    helpers.DrawLabelAndTextValue('Version: ', state.Version)
end

function ConfigurationPanel:drawInfo(width)
    ImGui.PushTextWrapPos(width-17)
    ImGui.Text('To get started with configuring boxhud, select an item from the menu on the left.')
    ImGui.Text('Properties define the data members which will be either observed with MQ2DanNet, read from MQ2NetBots or read from Spawn data.')
    ImGui.Text('Columns define how specific properties should be displayed.')
    ImGui.Text('Tabs define groupings of columns and will appear in the top tab bar.')
    ImGui.Text('Windows define separate instances of the boxhud window to be displayed for different peer groups. (MQ2DanNet only)')
    ImGui.PopTextWrapPos()
end

function ConfigurationPanel:drawRightPaneWindow()
    local x,y = ImGui.GetContentRegionAvail()
    if ImGui.BeginChild("right##"..self.Name, x, y-1, true) then
        if self.SelectedItemType == 'displaysettings' then
            self:drawDisplaySettings()
        elseif self.SelectedItemType == 'addnewproperty' then
            self.NewProperty:draw(x, self)
        elseif self.SelectedItemType == 'addpfromlibrary' then
            self:drawPropertyLibrary()
        elseif self.SelectedItemType == 'addnewcolumn' then
            self.NewColumn:draw(x, self)
        elseif self.SelectedItemType == 'addcfromlibrary' then
            self:drawColumnLibrary()
        elseif self.SelectedItemType == 'addnewtab' then
            self.NewTab:draw(x, self)
        elseif self.SelectedItemType == 'addnewwindow' then
            self.NewWindow:draw(x, self)
        elseif self.SelectedItemType == 'property' then
            local property = state.Settings['Properties'][self.SelectedItem]
            if property then
                property:draw(self)
            end
        elseif self.SelectedItemType == 'column' then
            local column = state.Settings['Columns'][self.SelectedItem]
            if column ~= nil then
                column:draw(self)
            end
        elseif self.SelectedItemType == 'tab' then
            local tab = state.Settings['Tabs'][self.SelectedItem]
            if tab then
                tab:draw(self)
            end
        elseif self.SelectedItemType == 'window' then
            local window = state.Settings['Windows'][self.SelectedItem]
            if window then
                window:draw(self)
            end
        elseif self.SelectedItemType == 'import' then
            self:drawImport()
        elseif self.SelectedItemType == 'about' then
            self:drawAbout()
        else
            self:drawInfo(x)
        end
    end
    ImGui.EndChild()
end

function ConfigurationPanel:drawSplitter(thickness, size0, min_size0)
    local x,y = ImGui.GetCursorPos()
    local delta = 0
    ImGui.SetCursorPosX(x + size0)

    ImGui.PushStyleColor(ImGuiCol.Button, 0, 0, 0, 0)
    ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0, 0, 0, 0)
    ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.6, 0.6, 0.6, 0.1)
    ImGui.Button('##splitter', thickness, -1)
    ImGui.PopStyleColor(3)

    ImGui.SetItemAllowOverlap()

    if ImGui.IsItemActive() then
        delta,_ = ImGui.GetMouseDragDelta()

        if delta < min_size0 - size0 then
            delta = min_size0 - size0
        end
        if delta > 275 - size0 then
            delta = 275 - size0
        end

        size0 = size0 + delta
        self.LeftPaneSize = size0
    else
        self.BaseLeftPaneSize = self.LeftPaneSize
    end
    ImGui.SetCursorPosX(x)
    ImGui.SetCursorPosY(y)
end

function ConfigurationPanel:draw()
    self:drawSplitter(8, self.BaseLeftPaneSize, 135)
    ImGui.PushStyleVar(ImGuiStyleVar.WindowPadding, 6, 6)
    self:drawLeftPaneWindow()
    ImGui.PopStyleVar()
    ImGui.SameLine()
    ImGui.PushStyleVar(ImGuiStyleVar.WindowPadding, 6, 6)
    self:drawRightPaneWindow()
    ImGui.PopStyleVar()
end

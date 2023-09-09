local Column = require 'classes.config.column'
local ColumnInput = require 'classes.inputs.columninput'
local helpers = require 'utils.uihelpers'
local state = require 'state'
local settings = require 'settings.settings'

local classes = {'all', 'melee', 'caster', 'hybrids', 'ranged', 'ber', 'brd',
        'bst', 'clr', 'dru', 'enc', 'mag', 'mnk', 'nec', 'pal', 'shd', 'rng',
        'rog', 'shm', 'war', 'wiz'}

function ColumnInput:toColumn()
    local column = Column({Name=self.Name,Type='property'})
    if self.Type == 1 then
        column['IncludeLevel'] = self.IncludeLevel
        column['Ascending']=self.Ascending
        column['InZone']=self.InZone
        column['Percentage']=self.Percentage
        column['Properties']={}
        for i,j in ipairs(self.Properties) do
            column['Properties'][j[1]] = j[2]
        end
        if self.MappingCount > 0 then
            column['Mappings']={}
        end
        for i,j in ipairs(self.Mappings) do
            column['Mappings'][j[1]] = j[2]
        end
        if self.ThresholdCount > 0 then
            column['Thresholds']={}
        end
        for i,j in ipairs(self.Thresholds) do
            column['Thresholds'][i] = tonumber(j)
        end
        column['OwnColor'] = self.OwnColor
        column['Color'] = self.Color
        column['Prettify'] = self.Prettify
    elseif self.Type == 2 then
        column['Type'] = 'button'
        column['Action'] = self.Action
    end
    return column
end

function ColumnInput:fromColumn(column)
    local o = ColumnInput()
    o.Name = column['Name']
    if column['Type'] == 'property' then
        o.Type = 1
        o.IncludeLevel = column['IncludeLevel']
        o.Ascending = column['Ascending']
        o.InZone = column['InZone']
        o.Percentage = column['Percentage']
        o.OwnColor = column['OwnColor'] or false
        o.Color = column['Color']
        o.Prettify = column['Prettify'] or false
        o.PropertyCount = 0
        o.Properties = {}
        if column['Properties'] then
            for propKey,propValue in pairs(column['Properties']) do
                o.PropertyCount = o.PropertyCount + 1
                o.Properties[o.PropertyCount] = {[1]=propKey,[2]=propValue}
            end
        end
        o.MappingCount = 0
        o.Mappings = {}
        if column['Mappings'] then
            for mappingKey,mappingValue in pairs(column['Mappings']) do
                o.MappingCount = o.MappingCount + 1
                o.Mappings[o.MappingCount] = {[1]=mappingKey,[2]=mappingValue}
            end
        end
        o.ThresholdCount = 0
        o.Thresholds = {}
        if column['Thresholds'] then
            for thresholdIdx,thresholdValue in ipairs(column['Thresholds']) do
                o.ThresholdCount = o.ThresholdCount + 1
                o.Thresholds[thresholdIdx] = tostring(thresholdValue)
            end
        end
    else
        o.Type = 2
        o.Action = column['Action']
    end
    return o
end

function ColumnInput:draw(width, configPanel)
    ImGui.TextColored(1, 0, 1, 1, "Add New Column")
    ImGui.Separator()
    ImGui.Text('Type: ')
    ImGui.SameLine()
    helpers.HelpMarker('Choose whether the column will display property values or buttons.')
    self.Type,_ = ImGui.RadioButton("Property", self.Type, 1)
    ImGui.SameLine()
    self.Type,_ = ImGui.RadioButton("Button", self.Type, 2)

    self.Name = helpers.DrawLabelAndTextInput('Name(*): ', '##newcolumnname', self.Name, 'The name of the column which will appear in the table column header.')

    if self.Type == 1 then
        ImGui.Text('Properties(*): ')
        ImGui.SameLine()
        helpers.HelpMarker('The property values which will be displayed in this column. The column can display different properties for different classes.')
        for propIdx, propName in ipairs(self.Properties) do
            if self.Properties[propIdx] ~= nil then
                ImGui.PushItemWidth(80)
                self.Properties[propIdx][1] = helpers.DrawComboBox("##colpropcombo1"..propIdx, self.Properties[propIdx][1], classes, false)
                ImGui.PopItemWidth()
                ImGui.SameLine()
                ImGui.PushItemWidth(160)
                self.Properties[propIdx][2] = helpers.DrawComboBox("##colpropcombo2"..propIdx, self.Properties[propIdx][2], state.Settings['Properties'], true)
                ImGui.PopItemWidth()
                ImGui.SameLine()
                if ImGui.Button('X##deleteRow'..propIdx) then
                    local propIter = propIdx
                    for prop = propIdx+1, #self.Properties do
                        self.Properties[propIter] = self.Properties[prop]
                        propIter = propIter+1
                    end
                    self.Properties[propIter] = nil
                    self.PropertyCount = self.PropertyCount - 1
                end
            end
        end
        if ImGui.Button('+##properties') then
            self.PropertyCount = self.PropertyCount + 1
            self.Properties[self.PropertyCount] = {[1]='',[2]=''}
        end
        
        ImGui.Text('Mappings: ')
        ImGui.SameLine()
        helpers.HelpMarker('Optional. Define mappings from raw property values to values that should be displayed.\nExample: Map \'TRUE\' to \'Paused\' for \'Macro.Paused\'.')
        for mappingIdx, _ in ipairs(self.Mappings) do
            if self.Mappings[mappingIdx] ~= nil then
                ImGui.PushItemWidth(100)
                self.Mappings[mappingIdx][1], configPanel.Selected = ImGui.InputText('##newcolmappings1-'..tostring(mappingIdx), self.Mappings[mappingIdx][1], ImGuiInputTextFlags.EnterReturnsTrue)
                ImGui.SameLine()
                self.Mappings[mappingIdx][2], configPanel.Selected = ImGui.InputText('##newcolmappings2-'..tostring(mappingIdx), self.Mappings[mappingIdx][2], ImGuiInputTextFlags.EnterReturnsTrue)
                ImGui.SameLine()
                if ImGui.Button('X##deleteMappingRow'..mappingIdx) then
                    local mappingIter = mappingIdx
                    for mapping = mappingIdx+1, #self.Mappings do
                        self.Mappings[mappingIter] = self.Mappings[mapping]
                        mappingIter = mappingIter+1
                    end
                    self.Mappings[mappingIter] = nil
                    self.MappingCount = self.MappingCount - 1
                end
                ImGui.PopItemWidth()
            end
        end
        if ImGui.Button('+##mappings') then
            self.MappingCount = self.MappingCount + 1
            self.Mappings[self.MappingCount] = {[1]='',[2]=''}
        end

        ImGui.Text('Thresholds: ')
        ImGui.SameLine()
        helpers.HelpMarker('Optional. Set up to (2) numbers, in increasing order, for column text color thresholds.\nExample: Set Me.PctHPs thresholds to 35, 70 so that values below 35 will be red, between 35-70 will be yellow, and above 70 will be green.')
        for thresholdIdx, _ in ipairs(self.Thresholds) do
            if self.Thresholds[thresholdIdx] ~= nil then
                ImGui.PushItemWidth(80)
                self.Thresholds[thresholdIdx], configPanel.Selected = ImGui.InputText('##newcolthresholds'..tostring(thresholdIdx), self.Thresholds[thresholdIdx], ImGuiInputTextFlags.EnterReturnsTrue)
                ImGui.PopItemWidth()
                ImGui.SameLine()
                if ImGui.Button('X##deleteThresholdRow'..thresholdIdx) then
                    local thresholdIter = thresholdIdx
                    for threshold = thresholdIdx+1, #self.Thresholds do
                        self.Thresholds[thresholdIter] = self.Thresholds[threshold]
                        thresholdIter = thresholdIter+1
                    end
                    self.Thresholds[thresholdIter] = nil
                    self.ThresholdCount = self.ThresholdCount - 1
                end
            end
        end
        if self.ThresholdCount < 2 then
            if ImGui.Button('+##thresholds') then
                self.ThresholdCount = self.ThresholdCount + 1
                self.Thresholds[self.ThresholdCount] = ''
            end
        end

        self.Percentage = helpers.DrawCheckBox('Percentage', '##newcolumnpercent', self.Percentage, 'Check this box if the values displayed in this column are percents.')
        self.Ascending = helpers.DrawCheckBox('Ascending', '##newcolumnascending', self.Ascending, 'Check this box if higher values are \'better\', i.e. 100%% HP is better than 10%%.')
        self.InZone = helpers.DrawCheckBox('InZone', '##newcolumninzone', self.InZone, 'Check this box if this column should only display values for characters in the same zone.')

        self.OwnColor = helpers.DrawCheckBox('Set color', '##newcolumncolor', self.OwnColor, 'Check this box if the column should have its own color settings. Overrides any global color settings.')
        if self.OwnColor then
            local tmpColor = self.Color or {1,1,1}
            local oldR, oldG, oldB = tmpColor[1], tmpColor[2], tmpColor[3]
            tmpColor = helpers.DrawColorEditor("Color", tmpColor)
            if tmpColor[1] ~= oldR or tmpColor[2] ~= oldG or tmpColor[3] ~= oldB then
                self.Color = tmpColor
            end
        else
            self.Color = nil
        end

        self.Prettify = helpers.DrawCheckBox('Prettify', '##newcolumnprettify', self.Prettify, 'Check this box if the column should prettify number values, like 1,000 instead of 1000.')

    elseif self.Type == 2 then
        self.Action = helpers.DrawLabelAndTextInput('Action(*): ', '##newcolumnaction', self.Action, 'The action to take on left click. The string \'#botName#\' will be replaced with the character name from the row of the button.\nExample: \'/dex #botName# /mqp\'')
    end
    ImGui.Separator()
    if ImGui.Button('Save##newcolumn'..configPanel.Name) then
        local column = self:toColumn()
        ok, self.Message = column:validate()
        if ok then
            state.Settings['Columns'][self.Name] = column
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

function Column:references(draw)
    local refFound = false
    for _,tab in pairs(state.Settings['Tabs']) do
        if tab['Columns'] then
            for _,columnNameIter in pairs(tab['Columns']) do
                if self.Name == columnNameIter then
                    refFound = true
                    if draw then
                        helpers.DrawReferenceText('Tab: ', tab['Name'], nil, nil)
                    end
                end
            end
        end
    end
    return refFound
end

function Column:draw(configPanel)
    ImGui.TextColored(1, 0, 1, 1, self.Name)
    ImGui.Separator()
    if self.Name ~= 'Name' then
        if ImGui.SmallButton('Edit##'..self.Name) then
            configPanel.NewColumn = ColumnInput:fromColumn(self)
            configPanel:selectItem(nil, 'addnewcolumn')
        end
        ImGui.SameLine()
        if ImGui.SmallButton('Delete##'..self.Name) then
            if not self:references(false) then
                state.Settings['Columns'][self.Name] = nil
                settings.SaveSettings()
                configPanel:clearSelection()
            end
        end
    end
    helpers.DrawLabelAndTextValue('Type: ', self.Type)
    
    if self.Type == 'property' then
        ImGui.Text('Properties: ')
        if self.Properties then
            ImGui.Indent(10)
            for i,j in pairs(self.Properties) do
                ImGui.TextColored(0, 1, 1, 1, i..': ')
                ImGui.SameLine()
                ImGui.TextColored(0, 1, 0, 1, j)
            end
            ImGui.Indent(-10)
        end
        ImGui.Text('Thresholds: ')
        if self.Thresholds then
            ImGui.Indent(10)
            for i,j in ipairs(self.Thresholds) do
                ImGui.TextColored(0, 1, 1, 1, tostring(i)..': ')
                ImGui.SameLine()
                ImGui.TextColored(0, 1, 0, 1, tostring(j))
            end
            ImGui.Indent(-10)
        else
            ImGui.SameLine()
            ImGui.TextColored(0, 1, 0, 1, 'None')
        end
        ImGui.Text('Mappings: ')
        if self.Mappings then
            ImGui.Indent(10)
            for i,j in pairs(self.Mappings) do
                ImGui.TextColored(0, 1, 1, 1, i..': ')
                ImGui.SameLine()
                ImGui.TextColored(0, 1, 0, 1, j)
            end
            ImGui.Indent(-10)
        else
            ImGui.SameLine()
            ImGui.TextColored(0, 1, 0, 1, 'None')
        end
        if self.Percentage then
            helpers.DrawLabelAndTextValue('Percentage: ', tostring(self.Percentage))
        end
        if self.Ascending then
            helpers.DrawLabelAndTextValue('Ascending: ', tostring(self.Ascending))
        end
        if self.InZone then
            helpers.DrawLabelAndTextValue('InZone: ', tostring(self.InZone))
        end
        if self.Prettify then
            helpers.DrawLabelAndTextValue('Prettify: ', tostring(self.Prettify))
        end
    elseif self.Type == 'button' then
        if self.Action then
            helpers.DrawLabelAndTextValue('Action: ', self.Action)
        end
    end
    ImGui.Separator()
    ImGui.Text('References:')
    ImGui.Indent(10)
    self:references(true)
    ImGui.Indent(-10)
end

--- @type Mq
local mq = require 'mq'
local Property = require 'classes.config.property'
local PropertyInput = require 'classes.inputs.propertyinput'
local helpers = require 'utils.uihelpers'
local state = require 'state'
local settings = require 'settings.settings'

function PropertyInput:toProperty()
    local property = Property({})
    property['Name'] = self.Name
    property['Type'] = 'Observed'
    if self.Type == 2 then
        property['Type'] = 'NetBots'
    elseif self.Type == 3 then
        property['Type'] = 'Spawn'
    end
    if self.DependsOnName ~= '' then
        property['DependsOnName'] = self.DependsOnName
    end
    if self.DependsOnValue ~= '' then
        property['DependsOnValue'] = self.DependsOnValue
    end
    property['Inverse'] = self.Inverse
    if self.FromIDProperty ~= '' then
        property['FromIDProperty'] = self.FromIDProperty
    end
    return property
end

function PropertyInput:fromProperty(property)
    local o = PropertyInput()
    o.Name = property.Name
    if property['Type'] == 'Observed' then
        o.Type = 1
        o.DependsOnName = property['DependsOnName'] or ''
        o.DependsOnValue = property['DependsOnValue'] or ''
    elseif property['Type'] == 'Spawn' then
        o.Type = 3
        o.FromIDProperty = property['FromIDProperty'] or ''
    else
        o.Type = 2
    end
    return o
end

function PropertyInput:draw(width, configPanel)
    ImGui.TextColored(1, 0, 1, 1, "Add New Property")
    ImGui.Separator()
    ImGui.Text('Type: ')
    ImGui.SameLine()
    helpers.HelpMarker('The source of the property value.\n\'Observed\' will get the value using MQ2DanNet.\n\'NetBots\' will get the value using MQ2NetBots.\n\'Spawn\' will get the value from the Spawn TLO.')
    self.Type,_ = ImGui.RadioButton("Observed", self.Type, 1)
    ImGui.SameLine()
    self.Type,_ = ImGui.RadioButton("NetBots", self.Type, 2)
    ImGui.SameLine()
    self.Type,_ = ImGui.RadioButton("Spawn", self.Type, 3)
    
    self.Name = helpers.DrawLabelAndTextInput('Name(*): ', '##newpropname', self.Name, 'The data member this property should display. Examples:\nObserved: \'Me.PctHPs\'\nNetBots: \'PctHPs\'\nSpawn: \'Distance3D\'\n')
    self.Name = self.Name:gsub('^${','')
    self.Name = self.Name:gsub('}$','')

    if self.Type == 1 then
        ImGui.PushTextWrapPos(width-17)
        ImGui.TextColored(1, 0, 0, 1, 'WARNING: Observed property names are case sensitive and must be valid TLO members on each character that will be observed. They MUST NOT include the brackets around them like ${ }.')
        ImGui.PopTextWrapPos()
        self.DependsOnName = helpers.DrawLabelAndTextInput('DependsOnName: ', '##newpropdepname', self.DependsOnName, 'Optional. The name of another property which this property depends on. This property will be ignored for a character if the property it depends on doesn\'t have the desired value.')
        self.DependsOnValue = helpers.DrawLabelAndTextInput('DependsOnValue: ', '##newpropdepvalue', self.DependsOnValue, 'Optional. The value of another property which this property depends on. This property will be ignored for a character if the property it depends on doesn\'t have the desired value.')
        self.Inverse = helpers.DrawCheckBox('Inverse', '##newpropinverse', self.Inverse, 'Optional. Validate that the dependency condition is false instead of true.')
    elseif self.Type == 3 then
        self.FromIDProperty = helpers.DrawLabelAndTextInput('FromIDProperty: ', '##newpropfromid', self.FromIDProperty, 'Optional. The name of another property to use as the ID in the Spawn search. The property MUST return a Spawn ID.')
    end
    ImGui.Separator()
    if self.savewarningname ~= self.Name then
        self.showsavewarning = false
        self.savewarningname = ''
    end
    if not self.showsavewarning then
        if ImGui.Button('Save##newprop'..configPanel.Name) then
            self.showsavewarning = true
            self.savewarningname = self.Name
        end
    else
        if ImGui.Button('Confirm') then
            local property = self:toProperty()
            local ok = false
            ok, self.Message = property:validate()
            if ok then
                state.Settings['Properties'][self.Name] = property
                settings.SaveSettings()
                configPanel:clearSelection()
            else
                self.Valid = false
            end
            self.showsavewarning = false
            self.savewarningname = ''
        end
        if self.Type == 1 then
            local prefix,_ = self.Name:gsub('%..*', '')
            prefix,_ = prefix:gsub('%[.*', '')
            local suffix,_ = self.Name:gsub('.*%.', '')
            ImGui.PushTextWrapPos(width-10)
            if not mq.TLO[prefix] then
                ImGui.TextColored(1, 1, 0, 1, string.format('TLO "%s" doesn\'t look familiar.', prefix))
            elseif suffix ~= prefix and not mq.TLO[prefix][suffix] then
                ImGui.TextColored(1, 1, 0, 1, string.format('"%s" TLO Member "%s" doesn\'t look familiar', prefix, suffix))
            end
            if self.Name:find('%[') and not self.Name:find(']') then
                ImGui.TextColored(1, 1, 0, 1, string.format('Mismatched [ ] in property "%s"', self.Name))
            end
            ImGui.TextColored(1, 1, 0, 1, string.format('Are you sure you want to add property: %s', self.Name))
            ImGui.PopTextWrapPos()
        elseif self.Type == 2 then
            ImGui.PushTextWrapPos(width-10)
            if not mq.TLO['NetBots'] or not mq.TLO['NetBots'][self.Name] then
                ImGui.TextColored(1, 1, 0, 1, string.format('"NetBots" TLO Member "%s" doesn\'t look familiar.', self.Name))
            end
            ImGui.TextColored(1, 1, 0, 1, string.format('Are you sure you want to add property: %s', self.Name))
            ImGui.PopTextWrapPos()
        elseif self.Type == 3 then
            ImGui.PushTextWrapPos(width-10)
            if not mq.TLO['Spawn'][self.Name] then
                ImGui.TextColored(1, 1, 0, 1, string.format('"Spawn" TLO Member "%s" doesn\'t look familiar', self.Name))
            end
            ImGui.TextColored(1, 1, 0, 1, string.format('Are you sure you want to add property: %s', self.Name))
            ImGui.PopTextWrapPos()
        end

    end
    if not self.Valid then
        ImGui.SameLine()
        ImGui.PushTextWrapPos(width-10)
        ImGui.TextColored(1, 0, 0, 1, string.format('Invalid input! %s', self.Message))
        ImGui.PopTextWrapPos()
    end
end

function Property:references(draw)
    local refFound = false
    for columnName,column in pairs(state.Settings['Columns']) do
        if column['Properties'] then
            for propKey,propValue in pairs(column['Properties']) do
                if propValue == self.Name then
                    refFound = true
                    if draw then
                        helpers.DrawReferenceText('Column: ', columnName, ' Property Key: ', propKey)
                    end
                end
            end
        end
    end
    for propNameIter,property in pairs(state.Settings['Properties']) do
        if property['DependsOnName'] == self.Name then
            refFound = true
            if draw then
                helpers.DrawReferenceText('Property: ', propNameIter, ' DependsOnName: ', self.Name)
            end
        elseif property['FromIDProperty'] == self.Name then
            refFound = true
            if draw then
                helpers.DrawReferenceText('Property: ', propNameIter, ' FromIDProperty: ', self.Name)
            end
        end
    end
    return refFound
end

function Property:draw(configPanel)
    ImGui.TextColored(1, 0, 1, 1, self.Name)
    ImGui.Separator()
    if self.Name ~= 'Me.Class.ShortName' then
        if ImGui.SmallButton('Edit##'..self.Name) then
            configPanel.NewProperty = PropertyInput:fromProperty(self)
            configPanel:selectItem(nil, 'addnewproperty')
        end
        ImGui.SameLine()
        if ImGui.SmallButton('Delete##'..self.Name) then
            if not self:references(false) then
                state.Settings['Properties'][self.Name] = nil
                settings.SaveSettings()
                configPanel:clearSelection()
            end
        end
    end
    helpers.DrawLabelAndTextValue('Type: ', self.Type)
    if self.DependsOnName then
        helpers.DrawLabelAndTextValue('DependsOnName: ', self.DependsOnName)
    end
    if self.DependsOnValue then
        helpers.DrawLabelAndTextValue('DependsOnValue: ', self.DependsOnValue)
    end
    if self.DependsOnName then
        helpers.DrawLabelAndTextValue('Inverse: ', tostring(self.Inverse))
    end
    if self.FromIDProperty then
        helpers.DrawLabelAndTextValue('FromIDProperty: ', self.FromIDProperty)
    end
    ImGui.Separator()
    ImGui.Text('References:')
    ImGui.Indent(10)
    self:references(true)
    ImGui.Indent(-10)
end
local uihelpers = {}

uihelpers.HelpMarker = function(desc)
    ImGui.TextDisabled('(?)')
    if ImGui.IsItemHovered() then
        ImGui.BeginTooltip()
        ImGui.PushTextWrapPos(ImGui.GetFontSize() * 35.0)
        ImGui.Text(desc)
        ImGui.PopTextWrapPos()
        ImGui.EndTooltip()
    end
end

uihelpers.DrawLabelAndTextInput = function(textLabel, inputLabel, resultVar, helpText)
    ImGui.Text(textLabel)
    ImGui.SameLine()
    uihelpers.HelpMarker(helpText)
    resultVar,_ = ImGui.InputText(inputLabel, resultVar, ImGuiInputTextFlags.EnterReturnsTrue)
    return resultVar
end

uihelpers.DrawLabelAndTextValue = function(label, value)
    ImGui.Text(label)
    ImGui.SameLine()
    ImGui.TextColored(0, 1, 0, 1, tostring(value))
end

uihelpers.DrawComboBox = function(label, resultvar, options, bykey)
    if ImGui.BeginCombo(label, resultvar) then
        for i,j in pairs(options) do
            if bykey then
                if ImGui.Selectable(i, i == resultvar) then
                    resultvar = i
                end
            else
                if ImGui.Selectable(j, j == resultvar) then
                    resultvar = j
                end
            end
        end
        ImGui.EndCombo()
    end
    return resultvar
end

uihelpers.DrawCheckBox = function(labelText, idText, resultVar, helpText)
    resultVar,_ = ImGui.Checkbox(idText, resultVar)
    ImGui.SameLine()
    ImGui.Text(labelText)
    ImGui.SameLine()
    uihelpers.HelpMarker(helpText)
    return resultVar
end

uihelpers.DrawColorEditor = function(label, resultVar)
    local col, _ = ImGui.ColorEdit3(label, resultVar, ImGuiColorEditFlags.NoInputs)
    if col then
        resultVar = col
    end
    return resultVar
end

uihelpers.DrawReferenceText = function(label1, value1, label2, value2)
    ImGui.TextColored(0, 1, 1, 1, label1)
    ImGui.SameLine()
    ImGui.TextColored(0, 1, 0, 1, value1)
    if label2 then
        ImGui.SameLine()
        ImGui.TextColored(0, 1, 1, 1, label2)
        ImGui.SameLine()
        ImGui.TextColored(0, 1, 0, 1, value2)
    end
end

return uihelpers
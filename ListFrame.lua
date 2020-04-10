local addon, ns = ...


function ns:CreateListFrame(name, list, parent)
    local frame = CreateFrame("Frame", name, parent)
    frame.buttons = {}
    local selected = nil

    for _, name in pairs(list) do
        local btn = CreateFrame("Button", ("$parent%s"):format(name), frame, "OptionsListButtonTemplate")
        btn:SetText(name)
        btn:SetScript("OnClick", function(self)
            if selected then
                selected:UnlockHighlight()
            end
            self:LockHighlight()
            selected = self
        end)
        function btn:GetListName()
            return name
        end
        frame.buttons[name] = btn
    end

    function frame:GetListHeight()
        local height = 0
        for _, btn in pairs(frame.buttons) do
            height = height + btn:GetHeight()
        end
        return height
    end

    function frame:GetSelected()
        return selected
    end

    frame:SetHeight(frame:GetListHeight())
    frame.buttons[list[1]]:SetPoint("TOPLEFT")
    frame.buttons[list[1]]:SetPoint("TOPRIGHT")

    for i = 2, #list do
        frame.buttons[list[i]]:SetPoint("TOPLEFT", frame.buttons[list[i - 1]], "BOTTOMLEFT")
        frame.buttons[list[i]]:SetPoint("TOPRIGHT", frame.buttons[list[i - 1]], "BOTTOMRIGHT")
    end

    return frame
end

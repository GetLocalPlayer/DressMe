local addon, ns = ...


local recycler = {}


local function button_OnClick(self)
    self:GetParent():Select(self:GetID())
end

local function ListFrame_GetListHeight(self)
    local height = 0
    for _, btn in pairs(self.buttons) do
        height = height + btn:GetHeight()
    end
    return height
end

local function ListFrame_Select(self, item)
    if self.selected ~= nil then
        self.buttons[self.selected]:UnlockHighlight()
    end
    if type(item) == "number" then
        self.buttons[item]:LockHighlight()
        self.selected = item
    elseif type(item) == "string" then
        for i = 1, #self.buttons do
            if self.buttons[i].name == item then
                self.buttons[i]:LockHighlight()
                self.selected = i
                break
            end
        end
    end
end

local function ListFrame_Deselect(self)
    if self.selected ~= nil then
        self.buttons[self.selected]:UnlockHighlight()
        local selected = self.selected
        self.selected = nil
        return selected
    end
end

local function ListFrame_GetSelected(self)
    return self.selected
end

local function ListFrame_GetButton(self, btn)
    if type(btn) == "string" then
        for i = 1, #self.buttons do
            if self.buttons[i].name == btn then
                return self.buttons[i]
            end
        end
    elseif type(btn) == "number" then
        return self.buttons[btn]
    end
end

local function ListFrame_RemoveItem(self, item)
    if #self.buttons >= item and item > 0 then
        if self:GetSelected() == item then
            self:Deselect()
        elseif self:GetSelected() > item then
            self.selected = self.selected - 1
        end
        for i = item + 1, #self.buttons do
            self.buttons[i]:SetID(i - 1)
        end  
        local btn = table.remove(self.buttons, item)
        btn:SetParent(nil)
        btn:ClearAllPoints()
        btn:Hide()
        table.insert(recycler, btn)
        self:Update()
    end
end

local function ListFrame_Update(self)
    self:SetHeight(self:GetListHeight())
    if #self.buttons > 0 then
        self.buttons[1]:SetPoint("TOPLEFT")
        self.buttons[1]:SetPoint("TOPRIGHT")

        for i = 2, #self.buttons do
            self.buttons[i]:SetPoint("TOPLEFT", self.buttons[i - 1], "BOTTOMLEFT")
            self.buttons[i]:SetPoint("TOPRIGHT", self.buttons[i - 1], "BOTTOMRIGHT")
        end
    end
    self:SetHeight(self:GetListHeight())
end

local function ListFrame_AddItem(self, name)
    assert(type(name) == "string", "Item name must be a 'string' value.")
    local btn = CreateFrame("Button", ("$parent%s"):format(name), self, "OptionsListButtonTemplate")
    btn:Show()
    btn:SetText(name)
    btn:SetScript("OnClick", button_OnClick)
    btn.name = name
    table.insert(self.buttons, btn)
    btn:SetID(#self.buttons)
    if self.GetListHeight ~= nil then
        self:SetHeight(self:GetListHeight())
    end
    self:Update()
    return #self.buttons
end

function ns:CreateListFrame(name, list, parent)
    local frame = CreateFrame("Frame", name, parent)
    frame.buttons = {}
    frame.selected = nil

    frame.GetListHeight = ListFrame_GetListHeight
    frame.GetSelected = ListFrame_GetSelected
    frame.GetButton = ListFrame_GetButton
    frame.Select = ListFrame_Select
    frame.Deselect = ListFrame_Deselect
    frame.AddItem = ListFrame_AddItem
    frame.RemoveItem = ListFrame_RemoveItem
    frame.Update = ListFrame_Update

    if list ~= nil then
        for _, name in pairs(list) do
            ListFrame_AddItem(frame, name)
        end
    end

    return frame
end

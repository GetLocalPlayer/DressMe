local addon, ns = ...


local recycler = {}
local counter = 0
local function nextInt()
    counter = counter + 1
    return counter
end


local function button_OnClick(self)
    self:GetParent():Select(self:GetID())
end


local function ListFrame_SetInsets(self, left, right, top, bottom)
    self.insets.left = left
    self.insets.right = right
    self.insets.top = top
    self.insets.bottom = bottom
    self:Update()
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
        if self.onSelect ~= nil then
            self.onSelect(self, item)
        end
    elseif type(item) == "string" then
        for i = 1, #self.buttons do
            if self.buttons[i]:GetText() == item then
                self.buttons[i]:LockHighlight()
                self.selected = i
                if self.onSelect ~= nil then
                    self.onSelect(self, i)
                end
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


local function ListFrame_Clear(self)
    if self:GetSelected() ~= nil then
        self:Deselect()
    end
    while #self.buttons > 0 do
        local btn = table.remove(self.buttons, #self.buttons)
        btn:SetParent(nil)
        btn:ClearAllPoints()
        btn:Hide()
        btn:SetID(0)
        table.insert(recycler, btn)
    end
    self:Update()
end


local function ListFrame_Update(self)
    self:SetHeight(self:GetListHeight() + self.insets.top + self.insets.bottom)
    if #self.buttons > 0 then
        self.buttons[1]:SetPoint("TOPLEFT", self.insets.left, -self.insets.top)
        self.buttons[1]:SetPoint("TOPRIGHT", -self.insets.right, self.insets.bottom)

        for i = 2, #self.buttons do
            self.buttons[i]:SetPoint("TOPLEFT", self.buttons[i - 1], "BOTTOMLEFT")
            self.buttons[i]:SetPoint("TOPRIGHT", self.buttons[i - 1], "BOTTOMRIGHT")
        end
    end
end


local function ListFrame_AddItem(self, itemName)
    assert(type(itemName) == "string", "Item name must be a 'string' value.")
    local btn = #recycler == 0 and CreateFrame("Button", "ListFrame"..nextInt(), self, "OptionsListButtonTemplate") or table.remove(recycler)
    btn:SetParent(self)
    btn:Show()
    btn:SetText(itemName)
    btn:SetScript("OnClick", button_OnClick)
    btn.name = itemName
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
    frame.insets = {left = 0, right = 0, top = 0, bottom = 0}
    frame.buttons = {}
    frame.selected = nil
    frame.onSelect = nil

    frame.SetInsets = ListFrame_SetInsets
    frame.GetListHeight = ListFrame_GetListHeight
    frame.GetSelected = ListFrame_GetSelected
    frame.GetButton = ListFrame_GetButton
    frame.Select = ListFrame_Select
    frame.Deselect = ListFrame_Deselect
    frame.AddItem = ListFrame_AddItem
    frame.RemoveItem = ListFrame_RemoveItem
    frame.Clear = ListFrame_Clear
    frame.Update = ListFrame_Update

    if list ~= nil then
        for _, name in pairs(list) do
            ListFrame_AddItem(frame, name)
        end
    end

    return frame
end

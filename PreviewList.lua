local addon, ns = ...


local previewBackdrop = { -- small "DressingRoom"s
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
}
local previewBackdropColor = {0.25, 0.25, 0.25, 1}
local previewHighlightTexture = "Interface\\Buttons\\ButtonHilight-Square"


local function subrange(t, first, last)
    local result = {}
    for i = first, last do
        if t[i] then
            table.insert(result, t[i])
        else
            break
        end
    end
    return result
end


local function fillGameTooltip(names, selected)
    GameTooltip:AddLine("This appearance's provided by:", 1, 1, 1)
    GameTooltip:AddLine(" ")
    for i = 1, #names do
        GameTooltip:AddLine((i == selected and "> " or "- ")..names[i])
    end
    GameTooltip:AddLine("|n|cff00ff00Left Click:|r try on the appearance.")
    if #names > 1 then
        GameTooltip:AddLine("|cff00ff00Tab:|r choose an item in the list.")
        GameTooltip:AddLine("|cff00ff00Shift + Left Click:|r create a hyperlink for the chosen item.")
    else
        GameTooltip:AddLine("|cff00ff00Shift + Left Click:|r create a hyperlink for the item.")
    end
    GameTooltip:AddLine("|cff00ff00Ctrl + Left Click:|r create a Wowhead URL for the chosen item.")
end


local function DressingRoom_OnUpdateModel(self)
    self:SetSequence(self:GetParent():GetParent().dressingRoomSetup.sequence)
end


local function button_OnClick(self, button)
    local onItemClick = self:GetParent():GetParent().onItemClick
    if onItemClick ~= nil then
        onItemClick(self, button)
    end
    if button == "LeftButton" then
        PlaySound("gsTitleOptionOK")
    end
end


local function button_OnEnter(self, ...)
    local onEnter = self:GetParent():GetParent().onEnter
    if onEnter ~= nil then
        onEnter(self, ...)
    end
end


local function button_OnLeave(self, ...)
    local onLeave = self:GetParent():GetParent().onLeave
    if onLeave ~= nil then
        onLeave(self, ...)
    end
end


local dressingRoomRecycler = {
    ["recycled"] = {},
    ["counter"] = 0,

    ["get"] = function(self, frame, number)
        local result = {}
        while #result < number do
            if self.recycled[frame] == nil then self.recycled[frame] = {} end
            local recycled = self.recycled[frame]
            if #self.recycled > 0 then
                table.insert(result, table.remove(recycled))
            else
                self.counter = self.counter + 1
                local dr = ns.CreateDressingRoom("$parentDressingRoom"..self.counter, frame)
                dr:SetBackdrop(previewBackdrop)
                dr:SetBackdropColor(unpack(previewBackdropColor))
                dr:EnableDragRotation(false)
                dr:EnableMouseWheel(false)
                dr.queriedLabel = dr:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                dr.queriedLabel:SetJustifyH("LEFT")
                dr.queriedLabel:SetHeight(18)
                dr.queriedLabel:SetPoint("CENTER", dr, "CENTER", 0, 0)
                dr.queriedLabel:SetText("Queried...")
                dr.queriedLabel:Hide()
                dr.queryFailedLabel = dr:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                dr.queryFailedLabel:SetJustifyH("LEFT")
                dr.queryFailedLabel:SetHeight(18)
                dr.queryFailedLabel:SetPoint("CENTER", dr, "CENTER", 0, 0)
                dr.queryFailedLabel:SetText("Query failed")
                dr.queryFailedLabel:Hide()
                dr.queryFailedLabel = dr.queryFailedLabel
                local btn = CreateFrame("Button", "$parent".."Button", dr)
                btn:SetAllPoints()
                btn:SetHighlightTexture(previewHighlightTexture)
                btn:EnableMouse(true)
                btn:RegisterForClicks("LeftButtonUp")
                btn:SetScript("OnEnter", button_OnEnter)
                btn:SetScript("OnLeave", button_OnLeave)
                btn:SetScript("OnClick", button_OnClick)
                dr.button = btn
                table.insert(result, dr)
            end
        end
        return result
    end,

    ["recycle"] = function(self, frame, dr)
        if self.recycled[frame] == nil then self.recycled[frame] = {} end
        local recycled = self.recycled[frame]
        for i=1, #recycled do
            if recycled[i] == dr then return end
        end
        table.insert(recycled, dr)
    end,
}


local function PreviewList_SetItems(self, itemIds)
    table.wipe(self.itemIds)
    for i=1, #itemIds do
        table.insert(self.itemIds, itemIds[i])
    end
    self:SetPage(1)
end


local function PreviewList_SetupModel(self, width, height, x, y, z, facing, sequence)
    self.dressingRoomSetup.width = width
    self.dressingRoomSetup.height = height
    self.dressingRoomSetup.x = x
    self.dressingRoomSetup.y = y
    self.dressingRoomSetup.z = z
    self.dressingRoomSetup.facing = facing
    self.dressingRoomSetup.sequence = sequence
    self:Update()
end


local function PreviewList_SetPage(self, page)
    self.currentPage = page
    self:Update()
end


local function PreviewList_GetPage(self)
    return self.currentPage
end


local function PreviewList_GetPageCount(self)
    local setup = self.dressingRoomSetup
    local width = setup.width > 0 and setup.width or self:GetWidth()
    local height = setup.height and setup.height or self:GetHeight()
    local countW = math.floor(self:GetWidth() / width)
    local countH = math.floor(self:GetHeight() / height)
    return math.ceil(#self.itemIds/(countW * countH))
end


local function PreviewList_Update(self)
    local setup = self.dressingRoomSetup
    local width = setup.width > 0 and setup.width or self:GetWidth()
    local height = setup.height and setup.height or self:GetHeight()
    local x, y, z = setup.x, setup.y, setup.z
    local facing, sequence = setup.facing, setup.sequence
    local countW = math.floor(self:GetWidth() / width)
    local countH = math.floor(self:GetHeight() / height)
    local perPage = countW * countH
    if #self.itemIds > 0 and perPage > 0 then
        if #self.dressingRooms < perPage then
            local list = dressingRoomRecycler:get(self, perPage - #self.dressingRooms)
            while #list > 0 do
                local dr = table.remove(list)
                dr:SetWidth(width)
                dr:SetHeight(height)
                table.insert(self.dressingRooms, dr)
            end
        elseif #self.dressingRooms > perPage then
            while #self.dressingRooms > perPage do
                local dr = table.remove(self.dressingRooms)
                dr:Hide()
                dr:OnUpdateModel(nil)
                dr.itemId = nil
                dressingRoomRecycler:recycle(self, dr)
            end
        end
        local gapW = (self:GetWidth() - countW * width) / 2
        local gapH = (self:GetHeight() - countH * height) / 2
        for h = 1, countH do
            for w = 1, countW do
                local dr = self.dressingRooms[(h - 1) * countW + w]
                dr:SetPoint("TOPLEFT", self, "TOPLEFT", width * (w - 1) + gapW , -height * (h - 1) - gapH)
            end
        end
        for i, dr in ipairs(self.dressingRooms) do
            local index = (self.currentPage - 1) * perPage + i
            local itemId = self.itemIds[index]
            if itemId == nil then
                dr:OnUpdateModel(nil)
                dr:Hide()
            else
                dr.itemId = itemId
                dr:SetWidth(width)
                dr:SetHeight(height)
                dr:Show()
                dr:ClearModel()
                dr.button:Hide()
                dr.queriedLabel:Show()
                dr.queryFailedLabel:Hide()
                ns.QueryItem(itemId, function(queriedItemId, success)
                    if queriedItemId == itemId then
                        dr.queriedLabel:Hide()
                        if success then
                            dr.queryFailedLabel:Hide()
                            dr:Reset()
                            dr:Undress()
                            dr:SetPosition(x, y, z)
                            dr:SetFacing(facing)
                            dr:TryOn(itemId)
                            dr.button:Show()
                            dr:OnUpdateModel(DressingRoom_OnUpdateModel)
                        else
                            dr.queryFailedLabel:Show()
                        end
                    end
                end)
            end
        end
    end
end


function ns.CreatePreviewList(parent)
    local frame = CreateFrame("Frame", addon.."PreviewList", parent)

    frame.itemIds = {}
    frame.dressingRooms = {}
    frame.currenPage = 0
    frame.dressingRoomSetup = {
        ["width"] = 0,
        ["height"] = 0,
        ["x"] = 0.0,
        ["y"] = 0.0,
        ["z"] = 0.0,
        ["facing"] = 0.0,
        ["sequence"] = 0,
    }

    frame.onEnter = nil
    frame.onLeave = nil
    frame.onItemClick = nil

    frame.SetItems = PreviewList_SetItems
    frame.Update = PreviewList_Update
    frame.SetupModel = PreviewList_SetupModel
    frame.GetPage = PreviewList_GetPage
    frame.SetPage = PreviewList_SetPage
    frame.GetPageCount = PreviewList_GetPageCount

    frame:SetScript("OnShow", function(self)
        self:SetPage(self.currentPage)
    end)

    frame:SetScript("OnHide", function(self)
        for i, dr in ipairs(self.dressingRooms) do
            dr:Hide()
        end
    end)

    return frame
end
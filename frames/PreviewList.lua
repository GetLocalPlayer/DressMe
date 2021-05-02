local addon, ns = ...


local itemBackdrop = { -- small "DressingRoom"s
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
}
local itemBackdropColor = {0.25, 0.25, 0.25, 1}
local itemBackdropBorderColor = {1, 1, 1}
local previewHighlightTexture = "Interface\\Buttons\\ButtonHilight-Square"

--[[
    Methods:
        GetPage
        SetPage
        GetPageCount
        SetItems(itemIds) // takes a list of integers
        SetupModel(self, width, height, x, y, z, facing, sequence)
        Update
]]

local function DressingRoom_OnUpdateModel(self)
    self:SetSequence(self:GetParent():GetParent().dressingRoomSetup.sequence)
end


local function button_OnClick(self, button)
    local mainFrame = self:GetParent():GetParent()
    local onItemClick = mainFrame.onItemClick
    mainFrame.selectedItemId = self:GetParent().itemId
    mainFrame.selectedItemIndex = self:GetParent().itemIndex
    if onItemClick ~= nil then
        onItemClick(self, button)
    end
    if button == "LeftButton" then
        PlaySound("gsTitleOptionOK")
    end
end


local function button_OnEnter(self, ...)
    local onEnter = self:GetParent():GetParent().onEnter
    self:GetParent():GetParent().enteredButton = self
    if onEnter ~= nil then
        onEnter(self, ...)
    end
end


local function button_OnLeave(self, ...)
    local onLeave = self:GetParent():GetParent().onLeave
    self:GetParent():GetParent().enteredButton = nil
    if onLeave ~= nil then
        onLeave(self, ...)
    end
end


local dressingRoomRecycler = {
    ["recycled"] = {},
    ["counter"] = 0,

    ["get"] = function(self, parent, number)
        local result = {}
        while #result < number do
            if self.recycled[parent] == nil then self.recycled[parent] = {} end
            local recycled = self.recycled[parent]
            if #self.recycled > 0 then
                table.insert(result, table.remove(recycled))
            else
                self.counter = self.counter + 1
                local dr = ns.CreateDressingRoom("$parentDressingRoom"..self.counter, parent)
                dr:SetBackdrop(itemBackdrop)
                dr:SetBackdropColor(unpack(itemBackdropColor))
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
                table.insert(result, 1, dr)
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
        dr:ClearModel()
        table.insert(recycled, dr)
    end,
}


local function PreviewList_SetItems(self, itemIds)
    table.wipe(self.itemIds)
    for i=1, #itemIds do
        table.insert(self.itemIds, itemIds[i])
    end
    self.selectedItemId = nil
    self.selectedItemIndex = nil
    if self.dressingRoomSetup ~= nil then
        self:Update()
    end
end


local function PreviewList_SetupModel(self, width, height, x, y, z, facing, sequence)
    assert(#self.itemIds > 0, "`SetItemIds` first.")
    self.dressingRoomSetup = {
        ["width"] = width,
        ["height"] = height,
        ["x"] = x,
        ["y"] = y,
        ["z"] = z,
        ["facing"] = facing,
        ["sequence"] = sequence,
    }
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
                dr.itemIndex = nil
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
            dr:SetSize(width, height)
        end
    end
    self:Update()
end


local function PreviewList_SetPage(self, page)
    assert(type(page) == "number", "`page` must be a positive number.")
    self.currentPage = page
    if self.dressingRoomSetup ~= nil then
        self:Update()
    end
end


local function PreviewList_GetPage(self)
    return self.currentPage
end


local function PreviewList_GetPageCount(self)
    if #self.itemIds == 0 or #self.dressingRooms == 0 then
        return 0
    end
    return math.ceil(#self.itemIds/#self.dressingRooms)
end


local function queryItemHandler(functable, itemId, success)
    local queriedItemId = functable.queriedItemId
    local dr = functable.dressingRoom
    if queriedItemId == itemId then
        dr.queriedLabel:Hide()
        if success then
            dr.queriedLabel:Hide()
            dr:Reset()
            dr:Undress()
            local setup = dr:GetParent().dressingRoomSetup
            dr:SetPosition(setup.x, setup.y, setup.z)
            dr:SetFacing(setup.facing)
            dr:TryOn(itemId)
            dr.button:Show()
            dr:OnUpdateModel(DressingRoom_OnUpdateModel)
        else
            dr.queryFailedLabel:Show()
        end
    end
end

local function PreviewList_Update(self)
    assert(self.dressingRoomSetup ~= nil, "`SetupModel` first.")
    assert(#self.itemIds > 0, "`SetItemIds` first.")
    local perPage = #self.dressingRooms
    for i, dr in ipairs(self.dressingRooms) do
        local dr = self.dressingRooms[i]
        local index = (self.currentPage - 1) * perPage + i
        local itemId = self.itemIds[index]
        if itemId == nil then
            dr:OnUpdateModel(nil)
            dr:ClearModel()
            dr:Hide()
        else
            dr.itemId = itemId
            dr.itemIndex = index
            dr:Show()
            dr:ClearModel()
            dr.button:Hide()
            dr.queriedLabel:Show()
            dr.queryFailedLabel:Hide()
            local handler = {
                ["queriedItemId"] = itemId,
                ["dressingRoom"] = dr,
                ["__call"] = queryItemHandler,}
            setmetatable(handler, handler)
            ns.QueryItem(itemId, handler)
        end
    end
end


function ns.CreatePreviewList(parent)
    local frame = CreateFrame("Frame", addon.."PreviewList", parent)

    frame.itemIds = {}
    frame.dressingRooms = {}
    frame.currentPage = 1
    frame.dressingRoomSetup = nil
    --[[
    frame.dressingRoomSetup = {
        ["width"] = 0,
        ["height"] = 0,
        ["x"] = 0.0,
        ["y"] = 0.0,
        ["z"] = 0.0,
        ["facing"] = 0.0,
        ["sequence"] = 0,
    }]]
    frame.onEnter = nil
    frame.onLeave = nil
    frame.onItemClick = nil

    frame.enteredButton = nil -- last button reacted on "OnEnter" event, set to `nil` in "OnLeave" event
    frame.selectedItemId = nil
    frame.selectedItemIndex = nil

    frame.SetItems = PreviewList_SetItems
    frame.Update = PreviewList_Update
    frame.SetupModel = PreviewList_SetupModel
    frame.GetPage = PreviewList_GetPage
    frame.SetPage = PreviewList_SetPage
    frame.GetPageCount = PreviewList_GetPageCount

    frame:SetScript("OnShow", function(self)
        if self.dressingRoomSetup ~= nil then
            self:Update()
        end
    end)

    return frame
end
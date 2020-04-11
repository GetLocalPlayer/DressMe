local addon, ns = ...


local previewBackdrop = { -- small "DressingRoom"s
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
}
--[[ local previewBackdropSelected = {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\AddOns\\DressMe\\images\\ui-tooltip-border-selected",
	tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
} ]]
local previewBackdropColor = {["r"] = 0.25, ["g"] = 0.25, ["b"] = 0.25, ["a"] = 1}
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


local tooltip = CreateFrame("GameTooltip", nil, UIParent)
local function queryItem(itemId)
    tooltip:SetHyperlink("item:".. tostring(itemId) ..":0:0:0:0:0:0:0")
end


local function btn_OnEnter(self)
    local data = self:GetParent().appereanceData
    self:EnableKeyboard(true)
    self.highlight:Show()
    self.focused = true
    self.selectedItem = 1
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:AddLine("Next items provide this appearance:", 1, 1, 1)
    local names = self:GetParent().appereanceData[2]
    GameTooltip:AddLine(" > " .. names[1])
    for i = 2, #names do
        GameTooltip:AddLine("- " .. names[i])
    end
    GameTooltip:Show()
end

local function btn_OnLeave(self)
    self:EnableKeyboard(false)
    self.highlight:Hide()
    self.focused = false
    GameTooltip:Hide()
end

local function btn_OnKeyDown(self, key)
    if self.focused and key == "TAB" then
        local data = self:GetParent().appereanceData
        local names = data[2]
        self.selectedItem = self.selectedItem + 1
        if self.selectedItem > #names then
            self.selectedItem = 1
        end
        GameTooltip:ClearLines()
        GameTooltip:AddLine("Next items provide this appearance:", 1, 1, 1)
        for i = 1, #names do
            local prefix = self.selectedItem == i and " > " or "- "
            GameTooltip:AddLine(prefix .. names[i])
        end
    end
end

function ns:CreatePreviewList(parent)
    local frame = CreateFrame("Frame", nil, parent)
    local previewRecycler = {}
    local previewList = {}
    local itemList = nil
    local perPage = 0
    local pageCount = 0
    local currentPage = 0
    local onClickScript

    function frame:Update(previewSetup, items, page)
        local width, height = previewSetup.width, previewSetup.height
        local x, y, z = previewSetup.x, previewSetup.y, previewSetup.z
        local facing, sequence = previewSetup.facing, previewSetup.sequence
        local countW = math.floor(frame:GetWidth() / width)
        local countH = math.floor(frame:GetHeight() / height)
        perPage = countW * countH
        if perPage < #previewList then
            for i = perPage + 1, #previewList do
                local preview = table.remove(previewList)
                preview:OnUpdateModel(nil)
                preview:Hide()
                table.insert(previewRecycler, preview)
            end
        else
            for i = #previewList + 1, perPage do
                local preview = table.remove(previewRecycler)
                if preview == nil then
                    preview = ns:CreateDressingRoom(frame)
                    preview:SetBackdrop(previewBackdrop)
                    preview:SetBackdropColor(previewBackdropColor.r, previewBackdropColor.g, previewBackdropColor.b, previewBackdropColor.a)
                    preview:EnableDragRotation(false)
                    preview:EnableMouseWheel(false)
                    preview.button = CreateFrame("Button", nil, preview)
                    local btn = preview.button
                    btn:SetAllPoints()
                    btn.highlight = preview:CreateTexture(nil, "OVERLAY")
                    btn.highlight:SetTexture(previewHighlightTexture)
                    btn.highlight:SetBlendMode("ADD")
                    btn.highlight:SetAllPoints()
                    btn.highlight:Hide()
                    btn:EnableMouse(true)
                    btn:RegisterForClicks("LeftButtonUp")
                    btn:SetScript("OnEnter", btn_OnEnter)
                    btn:SetScript("OnLeave", btn_OnLeave)
                    btn:SetScript("OnClick", function(self)
                        if onClickScript ~= nil then
                            local ids, names = {}, {}
                            for i = 1, #preview.appereanceData[1] do
                                table.insert(ids, preview.appereanceData[1][i])
                                table.insert(names, preview.appereanceData[2][i])
                            end
                            onClickScript(frame, ids, names, btn.selectedItem)
                        end
                    end)
                    btn:SetScript("OnKeyDown", btn_OnKeyDown)
                else
                    preview:Show()
                end
                table.insert(previewList, preview)
            end
        end
        for i = 1, #previewList do
            local preview = previewList[i]
            preview:SetSize(width, height)
            preview:SetPosition(x, y, z)
            preview:SetFacing(facing)
            preview:OnUpdateModel(function(self) self:SetSequence(sequence) end)
            preview:Hide()
        end
        local gapW = (frame:GetWidth() - countW * width) / 2
        local gapH = (frame:GetHeight() - countH * height) / 2
        for h = 1, countH do
            for w = 1, countW do
                local preview = previewList[(h - 1) * countW + w]
                preview:SetPoint("TOPLEFT", width * (w - 1) + gapW , -height * (h - 1) - gapH)
            end
        end
        itemList = items
        pageCount = math.floor(#items / perPage)
        if pageCount < #items / perPage then pageCount = pageCount + 1 end
        if page ~= nil and page > 0 and page <= pageCount then
            frame:SetPage(page)
        else
            frame:SetPage(1)
        end
    end

    function frame:GetPage()
        return currentPage
    end

    function frame:GetPageCount()
        return pageCount
    end

    function frame:SetPage(page)
        currentPage = page
        for i = 1, perPage do
            local preview = previewList[i]
            local data = itemList[(page - 1) * perPage + i]
            if data then
                local itemId = data[1][1]
                local itemName = GetItemInfo(itemId)
                if not itemName then
                    queryItem(itemId)
                end
                preview.appereanceData = data
                preview:Show()
                preview:Reset()
                preview:Undress()
                preview:TryOn(itemId)
            else
                preview:Hide()
            end
        end
    end

    function frame:OnClick(script)
        assert(type(script) == "function", "Usage: <Unnamed>:OnClick(function)")
        onClickScript = script
    end

    frame:SetScript("OnShow", function(self)
        self:SetPage(currentPage)
    end)

    return frame
end
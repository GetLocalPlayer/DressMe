local addon, ns = ...


local previewBackdrop = { -- small "DressingRoom"s
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
}
local previewBackdropColor = {["r"] = 0.25, ["g"] = 0.25, ["b"] = 0.25, ["a"] = 1}
local previewBorderColor = {["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1}
local previewBorderColorSelected = {["r"] = 0.75, ["g"] = 0.75, ["b"] = 1, ["a"] = 1}
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


local function queryItem(itemId)
    GameTooltip:SetHyperlink("item:".. tostring(itemId) ..":0:0:0:0:0:0:0")
end


local function preview_OnEnter(self)
    if self.ready then
        local data = self.data
        self.highlight:Show()
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:AddLine("asdfsdfsdf", 1, 1, 1)
        GameTooltip:Show()
    end
end


local function preview_OnLeave(self)
    self.highlight:Hide()
    GameTooltip:Hide()
end


function ns:CreatePreviewList(parent)
    local frame = CreateFrame("Frame", nil, parent)
    local previewRecycler = {}
    local previewList = {}
    local itemList = nil
    local perPage = 0
    local pageCount = 0
    local currentPage = 0

    function frame:Update(previewSetup, items)
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
                preview:SetScript("OnUpdate", nil)
                preview:HideQueryText()
                table.insert(previewRecycler, preview)
            end
        else
            for i = #previewList + 1, perPage do
                local preview = table.remove(previewRecycler)
                if preview == nil then
                    preview = ns:CreateDressingRoom(frame)
                    preview:SetBackdrop(previewBackdrop)
                    preview:SetBackdropColor(previewBackdropColor.r, previewBackdropColor.g, previewBackdropColor.b, previewBackdropColor.a)
                    preview:SetBackdropBorderColor(previewBorderColor.r, previewBorderColor.g, previewBorderColor.b, previewBorderColor.a)
                    preview:EnableDragRotation(false)
                    preview:EnableMouseWheel(false)
                    preview.highlight = preview:CreateTexture(nil, "OVERLAY")
                    preview.highlight:SetTexture(previewHighlightTexture)
                    preview.highlight:SetBlendMode("ADD")
                    preview.highlight:SetAllPoints()
                    preview.highlight:Hide()
                    preview:EnableMouse(true)
                    preview:SetScript("OnEnter", preview_OnEnter)
                    preview:SetScript("OnLeave", preview_OnLeave)
                    preview.ready = false
                    local queryText = preview:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    queryText:SetPoint("LEFT")
                    queryText:SetPoint("RIGHT")
                    queryText:SetJustifyH("CENTER")
                    queryText:SetHeight(15)
                    queryText:SetText("querying...")
                    queryText:Hide()
                    function preview:ShowQueryText() queryText:Show() end
                    function preview:HideQueryText() queryText:Hide() end
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
            preview:SetScript("OnUpdate", nil)
            preview:HideQueryText()
            preview:Hide()
        end
        local gapW = (frame:GetWidth() - countW * width) / (countW + 1)
        local gapH = (frame:GetHeight() - countH * height) / (countH + 1)
        for h = 1, countH do
            for w = 1, countW do
                local preview = previewList[(h - 1) * countW + w]
                preview:SetPoint("TOPLEFT", width * (w - 1) + gapW * w , -height * (h - 1) - gapH * h)
            end
        end
        itemList = items
        pageCount = math.floor(#items / perPage)
        if pageCount < #items / perPage then pageCount = pageCount + 1 end
        frame:SetPage(1)
    end

    function frame:GetPage()
        return currentPage
    end

    function frame:GetPagesCount()
        return pageCount
    end

    function frame:SetPage(page)
        for i = 1, perPage do
            local preview = previewList[i]
            local data = itemList[(page - 1) * perPage + i]
            if data then
                local itemId = data[1][1]
                local itemName = GetItemInfo(itemId)
                if not itemName then
                    queryItem(itemId)
                end
                preview:Show()
                preview:Reset()
                preview:Undress()
                preview:TryOn(itemId)
            else
                preview:Hide()
            end
        end
    end

    frame:SetScript("OnShow", function(self) self:SetPage(currentPage) end)

    return frame
end
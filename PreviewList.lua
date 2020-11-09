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


local onTabDummy = CreateFrame("Button", addon.."PreviewListOnTabDummy")
onTabDummy:SetScript("OnClick", function(self)
    local preview = self.preview
    local names = preview.appereanceData[2]
    preview.selected = preview.selected < #names and (preview.selected + 1) or 1
    GameTooltip:SetOwner(preview, "ANCHOR_TOPLEFT")
    GameTooltip:ClearLines()
    fillGameTooltip(names, preview.selected)
    GameTooltip:Show()
end)


local function btn_OnEnter(self)
    local preview = self:GetParent()
    local names = preview.appereanceData[2]
    preview.selected = 1
    GameTooltip:SetOwner(preview, "ANCHOR_TOPLEFT")
    GameTooltip:ClearLines()
    fillGameTooltip(names, preview.selected)
    GameTooltip:Show()
    if #names> 1 then
        onTabDummy.preview = preview
        SetOverrideBindingClick(onTabDummy, true, "TAB", onTabDummy:GetName(), "RightButton")
    end
end


local function btn_OnLeave(self)
    ClearOverrideBindings(onTabDummy)
    GameTooltip:Hide()
end


local function btn_OnClick(self, button)
    local mainFrame = self:GetParent():GetParent()
    mainFrame.OnButtonClick(self, button)
    if button == "LeftButton" then
        PlaySound("gsTitleOptionOK")
    end
end


local function preview_GetSelectedItemId(self)
    return self.appereanceData[1][self.selected]
end


function ns:CreatePreviewList(parent)
    local frame = CreateFrame("Frame", addon.."PreviewList", parent)
    local previewRecycler = {}
    local recyclerCounter = 0
    local previewList = {}
    local itemList = nil
    local perPage = 0
    local pageCount = 0
    local currentPage = 0
    -- Updates the list of previews
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
                    recyclerCounter = recyclerCounter + 1
                    preview = ns:CreateDressingRoom("$parent".."Preview"..recyclerCounter, frame)
                    preview:SetBackdrop(previewBackdrop)
                    preview:SetBackdropColor(unpack(previewBackdropColor))
                    preview:EnableDragRotation(false)
                    preview:EnableMouseWheel(false)
                    preview.selected = 0

                    preview.queriedLabel = preview:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    preview.queriedLabel:SetJustifyH("LEFT")
                    preview.queriedLabel:SetHeight(18)
                    preview.queriedLabel:SetPoint("CENTER", preview, "CENTER", 0, 0)
                    preview.queriedLabel:SetText("Queried...")
                    preview.queriedLabel:Hide()

                    preview.queryFailedLabel = preview:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    preview.queryFailedLabel:SetJustifyH("LEFT")
                    preview.queryFailedLabel:SetHeight(18)
                    preview.queryFailedLabel:SetPoint("CENTER", preview, "CENTER", 0, 0)
                    preview.queryFailedLabel:SetText("Query failed")
                    preview.queryFailedLabel:Hide()

                    preview.GetSelectedItemId = preview_GetSelectedItemId

                    preview.button = CreateFrame("Button", "$parent".."Button"..recyclerCounter, preview)
                    local btn = preview.button
                    btn:SetAllPoints()
                    btn:SetHighlightTexture(previewHighlightTexture)
                    btn:EnableMouse(true)
                    btn:RegisterForClicks("LeftButtonUp")
                    btn:SetScript("OnEnter", btn_OnEnter)
                    btn:SetScript("OnLeave", btn_OnLeave)
                    btn:SetScript("OnClick", btn_OnClick)
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
                preview.appereanceData = data
                preview.queriedItemId = data[1][1]
                preview:Show()
                preview.modelFacing = preview:GetFacing()
                preview.modelPosition = {preview:GetPosition()}
                preview:ClearModel()
                preview.button:Hide()
                preview.queriedLabel:Show()
                preview.queryFailedLabel:Hide()
                ns:QueryItem(preview.queriedItemId, function(itemId, success)
                    if itemId == preview.queriedItemId then
                        preview.queriedLabel:Hide()
                        if success then
                            preview.queryFailedLabel:Hide()
                            preview:Reset()
                            preview:Undress()
                            preview:SetPosition(unpack(preview.modelPosition))
                            preview:SetFacing(preview.modelFacing)
                            preview:TryOn(itemId)
                            preview.queriedItemId = nil
                            preview.modelPosition = nil
                            preview.modelFacing = nil
                            preview.button:Show()
                        else
                            preview.queryFailedLabel:Show()
                        end
                    end
                end)
            else
                preview:Hide()
            end
        end
    end

    function frame:OnButtonClick(script)
        assert(type(script) == "function", "Usage: <Unnamed>:OnClick(function)")
        self.OnButtonClick = script
    end

    frame:SetScript("OnShow", function(self)
        self:SetPage(currentPage)
    end)

    return frame
end
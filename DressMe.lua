local addon, ns = ...

local sex = UnitSex("player")
local race, raceFileName = UnitRace("player")
local items = ns:GetItemsData()
local cameraPresets = ns:GetCameraPresets().modern[raceFileName][sex]

local backdrop = {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = false, tileSize = 16, edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
}
local backdropColor = {["r"] = 0, ["g"] = 0, ["b"] = 0, ["a"] = 0.666666}

local dressingRoomBorderBackdrop = { -- For a frame above DressingRoom
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\AddOns\\DressMe\\images\\mirror-border",
	tile = false, tileSize = 16, edgeSize = 32,
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
}

local subclassListBackdrop = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
	tile = false, edgeSize = 8, tileSize = 8,
}
local subclassListBackdropColor = {["r"] = 0, ["g"] = 0, ["b"] = 0, ["a"] = 0.8}
local subclassListBorderColor = {["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1}

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

local tooltipBackdrop = { -- small "DressingRoom"s
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
}
local tooltipBackdropColor = {["r"] = 0.1, ["g"] = 0.1, ["b"] = 0.1, ["a"] = 75}

local mainFrame = CreateFrame("Frame", nil, UIParent)
mainFrame:SetPoint("CENTER")
mainFrame:SetSize(1182, 502)
mainFrame:SetMovable(true)
mainFrame:SetFrameStrata("FULLSCREEN_DIALOG")
mainFrame:SetBackdrop(backdrop)
mainFrame:SetBackdropColor(backdropColor.r, backdropColor.g, backdropColor.b, backdropColor.a)
mainFrame:EnableMouse(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
mainFrame:Hide()

local btnClose = CreateFrame("Button", "DressMeButtonClose", mainFrame, "UIPanelButtonTemplate2")
btnClose:SetSize(120, 20)
btnClose:SetPoint("BOTTOMRIGHT", -16, 16)
btnClose:SetText(CLOSE)
btnClose:SetScript("OnClick", function() mainFrame:Hide() end)

local titleFrame = CreateFrame("Frame", nil, mainFrame)
titleFrame:EnableMouse(true)
titleFrame:RegisterForDrag("LeftButton")
titleFrame:SetScript("OnDragStart", function() mainFrame:StartMoving() end)
titleFrame:SetScript("OnDragStop", function () mainFrame:StopMovingOrSizing() end)

local titleBg = titleFrame:CreateTexture(nil, "OVERLAY")
titleBg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
titleBg:SetTexCoord(0.31, 0.67, 0, 0.63)
titleBg:SetPoint("TOP", mainFrame, "TOP", 0, 16)
titleBg:SetWidth(65)
titleBg:SetHeight(40)

local titleBgLeft = titleFrame:CreateTexture(nil, "OVERLAY")
titleBgLeft:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
titleBgLeft:SetTexCoord(0.21, 0.31, 0, 0.63)
titleBgLeft:SetPoint("RIGHT", titleBg, "LEFT")
titleBgLeft:SetWidth(30)
titleBgLeft:SetHeight(40)

local titleBgRight = titleFrame:CreateTexture(nil, "OVERLAY")
titleBgRight:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
titleBgRight:SetTexCoord(0.67, 0.77, 0, 0.63)
titleBgRight:SetPoint("LEFT", titleBg, "RIGHT")
titleBgRight:SetWidth(30)
titleBgRight:SetHeight(40)

local titleText = titleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
titleText:SetPoint("TOP", titleBg, "TOP", 0, -14)
titleText:SetText("DressMe")

titleFrame:SetPoint("BOTTOMLEFT", titleBgLeft, "BOTTOMLEFT")
titleFrame:SetPoint("TOPRIGHT", titleBgRight, "TOPRIGHT")

local dressingRoom = ns:CreateDressingRoom(mainFrame)
dressingRoom:SetPoint("TOPLEFT", 16, -56)
dressingRoom:SetSize(400, 400)
dressingRoom:SetBackdrop(backdrop)
dressingRoom:SetBackdropColor(0, 0, 0, 1)
dressingRoom:SetScript("OnShow", function(self)
    -- Need to reset the model at least once or it will be either not shown or shown wrong.
    self:Reset()
    self:SetScript("OnShow", nil)
end)

local dressingRoomBorder = CreateFrame("Frame", nil, dressingRoom)
dressingRoomBorder:SetAllPoints()
dressingRoomBorder:SetBackdrop(dressingRoomBorderBackdrop)
dressingRoomBorder:SetBackdropColor(0, 0, 0, 0)

local btnUndress = CreateFrame("Button", "DressMeButtonUndress", mainFrame, "UIPanelButtonTemplate2")
btnUndress:SetSize(120, 20)
btnUndress:SetPoint("RIGHT", dressingRoom, "BOTTOMRIGHT", -20, -20)
btnUndress:SetText("Undress")
btnUndress:SetScript("OnClick", function()
    dressingRoom:Undress()
    local slotID = GetInventorySlotInfo("SHOULDERSLOT")
    local itemLink = GetInventoryItemLink("player", slotID)
    local _, link = GetItemInfo(itemLink)
    dressingRoom:TryOn(link)
end)

local btnReset = CreateFrame("Button", "DressMeButtonReset", mainFrame, "UIPanelButtonTemplate2")
btnReset:SetSize(120, 20)
btnReset:SetPoint("LEFT", dressingRoom, "BOTTOMLEFT", 20, -20)
btnReset:SetText("Reset")
btnReset:SetScript("OnClick", function() dressingRoom:Reset() end)

---------------- PREVIEW LIST ----------------

local previewListFrame = CreateFrame("Frame", nil, mainFrame)
previewListFrame:SetPoint("TOPLEFT", dressingRoom, "TOPRIGHT")
previewListFrame:SetSize(630, 401)

do
    local previewRecycler = {}
    local previewList = {}

    local label = previewListFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOP", previewListFrame, "BOTTOM")
    label:SetJustifyH("CENTER")
    label:SetHeight(15)

    local slider = CreateFrame("Slider", "DressMePageSlider", previewListFrame, "UIPanelScrollBarTemplateLightBorder")
    slider:SetPoint("TOP", previewListFrame, "TOPRIGHT", -15, -20)
    slider:SetHeight(dressingRoom:GetHeight() - 40)
    slider:SetScript("OnValueChanged", nil)
    slider:SetMinMaxValues(1, 10)
    slider:SetValueStep(1)
    slider:SetValue(1)
    _G[slider:GetName() .. "ScrollUpButton"]:SetScript("OnClick", function(self)
        local parent = self:GetParent()
        parent:SetValue(parent:GetValue() - 1)
    end)
    _G[slider:GetName() .. "ScrollDownButton"]:SetScript("OnClick", function(self)
        local parent = self:GetParent()
        parent:SetValue(parent:GetValue() + 1)
    end)

    local book = {}
    --[[ example:
        book[items] = {
            ["pages"] = {{items}, {items}, {items}...},
            ["current"], -- current page
            ["selected"] = {page = int, index = int},
        }
    ]]

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

    function previewListFrame:Update(cameraPreset, items)
        local width, height = cameraPreset.width, cameraPreset.height
        local x, y, z = cameraPreset.x, cameraPreset.y, cameraPreset.z
        local facing, sequence = cameraPreset.facing, cameraPreset.sequence
        local countW = math.floor(previewListFrame:GetWidth() / width)
        local countH = math.floor(previewListFrame:GetHeight() / height)
        local perPage = countW * countH
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
                    preview = ns:CreateDressingRoom(previewListFrame)
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
        end
        for h = 1, countH do
            for w = 1, countW do
                local preview = previewList[(h - 1) * countW + w]
                local hOffset = (previewListFrame:GetHeight() - countH * height) / 2
                preview:SetPoint("BOTTOMRIGHT", previewListFrame, "TOPLEFT", width * w, -h * height - hOffset)
            end
        end

        -- Items
        if not book[items] then
            local pages = {}
            for i = 1, #items, perPage do
                table.insert(pages, subrange(items, i, i + perPage - 1))
            end
            if #pages * perPage < #items then
                table.insert(pages, subrange(items, #pages * perPage, #items))
            end
            book[items] = {}
            book[items].pages = pages
            book[items].current = 1
            book[items].selected = nil
        end
        local pages = book[items].pages
        slider:SetMinMaxValues(1, #pages)
        slider:SetScript("OnValueChanged", function(self, value)
            for i = 1, #previewList do
                local current = pages[value]
                local preview = previewList[i]
                preview:HideQueryText()
                preview:SetScript("OnUpdate", nil)
                preview.ready = false
                local data = current[i]
                if data then
                    preview:Show()
                    preview:Reset()
                    preview:Undress()
                    local itemId = data[1][1]
                    local itemName = GetItemInfo(itemId)
                    if itemName ~= nil then
                        preview:TryOn(data[1][1])
                        preview.ready = true
                    else
                        preview:ShowQueryText()
                        preview:SetScript("OnUpdate", function(self)
                            preview:Undress()
                            preview:TryOn(itemId)
                            local itemName = GetItemInfo(itemId)
                            if itemName then
                                preview:SetScript("OnUpdate", nil)
                                preview:HideQueryText()
                                preview.data = data
                                preview.ready = true
                            end
                        end)
                    end
                else
                    preview:Hide()
                end
                book[items].current = value
            end
            label:SetText(string.format("%u/%u", value, #pages))
        end)
        if slider:GetValue() ~= book[items].current then
            slider:SetValue(book[items].current)
        else
            slider:GetScript("OnValueChanged")(slider, book[items].current) 
        end
        slider:SetScript("OnShow", function(self)
            self:GetScript("OnValueChanged")(self, book[items].current)
        end)
    end
end

---------------- SLOTS ----------------

local slots = {["Selected"] = nil}

local slotTextures = {
    ["Head"] =      "Interface\\Paperdoll\\ui-paperdoll-slot-head",
    ["Shoulder"] =  "Interface\\Paperdoll\\ui-paperdoll-slot-shoulder",
    ["Back"] =      "Interface\\Paperdoll\\ui-paperdoll-slot-chest",
    ["Chest"] =     "Interface\\Paperdoll\\ui-paperdoll-slot-chest",
    ["Shirt"] =     "Interface\\Paperdoll\\ui-paperdoll-slot-shirt",
    ["Tabard"] =     "Interface\\Paperdoll\\ui-paperdoll-slot-tabard",
    ["Wrist"] =     "Interface\\Paperdoll\\ui-paperdoll-slot-wrists",
    ["Gloves"] =    "Interface\\Paperdoll\\ui-paperdoll-slot-hands",
    ["Waist"] =     "Interface\\Paperdoll\\ui-paperdoll-slot-waist",
    ["Legs"] =      "Interface\\Paperdoll\\ui-paperdoll-slot-legs",
    ["Feet"] =      "Interface\\Paperdoll\\ui-paperdoll-slot-feet",
    ["Main Hand"] = "Interface\\Paperdoll\\ui-paperdoll-slot-mainhand",
    ["Off-hand"] =  "Interface\\Paperdoll\\ui-paperdoll-slot-secondaryhand",
    ["Ranged"] =    "Interface\\Paperdoll\\ui-paperdoll-slot-ranged",
}

function string:startswith(...)
    local array = {...}
    for i = 1, #array do
        assert(type(array[i]) == "string", "string:startswith argument type error - a list of strings is required")
        if self:sub(1, array[i]:len()) == array[i] then
            return true
        end
    end
    return  false
end

local function slot_OnClick(self)
    if slots["Selected"] then
        slots["Selected"]:UnlockHighlight()
        slots["Selected"].subclassFrame:Hide()
    end
    slots["Selected"] = self
    slots["Selected"]:LockHighlight()
    self.subclassFrame:Show()
    self.subclassFrame.buttons["Selected"]:Click("LeftButton")
end

for slotName, texturePath in pairs(slotTextures) do
   slots[slotName] = CreateFrame("Button", nil, mainFrame, "ItemButtonTemplate")
   slots[slotName]:SetFrameLevel(dressingRoom:GetFrameLevel() + 1)
   slots[slotName]:SetScript("OnClick", slot_OnClick)
   slots[slotName].slot = slotName
   local texture = slots[slotName]:CreateTexture(nil, "ARTWORK")
   texture:SetTexture(texturePath)
   texture:SetAllPoints()
end

-- At first time it's shown.
slots["Head"]:SetScript("OnShow", function(self)
    self:Click("LeftButton")
    self:SetScript("OnShow", nil)
end)

slots["Head"]:SetPoint("TOPLEFT", dressingRoom, "TOPLEFT", 16, -16)
slots["Shoulder"]:SetPoint("TOP", slots["Head"], "BOTTOM", 0, -4)
slots["Back"]:SetPoint("TOP", slots["Shoulder"], "BOTTOM", 0, -4)
slots["Chest"]:SetPoint("TOP", slots["Back"], "BOTTOM", 0, -4)
slots["Shirt"]:SetPoint("TOP", slots["Chest"], "BOTTOM", 0, -36)
slots["Tabard"]:SetPoint("TOP", slots["Shirt"], "BOTTOM", 0, -4)
slots["Wrist"]:SetPoint("TOP", slots["Tabard"], "BOTTOM", 0, -36)
slots["Gloves"]:SetPoint("TOPRIGHT", dressingRoom, "TOPRIGHT", -16, -16)
slots["Waist"]:SetPoint("TOP", slots["Gloves"], "BOTTOM", 0, -4)
slots["Legs"]:SetPoint("TOP", slots["Waist"], "BOTTOM", 0, -4)
slots["Feet"]:SetPoint("TOP", slots["Legs"], "BOTTOM", 0, -4)
slots["Off-hand"]:SetPoint("BOTTOM", dressingRoom, "BOTTOM", 0, 16)
slots["Main Hand"]:SetPoint("RIGHT", slots["Off-hand"], "LEFT", -4, 0)
slots["Ranged"]:SetPoint("LEFT", slots["Off-hand"], "RIGHT", 4, 0)

local armorSlots = {"Head", "Shoulder", "Chest", "Wrist", "Gloves", "Waist", "Legs", "Feet"}
local backSlot = "Back"
local miscellaneousSlots = {"Tabard", "Shirt"}
local mhSlot = "Main Hand"
local ohSlot = "Off-hand"
local rangedSlot = "Ranged"

---------------- SBUCLASS FRAMES ----------------

do
    local subclassBackgroudFrame = CreateFrame("Frame", nil, mainFrame)
    subclassBackgroudFrame:SetPoint("TOPLEFT", previewListFrame, "TOPRIGHT")
    subclassBackgroudFrame:SetPoint("Right", -16, 0)
    subclassBackgroudFrame:SetHeight(400)
    subclassBackgroudFrame:SetBackdrop(subclassListBackdrop)
    subclassBackgroudFrame:SetBackdropColor(subclassListBackdropColor.r, subclassListBackdropColor.g, subclassListBackdropColor.b, subclassListBackdropColor.a)
    subclassBackgroudFrame:SetBackdropBorderColor(subclassListBorderColor.r, subclassListBorderColor.g, subclassListBorderColor.b, subclassListBorderColor.a)

    local armorSubclassFrame = CreateFrame("Frame", nil, subclassBackgroudFrame)
    armorSubclassFrame:SetPoint("TOPLEFT", subclassListBackdrop.edgeSize, -subclassListBackdrop.edgeSize)
    armorSubclassFrame:SetPoint("BOTTOMRIGHT", -subclassListBackdrop.edgeSize, subclassListBackdrop.edgeSize)
    armorSubclassFrame:Hide()
    for _, v in pairs(armorSlots) do
        slots[v].subclassFrame = armorSubclassFrame
    end
    armorSubclassFrame:Hide()

    slots[backSlot].subclassFrame =  CreateFrame("Frame", nil, subclassBackgroudFrame)
    slots[backSlot].subclassFrame:SetAllPoints(armorSubclassFrame)
    slots[backSlot].subclassFrame:Hide()

    local miscelleneosSubclassFrame = CreateFrame("Frame", nil, subclassBackgroudFrame)
    miscelleneosSubclassFrame:SetAllPoints(armorSubclassFrame)
    miscelleneosSubclassFrame:Hide()
    for _, v in pairs(miscellaneousSlots) do
        slots[v].subclassFrame = miscelleneosSubclassFrame
    end
    miscelleneosSubclassFrame:Hide()

    slots[mhSlot].subclassFrame =  CreateFrame("Frame", nil, subclassBackgroudFrame)
    slots[mhSlot].subclassFrame:SetAllPoints(armorSubclassFrame)
    slots[mhSlot].subclassFrame:Hide()

    slots[ohSlot].subclassFrame =  CreateFrame("Frame", nil, subclassBackgroudFrame)
    slots[ohSlot].subclassFrame:SetAllPoints(armorSubclassFrame)
    slots[ohSlot].subclassFrame:Hide()

    slots[rangedSlot].subclassFrame = CreateFrame("Frame", nil, subclassBackgroudFrame)
    slots[rangedSlot].subclassFrame:SetAllPoints(armorSubclassFrame)
    slots[rangedSlot].subclassFrame:Hide()
end

---------------- ARMOR SUBCLASS LIST ----------------
do
    local subclassOrder = {"Cloth", "Leather", "Mail", "Plate"}
    local subclassFrame = slots[armorSlots[1]].subclassFrame
    subclassFrame.buttons = {}

    local function btn_OnClick(self)
        local selectedButton = self:GetParent().buttons["Selected"]
        if selectedButton then
            selectedButton:UnlockHighlight()
        end
        self:LockHighlight()
        self:GetParent().buttons["Selected"] = self
        previewListFrame:Update(cameraPresets["Armor"][slots["Selected"].slot], items["Armor"][slots["Selected"].slot][self.subclass])
    end

    for _, subclass in pairs(subclassOrder) do
        local btn = CreateFrame("Button", ("DressMeButtonSubclass%s"):format(subclass), subclassFrame, "OptionsListButtonTemplate")
        btn:SetText("|cffffffff" .. subclass .. FONT_COLOR_CODE_CLOSE)
        btn:SetScript("OnClick",btn_OnClick)
        btn:GetParent().buttons[subclass] = btn
        btn.subclass = subclass
    end
    
    subclassFrame.buttons[subclassOrder[1]]:SetPoint("TOPLEFT")
    subclassFrame.buttons[subclassOrder[1]]:SetPoint("TOPRIGHT")
    for i = 2, #subclassOrder do
        local current = subclassFrame.buttons[subclassOrder[i]]
        local previous = subclassFrame.buttons[subclassOrder[i - 1]]
        current:SetPoint("TOPLEFT", previous, "BOTTOMLEFT")
        current:SetPoint("TOPRIGHT", previous, "BOTTOMRIGHT")
    end

    -- Classes and what they wear to select it by default.
    local subclassPerPlayerClass = {
        MAGE = "Cloth",
        PRIEST = "Cloth",
        WARLOCK = "Cloth",
        DRUID = "Leather",
        ROGUE = "Leather",
        HUNTER = "Mail",
        SHAMAN = "Mail",
        PALADIN = "Plate",
        WARRIOR = "Plate",
        DEATHKNIGHT = "Plate"
    }
    local className, classFileName = UnitClass("player")
    subclassFrame.buttons["Selected"] = subclassFrame.buttons[subclassPerPlayerClass[classFileName]]
end

---------------- ARMOR BACK SUBCLASS LIST ----------------

do
    local subclassFrame = slots[backSlot].subclassFrame
    local subclass = "Cloth"
  
    local btn = CreateFrame("Button", ("DressMeButtonSlot%sSubclass%s"):format(backSlot, subclass), subclassFrame, "OptionsListButtonTemplate")
    btn:SetPoint("TOPLEFT")
    btn:SetPoint("TOPRIGHT")
    btn:SetText("|cffffffff" .. subclass .. FONT_COLOR_CODE_CLOSE)
    btn:SetScript("OnClick", function(self)
        previewListFrame:Update(cameraPresets["Armor"][slots["Selected"].slot], items["Armor"][slots["Selected"].slot][self.subclass])
    end)
    btn:LockHighlight()
    btn.subclass = subclass
    subclassFrame.buttons = {}
    subclassFrame.buttons[subclass] = btn
    subclassFrame.buttons["Selected"] = btn
end

---------------- ARMOR TABARD/SHIRT LIST ----------------
do
    local subclassFrame = slots[miscellaneousSlots[1]].subclassFrame
    local subclass = "Miscellaneous"    

    local btn = CreateFrame("Button", ("DressMeButtonSlotTabardShirtSubclass%s"):format(subclass), subclassFrame, "OptionsListButtonTemplate")
    btn:SetPoint("TOPLEFT")
    btn:SetPoint("TOPRIGHT")
    btn:SetText("|cffffffff" .. subclass .. FONT_COLOR_CODE_CLOSE)
    btn:SetScript("OnClick", function(self)
        previewListFrame:Update(cameraPresets["Armor"][slots["Selected"].slot], items["Armor"][slots["Selected"].slot][self.subclass])
    end)
    btn:LockHighlight()
    btn.subclass = subclass
    subclassFrame.buttons = {}
    subclassFrame.buttons[subclass] = btn
    subclassFrame.buttons["Selected"] = btn
end

---------------- MAIN HAND SUBCLASS LIST ----------------

do
    local subclassOrder = {
        "1H Axe", "1H Mace", "1H Sword", "1H Dagger", "1H Fist",
        "MH Axe", "MH Mace", "MH Sword", "MH Dagger", "MH Fist",
        "2H Axe", "2H Mace", "2H Sword", "Polearm", "Staff"
    }
    local subclassFrame = slots[mhSlot].subclassFrame
    subclassFrame.buttons = {}

    local function btn_OnClick(self)
        local selectedButton = self:GetParent().buttons["Selected"]
        if selectedButton then
            selectedButton:UnlockHighlight()
        end
        self:LockHighlight()
        self:GetParent().buttons["Selected"] = self
        local presetSubcategory = self.subclass:startswith("MH", "1H") and self.subclass:sub(4) or self.subclass
        previewListFrame:Update(cameraPresets[slots["Selected"].slot][presetSubcategory], items[slots["Selected"].slot][self.subclass])
    end

    for _, subclass in pairs(subclassOrder) do
        local btn = CreateFrame("Button", ("DressMeButtonSubclass%s"):format(subclass), subclassFrame, "OptionsListButtonTemplate")
        btn:SetText("|cffffffff" .. subclass .. FONT_COLOR_CODE_CLOSE)
        btn:SetScript("OnClick",btn_OnClick)
        btn:GetParent().buttons[subclass] = btn
        btn.subclass = subclass
    end
    
    subclassFrame.buttons[subclassOrder[1]]:SetPoint("TOPLEFT")
    subclassFrame.buttons[subclassOrder[1]]:SetPoint("TOPRIGHT")
    for i = 2, #subclassOrder do
        local current = subclassFrame.buttons[subclassOrder[i]]
        local previous = subclassFrame.buttons[subclassOrder[i - 1]]
        current:SetPoint("TOPLEFT", previous, "BOTTOMLEFT")
        current:SetPoint("TOPRIGHT", previous, "BOTTOMRIGHT")
    end

    subclassFrame.buttons["Selected"] = subclassFrame.buttons[subclassOrder[1]]
end

---------------- OFF HAND SUBCLASS LIST ----------------

do
    local subclassOrder = {
        -- "1H Axe", "1H Mace", "1H Sword", "1H Dagger", "1H Fist",
        "OH Axe", "OH Mace", "OH Sword", "OH Dagger", "OH Fist",
        "Shield", "Held in Off-hand"
    }
    local subclassFrame = slots[ohSlot].subclassFrame
    subclassFrame.buttons = {}

    local function btn_OnClick(self)
        local selectedButton = self:GetParent().buttons["Selected"]
        if selectedButton then
            selectedButton:UnlockHighlight()
        end
        self:LockHighlight()
        self:GetParent().buttons["Selected"] = self
        local presetSubcategory = self.subclass:startswith("OH", "1H") and self.subclass:sub(4) or self.subclass
        previewListFrame:Update(cameraPresets[slots["Selected"].slot][presetSubcategory], items[slots["Selected"].slot][self.subclass])
    end

    for _, subclass in pairs(subclassOrder) do
        local btn = CreateFrame("Button", ("DressMeButtonSubclass%s"):format(subclass), subclassFrame, "OptionsListButtonTemplate")
        btn:SetText("|cffffffff" .. subclass .. FONT_COLOR_CODE_CLOSE)
        btn:SetScript("OnClick",btn_OnClick)
        btn:GetParent().buttons[subclass] = btn
        btn.subclass = subclass
    end
    
    subclassFrame.buttons[subclassOrder[1]]:SetPoint("TOPLEFT")
    subclassFrame.buttons[subclassOrder[1]]:SetPoint("TOPRIGHT")
    for i = 2, #subclassOrder do
        local current = subclassFrame.buttons[subclassOrder[i]]
        local previous = subclassFrame.buttons[subclassOrder[i - 1]]
        current:SetPoint("TOPLEFT", previous, "BOTTOMLEFT")
        current:SetPoint("TOPRIGHT", previous, "BOTTOMRIGHT")
    end

    subclassFrame.buttons["Selected"] = subclassFrame.buttons[subclassOrder[1]]
end

---------------- RANGED SUBCLASS LIST ----------------

do
    local subclassOrder = {"Bow", "Crossbow", "Gun", "Wand", "Thrown"}
    local subclassFrame = slots[rangedSlot].subclassFrame
    subclassFrame.buttons = {}

    local function btn_OnClick(self)
        local selectedButton = self:GetParent().buttons["Selected"]
        if selectedButton then
            selectedButton:UnlockHighlight()
        end
        self:LockHighlight()
        self:GetParent().buttons["Selected"] = self
        local presetSubcategory = self.subclass
        previewListFrame:Update(cameraPresets[slots["Selected"].slot][presetSubcategory], items[slots["Selected"].slot][self.subclass])
    end

    for _, subclass in pairs(subclassOrder) do
        local btn = CreateFrame("Button", ("DressMeButtonSubclass%s"):format(subclass), subclassFrame, "OptionsListButtonTemplate")
        btn:SetText("|cffffffff" .. subclass .. FONT_COLOR_CODE_CLOSE)
        btn:SetScript("OnClick",btn_OnClick)
        btn:GetParent().buttons[subclass] = btn
        btn.subclass = subclass
    end
    
    subclassFrame.buttons[subclassOrder[1]]:SetPoint("TOPLEFT")
    subclassFrame.buttons[subclassOrder[1]]:SetPoint("TOPRIGHT")
    for i = 2, #subclassOrder do
        local current = subclassFrame.buttons[subclassOrder[i]]
        local previous = subclassFrame.buttons[subclassOrder[i - 1]]
        current:SetPoint("TOPLEFT", previous, "BOTTOMLEFT")
        current:SetPoint("TOPRIGHT", previous, "BOTTOMRIGHT")
    end

    subclassFrame.buttons["Selected"] = subclassFrame.buttons[subclassOrder[1]]
end

SLASH_DRESSME1 = "/dressme"

SlashCmdList["DRESSME"] = function(msg)
    if msg == "" then
        if mainFrame:IsShown() then mainFrame:Hide() else mainFrame:Show() end
    elseif msg == "debug" then
        if dressingRoom:IsDebugInfoShown() then dressingRoom:HideDebugInfo() else dressingRoom:ShowDebugInfo() end
    end
end

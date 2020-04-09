local addon, ns = ...

local sex = UnitSex("player")
local race, raceFileName = UnitRace("player")
local itemsData = ns:GetItemsData()
local previewSetup = ns:GetPreviewSetup().modern[raceFileName][sex]

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

local previewList = ns:CreatePreviewList(mainFrame)
previewList:SetPoint("TOPLEFT", dressingRoom, "TOPRIGHT")
previewList:SetSize(601, 401)

local previewListLabel = previewList:CreateFontString(nil, "OVERLAY", "GameFontNormal")
previewListLabel:SetPoint("TOP", previewList, "BOTTOM")
previewListLabel:SetJustifyH("CENTER")
previewListLabel:SetHeight(15)

local previewSlider = CreateFrame("Slider", "DressMePageSlider", previewList, "UIPanelScrollBarTemplateLightBorder")
previewSlider:SetPoint("LEFT", previewList, "RIGHT", 4, 0)
previewSlider:SetHeight(previewList:GetHeight() - 48)
previewSlider:SetScript("OnValueChanged", nil)
previewSlider:SetMinMaxValues(1, 10)
previewSlider:SetValueStep(1)
previewSlider:SetValue(1)
_G[previewSlider:GetName() .. "ScrollUpButton"]:SetScript("OnClick", function(self)
    local parent = self:GetParent()
    parent:SetValue(parent:GetValue() - 1)
end)
_G[previewSlider:GetName() .. "ScrollDownButton"]:SetScript("OnClick", function(self)
    local parent = self:GetParent()
    parent:SetValue(parent:GetValue() + 1)
end)

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
    subclassBackgroudFrame:SetPoint("TOPLEFT", previewList, "TOPRIGHT")
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
        previewList:Update(previewSetup["Armor"][slots["Selected"].slot], itemsData["Armor"][slots["Selected"].slot][self.subclass])
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
        previewList:Update(previewSetup["Armor"][slots["Selected"].slot], itemsData["Armor"][slots["Selected"].slot][self.subclass])
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
        previewList:Update(previewSetup["Armor"][slots["Selected"].slot], itemsData["Armor"][slots["Selected"].slot][self.subclass])
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
        previewList:Update(previewSetup[slots["Selected"].slot][presetSubcategory], itemsData[slots["Selected"].slot][self.subclass])
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
        previewList:Update(previewSetup[slots["Selected"].slot][presetSubcategory], itemsData[slots["Selected"].slot][self.subclass])
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
        previewList:Update(previewSetup[slots["Selected"].slot][presetSubcategory], itemsData[slots["Selected"].slot][self.subclass])
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

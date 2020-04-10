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

local mainFrame = CreateFrame("Frame", addon, UIParent)
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

local btnClose = CreateFrame("Button", "$parentButtonClose", mainFrame, "UIPanelButtonTemplate2")
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
titleText:SetText("$parent")

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

local btnUndress = CreateFrame("Button", "$parentButtonUndress", mainFrame, "UIPanelButtonTemplate2")
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

local btnReset = CreateFrame("Button", "$parentButtonReset", mainFrame, "UIPanelButtonTemplate2")
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

local previewSlider = CreateFrame("Slider", "$parentPageSlider", previewList, "UIPanelScrollBarTemplateLightBorder")
previewSlider:SetPoint("LEFT", previewList, "RIGHT", 4, 0)
previewSlider:SetHeight(previewList:GetHeight() - 48)
previewSlider:SetScript("OnValueChanged", function(self, value)
    previewList:SetPage(value)
    local _, max = self:GetMinMaxValues()
    previewListLabel:SetText(("%s/%s"):format(value, max))
end)
previewSlider:SetScript("OnMinMaxChanged", function(self, min, max)
    previewListLabel:SetText(("%s/%s"):format(self:GetValue(), max))
end)
previewSlider:SetMinMaxValues(0, 0)
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

local slots = {}
local selectedSlot = nil

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

local function slot_OnClick(self)
    if selectedSlot ~= nil then
        selectedSlot:UnlockHighlight()
        selectedSlot.subclassList:Hide()
        selectedSlot.selectedPage[selectedSlot.selectedSubclass] = previewSlider:GetValue()
    end
    selectedSlot = self
    self:LockHighlight()
    self.subclassList:Show()
    self.subclassList.buttons[self.selectedSubclass]:Click("LeftButton")
end

local function slot_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:SetText(self.slotName)
    GameTooltip:Show()
end

local function slot_OnLeave(self)
    GameTooltip:Hide()
end

for slotName, texturePath in pairs(slotTextures) do
    local slot = CreateFrame("Button", nil, mainFrame, "ItemButtonTemplate")
    slot:SetFrameLevel(dressingRoom:GetFrameLevel() + 1)
    slot:SetScript("OnClick", slot_OnClick)
    slot:SetScript("OnEnter", slot_OnEnter)
    slot:SetScript("OnLeave", slot_OnLeave)
    slot.slotName = slotName
    slot.selectedSubclass = nil -- init later in subclass
    slot.selectedPage = {} -- per subclass, filled later in subclass
    slot.selectedPreview = 0
    slot.subclassList = nil -- init later in subclss
    slots[slotName] = slot
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

function string:startswith(...)
    local array = {...}
    for i = 1, #array do
        assert(type(array[i]) == "string", "string:startswith(\"...\") - argument type error, string is required")
        if self:sub(1, array[i]:len()) == array[i] then
            return true
        end
    end
    return  false
end

local function subclass_OnClick(self)
    local name = selectedSlot.slotName
    local subclass = self:GetListName()
    local page = selectedSlot.selectedPage[subclass]
    if previewSetup["Armor"][name] then
        previewList:Update(previewSetup["Armor"][name], itemsData["Armor"][name][subclass], page)
    else
        local previewSubclass = subclass:startswith("OH", "MH", "1H") and subclass:sub(4) or subclass
        previewList:Update(previewSetup[name][previewSubclass], itemsData[name][subclass], page)
    end
    selectedSlot.selectedPage[selectedSlot.selectedSubclass] = previewSlider:GetValue()
    selectedSlot.selectedSubclass = subclass
    previewSlider:SetMinMaxValues(1, previewList:GetPageCount())
    previewSlider:SetValue(page)
    print(subclass, page)
end

---------------- ARMOR ----------------

do
    local subclasses = {"Cloth", "Leather", "Mail", "Plate"}
    local list = ns:CreateListFrame("TestList", subclasses, mainFrame)
    list:SetPoint("TOPLEFT", previewList, "TOPRIGHT", previewSlider:GetWidth() + 16, 0)
    list:SetPoint("RIGHT", mainFrame, "RIGHT", -16, 0)
    list:Hide()

    for name, btn in pairs(list.buttons) do
        btn:HookScript("OnClick", subclass_OnClick)
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

    for _, name in pairs(armorSlots) do
        slots[name].subclassList = list
        slots[name].selectedSubclass = subclassPerPlayerClass[classFileName]
        for _, subclass in pairs(subclasses) do
            slots[name].selectedPage[subclass] = 1
        end
    end
end

---------------- BACK ----------------
do
    local subclass = "Cloth"
    local list = ns:CreateListFrame("TestList", {subclass}, mainFrame)
    list:SetPoint("TOPLEFT", previewList, "TOPRIGHT", previewSlider:GetWidth() + 16, 0)
    list:SetPoint("RIGHT", mainFrame, "RIGHT", -16, 0)
    list:Hide()
    list.buttons[subclass]:HookScript("OnClick", subclass_OnClick)
    slots[backSlot].subclassList = list
    slots[backSlot].selectedSubclass = subclass
    slots[backSlot].selectedPage[subclass] = 1
end

---------------- SHIRT / TABARD ----------------

do
    local subclass = "Miscellaneous"
    local list = ns:CreateListFrame("TestList", {subclass}, mainFrame)
    list:SetPoint("TOPLEFT", previewList, "TOPRIGHT", previewSlider:GetWidth() + 16, 0)
    list:SetPoint("RIGHT", mainFrame, "RIGHT", -16, 0)
    list:Hide()
    list.buttons[subclass]:HookScript("OnClick", subclass_OnClick)
    for _, name in pairs(miscellaneousSlots) do
        slots[name].subclassList = list
        slots[name].selectedSubclass = subclass
        slots[name].selectedPage[subclass] = 1
    end
end

---------------- MAIN HAND ----------------

do
    local subclasses = {
        "1H Axe", "1H Mace", "1H Sword", "1H Dagger", "1H Fist",
        "MH Axe", "MH Mace", "MH Sword", "MH Dagger", "MH Fist",
        "2H Axe", "2H Mace", "2H Sword", "Polearm", "Staff"
    }
    local list = ns:CreateListFrame("TestList", subclasses, mainFrame)
    list:SetPoint("TOPLEFT", previewList, "TOPRIGHT", previewSlider:GetWidth() + 16, 0)
    list:SetPoint("RIGHT", mainFrame, "RIGHT", -16, 0)
    list:Hide()

    for name, btn in pairs(list.buttons) do
        btn:HookScript("OnClick", subclass_OnClick)
    end
    slots[mhSlot].subclassList = list
    slots[mhSlot].selectedSubclass = subclasses[1]
    for _, subclass in pairs(subclasses) do
        slots[mhSlot].selectedPage[subclass] = 1
    end
end

---------------- OFF-HAND ----------------

do
    local subclasses = {
        -- "1H Axe", "1H Mace", "1H Sword", "1H Dagger", "1H Fist",
        "OH Axe", "OH Mace", "OH Sword", "OH Dagger", "OH Fist",
        "Shield", "Held in Off-hand"
    }
    local list = ns:CreateListFrame("TestList", subclasses, mainFrame)
    list:SetPoint("TOPLEFT", previewList, "TOPRIGHT", previewSlider:GetWidth() + 16, 0)
    list:SetPoint("RIGHT", mainFrame, "RIGHT", -16, 0)
    list:Hide()

    for name, btn in pairs(list.buttons) do
        btn:HookScript("OnClick", subclass_OnClick)
    end
    slots[ohSlot].subclassList = list
    slots[ohSlot].selectedSubclass = subclasses[1]
    for _, subclass in pairs(subclasses) do
        slots[ohSlot].selectedPage[subclass] = 1
    end
end

---------------- RANGED ----------------

do
    local subclasses = {"Bow", "Crossbow", "Gun", "Wand", "Thrown"}
    local list = ns:CreateListFrame("TestList", subclasses, mainFrame)
    list:SetPoint("TOPLEFT", previewList, "TOPRIGHT", previewSlider:GetWidth() + 16, 0)
    list:SetPoint("RIGHT", mainFrame, "RIGHT", -16, 0)
    list:Hide()

    for name, btn in pairs(list.buttons) do
        btn:HookScript("OnClick", subclass_OnClick)
    end
    slots[rangedSlot].subclassList = list
    slots[rangedSlot].selectedSubclass = subclasses[1]
    for _, subclass in pairs(subclasses) do
        slots[rangedSlot].selectedPage[subclass] = 1
    end
end

SLASH_DRESSME1 = "/dressme"

SlashCmdList["DRESSME"] = function(msg)
    if msg == "" then
        if mainFrame:IsShown() then mainFrame:Hide() else mainFrame:Show() end
    elseif msg == "debug" then
        if dressingRoom:IsDebugInfoShown() then dressingRoom:HideDebugInfo() else dressingRoom:ShowDebugInfo() end
    end
end

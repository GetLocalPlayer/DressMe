local addon, ns = ...

local sex = UnitSex("player")
local race, raceFileName = UnitRace("player")
local itemsData = ns:GetItemsData()
local previewSetup = ns:GetPreviewSetup().modern[raceFileName][sex]

local colors = { -- per quality
    [0] = "ff9d9d9d",
    [1] = "ffffffff",
    [2] = "ff1eff00",
    [3] = "ff0070dd",
    [4] = "ffa335ee",
    [5] = "ffff8000",
    [6] = "ffe6cc80",
}

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
-- Hurry up! You must hack the main frame!
-- <hackerman noises>
mainFrame:SetPoint("CENTER")
mainFrame:SetSize(1182, 502)
mainFrame:SetMovable(true)
mainFrame:SetFrameStrata("HIGH")
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
titleText:SetText(addon)

titleFrame:SetPoint("BOTTOMLEFT", titleBgLeft, "BOTTOMLEFT")
titleFrame:SetPoint("TOPRIGHT", titleBgRight, "TOPRIGHT")

local dressingRoom = ns:CreateDressingRoom(mainFrame, true)
dressingRoom:SetPoint("TOPLEFT", 16, -56)
dressingRoom:SetSize(400, 400)
dressingRoom:SetBackdrop(backdrop)
dressingRoom:SetBackdropColor(0.055, 0.055, 0.055, 1)

do
    local dressingRoomBorder = CreateFrame("Frame", nil, dressingRoom)
    dressingRoomBorder:SetAllPoints()
    dressingRoomBorder:SetBackdrop(dressingRoomBorderBackdrop)
    dressingRoomBorder:SetBackdropColor(0, 0, 0, 0)

    local tip = dressingRoom:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tip:SetPoint("BOTTOM", dressingRoom, "TOP", 0, 8)
    tip:SetJustifyH("CENTER")
    tip:SetJustifyV("BOTTOM")
    tip:SetText("\124cff00ff00Left Mouse:\124r rotate \124 \124cff00ff00Right Mouse:\124r pan\124n\124cff00ff00Wheel:\124r zoom")
end

local btnUndress = CreateFrame("Button", "$parentButtonUndress", mainFrame, "UIPanelButtonTemplate2")
btnUndress:SetSize(120, 20)
btnUndress:SetPoint("RIGHT", dressingRoom, "BOTTOMRIGHT", -20, -20)
btnUndress:SetText("Undress")
btnUndress:SetScript("OnClick", function()
    dressingRoom:Undress()
end)

local btnReset = CreateFrame("Button", "$parentButtonReset", mainFrame, "UIPanelButtonTemplate2")
btnReset:SetSize(120, 20)
btnReset:SetPoint("LEFT", dressingRoom, "BOTTOMLEFT", 20, -20)
btnReset:SetText("Reset")
btnReset:SetScript("OnClick", function()
    dressingRoom:Reset()
end)

---------------- TABS ----------------

local tabFrame = CreateFrame("Frame", "$parentTabFrame", mainFrame)
tabFrame:SetPoint("TOPLEFT", dressingRoom, "TOPRIGHT")
tabFrame:SetPoint("BOTTOMRIGHT", -16, -16)
tabFrame.content = {}

do
    local function tab_OnClick(self)
        local selectedTab = PanelTemplates_GetSelectedTab(self:GetParent())
        local content = self:GetParent().content[selectedTab]
        if content ~= nil then
            content:Hide()
        end
        PanelTemplates_SetTab(self:GetParent(), self:GetID())
        self:GetParent().content[self:GetID()]:Show()
    end

    local tabNames = {"Items Preview", "Saved Looks"}

    for i = 1, #tabNames do
        local tab = CreateFrame("Button", "$parentTab"..i, tabFrame, "OptionsFrameTabButtonTemplate")
        tab:SetText(tabNames[i])
        tab:SetID(i)
        if i == 1 then
            tab:SetPoint("BOTTOMLEFT", tab:GetParent(), "TOPLEFT")
        else
            tab:SetPoint("LEFT", _G[tabFrame:GetName().."Tab"..(i - 1)], "RIGHT")
        end
        tab:SetScript("OnClick", tab_OnClick)

        local tabContent = CreateFrame("Frame", "$parentTab"..i.."Content", tabFrame)
        tabContent:SetAllPoints()
        tabContent:Hide()
        table.insert(tabFrame.content, tabContent)
    end
    
    PanelTemplates_SetNumTabs(tabFrame, #tabNames)
    tab_OnClick(_G[tabFrame:GetName().."Tab1"])
end

local previewTabContent = tabFrame.content[1]
local savedLooksTabContent = tabFrame.content[2]

---------------- PREVIEW LIST ----------------

local previewList = ns:CreatePreviewList(previewTabContent)
previewList:SetPoint("TOPLEFT")
previewList:SetSize(601, 401)

local previewListLabel = previewList:CreateFontString(nil, "OVERLAY", "GameFontNormal")
previewListLabel:SetPoint("TOP", previewList, "BOTTOM")
previewListLabel:SetJustifyH("CENTER")
previewListLabel:SetHeight(15)

local previewSlider = CreateFrame("Slider", "$parentPageSlider", previewTabContent, "UIPanelScrollBarTemplateLightBorder")
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
    ["Tabard"] =    "Interface\\Paperdoll\\ui-paperdoll-slot-tabard",
    ["Wrist"] =     "Interface\\Paperdoll\\ui-paperdoll-slot-wrists",
    ["Hands"] =     "Interface\\Paperdoll\\ui-paperdoll-slot-hands",
    ["Waist"] =     "Interface\\Paperdoll\\ui-paperdoll-slot-waist",
    ["Legs"] =      "Interface\\Paperdoll\\ui-paperdoll-slot-legs",
    ["Feet"] =      "Interface\\Paperdoll\\ui-paperdoll-slot-feet",
    ["Main Hand"] = "Interface\\Paperdoll\\ui-paperdoll-slot-mainhand",
    ["Off-hand"] =  "Interface\\Paperdoll\\ui-paperdoll-slot-secondaryhand",
    ["Ranged"] =    "Interface\\Paperdoll\\ui-paperdoll-slot-ranged",
}

local armorSlots = {"Head", "Shoulder", "Chest", "Wrist", "Hands", "Waist", "Legs", "Feet"}
local backSlot = "Back"
local miscellaneousSlots = {"Tabard", "Shirt"}
local mhSlot = "Main Hand"
local ohSlot = "Off-hand"
local rangedSlot = "Ranged"


local function hasValue(array, value)
    for i = 1, #array do
        if array[i] == value then
            return i
        end
    end
    return nil
end

local function slot_OnShiftLeftCick(self)
    local itemId = self.appearance.itemId
    local itemName = self.appearance.itemName
    if itemId ~= nil then
        local slotName = self.slotName
        if itemsData[slotName] == nil then
            for subclassName, sbuclassData in pairs(itemsData["Armor"][slotName]) do
                for _, data in pairs(sbuclassData) do
                    local index = hasValue(data[1], itemId)                
                    if index then
                        local color = itemName:sub(1, 10)
                        local name = itemName:sub(11, -3)
                        SELECTED_CHAT_FRAME:AddMessage("[DressMe]: "..self.slotName.." - "..subclassName.." "..color.."\124Hitem:"..itemId..":::::::|h["..name.."]\124h\124r".." ("..itemId..")")
                        return
                    end
                end
            end
        else
            for subclassName, sbuclassData in pairs(itemsData[slotName]) do
                for _, data in pairs(sbuclassData) do
                    local index = hasValue(data[1], itemId)                
                    if index then
                        local color = itemName:sub(1, 10)
                        local name = itemName:sub(11, -3)
                        SELECTED_CHAT_FRAME:AddMessage("[DressMe]: "..self.slotName.." - "..subclassName.." "..color.."\124Hitem:"..itemId..":::::::|h["..name.."]\124h\124r".." ("..itemId..")")
                        return
                    end
                end
            end
        end
    end
end


local function slot_OnLeftCick(self)
    if selectedSlot ~= nil then
        selectedSlot:UnlockHighlight()
        selectedSlot.subclassList:Hide()
        selectedSlot.selectedPage[selectedSlot.selectedSubclass] = previewSlider:GetValue()
    end
    selectedSlot = self
    self:LockHighlight()
    self.subclassList:Show()
    self.subclassList:Select(self.selectedSubclass)
    local slotName = self.slotName
    local subclass = self.selectedSubclass
    local page = self.selectedPage[subclass]
    if previewSetup[slotName] == nil then
        previewList:Update(previewSetup["Armor"][slotName], itemsData["Armor"][slotName][subclass])
    else
        local previewSubclass = subclass:startswith("OH", "MH", "1H") and subclass:sub(4) or subclass
        previewList:Update(previewSetup[slotName][previewSubclass], itemsData[slotName][subclass])
    end
    previewSlider:SetMinMaxValues(1, previewList:GetPageCount())
    if previewSlider:GetValue() ~= page then
        previewSlider:SetValue(page)
    else
        previewSlider:GetScript("OnValueChanged")(previewSlider, page)
    end
    -- Need to reTryOn weapon for proper look.
    if hasValue({mhSlot, ohSlot, rangedSlot}, self.slotName) then
        if self.appearance.shownItemId ~= nil then
            dressingRoom:TryOn(self.appearance.shownItemId)
        end
    end
end

local function slot_OnRightClick(self)
    self:Undress()
end

local function slot_OnClick(self, button)
    if button == "LeftButton" then
        if IsShiftKeyDown() then
            slot_OnShiftLeftCick(self)
        else
            slot_OnLeftCick(self)
        end
    elseif button == "RightButton" then
        slot_OnRightClick(self)
    end
end

local function slot_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:AddLine(self.slotName)
    if self.appearance.itemName ~= nil then
        GameTooltip:AddLine(self.appearance.itemName)
        GameTooltip:AddLine("|n|cff00ff00Shift + Left Click:|r create a hyperlink for the item.")
        GameTooltip:AddLine("|cff00ff00Right Click:|r undress the slot.")
    end
    GameTooltip:Show()
end

local function slot_OnLeave(self)
    GameTooltip:Hide()
end

local function slot_Reset(self)
    local slotName = self.slotName
    if slotName == mhSlot       then slotName = "MainHand"      end
    if slotName == ohSlot       then slotName = "SecondaryHand" end
    if slotName == rangedSlot   then slotName = "Ranged"        end
    if slotName == backSlot     then slotName = "Back"        end
    local slotId = GetInventorySlotInfo(slotName.."Slot")
    local itemId = GetInventoryItemID("player", slotId)
    local name, link, quality, _, _, _, _, _, _, texture = GetItemInfo(itemId ~= nil and itemId or 0)
    self.appearance.defaultItemId = itemId
    self.appearance.shownItemId = itemId
    self.appearance.itemId = itemId
    if name ~= nil then
        self.appearance.itemName = "\124c"..colors[quality]..name.."\124r"
        self.textures.empty:Hide()
        self.textures.item:Show()
        self.textures.item:SetTexture(texture)
    else
        self.appearance.itemName = nil
        self.textures.empty:Show()
        self.textures.item:Hide()
    end
end

local function slot_Undress(self)
    if self.appearance.itemId ~= nil then
        self.appearance.itemId = nil
        self.appearance.itemName = nil
        self.appearance.shownItemId = nil
        self.textures.empty:Show()
        self.textures.item:Hide()
        self:GetScript("OnEnter")(self)
        --[[ Undress only current slot. In lack of 
        the game's API we're undressing the whole
        model and dress it again but without the
        current slot. ]]
        dressingRoom:Undress()
        for _, slot in pairs(slots) do
            if slot ~= self then
                if slot.appearance.shownItemId ~= nil then
                    dressingRoom:TryOn(slot.appearance.shownItemId)
                end
            end
        end
    end
end

local function slot_TryOn(self, itemId, shownItemId, name)
    if not (shownItemId or name) then
        -- Don't query, find in the database.
        local db = itemsData["Armor"][self.slotName] ~= nil and itemsData["Armor"][self.slotName] or itemsData[self.slotName]
        for _, subclass in pairs(db) do
            for _, data in pairs(subclass) do
                local index = hasValue(data[1], itemId)
                if index then
                    shownItemId = data[1][1]
                    name = data[2][index]
                end
            end
        end
    end
    local _, link, quality, _, _, _, _, _, _, texture = GetItemInfo(shownItemId)
    self.textures.empty:Hide()
    self.textures.item:SetTexture(texture)
    self.textures.item:Show()
    self.appearance.itemId = itemId
    self.appearance.itemName = name
    self.appearance.shownItemId = shownItemId
    dressingRoom:TryOn(shownItemId)
end

for slotName, texturePath in pairs(slotTextures) do
    local slot = CreateFrame("Button", nil, mainFrame, "ItemButtonTemplate")
    slot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    slot:SetFrameLevel(dressingRoom:GetFrameLevel() + 1)
    slot:SetScript("OnClick", slot_OnClick)
    slot:SetScript("OnEnter", slot_OnEnter)
    slot:SetScript("OnLeave", slot_OnLeave)
    slot.slotName = slotName
    slot.selectedSubclass = nil -- init later in subclass
    slot.selectedPage = {}      -- per subclass, filled later in subclass
    slot.subclassList = nil     -- init later in subclss
    slot.appearance = {         -- assigned when a preview's clicked. Used to save in collection.
        ["itemId"] = nil,
        ["itemName"] = nil,
        ["shownItemId"] = nil,      -- To avoid overquerying, we TryOn only the first
                                    -- item from according preview.
        ["defaultItemId"] = nil,    -- Used when we right-click to undress the slot.
                                    -- The character's current equipement is assigned
                                    -- on first "OnShow", on each "Reset", and on each.
                                    -- "Undress". 'nil' on each "Undress"
    } 
    slots[slotName] = slot
    slot.textures = {}
    slot.textures.empty = slot:CreateTexture(nil, "BACKGROUND")
    slot.textures.empty:SetTexture(texturePath)
    slot.textures.empty:SetAllPoints()
    slot.textures.item = slot:CreateTexture(nil, "BACKGROUND")
    slot.textures.item:SetAllPoints()
    slot.textures.item:Hide()
    slot.Reset = slot_Reset
    slot.TryOn = slot_TryOn
    slot.Undress = slot_Undress
end

slots["Head"]:SetPoint("TOPLEFT", dressingRoom, "TOPLEFT", 16, -16)
slots["Shoulder"]:SetPoint("TOP", slots["Head"], "BOTTOM", 0, -4)
slots["Back"]:SetPoint("TOP", slots["Shoulder"], "BOTTOM", 0, -4)
slots["Chest"]:SetPoint("TOP", slots["Back"], "BOTTOM", 0, -4)
slots["Shirt"]:SetPoint("TOP", slots["Chest"], "BOTTOM", 0, -36)
slots["Tabard"]:SetPoint("TOP", slots["Shirt"], "BOTTOM", 0, -4)
slots["Wrist"]:SetPoint("TOP", slots["Tabard"], "BOTTOM", 0, -36)
slots["Hands"]:SetPoint("TOPRIGHT", dressingRoom, "TOPRIGHT", -16, -16)
slots["Waist"]:SetPoint("TOP", slots["Hands"], "BOTTOM", 0, -4)
slots["Legs"]:SetPoint("TOP", slots["Waist"], "BOTTOM", 0, -4)
slots["Feet"]:SetPoint("TOP", slots["Legs"], "BOTTOM", 0, -4)
slots["Off-hand"]:SetPoint("BOTTOM", dressingRoom, "BOTTOM", 0, 16)
slots["Main Hand"]:SetPoint("RIGHT", slots["Off-hand"], "LEFT", -4, 0)
slots["Ranged"]:SetPoint("LEFT", slots["Off-hand"], "RIGHT", 4, 0)

------- Tricks and hooks with slots and provided appearances. -------

local function btnReset_Hook()
    for _, slot in pairs(slots) do
        slot:Reset()
    end
end

local function btnUndress_Hook()
    for _, slot in pairs(slots) do
        slot.appearance.itemId = nil
        slot.appearance.itemName = nil
        slot.appearance.shownItemId = nil
        slot.appearance.defaultItemId = nil
        slot.textures.empty:Show()
        slot.textures.item:Hide()
    end
end

--[[
    Have to reTryOn selected appearances since
    the model's reset each time it's shown.
]]
local function dressingRoom_OnShowHook(self)
    self:Reset()
    self:Undress()
    for _, slot in pairs(slots) do
        if slot.appearance.shownItemId ~= nil then
            self:TryOn(slot.appearance.shownItemId)
        end
    end
end

-- At first time it's shown.
slots["Head"]:SetScript("OnShow", function(self)
    self:Click("LeftButton")
    self:SetScript("OnShow", nil)
    dressingRoom:Reset()
    btnReset_Hook()
    btnReset:HookScript("OnClick", btnReset_Hook)
    dressingRoom:HookScript("OnShow", dressingRoom_OnShowHook)
    btnUndress:HookScript("OnClick", btnUndress_Hook)
end)

---------------- PREVIEW LIST SCRIPT ----------------

do
    local tooltip = CreateFrame("GameTooltip", nil, UIParent)
    tooltip:Hide()

    previewList:OnClick(function(self, ids, names, selected)
        local _, link, quality, _, _, _, _, _, _, texture = GetItemInfo(ids[1])
        if not IsShiftKeyDown() then
            selectedSlot:TryOn(ids[selected], ids[1],  names[selected])
        else
            local color = names[selected]:sub(1, 10)
            local name = names[selected]:sub(11, -3)
            SELECTED_CHAT_FRAME:AddMessage("[DressMe]: "..selectedSlot.slotName.." - "..selectedSlot.selectedSubclass.." "..color.."\124Hitem:"..ids[selected]..":::::::|h["..name.."]\124h\124r".." ("..ids[selected]..")")
        end
    end)
end

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
    selectedSlot.selectedPage[selectedSlot.selectedSubclass] = previewSlider:GetValue()

    local slotName = selectedSlot.slotName
    local subclass = self.name
    local page = selectedSlot.selectedPage[subclass]
    if previewSetup["Armor"][slotName] then
        previewList:Update(previewSetup["Armor"][slotName], itemsData["Armor"][slotName][subclass], page)
    else
        local previewSubclass = subclass:startswith("OH", "MH", "1H") and subclass:sub(4) or subclass
        previewList:Update(previewSetup[slotName][previewSubclass], itemsData[slotName][subclass], page)
    end
    selectedSlot.selectedSubclass = subclass
    previewSlider:SetMinMaxValues(1, previewList:GetPageCount())
    if previewSlider:GetValue() ~= page then
        previewSlider:SetValue(page)
    else
        previewSlider:GetScript("OnValueChanged")(previewSlider, page)
    end
end

---------------- ARMOR ----------------

do
    local subclasses = {"Cloth", "Leather", "Mail", "Plate"}
    local list = ns:CreateListFrame("ArmorList", subclasses, previewTabContent)
    list:SetPoint("TOPLEFT", previewList, "TOPRIGHT", previewSlider:GetWidth() + 16, 0)
    list:SetPoint("RIGHT", mainFrame, "RIGHT", -16, 0)
    list:Hide()

    for _, btn in pairs(list.buttons) do
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
    local list = ns:CreateListFrame("BackList", {subclass}, previewTabContent)
    list:SetPoint("TOPLEFT", previewList, "TOPRIGHT", previewSlider:GetWidth() + 16, 0)
    list:SetPoint("RIGHT", mainFrame, "RIGHT", -16, 0)
    list:Hide()
    list:GetButton(subclass):HookScript("OnClick", subclass_OnClick)
    slots[backSlot].subclassList = list
    slots[backSlot].selectedSubclass = subclass
    slots[backSlot].selectedPage[subclass] = 1
end

---------------- SHIRT / TABARD ----------------

do
    local subclass = "Miscellaneous"
    local list = ns:CreateListFrame("MiscellaneousList", {subclass}, previewTabContent)
    list:SetPoint("TOPLEFT", previewList, "TOPRIGHT", previewSlider:GetWidth() + 16, 0)
    list:SetPoint("RIGHT", mainFrame, "RIGHT", -16, 0)
    list:Hide()
    list:GetButton(subclass):HookScript("OnClick", subclass_OnClick)
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
    local list = ns:CreateListFrame("MainHandList", subclasses, previewTabContent)
    list:SetPoint("TOPLEFT", previewList, "TOPRIGHT", previewSlider:GetWidth() + 16, 0)
    list:SetPoint("RIGHT", mainFrame, "RIGHT", -16, 0)
    list:Hide()

    for _, btn in pairs(list.buttons) do
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
    local list = ns:CreateListFrame("OffHandList", subclasses, previewTabContent)
    list:SetPoint("TOPLEFT", previewList, "TOPRIGHT", previewSlider:GetWidth() + 16, 0)
    list:SetPoint("RIGHT", mainFrame, "RIGHT", -16, 0)
    list:Hide()

    for _, btn in pairs(list.buttons) do
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
    local list = ns:CreateListFrame("RangedList", subclasses, previewTabContent)
    list:SetPoint("TOPLEFT", previewList, "TOPRIGHT", previewSlider:GetWidth() + 16, 0)
    list:SetPoint("RIGHT", mainFrame, "RIGHT", -16, 0)
    list:Hide()

    for _, btn in pairs(list.buttons) do
        btn:HookScript("OnClick", subclass_OnClick)
    end
    slots[rangedSlot].subclassList = list
    slots[rangedSlot].selectedSubclass = subclasses[1]
    for _, subclass in pairs(subclasses) do
        slots[rangedSlot].selectedPage[subclass] = 1
    end
end

---------------- SAVED LOOKS ----------------

do
    local scrollFrame = CreateFrame("ScrollFrame", "$parentSavedLooks", savedLooksTabContent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 20, -46)
    scrollFrame:SetPoint("BOTTOMLEFT", dressingRoom, "BOTTOMRIGHT", 0, 60)
    scrollFrame:SetWidth(250)

    local editBox = CreateFrame("EditBox", nil, scrollFrame)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject(GameFontHighlightMedium)
    editBox:SetHeight(18)
    editBox:SetJustifyH("LEFT")
    editBox:EnableMouse(true)
    editBox:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
        tile = true, edgeSize = 1, tileSize = 5,
    })
    editBox:SetBackdropColor(0, 0, 0, 0.5)
    editBox:SetBackdropBorderColor(0.3, 0.3, 0.30, 0.80)
    editBox.text = ""

    local btnSave = CreateFrame("Button", "$parentButtonSave", scrollFrame, "UIPanelButtonTemplate2")
    btnSave:SetSize(90, 20)
    btnSave:SetPoint("RIGHT", btnSave:GetParent(), "BOTTOMRIGHT", 0, -32 - editBox:GetHeight())
    btnSave:SetText("Save")
    btnSave:Disable()

    editBox:SetScript("OnEditFocusGained", function(self)
        self:HighlightText()
    end)
    editBox:SetScript("OnEnterPressed", function(self)
        self.text = self:GetText()
        self:HighlightText(0, 0)
        self:ClearFocus()
        if self.text:len() > 0 then
            btnSave:Enable()
        else
            btnSave:Disable()
        end
    end)
    editBox:SetScript("OnEscapePressed", function(self)
        self:SetText(self.text)
        self:HighlightText(0, 0)
        self:ClearFocus()
        if self.text:len() > 0 then
            btnSave:Enable()
        else
            btnSave:Disable()
        end
    end)
    editBox:SetScript("OnTextChanged", function(self)
        if self:GetText():len() > 0 then
            btnSave:Enable()
        else
            btnSave:Disable()
        end
    end)

    local label = editBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetJustifyH("LEFT")
    label:SetHeight(18)
    label:SetPoint("RIGHT", label:GetParent(), "LEFT", -10, 1)
    label:SetText("Name:")

    editBox:SetPoint("TOPRIGHT", scrollFrame, "BOTTOMRIGHT", -5, -10)
    editBox:SetWidth(scrollFrame:GetWidth() - label:GetWidth() - 20)

    local btnTryOn = CreateFrame("Button", "$parentButtonTryOn", scrollFrame, "UIPanelButtonTemplate2")
    btnTryOn:SetSize(90, 20)
    btnTryOn:SetPoint("LEFT", btnTryOn:GetParent(), "BOTTOMLEFT", 0, -32 - editBox:GetHeight())
    btnTryOn:SetText("Try on")
    btnTryOn:Disable()

    local btnRemove = CreateFrame("Button", "$parentButtonRemove", scrollFrame, "UIPanelButtonTemplate2")
    btnRemove:SetSize(90, 20)
    btnRemove:SetPoint("RIGHT", btnRemove:GetParent(), "TOPRIGHT", 0, 26)
    btnRemove:SetText("Remove")
    btnRemove:Disable()

    local slotOrder = { "Head", "Shoulder", "Back", "Chest", "Shirt", "Tabard", "Wrist", "Hands", "Waist", "Legs", "Feet", "Main Hand", "Off-hand", "Ranged",}
    --[[ Save looks structure 
        _G["DressMeSavedLooks"] = {
            {
                ["name"] = "This is the name",
                ["items"] = {...} -- an array of item ids in order of the "slotOrder" above.
            },
            {
                ...
            },
            ...
        }
    ]]

    local list = ns:CreateListFrame("$parentSavedLooks", nil, scrollFrame)
    list:SetWidth(scrollFrame:GetWidth())

    local function list_OnClick(self)
        list:Select(self:GetID())
        btnTryOn:Enable()
        btnRemove:Enable()
    end

    local function buildList(savedLooks)
        for index, look in pairs(savedLooks) do
            local item = list:AddItem(look.name)
            local btn = list.buttons[item]
            btn.lookIndex = index
            btn:SetScript("OnClick", list_OnClick)
        end
        scrollFrame:SetScrollChild(list)
    end

    local savedLooks

    list:RegisterEvent("ADDON_LOADED")
    list:SetScript("OnEvent", function(self, event, addonName)
        if addonName == addon then
            if event == "ADDON_LOADED" then
                if _G["DressMeSavedLooks"] == nil then
                    _G["DressMeSavedLooks"] = {}
                end
                savedLooks = _G["DressMeSavedLooks"]
                buildList(_G["DressMeSavedLooks"])
            end
        end
    end)

    btnTryOn:HookScript("OnClick", function(self)
        local lookIndex = list.buttons[list:GetSelected()].lookIndex
        for index, slotName in pairs(slotOrder) do
            local itemId = savedLooks[lookIndex].items[index]
            if itemId ~= 0 then
                slots[slotName]:TryOn(itemId)
            else
                slots[slotName]:Undress()
            end
        end
    end)

    btnSave:HookScript("OnClick", function(self)
        local name = editBox:GetText()
        local items = {}
        for _, slotName in pairs(slotOrder) do
            if slots[slotName].appearance.itemId ~= nil then
                table.insert(items, slots[slotName].appearance.itemId)
            else
                table.insert(items, 0)
            end
        end
        local lookIndex = nil
        for index, look in pairs(savedLooks) do
            if look.name == name then
                lookIndex = index
                break
            end
        end
        if lookIndex == nil then
            table.insert(savedLooks, {["name"] = name, ["items"] = items})
            local item = list:AddItem(name)
            list.buttons[item]:SetScript("OnClick", list_OnClick)
            list.buttons[item].lookIndex = #savedLooks
            scrollFrame:UpdateScrollChildRect()
        else
            StaticPopupDialogs["DressMeOverwriteConfirmDialog"] = {
                text = ("\124cff00ff00%s\124r\124nalready exists. Overwrite?"):format(name),
                button1 = "Yes",
                button2 = "No",
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
                OnAccept = function(self)
                    savedLooks[lookIndex].items = items
                end,
            }
            local dialog = StaticPopup_Show("DressMeOverwriteConfirmDialog")
            if dialog then
                dialog.lookIndex = lookIndex
            end
        end
    end)

    btnRemove:HookScript("OnClick", function()
        StaticPopupDialogs["DressMeRemoveConfirmDialog"] = {
            text = ("Remove \124cff00ff00%s\124r?"):format(list.buttons[list:GetSelected()].name),
            button1 = "Yes",
            button2 = "No",
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
            OnAccept = function(self)
                btnTryOn:Disable()
                btnRemove:Disable()
                for i = self.lookIndex + 1, #list.buttons do
                    list.buttons[i].lookIndex = i - 1
                end
                list:RemoveItem(self.lookIndex)
                table.remove(savedLooks, self.lookIndex)
                scrollFrame:UpdateScrollChildRect()
            end,
        }
        local dialog = StaticPopup_Show("DressMeRemoveConfirmDialog")
        if dialog then
            dialog.lookIndex = list.buttons[list:GetSelected()].lookIndex
        end
    end)
end



SLASH_DRESSME1 = "/dressme"

SlashCmdList["DRESSME"] = function(msg)
    if msg == "" then
        if mainFrame:IsShown() then mainFrame:Hide() else mainFrame:Show() end
    elseif msg == "debug" then
        if dressingRoom:IsDebugInfoShown() then dressingRoom:HideDebugInfo() else dressingRoom:ShowDebugInfo() end
    end
end

do
    local btn = CreateFrame("Button", "$parent"..addon, CharacterModelFrame, "UIPanelButtonTemplate2")
    btn:SetSize(80, 20)
    btn:SetPoint("BOTTOMRIGHT", -2, 25)
    btn:SetText("DressMe")
    btn:SetScript("OnClick", function(self)
        if mainFrame:IsShown() then
            mainFrame:Hide()
        else
            mainFrame:Show() 
        end
    end)
end
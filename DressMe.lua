local addon, ns = ...

local sex = UnitSex("player")
local _, raceFileName = UnitRace("player")
local _, classFileName = UnitClass("player")

local previewSetupVersion = "classic"

local GetPreviewSetup = ns.GetPreviewSetup
local GetSubclassAppearances = ns.GetSubclassAppearances
local GetOtherAppearances = ns.GetOtherAppearances

-- Used in look saving/sending. Chenging wil breack compatibility.
local slotOrder = { "Head", "Shoulder", "Back", "Chest", "Shirt", "Tabard", "Wrist", "Hands", "Waist", "Legs", "Feet", "Main Hand", "Off-hand", "Ranged",}


local defaultSettings = {
    dressingRoomBackgroundColor = {0.055, 0.055, 0.055, 1},
    previewSetup = "classic", -- possible values are "classic" and "modern",
    showDressMeButton = true,
}

local backdrop = { -- currently used for tests
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = false, tileSize = 16, edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
}

local dressingRoomBorderBackdrop = { -- For a frame above DressingRoom
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\AddOns\\DressMe\\images\\mirror-border",
	tile = false, tileSize = 16, edgeSize = 32,
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
}


local mainFrame = CreateFrame("Frame", addon, UIParent)
-- "Hurry up! You must hack the main frame!"
-- <hackerman noises>
table.insert(UISpecialFrames, mainFrame:GetName())
do 
    mainFrame:SetWidth(1045)
    mainFrame:SetHeight(505)
    mainFrame:SetPoint("CENTER")
    mainFrame:Hide()
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
    mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
    mainFrame:SetScript("OnShow", function() PlaySound("igCharacterInfoOpen") end)
    mainFrame:SetScript("OnHide", function() PlaySound("igCharacterInfoClose") end)

    local title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -9)
    title:SetText("DressMe")

    local titleBg = mainFrame:CreateTexture(nil, "BACKGROUND")
	titleBg:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Title-Background")
	titleBg:SetPoint("TOPLEFT", 10, -7)
    titleBg:SetPoint("BOTTOMRIGHT", mainFrame, "TOPRIGHT", -28, -24)

	local menuBg = mainFrame:CreateTexture(nil, "BACKGROUND")
    menuBg:SetTexture("Interface\\WorldStateFrame\\WorldStateFinalScoreFrame-TopBackground")
    menuBg:SetTexCoord(0, 1, 0, 0.8125) 
	menuBg:SetPoint("TOPLEFT", 10, -26)
    menuBg:SetPoint("RIGHT", -6, 0)
    menuBg:SetHeight(48)
    menuBg:SetVertexColor(0.5, 0.5, 0.5)

    local frameBg = mainFrame:CreateTexture(nil, "BACKGROUND")
    frameBg:SetTexture("Interface\\WorldStateFrame\\WorldStateFinalScoreFrame-TopBackground")
    frameBg:SetTexCoord(0, 0.5, 0, 0.8125) 
    frameBg:SetPoint("TOPLEFT", menuBg, "BOTTOMLEFT")
    frameBg:SetPoint("TOPRIGHT", menuBg, "BOTTOMRIGHT")
    frameBg:SetPoint("BOTTOM", 0, 5)
    frameBg:SetVertexColor(0.25, 0.25, 0.25)
	
	local topLeft = mainFrame:CreateTexture(nil, "BORDER")
    topLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
    topLeft:SetTexCoord(0.5, 0.625, 0, 1)
	topLeft:SetWidth(64)
	topLeft:SetHeight(64)
	topLeft:SetPoint("TOPLEFT")
	
	local topRight = mainFrame:CreateTexture(nil, "BORDER")
    topRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
    topRight:SetTexCoord(0.625, 0.75, 0, 1)
	topRight:SetWidth(64)
	topRight:SetHeight(64)
    topRight:SetPoint("TOPRIGHT")
	
	local top = mainFrame:CreateTexture(nil, "BORDER")
    top:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
    top:SetTexCoord(0.25, 0.37, 0, 1)
	top:SetPoint("TOPLEFT", topLeft, "TOPRIGHT")
    top:SetPoint("TOPRIGHT", topRight, "TOPLEFT")

    local menuSeparatorLeft = mainFrame:CreateTexture(nil, "BORDER")
    menuSeparatorLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
    menuSeparatorLeft:SetTexCoord(0.5, 0.5546875, 0.25, 0.53125)
	menuSeparatorLeft:SetPoint("TOPLEFT", topLeft, "BOTTOMLEFT")
    menuSeparatorLeft:SetWidth(28)
    menuSeparatorLeft:SetHeight(18)

    local menuSeparatorRight = mainFrame:CreateTexture(nil, "BORDER")
    menuSeparatorRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
    menuSeparatorRight:SetTexCoord(0.7109375, 0.75, 0.25, 0.53125)
	menuSeparatorRight:SetPoint("TOPRIGHT", topRight, "BOTTOMRIGHT")
    menuSeparatorRight:SetWidth(20)
    menuSeparatorRight:SetHeight(18)

    local menuSeparatorCenter = mainFrame:CreateTexture(nil, "BORDER")
    menuSeparatorCenter:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
    menuSeparatorCenter:SetTexCoord(0.564453125, 0.671875, 0.25, 0.53125)
    menuSeparatorCenter:SetPoint("TOPLEFT", menuSeparatorLeft, "TOPRIGHT")
    menuSeparatorCenter:SetPoint("BOTTOMRIGHT", menuSeparatorRight, "BOTTOMLEFT")

    local botLeft = mainFrame:CreateTexture(nil, "BORDER")
    botLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
    botLeft:SetTexCoord(0.75, 0.875, 0, 1)
	botLeft:SetPoint("BOTTOMLEFT")
    botLeft:SetWidth(64)
    botLeft:SetHeight(64)

    local left = mainFrame:CreateTexture(nil, "BORDER")
    left:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
    left:SetTexCoord(0, 0.125, 0, 1)
    left:SetPoint("TOPLEFT", menuSeparatorLeft, "BOTTOMLEFT")
    left:SetPoint("BOTTOMRIGHT", botLeft, "TOPRIGHT")

    local botRight = mainFrame:CreateTexture(nil, "BORDER")
    botRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
    botRight:SetTexCoord(0.875, 1, 0, 1)
	botRight:SetPoint("BOTTOMRIGHT")
    botRight:SetWidth(64)
    botRight:SetHeight(64)

    local right = mainFrame:CreateTexture(nil, "BORDER")
    right:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
    right:SetTexCoord(0.125, 0.25, 0, 1)
    right:SetPoint("TOPRIGHT", menuSeparatorRight, "BOTTOMRIGHT", 4, 0)
    right:SetPoint("BOTTOMLEFT", botRight, "TOPLEFT", 4, 0)

    local bot = mainFrame:CreateTexture(nil, "BORDER")
    bot:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
    bot:SetTexCoord(0.38, 0.45, 0, 1)
    bot:SetPoint("BOTTOMLEFT", botLeft, "BOTTOMRIGHT")
    bot:SetPoint("TOPRIGHT", botRight, "TOPLEFT")

    local separatorV = mainFrame:CreateTexture(nil, "BORDER")
    separatorV:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
    separatorV:SetTexCoord(0.23046875, 0.236328125, 0, 1)
    separatorV:SetPoint("TOPLEFT", 410, -72)
    separatorV:SetPoint("BOTTOM", 0, 32)
    separatorV:SetWidth(3)
    separatorV:SetVertexColor(0.5, 0.5, 0.5)
    
    mainFrame.stats = CreateFrame("Frame", nil, mainFrame)
    local stats = mainFrame.stats
    stats:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	    tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 5, bottom = 3 }
    })
    stats:SetBackdropColor(0.12, 0.12, 0.12)
    stats:SetBackdropBorderColor(0.25, 0.25, 0.25)
    stats:SetPoint("BOTTOMLEFT", 410, 8)
    stats:SetPoint("BOTTOMRIGHT", -6, 8)
    stats:SetHeight(24)

    mainFrame.buttons = {}

	local close = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", 2, 1)
    close:SetScript("OnClick", function(self)
        self:GetParent():Hide()
    end)

    mainFrame.buttons.close = close
end


mainFrame.dressingRoom = ns:CreateDressingRoom(nil, mainFrame)

do
    local dressingRoom = mainFrame.dressingRoom
    dressingRoom:SetPoint("TOPLEFT", 10, -74)
    dressingRoom:SetSize(400, 400)
    dressingRoom:SetBackdrop(backdrop)
    dressingRoom:SetBackdropColor(unpack(defaultSettings.dressingRoomBackgroundColor))

    local border = CreateFrame("Frame", nil, dressingRoom)
    border:SetAllPoints()
    border:SetBackdrop(dressingRoomBorderBackdrop)
    border:SetBackdropColor(0, 0, 0, 0)

    local tip = dressingRoom:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tip:SetPoint("BOTTOM", dressingRoom, "TOP", 0, 12)
    tip:SetJustifyH("CENTER")
    tip:SetJustifyV("BOTTOM")
    tip:SetText("\124cff00ff00Left Mouse:\124r rotate \124 \124cff00ff00Right Mouse:\124r pan\124n\124cff00ff00Wheel:\124r zoom")
end

mainFrame.buttons.reset = CreateFrame("Button", "$parentButtonReset", mainFrame, "UIPanelButtonTemplate2")

do
    local btn = mainFrame.buttons.reset
    btn:SetPoint("TOPRIGHT", mainFrame.dressingRoom, "BOTTOMRIGHT")
    btn:SetPoint("BOTTOM", mainFrame.stats, "BOTTOM", 0, 1)
    btn:SetWidth(mainFrame.dressingRoom:GetWidth()/3)
    btn:SetText("Reset")
    btn:SetScript("OnClick", function()
        mainFrame.dressingRoom:Reset()
        PlaySound("gsTitleOptionOK")
    end)
end

mainFrame.buttons.undress = CreateFrame("Button", "$parentButtonUndress", mainFrame, "UIPanelButtonTemplate2")

do
    local btn = mainFrame.buttons.undress
    btn:SetPoint("TOPRIGHT", mainFrame.buttons.reset, "TOPLEFT")
    btn:SetPoint("BOTTOMRIGHT", mainFrame.buttons.reset, "BOTTOMLEFT")
    btn:SetWidth(mainFrame.buttons.reset:GetWidth())
    btn:SetText("Undress")
    btn:SetScript("OnClick", function()
        mainFrame.dressingRoom:Undress()
        PlaySound("gsTitleOptionOK")
    end)
end

mainFrame.buttons.useTarget = CreateFrame("Button", "$parentButtonUseTarget", mainFrame, "UIPanelButtonTemplate2")

do
    local btn = mainFrame.buttons.useTarget
    btn:SetPoint("TOPRIGHT", mainFrame.buttons.undress, "TOPLEFT")
    btn:SetWidth(mainFrame.buttons.undress:GetWidth())
    btn:SetText("Use Target")
    btn:SetScript("OnClick", function()
        mainFrame.dressingRoom:SetUnit("target")
        PlaySound("gsTitleOptionOK")
    end)
    btn:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("Use target player's model.")
        GameTooltip:AddLine("The target must be in range of inspection.", 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btn:HookScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end

---------------- TABS ----------------

local TAB_NAMES = {"Items Preview", "Appearances", "Settings"}

mainFrame.tabs = {}

do
    local tabs = {}

    local function tab_OnClick(self)
        local selectedTab = PanelTemplates_GetSelectedTab(self:GetParent())
        local tab = tabs[selectedTab]
        if tab ~= nil then
            tab:Hide()
        end
        PanelTemplates_SetTab(self:GetParent(), self:GetID())
        tabs[self:GetID()]:Show()
        PlaySound("gsTitleOptionOK")
    end

    for i = 1, #TAB_NAMES do
        mainFrame.buttons["tab"..i] = CreateFrame("Button", "$parentTab"..i, mainFrame, "OptionsFrameTabButtonTemplate")
        local btn = mainFrame.buttons["tab"..i]
        btn:SetText(TAB_NAMES[i])
        btn:SetID(i)
        if i == 1 then
            btn:SetPoint("BOTTOMLEFT", btn:GetParent(), "TOPLEFT", 410, -70)
        else
            btn:SetPoint("LEFT", _G[mainFrame:GetName().."Tab"..(i - 1)], "RIGHT")
        end
        btn:SetScript("OnClick", tab_OnClick)

        local frame = CreateFrame("Frame", "$parentTab"..i.."Content", mainFrame)
        frame:SetPoint("TOPLEFT", 410, -73)
        frame:SetPoint("BOTTOMRIGHT", -8, 28)
        frame:Hide()
        table.insert(tabs, frame)
    end
    
    PanelTemplates_SetNumTabs(mainFrame, #TAB_NAMES)
    tab_OnClick(_G[mainFrame:GetName().."Tab1"])

    mainFrame.tabs.preview = tabs[1]
    mainFrame.tabs.appearances = tabs[2]
    mainFrame.tabs.settings = tabs[3]
end

---------------- PREVIEW LIST ----------------

mainFrame.tabs.preview.list = ns:CreatePreviewList(mainFrame.tabs.preview)
mainFrame.tabs.preview.slider = CreateFrame("Slider", "$parentSlider", mainFrame.tabs.preview, "UIPanelScrollBarTemplateLightBorder")

do
    local list = mainFrame.tabs.preview.list
    list:SetPoint("TOPLEFT")
    list:SetSize(601, 401)

    local label = list:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOP", list, "BOTTOM", 0, -5)
    label:SetJustifyH("CENTER")
    label:SetHeight(10)

    local slider = mainFrame.tabs.preview.slider
    slider:SetPoint("TOPRIGHT", -6, -21)
    slider:SetPoint("BOTTOMRIGHT", -6, 21)
    slider:EnableMouseWheel(true)
    slider:SetScript("OnMouseWheel", function(self, delta)
        self:SetValue(self:GetValue() - delta)
    end)
    slider:SetScript("OnValueChanged", function(self, value)
        list:SetPage(value)
        local _, max = self:GetMinMaxValues()
        label:SetText(("Page: %s/%s"):format(value, max))
    end)
    slider:SetScript("OnMinMaxChanged", function(self, min, max)
        label:SetText(("Page: %s/%s"):format(self:GetValue(), max))
    end)
    slider:SetMinMaxValues(0, 0)
    slider:SetValueStep(1)
    slider:SetValue(1)
    
    slider.buttons = {}
    slider.buttons.up = _G[slider:GetName() .. "ScrollUpButton"]
    slider.buttons.down = _G[slider:GetName() .. "ScrollDownButton"]

    slider.buttons.up:SetScript("OnClick", function(self)
        slider:SetValue(slider:GetValue() - 1)
        PlaySound("gsTitleOptionOK")
    end)
    slider.buttons.down:SetScript("OnClick", function(self)
        slider:SetValue(slider:GetValue() + 1)
        PlaySound("gsTitleOptionOK")
    end)

    list:EnableMouseWheel(true)
    list:SetScript("OnMouseWheel", function(self, delta)
        slider:SetValue(slider:GetValue() - delta)
    end)
end

---------------- SLOTS ----------------

mainFrame.slots = {}
mainFrame.selectedSlot = nil

local SLOT_TEXTURES = {
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

local ARMOR_SLOTS = {"Head", "Shoulder", "Chest", "Wrist", "Hands", "Waist", "Legs", "Feet"}
local BACK_SLOT = "Back"
local MISCELLANEOUS_SLOTS = {"Tabard", "Shirt"}
local MAIN_HAND_SLOT = "Main Hand"
local OFF_HAND_SLOT = "Off-hand"
local RANGED_SLOT = "Ranged"

local function hasValue(array, value)
    for i = 1, #array do
        if array[i] == value then
            return i
        end
    end
    return nil
end

local function slot_OnShiftLeftClick(self)
    local itemId = self.appearance.itemId
    local itemName = self.appearance.itemName
    if itemId ~= nil then
        local slotName = self.slotName
        local ids, names, index, subclassName = GetOtherAppearances(itemId, slotName)
        if ids ~= nil then
            local color = itemName:sub(1, 10)
            local name = itemName:sub(11, -3)
            SELECTED_CHAT_FRAME:AddMessage("[DressMe]: "..self.slotName.." - "..subclassName.." "..color.."\124Hitem:"..itemId..":::::::|h["..name.."]\124h\124r".." ("..itemId..")")
        else
            SELECTED_CHAT_FRAME:AddMessage("[DressMe]: It seems this item cannot be used for transmogrification.")
        end
    end
end


local function slot_OnControlLeftClick(self)
    local itemId = self.appearance.itemId
    if itemId ~= nil then
        ns:ShowWowheadURLDialog(itemId)
    end
end


local function slot_OnLeftCick(self)
    local selectedSlot = mainFrame.selectedSlot
    if selectedSlot ~= nil then
        selectedSlot:UnlockHighlight()
        selectedSlot.selectedPage[selectedSlot.selectedSubclass] = mainFrame.tabs.preview.slider:GetValue()
    end
    mainFrame.selectedSlot = self
    local slotName = self.slotName
    local subclass = self.selectedSubclass
    local page = self.selectedPage[subclass]
    local previewSetup = GetPreviewSetup(previewSetupVersion, raceFileName, sex, slotName, subclass)
    local subclassAppearances = GetSubclassAppearances(slotName, subclass)
    local list = mainFrame.tabs.preview.list
    list:Update(previewSetup, subclassAppearances, page)
    local slider = mainFrame.tabs.preview.slider
    slider:SetMinMaxValues(1, list:GetPageCount())
    if slider:GetValue() ~= page then
        slider:SetValue(page)
    else
        slider:GetScript("OnValueChanged")(slider, page)
    end
    -- Need to reTryOn weapon for proper look.
    if hasValue({MAIN_HAND_SLOT, OFF_HAND_SLOT, RANGED_SLOT}, self.slotName) then
        if self.appearance.displayedItemId ~= nil then
            mainFrame.dressingRoom:TryOn(self.appearance.displayedItemId)
        end
    end
    self:LockHighlight()
    mainFrame.tabs.preview.subclassMenu:Update(slotName, subclass)
end

local function slot_OnRightClick(self)
    self:Undress()
end

local function slot_OnClick(self, button)
    if button == "LeftButton" then
        if IsShiftKeyDown() then
            slot_OnShiftLeftClick(self)
        elseif IsControlKeyDown() then
            slot_OnControlLeftClick(self)
        else
            slot_OnLeftCick(self)
        end
        PlaySound("gsTitleOptionOK")
    elseif button == "RightButton" then
        slot_OnRightClick(self)
    end
end

local function slot_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:AddLine(self.slotName)
    if self.appearance.itemName ~= nil then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(self.appearance.itemName)
        GameTooltip:AddLine("|n|cff00ff00Shift + Left Click:|r create a hyperlink for the item.")
        GameTooltip:AddLine("|cff00ff00Right Click:|r undress the slot.")
        GameTooltip:AddLine("|cff00ff00Ctrl + Left Click:|r create a Wowhead URL for the item.")
    end
    GameTooltip:Show()
end

local function slot_OnLeave(self)
    GameTooltip:Hide()
end

local function slot_Reset(self)
    local slotName = self.slotName
    if slotName == MAIN_HAND_SLOT       then slotName = "MainHand"      end
    if slotName == OFF_HAND_SLOT       then slotName = "SecondaryHand" end
    if slotName == RANGED_SLOT   then slotName = "Ranged"        end
    if slotName == BACK_SLOT     then slotName = "Back"        end
    local slotId = GetInventorySlotInfo(slotName.."Slot")
    local itemId = GetInventoryItemID("player", slotId)
    local name, link, quality, _, _, _, _, _, _, texture = GetItemInfo(itemId ~= nil and itemId or 0)
    if name ~= nil and (quality >= 2 or hasValue(MISCELLANEOUS_SLOTS, self.slotName))then
        self.appearance.displayedItemId = itemId
        self.appearance.itemId = itemId
        self.appearance.itemName = link:sub(1, 10)..name.."\124r"
        self.textures.empty:Hide()
        self.textures.item:Show()
        self.textures.item:SetTexture(texture)
        self:TryOn(itemId)
    else
        self.appearance.displayedItemId = nil
        self.appearance.itemId = nil
        self.appearance.itemName = nil
        self.textures.empty:Show()
        self.textures.item:Hide()
    end
end

local function slot_Undress(self)
    if self.appearance.itemId ~= nil then
        self.appearance.itemId = nil
        self.appearance.itemName = nil
        self.appearance.displayedItemId = nil
        self.textures.empty:Show()
        self.textures.item:Hide()
        self:GetScript("OnEnter")(self)
        --[[ Undress only current slot. In lack of 
        the game's API we're undressing the whole
        model and dress it up again but without the
        current slot. ]]
        mainFrame.dressingRoom:Undress()
        for _, slot in pairs(mainFrame.slots) do
            if slot ~= self then
                if slot.appearance.displayedItemId ~= nil then
                    mainFrame.dressingRoom:TryOn(slot.appearance.displayedItemId)
                end
            end
        end
    end
end

local function slot_TryOn(self, itemId, displayedItemId, name)
    if not (displayedItemId or name) then
        -- We need only the name to display it in the tooltip.
        local ids, names, index = GetOtherAppearances(itemId, self.slotName)
        if ids ~= nil then
            displayedItemId = ids[1]
            name = names[index]
        end
    end
    if displayedItemId then -- we don't need an item that doens't exist in the db
        self.appearance.itemId = itemId
        self.appearance.itemName = name
        self.appearance.displayedItemId = displayedItemId
        ns:QueryItem(displayedItemId, function(itemId, success)
            if itemId == self.appearance.displayedItemId and success then
                local _, link, quality, _, _, _, _, _, _, texture = GetItemInfo(displayedItemId)        
                self.textures.empty:Hide()
                self.textures.item:SetTexture(texture)
                self.textures.item:Show()
                mainFrame.dressingRoom:TryOn(itemId)
            end
        end)
    end
end

--------- Slot building

do
    for slotName, texturePath in pairs(SLOT_TEXTURES) do
        local slot = CreateFrame("Button", "$parentSlot"..slotName, mainFrame, "ItemButtonTemplate")
        slot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        slot:SetFrameLevel(mainFrame.dressingRoom:GetFrameLevel() + 1)
        slot:SetScript("OnClick", slot_OnClick)
        slot:SetScript("OnEnter", slot_OnEnter)
        slot:SetScript("OnLeave", slot_OnLeave)
        slot.slotName = slotName
        slot.selectedPage = {}      -- per subclass, filled later in subclass
        -- Empty declarations just as reminder
        slot.selectedSubclass = nil -- init later in subclass
        slot.appearance = {         -- assigned when a preview's clicked. Used to save in a collection.
            ["itemId"] = nil,
            ["itemName"] = nil,
            ["displayedItemId"] = nil,      -- To avoid overquerying, we TryOn only the first
                                        -- item from according preview.
        } 
        mainFrame.slots[slotName] = slot
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

    local slots = mainFrame.slots
    slots["Head"]:SetPoint("TOPLEFT", mainFrame.dressingRoom, "TOPLEFT", 16, -16)
    slots["Shoulder"]:SetPoint("TOP", slots["Head"], "BOTTOM", 0, -4)
    slots["Back"]:SetPoint("TOP", slots["Shoulder"], "BOTTOM", 0, -4)
    slots["Chest"]:SetPoint("TOP", slots["Back"], "BOTTOM", 0, -4)
    slots["Shirt"]:SetPoint("TOP", slots["Chest"], "BOTTOM", 0, -36)
    slots["Tabard"]:SetPoint("TOP", slots["Shirt"], "BOTTOM", 0, -4)
    slots["Wrist"]:SetPoint("TOP", slots["Tabard"], "BOTTOM", 0, -36)
    slots["Hands"]:SetPoint("TOPRIGHT", mainFrame.dressingRoom, "TOPRIGHT", -16, -16)
    slots["Waist"]:SetPoint("TOP", slots["Hands"], "BOTTOM", 0, -4)
    slots["Legs"]:SetPoint("TOP", slots["Waist"], "BOTTOM", 0, -4)
    slots["Feet"]:SetPoint("TOP", slots["Legs"], "BOTTOM", 0, -4)
    slots["Off-hand"]:SetPoint("BOTTOM", mainFrame.dressingRoom, "BOTTOM", 0, 16)
    slots["Main Hand"]:SetPoint("RIGHT", slots["Off-hand"], "LEFT", -4, 0)
    slots["Ranged"]:SetPoint("LEFT", slots["Off-hand"], "RIGHT", 4, 0)
end

------- Tricks and hooks with slots and provided appearances. -------

local function btnReset_Hook()
    mainFrame.dressingRoom:Undress()
    for _, slot in pairs(mainFrame.slots) do
        slot:Reset()
    end
end

local function btnUndress_Hook()
    for _, slot in pairs(mainFrame.slots) do
        slot.appearance.itemId = nil
        slot.appearance.itemName = nil
        slot.appearance.displayedItemId = nil
        slot.textures.empty:Show()
        slot.textures.item:Hide()
    end
end

local function tryOnSlots(dressUpModel)
    for _, slot in pairs(mainFrame.slots) do
        if slot.appearance.displayedItemId ~= nil then
            dressUpModel:TryOn(slot.appearance.displayedItemId)
        end
    end
end

--[[
    Have to reTryOn selected appearances since
    the model's reset each time it's shown.
]]
--[[
    After half of a year I don't remeber anymore
    why I do it, but showing/hiding a DressUpModel
    brokes the model's positioning.
]]
local function dressingRoom_OnShow(self)
    self:Reset()
    self:Undress()
    tryOnSlots(self)
end

--[[
    Need to TryOn items in the slots if we changed
    displayed model.
]]
mainFrame.buttons.useTarget:HookScript("OnClick", function(slef)
    mainFrame.dressingRoom:Undress()
    tryOnSlots(mainFrame.dressingRoom)
end)

-- At first time it's shown.
mainFrame.slots["Head"]:SetScript("OnShow", function(self)
    self:SetScript("OnShow", nil)
    self:Click("LeftButton")
    mainFrame.buttons.reset:HookScript("OnClick", btnReset_Hook)
    mainFrame.dressingRoom:HookScript("OnShow", dressingRoom_OnShow)
    dressingRoom_OnShow(mainFrame.dressingRoom)
    btnReset_Hook()
    mainFrame.buttons.undress:HookScript("OnClick", btnUndress_Hook)
end)

---------------- PREVIEW LIST SCRIPT ----------------

mainFrame.tabs.preview.list:OnButtonClick(function(self, button)
    local preview = self:GetParent()
    local ids, names = unpack(preview.appereanceData)
    local selectedPreview = preview.selected
    local selectedSlot = mainFrame.selectedSlot
    if IsShiftKeyDown() then
        local color = names[selectedPreview]:sub(1, 10)
        local name = names[selectedPreview]:sub(11, -3)
        SELECTED_CHAT_FRAME:AddMessage("[DressMe]: "..selectedSlot.slotName.." - "..selectedSlot.selectedSubclass.." "..color.."\124Hitem:"..ids[selectedPreview]..":::::::|h["..name.."]\124h\124r".." ("..ids[selectedPreview]..")")
    elseif IsControlKeyDown() then
        ns:ShowWowheadURLDialog(ids[selectedPreview])
    else
        selectedSlot:TryOn(ids[selectedPreview], ids[1],  names[selectedPreview])
    end
end)

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

mainFrame.tabs.preview.subclassMenu = CreateFrame("Frame", "$parentSubclassMenu", mainFrame.tabs.preview, "UIDropDownMenuTemplate")

do
    local menu = mainFrame.tabs.preview.subclassMenu
    menu:SetPoint("TOPRIGHT", -120, 38)
    menu.initializers = {} -- init func per slot
    UIDropDownMenu_JustifyText(menu, "LEFT")

    function menu.Update(self, slotName, subclass)
        UIDropDownMenu_SetText(self, subclass)
        if menu.initializers[slotName] ~= nil then
            UIDropDownMenu_EnableDropDown(self)
            UIDropDownMenu_Initialize(self, menu.initializers[slotName])
        else
            UIDropDownMenu_DisableDropDown(self)
        end
    end

    local previewTab = mainFrame.tabs.preview
    local slots = mainFrame.slots

    local function subclassMenu_OnClick(self, subclass)
        local selectedSlot = mainFrame.selectedSlot
        selectedSlot.selectedPage[selectedSlot.selectedSubclass] = previewTab.slider:GetValue()
        local slotName = selectedSlot.slotName
        local page = selectedSlot.selectedPage[subclass]
        local previewSetup = GetPreviewSetup(previewSetupVersion, raceFileName, sex, slotName, subclass)
        local subclassAppearances = GetSubclassAppearances(slotName, subclass)
        previewTab.list:Update(previewSetup, subclassAppearances, page)
        selectedSlot.selectedSubclass = subclass
        previewTab.slider:SetMinMaxValues(1, previewTab.list:GetPageCount())
        if previewTab.slider:GetValue() ~= page then
            previewTab.slider:SetValue(page)
        else
            previewTab.slider:GetScript("OnValueChanged")(previewTab.slider, page)
        end
        UIDropDownMenu_SetText(mainFrame.tabs.preview.subclassMenu, subclass)
    end

    ---------------- ARMOR ----------------

    do
        local subclasses = {"Cloth", "Leather", "Mail", "Plate"}
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

        local function init(self)
            local info = UIDropDownMenu_CreateInfo()
            for i = 1, #subclasses do
                info.text, info.checked, info.arg1, info.func = subclasses[i], subclasses[i] == UIDropDownMenu_GetText(self), subclasses[i], subclassMenu_OnClick
                UIDropDownMenu_AddButton(info)
            end
        end

        for _, slotName in pairs(ARMOR_SLOTS) do
            previewTab.subclassMenu.initializers[slotName] = init
            slots[slotName].selectedSubclass = subclassPerPlayerClass[classFileName]
            for _, subclass in ipairs(subclasses) do
                slots[slotName].selectedPage[subclass] = 1
            end
        end
    end

    ---------------- BACK ----------------

    do
        local subclass = "Cloth"
        slots[BACK_SLOT].selectedSubclass = subclass
        slots[BACK_SLOT].selectedPage[subclass] = 1
    end

    ---------------- SHIRT / TABARD ----------------

    do
        local subclass = "Miscellaneous"
        for _, name in pairs(MISCELLANEOUS_SLOTS) do
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
        local function init (self)
            local info = UIDropDownMenu_CreateInfo()
            for i = 1, #subclasses do
                info.text, info.checked, info.arg1, info.func = subclasses[i], subclasses[i] == UIDropDownMenu_GetText(self), subclasses[i], subclassMenu_OnClick
                UIDropDownMenu_AddButton(info)
            end
        end
        previewTab.subclassMenu.initializers[MAIN_HAND_SLOT] = init
        slots[MAIN_HAND_SLOT].selectedSubclass = subclasses[1]
        for _, subclass in ipairs(subclasses) do
            slots[MAIN_HAND_SLOT].selectedPage[subclass] = 1
        end
    end

    ---------------- OFF-HAND ----------------

    do
        local subclasses = {
            "OH Axe", "OH Mace", "OH Sword", "OH Dagger", "OH Fist",
            "Shield", "Held in Off-hand"
        }
        local function init(self)
            local info = UIDropDownMenu_CreateInfo()
            for i = 1, #subclasses do
                info.text, info.checked, info.arg1, info.func = subclasses[i], subclasses[i] == UIDropDownMenu_GetText(self), subclasses[i], subclassMenu_OnClick
                UIDropDownMenu_AddButton(info)
            end
        end
        previewTab.subclassMenu.initializers[OFF_HAND_SLOT] = init
        slots[OFF_HAND_SLOT].selectedSubclass = subclasses[1]
        for _, subclass in ipairs(subclasses) do
            slots[OFF_HAND_SLOT].selectedPage[subclass] = 1
        end
    end

    ---------------- RANGED ----------------

    do
        local subclasses = {"Bow", "Crossbow", "Gun", "Wand", "Thrown"}
        local function init(self)
            local info = UIDropDownMenu_CreateInfo()
            for i = 1, #subclasses do
                info.text, info.checked, info.arg1, info.func = subclasses[i], subclasses[i] == UIDropDownMenu_GetText(self), subclasses[i], subclassMenu_OnClick
                UIDropDownMenu_AddButton(info)
            end
        end
        previewTab.subclassMenu.initializers[RANGED_SLOT] = init
        slots[RANGED_SLOT].selectedSubclass = subclasses[1]
        for _, subclass in ipairs(subclasses) do
            slots[RANGED_SLOT].selectedPage[subclass] = 1
        end
    end
end

---------------- APPEARANCES ----------------

do
    local appearancesTab = mainFrame.tabs.appearances

    local background = CreateFrame("Frame", "$parentSavedListBackground", appearancesTab)
    background:SetPoint("TOPLEFT", 5, -30)
    background:SetPoint("BOTTOM", 0, 30)
    background:SetWidth(280)
    background:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    background:SetBackdropColor(0, 0, 0, 1)

    local scrollFrame = CreateFrame("ScrollFrame", "$parentScrollFrame", background, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 8, -8)
    scrollFrame:SetPoint("BOTTOMLEFT", 8, 8)
    scrollFrame:SetWidth(background:GetWidth() - 12)

    local btnSave = CreateFrame("Button", "$parentButtonSave", scrollFrame, "UIPanelButtonTemplate2")
    btnSave:SetSize(90, 20)
    btnSave:SetPoint("CENTER", background, "TOP", 0, 14)
    btnSave:SetText("Save")
    btnSave:SetScript("OnClick", function() PlaySound("gsTitleOptionOK") end)
    btnSave:Disable()

    local btnSaveAs = CreateFrame("Button", "$parentButtonSaveAs", scrollFrame, "UIPanelButtonTemplate2")
    btnSaveAs:SetSize(90, 20)
    btnSaveAs:SetPoint("LEFT", background, "TOPLEFT", 0, 14)
    btnSaveAs:SetText("Save As...")
    btnSaveAs:SetScript("OnClick", function() PlaySound("gsTitleOptionOK") end)

    local btnRemove = CreateFrame("Button", "$parentButtonRemove", scrollFrame, "UIPanelButtonTemplate2")
    btnRemove:SetSize(90, 20)
    btnRemove:SetPoint("RIGHT", background, "TOPRIGHT", 0, 14)
    btnRemove:SetText("Remove")
    btnRemove:SetScript("OnClick", function() PlaySound("gsTitleOptionOK") end)
    btnRemove:Disable()

    local btnTryOn = CreateFrame("Button", "$parentButtonTryOn", scrollFrame, "UIPanelButtonTemplate2")
    btnTryOn:SetSize(90, 20)
    btnTryOn:SetPoint("LEFT", background, "BOTTOMLEFT", 0, -12)
    btnTryOn:SetText("Try on")
    btnTryOn:SetScript("OnClick", function() PlaySound("gsTitleOptionOK") end)
    btnTryOn:Disable()

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

    local listFrame = ns:CreateListFrame("$parentSavedLooks", nil, scrollFrame)
    listFrame:SetWidth(scrollFrame:GetWidth())
    listFrame:SetScript("OnShow", function(self)
        if self.selected == nil then
            btnTryOn:Disable()
            btnRemove:Disable()
            btnSave:Disable()
        else
            btnTryOn:Enable()
            btnRemove:Enable()
            btnSave:Enable()
        end
    end)

    listFrame.onSelect = function()
        btnTryOn:Enable()
        btnRemove:Enable()
        btnSave:Enable()
    end

    local function slots2ItemList()
        local items = {}
        for _, slotName in pairs(slotOrder) do
            if mainFrame.slots[slotName].appearance.displayedItemId ~= nil then
                table.insert(items, mainFrame.slots[slotName].appearance.itemId)
            else
                table.insert(items, 0)
            end
        end
        return items
    end

    local function buildList()
        local savedLooks = _G["DressMeSavedLooks"]
        _G["DressMeSavedLooks"] = {}
        local names = {}
        local items = {} -- by name
        for index, look in pairs(savedLooks) do
            table.insert(names, look.name)
            items[look.name] = look.items
        end
        table.sort(names)
        for i, name in ipairs(names) do
            listFrame:AddItem(name)
            table.insert(_G["DressMeSavedLooks"], {["name"] = name, ["items"] = items[name]})
        end
    end

    listFrame:RegisterEvent("ADDON_LOADED")
    listFrame:SetScript("OnEvent", function(self, event, addonName)
        if addonName == addon then
            if event == "ADDON_LOADED" then
                if _G["DressMeSavedLooks"] == nil then
                    _G["DressMeSavedLooks"] = {}
                end
                buildList()
                scrollFrame:SetScrollChild(listFrame)
            end
        end
    end)

    btnTryOn:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("Try On")
        GameTooltip:AddLine("Can be not immediate if there are items in the chosen look that  must be queried and cached.", 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)

    btnTryOn:HookScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    btnTryOn:HookScript("OnClick", function(self)
        local savedLooks = _G["DressMeSavedLooks"]
        local id = listFrame.buttons[listFrame:GetSelected()]:GetID()
        for index, slotName in pairs(slotOrder) do
            local itemId = savedLooks[id].items[index]
            if itemId ~= 0 then
                mainFrame.slots[slotName]:TryOn(itemId)
            else
                mainFrame.slots[slotName]:Undress()
            end
        end
    end)

    btnSaveAs:HookScript("OnClick", function(self)
        StaticPopupDialogs["DRESSME_SAVED_LOOKS_SAVE_AS_DIALOG"] = {
            text = ("Enter the name:"),
            button1 = "Save",
            button2 = "Cancel",
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            hasEditBox = true,
            hasWideEditBox = true,
            maxLetters = 50,
            preferredIndex = 3,
            -- EditBoxOnTextChanged, Doesn't seems to be working for wideEditBox, have to hook it.
            OnShow = function(self)
                self.button1:Disable()
                self.wideEditBoxOnChangeOrigin = self.wideEditBox:GetScript("OnTextChanged")
                self.wideEditBox:SetScript("OnTextChanged", function(self, ...)
                    if self:GetText() == "" then
                        self:GetParent().button1:Disable()
                    else
                        self:GetParent().button1:Enable()
                    end
                    self:GetParent().wideEditBoxOnChangeOrigin(self, ...)
                end)
                self.RemoveWideEditBoxOnChangeHook = function(self)
                    self.wideEditBox:SetScript("OnTextChanged", self.wideEditBoxOnChangeOrigin)
                    self.wideEditBoxOnChangeOrigin = nil
                    self.RemoveWideEditBoxOnChangeHook = nil
                end
            end,
            OnAccept = function(self)
                self:RemoveWideEditBoxOnChangeHook()
                local enteredName = self.wideEditBox:GetText()
                local items = slots2ItemList()
                local savedLooks = _G["DressMeSavedLooks"]
                for i, look in ipairs(savedLooks) do
                    if look.name == enteredName then
                        StaticPopupDialogs["DRESSME_SAVED_LOOKS_SAVE_AS_OVERWRITE_CONFIRM_DIALOG"] = {
                            text = ("\124cff00ff00%s\124r\124nalready exists. Overwrite?"):format(enteredName),
                            button1 = "Yes",
                            button2 = "No",
                            timeout = 0,
                            whileDead = true,
                            hideOnEscape = true,
                            showAlert = true,
                            preferredIndex = 3,
                            OnAccept = function(self)
                                look.items = items
                            end,
                        }
                        StaticPopup_Show("DRESSME_SAVED_LOOKS_SAVE_AS_OVERWRITE_CONFIRM_DIALOG")
                        return
                    end
                end
                table.insert(savedLooks, {name = enteredName, items = items})
                listFrame:Clear()
                buildList()
                scrollFrame:UpdateScrollChildRect()
            end,
            OnCancel = function(self)
                self:RemoveWideEditBoxOnChangeHook()
            end,
        }
        StaticPopup_Show("DRESSME_SAVED_LOOKS_SAVE_AS_DIALOG")
    end)

    btnSave:HookScript("OnClick", function(self)
        local items = slots2ItemList()
        StaticPopupDialogs["DRESSME_SAVE_OVERWRITE_CONFIRM_DIALOG"] = {
            text = ("Overwrite \124cff00ff00%s\124r?"):format(listFrame.buttons[listFrame.selected]:GetText()),
            button1 = "Yes",
            button2 = "No",
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            showAlert = true,
            preferredIndex = 3,
            OnAccept = function(self)
                _G["DressMeSavedLooks"][self.id].items = items
            end,
        }
        local dialog = StaticPopup_Show("DRESSME_SAVE_OVERWRITE_CONFIRM_DIALOG")
        if dialog then
            dialog.id = listFrame.selected
        end
    end)

    btnRemove:HookScript("OnClick", function()
        StaticPopupDialogs["DRESSME_REMOVE_CONFIRM_DIALOG"] = {
            text = ("Remove \124cff00ff00%s\124r?"):format(listFrame.buttons[listFrame:GetSelected()].name),
            button1 = "Yes",
            button2 = "No",
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            showAlert = true,
            preferredIndex = 3,
            OnAccept = function(self)
                btnTryOn:Disable()
                btnRemove:Disable()
                btnSave:Disable()
                --[[ Why did I do this loop if the same was happening in :RemoveItem(...) method?
                for i = self.id + 1, #listFrame.buttons do
                    listFrame.buttons[i].id = i - 1
                end ]]
                table.remove(_G["DressMeSavedLooks"], self.id)
                listFrame:RemoveItem(self.id)
                scrollFrame:UpdateScrollChildRect()
            end,
        }
        local dialog = StaticPopup_Show("DRESSME_REMOVE_CONFIRM_DIALOG")
        if dialog then
            dialog.id = listFrame.buttons[listFrame:GetSelected()]:GetID()
        end
    end)
end

---------------- CHARACTER MENU BUTTON ----------------

local btnDressMe = CreateFrame("Button", "$parent"..addon.."DressMeButton", CharacterModelFrame, "UIPanelButtonTemplate2")
btnDressMe:SetSize(80, 20)
btnDressMe:SetPoint("BOTTOMRIGHT", -2, 25)
btnDressMe:SetText("DressMe")
btnDressMe:SetScript("OnClick", function(self)
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show() 
    end
end)

---------------- SETTINGS TAB ----------------

do
    local settingsTab = mainFrame.tabs.settings

    local function GetSettings()
        if _G["DressMeSettings"] == nil then
            local function copyTable(tableFrom)
                local result = {}
                for k, v in pairs(tableFrom) do
                    if type(v) == "table" then
                        result[k] = copyTable(v)
                    else
                        result[k] = v
                    end
                end
                return result
            end
            _G["DressMeSettings"] = copyTable(defaultSettings)
        end
        return _G["DressMeSettings"]
    end
    
    --------- Preview Setup

    local menu = CreateFrame("Frame", addon.."PreviewSetupDropDownMenu", settingsTab, "UIDropDownMenuTemplate")

    local function menu_OnClick(self, arg1, arg2, checked)
        GetSettings().previewSetup = arg1
        UIDropDownMenu_SetText(menu, arg1)
        previewSetupVersion = arg1
        mainFrame.selectedSlot:Click("LeftButton")
    end

    UIDropDownMenu_Initialize(menu, function(frame, level, menuList)
        local previewSetup = GetSettings().previewSetup
        local info = UIDropDownMenu_CreateInfo()
        info.text, info.checked, info.arg1, info.func = "classic", previewSetup == "classic", "classic", menu_OnClick
        UIDropDownMenu_AddButton(info)
        info.text, info.checked, info.arg1, info.func = "modern", previewSetup == "modern", "modern", menu_OnClick
        UIDropDownMenu_AddButton(info)
    end)

    local menuTitle = menu:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    menuTitle:SetPoint("TOPLEFT", settingsTab, "TOPLEFT", 16, -24)
    menuTitle:SetText("Used models:")

    local menuTip = CreateFrame("Frame", addon.."PreviewSetupDropDownMenuTip", settingsTab)
    menuTip:SetPoint("LEFT", menuTitle, "LEFT")
    menuTip:SetPoint("RIGHT", menu:GetChildren(), "LEFT")
    menuTip:SetHeight(menu:GetChildren():GetHeight())
    menuTip:EnableMouse(true)
    menuTip:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("Used models")
        GameTooltip:AddLine("There's a funmade modification for WotLK client that brings modern high quality character models from \"Warlords of Draenor\" expansion. Unfortunately, preview for the modern models has different setup. If your game client's using the modern models, choose \"modern\" in this popup menu and \"classic\" otherwise.", 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    menuTip:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    menu:SetPoint("TOPLEFT", menuTitle:GetWidth() + 10, -16)

    --------- Character background color

    local colorPicker = CreateFrame("Frame", addon.."BorderDressingRoomBackgroundColorPicker", settingsTab)
    colorPicker:SetSize(24, 24)
    colorPicker:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameBackground"})
    colorPicker:SetBackdropColor(0.15, 0.15, 0.15, 1)
    local btnColorPicker = CreateFrame("Button", "$parentButton", colorPicker)
    btnColorPicker:SetPoint("TOPLEFT", 2, -2)
    btnColorPicker:SetPoint("BOTTOMRIGHT", -2, 2)
    btnColorPicker:RegisterForClicks("LeftButtonDown")
    
    btnColorPicker:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameBackground"})
    btnColorPicker:SetBackdropColor(unpack(defaultSettings.dressingRoomBackgroundColor))

    local colorPickerTitle = colorPicker:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    colorPickerTitle:SetPoint("TOPLEFT", settingsTab, "TOPLEFT", 16, -80)
    colorPickerTitle:SetText("Character background color:")

    colorPicker:SetPoint("LEFT", colorPickerTitle, "RIGHT", 8, 0)

    local function colorPicker_OnAccept(a, b, c)
        local r, g, b = ColorPickerFrame:GetColorRGB() 
        mainFrame.dressingRoom:SetBackdropColor(r, g, b)
        btnColorPicker:SetBackdropColor(r, g, b)
        GetSettings().dressingRoomBackgroundColor = {r, g, b}
    end

    local function colorPicker_OnCancel(previousValues)
        mainFrame.dressingRoom:SetBackdropColor(unpack(previousValues))
        btnColorPicker:SetBackdropColor(unpack(previousValues))
        GetSettings().dressingRoomBackgroundColor = {unpack(previousValues)}
    end

    btnColorPicker:SetScript("OnClick", function(self)
        local color = GetSettings().dressingRoomBackgroundColor
        ColorPickerFrame.previousValues = {unpack(color)}
        ColorPickerFrame:SetColorRGB(unpack(color))
        ColorPickerFrame.func = colorPicker_OnAccept
        ColorPickerFrame.cancelFunc = colorPicker_OnCancel
        ColorPickerFrame:Hide()
        ColorPickerFrame:Show()
    end)

    local btnColorPickerReset = CreateFrame("Button", "$parentResetButton", colorPicker, "UIPanelButtonTemplate2")
    btnColorPickerReset:SetPoint("TOPRIGHT", btnColorPickerReset:GetParent(), "BOTTOMRIGHT", 0, -4)
    btnColorPickerReset:SetText("Reset Color")
    btnColorPickerReset:SetWidth(120)
    btnColorPickerReset:SetScript("OnClick", function(self)
        local settings = GetSettings()
        local color = {unpack(defaultSettings.dressingRoomBackgroundColor)}
        settings.dressingRoomBackgroundColor = color
        mainFrame.dressingRoom:SetBackdropColor(unpack(color))
        btnColorPicker:SetBackdropColor(unpack(color))
        PlaySound("gsTitleOptionOK")
    end)

    --------- Show/hide "DressMe" button
    
    local showDressMeButtonCheckBox = CreateFrame("CheckButton", addon.."ShowDressMeButtonCheckBox", settingsTab, "ChatConfigCheckButtonTemplate")
    showDressMeButtonCheckBox:SetScript("OnClick", function(self)
        if self:GetChecked() then
            btnDressMe:Show()
            GetSettings().showDressMeButton = true
        else
            btnDressMe:Hide()
            GetSettings().showDressMeButton = false
        end
    end)
    showDressMeButtonCheckBox:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("Show \"DressMe\" button")
        GameTooltip:AddLine("Show or hide \"DressMe\" button in the character window.", 1, 1, 1, 1, true)
        GameTooltip:AddLine("The addon can be still accessed via \"/dressme\" chat command.", 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    showDressMeButtonCheckBox:HookScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    local showDressMeButtonTitle = colorPicker:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    showDressMeButtonTitle:SetText("Show \"DressMe\" button:")
    showDressMeButtonTitle:SetPoint("TOPRIGHT", showDressMeButtonCheckBox, "TOPLEFT", -4, -4)

    showDressMeButtonCheckBox:SetPoint("TOPLEFT", settingsTab, "TOPLEFT", showDressMeButtonTitle:GetWidth() + 28, -150)

    --------- Apply settings on addon loaded

    local function applySettings(settings)
        -- Dressing room background color
        mainFrame.dressingRoom:SetBackdropColor(unpack(settings.dressingRoomBackgroundColor))
        btnColorPicker:SetBackdropColor(unpack(settings.dressingRoomBackgroundColor))
        -- Preview setup popup menu
        previewSetupVersion = settings.previewSetup
        -- Show/hide "DressMe" button
        showDressMeButtonCheckBox:SetChecked(settings.showDressMeButton)
        if settings.showDressMeButton then
            btnDressMe:Show()
        else
            btnDressMe:Hide()
        end
        UIDropDownMenu_SetText(menu, settings.previewSetup)
    end

    settingsTab:RegisterEvent("ADDON_LOADED")
    settingsTab:SetScript("OnEvent", function(self, event, addonName)
        if addonName == addon then
            if event == "ADDON_LOADED" then
                local settings = GetSettings()
                applySettings(settings)
            end
        end
    end)
end

---------------- CHAT COMMANDS ----------------

SLASH_DRESSME1 = "/dressme"

SlashCmdList["DRESSME"] = function(msg)
    if msg == "" then
        if mainFrame:IsShown() then mainFrame:Hide() else mainFrame:Show() end
    elseif msg == "debug" then
        if mainFrame.dressingRoom:IsDebugInfoShown() then mainFrame.dressingRoom:HideDebugInfo() else mainFrame.dressingRoom:ShowDebugInfo() end
    end
end
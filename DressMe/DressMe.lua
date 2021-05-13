local addon, ns = ...

local mainFrameTitle = "|ccff6ff98DressMe |cffffffff1.3.1|r"

local sex = UnitSex("player")
local _, raceFileName = UnitRace("player")
local _, classFileName = UnitClass("player")

local previewSetupVersion = "classic"

local armorSlots = {"Head", "Shoulder", "Chest", "Wrist", "Hands", "Waist", "Legs", "Feet"}
local backSlot = "Back"
local miscellaneousSlots = {"Tabard", "Shirt"}
local mainHandSlot = "Main Hand"
local offHandSlot = "Off-hand"
local rangedSlot = "Ranged"

-- For hiding hair/beard
local chestSlots = {"Chest", "Tabard", "Shirt"}

local addonMessagePrefix = "DressMe"
-- Used in look saving/sending. Chenging wil breack compatibility.
local slotOrder = { "Head", "Shoulder", "Back", "Chest", "Shirt", "Tabard", "Wrist", "Hands", "Waist", "Legs", "Feet", "Main Hand", "Off-hand", "Ranged",}

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

local slotSubclasses = {--[[
    ["slot1"] = {subclass1, subclass2, ...},
    ["slot2"] = {subclass1, subclass2, ...},
    ["slot2"] = {subclass1, subclass2, ...},
    ...]]
}

do
    for i, slot in ipairs(armorSlots) do slotSubclasses[slot] = {"Cloth", "Leather", "Mail", "Plate"} end
    for i, slot in ipairs(miscellaneousSlots) do slotSubclasses[slot] = {"Miscellaneous", } end
    slotSubclasses[backSlot] = {"Cloth", }
    slotSubclasses[mainHandSlot] = {
        "1H Axe", "1H Mace", "1H Sword", "1H Dagger", "1H Fist",
        "MH Axe", "MH Mace", "MH Sword", "MH Dagger", "MH Fist",
        "2H Axe", "2H Mace", "2H Sword", "Polearm", "Staff" }
    slotSubclasses[offHandSlot] = { "OH Axe", "OH Mace", "OH Sword", "OH Dagger", "OH Fist", "Shield", "Held in Off-hand"}
    slotSubclasses[rangedSlot] = {"Bow", "Crossbow", "Gun", "Wand", "Thrown"}
end

local defaultSlot = "Head"

local defaultArmorSubclass = {
    ["MAGE"] = "Cloth",
    ["PRIEST"] = "Cloth",
    ["WARLOCK"] = "Cloth",
    ["DRUID"] = "Leather",
    ["ROGUE"] = "Leather",
    ["HUNTER"] = "Mail",
    ["SHAMAN"] = "Mail",
    ["PALADIN"] = "Plate",
    ["WARRIOR"] = "Plate",
    ["DEATHKNIGHT"] = "Plate"
}


local defaultSettings = {
    dressingRoomBackgroundColor = {0.6, 0.6, 0.6, 1},
    dressingRoomBackgroundTexture = {
        [GetRealmName()] = {
            [GetUnitName("player")] = classFileName == "DEATHKNIGHT" and classFileName or raceFileName,
        },
    },
    previewSetup = "classic", -- possible values are "classic" and "modern",
    showDressMeButton = true,
    showShortcutsInTooltip = true,
    hideHairOnCloakPreview = false,
    hideHairBeardOnChestPreview = false,
    useServerTimeInReceivedAppearances = false,
    announceAppearanceReceiving = true,
    ignoreUIScaling = false,
}

local function GetSettings()
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

    if _G["DressMeSettings"] == nil then
        _G["DressMeSettings"] = copyTable(defaultSettings)
    else
        for k, v in pairs(defaultSettings) do
            if _G["DressMeSettings"][k] == nil then
                _G["DressMeSettings"][k] = type(v) == "table" and copyTable(v) or v
            end
        end
        if _G["DressMeSettings"].dressingRoomBackgroundTexture[GetRealmName()] == nil then
            _G["DressMeSettings"].dressingRoomBackgroundTexture[GetRealmName()] = {}
        end
        if _G["DressMeSettings"].dressingRoomBackgroundTexture[GetRealmName()][GetUnitName("player")] == nil then
            _G["DressMeSettings"].dressingRoomBackgroundTexture[GetRealmName()][GetUnitName("player")] = defaultSettings.dressingRoomBackgroundTexture[GetRealmName()][GetUnitName("player")]
        end
    end

    return _G["DressMeSettings"]
end


local function arrayHasValue(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return true
        end
    end
    return false
end


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
    title:SetText(mainFrameTitle)

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


mainFrame.dressingRoom = ns.CreateDressingRoom(nil, mainFrame)

do
    local dr = mainFrame.dressingRoom
    dr:SetPoint("TOPLEFT", 10, -74)
    dr:SetSize(400, 400)

    local border = CreateFrame("Frame", nil, dr)
    border:SetAllPoints()
    border:SetBackdrop(dressingRoomBorderBackdrop)
    border:SetBackdropColor(0, 0, 0, 0)

    dr.backgroundTextures = {}
    for s in ("human,nightelf,dwarf,gnome,draenei,orc,scourge,tauren,troll,bloodelf,deathknight"):gmatch("%w+") do
        dr.backgroundTextures[s] = dr:CreateTexture(nil, "BACKGROUND")
        dr.backgroundTextures[s]:SetTexture("Interface\\AddOns\\DressMe\\images\\"..s)
        dr.backgroundTextures[s]:SetAllPoints()
        dr.backgroundTextures[s]:Hide()
    end
    dr.backgroundTextures["color"] = dr:CreateTexture(nil, "BACKGROUND")
    dr.backgroundTextures["color"]:SetAllPoints()
    dr.backgroundTextures["color"]:SetTexture(1, 1, 1)
    dr.backgroundTextures["color"]:Hide()

    local tip = dr:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tip:SetPoint("BOTTOM", dr, "TOP", 0, 12)
    tip:SetJustifyH("CENTER")
    tip:SetJustifyV("BOTTOM")
    tip:SetText("\124cff00ff00Left Mouse:\124r rotate \124 \124cff00ff00Right Mouse:\124r pan\124n\124cff00ff00Wheel\124r or \124cff00ff00Alt + Right Mouse:\124r zoom")

    -- SetLight(enabled, omni, dirX, dirY, dirZ, ambIntensity, ambR, ambG, ambB, dirIntensity, dirR, dirG, dirB)
    local defaultLight = {1, 0, 0, 1, 0, 1, 0.7, 0.7, 0.7, 1, 0.8, 0.8, 0.64}
    local shadowformLight = {1, 0, 0, 1, 0, 1, 0.16, 0, 0.23, 0}
    local shadowformAlpha = 0.75

    dr.shadowformEnabled = false

    dr.EnableShadowform = function(self)
        self:SetLight(unpack(shadowformLight))
        self:SetModelAlpha(shadowformAlpha)
        self.shadowformEnabled = true
    end

    dr.DisableShadowform = function(self)
        self:SetLight(unpack(defaultLight))
        self:SetModelAlpha(1)
        self.shadowformEnabled = false
    end
end

mainFrame.buttons.send = CreateFrame("Button", "$parentButtonSend", mainFrame, "UIPanelButtonTemplate2")

do
    StaticPopupDialogs["DRESSME_SEND_DIALOG"] = {
        text = "|cffffd700Enter player name:",
        button1 = "Send",
        button2 = CLOSE,
        timeout = 0,
        whileDead = true,
        hasEditBox = true,
        preferredIndex = 3,
        OnAccept = function(self)
            local playerName = self.editBox:GetText()
            if playerName ~= "" then
                local slots = mainFrame.slots
                local s = slots[slotOrder[1]].itemId ~= nil and tostring(slots[slotOrder[1]].itemId) or ""
                local itemsCount = slots[slotOrder[1]].itemId == nil and 0 or 1
                for i=2, #slotOrder do
                    s = s..":"
                    if slots[slotOrder[i]].itemId ~= nil then
                        s = s..slots[slotOrder[i]].itemId
                        itemsCount = itemsCount + 1
                    end
                end
                if itemsCount > 0 then
                    SendAddonMessage(addonMessagePrefix, s, "WHISPER", playerName)
                else
                    SELECTED_CHAT_FRAME:AddMessage("|ccff6ff98<DressMe>|r: nothing to send.")
                end
            end
        end,
        OnShow = function(self)
            local data = self.data
            self.editBox:SetText("")
        end,}
    local btn = mainFrame.buttons.send
    btn:SetPoint("TOPRIGHT", mainFrame.dressingRoom, "BOTTOMRIGHT")
    btn:SetPoint("BOTTOM", mainFrame.stats, "BOTTOM", 0, 1)
    btn:SetWidth(mainFrame.dressingRoom:GetWidth()/4)
    btn:SetText("Send")
    btn:SetScript("OnClick", function()
        StaticPopup_Show("DRESSME_SEND_DIALOG")
        PlaySound("gsTitleOptionOK")
    end)
end

mainFrame.buttons.reset = CreateFrame("Button", "$parentButtonReset", mainFrame, "UIPanelButtonTemplate2")

do
    local btn = mainFrame.buttons.reset
    btn:SetPoint("TOPRIGHT", mainFrame.buttons.send, "TOPLEFT")
    btn:SetWidth(mainFrame.buttons.send:GetWidth())
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

---------------- SLOTS ----------------

mainFrame.slots = {}
mainFrame.selectedSlot = nil

local function slot_OnShiftLeftClick(self)
    if self.itemId ~= nil then
        local _, link = GetItemInfo(self.itemId)
        if link ~= nil then
            SELECTED_CHAT_FRAME:AddMessage("|ccff6ff98<DressMe>|r: "..link.." ("..self.itemId..")")
        else
            SELECTED_CHAT_FRAME:AddMessage("|ccff6ff98<DressMe>|r: It seems this item cannot be used for transmogrification.")
        end
    end
end

local function getIndex(array, value)
    for i = 1, #array do
        if array[i] == value then
            return i    
        end
    end
    return nil
end

local function slot_OnControlLeftClick(self)
    if self.itemId ~= nil then
        ns.ShowWowheadURLDialog(self.itemId)
    end
end


local function slot_OnLeftClick(self)
    local selectedSlot = mainFrame.selectedSlot
    if selectedSlot ~= nil then
        selectedSlot:UnlockHighlight()
    end
    mainFrame.selectedSlot = self
    mainFrame.tabs.preview.subclassMenu:Update(self.slotName)
    --[[ ReTryOn weapon so the model displays
    the weapon of the clicked (selected) slot. ]]
    if self.itemId ~= nil and getIndex({mainHandSlot, offHandSlot, rangedSlot}, self.slotName) then
        mainFrame.dressingRoom:TryOn(self.itemId)
    end
    self:LockHighlight()
end

local function slot_OnRightClick(self)
    self:RemoveItem()
end

local function slot_OnClick(self, button)
    if button == "LeftButton" then
        if IsShiftKeyDown() then
            slot_OnShiftLeftClick(self)
        elseif IsControlKeyDown() then
            slot_OnControlLeftClick(self)
        else
            slot_OnLeftClick(self)
        end
        PlaySound("gsTitleOptionOK")
    elseif button == "RightButton" then
        slot_OnRightClick(self)
    end
end

local function slot_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    if self.itemId == nil then
        GameTooltip:AddLine(self.slotName)
    else
        local _, link = GetItemInfo(self.itemId)
        GameTooltip:SetHyperlink(link)
        if GetSettings().showShortcutsInTooltip then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("|cff00ff00Shift + Left Click:|r create a hyperlink for the item.")
            GameTooltip:AddLine("|cff00ff00Right Click:|r undress the slot.")
            GameTooltip:AddLine("|cff00ff00Ctrl + Left Click:|r create a Wowhead URL for the item.")
        end
    end
    GameTooltip:Show()
end

local function slot_OnLeave(self)
    GameTooltip:Hide()
end

local function slot_Reset(self)
    local characterSlotName = self.slotName
    if characterSlotName == mainHandSlot then characterSlotName = "MainHand" end
    if characterSlotName == offHandSlot then characterSlotName = "SecondaryHand" end
    if characterSlotName == rangedSlot then characterSlotName = "Ranged" end
    if characterSlotName == backSlot then characterSlotName = "Back" end
    local slotId = GetInventorySlotInfo(characterSlotName.."Slot")
    local itemId = GetInventoryItemID("player", slotId)
    local name, link, _, _, _, _, _, _, _, texture = GetItemInfo(itemId ~= nil and itemId or 0)
    if name ~= nil then
        self:SetItem(itemId)
    else
        self:RemoveItem()
    end
end

local function slot_RemoveItem(self)
    if self.itemId ~= nil then
        self.itemId = nil
        self.textures.empty:Show()
        self.textures.item:Hide()
        self:GetScript("OnEnter")(self)
        --[[ We cannot undress a specific slot
        of a DressUpModel in WotLK. Instead,
        we're undressing the whole model and
        dressing it up again without the slot. ]]
        mainFrame.dressingRoom:Undress()
        for _, slot in pairs(mainFrame.slots) do
            if slot.itemId ~= nil then
                mainFrame.dressingRoom:TryOn(slot.itemId)
            end
        end
    end
end

local function slot_SetItem(self, itemId)
    self.itemId = itemId
    ns.QueryItem(itemId, function(queriedItemId, success)
        if queriedItemId == self.itemId and success then
            local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(queriedItemId)
            self.textures.empty:Hide()
            self.textures.item:SetTexture(texture)
            self.textures.item:Show()
            mainFrame.dressingRoom:TryOn(queriedItemId)
        end
    end)
end

--------- Slot building

do
    for slotName, texturePath in pairs(slotTextures) do
        local slot = CreateFrame("Button", "$parentSlot"..slotName, mainFrame, "ItemButtonTemplate")
        slot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        slot:SetFrameLevel(mainFrame.dressingRoom:GetFrameLevel() + 1)
        slot:SetScript("OnClick", slot_OnClick)
        slot:SetScript("OnEnter", slot_OnEnter)
        slot:SetScript("OnLeave", slot_OnLeave)
        slot.slotName = slotName
        mainFrame.slots[slotName] = slot
        slot.textures = {}
        slot.textures.empty = slot:CreateTexture(nil, "BACKGROUND")
        slot.textures.empty:SetTexture(texturePath)
        slot.textures.empty:SetAllPoints()
        slot.textures.item = slot:CreateTexture(nil, "BACKGROUND")
        slot.textures.item:SetAllPoints()
        slot.textures.item:Hide()
        slot.Reset = slot_Reset
        slot.SetItem = slot_SetItem
        slot.RemoveItem = slot_RemoveItem
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
        if slot.slotName == rangedSlot and ("DRUIDSHAMANPALADINDEATHKNIGHT"):find(classFileName) then
            slot:RemoveItem()
        else
            slot:Reset()
        end
    end
    if mainFrame.dressingRoom.shadowformEnabled then
        mainFrame.dressingRoom:EnableShadowform()
    end
end

local function btnUndress_Hook()
    for _, slot in pairs(mainFrame.slots) do
        slot.itemId = nil
        slot.textures.empty:Show()
        slot.textures.item:Hide()
    end
end

local function tryOnFromSlots(dressUpModel)
    for _, slot in pairs(mainFrame.slots) do
        if slot.itemId ~= nil then
            dressUpModel:TryOn(slot.itemId)
        end
    end
end

--[[
    Have to reTryOn selected appearances since
    the model's reset each time it's shown.
]]
--[[
    After half a year I don't remeber anymore
    why I do it, but showing/hiding a DressUpModel
    breaks the model's positioning.
]]
local function dressingRoom_OnShow(self)
    self:Reset()
    self:Undress()
    tryOnFromSlots(self)
    if self.shadowformEnabled then
        self:EnableShadowform()
    end
end

--[[
    Need to TryOn items in the slots if we changed
    displayed model.
]]
mainFrame.buttons.useTarget:HookScript("OnClick", function(slef)
    if mainFrame.dressingRoom.shadowformEnabled then
        mainFrame.dressingRoom:EnableShadowform()
    end
    mainFrame.dressingRoom:Undress()
    tryOnFromSlots(mainFrame.dressingRoom)
end)

-- At first time it's shown.
mainFrame.slots[defaultSlot]:SetScript("OnShow", function(self)
    self:SetScript("OnShow", nil)
    mainFrame.buttons.reset:HookScript("OnClick", btnReset_Hook)
    mainFrame.dressingRoom:HookScript("OnShow", dressingRoom_OnShow)
    dressingRoom_OnShow(mainFrame.dressingRoom)
    btnReset_Hook()
    mainFrame.buttons.undress:HookScript("OnClick", btnUndress_Hook)
    self:Click("LeftButton")
end)

---------------- SHADOWFORM ----------------

mainFrame.buttons.shadowform = CreateFrame("Button", "$parentShadowformButton", mainFrame, "ItemButtonTemplate")

do
    local enableTexture = "Interface\\Icons\\spell_shadow_shadowform"
    local disableTexture = "Interface\\Icons\\spell_nature_wispsplode"
    
    local btn = mainFrame.buttons.shadowform
    btn:SetSize(28, 28)
    _G[btn:GetName().."NormalTexture"]:SetAllPoints()
    _G[btn:GetName().."NormalTexture"]:SetTexCoord(0.1875, 0.796875, 0.1875, 0.796875)

    btn:SetPoint("RIGHT", mainFrame.dressingRoom, "BOTTOMRIGHT", -16, 54)
    btn:SetFrameLevel(mainFrame.dressingRoom:GetFrameLevel() + 1)

    local texture = btn:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints()
    texture:SetTexture(enableTexture)

    btn:RegisterForClicks("LeftButtonUp")
    btn:SetScript("OnClick", function(self)
        PlaySound("gsTitleOptionOK")
        if not mainFrame.dressingRoom.shadowformEnabled then
            mainFrame.dressingRoom:EnableShadowform()
            texture:SetTexture(disableTexture)
            self:LockHighlight()
        else
            mainFrame.dressingRoom:DisableShadowform()
            texture:SetTexture(enableTexture)
            self:UnlockHighlight()
        end
    end)

    btn:SetScript("OnEnter", function(self)
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:AddLine("Shadowform")
        GameTooltip:AddLine("A poor simulation that relies on the model's light setup. Equipment with its own light source (like  \"Excavator's Brand\" tourch) gives wrong result. Emission textures that ignore light (like Draenei eyes) also ignore the simulation and are not shaded as they would be in the true shadowform.", 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function(self)
        GameTooltip:ClearLines()
        GameTooltip:Hide()
    end)
end

---------------- PREVIEW TAB ----------------

mainFrame.tabs.preview.list = ns.CreatePreviewList(mainFrame.tabs.preview)
mainFrame.tabs.preview.slider = CreateFrame("Slider", "$parentSlider", mainFrame.tabs.preview, "UIPanelScrollBarTemplateLightBorder")

---------------- Slider

do
    local previewTab = mainFrame.tabs.preview
    local list = mainFrame.tabs.preview.list
    local slider = mainFrame.tabs.slider

    list:SetPoint("TOPLEFT")
    list:SetSize(601, 401)

    local label = list:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
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
    slider:SetScript("OnMinMaxChanged", function(self, min, max)
        label:SetText(("Page: %s/%s"):format(self:GetValue(), max))
    end)
    
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

    slider:SetScript("OnValueChanged", function (self, value)
        local _, max = self:GetMinMaxValues()
        label:SetText(("Page: %s/%s"):format(value, max))
    end)

    slider:SetMinMaxValues(0, 0)
    slider:SetValueStep(1)
end

---------------- Preview list

do
    local previewTab = mainFrame.tabs.preview
    local list = previewTab.list
    local slider = previewTab.slider

    local slotSubclassPage = {} -- page per [slot][subclass] can be `nil`

    for slot, _ in pairs(mainFrame.slots) do
        slotSubclassPage[slot] = {}
    end

    local currSlot, currSubclass = defaultSlot, defaultArmorSubclass[classFileName]
    local records

    local hideHairItemId = 10289
    local hideHairBeardItemId = 29943

    ns.QueryItem(hideHairItemId)
    ns.QueryItem(hideHairBeardItemId)

    local function hairBeardControl(slot)
        if slot == backSlot and GetSettings().hideHairOnCloakPreview then
            list:TryOn(hideHairItemId)
        end
        if arrayHasValue(chestSlots, slot) and GetSettings().hideHairBeardOnChestPreview then
            list:TryOn(hideHairBeardItemId)
        end
    end

    previewTab.Update = function(self, slot, subclass)
        slotSubclassPage[currSlot][currSubclass] = slider:GetValue() > 0 and slider:GetValue() or 1
        currSlot = slot
        currSubclass = subclass
        records = ns.GetSubclassRecords(slot, subclass)

        local itemIds = {}
        local selectedItemId
        for i=1, #records do
            local ids = records[i][1]
            table.insert(itemIds, ids[1])
            if selectedItemId == nil and mainFrame.slots[slot].itemId ~= nil and arrayHasValue(ids, mainFrame.slots[slot].itemId) then
                selectedItemId = ids[1]
            end
        end
        list:SetItems(itemIds)
        if selectedItemId ~= nil then
            list:SelectByItemId(selectedItemId)
        end

        local setup = ns.GetPreviewSetup(previewSetupVersion, raceFileName, sex, slot, subclass)
        list:SetupModel(setup.width, setup.height, setup.x, setup.y, setup.z, setup.facing, setup.sequence)

        list:TryOn(nil)
        local page = slotSubclassPage[slot][subclass] ~= nil and slotSubclassPage[slot][subclass] or 1
        local pageCount = list:GetPageCount()
        --[[ SetMinMaxValues triggers "OnValueChanged"
        via changing current value if current value is
        not in range of current min/max values. ]]
        local _, sliderMax = slider:GetMinMaxValues()
        if page > sliderMax then
            slider:SetMinMaxValues(1, pageCount)
        end
        if slider:GetValue() ~= page then
            slider:SetValue(page)
        else
            list:SetPage(page)
            list:Update()
        end
        slider:SetMinMaxValues(1, pageCount)
        hairBeardControl(slot)
    end

    previewTab:SetScript("OnShow", function(self)
        self:Update(currSlot, currSubclass)
    end)

    slider:HookScript("OnValueChanged", function(self, value)
        list:SetPage(value)
        list:Update()
        hairBeardControl(currSlot)
    end)

    local selectedInRecord = {} -- { [first id in record] = index of selected id, ...}
    local enteredButton

    local tabDummy = CreateFrame("Button", addon.."PreviewListTabDummy", previewTab)

    list.onEnter = function(self)
        local recordIndex = self:GetParent().itemIndex
        local ids = records[recordIndex][1]
        local names = records[recordIndex][2]
        GameTooltip:Hide()
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("This appearance is provided by:", 1, 1, 1)
        GameTooltip:AddLine(" ")
        local selectedIndex = selectedInRecord[ids[1]] ~= nil and selectedInRecord[ids[1]] or 1
        for i, id in ipairs(ids) do
            GameTooltip:AddLine((i == selectedIndex and "> " or "- ")..names[i]..(id == mainFrame.selectedSlot.itemId and " •"or ""))
        end
        if GetSettings().showShortcutsInTooltip then
            GameTooltip:AddLine("|n|cff00ff00Left Click:|r try on the appearance.")
            if #ids > 1 then
                GameTooltip:AddLine("|cff00ff00Tab:|r choose an item in the list.")
                GameTooltip:AddLine("|cff00ff00Shift + Left Click:|r create a hyperlink for the chosen item.")
            else
                GameTooltip:AddLine("|cff00ff00Shift + Left Click:|r create a hyperlink for the item.")
            end
            GameTooltip:AddLine("|cff00ff00Ctrl + Left Click:|r create a Wowhead URL for the chosen item.")
        end
        GameTooltip:Show()
        SetOverrideBindingClick(tabDummy, true, "TAB", tabDummy:GetName(), "RightButton")
        enteredButton = self
    end

    list.onLeave = function(self, ...)
        ClearOverrideBindings(tabDummy)
        GameTooltip:ClearLines()
        GameTooltip:Hide()
        enteredButton = nil
    end

    tabDummy:SetScript("OnClick", function(self)
        if enteredButton ~= nil then
            local recordIndex = enteredButton:GetParent().itemIndex
            local ids = records[recordIndex][1]
            if #ids > 1 then
                if selectedInRecord[ids[1]] == nil then
                    selectedInRecord[ids[1]] = 2
                else
                    selectedInRecord[ids[1]] = selectedInRecord[ids[1]] < #ids and selectedInRecord[ids[1]] + 1 or 1
                end
            end
            list.onEnter(enteredButton)
        end
    end)

    list.onItemClick = function(self, button)
        local recordIndex = self:GetParent().itemIndex
        local ids = records[recordIndex][1]
        local selectedIndex = selectedInRecord[ids[1]] ~= nil and selectedInRecord[ids[1]] or 1
        local itemId = ids[selectedIndex]
        if IsShiftKeyDown() then
            local names = records[recordIndex][2]
            local color = names[selectedIndex]:sub(1, 10)
            local name = names[selectedIndex]:sub(11, -3)
            SELECTED_CHAT_FRAME:AddMessage("|ccff6ff98<DressMe>|r: "..color.."\124Hitem:"..itemId..":::::::|h["..name.."]\124h\124r".." ("..itemId..")")
        elseif IsControlKeyDown() then
            ns.ShowWowheadURLDialog(itemId)
        else
            mainFrame.selectedSlot:SetItem(itemId)
        end
        list.onEnter(self)
    end
end

---------------- SBUCLASS FRAME ----------------

mainFrame.tabs.preview.subclassMenu = CreateFrame("Frame", "$parentSubclassMenu", mainFrame.tabs.preview, "UIDropDownMenuTemplate")

do
    local previewTab = mainFrame.tabs.preview
    local slots = mainFrame.slots
    local menu = mainFrame.tabs.preview.subclassMenu

    menu:SetPoint("TOPRIGHT", -120, 38)
    menu.initializers = {} -- init func per slot
    UIDropDownMenu_JustifyText(menu, "LEFT")

    local slotSelectedSubclass = {}

    for i, slot in ipairs(armorSlots) do slotSelectedSubclass[slot] = defaultArmorSubclass[classFileName] end
    for i, slot in ipairs(miscellaneousSlots) do slotSelectedSubclass[slot] = "Miscellaneous" end
    slotSelectedSubclass[backSlot] = slotSubclasses[backSlot][1] 
    slotSelectedSubclass[mainHandSlot] = slotSubclasses[mainHandSlot][1]
    slotSelectedSubclass[offHandSlot] = slotSubclasses[offHandSlot][1]
    slotSelectedSubclass[rangedSlot] = slotSubclasses[rangedSlot][1]

    local function menu_OnClick(self, slot, subclass)
        previewTab:Update(slot, subclass)
        slotSelectedSubclass[slot] = subclass
        UIDropDownMenu_SetText(mainFrame.tabs.preview.subclassMenu, subclass)
    end

    local initializer = {
        ["slot"] = nil,

        ["__call"] = function (self, frame)
            local info = UIDropDownMenu_CreateInfo()
            local slot = self.slot
            for i, subclass in ipairs(slotSubclasses[slot]) do
                info.text = subclass
                info.checked = subclass == UIDropDownMenu_GetText(frame)
                info.arg1 = slot
                info.arg2 = subclass
                info.func = menu_OnClick
                UIDropDownMenu_AddButton(info)
            end
        end,
    }
    setmetatable(initializer, initializer)

    menu.Update = function(self, slot)
        if #slotSubclasses[slot] > 1 then
            UIDropDownMenu_EnableDropDown(self)
        else
            UIDropDownMenu_DisableDropDown(self)
        end
        UIDropDownMenu_SetText(self, slotSelectedSubclass[slot])
        initializer.slot = slot
        previewTab:Update(slot, slotSelectedSubclass[slot])
        UIDropDownMenu_Initialize(self, initializer)
    end
end

---------------- APPEARANCES ----------------

mainFrame.tabs.appearances.saved = CreateFrame("Frame", "$parentSaved", mainFrame.tabs.appearances)

do
    local appearancesTab = mainFrame.tabs.appearances

    local frame = appearancesTab.saved
    frame:SetPoint("TOPLEFT", 5, -30)
    frame:SetPoint("BOTTOM", 0, 30)
    frame:SetWidth(280)
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    frame:SetBackdropColor(0, 0, 0, 1)

    local scrollFrame = CreateFrame("ScrollFrame", "$parentScrollFrame", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 8, -8)
    scrollFrame:SetPoint("BOTTOMLEFT", 8, 8)
    scrollFrame:SetWidth(frame:GetWidth() - 12)

    local btnSave = CreateFrame("Button", "$parentButtonSave", scrollFrame, "UIPanelButtonTemplate2")
    btnSave:SetSize(90, 20)
    btnSave:SetPoint("CENTER", frame, "TOP", 0, 14)
    btnSave:SetText("Save")
    btnSave:SetScript("OnClick", function() PlaySound("gsTitleOptionOK") end)
    btnSave:Disable()

    local btnSaveAs = CreateFrame("Button", "$parentButtonSaveAs", scrollFrame, "UIPanelButtonTemplate2")
    btnSaveAs:SetSize(90, 20)
    btnSaveAs:SetPoint("LEFT", frame, "TOPLEFT", 0, 14)
    btnSaveAs:SetText("Save As...")
    btnSaveAs:SetScript("OnClick", function() PlaySound("gsTitleOptionOK") end)

    local btnRemove = CreateFrame("Button", "$parentButtonRemove", scrollFrame, "UIPanelButtonTemplate2")
    btnRemove:SetSize(90, 20)
    btnRemove:SetPoint("RIGHT", frame, "TOPRIGHT", 0, 14)
    btnRemove:SetText("Remove")
    btnRemove:SetScript("OnClick", function() PlaySound("gsTitleOptionOK") end)
    btnRemove:Disable()

    local btnTryOn = CreateFrame("Button", "$parentButtonTryOn", scrollFrame, "UIPanelButtonTemplate2")
    btnTryOn:SetSize(90, 20)
    btnTryOn:SetPoint("LEFT", frame, "BOTTOMLEFT", 0, -12)
    btnTryOn:SetText("Try On")
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

    local listFrame = ns.CreateListFrame("$parentSavedLooks", nil, scrollFrame)
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
            if mainFrame.slots[slotName].itemId ~= nil then
                table.insert(items, mainFrame.slots[slotName].itemId)
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
                mainFrame.slots[slotName]:SetItem(itemId)
            else
                mainFrame.slots[slotName]:RemoveItem()
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

---------------- RECIEVED APPEARANCES ----------------

mainFrame.tabs.appearances.received = CreateFrame("Frame", "$parentReceived", mainFrame.tabs.appearances)

do
    local appearancesTab = mainFrame.tabs.appearances

    local frame = mainFrame.tabs.appearances.received
    frame:SetPoint("TOP", mainFrame.tabs.appearances.saved, "TOP")
    frame:SetPoint("RIGHT", -21, 0)
    frame:SetPoint("BOTTOM", 0, 30)
    frame:SetWidth(280)
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    frame:SetBackdropColor(0, 0, 0, 1)

    local scrollFrame = CreateFrame("ScrollFrame", "$parentScrollFrame", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 8, -8)
    scrollFrame:SetPoint("BOTTOMLEFT", 8, 8)
    scrollFrame:SetWidth(frame:GetWidth() - 12)

    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("BOTTOM", frame, "TOP", 0, 10)
    label:SetJustifyH("CENTER")
    label:SetHeight(10)
    label:SetText("Received Appearances")

    local btnRemove = CreateFrame("Button", "$parentButtonRemove", scrollFrame, "UIPanelButtonTemplate2")
    btnRemove:SetSize(90, 20)
    btnRemove:SetPoint("CENTER", frame, "BOTTOM", 0, -12)
    btnRemove:SetText("Remove")
    btnRemove:SetScript("OnClick", function() PlaySound("gsTitleOptionOK") end)
    btnRemove:Disable()

    local btnTryOn = CreateFrame("Button", "$parentButtonSaveAs", scrollFrame, "UIPanelButtonTemplate2")
    btnTryOn:SetSize(90, 20)
    btnTryOn:SetPoint("LEFT", frame, "BOTTOMLEFT", 0, -12)
    btnTryOn:SetText("Try On")
    btnTryOn:SetScript("OnClick", function() PlaySound("gsTitleOptionOK") end)
    btnTryOn:Disable()

    local btnClear = CreateFrame("Button", "$parentButtonClear", scrollFrame, "UIPanelButtonTemplate2")
    btnClear:SetSize(90, 20)
    btnClear:SetPoint("RIGHT", frame, "BOTTOMRIGHT", 0, -12)
    btnClear:SetText("Clear")
    btnClear:SetScript("OnClick", function() PlaySound("gsTitleOptionOK") end)
    btnClear:Disable()

    local listFrame = ns.CreateListFrame("$parentSavedLooks", nil, scrollFrame)
    listFrame:SetWidth(scrollFrame:GetWidth())
    listFrame:SetScript("OnShow", function(self)
        if self.selected == nil then
            btnTryOn:Disable()
            btnRemove:Disable()
        else
            btnTryOn:Enable()
            btnRemove:Enable()
        end
        if self:GetSize() == 0 then
            btnClear:Disable()
        else
            btnClear:Enable()
        end
        for i=1, self:GetSize() do
            local btn = self:GetButton(i)
            if GetSettings().useServerTimeInReceivedAppearances then
                btn:SetText(btn.serverTime.." "..btn.sender)
            else
                btn:SetText(btn.localTime.." "..btn.sender)
            end
        end
    end)
    
    scrollFrame:SetScrollChild(listFrame)

    listFrame:RegisterEvent("CHAT_MSG_ADDON")
    listFrame:SetScript("OnEvent", function(self, event, prefix, message, channel, sender)
        if prefix == addonMessagePrefix then
            for i=1, listFrame:GetSize() do
                local btn = listFrame:GetButton(i)
                if btn.sender == sender and btn.message == message then
                    return
                end
            end
            local btn = listFrame:GetButton(listFrame:AddItem(sender))
            btn.sender = sender
            btn.message = message
            local h, m = GetGameTime()
            btn.serverTime = format("[%u:%s]", h, m < 10 and "0"..m or tostring(m))
            local d = date("*t")
            btn.localTime = format("[%u:%s]", d.hour, d.min < 10 and "0"..d.min or tostring(d.min))
            if GetSettings().useServerTimeInReceivedAppearances then
                btn:SetText(btn.serverTime.." "..sender)
            else
                btn:SetText(btn.localTime.." "..sender)
            end
            btnClear:Enable()
            scrollFrame:UpdateScrollChildRect()
            if GetSettings().announceAppearanceReceiving then
                SELECTED_CHAT_FRAME:AddMessage("|ccff6ff98<DressMe>|r: an appearance has been received from "..sender..".")
            end
        end
    end)

    listFrame.onSelect = function(self)
        btnRemove:Enable()
        btnTryOn:Enable()
    end

    btnRemove:HookScript("OnClick", function(self)
        local btn = listFrame:GetButton(listFrame:GetSelected())
        btn.sender = nil
        btn.message = nil
        btn.serverTime = nil
        btn.localTime = nil
        listFrame:RemoveItem(listFrame:GetSelected())
        self:Disable()
        btnTryOn:Disable()
        if listFrame:GetSize() == 0 then
            btnClear:Disable()
        end
        scrollFrame:UpdateScrollChildRect()
    end)

    btnClear:HookScript("OnClick", function(self)
        while listFrame:GetSize() > 0 do
            local btn = listFrame:GetButton(1)
            btn.sender = nil
            btn.message = nil
            btn.serverTime = nil
            btn.localTime = nil
            listFrame:RemoveItem(1)
        end
        btnTryOn:Disable()
        btnRemove:Disable()
        btnClear:Disable()
        scrollFrame:UpdateScrollChildRect()
    end)

    btnTryOn:HookScript("OnClick", function()
        local btn = listFrame:GetButton(listFrame:GetSelected())
        local splitted = {}
        for s in string.gmatch(btn.message..":", "([^:]*):") do
            table.insert(splitted, s)
        end
        if #splitted == #slotOrder then
            for i, slot in ipairs(slotOrder) do
                local itemId = tonumber(splitted[i])
                if itemId ~= nil then
                    mainFrame.slots[slot]:SetItem(itemId)
                else
                    mainFrame.slots[slot]:RemoveItem()
                end
            end
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

do  --------- email and github
    local email = mainFrame.tabs.settings:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    email:SetPoint("CENTER", mainFrame.stats, "CENTER", 10, 0)
    email:SetJustifyH("CENTER")
    email:SetHeight(10)
    email:SetText("GetLocalPlayer@Gmail.com  |  GitHub.com/GetLocalPlayer/DressMe")
end


do  --------- Preview Setup
    local settingsTab = mainFrame.tabs.settings

    settingsTab.previewSetupMenu = CreateFrame("Frame", "$parentPreviewSetupDropDownMenu", settingsTab, "UIDropDownMenuTemplate")
    
    local menu = settingsTab.previewSetupMenu

    local function menu_OnClick(self, mode)
        GetSettings().previewSetup = mode
        UIDropDownMenu_SetText(menu, mode)
        previewSetupVersion = mode
        if mainFrame.selectedSlot ~= nil then
            mainFrame.selectedSlot:Click("LeftButton")
        end
    end

    UIDropDownMenu_Initialize(menu, function(frame)
        local previewSetup = GetSettings().previewSetup
        local info = UIDropDownMenu_CreateInfo()
        info.text, info.checked, info.arg1, info.func = "classic", previewSetup == "classic", "classic", menu_OnClick
        UIDropDownMenu_AddButton(info)
        info.text, info.checked, info.arg1, info.func = "modern", previewSetup == "modern", "modern", menu_OnClick
        UIDropDownMenu_AddButton(info)
    end)

    local label = menu:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", settingsTab, "TOPLEFT", 16, -24)
    label:SetText("Used models:")

    local tipFrame = CreateFrame("Frame", addon.."PreviewSetupDropDownMenuTip", settingsTab)
    tipFrame:SetPoint("LEFT", label, "LEFT")
    tipFrame:SetPoint("RIGHT", menu:GetChildren(), "LEFT")
    tipFrame:SetHeight(menu:GetChildren():GetHeight())
    tipFrame:EnableMouse(true)
    tipFrame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("Used models")
        GameTooltip:AddLine("There's a funmade modification for WotLK client that brings modern high quality character models from \"Warlords of Draenor\" expansion. Unfortunately, preview for the modern models has different setup. If your game client's using the modern models, choose \"modern\" in this popup menu and \"classic\" otherwise.", 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    tipFrame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    menu:SetPoint("TOPLEFT", label:GetWidth() + 10, -16)

    settingsTab.SetPreviewSetup = function(self, mode)
        menu_OnClick(nil, mode)
    end
end


do  --------- Character background
    local settingsTab = mainFrame.tabs.settings
    local textures = mainFrame.dressingRoom.backgroundTextures

    local colorButtonBackground = CreateFrame("Frame", "$parentBorderDressingRoomBackgroundColorPicker", settingsTab)
    colorButtonBackground:SetSize(24, 24)
    colorButtonBackground:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameBackground"})
    colorButtonBackground:SetBackdropColor(0.15, 0.15, 0.15, 1)

    local colorButton = CreateFrame("Button", "$parentButton", colorButtonBackground)
    colorButton:SetPoint("TOPLEFT", 2, -2)
    colorButton:SetPoint("BOTTOMRIGHT", -2, 2)
    colorButton:RegisterForClicks("LeftButtonDown")
    
    colorButton:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameBackground"})
    colorButton:SetBackdropColor(unpack(defaultSettings.dressingRoomBackgroundColor))

    local label = colorButtonBackground:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", settingsTab, "TOPLEFT", 16, -80)
    label:SetText("Character background:")

    colorButtonBackground:SetPoint("TOPRIGHT", label, "BOTTOMRIGHT", 0, -4)

    local function colorPicker_OnAccept()
        local r, g, b = ColorPickerFrame:GetColorRGB() 
        textures.color:SetTexture(r, g, b)
        colorButton:SetBackdropColor(r, g, b)
        GetSettings().dressingRoomBackgroundColor = {r, g, b}
    end

    local function colorPicker_OnCancel(previousValues)
        local settings = GetSettings()
        textures.color:SetTexture(unpack(previousValues))
        colorButton:SetBackdropColor(unpack(previousValues))
        GetSettings().dressingRoomBackgroundColor = {unpack(previousValues)}
    end

    colorButton:SetScript("OnClick", function(self)
        local r, g, b = unpack(GetSettings().dressingRoomBackgroundColor)
        ColorPickerFrame.previousValues = {r, g, b}
        ColorPickerFrame:SetColorRGB(r, g, b)
        ColorPickerFrame.func = colorPicker_OnAccept
        ColorPickerFrame.cancelFunc = colorPicker_OnCancel
        ColorPickerFrame:Hide()
        ColorPickerFrame:Show()
    end)

    local btnReset = CreateFrame("Button", "$parentResetButton", colorButtonBackground, "UIPanelButtonTemplate2")
    btnReset:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -6)
    btnReset:SetText("Reset Color")
    btnReset:SetWidth(100)
    btnReset:SetScript("OnClick", function(self)
        local r, g, b = unpack(defaultSettings.dressingRoomBackgroundColor)
        GetSettings().dressingRoomBackgroundColor = {r, g, b}
        textures.color:SetTexture(r, g, b)
        colorButton:SetBackdropColor(r, g, b)
        PlaySound("gsTitleOptionOK")
    end)

    settingsTab.backgroundMenu = CreateFrame("Frame", "$parentDropDownMenu", colorButtonBackground, "UIDropDownMenuTemplate")
    
    local menu = settingsTab.backgroundMenu
    local function getText(background)
        return  (background == "deathknight" and "Death Knight")
                or (background == "nightelf" and "Night Elf")
                or (background == "bloodelf" and "Blood Elf")
                or (background == "scourge" and "Forsaken")
                or background:gsub("^%l", string.upper)
    end

    local function menu_OnClick(self, background)
        GetSettings().dressingRoomBackgroundTexture[GetRealmName()][GetUnitName("player")] = background
        for _, tex in pairs(textures) do
            tex:Hide()
        end
        textures[background]:Show()
        UIDropDownMenu_SetText(menu, getText(background))
    end

    UIDropDownMenu_Initialize(menu, function()
        local currBackground = GetSettings().dressingRoomBackgroundTexture[GetRealmName()][GetUnitName("player")]:lower()
        local info = UIDropDownMenu_CreateInfo()
        for background in ("color,human,dwarf,nightelf,gnome,draenei,orc,scourge,tauren,troll,bloodelf,deathknight"):gmatch("%w+") do
            info.text = getText(background)
            info.checked = currBackground == background
            info.arg1 = background
            info.func = menu_OnClick
            UIDropDownMenu_AddButton(info)
        end
    end)

    settingsTab.SetCharacterBackground = function(self, background, r, g, b)
        menu_OnClick(nil, background:lower())
        colorButton:SetBackdropColor(r, g, b)
        textures.color:SetTexture(r, g, b)
    end
    
    menu:SetPoint("LEFT", label, "RIGHT")
    UIDropDownMenu_SetWidth(menu, 100)
end


do  --------- Show/hide "DressMe" button
    local settingsTab = mainFrame.tabs.settings
    settingsTab.showDressMeButtonCheckBox = CreateFrame("CheckButton", "$parentShowDressMeButtonCheckBox", settingsTab, "ChatConfigCheckButtonTemplate")

    local checkbox = settingsTab.showDressMeButtonCheckBox
    checkbox:SetPoint("TOPLEFT", settingsTab, "TOPLEFT", 15, -150)
    checkbox:SetScript("OnClick", function(self)
        if self:GetChecked() then
            btnDressMe:Show()
            GetSettings().showDressMeButton = true
        else
            btnDressMe:Hide()
            GetSettings().showDressMeButton = false
        end
    end)
    checkbox:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("Show \"DressMe\" button")
        GameTooltip:AddLine("Show or hide \"DressMe\" button in the character window.", 1, 1, 1, 1, true)
        GameTooltip:AddLine("The addon can be still accessed via \"/dressme\" chat command.", 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    checkbox:HookScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    local label = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetText("Show \"DressMe\" button")
    label:SetPoint("LEFT", checkbox, "RIGHT", 4, 2)
end


do  --------- Show shortcuts in tooltips
    local settingsTab = mainFrame.tabs.settings
    settingsTab.showShortcutsInTooltipCheckBox = CreateFrame("CheckButton", "$parentShowShortcutsInTooltipCheckBox", settingsTab, "ChatConfigCheckButtonTemplate")
    
    local checkbox = settingsTab.showShortcutsInTooltipCheckBox
    checkbox:SetPoint("TOP", settingsTab.showDressMeButtonCheckBox, "BOTTOM", 0, -10)
    checkbox:SetScript("OnClick", function(self)
        GetSettings().showShortcutsInTooltip = self:GetChecked() ~= nil
    end)
    local label = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetText("Show shortcuts in tooltip")
    label:SetPoint("LEFT", checkbox, "RIGHT", 4, 2)
end


do  --------- Hide hair on cloak preview
    local settingsTab = mainFrame.tabs.settings
    settingsTab.hideHairOnCloakPreviewCheckBox = CreateFrame("CheckButton", "$parentHideHairOnCloakPreviewCheckBox", settingsTab, "ChatConfigCheckButtonTemplate")

    local checkbox = settingsTab.hideHairOnCloakPreviewCheckBox
    checkbox:SetPoint("LEFT", settingsTab.showDressMeButtonCheckBox, "RIGHT", 250, 0)
    checkbox:SetScript("OnClick", function(self)
        GetSettings().hideHairOnCloakPreview = self:GetChecked() ~= nil
    end)
    local label = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetText("Hide hair on cloak preview")
    label:SetPoint("LEFT", checkbox, "RIGHT", 4, 2)
end


do  --------- Hide hair and beard on chest preview
    local settingsTab = mainFrame.tabs.settings
    settingsTab.hideHairBeardOnChestPreviewCheckBox = CreateFrame("CheckButton", "$parentHideHairBeardOnChestPreviewCheckBox", settingsTab, "ChatConfigCheckButtonTemplate")
    
    local checkbox = settingsTab.hideHairBeardOnChestPreviewCheckBox
    checkbox:SetPoint("TOP", settingsTab.hideHairOnCloakPreviewCheckBox, "BOTTOM", 0, -10)
    checkbox:SetScript("OnClick", function(self)
        GetSettings().hideHairBeardOnChestPreview = self:GetChecked() ~= nil
    end)
    local label = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetText("Hide hair and beard on chest,\nshirt, and tabard previews")
    label:SetJustifyH("LEFT")
    label:SetPoint("LEFT", checkbox, "RIGHT", 4, 2)
end


do  --------- Use server time in received appearances
    local settingsTab = mainFrame.tabs.settings
    settingsTab.useServerTimeInReceivedAppearancesCheckBox = CreateFrame("CheckButton", "$parentUseServerTimeInReceivedAppearancesCheckBox", settingsTab, "ChatConfigCheckButtonTemplate")
    
    local checkbox = settingsTab.useServerTimeInReceivedAppearancesCheckBox
    checkbox:SetPoint("TOP", settingsTab.showShortcutsInTooltipCheckBox, "BOTTOM", 0, -30)
    checkbox:SetScript("OnClick", function(self)
        GetSettings().useServerTimeInReceivedAppearances = self:GetChecked() ~= nil
    end)
    local label = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetText("Use Server Time in \"Received\nAppearences\" list")
    label:SetJustifyH("LEFT")
    label:SetPoint("LEFT", checkbox, "RIGHT", 4, 2)
end


do  --------- Announce appearance receiving
    local settingsTab = mainFrame.tabs.settings
    settingsTab.announceAppearanceReceivingCheckBox = CreateFrame("CheckButton", "$parentAnnounceAppearanceReceivingCheckBox", settingsTab, "ChatConfigCheckButtonTemplate")
    
    local checkbox = settingsTab.announceAppearanceReceivingCheckBox
    checkbox:SetPoint("TOP", settingsTab.useServerTimeInReceivedAppearancesCheckBox, "BOTTOM", 0, -10)
    checkbox:SetScript("OnClick", function(self)
        GetSettings().announceAppearanceReceiving = self:GetChecked() ~= nil
    end)
    local label = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetText("Announce in the chat if an appearance\nhas been received from another player")
    label:SetJustifyH("LEFT")
    label:SetPoint("LEFT", checkbox, "RIGHT", 4, 2)
end


do  --------- Ignore UI sclaing
    local settingsTab = mainFrame.tabs.settings
    settingsTab.ignoreUIScalingCheckBox = CreateFrame("CheckButton", "$parentIgnoreUIScalingCheckBox", settingsTab, "ChatConfigCheckButtonTemplate")
    
    local checkbox = settingsTab.ignoreUIScalingCheckBox
    checkbox:SetPoint("TOP", settingsTab.announceAppearanceReceivingCheckBox, "BOTTOM", 0, -30)
    checkbox:SetScript("OnClick", function(self)
        GetSettings().ignoreUIScaling = self:GetChecked() ~= nil
        if self:GetChecked() then
            mainFrame:SetParent(nil)
            mainFrame:SetScale(0.9)
        else
            mainFrame:SetParent(UIParent)
            mainFrame:SetScale(1)
        end
        if mainFrame:IsVisible() then
            -- only to update the main dressing room
            mainFrame:Hide()
            mainFrame:Show()
        end
    end)
    local origingSetChecked = checkbox.SetChecked
    checkbox.SetChecked = function(self, enable)
        origingSetChecked(self, enable)
        checkbox:GetScript("OnClick")(self)
    end
    checkbox:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("Ignore UI scaling")
        GameTooltip:AddLine("The game's 3D rendering can break correct displaying of previews with too small values of UI scaling in video settings. Set this checkbox to ignore UI scaling.", 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    checkbox:HookScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    local label = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetText("Ignore UI scaling")
    label:SetPoint("LEFT", checkbox, "RIGHT", 4, 2)
end



do  --------- Apply settings on addon loaded
    local settingsTab = mainFrame.tabs.settings

    local function applySettings(settings)
        -- Dressing room background color
        settingsTab:SetCharacterBackground(settings.dressingRoomBackgroundTexture[GetRealmName()][GetUnitName("player")], unpack(settings.dressingRoomBackgroundColor))
        -- Preview setup popup menu
        settingsTab:SetPreviewSetup(settings.previewSetup)
        -- Show/hide "DressMe" button
        settingsTab.showDressMeButtonCheckBox:SetChecked(settings.showDressMeButton)
        if settings.showDressMeButton then
            btnDressMe:Show()
        else
            btnDressMe:Hide()
        end
        -- Show shortcuts in tooltip
        settingsTab.showShortcutsInTooltipCheckBox:SetChecked(settings.showShortcutsInTooltip)
        -- Hide hair on cloak preview
        settingsTab.hideHairOnCloakPreviewCheckBox:SetChecked(settings.hideHairOnCloakPreview)
        -- Hide hair and beard on chest preview
        settingsTab.hideHairBeardOnChestPreviewCheckBox:SetChecked(settings.hideHairBeardOnChestPreview)
        -- Use server time in Received Appearences list
        settingsTab.useServerTimeInReceivedAppearancesCheckBox:SetChecked(settings.useServerTimeInReceivedAppearances)
        -- Announce appearance receiving
        settingsTab.announceAppearanceReceivingCheckBox:SetChecked(settings.announceAppearanceReceiving)
        -- Ignore UI scaling
        settingsTab.ignoreUIScalingCheckBox:SetChecked(settings.ignoreUIScaling)
    end

    settingsTab:RegisterEvent("ADDON_LOADED")
    settingsTab:SetScript("OnEvent", function(self, event, addonName)
        if addonName == addon then
            if event == "ADDON_LOADED" then
                applySettings(GetSettings())
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
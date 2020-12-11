local addon, ns = ...


StaticPopupDialogs["DRESSME_WOWHEAD_URL_DIALOG"] = {
    text = "DRESSME_WOWHEAD_URL_DIALOG",
    button1 = "Version",
    button2 = CLOSE,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    hasEditBox = true,
    hasWideEditBox = true,
    preferredIndex = 3,
    OnAccept = function(self)
    end
}


function ns:ShowWowheadURLDialog(itemId)
    local isRetail = true
    local isCanceled = false

    StaticPopupDialogs["DRESSME_WOWHEAD_URL_DIALOG"].OnShow = function (self)
        self.text:SetText(("Wowhead \124cff00ff00%s\124r"):format(isRetail and "Retail" or "Classic"))
        self.wideEditBox:SetText(("https://%s.wowhead.com/item=%s"):format((isRetail and "www" or "classic"), itemId))
        self.wideEditBox:HighlightText()
        self.button1:SetText(isRetail and "Classic" or "Retail")
    end

    StaticPopupDialogs["DRESSME_WOWHEAD_URL_DIALOG"].OnAccept = function(self)
        isRetail = not isRetail
        isCanceled = true
        StaticPopup_Hide("DRESSME_WOWHEAD_URL_DIALOG")
    end

    StaticPopupDialogs["DRESSME_WOWHEAD_URL_DIALOG"].OnCancel = function(self)
        isCanceled = false
    end

    StaticPopupDialogs["DRESSME_WOWHEAD_URL_DIALOG"].OnHide = function(self)
        if isCanceled then
            StaticPopup_Show("DRESSME_WOWHEAD_URL_DIALOG")
        end
    end

    if StaticPopup_Visible("DRESSME_WOWHEAD_URL_DIALOG") then
        StaticPopup_Hide("DRESSME_WOWHEAD_URL_DIALOG")
    end
    StaticPopup_Show("DRESSME_WOWHEAD_URL_DIALOG")
end
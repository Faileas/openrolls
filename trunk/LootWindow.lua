OpenRolls = LibStub("AceAddon-3.0"):GetAddon("OpenRolls")

do
    local function AttachMouseoverText(frame, text, r, g, b, a)
        frame:EnableMouse()
        frame:SetScript("OnEnter", function(self, ...) 
            local GT = GameTooltip
            GT:SetOwner(self, "ANCHOR_TOPLEFT")
            GT:SetText(text, r, g, b, a)
            GT:Show()
        end)
        frame:SetScript("OnLeave", function(self, ...) GameTooltip:Hide() end)
    end
    
    local function Release(self)
        self:ClearAllPoints()
        self:Hide()
    end
    
    function OpenRolls:CreateLootWindow(framename, parent, lootslot)
        local self = CreateFrame("frame", framename, parent)
        self.lootSlot = lootslot
        
        self:SetBackdrop({
            bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", 
            tile = true, tileSize = 32, edgeSize = 32, 
            insets = { left = 8, right = 8, top = 8, bottom = 8 }
        }  )
        self:SetBackdropColor(0,0,0,1)
        self:SetToplevel(true)
        self:SetFrameStrata("FULLSCREEN_DIALOG")        
        self:SetWidth(278)
        self:SetHeight(100)

        local icon = CreateFrame("Frame", framename .. "Icon", self)
        icon:SetHeight(52)
        icon:SetWidth(52)
        icon:EnableMouse()
        icon:SetScript("OnLeave", function(frame, ...) GameTooltip:Hide() end)
        icon:SetPoint("TOPLEFT", self, "TOPLEFT", 15, -15)
        icon:SetBackdrop({
            bgFile=(GetLootSlotInfo(lootslot)),
            edgeFile=nil,
            tile = false, tileSize = 32, edgeSize = 32, 
            insets = { left = 0, right = 0, top = 0, bottom = 0 }
        })
        icon:SetScript("OnEnter", function(frame, ...)
            local GameTooltip = GameTooltip
            GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
            GameTooltip:SetHyperlink(GetLootSlotLink(lootslot))
            GameTooltip:Show()
        end)        
        
        local ignore = CreateFrame("button", framename .. "Ignore", self, "UIPanelCloseButton")
        ignore:SetPoint("TOPRIGHT", self, "TOPRIGHT", -4, -4)
        ignore:SetScript("OnClick", nil)
    
        local name = self:CreateFontString(framename .. "Name", "OVERLAY", "GameFontNormal")
        name:SetJustifyH("CENTER")
        name:SetPoint("TOPLEFT", icon, "TOPRIGHT")
        name:SetText(GetLootSlotLink(lootslot))
        name:SetPoint("RIGHT", ignore, "LEFT", 4, 0)
        
        local chant = CreateFrame("button", framename .. "Disenchant", self, "UIPanelButtonTemplate")
        chant:SetPoint("LEFT", name, "LEFT")
        chant:SetPoint("TOP", ignore, "BOTTOM", 0, 6)
        chant:SetHeight(20)
        chant:SetWidth(100)
        chant:SetText("Disenchant")
        chant:SetScript("OnClick", nil)
        
        local bank = CreateFrame("button", framename .. "Bank", self, "UIPanelButtonTemplate")
        bank:SetPoint("TOPLEFT", chant, "TOPRIGHT")
        bank:SetHeight(20)
        bank:SetWidth(100)
        bank:SetText("Bank")
        bank:SetScript("OnClick", nil)
                
        local duration = CreateFrame("EditBox", framename .. "Duration", self, "InputBoxTemplate")
        duration:SetAutoFocus(false)
        duration:SetFontObject(ChatFontNormal)
        duration:SetNumeric()
        duration:SetTextInsets(0,0,3,3)
        duration:SetMaxLetters(2)
        duration:SetPoint("TOPRIGHT", chant, "BOTTOMRIGHT")--, -5, 0)
        duration:SetHeight(20)
        duration:SetWidth(20)
        duration:SetText("30")
        AttachMouseoverText(duration, "Duration of an open roll", 1, 1, 1, 1)
        
        local open = CreateFrame("button", framename .. "Open", self, "UIPanelButtonTemplate")
        open:SetPoint("TOPRIGHT", duration, "TOPLEFT", -5, 0)
        open:SetPoint("LEFT", chant, "LEFT")
        open:SetHeight(20)
        open:SetWidth(100)
        open:SetText("Open")
        open:SetScript("OnClick", nil)
        
        local raid = CreateFrame("button", framename .. "Raid", self, "UIPanelButtonTemplate")
        raid:SetPoint("TOPRIGHT", bank, "BOTTOMRIGHT")
        raid:SetHeight(20)
        raid:SetWidth(100)
        raid:SetText("Raid")
        raid:SetScript("OnClick", nil)
        
        local assignName = CreateFrame("EditBox", framename .. "AssignName", self, "InputBoxTemplate")
        assignName:SetAutoFocus(false)
        assignName:SetFontObject(ChatFontNormal)
        assignName:SetTextInsets(0,0,3,3)
        assignName:SetMaxLetters(12)
        assignName:SetPoint("LEFT", icon, "LEFT", 5, 0)
        assignName:SetPoint("TOPRIGHT", open, "BOTTOMRIGHT")--, -5, 0)
        assignName:SetHeight(20)
        AttachMouseoverText(assignName, "User to award item to", 1, 1, 1, 1)
        
        local assign = CreateFrame("button", framename .. "Assign", self, "UIPanelButtonTemplate")
        assign:SetPoint("TOPLEFT", assignName, "TOPRIGHT")
        assign:SetPoint("TOPRIGHT", raid, "TOPRIGHT")
        assign:SetHeight(20)
        assign:SetText("Award")
        assign:SetScript("OnClick", function(frame, ...)
            local player = assignName:GetText()
            if player == "" then return end
            if not OpenRolls:DistributeItemByName(player, lootslot) then
                OpenRolls:Print(player .. " not eligible for this item.")
            end
        end)
        
        self.icon = icon
        self.name = name
        
        self.Release = Release
        
        return self
    end
end
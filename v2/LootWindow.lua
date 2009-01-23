local OpenRolls = LibStub("AceAddon-3.0"):GetAddon("OpenRolls")

--Handles the creation of a loot window

do
    --A simple helper function for frames that want to have mouseover text
    --  frame is the frame the text should be attached to
    --  text is the text to show
    --  r, g, b, a is the color the text should appear in
    --The frame gets EnableMouse() called on it, and assigned a script for the 
    --  OnEnter and OnLeave events
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
    

    --I think this is what's neccessary to free a frame for garbage collection
    local function Release(self)
        self:ClearAllPoints()
        self:Hide()
    end
    
    --Attaches a third party addon's loot window to our own
    --  addon must have a function called CreateLootWindow that returns the addon's loot frame
    --  The frame has all points cleared before being attached, so it needs to be self contained
    --    in this regard
    --Further, the frame gets two new functions added to it, SetAssign and GetAssign.  They are 
    --  used so the addon has access to the assignment frame of the base loot window
    local function AttachLootWindow(self, addon)
        if type(addon.CreateLootWindow) ~= "function" then
            error("OpenRolls: Function CreateLootWindow not found on addon object")
        end
        local frame = addon:CreateLootWindow(self.slot, self)
        --frame:SetPoint("TOPLEFT", self, "TOPLEFT", self:GetWidth(), -20)
        frame:ClearAllPoints()
        frame:SetPoint("TOP", self.ignore, "BOTTOM", 0, 6)
        frame:SetPoint("LEFT", self, "LEFT", self:GetWidth() - 12, 0)
        
        frame.SetAssign = function(f, player)
            self.assignName:SetText(player)
        end
        
        frame.GetAssign = function(f)
            return self.assignName:GetText()
        end
        
        self:SetWidth(self:GetWidth() + frame:GetWidth())
        
        table.insert(self.attachedFrames, frame)
        
        if frame:GetHeight() > self:GetHeight() then 
            self:SetHeight(frame:GetHeight())
        end
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
            GameTooltip:SetLootItem(lootslot)
            GameTooltip:Show()
        end)        
        
        local ignore = CreateFrame("button", framename .. "Ignore", self, "UIPanelCloseButton")
        ignore:SetPoint("TOPRIGHT", self, "TOPRIGHT", -4, -4)
        ignore:SetScript("OnClick", function(frame, ...)
            frame:GetParent():Release()
        end)
    
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
        chant:SetScript("OnClick", function(frame, ...)
            local player = OpenRolls:GetDisenchanter()
            local parent = frame:GetParent()
            local item = GetLootSlotLink(parent.slot)
            if player == "" then return end
            local followup = function(window, player)
                local item = GetLootSlotLink(window.slot)
                for _, j in pairs(window.attachedFrames) do
                    if type(j.AwardToDisenchanter) == 'function' then
                        j:AwardToDisenchanter(player, item)
                    end
                end
            end
            if not OpenRolls:DistributeItemByName(player, parent, followup) then
                OpenRolls:Print(player .. " is not eligible for this item.")
                return
            end
        end)
        
        local bank = CreateFrame("button", framename .. "Bank", self, "UIPanelButtonTemplate")
        bank:SetPoint("TOPLEFT", chant, "TOPRIGHT")
        bank:SetHeight(20)
        bank:SetWidth(100)
        bank:SetText("Bank")
        bank:SetScript("OnClick", function(frame, ...)
            local player = OpenRolls:GetBanker()
            local parent = frame:GetParent()
            local item = GetLootSlotLink(parent.slot)
            if player == "" then return end
            local followup = function(window, player)
            local item = GetLootSlotLink(window.slot)
                for _, j in pairs(window.attachedFrames) do
                    if type(j.AwardToBanker) == 'function' then
                        j:AwardToBanker(player, item)
                    end
                end
            end
            if not OpenRolls:DistributeItemByName(player, parent, followup) then
                OpenRolls:Print(player .. " is not eligible for this item.")
                return
            end
        end)
        
        local open = CreateFrame("button", framename .. "Open", self, "UIPanelButtonTemplate")
        open:SetPoint("TOPRIGHT", chant, "BOTTOMRIGHT")
        open:SetPoint("LEFT", chant, "LEFT")
        open:SetHeight(20)
        open:SetWidth(100)
        open:SetText("Open")
        open:SetScript("OnClick", function(frame, ...)
            local parent = frame:GetParent()
            OpenRolls:Roll(GetLootSlotLink(parent.slot), 1)
        end)
        
        local raid = CreateFrame("button", framename .. "Raid", self, "UIPanelButtonTemplate")
        raid:SetPoint("TOPRIGHT", bank, "BOTTOMRIGHT")
        raid:SetHeight(20)
        raid:SetWidth(100)
        raid:SetText("Raid")
        raid:SetScript("OnClick", function(frame, ...)
            local candidates = {}
            local parent = frame:GetParent()

            local item = GetLootSlotLink(parent.slot)
            local rarity = (select(3, GetItemInfo(item)));
            local confirm = OpenRollsData.ConfirmBeforeLooting 
                          and ((rarity > 2) or not OpenRollsData.ConfirmGreens)
            for i = 1, 40 do
                if GetMasterLootCandidate(i) ~= nil then
                    table.insert(candidates, {index = i, name = GetMasterLootCandidate(i)})
                end
            end
            local candidate = math.random(#candidates)
            local i = candidates[candidate].index
            local name = candidates[candidate].name
            if confirm then
                local str = "Do you wish to award " .. item .. " to " .. name .. "?"
                LibStub("dzjrGUI").MessageBox:new(str, 
                                                  function() GiveMasterLoot(parent.slot, i) end, 
                                                  function() end)
            else
                GiveMasterLoot(parent.slot, i)
            end
            parent.assignName:SetText(name)
        end)
        
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
            local window = frame:GetParent()
            local player = window.assignName:GetText()
            local item = GetLootSlotLink(window.slot)
            if player == "" then return end
            local followup = function(window, player)
                local item = GetLootSlotLink(window.slot)
                for _, j in pairs(window.attachedFrames) do
                    if type(j.AwardToPlayer) == 'function' then
                        j:AwardToPlayer(player, item)
                    end
                end
            end
            if not OpenRolls:DistributeItemByName(player, window, followup) then
                OpenRolls:Print(player .. " not eligible for this item.")
                return
            end
        end)
        
        self.slot = lootslot
        self.icon = icon
        self.name = name
        self.raid = raid
        self.open = open
        self.assign = assign
        self.assignName = assignName
        self.duration = duration
        self.chant = chant
        self.bank = bank
        self.ignore = ignore
        self.attachedFrames = {}
        
        self.Release = Release
        self.AttachLootWindow = AttachLootWindow

        return self
    end
end
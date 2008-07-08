local tostring = tostring

do
    local function GetRolledColor()
        return 0, 1, 0
    end
    
    local function GetWaitingColor()
        return 0.5, 0.5, 0.5
    end
    
    local function GetPassedColor()
        return 0.5, 0.5, 0.5
    end
    
    local function GetOfflineColor()
        return 1, 0, 0
    end

    local function OnEnter(self, ...)
        local GameTooltip = GameTooltip
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:AddDoubleLine(self.name, self.RollString:GetText(), self.r, self.g, self.b, self.r, self.g, self.b)
        for single, func in OpenRolls:SummaryHooks() do
            if single then
                GameTooltip:AddLine(func(self.name, self.roll))
            else
                GameTooltip:AddDoubleLine(func(self.name, self.roll))
            end
        end
        GameTooltip:Show()
    end
    
    local function OnLeave(self, ...)
        GameTooltip:Hide()
    end
    
    local function GetPlayer(self)
        return self.name
    end
    
    local function SetPlayer(self, text)
        self.name = text
        self.NameString:SetText(text)
    end
    
    local function SetRoll(self, roll)
        if roll <= 0 then
            self:PassRoll()
        else
            self.roll = roll
            self.RollString:SetText(tostring(roll))
            self.RollString:SetTextColor(GetRolledColor())
            self.NameString:SetTextColor(GetRolledColor())
        end
    end
    
    local function PassRoll(self)
        self.roll = 0
        self.RollString:SetText("Passed")
        self.RollString:SetTextColor(GetPassedColor())
        self.NameString:SetTextColor(GetPassedColor())
    end
    
    local function ClearRoll(self)
        self.roll = -1
        self.RollString:SetText("Waiting...")
        self.RollString:SetTextColor(GetWaitingColor())
        self.NameString:SetTextColor(GetWaitingColor())
    end    
    
    local function SetOffline(self)
        self.roll = -2
        self.RollString:SetText("Offline")
        self.RollString:SetTextColor(GetOfflineColor())
        self.NameString:SetTextColor(GetOfflineColor())
    end
    
    local function Value(self)
        return self.roll
    end
    
    local function Compare(self, other)
        if self.roll < other.roll then return true end
        if self.roll > other.roll then return false end
        return self.name < other.name
    end
    
    function OpenRolls:CreateSummaryLine(framename, parent, player)
        local self = CreateFrame("frame", framename, parent)
        self:EnableMouse()
        self:SetScript("OnEnter", function(self, ...) self:OnEnter() end)
        self:SetScript("OnLeave", function(self, ...) self:OnLeave() end)
            
        local name = self:CreateFontString(framename .. "Name", "OVERLAY", "GameFontNormal")
        name:SetJustifyH("LEFT")
        name:SetPoint("TOPLEFT", self, "TOPLEFT")
        name:SetText(player)
        self.name = player
        self.NameString = name
    
        local roll = self:CreateFontString(framename .. "Roll", "OVERLAY", "GameFontNormal")
        roll:SetJustifyH("RIGHT")
        roll:SetPoint("TOPRIGHT", self, "TOPRIGHT")
        self.RollString = roll
        
        self:SetHeight(name:GetHeight())
        
        self.OnEnter = OnEnter
        self.OnLeave = OnLeave
        self.GetPlayer = GetPlayer
        self.SetPlayer = SetPlayer
        self.SetRoll = SetRoll
        self.PassRoll = PassRoll
        self.ClearRoll = ClearRoll
        self.SetOffline = SetOffline
        self.Value = Value
        self.Compare = Compare        
        return self
    end
end
local tostring = tostring

do

    local info = {}

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
    
    local function OnMouseUp(self, ...)
        ToggleDropDownMenu(1, nil, self.menu, self, 0, 0);
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
    
    local function HasPassed(self)
        return self.roll == 0
    end
    
    local function ClearRoll(self)
        self.roll = -1
        self.RollString:SetText("Waiting...")
        self.RollString:SetTextColor(GetWaitingColor())
        self.NameString:SetTextColor(GetWaitingColor())
    end
    
    local function IsWaiting(self)
        return self.roll == -1
    end
    
    local function SetOffline(self)
        self.roll = -2
        self.RollString:SetText("Offline")
        self.RollString:SetTextColor(GetOfflineColor())
        self.NameString:SetTextColor(GetOfflineColor())
    end
    
    local function IsOffline(self)
        return self.roll == -2
    end
    
    local function Value(self)
        return self.roll
    end
    
    local function Compare(self, other)
        if self.roll < other.roll then return true end
        if self.roll > other.roll then return false end
        return self.name < other.name
    end
    
    local function CreateMenu(self, framename)
        local menu = CreateFrame("Frame", framename .. "Menu", self)
        menu.displayMode = "MENU"
        menu.initialize = function()    
            for k in pairs(info) do info[k] = nil end
            -- Create the title of the menu
            info.isTitle		= 1
            info.text		    = self.name
            info.notCheckable	= 1
            UIDropDownMenu_AddButton(info, level)

            info.isTitle		= nil
            info.notCheckable	= nil
            info.disabled		= self:IsOffline() or nil

            -- Menu Item 1
            info.text		= "Pass"
            info.func		= function() self:PassRoll() OpenRolls:UpdateRollList() end
            info.arg1		= 1
            UIDropDownMenu_AddButton(info, level)
            
            --Menu Item 2
            info.text		= "Reset"
            info.func		= function(arg1) self:ClearRoll() OpenRolls:UpdateRollList() end
            info.arg1		= 2
            UIDropDownMenu_AddButton(info, level)

            -- Close menu item
            info.disabled   = nil
            info.arg1		= nil
            info.hasArrow	= nil
            info.text		= CLOSE
            info.func		= CloseDropDownMenus
            UIDropDownMenu_AddButton(info, level)
        end
        
        return menu
    end
    
    function OpenRolls:CreateSummaryLine(framename, parent, player)
        local self = CreateFrame("frame", framename, parent)
        self:EnableMouse()
        self:SetScript("OnEnter", function(self, ...) self:OnEnter() end)
        self:SetScript("OnLeave", function(self, ...) self:OnLeave() end)
        self:SetScript("OnMouseUp", function(self, ...) self:OnMouseUp() end)

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

        self.menu = CreateMenu(self, framename)

        self:SetHeight(name:GetHeight())

        self.OnEnter = OnEnter
        self.OnLeave = OnLeave
        self.OnMouseUp = OnMouseUp
        self.GetPlayer = GetPlayer
        self.SetPlayer = SetPlayer
        self.SetRoll = SetRoll
        self.PassRoll = PassRoll
        self.HasPassed = HasPassed
        self.ClearRoll = ClearRoll
        self.IsWaiting = IsWaiting
        self.SetOffline = SetOffline
        self.IsOffline = IsOffline
        self.Value = Value
        self.Compare = Compare        
        return self
    end
end
--[[
Provides the configuration panel within the Blizzard options frame
]]--

do    
    local pairs = pairs
    
    --Builds a series of radio buttons on top of each other
    --name and parent are self explanatory
    --options is a table with each element corresponding to a button
    --  the index is the value that should be returned by GetSetting when that button is selected
    --  the value is the text that should show next to the button itself
    local function CreateRadioGroup(options, name, parent)
        local frame = CreateFrame("frame", name, parent)
        local radio = {}
        local i = 0
        local init = nil
        local max, cur = 0, 0
        local height = 0
        for pos, j in pairs(options) do
            local r = CreateFrame("CheckButton", name .. "Radio" .. i, frame, "UIRadioButtonTemplate")
            r:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -i*20)
            r.parent = frame
            r.position = pos
            r:SetScript("OnClick", function(self, ...)
                self.parent:Click(self.position)
            end)
            if init == nil then 
                init = pos
                r:SetChecked(true)
            end

            local s = frame:CreateFontString(name .. "RadioString" .. i, "OVERLAY", "GameFontNormal")
            s:SetPoint("TOPLEFT", r, "TOPRIGHT")
            s:SetText(j)

            cur = s:GetWidth() + r:GetWidth()
            if cur > max then max = cur end
            height = height + s:GetHeight() + 5

            radio[pos] = {button = r, text = s}
            i = i + 1
        end

        frame.Click = function(self, position)
            if position ~= self.checked then
                self.radio[self.checked].button:SetChecked(false)
                self.checked = position
            end
            self.radio[position].button:SetChecked(true)
        end

        frame.GetSetting = function(self)
            return frame.checked
        end

        frame:SetWidth(max)
        frame:SetHeight(height)
        frame.radio = radio
        frame.checked = init
        return frame
    end
    
    local ConfigPanel = CreateFrame("frame", "OpenRollsConfig")

    local WhenShowString = 
        ConfigPanel:CreateFontString("OpenRollsConfigWhenShowString", "OVERLAY", "GameFontNormal")
    WhenShowString:SetPoint("TOPLEFT", ConfigPanel, "TOPLEFT", 6, -6)
    WhenShowString:SetText("When should loot windows display?")
        
    local WhenShowBox = CreateRadioGroup({always = "Always", 
                                          whenML = "When Masterlooter", 
                                          never = "Never"}, 
                                        "OpenRollsConfigWhenShow", 
                                        ConfigPanel)
    WhenShowBox:SetPoint("TOPLEFT", WhenShowString, "BOTTOMLEFT", 20, -6)
    WhenShowBox:Click('whenML')

    local RemindBox = CreateFrame("CheckButton", "OpenRollsConfigRemindBox", ConfigPanel, "UICheckButtonTemplate")
    RemindBox:SetPoint("TOPLEFT", WhenShowBox, "BOTTOMLEFT", -20, -6)
    
    local RemindString = 
        ConfigPanel:CreateFontString("OpenRollsConfigRemindString", "OVERLAY", "GameFontNormal")
    RemindString:SetPoint("CENTER", RemindBox, "CENTER")
    RemindString:SetPoint("LEFT", RemindBox, "RIGHT")
    RemindString:SetText("Display roll summary window when roll is complete?")
    
    local ConfirmBox = CreateFrame("CheckButton", "OpenRollsConfigConfirmBox", ConfigPanel, "UICheckButtonTemplate")
    ConfirmBox:SetPoint("TOPLEFT", RemindBox, "BOTTOMLEFT", 0, 0)
    
    local ConfirmString = 
        ConfigPanel:CreateFontString("OpenRollsConfigConfirmString", "OVERLAY", "GameFontNormal")
    ConfirmString:SetPoint("CENTER", ConfirmBox, "CENTER")
    ConfirmString:SetPoint("LEFT", ConfirmBox, "RIGHT")
    ConfirmString:SetText("Confirm before looting?")
    
    local WarningBox = CreateFrame("CheckButton", "OpenRollsConfigWarningBox", ConfigPanel, "UICheckButtonTemplate")
    WarningBox:SetPoint("TOPLEFT", ConfirmBox, "BOTTOMLEFT", 0, 0)
    
    local WarningString = 
        ConfigPanel:CreateFontString("OpenRollsConfigWarningString", "OVERLAY", "GameFontNormal")
    WarningString:SetPoint("CENTER", WarningBox, "CENTER")
    WarningString:SetPoint("LEFT", WarningBox, "RIGHT")
    WarningString:SetText("Provide warning period?")
    
    local MainDuration = CreateFrame("EditBox", "OpenRollsConfigMainDuration", ConfigPanel, "InputBoxTemplate")
    MainDuration:SetAutoFocus(false)
    MainDuration:SetFontObject(ChatFontNormal)
    MainDuration:SetNumeric()
    MainDuration:SetTextInsets(0, 0, 3, 3)
    MainDuration:SetMaxLetters(3)
    MainDuration:SetPoint("TOPLEFT", WarningBox, "BOTTOMLEFT", 10, 0)
    MainDuration:SetHeight(20)
    MainDuration:SetWidth(30)
    
    local MainDurationString = 
        ConfigPanel:CreateFontString("OpenRollsConfigMainDurationString", "OVERLAY", "GameFontNormal")
    MainDurationString:SetPoint("CENTER", MainDuration, "CENTER")
    MainDurationString:SetPoint("LEFT", MainDuration, "RIGHT")
    MainDurationString:SetText("Length of silent countdown")
    
    local SubDuration = CreateFrame("EditBox", "OpenRollsConfigSubDuration", ConfigPanel, "InputBoxTemplate")
    SubDuration:SetAutoFocus(false)
    SubDuration:SetFontObject(ChatFontNormal)
    SubDuration:SetNumeric()
    SubDuration:SetTextInsets(0, 0, 3, 3)
    SubDuration:SetMaxLetters(3)
    SubDuration:SetPoint("TOPLEFT", MainDuration, "BOTTOMLEFT", 0, -10)
    SubDuration:SetHeight(20)
    SubDuration:SetWidth(30)
    
    local SubDurationString = 
        ConfigPanel:CreateFontString("OpenRollsConfigSubDurationString", "OVERLAY", "GameFontNormal")
    SubDurationString:SetPoint("CENTER", SubDuration, "CENTER")
    SubDurationString:SetPoint("LEFT", SubDuration, "RIGHT")
    SubDurationString:SetText("Length of spammed countdown")
    
    local ShowAnchorButton = CreateFrame("button", "OpenRollsConfigShowAnchor", ConfigPanel, "UIPanelButtonTemplate")
    ShowAnchorButton:SetPoint("TOPLEFT", SubDuration, "BOTTOMLEFT", -5, -10)
    ShowAnchorButton:SetHeight(20)
    ShowAnchorButton:SetWidth(100)
    ShowAnchorButton:SetText("Show Anchor")
    ShowAnchorButton:SetScript("OnClick", function(frame, ...) 
        local anchor = OpenRolls.anchor
        if anchor:IsShown() then
            anchor:Hide()
            frame:SetText("Show Anchor")
        else
            anchor:Show()
            frame:SetText("Hide Anchor")
        end
    end)
    
    ConfigPanel:SetScript("OnShow", function(self, ...)
        local Data = OpenRollsData
        WhenShowBox:Click(Data.ShowLootWindows)
        RemindBox:SetChecked(Data.ShowSummaryWhenRollsOver)
        ConfirmBox:SetChecked(Data.ConfirmBeforeLooting)
        WarningBox:SetChecked(Data.Warning)
        MainDuration:SetText(Data.SilentTime)
        SubDuration:SetText(Data.CountdownTime)

        local anchor,x,y = select(3, OpenRolls.anchor:GetPoint(1))
        Data.LootFramesAnchor = anchor
        Data.LootFramesOffset = {horizontal = math.floor(x), vertical = math.floor(y)} 
    end)
    
    ConfigPanel.name = "Open Rolls"
    ConfigPanel.okay = function() 
        local Data = OpenRollsData
        Data.ShowSummaryWhenRollsOver = not not RemindBox:GetChecked()
        Data.ShowLootWindows = WhenShowBox:GetSetting()
        Data.ConfirmBeforeLooting = not not ConfirmBox:GetChecked()
        Data.Warning = not not WarningBox:GetChecked()
        Data.SilentTime = tonumber(MainDuration:GetText())
        Data.CountdownTime = tonumber(SubDuration:GetText())

        local anchor,x,y = select(3, OpenRolls.anchor:GetPoint(1))
        Data.LootFramesAnchor = anchor
        Data.LootFramesOffset = {horizontal = math.floor(x), vertical = math.floor(y)}   
    end
    
    ConfigPanel.cancel = function()
        local Data = OpenRollsData
        OpenRolls.anchor:ClearAllPoints()
        OpenRolls.anchor:SetPoint(Data.LootFramesAnchor, UIParent, Data.LootFramesAnchor, Data.LootFramesOffset.horizontal, Data.LootFramesOffset.vertical)
    end
    InterfaceOptions_AddCategory(ConfigPanel)
end
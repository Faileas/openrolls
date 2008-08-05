do    
    local pairs = pairs
    
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
    
    ConfigPanel:SetScript("OnShow", function(self, ...)
        local Data = OpenRollsData
        WhenShowBox:Click(Data.ShowLootWindows)
        RemindBox:SetChecked(Data.ShowSummaryWhenRollsOver)
        ConfirmBox:SetChecked(Data.ConfirmBeforeLooting)
    end)
    
    ConfigPanel.name = "Open Rolls"
    ConfigPanel.okay = function() 
        local Data = OpenRollsData
        Data.ShowSummaryWhenRollsOver = not not RemindBox:GetChecked()
        Data.ShowLootWindows = WhenShowBox:GetSetting()
        Data.ConfirmBeforeLooting = not not ConfirmBox:GetSetting()
    end
    InterfaceOptions_AddCategory(ConfigPanel)
end
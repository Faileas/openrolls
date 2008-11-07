--[[
Provides the configuration panel within the Blizzard options frame
]]--

do    
local pairs = pairs

local GUILib = LibStub("dzjrGUI")

local function CreateMainConfig(name)
    local ConfigPanel = CreateFrame("frame", name)

    local WhenShowString = 
        ConfigPanel:CreateFontString(name .."WhenShowString", "OVERLAY", "GameFontNormal")
    WhenShowString:SetPoint("TOPLEFT", ConfigPanel, "TOPLEFT", 6, -6)
    WhenShowString:SetText("When should loot windows display?")
        
    local WhenShowBox = GUILib.RadioGroup({always = "Always", 
                                          whenML = "When Masterlooter", 
                                          never = "Never"}, 
                                        name .. "WhenShow", 
                                        ConfigPanel)
    WhenShowBox:SetPoint("TOPLEFT", WhenShowString, "BOTTOMLEFT", 20, -6)
    WhenShowBox:Click('whenML')

    local RemindBox = CreateFrame("CheckButton", name .. "RemindBox", ConfigPanel, "UICheckButtonTemplate")
    RemindBox:SetPoint("TOPLEFT", WhenShowBox, "BOTTOMLEFT", -20, -6)

    local RemindString = 
        ConfigPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    RemindString:SetPoint("CENTER", RemindBox, "CENTER")
    RemindString:SetPoint("LEFT", RemindBox, "RIGHT")
    RemindString:SetText("Display roll summary window when roll is complete?")

    local ConfirmBox = CreateFrame("CheckButton", name .. "ConfirmBox", ConfigPanel, "UICheckButtonTemplate")
    ConfirmBox:SetPoint("TOPLEFT", RemindBox, "BOTTOMLEFT", 0, 0)

    local ConfirmString = ConfigPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    ConfirmString:SetPoint("CENTER", ConfirmBox, "CENTER")
    ConfirmString:SetPoint("LEFT", ConfirmBox, "RIGHT")
    ConfirmString:SetText("Confirm before looting?")

    local WarningBox = CreateFrame("CheckButton", name .. "WarningBox", ConfigPanel, "UICheckButtonTemplate")
    WarningBox:SetPoint("TOPLEFT", ConfirmBox, "BOTTOMLEFT", 0, 0)

    local WarningString = 
        ConfigPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    WarningString:SetPoint("CENTER", WarningBox, "CENTER")
    WarningString:SetPoint("LEFT", WarningBox, "RIGHT")
    WarningString:SetText("Provide warning period?")

    local MainDuration = CreateFrame("EditBox", name .. "MainDuration", ConfigPanel, "InputBoxTemplate")
    MainDuration:SetAutoFocus(false)
    MainDuration:SetFontObject(ChatFontNormal)
    MainDuration:SetNumeric()
    MainDuration:SetTextInsets(0, 0, 3, 3)
    MainDuration:SetMaxLetters(3)
    MainDuration:SetPoint("TOPLEFT", WarningBox, "BOTTOMLEFT", 10, 0)
    MainDuration:SetHeight(20)
    MainDuration:SetWidth(30)

    local MainDurationString = 
        ConfigPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    MainDurationString:SetPoint("CENTER", MainDuration, "CENTER")
    MainDurationString:SetPoint("LEFT", MainDuration, "RIGHT")
    MainDurationString:SetText("Length of silent countdown")

    local SubDuration = CreateFrame("EditBox", name .. "SubDuration", ConfigPanel, "InputBoxTemplate")
    SubDuration:SetAutoFocus(false)
    SubDuration:SetFontObject(ChatFontNormal)
    SubDuration:SetNumeric()
    SubDuration:SetTextInsets(0, 0, 3, 3)
    SubDuration:SetMaxLetters(3)
    SubDuration:SetPoint("TOPLEFT", MainDuration, "BOTTOMLEFT", 0, -10)
    SubDuration:SetHeight(20)
    SubDuration:SetWidth(30)

    local SubDurationString = 
        ConfigPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    SubDurationString:SetPoint("CENTER", SubDuration, "CENTER")
    SubDurationString:SetPoint("LEFT", SubDuration, "RIGHT")
    SubDurationString:SetText("Length of spammed countdown")

    ConfigPanel.LoadData = function()
        local Data = OpenRollsData
        WhenShowBox:Click(Data.ShowLootWindows)
        RemindBox:SetChecked(Data.ShowSummaryWhenRollsOver)
        ConfirmBox:SetChecked(Data.ConfirmBeforeLooting)
        WarningBox:SetChecked(Data.Warning)
        MainDuration:SetText(Data.SilentTime)
        SubDuration:SetText(Data.CountdownTime)
    end
    
    ConfigPanel:SetScript("OnShow", function(self, ...)
        if not ConfigPanel.OriginalValues then
            ConfigPanel.LoadData()
            local Data = OpenRollsData
            ConfigPanel.OriginalValues = {
                ShowLootWindows = Data.ShowLootWindows,
                ShowSummaryWhenRollsOver = Data.ShowSummaryWhenRollsOver,
                ConfirmBeforeLooting = Data.ConfirmBeforeLooting,
                Warning = Data.Warning,
                SilentTime = Data.SilentTime,
                CountdownTime = Data.CountdownTime
            }
        end
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
        
        ConfigPanel.OriginalValues = nil
    end
    
    ConfigPanel.default = function()
        local Data = OpenRollsData
        Data.ShowSummaryWhenRollsOver = nil
        Data.ShowLootWindows = nil
        Data.ConfirmBeforeLooting = nil
        Data.Warning = nil
        Data.SilentTime = nil
        Data.CountdownTime = nil
        
        ConfigPanel.LoadData()
    end
    
    ConfigPanel.cancel = function()
        local Data = OpenRollsData
        for i,j in pairs(ConfigPanel.OriginalValues) do
            Data[i] = j
        end
        ConfigPanel.OriginalValues = nil
    end

    local obj = GUILib.Slider:new("horizontal", 0, 100, 1, "OpenRollsConfigSlider", ConfigPanel)
    obj:SetWidth(100)
    obj:SetPoint("BOTTOMLEFT", 20, 20)
    GUILib.AddMouseoverText(obj, "???")

    return ConfigPanel
end

local sampleNameFrame
local sampleAnchor
local sampleLootWindow
do --Create Sample Windows
local backdrop = {bgFile="Interface/Tooltips/UI-Tooltip-Background",
                  edgeFile=nil,  
                  tile = true, 
                  tileSize = 32, 
                  edgeSize = 32,  
                  insets = { left = 8, right = 8, top = 8, bottom = 8 }}

local frame = CreateFrame("frame", "OpenRollConfigSampleName", UIParent)
frame:SetBackdrop(backdrop) 
frame:SetBackdropColor(1,0,0,1) 
frame:SetToplevel(true) 
frame:SetFrameStrata("FULLSCREEN_DIALOG")  
frame:SetWidth(178) 
frame:SetHeight(50) 
local obj = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal") 
obj:SetPoint("CENTER", frame, "CENTER") 
obj:SetText("Name Frame")
frame:Hide()
sampleNameFrame = frame

frame = CreateFrame("frame", "OpenRollConfigSampleLoot", UIParent)
frame:SetBackdrop(backdrop) 
frame:SetBackdropColor(0,0,1,1) 
frame:SetToplevel(true) 
frame:SetFrameStrata("FULLSCREEN_DIALOG")  
frame:SetWidth(178) 
frame:SetHeight(50) 
obj = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal") 
obj:SetPoint("CENTER", frame, "CENTER") 
obj:SetText("Loot Frame")
frame:Hide()
sampleLootFrame = frame

frame = CreateFrame("frame", "OpenRollConfigSampleAnchor", UIParent)
frame:SetBackdrop(backdrop) 
frame:SetBackdropColor(0,1,0,1) 
frame:SetToplevel(true) 
frame:SetFrameStrata("FULLSCREEN_DIALOG")  
frame:SetWidth(200) 
frame:SetHeight(260) 
frame:SetPoint("TOPLEFT", LootFrame, "TOPLEFT")
obj = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal") 
obj:SetPoint("CENTER", frame, "CENTER") 
obj:SetText("Anchor")
frame:Hide()
sampleAnchor = frame
end

local function CreateNameFrameConfig(framename, name, parent)
    local panel = CreateFrame("frame", name, InterfaceOptionsFramePanelContainer)
    panel.name = name
    panel.parent = parent
    
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText("Name Frame")
    
    local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtitle:SetHeight(35)
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtitle:SetPoint("RIGHT", panel, -8, 0)
	subtitle:SetNonSpaceWrap(true)
	subtitle:SetJustifyH("LEFT")
	subtitle:SetJustifyV("TOP")
	subtitle:SetText("The name frame is the shared window that holds the name of the Banker and " ..
                     "Disenchanter.  By default, it is placed above the loot window, and moves " ..
                     "with it.")
    
    title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -8)
    title:SetText("Anchor")

    subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtitle:SetHeight(55)
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtitle:SetPoint("RIGHT", panel, -8, 0)
	subtitle:SetNonSpaceWrap(true)
	subtitle:SetJustifyH("LEFT")
	subtitle:SetJustifyV("TOP")
	subtitle:SetText("The anchor is used to attach the name frame to an existing object.  If that " ..
                     "object moves, the name frame will move with it.  'LootFrame' is the object " ..
                     "that represents a loot window.  'UIParent' represents the entire screen; " ..
                     "anchoring to this object will give the name frame a static location that " ..
                     "will not move under normal circumstances.")

    local obj = GUILib.InputBox(function(self)
        self:GetParent():UpdateData()
    end, name .. "Anchor", panel)
    obj:SetWidth(200)
    obj:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 3, -8)
    panel.Anchor = obj

    title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("TOPLEFT", obj, "BOTTOMLEFT", -3, -8)
    title:SetText("Anchor points")

    subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtitle:SetHeight(50)
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtitle:SetPoint("RIGHT", panel, -8, 0)
	subtitle:SetNonSpaceWrap(true)
	subtitle:SetJustifyH("LEFT")
	subtitle:SetJustifyV("TOP")
	subtitle:SetText("These define how the name frame is positioned relative to its anchor. The " ..
                     "two points remain the same distance apart whenever you move the anchor " ..
                     "object.")

    local factory = function(str) return function() 
        panel:UpdateData()
    end end
    obj = GUILib.DropdownMenu({["TOPLEFT"] = factory("TOPLEFT"), 
                               ["TOPRIGHT"] = factory("TOPRIGHT"), 
                               ["BOTTOMLEFT"] = factory("BOTTOMLEFT"),
                               ["BOTTOMRIGHT"] = factory("BOTTOMRIGHT"),
                               ["CENTER"] = factory("CENTER"),
                               ["TOP"] = factory("TOP"),
                               ["BOTTOM"] = factory("BOTTOM"),
                               ["LEFT"] = factory("LEFT"),
                               ["RIGHT"] = factory("RIGHT")}, 
                               name .. "NameFramePoint", panel)
    obj:SetWidth(162)
    obj:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -8)
    panel.NameFramePoint = obj

    subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("BOTTOMLEFT", obj, "TOPLEFT", 0, 8)
    subtitle:SetPoint("BOTTOMRIGHT", obj, "TOPRIGHT", 0, 8)
    subtitle:SetJustifyH("CENTER")
    subtitle:SetText("Name Frame Point")

    factory = function(str) return function() 
        panel:UpdateData()
    end end
    obj = GUILib.DropdownMenu({["TOPLEFT"] = factory("TOPLEFT"), 
                               ["TOPRIGHT"] = factory("TOPRIGHT"), 
                               ["BOTTOMLEFT"] = factory("BOTTOMLEFT"),
                               ["BOTTOMRIGHT"] = factory("BOTTOMRIGHT"),
                               ["CENTER"] = factory("CENTER"),
                               ["TOP"] = factory("TOP"),
                               ["BOTTOM"] = factory("BOTTOM"),
                               ["LEFT"] = factory("LEFT"),
                               ["RIGHT"] = factory("RIGHT")}, 
                               name .. "AnchorPoint", panel)
    obj:SetWidth(162)
    obj:SetPoint("TOPLEFT", panel.NameFramePoint, "TOPRIGHT", 8, 0)
    panel.AnchorPoint = obj

    subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("BOTTOMLEFT", obj, "TOPLEFT", 0, 8)
    subtitle:SetPoint("BOTTOMRIGHT", obj, "TOPRIGHT", 0, 8)
    subtitle:SetJustifyH("CENTER")
    subtitle:SetText("Anchor Point")

    title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("TOPLEFT", panel.NameFramePoint, "BOTTOMLEFT", 0, -8)
    title:SetText("Offset")

    subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtitle:SetHeight(35)
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtitle:SetPoint("RIGHT", panel, -8, 0)
	subtitle:SetNonSpaceWrap(true)
	subtitle:SetJustifyH("LEFT")
	subtitle:SetJustifyV("TOP")
	subtitle:SetText("This represents the distance the name frame will be from its anchor. " ..
                     "Positive values move the name frame up or to the right; negative values " .. 
                     "down or to the left.")

    title = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    title:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -8)
    title:SetText("Horizontal:")
    
    obj = GUILib.InputBox(function(self) 
        local number = tonumber(self:GetText())
        if not number then 
            number = OpenRollsData.NameFramesOffset.horizontal
        end
        self:SetText(tostring(number))
        self:GetParent():UpdateData()
    end, name .. "Horizontal", panel)
    obj:SetWidth(35)
    obj:SetPoint("CENTER")
    obj:SetPoint("LEFT", title, "RIGHT", 10, 0)
    panel.Horizontal = obj
    
    subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "TOPRIGHT", 50, 0)
    subtitle:SetText("Vertical:")

    obj = GUILib.InputBox(function(self) 
        local number = tonumber(self:GetText())
        if not number then 
            number = OpenRollsData.NameFramesOffset.vertical
        end
        self:SetText(tostring(number))
        self:GetParent():UpdateData()
    end, name .. "Vertical", panel)
    obj:SetWidth(35)
    obj:SetPoint("CENTER")
    obj:SetPoint("LEFT", subtitle, "RIGHT", 10, 0)
    panel.Vertical = obj
    
    local btn = function(self)
        sampleAnchor:Show()
        sampleLootFrame:Show()
        sampleNameFrame:Show()
    end

    obj = GUILib.Button:new("Show", btn, name .. "Show", panel)
    obj:SetPoint("CENTER")
    obj:SetPoint("BOTTOM", 0, 10)
    obj:AddMouseoverText("Shows a sample anchor and name frame.  Use as a " ..
                         "reference; the actual placement may not match.", 1, 1, 1, 1)

    panel.LoadData = function(self, Data)
        self.Anchor:SetText(Data.NameFramesAnchorFrame)
        self.NameFramePoint:SetSelected(Data.NameFramesAnchorFrom)
        self.AnchorPoint:SetSelected(Data.NameFramesAnchorTo)
        self.Horizontal:SetText(tostring(Data.NameFramesOffset.horizontal))
        self.Vertical:SetText(tostring(Data.NameFramesOffset.vertical))
        self:UpdateSampleFrame()
        self:UpdateData()
    end
    panel:SetScript("OnShow", function(self) 
        if not self.OriginalValues then
            self.OriginalValues = {NameFramesAnchorFrame = OpenRollsData.NameFramesAnchorFrame,
                                   NameFramesAnchorTo = OpenRollsData.NameFramesAnchorTo,
                                   NameFramesAnchorFrom = OpenRollsData.NameFramesAnchorFrom,
                                   NameFramesOffset = OpenRollsData.NameFramesOffset}
            self:LoadData(OpenRollsData) 
        end
    end)

    panel:SetScript("OnHide", function(self)
        sampleNameFrame:Hide()
        sampleLootFrame:Hide()
        sampleAnchor:Hide()
    end)

    panel.okay = function(self)
        self:UpdateData()
        self.OriginalValues = nil
    end

    panel.cancel = function(self)
        local Data = OpenRollsData
        for i, j in pairs(self.OriginalValues) do
            Data[i] = j
        end
        OpenRolls:RepositionLootWindows()
        self.OriginalValues = nil
    end

    panel.default = function(self) self:LoadData(OpenRolls.Defaults) end

    panel.UpdateData = function(self)
        local Data = OpenRollsData
        Data.NameFramesAnchorFrame = self.Anchor:GetText()
        Data.NameFramesAnchorTo = self.AnchorPoint:GetSelected()
        Data.NameFramesAnchorFrom = self.NameFramePoint:GetSelected()
        Data.NameFramesOffset = {horizontal = tonumber(self.Horizontal:GetText()),
                                 vertical = tonumber(self.Vertical:GetText())}
        OpenRolls:RepositionLootWindows()
        
        sampleNameFrame:ClearAllPoints()
        sampleNameFrame:SetPoint(Data.NameFramesAnchorFrom, 
                                 sampleAnchor, 
                                 Data.NameFramesAnchorTo,
                                 Data.NameFramesOffset.horizontal,
                                 Data.NameFramesOffset.vertical)
    end

    panel.UpdateSampleFrame = function(self)
        local anchorPoint = self.AnchorPoint:GetSelected()
        local namePoint = self.NameFramePoint:GetSelected()
        local x = self.Horizontal:GetText()
        local y = self.Vertical:GetText()
        sampleNameFrame:ClearAllPoints()
        sampleNameFrame:SetPoint(namePoint, sampleAnchor, anchorPoint, x, y)        
    end

    panel:Hide()
    panel:LoadData(OpenRollsData)
    return panel
end

local function CreateLootFrameConfig(framename, name, parent)
    local panel = CreateFrame("frame", name, InterfaceOptionsFramePanelContainer)
    panel.name = name
    panel.parent = parent
    
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText("Item Frame")
    
    local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtitle:SetHeight(35)
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtitle:SetPoint("RIGHT", panel, -8, 0)
	subtitle:SetNonSpaceWrap(true)
	subtitle:SetJustifyH("LEFT")
	subtitle:SetJustifyV("TOP")
	subtitle:SetText("The item frame displays the options available to items " ..
                     "eligible for master looting.  By default, it is placed to the " ..
                     "right of the loot window, and grows downward as additional " ..
                     "items are added.")
    
    title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -8)
    title:SetText("Anchor")

    subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtitle:SetHeight(55)
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtitle:SetPoint("RIGHT", panel, -8, 0)
	subtitle:SetNonSpaceWrap(true)
	subtitle:SetJustifyH("LEFT")
	subtitle:SetJustifyV("TOP")
	subtitle:SetText("The anchor is used to attach the item frame to an existing " ..
                     "object.  If that object moves, the item frame will move with "..
                     "it.  'LootFrame' is the object that represents a loot window. " ..
                     "'UIParent' represents the entire screen; anchoring to this " ..
                     "object will give the item frame a static location that will " ..
                     "not move under normal circumstances.")

    local obj = GUILib.InputBox(function(self)
        self:GetParent():UpdateData()
    end, name .. "Anchor", panel)
    obj:SetWidth(200)
    obj:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 3, -8)
    panel.Anchor = obj

    title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("TOPLEFT", obj, "BOTTOMLEFT", -3, -8)
    title:SetText("Anchor points")

    subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtitle:SetHeight(50)
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtitle:SetPoint("RIGHT", panel, -8, 0)
	subtitle:SetNonSpaceWrap(true)
	subtitle:SetJustifyH("LEFT")
	subtitle:SetJustifyV("TOP")
	subtitle:SetText("These define how the item frame is positioned relative to its " ..
                     "anchor. The two points remain the same distance apart " ..
                     "whenever you move the anchor object.")

    local factory = function(str) return function() 
        panel:UpdateData()
    end end
    obj = GUILib.DropdownMenu({["TOPLEFT"] = factory("TOPLEFT"), 
                               ["TOPRIGHT"] = factory("TOPRIGHT"), 
                               ["BOTTOMLEFT"] = factory("BOTTOMLEFT"),
                               ["BOTTOMRIGHT"] = factory("BOTTOMRIGHT"),
                               ["CENTER"] = factory("CENTER"),
                               ["TOP"] = factory("TOP"),
                               ["BOTTOM"] = factory("BOTTOM"),
                               ["LEFT"] = factory("LEFT"),
                               ["RIGHT"] = factory("RIGHT")}, 
                               name .. "ItemFramePoint", panel)
    obj:SetWidth(162)
    obj:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -8)
    panel.LootFramePoint = obj

    subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("BOTTOMLEFT", obj, "TOPLEFT", 0, 8)
    subtitle:SetPoint("BOTTOMRIGHT", obj, "TOPRIGHT", 0, 8)
    subtitle:SetJustifyH("CENTER")
    subtitle:SetText("Item Frame Point")

    obj = GUILib.DropdownMenu({["TOPLEFT"] = factory("TOPLEFT"), 
                               ["TOPRIGHT"] = factory("TOPRIGHT"), 
                               ["BOTTOMLEFT"] = factory("BOTTOMLEFT"),
                               ["BOTTOMRIGHT"] = factory("BOTTOMRIGHT"),
                               ["CENTER"] = factory("CENTER"),
                               ["TOP"] = factory("TOP"),
                               ["BOTTOM"] = factory("BOTTOM"),
                               ["LEFT"] = factory("LEFT"),
                               ["RIGHT"] = factory("RIGHT")}, 
                               name .. "AnchorPoint", panel)
    obj:SetWidth(162)
    obj:SetPoint("TOPLEFT", panel.LootFramePoint, "TOPRIGHT", 8, 0)
    panel.AnchorPoint = obj

    subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("BOTTOMLEFT", obj, "TOPLEFT", 0, 8)
    subtitle:SetPoint("BOTTOMRIGHT", obj, "TOPRIGHT", 0, 8)
    subtitle:SetJustifyH("CENTER")
    subtitle:SetText("Anchor Point")

    title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("TOPLEFT", panel.LootFramePoint, "BOTTOMLEFT", 0, -8)
    title:SetText("Offset")

    subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtitle:SetHeight(35)
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtitle:SetPoint("RIGHT", panel, -8, 0)
	subtitle:SetNonSpaceWrap(true)
	subtitle:SetJustifyH("LEFT")
	subtitle:SetJustifyV("TOP")
	subtitle:SetText("This represents the distance the item frame will be from its " ..
                     "anchor.  Positive values move the item frame up or to the " ..
                     "right; negative values down or to the left.")

    title = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    title:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -8)
    title:SetText("Horizontal:")
    
    obj = GUILib.InputBox(function(self) 
        local number = tonumber(self:GetText())
        if not number then 
            number = OpenRollsData.LootFramesOffset.horizontal
        end
        self:SetText(tostring(number))
        self:GetParent():UpdateData()
    end, name .. "Horizontal", panel)
    obj:SetWidth(35)
    obj:SetPoint("CENTER")
    obj:SetPoint("LEFT", title, "RIGHT", 10, 0)
    panel.Horizontal = obj
    
    subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "TOPRIGHT", 50, 0)
    subtitle:SetText("Vertical:")

    obj = GUILib.InputBox(function(self) 
        local number = tonumber(self:GetText())
        if not number then 
            number = OpenRollsData.LootFramesOffset.vertical
        end
        self:SetText(tostring(number))
        self:GetParent():UpdateData()
    end, name .. "Vertical", panel)
    obj:SetWidth(35)
    obj:SetPoint("CENTER")
    obj:SetPoint("LEFT", subtitle, "RIGHT", 10, 0)
    panel.Vertical = obj

    local btn = function(self)
        sampleAnchor:Show()
        sampleLootFrame:Show()
        sampleNameFrame:Show()
    end

    obj = GUILib.Button:new("Show", btn, name .. "Show", panel)
    obj:SetPoint("CENTER")
    obj:SetPoint("BOTTOM", 0, 10)
    obj:AddMouseoverText("Shows a sample anchor and item frame.  Use as a " ..
                         "reference; the actual placement may not match.", 1, 1, 1, 1)

    panel.LoadData = function(self, Data)
        self.Anchor:SetText(Data.LootFramesAnchorFrame)
        self.LootFramePoint:SetSelected(Data.LootFramesAnchorFrom)
        self.AnchorPoint:SetSelected(Data.LootFramesAnchorTo)
        self.Horizontal:SetText(tostring(Data.LootFramesOffset.horizontal))
        self.Vertical:SetText(tostring(Data.LootFramesOffset.vertical))
        self:UpdateData()
    end
    
    panel:SetScript("OnShow", function(self) 
        if not self.OriginalValues then
            self.OriginalValues = {LootFramesAnchorFrame = OpenRollsData.LootFramesAnchorFrame,
                                   LootFramesAnchorTo = OpenRollsData.LootFramesAnchorTo,
                                   LootFramesAnchorFrom = OpenRollsData.LootFramesAnchorFrom,
                                   LootFramesOffset = OpenRollsData.LootFramesOffset}
            self:LoadData(OpenRollsData) 
        end
    end)

    panel:SetScript("OnHide", function(self)
        sampleNameFrame:Hide()
        sampleLootFrame:Hide()
        sampleAnchor:Hide()
    end)

    panel.okay = function(self)
        self:UpdateData()
        self.OriginalValues = nil
    end

    panel.cancel = function(self)
        local Data = OpenRollsData
        for i, j in pairs(self.OriginalValues) do
            Data[i] = j
        end
        OpenRolls:RepositionLootWindows()
        self.OriginalValues = nil
    end
    
    panel.default = function(self) self:LoadData(OpenRolls.Defaults) end

    panel.UpdateData = function(self)
        local Data = OpenRollsData
        Data.LootFramesAnchorFrame = self.Anchor:GetText()
        Data.LootFramesAnchorTo = self.AnchorPoint:GetSelected()
        Data.LootFramesAnchorFrom = self.LootFramePoint:GetSelected()
        Data.LootFramesOffset = {horizontal = tonumber(self.Horizontal:GetText()),
                                 vertical = tonumber(self.Vertical:GetText())}
        OpenRolls:RepositionLootWindows()
        
        sampleLootFrame:ClearAllPoints()
        sampleLootFrame:SetPoint(Data.LootFramesAnchorFrom, 
                                 sampleAnchor, 
                                 Data.LootFramesAnchorTo,
                                 Data.LootFramesOffset.horizontal,
                                 Data.LootFramesOffset.vertical)
    end

    panel.UpdateSampleFrame = function(self)
        local anchorPoint = self.AnchorPoint:GetSelected()
        local lootPoint = self.LootFramePoint:GetSelected()
        local x = self.Horizontal:GetText()
        local y = self.Vertical:GetText()
        sampleLootFrame:ClearAllPoints()
        sampleLootFrame:SetPoint(lootPoint, sampleAnchor, anchorPoint, x, y)        
    end

    panel:Hide()
    panel:LoadData(OpenRollsData)
    return panel
end


function OpenRolls:ShowConfig()
    InterfaceOptionsFrame_OpenToCategory("Open Rolls")
end

function OpenRolls:CreateConfig()
    local ConfigPanel = CreateMainConfig("OpenRollsConfig")
    InterfaceOptions_AddCategory(ConfigPanel)
    ConfigPanel = CreateNameFrameConfig("OpenRollsConfigNameFrame", "Name Frame", "Open Rolls")
    InterfaceOptions_AddCategory(ConfigPanel)
    ConfigPanel = CreateLootFrameConfig("OpenRollsConfigLootFrame", "Item Frame", "Open Rolls")
    InterfaceOptions_AddCategory(ConfigPanel)    
end
end
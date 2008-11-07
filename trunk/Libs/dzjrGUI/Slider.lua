do
local Lib = LibStub("dzjrGUI")

--[[local Frame = CreateFrame("frame")
Frame.__index = Frame

Lib.Slider = setmetatable({}, Frame)
Lib.Slider.__index = Lib.Slider]]--

Lib.Slider = setmetatable({}, Lib.Base["frame"])
Lib.Slider.__index = Lib.Slider

function Lib.Slider:AddMouseoverText(text, r, g, b, a)
    local oldEnter = self.Slider:GetScript("OnEnter")
    local oldLeave = self.Slider:GetScript("OnLeave")
    self.Slider:SetScript("OnEnter", function(self, ...) 
        local GT = GameTooltip
        GT:SetOwner(self, "ANCHOR_TOPLEFT")
        GT:AddLine(text, r, g, b, a, true)
        GT:Show()
        if oldEnter then oldEnter() end
    end)
    self.Slider:SetScript("OnLeave", function(self, ...) 
        GameTooltip:Hide() 
        if oldLeave then oldLeave() end
    end)
end

function Lib.Slider:SetScript(script, func)
    if script == "OnValueChanged" then
        self.Slider:SetScript("OnValueChanged", function(slider, value) func(self, value) end)
    else
        Frame.SetScript(self, script, func)
    end
end

function Lib.Slider:GetMinMaxValues()
    return self.Slider:GetMinMaxValues()
end

function Lib.Slider:GetOrientation()
    return self.Slider:GetOrientation()
end

function Lib.Slider:GetThumbTexture()
    return self.Slider:GetThumbTexture()
end

function Lib.Slider:GetValue()
    return self.Slider:GetValue()
end

function Lib.Slider:ValueStep()
    return self.Slider:ValueStep()
end

function Lib.Slider:SetMinMaxValues(min, max)
    self.Slider:SetMinMaxValues(min, max)
    self.MinText:SetText(min)
    self.MaxText:SetText(max)
end

function Lib.Slider:SetThumbTexture(texture) 
    self.Slider:SetThumbTexture(texture)
end

function Lib.Slider:SetValue(value)
    self.Slider:SetValue(value)
end

function Lib.Slider:SetValueStep(value)
    self.Slider:SetValueStep(value)
end

function Lib.Slider:SetOrientation(orientation)
    local horizontal
    if orientation:lower() == "horizontal" then
        horizontal = true
    else
        horizontal = false
    end

    local slider = self.Slider
    local minText = self.MinText
    local maxText = self.MaxText

    slider:ClearAllPoints()
    minText:ClearAllPoints()
    maxText:ClearAllPoints()
    
    slider:SetOrientation(orientation)
    if horizontal then
        self:SetHeight(25)
        slider:SetPoint("TOPLEFT")
        slider:SetPoint("RIGHT")
        slider:SetHeight(17)
        minText:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, 3)
        maxText:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", 0, 3)
        maxText:SetJustifyH("RIGHT")
        slider:SetHitRectInsets(0, 0, 0, -7)
        slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    else
        self:SetWidth(10)
        slider:SetPoint("TOPLEFT", 0, -9)
        slider:SetPoint("BOTTOM", 0, 9)
        slider:SetWidth(10)
        slider:SetHitRectInsets(0, 0, -9, -9)
        minText:SetPoint("BOTTOM", slider, "TOP", 0, -2)
        minText:SetJustifyH("CENTER")
        maxText:SetPoint("TOP", slider, "BOTTOM", 0, 2)
        maxText:SetJustifyH("CENTER")
        slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Vertical")        
    end
end

function Lib.Slider:new(orientation, min, max, step, name, parent)
    local self = CreateFrame("Frame", name, parent)
    self = setmetatable(self, Lib.Slider)

    local slider = CreateFrame("Slider", name .. "Slider", self)
    slider:SetBackdrop({
        bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
        edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
        edgeSize = 8, tile = true, tileSize = 8,
        insets = {left = 3, right = 3, top = 6, bottom = 6}
    })    
    slider:SetMinMaxValues(min, max)
    if step then
        slider:SetValueStep(step)
    end    
    self.Slider = slider

    local minText = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    minText:SetText(tostring(min))
    self.MinText = minText

    local maxText = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    maxText:SetText(tostring(max))
    self.MaxText = maxText

    self:SetOrientation(orientation)

    return self
end
end
do
local Lib, minor = LibStub("dzjrGUI")

if not Lib or minor > 2 then return end

local setmetatable = setmetatable
local error = error
local CreateFrame = CreateFrame

Lib.CheckButton = setmetatable({}, Lib.Base["CheckButton"])
Lib.CheckButton.__index = Lib.CheckButton

function Lib.CheckButton:new(typeof, name, parent)
    typeof = typeof:lower()
    local frame = setmetatable(CreateFrame("CheckButton", name, parent), Lib.CheckButton)

    frame:SetWidth(16)
    frame:SetHeight(16)
    if typeof == "check" then
        frame:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
        frame:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
        frame:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
        frame:GetHighlightTexture():SetBlendMode("ADD")
        frame:SetDisabledTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
        frame:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
    elseif typeof == "radio" then
        frame:SetNormalTexture("Interface\\Buttons\\UI-RadioButton")
        frame:SetHighlightTexture("Interface\\Buttons\\UI-RadioButton")
        frame:SetCheckedTexture("Interface\\Buttons\\UI-RadioButton")
        
        frame:GetNormalTexture():SetTexCoord(0, 0.25, 0, 1)
        frame:GetHighlightTexture():SetTexCoord(0.5, 0.75, 0, 1)
        frame:GetCheckedTexture():SetTexCoord(0.25, 0.5, 0, 1)
    else
        error("Unknown checkbutton type: " .. typeof)
        return
    end
    
    return frame
end
end
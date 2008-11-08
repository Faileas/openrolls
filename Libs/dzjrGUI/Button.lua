do
local Lib = LibStub("dzjrGUI")

local setmetatable = setmetatable
local CreateFrame = CreateFrame

Lib.Button = setmetatable({}, Lib.Base["button"])
Lib.Button.__index = Lib.Button

function Lib.Button:new(text, func, name, parent)
    local frame = CreateFrame("button", name, parent)
    frame = setmetatable(frame, Lib.Button)
    
    frame:SetText(text)
    frame:SetWidth(80)
    frame:SetHeight(22)
    frame:SetScript("OnClick", func)
    
    frame:SetDisabledFontObject(GameFontDisable)
    frame:SetHighlightFontObject(GameFontHighlight)
    frame:SetNormalFontObject(GameFontNormal)

    -- Textures --
    frame:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
    frame:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
    frame:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
    frame:SetDisabledTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
    frame:GetNormalTexture():SetTexCoord(0, 0.625, 0, 0.6875)
    frame:GetPushedTexture():SetTexCoord(0, 0.625, 0, 0.6875)
    frame:GetHighlightTexture():SetTexCoord(0, 0.625, 0, 0.6875)
    frame:GetDisabledTexture():SetTexCoord(0, 0.625, 0, 0.6875)
    frame:GetHighlightTexture():SetBlendMode("ADD")
    
    return frame
end
end
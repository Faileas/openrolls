do
local Lib = LibStub("dzjrGUI")

function Lib.Button(text, func, name, parent)
    local frame = CreateFrame("button", name .. "Button", parent)
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
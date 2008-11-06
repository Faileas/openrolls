do
local Lib = LibStub("dzjrGUI")

function Lib.Slider(orientation, min, max, step, name, parent)
    local horizontal
    ChatFrame1:AddMessage(orientation)
    if orientation:lower() == "horizontal" then
        horizontal = true
    else
        horizontal = false
    end

    local slider = CreateFrame("Slider", name .. "Slider", parent)
    slider:SetOrientation(orientation)
    if horizontal then
        slider:SetHeight(17)
        slider:SetHitRectInsets(0, 0, -10, -10)
        slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    else
        slider:SetWidth(10)
        slider:SetHitRectInsets(-10, -10, 0, 0)
        slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Vertical")
    end
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
    
    return slider
end
end
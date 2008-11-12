--Creates a message box with "Confirm" and "Cancel" buttons
--  yes is the function that gets called if "Confirm" is pressed
--  no is the function that gets called if "Cancel" is pressed

local Lib = LibStub("dzjrGUI")

local setmetatable = setmetatable
local type = type

Lib.MessageBox = setmetatable({}, Lib.Base["Frame"])
Lib.MessageBox.__index = Lib.MessageBox

local function MouseDown(self)
    self:StartMoving()
end

local function MouseUp(self)
    self:StopMovingOrSizing()
end

local function Confirm(self)
    local frame = self:GetParent()
    frame:Hide()
    frame.Confirm()
end

local function Cancel(self)
    local frame = self:GetParent()
    frame:Hide()
    frame.Cancel()
end

local ValidAttributes = {
    Width = 278,
    ConfirmText = "Confirm",
    CancelText = "Cancel",
    Font = "GameFontHighlightSmall",
    ShowCancel = true,
    --ConfirmFunction
    --CancelFunction
    --Name
    --Text
    --Height
}
ValidAttributes.__index = ValidAttributes

--Acceptable formats:
--  (attributes)
--  (text, confirm, [cancel], [name])
function Lib.MessageBox:new(...)
    local first, second, third, fourth = select(1, ...)
    local attributes
    if type(first) == "table" then
        attributes = setmetatable(first, ValidAttributes)
    else
        attributes = setmetatable({}, ValidAttributes)
        attributes.Text = first
        attributes.ConfirmFunction = second
        if type(third) == "function" then
            attributes.CancelFunction = third
            attributes.Name = fourth
        else
            attributes.ShowCancel = false
            attributes.Name = third
        end
    end
    
    local box = CreateFrame("Frame", attributes.Name, UIParent)
    
    box.Confirm = attributes.ConfirmFunction
    box.Cancel = attributes.CancelFunction
    
    box:SetBackdrop({
        bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", 
        tile = true, tileSize = 32, edgeSize = 32, 
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })    
    box:SetBackdropColor(0,0,0,1)
    box:SetToplevel(true)
    box:SetFrameStrata("FULLSCREEN_DIALOG")
    box:SetHeight(100)
    box:SetPoint("CENTER", UIParent, "CENTER")
    box:SetMovable(true)
    box:EnableMouse()
    box:SetScript("OnMouseDown", MouseDown)
    box:SetScript("OnMouseUp", MouseUp)

    local confirm = Lib.Button:new(attributes.ConfirmText, Confirm, nil, box)
    confirm:SetPoint("BOTTOM", 0, 12)
    local width = confirm:GetWidth() + 24
    if attributes.ShowCancel then
        local cancel = Lib.Button:new(attributes.CancelText, Cancel, nil, box)
        cancel:SetPoint("BOTTOM", confirm)
        cancel:SetPoint("LEFT", box, "CENTER", 20, 0)
        --cancel:SetPoint("BOTTOMRIGHT", box,"BOTTOMRIGHT", -12, 12)
    
        confirm:SetPoint("LEFT", box, "CENTER", -20, 0)

        width = width + cancel:GetWidth() + 12
    else
        confirm:SetPoint("CENTER")
    end

    if width > attributes.Width then attributes.Width = width end
    box:SetWidth(attributes.Width)

    local str = box:CreateFontString(nil, "ARTWORK", attributes.Font)
    str:SetPoint("TOPLEFT", box, 17, -17)
    str:SetWidth(box:GetRight() - box:GetLeft() - 34)
    str:SetText(attributes.Text)

    if attributes.Height then
        box:SetHeight(attributes.Height)
    else
        box:SetHeight(str:GetHeight() + 50 + 10)
    end
    
    box:Show()
end

do
local rev = tonumber(strmatch("$Revision$", "%d+"))
local Lib = LibStub("dzjrGUI")

local version = Lib.Versions.InputPrompt or 0
if version >= rev then return end
Lib.Versions.InputPrompt = rev

local setmetatable = setmetatable
local CreateFrame = CreateFrame

Lib.InputPrompt = setmetatable({}, Lib.Base["frame"])
Lib.InputPrompt.__index = Lib.InputPrompt

local ValidAttributes = {
    Width = 320,
    PromptWidth = 200,
    ConfirmText = "Accept",
    CancelText = "Cancel",
    Font = "GameFontHighlight",
    ShowCancel = true,
    Default = "",
    Numeric = false,
    --Validate
    --CancelFunction
    --ConfirmFunction
    --Name
    --Text
    --Height
    --MaxLetters
}
ValidAttributes.__index = ValidAttributes

local function MouseDown(self)
    self:StartMoving()
end

local function MouseUp(self)
    self:StopMovingOrSizing()
end

local function ClickConfirm(self)
    local p = self:GetParent()
    if not p.Validate or p.Validate(p.Prompt:GetText()) then
        p.Confirm()
        p:Hide()
    end
end

local function ClickCancel(self)
    local p = self:GetParent()
    if p.Cancel then
        p.Cancel()
        p:Hide()
    end
end    

local function Create(attributes)
    local box = CreateFrame("Frame", attributes.Name, UIParent)
    
    box.Confirm = attributes.ConfirmFunction
    box.Cancel = attributes.CancelFunction
    box.Validate = attributes.Validate

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

    box:SetWidth(attributes.Width)

    local str = box:CreateFontString(nil, "ARTWORK", attributes.Font)
    str:SetPoint("TOPLEFT", box, "TOPLEFT", 17, -16)
    str:SetText(attributes.Text)

    local prompt = Lib.InputBox:new(ClickConfirm, nil, box)
    prompt:SetWidth(attributes.PromptWidth)
    prompt:SetPoint("TOP", str, "BOTTOM", 0, -13)
    prompt:SetPoint("CENTER", box, "CENTER")
    prompt:SetText(attributes.Default)
    prompt:SetNumeric(attributes.Numeric)
    if attributes.MaxLetters then
        prompt:SetMaxLetters(attributes.MaxLetters)
    end
    box.Prompt = prompt

    local promptWidth = prompt:GetWidth() + 80

    local confirm = Lib.Button:new(attributes.ConfirmText, ClickConfirm, nil, box)
    confirm:SetPoint("BOTTOM", 0, 15)

    local buttonWidth = confirm:GetWidth() + 40
    if attributes.ShowCancel then
        confirm:SetPoint("RIGHT", box, "CENTER", -7, 0)

        local cancel = Lib.Button:new(attributes.CancelText, ClickCancel, nil, box)
        cancel:SetPoint("LEFT", box, "CENTER", 7, 0)
        cancel:SetPoint("BOTTOM", confirm)
        cancel:SetScript("OnClick", ClickCancel)

        buttonWidth = buttonWidth + cancel:GetWidth() + 14
    else
        confirm:SetPoint("CENTER")
    end

    box:SetWidth(max(buttonWidth, promptWidth, attributes.Width or 0))
    str:SetWidth(box:GetRight() - box:GetLeft() - 34)

    local minHeight = str:GetHeight() + confirm:GetHeight() + prompt:GetHeight() + 58

    box:SetHeight(max(attributes.Height or 0, minHeight))

    return box
end

--Acceptable formats:
--  (attributes)
--  (text, confirm, [cancel], [name])
function Lib.InputPrompt:new(...)
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
            attributes.Name = third
        end
    end
    attributes = setmetatable(attributes, ValidAttributes)
    return Create(attributes)
end

end
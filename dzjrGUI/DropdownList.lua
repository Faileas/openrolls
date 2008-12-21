do
local Lib, minor = LibStub("dzjrGUI")

if not Lib or minor > 2 then return end

local setmetatable = setmetatable
local pairs = pairs
local CreateFrame = CreateFrame

Lib.DropdownList = setmetatable({}, Lib.Base["Frame"])
Lib.DropdownList.__index = Lib.DropdownList

function Lib.DropdownList:GetSelected()
    return UIDropDownMenu_GetSelectedValue(self.menu)
end

function Lib.DropdownList:SetSelected(value)
    UIDropDownMenu_SetSelectedValue(self.menu, value)
    self:SetText(value)
end

function Lib.DropdownList:SetText(str)
    self.text:SetText(str)
end

local sorted = {}
local count = 0
local function CreateMenu(self, name, options)
    --Blizzard's menu code requires the frame be named, and I'm too lazy to recreate it.
    if not name then 
        name = "dzjrGUIDropDownMenu" .. count
        count = count + 1
    end
    local menu = CreateFrame("Frame", name .. "Menu", self, "UIDropDownMenuTemplate")
    menu.initialize = function()
        for name in pairs(options) do
            sorted[#sorted+1] = name
        end
        table.sort(sorted)
        
        local info = UIDropDownMenu_CreateInfo()
        for i, name in ipairs(sorted) do            
            sorted[i] = nil
            info.text = name
            info.value = name
            info.arg1 = menu
            info.func = function()
                UIDropDownMenu_SetSelectedValue(this.arg1, this.value)
                self:SetText(this.value)
                options[name]()
            end
            info.checked = false
            UIDropDownMenu_AddButton(info)
        end
    end
    
    return menu
end

local function ButtonClick(self)
    local frame = self:GetParent()
    ToggleDropDownMenu(1, nil, frame.menu, frame, 0, 0)
end

--Creates a dropdown menu
function Lib.DropdownList:new(options, name, parent)
	local frame = setmetatable(CreateFrame("Frame", name, parent), Lib.DropdownList)
    frame:SetHeight(26)

    local left = frame:CreateTexture(nil, "ARTWORK")
    left:SetWidth(25)
    left:SetPoint("TOPLEFT", -16, 20)
    left:SetPoint("BOTTOM", 0, -20)
	left:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
	left:SetTexCoord(0, 0.1953125, 0, 1)

    local right = frame:CreateTexture(nil, "ARTWORK")
    right:SetWidth(25)
    right:SetPoint("TOPRIGHT", 16, 20)
    right:SetPoint("BOTTOM", 0, -20)
	right:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
	right:SetTexCoord(0.8046875, 1, 0, 1)

    local middle = frame:CreateTexture(nil, "ARTWORK")
    middle:SetPoint("TOPLEFT", left, "TOPRIGHT")
    middle:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT")
	middle:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
	middle:SetTexCoord(0.1953125, 0.8046875, 0, 1)

    local button = CreateFrame("Button", nil, frame)
	button:SetWidth(26) 
    button:SetHeight(26)
	button:SetPoint("TOPRIGHT", 0, 2)
	button:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
	button:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
	button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
	button:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled")
	button:GetHighlightTexture():SetBlendMode("ADD")
    
    local text = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	text:SetPoint("TOPRIGHT", button, "TOPLEFT", 0, -8)
	text:SetJustifyH("RIGHT")
    frame.text = text

    local menu = CreateMenu(frame, name, options)
    
    button:SetScript("OnClick", ButtonClick)
    frame.menu = menu
    
    return frame
end
end
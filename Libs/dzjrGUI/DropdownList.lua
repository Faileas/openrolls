do
local Lib = LibStub("dzjrGUI")

local function CreateMenu(self, name, options, func)
    local menu = CreateFrame("Frame", name .. "Menu", self, "UIDropDownMenuTemplate")
    --menu.displayMode = "MENU"
    menu.initialize = function()
        local info = UIDropDownMenu_CreateInfo()
        for name, funct in pairs(options) do
            info.text = name
            info.value = name
            info.arg1 = menu
            info.func = function()
                UIDropDownMenu_SetSelectedValue(this.arg1, this.value)
                func(this.value)
                funct()
            end
            info.checked = false
            UIDropDownMenu_AddButton(info)
        end
    end
    
    return menu
end

--Creates a dropdown menu
function Lib.DropdownMenu(options, name, parent)
	local frame = CreateFrame("Frame", name, parent)
    frame:SetHeight(26)

    local left = frame:CreateTexture(name.."Left", "ARTWORK")
    left:SetWidth(25)
    left:SetPoint("TOPLEFT", -16, 20)
    left:SetPoint("BOTTOM", 0, -20)
	left:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
	left:SetTexCoord(0, 0.1953125, 0, 1)

    local right = frame:CreateTexture(name.."Right", "ARTWORK")
    right:SetWidth(25)
    right:SetPoint("TOPRIGHT", 16, 20)
    right:SetPoint("BOTTOM", 0, -20)
	right:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
	right:SetTexCoord(0.8046875, 1, 0, 1)

    local middle = frame:CreateTexture(name.."Middle", "ARTWORK")
    middle:SetPoint("TOPLEFT", left, "TOPRIGHT")
    middle:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT")
	middle:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
	middle:SetTexCoord(0.1953125, 0.8046875, 0, 1)

    local button = CreateFrame("Button", name.."Button", frame)
	button:SetWidth(26) 
    button:SetHeight(26)
	button:SetPoint("TOPRIGHT", 0, 2)
	button:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
	button:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
	button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
	button:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled")
	button:GetHighlightTexture():SetBlendMode("ADD")
    
    local text = frame:CreateFontString(name.."Text", "ARTWORK", "GameFontHighlightSmall")
	text:SetPoint("TOPRIGHT", button, "TOPLEFT", 0, -8)
	text:SetJustifyH("RIGHT")
    
    frame.SetText = function(self, str) text:SetText(str) end
    
    local menu = CreateMenu(frame, name .. "Menu", options, function(value)
		text:SetText(value)
	end)
    
    button:SetScript("OnClick", function() ToggleDropDownMenu(1, nil, menu, frame, 0, 0) end)
    frame.menu = menu
    
    frame.GetSelected = function(self)
        return UIDropDownMenu_GetSelectedValue(self.menu)
    end
    
    frame.SetSelected = function(self, value)
        UIDropDownMenu_SetSelectedValue(self.menu, value)
        text:SetText(value)
    end
    
    return frame
end
end
do

local MAJOR, MINOR = "dzjrGUI", 1
local Lib = LibStub:NewLibrary(MAJOR, MINOR)

if not Lib then return end

function Lib.AddMouseoverText(frame, text, r, g, b, a)
    frame:EnableMouse()
    local oldEnter = frame:GetScript("OnEnter")
    local oldLeave = frame:GetScript("OnLeave")
    frame:SetScript("OnEnter", function(self, ...) 
        local GT = GameTooltip
        GT:SetOwner(self, "ANCHOR_TOPLEFT")
        GT:AddLine(text, r, g, b, a, true)
        GT:Show()
        if oldEnter then oldEnter() end
    end)
    frame:SetScript("OnLeave", function(self, ...) 
        GameTooltip:Hide() 
        if oldLeave then oldLeave() end
    end)
end

--Builds a series of radio buttons on top of each other
--name and parent are self explanatory
--options is a table with each element corresponding to a button
--  the index is the value that should be returned by GetSetting when that button is selected
--  the value is the text that should show next to the button itself
function Lib.RadioGroup(options, name, parent)
    local frame = CreateFrame("frame", name, parent)
    local radio = {}
    local i = 0
    local init = nil
    local max, cur = 0, 0
    local height = 0
    for pos, j in pairs(options) do
        local r = CreateFrame("CheckButton", name .. "Radio" .. i, frame, "UIRadioButtonTemplate")
        r:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -i*20)
        r.parent = frame
        r.position = pos
        r:SetScript("OnClick", function(self, ...)
            self.parent:Click(self.position)
        end)
        if init == nil then 
            init = pos
            r:SetChecked(true)
        end

        local s = frame:CreateFontString(name .. "RadioString" .. i, "OVERLAY", "GameFontHighlight")
        s:SetPoint("TOPLEFT", r, "TOPRIGHT")
        s:SetText(j)

        cur = s:GetWidth() + r:GetWidth()
        if cur > max then max = cur end
        height = height + s:GetHeight() + 5

        radio[pos] = {button = r, text = s}
        i = i + 1
    end

    frame.Click = function(self, position)
        if position ~= self.checked then
            self.radio[self.checked].button:SetChecked(false)
            self.checked = position
        end
        self.radio[position].button:SetChecked(true)
    end

    frame.GetSetting = function(self)
        return frame.checked
    end

    frame:SetWidth(max)
    frame:SetHeight(height)
    frame.radio = radio
    frame.checked = init
    return frame
end

--Creates an input box.  The resultant box has a height set, but no width
function Lib.InputBox(name, parent, func)
    local obj = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
    obj:SetAutoFocus(false)
    obj:SetFontObject(ChatFontNormal)
    obj:SetTextInsets(0, 0, 3, 3)
    obj:SetHeight(20)
    obj:SetScript("OnEnterPressed", func)
    return obj
end

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
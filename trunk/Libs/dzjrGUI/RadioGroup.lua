do
local Lib = LibStub("dzjrGUI")

Lib.RadioGroup = setmetatable({}, Lib.Base["Frame"])
Lib.RadioGroup.__index = Lib.RadioGroup

--Builds a series of radio buttons on top of each other
--name and parent are self explanatory
--options is a table with each element corresponding to a button
--  the index is the value that should be returned by GetSetting when that button is selected
--  the value is the text that should show next to the button itself
function Lib.RadioGroup:new(options, name, parent)
    local frame = setmetatable(CreateFrame("frame", name, parent), Lib.RadioGroup)
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
end
do
local Lib = LibStub("dzjrGUI")

Lib.RadioGroup = setmetatable({}, Lib.Base["Frame"])
Lib.RadioGroup.__index = Lib.RadioGroup

function Lib.RadioGroup:Click(position)
    if position ~= self.checked then
        self.radio[self.checked].button:SetChecked(false)
        self.checked = position
    end
    self.radio[position].button:SetChecked(true)
end

function Lib.RadioGroup:GetSetting()
    return frame.checked
end

local function RadioClick(self)
    self:GetParent():Click(self.position)
end

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
        local r = Lib.CheckButton:new("radio", nil, frame)
        r:SetPoint("TOPLEFT", 0, -i*20)
        r.position = pos
        r:SetScript("OnClick", RadioClick)
        if init == nil then 
            init = pos
            r:SetChecked(true)
        end

        local s = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        s:SetPoint("TOPLEFT", r, "TOPRIGHT")
        s:SetText(j)

        cur = s:GetWidth() + r:GetWidth()
        if cur > max then max = cur end
        height = height + s:GetHeight() + 5

        radio[pos] = {button = r, text = s}
        i = i + 1
    end

    frame:SetWidth(max)
    frame:SetHeight(height)
    frame.radio = radio
    frame.checked = init
    return frame
end
end
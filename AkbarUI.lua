--[[
    AKBAR UI v2.0 — Modern Dark Glassmorphism UI Framework (Fixed & Complete)
    Fitur : Window, Tab, Section (accordion), Toggle, Slider, Dropdown (multi),
            Button, Label, Paragraph, Keybind, ColorPicker, Input, Divider,
            Notification, Confirm/Dialog, Config Save/Load, Live Theme
    Mobile: drag/resize/component support touch
]]

local Akbar = {}
Akbar.__index = Akbar
Akbar.Version = "2.0.0"
Akbar.AnimationEnabled = true

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer

-- ════════════════════════ THEME ════════════════════════
Akbar.Theme = {
    Background = Color3.fromRGB(15, 17, 23),
    Surface = Color3.fromRGB(23, 26, 36),
    Surface2 = Color3.fromRGB(31, 35, 48),
    SurfaceHover = Color3.fromRGB(38, 43, 60),
    Border = Color3.fromRGB(45, 52, 71),
    BorderLight = Color3.fromRGB(65, 75, 102),
    Text = Color3.fromRGB(245, 247, 252),
    Muted = Color3.fromRGB(140, 147, 168),
    Accent = Color3.fromRGB(56, 130, 255),
    AccentDark = Color3.fromRGB(40, 95, 200),
    Success = Color3.fromRGB(46, 204, 113),
    Warning = Color3.fromRGB(241, 196, 15),
    Error = Color3.fromRGB(231, 76, 60),
    GlassTransparency = 0.12,
}

-- ════════════════════════ PRESET THEMES ════════════════════════
-- Palet siap pakai biar user tinggal panggil Akbar:SetPreset("Nama")
Akbar.Presets = {
    ["Default Blue"] = { Accent = Color3.fromRGB(56, 130, 255), AccentDark = Color3.fromRGB(40, 95, 200) },
    ["Royal Purple"] = { Accent = Color3.fromRGB(147, 112, 255), AccentDark = Color3.fromRGB(110, 80, 210) },
    ["Crimson Red"] = { Accent = Color3.fromRGB(255, 82, 82), AccentDark = Color3.fromRGB(205, 55, 55) },
    ["Emerald Green"] = { Accent = Color3.fromRGB(46, 213, 145), AccentDark = Color3.fromRGB(30, 170, 115) },
    ["Sunset Orange"] = { Accent = Color3.fromRGB(255, 150, 60), AccentDark = Color3.fromRGB(215, 115, 35) },
    ["Ocean Teal"] = { Accent = Color3.fromRGB(45, 200, 220), AccentDark = Color3.fromRGB(30, 160, 180) },
    ["Midnight Pink"] = { Accent = Color3.fromRGB(255, 105, 180), AccentDark = Color3.fromRGB(210, 75, 145) },
}

local Icons = {
    ["crown"] = "rbxassetid://7733964719", ["anchor"] = "rbxassetid://7733658504",
    ["fish"] = "rbxassetid://7733919783", ["pickaxe"] = "rbxassetid://7734053495",
    ["bot"] = "rbxassetid://7733692043", ["sprout"] = "rbxassetid://7734068321",
    ["settings"] = "rbxassetid://7734053426", ["home"] = "rbxassetid://7733960981",
    ["info"] = "rbxassetid://7733965118", ["user"] = "rbxassetid://7734091286",
    ["users"] = "rbxassetid://7734091392", ["zap"] = "rbxassetid://7734110803",
    ["shield"] = "rbxassetid://7734056608", ["wrench"] = "rbxassetid://7734110303",
    ["refresh-cw"] = "rbxassetid://7734051050", ["layout-dashboard"] = "rbxassetid://7733955740",
    ["scroll-text"] = "rbxassetid://7734052335", ["search"] = "rbxassetid://7734052925",
    ["x"] = "rbxassetid://7734110595", ["minus"] = "rbxassetid://7733911828",
    ["maximize"] = "rbxassetid://7733955511", ["chevron-down"] = "rbxassetid://7733717444",
    ["chevron-up"] = "rbxassetid://7733717651", ["check"] = "rbxassetid://7733715400",
    ["save"] = "rbxassetid://7734052335", ["palette"] = "rbxassetid://7734053495",
    ["fallback"] = "rbxassetid://7733964719"
}

local function GetIcon(name)
    if type(name) ~= "string" or name == "" then return Icons.fallback end
    local lower = string.lower(name) -- FIX: case-insensitive
    if string.find(lower, "rbxassetid://", 1, true) or string.find(lower, "http", 1, true) then
        return name
    end
    return Icons[lower] or Icons.fallback
end

-- ════════════════════════ LIVE THEME SYSTEM ════════════════════════
local ThemedRegistry = {}
local ThemeHooks = {}

local function Themed(inst, prop, key)
    if Akbar.Theme[key] ~= nil then
        inst[prop] = Akbar.Theme[key]
        table.insert(ThemedRegistry, { inst, prop, key })
    end
    return inst
end

local function RefreshThemed()
    for i = #ThemedRegistry, 1, -1 do
        local entry = ThemedRegistry[i]
        if not entry[1] or entry[1].Parent == nil then
            table.remove(ThemedRegistry, i)
        else
            pcall(function() entry[1][entry[2]] = Akbar.Theme[entry[3]] end)
        end
    end
    for i = #ThemeHooks, 1, -1 do
        local hook = ThemeHooks[i]
        if not hook[1].ScreenGui or hook[1].ScreenGui.Parent == nil then
            table.remove(ThemeHooks, i)
        else
            pcall(hook[2])
        end
    end
end

-- ════════════════════════ UTILITIES ════════════════════════
local function TI(t, style, dir)
    return TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
end

local function Tween(instance, info, properties)
    if not instance then return nil end
    if not Akbar.AnimationEnabled then
        for prop, val in pairs(properties) do
            pcall(function() instance[prop] = val end)
        end
        return nil
    end
    local ok, tween = pcall(TweenService.Create, TweenService, instance, info, properties)
    if ok and tween then tween:Play() return tween end
    return nil
end

local function Round(inst, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = inst
    return c
end

local function Stroke(inst, key, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.5
    Themed(s, "Color", key or "Border")
    s.Parent = inst
    return s
end

-- FIX/PREMIUM: efek tactile ringan (mengecil dikit saat ditekan) biar respon klik lebih "berasa",
-- terutama di HP dimana nggak ada hover state. Dipasang ke UIScale, bukan Size langsung,
-- biar tidak ganggu AutomaticSize/Layout milik elemen aslinya.
local function PressFeedback(button, minScale)
    minScale = minScale or 0.96
    local scale = Instance.new("UIScale")
    scale.Scale = 1
    scale.Parent = button
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Tween(scale, TI(0.08, Enum.EasingStyle.Quad), { Scale = minScale })
        end
    end)
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Tween(scale, TI(0.15, Enum.EasingStyle.Back), { Scale = 1 })
        end
    end)
    return scale
end

local function SafeParentGui(gui, preferredParent)
    local target = preferredParent or (gethui and gethui()) or CoreGui
    local ok = pcall(function() gui.Parent = target end)
    if not ok then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

local function FindParentScroll(obj)
    local current = obj and obj.Parent
    while current and current ~= game do
        if current:IsA("ScrollingFrame") then return current end
        current = current.Parent
    end
    return nil
end

-- FIX: cegah scroll frame parent scroll saat drag slider/colorpicker
local function SetScrollEnabled(obj, enabled)
    local scroll = FindParentScroll(obj)
    if scroll then scroll.ScrollingEnabled = enabled end
end

-- FIX: input.Position & AbsolutePosition beda ruang koordinat (GUI inset)
local function ScreenPos(input)
    local it = input.UserInputType
    if it == Enum.UserInputType.MouseButton1 or it == Enum.UserInputType.MouseButton2
        or it == Enum.UserInputType.MouseMovement then
        return UserInputService:GetMouseLocation()
    end
    local inset = GuiService:GetGuiInset()
    return Vector2.new(input.Position.X + inset.X, input.Position.Y + inset.Y)
end

local function InBounds(pos, gui)
    if not gui then return false end
    local ap, as = gui.AbsolutePosition, gui.AbsoluteSize
    return pos.X >= ap.X and pos.X <= ap.X + as.X and pos.Y >= ap.Y and pos.Y <= ap.Y + as.Y
end

-- ════════════════════════ CONFIG MANAGER ════════════════════════
local ConfigManager = {}
ConfigManager.__index = ConfigManager

function ConfigManager.new(folderName, defaultFileName)
    local self = setmetatable({}, ConfigManager)
    self.Folder = folderName or "AkbarUI"
    self.DefaultFile = defaultFileName or "default"
    self.Flags = {}
    return self
end

function ConfigManager:Register(flag, getter, setter)
    if type(flag) ~= "string" or flag == "" then return end
    self.Flags[flag] = { Get = getter, Set = setter }
end

function ConfigManager:Save(fileName)
    fileName = (fileName or self.DefaultFile) .. ".json"
    local data = {}
    for flag, item in pairs(self.Flags) do
        local ok, val = pcall(item.Get)
        if ok then
            if typeof(val) == "Color3" then
                data[flag] = { __type = "Color3", r = val.R, g = val.G, b = val.B }
            elseif typeof(val) == "EnumItem" then
                data[flag] = { __type = "EnumItem", enum = tostring(val.EnumType), name = val.Name }
            else
                data[flag] = val
            end
        end
    end
    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, data)
    if not ok or not encoded then return false end
    if writefile then
        pcall(function()
            if makefolder and (not isfolder or not isfolder(self.Folder)) then
                makefolder(self.Folder)
            end
            writefile(self.Folder .. "/" .. fileName, encoded)
        end)
    else
        _G["AKBAR_CONFIG_" .. self.Folder .. "_" .. fileName] = encoded
    end
    return true
end

function ConfigManager:Load(fileName)
    fileName = (fileName or self.DefaultFile) .. ".json"
    local content = nil
    if readfile and isfile then
        pcall(function()
            if isfile(self.Folder .. "/" .. fileName) then
                content = readfile(self.Folder .. "/" .. fileName)
            end
        end)
    end
    if not content then
        content = _G["AKBAR_CONFIG_" .. self.Folder .. "_" .. fileName]
    end
    if not content then return false end
    local ok, decoded = pcall(HttpService.JSONDecode, HttpService, content)
    if not ok or type(decoded) ~= "table" then return false end
    for flag, val in pairs(decoded) do
        local item = self.Flags[flag]
        if item then
            if type(val) == "table" and val.__type == "Color3" then
                pcall(item.Set, Color3.new(val.r or 0, val.g or 0, val.b or 0))
            elseif type(val) == "table" and val.__type == "EnumItem" then
                -- FIX: EnumItem sebelumnya tersimpan tapi gagal di-load
                local typeName = string.match(tostring(val.enum), "%.([%w_]+)$")
                local enumItem = nil
                if typeName then
                    pcall(function() enumItem = Enum[typeName][val.name] end)
                end
                if enumItem then pcall(item.Set, enumItem) end
            else
                pcall(item.Set, val)
            end
        end
    end
    return true
end

function ConfigManager:Delete(fileName)
    fileName = (fileName or self.DefaultFile) .. ".json"
    if delfile and isfile then
        pcall(function()
            if isfile(self.Folder .. "/" .. fileName) then
                delfile(self.Folder .. "/" .. fileName)
            end
        end)
    else
        _G["AKBAR_CONFIG_" .. self.Folder .. "_" .. fileName] = nil
    end
end

function ConfigManager:List()
    local list = {}
    if listfiles and isfolder and isfolder(self.Folder) then
        for _, filePath in ipairs(listfiles(self.Folder)) do
            local clean = string.match(filePath, "([^/\\]+)%.json$")
            if clean then table.insert(list, clean) end
        end
    else
        local esc = string.gsub(self.Folder, "([%(%)%%%.%[%]%*%+%-%?%^%$])", "%%%1")
        local pattern = "^AKBAR_CONFIG_" .. esc .. "_(.+)%.json$"
        for key, _ in pairs(_G) do
            local clean = string.match(tostring(key), pattern)
            if clean then table.insert(list, clean) end
        end
    end
    table.sort(list)
    return list
end

-- ════════════════════════ PUBLIC THEME API ════════════════════════
function Akbar:SetTheme(newTheme)
    for key, val in pairs(newTheme or {}) do
        if Akbar.Theme[key] ~= nil then Akbar.Theme[key] = val end
    end
    RefreshThemed()
end

function Akbar:SetAccentColor(color)
    Akbar.Theme.Accent = color
    Akbar.Theme.AccentDark = Color3.fromRGB(
        math.clamp(math.floor(color.R * 255) - 20, 0, 255),
        math.clamp(math.floor(color.G * 255) - 20, 0, 255),
        math.clamp(math.floor(color.B * 255) - 20, 0, 255))
    RefreshThemed()
end

function Akbar:SetPreset(name)
    local preset = Akbar.Presets[name]
    if not preset then return false end
    Akbar.Theme.Accent = preset.Accent
    Akbar.Theme.AccentDark = preset.AccentDark
    RefreshThemed()
    return true
end

function Akbar:ListPresets()
    local names = {}
    for name in pairs(Akbar.Presets) do table.insert(names, name) end
    table.sort(names)
    return names
end

function Akbar:SetAnimations(state)
    Akbar.AnimationEnabled = state and true or false
end

function Akbar:RefreshTheme()
    RefreshThemed()
end

-- ════════════════════════ ELEMENT FACTORY ════════════════════════
local function BuildAPI(container, ownerTab)
    local api = {}
    local Window = ownerTab.Window
    local sections = {}

    local function Track(conn)
        table.insert(Window.Connections, conn)
        return conn
    end
    local function AddHook(fn)
        table.insert(ThemeHooks, { Window, fn })
    end
    local function NextOrder()
        return #container:GetChildren() + 1
    end
    local function RegisterFlag(elem, flag)
        if type(flag) == "string" and flag ~= "" then
            Window.Config:Register(flag, function() return elem.Value end,
                function(v) return elem:Set(v, true) end)
        end
    end
    local function CopyTable(t)
        local copy = {}
        for i, v in ipairs(t) do copy[i] = v end
        return copy
    end
    local function NewRow(title, desc, height)
        height = height or (desc and 58) or 46
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, 0, 0, height)
        Themed(Row, "BackgroundColor3", "Surface")
        Row.BackgroundTransparency = 0.55
        Row.BorderSizePixel = 0
        Row.LayoutOrder = NextOrder()
        Round(Row, 8)
        Row.Parent = container

        local Title = Instance.new("TextLabel")
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamMedium
        Themed(Title, "TextColor3", "Text")
        Title.TextSize = 13
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.TextTruncate = Enum.TextTruncate.AtEnd
        Title.Text = title or ""
        Title.Parent = Row

        if desc then
            Title.Position = UDim2.new(0, 14, 0, 8)
            Title.Size = UDim2.new(1, -170, 0, 16)
            local Desc = Instance.new("TextLabel")
            Desc.Position = UDim2.new(0, 14, 0, 25)
            Desc.Size = UDim2.new(1, -28, 0, 14)
            Desc.BackgroundTransparency = 1
            Desc.Font = Enum.Font.Gotham
            Themed(Desc, "TextColor3", "Muted")
            Desc.TextSize = 11
            Desc.TextXAlignment = Enum.TextXAlignment.Left
            Desc.TextTruncate = Enum.TextTruncate.AtEnd
            Desc.Text = desc
            Desc.Parent = Row
        else
            Title.Position = UDim2.new(0, 14, 0, 0)
            Title.Size = UDim2.new(1, -170, 1, 0)
            Title.TextYAlignment = Enum.TextYAlignment.Center
        end
        return Row, Title
    end

    -- ─────────── SECTION (collapsible + accordion) ───────────
    function api:Section(c)
        if type(c) == "string" then c = { Title = c } end
        c = c or {}
        local expanded = c.Open ~= false

        local Holder = Instance.new("Frame")
        Holder.Size = UDim2.new(1, 0, 0, 0)
        Holder.AutomaticSize = Enum.AutomaticSize.Y
        Holder.BackgroundTransparency = 1
        Holder.LayoutOrder = NextOrder()
        Holder.Parent = container

        local HolderLayout = Instance.new("UIListLayout") -- FIX: cegah Header & Clip overlap di (0,0)
        HolderLayout.SortOrder = Enum.SortOrder.LayoutOrder
        HolderLayout.Parent = Holder

        local Header = Instance.new("TextButton")
        Header.Size = UDim2.new(1, 0, 0, 34)
        Header.LayoutOrder = 1 -- FIX
        Themed(Header, "BackgroundColor3", "Surface2")
        Header.BackgroundTransparency = 0.35
        Header.AutoButtonColor = false
        Header.Text = ""
        Header.BorderSizePixel = 0
        Round(Header, 8)
        Header.Parent = Holder

        local HTitle = Instance.new("TextLabel")
        HTitle.Position = UDim2.new(0, 14, 0, 0)
        HTitle.Size = UDim2.new(1, -44, 1, 0)
        HTitle.BackgroundTransparency = 1
        HTitle.Font = Enum.Font.GothamBold
        Themed(HTitle, "TextColor3", "Text")
        HTitle.TextSize = 13
        HTitle.TextXAlignment = Enum.TextXAlignment.Left
        HTitle.TextYAlignment = Enum.TextYAlignment.Center
        HTitle.Text = c.Title or "Section"
        HTitle.Parent = Header

        local Chevron = Instance.new("ImageLabel")
        Chevron.AnchorPoint = Vector2.new(1, 0.5)
        Chevron.Position = UDim2.new(1, -12, 0.5, 0)
        Chevron.Size = UDim2.new(0, 14, 0, 14)
        Chevron.BackgroundTransparency = 1
        Chevron.Image = GetIcon("chevron-down")
        Themed(Chevron, "ImageColor3", "Muted")
        Chevron.Rotation = expanded and 180 or 0
        Chevron.Parent = Header

        local Clip = Instance.new("Frame")
        Clip.Size = UDim2.new(1, 0, 0, 0)
        Clip.LayoutOrder = 2 -- FIX
        Clip.ClipsDescendants = true
        Clip.BackgroundTransparency = 1
        Clip.BorderSizePixel = 0
        Clip.Parent = Holder

        local Content = Instance.new("Frame")
        Content.Size = UDim2.new(1, 0, 0, 0)
        Content.AutomaticSize = Enum.AutomaticSize.Y
        Content.BackgroundTransparency = 1
        Content.Parent = Clip

        local CLayout = Instance.new("UIListLayout")
        CLayout.SortOrder = Enum.SortOrder.LayoutOrder
        CLayout.Padding = UDim.new(0, 6)
        CLayout.Parent = Content

        local contentHeight = 0
        CLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            contentHeight = CLayout.AbsoluteContentSize.Y
            if expanded then
                Clip.Size = UDim2.new(1, 0, 0, contentHeight + 4)
            end
        end)

        local Section = { Expanded = expanded }

        local function SetExpanded(state)
            expanded = state and true or false
            Section.Expanded = expanded
            Tween(Chevron, TI(0.25), { Rotation = expanded and 180 or 0 })
            Tween(Clip, TI(0.25), {
                Size = expanded and UDim2.new(1, 0, 0, contentHeight + 4) or UDim2.new(1, 0, 0, 0)
            })
        end

        Header.Activated:Connect(function()
            if expanded then
                SetExpanded(false)
            else
                if Window.Accordion then
                    for _, s in ipairs(sections) do
                        if s ~= Section and s.Expanded then s:Collapse() end
                    end
                end
                SetExpanded(true)
            end
        end)

        function Section:Collapse() SetExpanded(false) end
        function Section:Expand() SetExpanded(true) end
        function Section:SetExpanded(state) SetExpanded(state and true or false) end

        local sub = BuildAPI(Content, ownerTab)
        for k, v in pairs(sub) do
            if type(v) == "function" and Section[k] == nil then
                Section[k] = v
            end
        end

        table.insert(sections, Section)
        task.defer(function()
            contentHeight = CLayout.AbsoluteContentSize.Y
            if expanded then Clip.Size = UDim2.new(1, 0, 0, contentHeight + 4) end
        end)
        return Section
    end

    -- ─────────── TOGGLE ───────────
    function api:Toggle(c)
        c = c or {}
        local Row = NewRow(c.Title, c.Desc)
        local Value = c.Default and true or false
        local Toggle = { Value = Value }

        local Pill = Instance.new("Frame")
        Pill.AnchorPoint = Vector2.new(1, 0.5)
        Pill.Position = UDim2.new(1, -14, 0.5, 0)
        Pill.Size = UDim2.new(0, 42, 0, 22)
        Pill.BackgroundColor3 = Akbar.Theme.Surface2
        Pill.BorderSizePixel = 0
        Pill.ZIndex = 2
        Round(Pill, 11)
        Pill.Parent = Row
        Stroke(Pill, "Border", 0.6, 1)

        local Knob = Instance.new("Frame")
        Knob.Position = UDim2.new(0, 3, 0.5, -8)
        Knob.Size = UDim2.new(0, 16, 0, 16)
        Knob.BackgroundColor3 = Akbar.Theme.BorderLight
        Knob.BorderSizePixel = 0
        Knob.ZIndex = 3
        Round(Knob, 8)
        Knob.Parent = Pill

        local Hitbox = Instance.new("TextButton")
        Hitbox.Size = UDim2.new(1, 0, 1, 0)
        Hitbox.BackgroundTransparency = 1
        Hitbox.Text = ""
        Hitbox.ZIndex = 4
        Hitbox.Parent = Row

        local PillScale = Instance.new("UIScale") -- PREMIUM: pill mengecil dikit saat ditekan
        PillScale.Scale = 1
        PillScale.Parent = Pill
        Hitbox.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Tween(PillScale, TI(0.08, Enum.EasingStyle.Quad), { Scale = 0.9 })
            end
        end)
        Hitbox.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Tween(PillScale, TI(0.15, Enum.EasingStyle.Back), { Scale = 1 })
            end
        end)

        local function Render(instant)
            local targetColor = Value and Akbar.Theme.Accent or Akbar.Theme.Surface2
            local targetPos = Value and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            local knobColor = Value and Color3.fromRGB(255, 255, 255) or Akbar.Theme.BorderLight
            if instant then
                Pill.BackgroundColor3 = targetColor
                Knob.Position = targetPos
                Knob.BackgroundColor3 = knobColor
            else
                Tween(Pill, TI(0.2), { BackgroundColor3 = targetColor })
                Tween(Knob, TI(0.2), { Position = targetPos, BackgroundColor3 = knobColor })
            end
        end

        Hitbox.Activated:Connect(function()
            Toggle:Set(not Value)
        end)

        function Toggle:Set(value, silent)
            Value = value and true or false
            Toggle.Value = Value
            Render(false)
            if not silent and c.Callback then
                task.spawn(c.Callback, Value)
            end
        end

        function Toggle:Get() return Value end

        Render(true)
        AddHook(function() Render(true) end)
        RegisterFlag(Toggle, c.Flag)
        return Toggle
    end

    -- ─────────── SLIDER ───────────
    function api:Slider(c)
        c = c or {}
        local min = c.Min or 0
        local max = c.Max or 100
        if max <= min then max = min + 1 end
        local precision = c.Precision or c.Decimals or 0
        if precision < 0 then precision = 0 end
        local step = c.Step
        local suffix = c.Suffix or ""
        local value = math.clamp(tonumber(c.Default) or min, min, max)

        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, 0, 0, c.Desc and 66 or 60)
        Themed(Row, "BackgroundColor3", "Surface")
        Row.BackgroundTransparency = 0.55
        Row.BorderSizePixel = 0
        Row.LayoutOrder = NextOrder()
        Round(Row, 8)
        Row.Parent = container

        local Title = Instance.new("TextLabel")
        Title.Position = UDim2.new(0, 14, 0, 9)
        Title.Size = UDim2.new(1, -130, 0, 16)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamMedium
        Themed(Title, "TextColor3", "Text")
        Title.TextSize = 13
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.TextTruncate = Enum.TextTruncate.AtEnd
        Title.Text = c.Title or "Slider"
        Title.Parent = Row

        if c.Desc then
            local Desc = Instance.new("TextLabel")
            Desc.Position = UDim2.new(0, 14, 0, 25)
            Desc.Size = UDim2.new(1, -28, 0, 14)
            Desc.BackgroundTransparency = 1
            Desc.Font = Enum.Font.Gotham
            Themed(Desc, "TextColor3", "Muted")
            Desc.TextSize = 11
            Desc.TextXAlignment = Enum.TextXAlignment.Left
            Desc.TextTruncate = Enum.TextTruncate.AtEnd
            Desc.Text = c.Desc
            Desc.Parent = Row
        end

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.AnchorPoint = Vector2.new(1, 0)
        ValueLabel.Position = UDim2.new(1, -14, 0, 9)
        ValueLabel.Size = UDim2.new(0, 100, 0, 16)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Font = Enum.Font.GothamBold
        Themed(ValueLabel, "TextColor3", "Muted")
        ValueLabel.TextSize = 12
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.Parent = Row

        local TrackBar = Instance.new("Frame")
        TrackBar.Position = UDim2.new(0, 14, 0, c.Desc and 46 or 42)
        TrackBar.Size = UDim2.new(1, -28, 0, 6)
        Themed(TrackBar, "BackgroundColor3", "Surface2")
        TrackBar.BorderSizePixel = 0
        TrackBar.Parent = Row
        Round(TrackBar, 3)

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new(0, 0, 1, 0)
        Fill.BackgroundColor3 = Akbar.Theme.Accent
        Fill.BorderSizePixel = 0
        Fill.ZIndex = 2
        Fill.Parent = TrackBar
        Round(Fill, 3)

        local Knob = Instance.new("Frame")
        Knob.AnchorPoint = Vector2.new(0.5, 0.5)
        Knob.Position = UDim2.new(0, 0, 0.5, 0)
        Knob.Size = UDim2.new(0, 14, 0, 14)
        Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Knob.BorderSizePixel = 0
        Knob.ZIndex = 3
        Knob.Parent = TrackBar
        Round(Knob, 7)
        Stroke(Knob, "Border", 0.4, 1)

        local Slider = { Value = value }
        local function ToAlpha(v) return (v - min) / (max - min) end
        local function FromAlpha(a)
            local v = min + (max - min) * a
            if step and step > 0 then v = math.floor(v / step + 0.5) * step end
            return tonumber(string.format("%." .. precision .. "f", math.clamp(v, min, max)))
        end

        local function Render()
            local alpha = math.clamp(ToAlpha(value), 0, 1)
            Fill.Size = UDim2.new(alpha, 0, 1, 0)
            Knob.Position = UDim2.new(alpha, 0, 0.5, 0)
            ValueLabel.Text = string.format("%." .. precision .. "f", value) .. suffix
        end

        local dragging = false
        TrackBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                SetScrollEnabled(TrackBar, false)
                local pos = ScreenPos(input)
                local alpha = math.clamp((pos.X - TrackBar.AbsolutePosition.X) / math.max(TrackBar.AbsoluteSize.X, 1), 0, 1)
                Slider:Set(FromAlpha(alpha))
                local releaseConn
                releaseConn = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        SetScrollEnabled(TrackBar, true)
                        if releaseConn then releaseConn:Disconnect() end
                    end
                end)
            end
        end)

        Track(UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local pos = ScreenPos(input)
                local alpha = math.clamp((pos.X - TrackBar.AbsolutePosition.X) / math.max(TrackBar.AbsoluteSize.X, 1), 0, 1)
                Slider:Set(FromAlpha(alpha))
            end
        end))

        function Slider:Set(v, silent)
            v = tonumber(v)
            if v == nil then return end
            if step and step > 0 then v = math.floor(v / step + 0.5) * step end
            v = tonumber(string.format("%." .. precision .. "f", math.clamp(v, min, max)))
            local changed = v ~= value
            value = v
            Slider.Value = value
            Render()
            if changed and not silent and c.Callback then
                task.spawn(c.Callback, value)
            end
        end

        function Slider:Get() return value end

        Render()
        AddHook(function() Fill.BackgroundColor3 = Akbar.Theme.Accent end)
        RegisterFlag(Slider, c.Flag)
        return Slider
    end

    -- ─────────── DROPDOWN (single & multi) ───────────
    function api:Dropdown(c)
        c = c or {}
        local options = {}
        for _, o in ipairs(c.Options or {}) do table.insert(options, tostring(o)) end
        local multi = c.Multi and true or false
        local Value
        if multi then
            Value = {}
            for _, d in ipairs(c.Default or {}) do table.insert(Value, tostring(d)) end
        else
            Value = (c.Default ~= nil and tostring(c.Default)) or options[1] or ""
        end

        local Row = NewRow(c.Title, c.Desc)
        local Dropdown = { Value = Value }

        local OpenBtn = Instance.new("TextButton")
        OpenBtn.AnchorPoint = Vector2.new(1, 0.5)
        OpenBtn.Position = UDim2.new(1, -14, 0.5, 0)
        OpenBtn.Size = UDim2.new(0, 140, 0, 28)
        Themed(OpenBtn, "BackgroundColor3", "Surface2")
        OpenBtn.AutoButtonColor = false
        OpenBtn.Text = ""
        OpenBtn.BorderSizePixel = 0
        Round(OpenBtn, 6)
        OpenBtn.Parent = Row
        Stroke(OpenBtn, "Border", 0.6, 1)

        local ValLabel = Instance.new("TextLabel")
        ValLabel.Position = UDim2.new(0, 10, 0, 0)
        ValLabel.Size = UDim2.new(1, -32, 1, 0)
        ValLabel.BackgroundTransparency = 1
        ValLabel.Font = Enum.Font.GothamMedium
        Themed(ValLabel, "TextColor3", "Text")
        ValLabel.TextSize = 12
        ValLabel.TextXAlignment = Enum.TextXAlignment.Left
        ValLabel.TextTruncate = Enum.TextTruncate.AtEnd
        ValLabel.Parent = OpenBtn

        local Chevron = Instance.new("ImageLabel")
        Chevron.AnchorPoint = Vector2.new(1, 0.5)
        Chevron.Position = UDim2.new(1, -8, 0.5, 0)
        Chevron.Size = UDim2.new(0, 12, 0, 12)
        Chevron.BackgroundTransparency = 1
        Chevron.Image = GetIcon("chevron-down")
        Themed(Chevron, "ImageColor3", "Muted")
        Chevron.Parent = OpenBtn

        local ListFrame = Instance.new("Frame")
        ListFrame.Size = UDim2.new(1, 0, 0, 0)
        ListFrame.ClipsDescendants = true
        Themed(ListFrame, "BackgroundColor3", "Surface")
        ListFrame.BackgroundTransparency = 0.3
        ListFrame.BorderSizePixel = 0
        ListFrame.Visible = false
        ListFrame.LayoutOrder = NextOrder()
        Round(ListFrame, 8)
        ListFrame.Parent = container
        Stroke(ListFrame, "Border", 0.6, 1)

        local ListScroll = Instance.new("ScrollingFrame")
        ListScroll.Size = UDim2.new(1, -8, 1, -8)
        ListScroll.Position = UDim2.new(0, 4, 0, 4)
        ListScroll.BackgroundTransparency = 1
        ListScroll.BorderSizePixel = 0
        ListScroll.ScrollBarThickness = 3
        Themed(ListScroll, "ScrollBarImageColor3", "Border")
        ListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        ListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        ListScroll.Parent = ListFrame

        local LLayout = Instance.new("UIListLayout")
        LLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LLayout.Padding = UDim.new(0, 2)
        LLayout.Parent = ListScroll

        local expanded = false
        local optionButtons = {}

        local function DisplayText()
            if multi then
                if #Value == 0 then return "None" end
                if #Value == 1 then return Value[1] end
                return tostring(#Value) .. " selected"
            end
            return (Value ~= "" and Value) or "None"
        end

        local function RenderOptions()
            ValLabel.Text = DisplayText()
            for opt, info in pairs(optionButtons) do
                local selected
                if multi then selected = table.find(Value, opt) ~= nil else selected = (opt == Value) end
                info.Label.TextColor3 = selected and Akbar.Theme.Accent or Akbar.Theme.Muted
                info.Check.ImageColor3 = Akbar.Theme.Accent
                info.Check.Visible = selected
            end
        end

        local function SetOpen(state)
            expanded = state and true or false
            if expanded then ListFrame.Visible = true end
            local target = expanded and math.clamp(#options * 30 + 10, 0, 164) or 0
            Tween(ListFrame, TI(0.25), { Size = UDim2.new(1, 0, 0, target) })
            Tween(Chevron, TI(0.25), { Rotation = expanded and 180 or 0 })
            if not expanded then
                task.delay(0.3, function()
                    if not expanded then ListFrame.Visible = false end
                end)
            end
        end

        local function BuildOptions()
            for _, child in ipairs(ListScroll:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            optionButtons = {}
            for i, opt in ipairs(options) do
                local Opt = Instance.new("TextButton")
                Opt.Size = UDim2.new(1, 0, 0, 28)
                Opt.BackgroundTransparency = 1
                Opt.AutoButtonColor = false
                Opt.Text = ""
                Opt.BorderSizePixel = 0
                Opt.LayoutOrder = i
                Opt.Parent = ListScroll

                local OL = Instance.new("TextLabel")
                OL.Position = UDim2.new(0, 10, 0, 0)
                OL.Size = UDim2.new(1, -40, 1, 0)
                OL.BackgroundTransparency = 1
                OL.Font = Enum.Font.GothamMedium
                Themed(OL, "TextColor3", "Muted")
                OL.TextSize = 12
                OL.TextXAlignment = Enum.TextXAlignment.Left
                OL.TextTruncate = Enum.TextTruncate.AtEnd
                OL.Text = opt
                OL.Parent = Opt

                local Check = Instance.new("ImageLabel")
                Check.AnchorPoint = Vector2.new(1, 0.5)
                Check.Position = UDim2.new(1, -10, 0.5, 0)
                Check.Size = UDim2.new(0, 14, 0, 14)
                Check.BackgroundTransparency = 1
                Check.Image = GetIcon("check")
                Check.ImageColor3 = Akbar.Theme.Accent
                Check.Visible = false
                Check.Parent = Opt

                optionButtons[opt] = { Label = OL, Check = Check }

                Opt.MouseEnter:Connect(function() OL.TextColor3 = Akbar.Theme.Text end)
                Opt.MouseLeave:Connect(function() RenderOptions() end)

                Opt.Activated:Connect(function()
                    if multi then
                        local idx = table.find(Value, opt)
                        if idx then table.remove(Value, idx) else table.insert(Value, opt) end
                        RenderOptions()
                        if c.Callback then task.spawn(c.Callback, CopyTable(Value)) end
                    else
                        if Value ~= opt then
                            Value = opt
                            Dropdown.Value = Value
                            RenderOptions()
                            if c.Callback then task.spawn(c.Callback, Value) end
                        end
                        SetOpen(false)
                    end
                end)
            end
            RenderOptions()
        end

        OpenBtn.Activated:Connect(function() SetOpen(not expanded) end)
        OpenBtn.MouseEnter:Connect(function()
            Tween(OpenBtn, TI(0.15), { BackgroundTransparency = 0.35 })
        end)
        OpenBtn.MouseLeave:Connect(function()
            Tween(OpenBtn, TI(0.15), { BackgroundTransparency = 0 })
        end)

        -- FIX: tutup dropdown kalau klik di luar area dropdown
        Track(UserInputService.InputBegan:Connect(function(input)
            if not expanded then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local pos = ScreenPos(input)
                if not InBounds(pos, ListFrame) and not InBounds(pos, OpenBtn) and not InBounds(pos, Row) then
                    SetOpen(false)
                end
            end
        end))

        function Dropdown:Set(v, silent)
            if multi then
                local list = {}
                if type(v) == "table" then
                    for _, x in ipairs(v) do table.insert(list, tostring(x)) end
                elseif v ~= nil then
                    table.insert(list, tostring(v))
                end
                Value = list
            else
                Value = tostring(v ~= nil and v or "")
            end
            Dropdown.Value = Value
            RenderOptions()
            if not silent and c.Callback then
                task.spawn(c.Callback, multi and CopyTable(Value) or Value)
            end
        end

        function Dropdown:Get()
            return multi and CopyTable(Value) or Value
        end

        function Dropdown:Refresh(newOptions, keepSelection)
            options = {}
            for _, o in ipairs(newOptions or {}) do table.insert(options, tostring(o)) end
            if multi then
                local kept = {}
                for _, val in ipairs(Value) do
                    if table.find(options, val) then table.insert(kept, val) end
                end
                Value = (keepSelection and kept) or {}
            else
                if not keepSelection or not table.find(options, Value) then
                    Value = options[1] or ""
                end
            end
            Dropdown.Value = Value
            BuildOptions()
        end

        BuildOptions()
        AddHook(RenderOptions)
        RegisterFlag(Dropdown, c.Flag)
        return Dropdown
    end

    -- ─────────── BUTTON ───────────
    function api:Button(c)
        c = c or {}
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, c.Height or 40)
        Themed(Btn, "BackgroundColor3", c.Primary and "Accent" or "Surface2")
        Btn.AutoButtonColor = false
        Btn.BorderSizePixel = 0
        Btn.Font = Enum.Font.GothamBold
        Themed(Btn, "TextColor3", "Text")
        Btn.TextSize = 13
        Btn.Text = c.Title or "Button"
        Btn.LayoutOrder = NextOrder()
        Round(Btn, 8)
        Btn.Parent = container
        PressFeedback(Btn) -- PREMIUM: efek tactile

        if c.Primary then
            Stroke(Btn, "Accent", 0.55, 1) -- PREMIUM: glow tipis di tombol primary
        end

        Btn.MouseEnter:Connect(function() Tween(Btn, TI(0.15), { BackgroundTransparency = 0.25 }) end)
        Btn.MouseLeave:Connect(function() Tween(Btn, TI(0.15), { BackgroundTransparency = 0 }) end)

        local busy = false -- FIX: cegah spam-klik/double-fire pas mobile nge-tap cepat
        Btn.Activated:Connect(function()
            if busy then return end
            busy = true
            if c.Callback then
                local ok, err = pcall(c.Callback)
                if not ok then warn("[AkbarUI] Button callback error:", err) end
            end
            task.wait(0.15)
            busy = false
        end)

        local obj = { Instance = Btn }
        function obj:Set(text) Btn.Text = tostring(text or "") end
        return obj
    end


    -- ─────────── LABEL / PARAGRAPH / DIVIDER ───────────
    function api:Label(c)
        c = c or {}
        local L = Instance.new("TextLabel")
        L.Size = UDim2.new(1, 0, 0, 0)
        L.AutomaticSize = Enum.AutomaticSize.Y
        L.BackgroundTransparency = 1
        L.Font = Enum.Font.GothamMedium
        Themed(L, "TextColor3", "Text")
        L.TextSize = 13
        L.TextWrapped = true
        L.TextXAlignment = Enum.TextXAlignment.Left
        L.Text = c.Title or c.Text or ""
        L.LayoutOrder = NextOrder()
        L.Parent = container
        local obj = {}
        function obj:Set(t) L.Text = tostring(t or "") end
        return obj
    end

    function api:Paragraph(c)
        c = c or {}
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 0)
        Frame.AutomaticSize = Enum.AutomaticSize.Y
        Frame.BackgroundTransparency = 1
        Frame.LayoutOrder = NextOrder()
        Frame.Parent = container

        local T = Instance.new("TextLabel")
        T.Size = UDim2.new(1, 0, 0, 18)
        T.BackgroundTransparency = 1
        T.Font = Enum.Font.GothamBold
        Themed(T, "TextColor3", "Text")
        T.TextSize = 13
        T.TextXAlignment = Enum.TextXAlignment.Left
        T.Text = c.Title or ""
        T.Parent = Frame

        local D = Instance.new("TextLabel")
        D.Position = UDim2.new(0, 0, 0, 20)
        D.Size = UDim2.new(1, 0, 0, 0)
        D.AutomaticSize = Enum.AutomaticSize.Y
        D.BackgroundTransparency = 1
        D.Font = Enum.Font.Gotham
        Themed(D, "TextColor3", "Muted")
        D.TextSize = 12
        D.TextWrapped = true
        D.TextXAlignment = Enum.TextXAlignment.Left
        D.Text = c.Desc or c.Text or ""
        D.Parent = Frame

        local obj = {}
        function obj:Set(title, desc) T.Text = title or "" D.Text = desc or "" end
        return obj
    end

    function api:Divider()
        local Hold = Instance.new("Frame")
        Hold.Size = UDim2.new(1, 0, 0, 10)
        Hold.BackgroundTransparency = 1
        Hold.LayoutOrder = NextOrder()
        Hold.Parent = container
        local Line = Instance.new("Frame")
        Line.AnchorPoint = Vector2.new(0.5, 0.5)
        Line.Position = UDim2.new(0.5, 0, 0.5, 0)
        Line.Size = UDim2.new(1, -8, 0, 1)
        Themed(Line, "BackgroundColor3", "Border")
        Line.BorderSizePixel = 0
        Line.Parent = Hold
        return Hold
    end

    -- ─────────── KEYBIND ───────────
    function api:Keybind(c)
        c = c or {}
        local Row = NewRow(c.Title, c.Desc)
        local current = c.Default
        if type(current) == "string" then
            local ok, resolved = pcall(function() return Enum.KeyCode[current] end)
            if ok and typeof(resolved) == "EnumItem" then current = resolved end
        end
        if typeof(current) ~= "EnumItem" then current = Enum.KeyCode.Unknown end
        local Keybind = { Value = current }
        local listening = false

        local Chip = Instance.new("TextButton")
        Chip.AnchorPoint = Vector2.new(1, 0.5)
        Chip.Position = UDim2.new(1, -14, 0.5, 0)
        Chip.Size = UDim2.new(0, 110, 0, 26)
        Themed(Chip, "BackgroundColor3", "Surface2")
        Chip.AutoButtonColor = false
        Chip.Text = ""
        Chip.BorderSizePixel = 0
        Round(Chip, 6)
        Chip.Parent = Row
        Stroke(Chip, "Border", 0.6, 1)

        local ChipLabel = Instance.new("TextLabel")
        ChipLabel.Size = UDim2.new(1, 0, 1, 0)
        ChipLabel.BackgroundTransparency = 1
        ChipLabel.Font = Enum.Font.GothamBold
        Themed(ChipLabel, "TextColor3", "Muted")
        ChipLabel.TextSize = 11
        ChipLabel.Text = current ~= Enum.KeyCode.Unknown and current.Name or "None"
        ChipLabel.Parent = Chip

        Track(UserInputService.InputBegan:Connect(function(input, processed)
            if listening then
                if processed then return end
                if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                if input.KeyCode == Enum.KeyCode.Escape then
                    listening = false
                    ChipLabel.Text = Keybind.Value ~= Enum.KeyCode.Unknown and Keybind.Value.Name or "None"
                    return
                end
                if input.KeyCode ~= Enum.KeyCode.Unknown then
                    Keybind:Set(input.KeyCode)
                    listening = false
                end
                return
            end
            if processed then return end
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Keybind.Value then
                if c.Callback then task.spawn(c.Callback, Keybind.Value.Name) end
            end
        end))

        Chip.Activated:Connect(function()
            if listening then
                listening = false
                ChipLabel.Text = Keybind.Value ~= Enum.KeyCode.Unknown and Keybind.Value.Name or "None"
            else
                listening = true
                ChipLabel.Text = "Press key..."
            end
        end)

        function Keybind:Set(key, silent)
            if type(key) == "string" then
                local ok, resolved = pcall(function() return Enum.KeyCode[key] end)
                if ok and typeof(resolved) == "EnumItem" then key = resolved end
            end
            if typeof(key) ~= "EnumItem" then return end
            Keybind.Value = key
            ChipLabel.Text = key ~= Enum.KeyCode.Unknown and key.Name or "None"
            if not silent and c.OnChanged then task.spawn(c.OnChanged, key) end
        end

        RegisterFlag(Keybind, c.Flag)
        return Keybind
    end

    -- ─────────── COLOR PICKER ───────────
    function api:ColorPicker(c)
        c = c or {}
        local Row = NewRow(c.Title or "Color", c.Desc)
        local current = c.Default or Akbar.Theme.Accent
        local h, s, v = Color3.toHSV(current)
        local Picker = { Value = current }
        local expanded = false

        local Swatch = Instance.new("TextButton")
        Swatch.AnchorPoint = Vector2.new(1, 0.5)
        Swatch.Position = UDim2.new(1, -14, 0.5, 0)
        Swatch.Size = UDim2.new(0, 34, 0, 26)
        Swatch.BackgroundColor3 = current
        Swatch.AutoButtonColor = false
        Swatch.Text = ""
        Swatch.BorderSizePixel = 0
        Round(Swatch, 6)
        Swatch.Parent = Row
        Stroke(Swatch, "Border", 0.5, 1)

        local Panel = Instance.new("Frame")
        Panel.Size = UDim2.new(1, 0, 0, 0)
        Panel.ClipsDescendants = true
        Themed(Panel, "BackgroundColor3", "Surface")
        Panel.BackgroundTransparency = 0.3
        Panel.BorderSizePixel = 0
        Panel.Visible = false
        Panel.LayoutOrder = NextOrder()
        Round(Panel, 8)
        Panel.Parent = container
        Stroke(Panel, "Border", 0.6, 1)

        local SV = Instance.new("Frame")
        SV.Position = UDim2.new(0, 12, 0, 12)
        SV.Size = UDim2.new(0, 130, 0, 110)
        SV.BackgroundColor3 = Color3.new(1, 1, 1)
        SV.BorderSizePixel = 0
        SV.Parent = Panel
        local SVGrad = Instance.new("UIGradient")
        SVGrad.Rotation = 0
        SVGrad.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(h, 1, 1))
        SVGrad.Parent = SV

        local SVOverlay = Instance.new("Frame")
        SVOverlay.Size = UDim2.new(1, 0, 1, 0)
        SVOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
        SVOverlay.BorderSizePixel = 0
        SVOverlay.ZIndex = 2
        SVOverlay.Parent = SV
        local OVGrad = Instance.new("UIGradient")
        OVGrad.Rotation = 90
        OVGrad.Transparency = NumberSequence.new(1, 0)
        OVGrad.Parent = SVOverlay

        local SVCursor = Instance.new("Frame")
        SVCursor.AnchorPoint = Vector2.new(0.5, 0.5)
        SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
        SVCursor.Size = UDim2.new(0, 10, 0, 10)
        SVCursor.BackgroundColor3 = Color3.new(1, 1, 1)
        SVCursor.BorderSizePixel = 0
        SVCursor.ZIndex = 3
        SVCursor.Parent = SV
        local svStroke = Instance.new("UIStroke")
        svStroke.Color = Color3.fromRGB(25, 25, 25)
        svStroke.Thickness = 1
        svStroke.Parent = SVCursor

        local HueBar = Instance.new("Frame")
        HueBar.Position = UDim2.new(0, 152, 0, 12)
        HueBar.Size = UDim2.new(0, 14, 0, 110)
        HueBar.BackgroundColor3 = Color3.new(1, 1, 1)
        HueBar.BorderSizePixel = 0
        HueBar.Parent = Panel
        local HueGrad = Instance.new("UIGradient")
        HueGrad.Rotation = 90
        local hueKeys = {}
        for i = 0, 6 do
            table.insert(hueKeys, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1)))
        end
        HueGrad.Color = ColorSequence.new(hueKeys)
        HueGrad.Parent = HueBar

        local HueCursor = Instance.new("Frame")
        HueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
        HueCursor.Position = UDim2.new(0.5, 0, h, 0)
        HueCursor.Size = UDim2.new(0, 18, 0, 4)
        HueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
        HueCursor.BorderSizePixel = 0
        HueCursor.ZIndex = 2
        HueCursor.Parent = HueBar
        local hueStroke = Instance.new("UIStroke")
        hueStroke.Color = Color3.fromRGB(25, 25, 25)
        hueStroke.Thickness = 1
        hueStroke.Parent = HueCursor

        local RGBLabel = Instance.new("TextLabel")
        RGBLabel.Position = UDim2.new(0, 176, 0, 14)
        RGBLabel.Size = UDim2.new(1, -188, 0, 16)
        RGBLabel.BackgroundTransparency = 1
        RGBLabel.Font = Enum.Font.GothamMedium
        Themed(RGBLabel, "TextColor3", "Muted")
        RGBLabel.TextSize = 11
        RGBLabel.TextXAlignment = Enum.TextXAlignment.Left
        RGBLabel.Parent = Panel

        local Preview = Instance.new("Frame")
        Preview.Position = UDim2.new(0, 176, 0, 38)
        Preview.Size = UDim2.new(1, -188, 0, 8)
        Preview.BackgroundColor3 = current
        Preview.BorderSizePixel = 0
        Preview.Parent = Panel
        Round(Preview, 4)

        local function Update(silent)
            current = Color3.fromHSV(h, s, v)
            SVGrad.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(h, 1, 1))
            SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
            HueCursor.Position = UDim2.new(0.5, 0, h, 0)
            Swatch.BackgroundColor3 = current
            Preview.BackgroundColor3 = current
            Picker.Value = current
            RGBLabel.Text = string.format("RGB: %d, %d, %d",
                math.floor(current.R * 255 + 0.5),
                math.floor(current.G * 255 + 0.5),
                math.floor(current.B * 255 + 0.5))
            if not silent and c.Callback then
                task.spawn(c.Callback, current)
            end
        end

        local draggingSV, draggingHue = false, false

        local function ApplySV(pos)
            local relX = math.clamp(pos.X - SV.AbsolutePosition.X, 0, SV.AbsoluteSize.X)
            local relY = math.clamp(pos.Y - SV.AbsolutePosition.Y, 0, SV.AbsoluteSize.Y)
            s = relX / math.max(SV.AbsoluteSize.X, 1)
            v = 1 - (relY / math.max(SV.AbsoluteSize.Y, 1))
            Update(false)
        end

        local function ApplyHue(pos)
            local relY = math.clamp(pos.Y - HueBar.AbsolutePosition.Y, 0, HueBar.AbsoluteSize.Y)
            h = relY / math.max(HueBar.AbsoluteSize.Y, 1)
            Update(false)
        end

        local function BindDrag(area, isSV, apply)
            area.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if isSV then draggingSV = true else draggingHue = true end
                    SetScrollEnabled(area, false)
                    apply(ScreenPos(input))
                    local releaseConn
                    releaseConn = input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            if isSV then draggingSV = false else draggingHue = false end
                            SetScrollEnabled(area, true)
                            if releaseConn then releaseConn:Disconnect() end
                        end
                    end)
                end
            end)
        end

        BindDrag(SV, true, ApplySV)
        BindDrag(HueBar, false, ApplyHue)

        Track(UserInputService.InputChanged:Connect(function(input)
            if (draggingSV or draggingHue) and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local pos = ScreenPos(input)
                if draggingSV then ApplySV(pos) end
                if draggingHue then ApplyHue(pos) end
            end
        end))

        Swatch.Activated:Connect(function()
            expanded = not expanded
            if expanded then Panel.Visible = true end
            Tween(Panel, TI(0.25), { Size = UDim2.new(1, 0, 0, expanded and 134 or 0) })
            if expanded then
                task.defer(Update, true)
            else
                task.delay(0.3, function() if not expanded then Panel.Visible = false end end)
            end
        end)

        function Picker:Set(color, silent)
            if typeof(color) ~= "Color3" then return end
            h, s, v = Color3.toHSV(color)
            Update(silent)
        end

        Update(true)
        RegisterFlag(Picker, c.Flag)
        return Picker
    end

    -- ─────────── INPUT ───────────
    function api:Input(c)
        c = c or {}
        local Row = NewRow(c.Title, c.Desc)
        local Box = Instance.new("TextBox")
        Box.AnchorPoint = Vector2.new(1, 0.5)
        Box.Position = UDim2.new(1, -14, 0.5, 0)
        Box.Size = UDim2.new(0, 150, 0, 28)
        Themed(Box, "BackgroundColor3", "Surface2")
        Box.BorderSizePixel = 0
        Box.Font = Enum.Font.GothamMedium
        Themed(Box, "TextColor3", "Text")
        Box.TextSize = 12
        Box.PlaceholderText = c.Placeholder or "Type here..."
        Box.PlaceholderColor3 = Akbar.Theme.Muted
        Box.Text = c.Default or ""
        Box.TextXAlignment = Enum.TextXAlignment.Left
        Box.ClearTextOnFocus = false
        Round(Box, 6)
        Box.Parent = Row
        Stroke(Box, "Border", 0.6, 1)

        local Input = { Value = Box.Text }

        Box.FocusLost:Connect(function(enterPressed)
            Input.Value = Box.Text
            if c.Callback then task.spawn(c.Callback, Box.Text, enterPressed) end
        end)

        function Input:Set(text)
            Box.Text = tostring(text or "")
            Input.Value = Box.Text
        end

        RegisterFlag(Input, c.Flag)
        return Input
    end

    -- ─────────── STEPPER (baru) ───────────
    function api:Stepper(c)
        c = c or {}
        local min = (c.Range and c.Range[1]) or 0
        local max = (c.Range and c.Range[2]) or 100
        if max <= min then max = min + 1 end
        local step = c.Increment or 1
        local value = math.clamp(tonumber(c.CurrentValue) or min, min, max)

        local Row = NewRow(c.Title, c.Desc)
        local Stepper = { Value = value }

        local MinusBtn = Instance.new("TextButton")
        MinusBtn.AnchorPoint = Vector2.new(1, 0.5)
        MinusBtn.Position = UDim2.new(1, -104, 0.5, 0)
        MinusBtn.Size = UDim2.new(0, 28, 0, 28)
        Themed(MinusBtn, "BackgroundColor3", "Surface2")
        MinusBtn.AutoButtonColor = false
        MinusBtn.Font = Enum.Font.GothamBold
        Themed(MinusBtn, "TextColor3", "Text")
        MinusBtn.TextSize = 16
        MinusBtn.Text = "-"
        MinusBtn.BorderSizePixel = 0
        Round(MinusBtn, 6)
        MinusBtn.Parent = Row
        Stroke(MinusBtn, "Border", 0.6, 1)
        PressFeedback(MinusBtn, 0.9)

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.AnchorPoint = Vector2.new(1, 0.5)
        ValueLabel.Position = UDim2.new(1, -70, 0.5, 0)
        ValueLabel.Size = UDim2.new(0, 56, 0, 28)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Font = Enum.Font.GothamBold
        Themed(ValueLabel, "TextColor3", "Text")
        ValueLabel.TextSize = 13
        ValueLabel.Text = tostring(value)
        ValueLabel.Parent = Row

        local PlusBtn = Instance.new("TextButton")
        PlusBtn.AnchorPoint = Vector2.new(1, 0.5)
        PlusBtn.Position = UDim2.new(1, -14, 0.5, 0)
        PlusBtn.Size = UDim2.new(0, 28, 0, 28)
        Themed(PlusBtn, "BackgroundColor3", "Surface2")
        PlusBtn.AutoButtonColor = false
        PlusBtn.Font = Enum.Font.GothamBold
        Themed(PlusBtn, "TextColor3", "Text")
        PlusBtn.TextSize = 16
        PlusBtn.Text = "+"
        PlusBtn.BorderSizePixel = 0
        Round(PlusBtn, 6)
        PlusBtn.Parent = Row
        Stroke(PlusBtn, "Border", 0.6, 1)
        PressFeedback(PlusBtn, 0.9)

        function Stepper:Set(v, silent)
            v = tonumber(v)
            if v == nil then return end
            v = math.clamp(v, min, max)
            local changed = v ~= value
            value = v
            Stepper.Value = value
            ValueLabel.Text = tostring(value)
            if changed and not silent and c.Callback then
                task.spawn(c.Callback, value)
            end
        end

        function Stepper:Get() return value end

        MinusBtn.Activated:Connect(function() Stepper:Set(value - step) end)
        PlusBtn.Activated:Connect(function() Stepper:Set(value + step) end)

        RegisterFlag(Stepper, c.Flag)
        return Stepper
    end

    -- ─────────── PROGRESS BAR (baru) ───────────
    function api:Progress(c)
        c = c or {}
        local value = math.clamp(tonumber(c.CurrentValue) or 0, 0, 1)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, 0, 0, 46)
        Themed(Row, "BackgroundColor3", "Surface")
        Row.BackgroundTransparency = 0.55
        Row.BorderSizePixel = 0
        Row.LayoutOrder = NextOrder()
        Round(Row, 8)
        Row.Parent = container

        local Title = Instance.new("TextLabel")
        Title.Position = UDim2.new(0, 14, 0, 8)
        Title.Size = UDim2.new(1, -110, 0, 14)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamMedium
        Themed(Title, "TextColor3", "Text")
        Title.TextSize = 12
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.TextTruncate = Enum.TextTruncate.AtEnd
        Title.Text = c.Title or "Progress"
        Title.Parent = Row

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.AnchorPoint = Vector2.new(1, 0)
        ValueLabel.Position = UDim2.new(1, -14, 0, 8)
        ValueLabel.Size = UDim2.new(0, 90, 0, 14)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Font = Enum.Font.GothamBold
        Themed(ValueLabel, "TextColor3", "Muted")
        ValueLabel.TextSize = 11
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.Parent = Row

        local TrackBar = Instance.new("Frame")
        TrackBar.Position = UDim2.new(0, 14, 0, 28)
        TrackBar.Size = UDim2.new(1, -28, 0, 8)
        Themed(TrackBar, "BackgroundColor3", "Surface2")
        TrackBar.BorderSizePixel = 0
        TrackBar.Parent = Row
        Round(TrackBar, 4)

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new(0, 0, 1, 0)
        Fill.BackgroundColor3 = Akbar.Theme.Accent
        Fill.BorderSizePixel = 0
        Fill.Parent = TrackBar
        Round(Fill, 4)
        local FillGrad = Instance.new("UIGradient") -- PREMIUM: gradient tipis di isi progress bar
        FillGrad.Color = ColorSequence.new(Akbar.Theme.Accent, Akbar.Theme.AccentDark)
        FillGrad.Parent = Fill

        local Progress = { Value = value }
        local function Render(instant)
            local text = c.Format and c.Format(value) or (math.floor(value * 100) .. "%")
            ValueLabel.Text = text
            if instant then
                Fill.Size = UDim2.new(value, 0, 1, 0)
            else
                Tween(Fill, TI(0.3), { Size = UDim2.new(value, 0, 1, 0) })
            end
        end

        function Progress:Set(v)
            v = math.clamp(tonumber(v) or 0, 0, 1)
            value = v
            Progress.Value = value
            Render(false)
        end

        Render(true)
        AddHook(function()
            Fill.BackgroundColor3 = Akbar.Theme.Accent
            FillGrad.Color = ColorSequence.new(Akbar.Theme.Accent, Akbar.Theme.AccentDark)
        end)
        return Progress
    end

    -- ─────────── TOOLTIP / INFO HINT (baru) ───────────
    function api:Tooltip(c)
        c = c or {}
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, 0, 0, 0)
        Row.AutomaticSize = Enum.AutomaticSize.Y
        Row.BackgroundTransparency = 1
        Row.LayoutOrder = NextOrder()
        Row.Parent = container

        local Head = Instance.new("TextButton")
        Head.Size = UDim2.new(1, 0, 0, 30)
        Themed(Head, "BackgroundColor3", "Surface")
        Head.BackgroundTransparency = 0.6
        Head.AutoButtonColor = false
        Head.Text = ""
        Head.BorderSizePixel = 0
        Round(Head, 6)
        Head.Parent = Row
        PressFeedback(Head, 0.98)

        local Icon = Instance.new("ImageLabel")
        Icon.Position = UDim2.new(0, 10, 0.5, -8)
        Icon.Size = UDim2.new(0, 16, 0, 16)
        Icon.BackgroundTransparency = 1
        Icon.Image = GetIcon("info")
        Themed(Icon, "ImageColor3", "Accent")
        Icon.Parent = Head

        local HTitle = Instance.new("TextLabel")
        HTitle.Position = UDim2.new(0, 34, 0, 0)
        HTitle.Size = UDim2.new(1, -50, 1, 0)
        HTitle.BackgroundTransparency = 1
        HTitle.Font = Enum.Font.GothamMedium
        Themed(HTitle, "TextColor3", "Muted")
        HTitle.TextSize = 12
        HTitle.TextXAlignment = Enum.TextXAlignment.Left
        HTitle.Text = c.Title or "Info"
        HTitle.Parent = Head

        local Chevron = Instance.new("ImageLabel")
        Chevron.AnchorPoint = Vector2.new(1, 0.5)
        Chevron.Position = UDim2.new(1, -10, 0.5, 0)
        Chevron.Size = UDim2.new(0, 12, 0, 12)
        Chevron.BackgroundTransparency = 1
        Chevron.Image = GetIcon("chevron-down")
        Themed(Chevron, "ImageColor3", "Muted")
        Chevron.Parent = Head

        local Clip = Instance.new("Frame")
        Clip.Position = UDim2.new(0, 0, 0, 30)
        Clip.Size = UDim2.new(1, 0, 0, 0)
        Clip.ClipsDescendants = true
        Clip.BackgroundTransparency = 1
        Clip.Parent = Row

        local Text = Instance.new("TextLabel")
        Text.Position = UDim2.new(0, 34, 0, 4)
        Text.Size = UDim2.new(1, -44, 0, 0)
        Text.AutomaticSize = Enum.AutomaticSize.Y
        Text.BackgroundTransparency = 1
        Text.Font = Enum.Font.Gotham
        Themed(Text, "TextColor3", "Muted")
        Text.TextSize = 12
        Text.TextWrapped = true
        Text.TextXAlignment = Enum.TextXAlignment.Left
        Text.Text = c.Text or ""
        Text.Parent = Clip

        local expanded = false
        local textHeight = 0
        Text:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            textHeight = Text.AbsoluteSize.Y
            if expanded then Clip.Size = UDim2.new(1, 0, 0, textHeight + 10) end
        end)

        local function SetExpanded(state)
            expanded = state and true or false
            Tween(Chevron, TI(0.2), { Rotation = expanded and 180 or 0 })
            Tween(Clip, TI(0.2), {
                Size = expanded and UDim2.new(1, 0, 0, textHeight + 10) or UDim2.new(1, 0, 0, 0)
            })
        end

        Head.Activated:Connect(function() SetExpanded(not expanded) end)

        local Tooltip = {}
        function Tooltip:Expand() SetExpanded(true) end
        function Tooltip:Collapse() SetExpanded(false) end
        return Tooltip
    end

    return api
end

-- ════════════════════════ WINDOW ════════════════════════
function Akbar:CreateWindow(config)
    config = config or {}
    local WindowName = config.Name or "King Akbar"
    local WindowSubtitle = config.LoadingSubtitle or config.Subtitle or "King Akbar"
    local WindowIcon = config.Icon or "crown"
    local ToggleKey = config.ToggleUIKeybind or config.ToggleKey or "RightControl"
    local WindowSize = config.Size or UDim2.fromOffset(760, 520)
    local MinSize = config.MinSize or Vector2.new(480, 360)
    local MaxSize = config.MaxSize or Vector2.new(1100, 750)
    local MaxNotifs = config.MaxNotifications or 5
    local KeepOnScreen = config.KeepOnScreen ~= false
    local ShadowPad = 12

    local Window = {
        Tabs = {}, ActiveTab = nil, Connections = {},
        Size = WindowSize, MinSize = MinSize, MaxSize = MaxSize,
        IsMinimized = false, IsMaximized = false,
        PreMinimizeSize = WindowSize,
        PreMaximizeSize = WindowSize, PreMaximizePos = UDim2.new(0.5, 0, 0.5, 0),
        Accordion = config.Accordion and true or false,
        SearchEnabled = config.SearchEnabled ~= false,
        Notifications = {},
        Config = ConfigManager.new(
            (config.ConfigurationSaving and config.ConfigurationSaving.FolderName) or "AkbarUI",
            (config.ConfigurationSaving and config.ConfigurationSaving.FileName) or "default"),
    }

    local function Track(conn)
        table.insert(Window.Connections, conn)
        return conn
    end
    local function AddHook(fn)
        table.insert(ThemeHooks, { Window, fn })
    end

    -- Root ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AkbarUI_" .. tostring(WindowName):gsub("%s+", "")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = config.DisplayOrder or 100
    SafeParentGui(ScreenGui, config.Parent)
    Window.ScreenGui = ScreenGui

    -- Shadow + Main Window
    local MainShadow = Instance.new("ImageLabel")
    MainShadow.Name = "Shadow"
    MainShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    MainShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainShadow.Size = WindowSize
    MainShadow.BackgroundTransparency = 1
    MainShadow.Image = "rbxassetid://5554236805"
    MainShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    MainShadow.ImageTransparency = 0.4
    MainShadow.ScaleType = Enum.ScaleType.Slice
    MainShadow.SliceCenter = Rect.new(23, 23, 277, 277)
    MainShadow.ZIndex = 10
    MainShadow.Parent = ScreenGui
    Window.MainShadow = MainShadow

    local MainWindow = Instance.new("Frame")
    MainWindow.Name = "MainWindow"
    MainWindow.Position = UDim2.new(0, ShadowPad, 0, ShadowPad)
    MainWindow.Size = UDim2.new(1, -ShadowPad * 2, 1, -ShadowPad * 2)
    Themed(MainWindow, "BackgroundColor3", "Background")
    MainWindow.BackgroundTransparency = Akbar.Theme.GlassTransparency
    MainWindow.BorderSizePixel = 0
    MainWindow.ClipsDescendants = false
    MainWindow.Parent = MainShadow
    Round(MainWindow, 12)
    Stroke(MainWindow, "Border", 0.3, 1.2)

    -- Notification layer
    local NotificationHolder = Instance.new("Frame")
    NotificationHolder.Name = "Notifications"
    NotificationHolder.AnchorPoint = Vector2.new(1, 1)
    NotificationHolder.Position = UDim2.new(1, -20, 1, -20)
    NotificationHolder.Size = UDim2.new(0, 320, 1, -40)
    NotificationHolder.BackgroundTransparency = 1
    NotificationHolder.ZIndex = 50
    NotificationHolder.Parent = ScreenGui

    local NotifLayout = Instance.new("UIListLayout")
    NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifLayout.Padding = UDim.new(0, 10)
    NotifLayout.Parent = NotificationHolder

    -- Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 52)
    Themed(Header, "BackgroundColor3", "Surface")
    Header.BackgroundTransparency = Akbar.Theme.GlassTransparency
    Header.BorderSizePixel = 0
    Header.Parent = MainWindow
    Round(Header, 12)

    local HeaderMask = Instance.new("Frame")
    HeaderMask.AnchorPoint = Vector2.new(0, 1)
    HeaderMask.Position = UDim2.new(0, 0, 1, 0)
    HeaderMask.Size = UDim2.new(1, 0, 0, 12)
    Themed(HeaderMask, "BackgroundColor3", "Surface")
    HeaderMask.BackgroundTransparency = Akbar.Theme.GlassTransparency
    HeaderMask.BorderSizePixel = 0
    HeaderMask.Parent = Header

    local HeaderLine = Instance.new("Frame")
    HeaderLine.AnchorPoint = Vector2.new(0, 1)
    HeaderLine.Position = UDim2.new(0, 0, 1, 0)
    HeaderLine.Size = UDim2.new(1, 0, 0, 1)
    Themed(HeaderLine, "BackgroundColor3", "Border")
    HeaderLine.BorderSizePixel = 0
    HeaderLine.Parent = Header

    local BrandIcon = Instance.new("ImageLabel")
    BrandIcon.Name = "BrandIcon"
    BrandIcon.Position = UDim2.new(0, 16, 0.5, -12)
    BrandIcon.Size = UDim2.new(0, 24, 0, 24)
    BrandIcon.BackgroundTransparency = 1
    BrandIcon.Image = GetIcon(WindowIcon)
    Themed(BrandIcon, "ImageColor3", "Accent")
    BrandIcon.Parent = Header

    local TitleContainer = Instance.new("Frame")
    TitleContainer.Position = UDim2.new(0, 48, 0, 8)
    TitleContainer.Size = UDim2.new(0, 250, 0, 36)
    TitleContainer.BackgroundTransparency = 1
    TitleContainer.Parent = Header

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 0, 18)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    Themed(TitleLabel, "TextColor3", "Text")
    TitleLabel.TextSize = 15
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Text = WindowName
    TitleLabel.Parent = TitleContainer

    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Position = UDim2.new(0, 0, 0, 18)
    SubtitleLabel.Size = UDim2.new(1, 0, 0, 16)
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Font = Enum.Font.Gotham
    Themed(SubtitleLabel, "TextColor3", "Muted")
    SubtitleLabel.TextSize = 12
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubtitleLabel.Text = WindowSubtitle
    SubtitleLabel.Parent = TitleContainer

    -- Window controls
    local Controls = Instance.new("Frame")
    Controls.Name = "Controls"
    Controls.AnchorPoint = Vector2.new(1, 0.5)
    Controls.Position = UDim2.new(1, -12, 0.5, 0)
    Controls.Size = UDim2.new(0, 105, 0, 32)
    Controls.BackgroundTransparency = 1
    Controls.Parent = Header

    local ControlsLayout = Instance.new("UIListLayout")
    ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
    ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ControlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ControlsLayout.Padding = UDim.new(0, 6)
    ControlsLayout.Parent = Controls

    local function CreateHeaderButton(iconName, isClose)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 28, 0, 28)
        Themed(btn, "BackgroundColor3", "Surface2")
        btn.BackgroundTransparency = 0.5
        btn.AutoButtonColor = false
        btn.Text = ""
        btn.BorderSizePixel = 0
        btn.Parent = Controls
        Round(btn, 7)

        local btnIcon = Instance.new("ImageLabel")
        btnIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        btnIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
        btnIcon.Size = UDim2.new(0, 14, 0, 14)
        btnIcon.BackgroundTransparency = 1
        btnIcon.Image = GetIcon(iconName)
        Themed(btnIcon, "ImageColor3", "Muted")
        btnIcon.Parent = btn

        btn.MouseEnter:Connect(function()
            Tween(btn, TI(0.2), {
                BackgroundColor3 = isClose and Akbar.Theme.Error or Akbar.Theme.SurfaceHover,
                BackgroundTransparency = 0.1
            })
            Tween(btnIcon, TI(0.2), { ImageColor3 = Color3.fromRGB(255, 255, 255) })
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, TI(0.2), { BackgroundColor3 = Akbar.Theme.Surface2, BackgroundTransparency = 0.5 })
            Tween(btnIcon, TI(0.2), { ImageColor3 = Akbar.Theme.Muted })
        end)
        return btn
    end

    local MinBtn = CreateHeaderButton("minus", false)
    local MaxBtn = CreateHeaderButton("maximize", false)
    local CloseBtn = CreateHeaderButton("x", true)

    -- Body
    local BodyContainer = Instance.new("Frame")
    BodyContainer.Name = "BodyContainer"
    BodyContainer.Position = UDim2.new(0, 0, 0, 52)
    BodyContainer.Size = UDim2.new(1, 0, 1, -52)
    BodyContainer.BackgroundTransparency = 1
    BodyContainer.ClipsDescendants = true
    BodyContainer.Parent = MainWindow
    Window.BodyContainer = BodyContainer

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 220, 1, 0)
    Themed(Sidebar, "BackgroundColor3", "Surface")
    Sidebar.BackgroundTransparency = 0.3
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = BodyContainer

    local SidebarRightBorder = Instance.new("Frame")
    SidebarRightBorder.AnchorPoint = Vector2.new(1, 0)
    SidebarRightBorder.Position = UDim2.new(1, 0, 0, 0)
    SidebarRightBorder.Size = UDim2.new(0, 1, 1, 0)
    Themed(SidebarRightBorder, "BackgroundColor3", "Border")
    SidebarRightBorder.BorderSizePixel = 0
    SidebarRightBorder.Parent = Sidebar

    local SearchContainer = Instance.new("Frame")
    SearchContainer.Name = "SearchBox"
    SearchContainer.Position = UDim2.new(0, 12, 0, 12)
    SearchContainer.Size = UDim2.new(1, -24, 0, 36)
    Themed(SearchContainer, "BackgroundColor3", "Surface2")
    SearchContainer.BackgroundTransparency = 0.4
    SearchContainer.BorderSizePixel = 0
    SearchContainer.Parent = Sidebar
    Round(SearchContainer, 8)
    Stroke(SearchContainer, "Border", 0.5, 1)

    local SearchIcon = Instance.new("ImageLabel")
    SearchIcon.Position = UDim2.new(0, 10, 0.5, -8)
    SearchIcon.Size = UDim2.new(0, 16, 0, 16)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Image = GetIcon("search")
    Themed(SearchIcon, "ImageColor3", "Muted")
    SearchIcon.Parent = SearchContainer

    local SearchInput = Instance.new("TextBox")
    SearchInput.Position = UDim2.new(0, 34, 0, 0)
    SearchInput.Size = UDim2.new(1, -40, 1, 0)
    SearchInput.BackgroundTransparency = 1
    SearchInput.Font = Enum.Font.Gotham
    SearchInput.PlaceholderText = "Search..."
    SearchInput.PlaceholderColor3 = Akbar.Theme.Muted
    SearchInput.Text = ""
    Themed(SearchInput, "TextColor3", "Text")
    SearchInput.TextSize = 13
    SearchInput.TextXAlignment = Enum.TextXAlignment.Left
    SearchInput.ClearTextOnFocus = false
    SearchInput.Parent = SearchContainer

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Name = "TabScroll"
    TabScroll.Position = UDim2.new(0, 8, 0, 58)
    TabScroll.Size = UDim2.new(1, -16, 1, -68)
    TabScroll.BackgroundTransparency = 1
    TabScroll.BorderSizePixel = 0
    TabScroll.ScrollBarThickness = 2
    Themed(TabScroll, "ScrollBarImageColor3", "Border")
    TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabScroll.Parent = Sidebar

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 4)
    TabLayout.Parent = TabScroll

    local ContentHolder = Instance.new("Frame")
    ContentHolder.Name = "ContentArea"
    ContentHolder.Position = UDim2.new(0, 220, 0, 0)
    ContentHolder.Size = UDim2.new(1, -220, 1, 0)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.Parent = BodyContainer

    local ContentHeader = Instance.new("Frame")
    ContentHeader.Size = UDim2.new(1, 0, 0, 58)
    ContentHeader.BackgroundTransparency = 1
    ContentHeader.Parent = ContentHolder

    local ContentHeaderPadding = Instance.new("UIPadding")
    ContentHeaderPadding.PaddingLeft = UDim.new(0, 24)
    ContentHeaderPadding.PaddingRight = UDim.new(0, 24)
    ContentHeaderPadding.PaddingTop = UDim.new(0, 12)
    ContentHeaderPadding.Parent = ContentHeader

    local TabHeading = Instance.new("TextLabel")
    TabHeading.Size = UDim2.new(1, 0, 0, 22)
    TabHeading.BackgroundTransparency = 1
    TabHeading.Font = Enum.Font.GothamBold
    Themed(TabHeading, "TextColor3", "Text")
    TabHeading.TextSize = 18
    TabHeading.TextXAlignment = Enum.TextXAlignment.Left
    TabHeading.Text = "Tab"
    TabHeading.Parent = ContentHeader

    local TabDesc = Instance.new("TextLabel")
    TabDesc.Position = UDim2.new(0, 0, 0, 22)
    TabDesc.Size = UDim2.new(1, 0, 0, 16)
    TabDesc.BackgroundTransparency = 1
    TabDesc.Font = Enum.Font.Gotham
    Themed(TabDesc, "TextColor3", "Muted")
    TabDesc.TextSize = 12
    TabDesc.TextXAlignment = Enum.TextXAlignment.Left
    TabDesc.Text = ""
    TabDesc.Parent = ContentHeader

    local PagesContainer = Instance.new("Frame")
    PagesContainer.Name = "Pages"
    PagesContainer.Position = UDim2.new(0, 0, 0, 58)
    PagesContainer.Size = UDim2.new(1, 0, 1, -58)
    PagesContainer.BackgroundTransparency = 1
    PagesContainer.Parent = ContentHolder

    local ResizeGrip = Instance.new("ImageButton")
    ResizeGrip.Name = "ResizeGrip"
    ResizeGrip.AnchorPoint = Vector2.new(1, 1)
    ResizeGrip.Position = UDim2.new(1, -2, 1, -2)
    ResizeGrip.Size = UDim2.new(0, 16, 0, 16)
    ResizeGrip.BackgroundTransparency = 1
    ResizeGrip.Image = "rbxassetid://7734053426"
    Themed(ResizeGrip, "ImageColor3", "Muted")
    ResizeGrip.ImageTransparency = 0.5
    ResizeGrip.ZIndex = 20
    ResizeGrip.Parent = MainWindow

    -- ───── Viewport clamping (FIX: koordinat konsisten + aman respawn) ─────
    local function ClampCenter(center)
        local gs = ScreenGui.AbsoluteSize
        if gs.X <= 0 or gs.Y <= 0 then return center end
        local size = MainShadow.AbsoluteSize
        local halfW, halfH = size.X / 2, size.Y / 2
        local x = math.clamp(center.X, halfW, math.max(halfW, gs.X - halfW))
        local y = math.clamp(center.Y, halfH, math.max(halfH, gs.Y - halfH))
        return Vector2.new(x, y)
    end

    local function CurrentCenter()
        local gs = ScreenGui.AbsoluteSize
        local p = MainShadow.Position
        return Vector2.new(p.X.Scale * gs.X + p.X.Offset, p.Y.Scale * gs.Y + p.Y.Offset)
    end

    local function ClampToViewport()
        if not KeepOnScreen then return end
        local c = ClampCenter(CurrentCenter())
        MainShadow.Position = UDim2.new(0, c.X, 0, c.Y)
    end

    Track(ScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(ClampToViewport))

    -- ───── Drag state ─────
    local isDragging, dragStart, startCenter = false, nil, nil
    local isResizing, resizeStart, startSize = false, nil, nil
    local isFloatDragging, floatStart, floatPos, hasMoved = false, nil, nil, false
    local SetWindowVisible -- forward declaration

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if Window.IsMaximized then return end -- FIX: drag mati saat maximize
            -- FIX: jangan mulai drag kalau pointer di area tombol kontrol
            local ap, as = Controls.AbsolutePosition, Controls.AbsoluteSize
            local p = ScreenPos(input)
            if p.X >= ap.X - 4 and p.X <= ap.X + as.X + 4 and p.Y >= ap.Y - 4 and p.Y <= ap.Y + as.Y + 4 then
                return
            end
            isDragging = true
            dragStart = input.Position
            startCenter = CurrentCenter()
            local releaseConn
            releaseConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                    if releaseConn then releaseConn:Disconnect() end
                end
            end)
        end
    end)

    ResizeGrip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if Window.IsMinimized or Window.IsMaximized then return end -- FIX
            isResizing = true
            resizeStart = input.Position
            startSize = MainShadow.AbsoluteSize
            local releaseConn
            releaseConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isResizing = false
                    if releaseConn then releaseConn:Disconnect() end
                end
            end)
        end
    end)

    -- ───── Floating toggle button ─────
    local OpenButton = nil
    if config.OpenButton ~= false then
        local btnConfig = config.OpenButton or {}
        local FloatBtn = Instance.new("ImageButton")
        FloatBtn.Name = "Akbar_ToggleIcon"
        FloatBtn.Size = UDim2.new(0, 42, 0, 42)
        FloatBtn.Position = btnConfig.Position or UDim2.new(0, 16, 0, 16)
        Themed(FloatBtn, "BackgroundColor3", "Surface")
        FloatBtn.BackgroundTransparency = 0.2
        FloatBtn.Image = GetIcon(btnConfig.Icon or WindowIcon)
        Themed(FloatBtn, "ImageColor3", "Accent")
        FloatBtn.BorderSizePixel = 0
        FloatBtn.ZIndex = 120
        FloatBtn.Parent = ScreenGui
        Round(FloatBtn, 10)
        Stroke(FloatBtn, "BorderLight", 0.3, 1.2)

        FloatBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isFloatDragging = true
                hasMoved = false
                floatStart = input.Position
                floatPos = FloatBtn.Position
                local releaseConn
                releaseConn = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        isFloatDragging = false
                        if releaseConn then releaseConn:Disconnect() end
                        -- FIX: clamp biar tidak bisa di-drag keluar layar
                        local gs = ScreenGui.AbsoluteSize
                        local p = FloatBtn.Position
                        local x = math.clamp(p.X.Scale * gs.X + p.X.Offset, 8, math.max(8, gs.X - 50))
                        local y = math.clamp(p.Y.Scale * gs.Y + p.Y.Offset, 8, math.max(8, gs.Y - 50))
                        FloatBtn.Position = UDim2.new(0, x, 0, y)
                    end
                end)
            end
        end)

        FloatBtn.Activated:Connect(function()
            if not hasMoved then
                SetWindowVisible(not MainShadow.Visible)
            end
        end)

        OpenButton = FloatBtn
    end
    Window.OpenButton = OpenButton

    -- ───── FIX: satu koneksi InputChanged untuk semua (drag/resize/float) ─────
    Track(UserInputService.InputChanged:Connect(function(input)
        local isMove = input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        if not isMove then return end

        if isDragging then
            local delta = input.Position - dragStart
            local desired = startCenter + Vector2.new(delta.X, delta.Y)
            local c = KeepOnScreen and ClampCenter(desired) or desired
            MainShadow.Position = UDim2.new(0, c.X, 0, c.Y)

        elseif isResizing then
            local delta = input.Position - resizeStart
            local gs = ScreenGui.AbsoluteSize
            local newX = math.clamp(startSize.X + delta.X, Window.MinSize.X, math.min(Window.MaxSize.X, gs.X - 16))
            local newY = math.clamp(startSize.Y + delta.Y, Window.MinSize.Y, math.min(Window.MaxSize.Y, gs.Y - 16))
            local newSize = UDim2.fromOffset(newX, newY)
            MainShadow.Size = newSize
            Window.Size = newSize
            ClampToViewport()

        elseif isFloatDragging and OpenButton then
            local delta = input.Position - floatStart
            if math.abs(delta.X) > 6 or math.abs(delta.Y) > 6 then hasMoved = true end
            OpenButton.Position = UDim2.new(
                floatPos.X.Scale, floatPos.X.Offset + delta.X,
                floatPos.Y.Scale, floatPos.Y.Offset + delta.Y)
        end
    end))

    -- ───── Show / hide dengan animasi (FIX: tidak blokir thread UI) ─────
    SetWindowVisible = function(visible)
        if visible then
            if Window.IsMinimized then
                Window.IsMinimized = false
                BodyContainer.Size = UDim2.new(1, 0, 1, -52)
                MainShadow.Size = Window.PreMinimizeSize or Window.Size
                ResizeGrip.Visible = not Window.IsMaximized
            end
            MainShadow.Visible = true
            if not Window.IsMaximized then
                local wsx, wsy = Window.Size.X.Offset, Window.Size.Y.Offset
                local baseX = (MainShadow.AbsoluteSize.X > 0 and MainShadow.AbsoluteSize.X) or (wsx > 0 and wsx) or 760
                local baseY = (MainShadow.AbsoluteSize.Y > 0 and MainShadow.AbsoluteSize.Y) or (wsy > 0 and wsy) or 520
                MainShadow.Size = UDim2.fromOffset(baseX * 0.9, baseY * 0.9)
                Tween(MainShadow, TI(0.25), { Size = UDim2.fromOffset(baseX, baseY) })
                Window.Size = UDim2.fromOffset(baseX, baseY)
            end
            ClampToViewport()
        else
            if Window.IsMinimized then
                MainShadow.Visible = false
                return
            end
            task.spawn(function()
                local wsx, wsy = Window.Size.X.Offset, Window.Size.Y.Offset
                local baseX = (MainShadow.AbsoluteSize.X > 0 and MainShadow.AbsoluteSize.X) or (wsx > 0 and wsx) or 760
                local baseY = (MainShadow.AbsoluteSize.Y > 0 and MainShadow.AbsoluteSize.Y) or (wsy > 0 and wsy) or 520
                local shrink = Tween(MainShadow, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                    Size = UDim2.fromOffset(baseX * 0.88, baseY * 0.88)
                })
                if shrink then shrink.Completed:Wait() end
                MainShadow.Visible = false
                MainShadow.Size = UDim2.fromOffset(baseX, baseY)
                Window.Size = UDim2.fromOffset(baseX, baseY)
            end)
        end
    end

    -- ───── Minimize / Maximize / Close ─────
    MinBtn.Activated:Connect(function()
        if Window.IsMaximized then
            Window.IsMaximized = false
            MainShadow.Size = Window.PreMaximizeSize
            MainShadow.Position = Window.PreMaximizePos
        end
        Window.IsMinimized = not Window.IsMinimized
        ResizeGrip.Visible = not Window.IsMinimized and not Window.IsMaximized
        if Window.IsMinimized then
            local cur = MainShadow.AbsoluteSize
            Window.PreMinimizeSize = UDim2.fromOffset(cur.X, cur.Y)
            Tween(BodyContainer, TI(0.25), { Size = UDim2.new(1, 0, 0, 0) })
            Tween(MainShadow, TI(0.25), { Size = UDim2.fromOffset(cur.X, 52 + ShadowPad * 2) })
        else
            Tween(MainShadow, TI(0.25), { Size = Window.PreMinimizeSize or Window.Size })
            Tween(BodyContainer, TI(0.25), { Size = UDim2.new(1, 0, 1, -52) })
        end
    end)

    MaxBtn.Activated:Connect(function()
        if Window.IsMinimized then
            Window.IsMinimized = false
            BodyContainer.Size = UDim2.new(1, 0, 1, -52)
            MainShadow.Size = Window.PreMinimizeSize or Window.Size
        end
        Window.IsMaximized = not Window.IsMaximized
        ResizeGrip.Visible = not Window.IsMinimized and not Window.IsMaximized
        if Window.IsMaximized then
            Window.PreMaximizeSize = MainShadow.Size
            Window.PreMaximizePos = MainShadow.Position
            local gs = ScreenGui.AbsoluteSize
            Tween(MainShadow, TI(0.3), {
                Size = UDim2.fromOffset(
                    math.max(gs.X - 40, Window.MinSize.X),
                    math.max(gs.Y - 60, Window.MinSize.Y)),
                Position = UDim2.new(0, gs.X / 2, 0, gs.Y / 2)
            })
        else
            local t = Tween(MainShadow, TI(0.3), { Size = Window.PreMaximizeSize, Position = Window.PreMaximizePos })
            if t then
                t.Completed:Connect(function() ClampToViewport() end)
            else
                ClampToViewport()
            end
        end
    end)

    CloseBtn.Activated:Connect(function()
        if config.CloseBehavior == "Destroy" then
            Window:Destroy()
        else
            SetWindowVisible(false)
        end
    end)

    -- ───── Keybind toggle (FIX: support string & EnumItem) ─────
    local function MatchesToggleKey(keyCode)
        if typeof(ToggleKey) == "EnumItem" then return keyCode == ToggleKey end
        return keyCode.Name == ToggleKey
    end

    Track(UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType == Enum.UserInputType.Keyboard and MatchesToggleKey(input.KeyCode) then
            SetWindowVisible(not MainShadow.Visible)
        end
    end))

    -- ───── Search filter (FIX: auto pindah tab) ─────
    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        if not Window.SearchEnabled then return end
        local query = string.lower(SearchInput.Text)
        local firstVisible = nil
        for _, tab in ipairs(Window.Tabs) do
            local match = (query == "") or (string.find(string.lower(tab.Name), query, 1, true) ~= nil)
            if tab.NavButton then tab.NavButton.Visible = match end
            if match and not firstVisible then firstVisible = tab end
        end
        if firstVisible and Window.ActiveTab and (not Window.ActiveTab.NavButton or not Window.ActiveTab.NavButton.Visible) then
            Window:SelectTab(firstVisible)
        end
    end)

    -- ───── Loading screen (FIX: TextButton biar input tidak tembus) ─────
    if config.Loading and config.Loading.Enabled then
        local lData = config.Loading
        local LoadFrame = Instance.new("TextButton")
        LoadFrame.Name = "LoadingScreen"
        LoadFrame.Size = UDim2.new(1, 0, 1, 0)
        LoadFrame.BackgroundColor3 = Akbar.Theme.Background
        LoadFrame.AutoButtonColor = false
        LoadFrame.Text = ""
        LoadFrame.ZIndex = 100
        LoadFrame.BorderSizePixel = 0
        LoadFrame.Parent = MainWindow
        Round(LoadFrame, 12)

        local LoadIcon = Instance.new("ImageLabel")
        LoadIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        LoadIcon.Position = UDim2.new(0.5, 0, 0.4, 0)
        LoadIcon.Size = UDim2.new(0, 54, 0, 54)
        LoadIcon.BackgroundTransparency = 1
        LoadIcon.Image = GetIcon(WindowIcon)
        Themed(LoadIcon, "ImageColor3", "Accent")
        LoadIcon.Parent = LoadFrame

        local LoadTitle = Instance.new("TextLabel")
        LoadTitle.AnchorPoint = Vector2.new(0.5, 0)
        LoadTitle.Position = UDim2.new(0.5, 0, 0.4, 36)
        LoadTitle.Size = UDim2.new(1, 0, 0, 24)
        LoadTitle.BackgroundTransparency = 1
        LoadTitle.Font = Enum.Font.GothamBold
        Themed(LoadTitle, "TextColor3", "Text")
        LoadTitle.TextSize = 20
        LoadTitle.Text = lData.Title or "AKBAR UI"
        LoadTitle.Parent = LoadFrame

        local LoadStatus = Instance.new("TextLabel")
        LoadStatus.AnchorPoint = Vector2.new(0.5, 0)
        LoadStatus.Position = UDim2.new(0.5, 0, 0.4, 64)
        LoadStatus.Size = UDim2.new(1, 0, 0, 18)
        LoadStatus.BackgroundTransparency = 1
        LoadStatus.Font = Enum.Font.Gotham
        Themed(LoadStatus, "TextColor3", "Muted")
        LoadStatus.TextSize = 13
        LoadStatus.Text = lData.Text or "Starting..."
        LoadStatus.Parent = LoadFrame

        task.spawn(function()
            local steps = lData.Steps or { "Preparing interface", "Loading components", "Almost ready" }
            local duration = lData.Duration or 1.5
            local stepWait = duration / (#steps + 1)
            for _, step in ipairs(steps) do
                LoadStatus.Text = step
                task.wait(stepWait)
            end
            LoadStatus.Text = "Ready!"
            task.wait(0.2)
            Tween(LoadFrame, TI(0.4), { BackgroundTransparency = 1 })
            Tween(LoadIcon, TI(0.3), { ImageTransparency = 1 })
            Tween(LoadTitle, TI(0.3), { TextTransparency = 1 })
            local fadeOut = Tween(LoadStatus, TI(0.3), { TextTransparency = 1 })
            if fadeOut then
                fadeOut.Completed:Wait()
            else
                task.wait(0.3)
            end
            LoadFrame:Destroy()
        end)
    end

    -- ════════════════ WINDOW METHODS ════════════════
    function Window:Toggle() SetWindowVisible(not MainShadow.Visible) end
    function Window:Center()
        MainShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
        ClampToViewport()
    end
    function Window:SetSize(size)
        MainShadow.Size = size
        Window.Size = size
        ClampToViewport()
    end
    function Window:GetSize() return MainShadow.Size end
    function Window:SetMinSize(min) Window.MinSize = min end
    function Window:SetMaxSize(max) Window.MaxSize = max end
    function Window:SetTitle(text) TitleLabel.Text = text or WindowName end
    function Window:SetSubtitle(text) SubtitleLabel.Text = text or WindowSubtitle end
    function Window:SetIcon(iconAsset) BrandIcon.Image = GetIcon(iconAsset) end
    function Window:SetToggleKey(key) ToggleKey = key end
    function Window:SetAccordion(state) Window.Accordion = state and true or false end

    function Window:SetSearchEnabled(enabled)
        Window.SearchEnabled = enabled and true or false
        SearchContainer.Visible = Window.SearchEnabled
        if Window.SearchEnabled then
            TabScroll.Position = UDim2.new(0, 8, 0, 58)
            TabScroll.Size = UDim2.new(1, -16, 1, -68)
        else
            TabScroll.Position = UDim2.new(0, 8, 0, 12)
            TabScroll.Size = UDim2.new(1, -16, 1, -24)
        end
    end

    function Window:SaveConfig(name) return Window.Config:Save(name) end
    function Window:LoadConfig(name) return Window.Config:Load(name) end
    function Window:DeleteConfig(name) Window.Config:Delete(name) end
    function Window:ListConfigs() return Window.Config:List() end

    -- ───── Notifications (FIX: animasi tidak bentrok dgn UIListLayout) ─────
    function Window:Notify(notifData)
        notifData = notifData or {}
        local title = notifData.Title or "Akbar UI"
        local content = notifData.Content or ""
        local duration = notifData.Duration or 3.5
        local icon = notifData.Icon or "info"
        local iconColor = Akbar.Theme.Accent
        local t = string.lower(tostring(notifData.Type or ""))
        if t == "success" then
            icon = notifData.Icon or "check"
            iconColor = Akbar.Theme.Success
        elseif t == "warning" then
            iconColor = Akbar.Theme.Warning
        elseif t == "error" then
            iconColor = Akbar.Theme.Error
        end

        local Card = Instance.new("Frame")
        Card.Name = "NotifCard"
        Card.Size = UDim2.new(1, 0, 0, 68)
        Card.BackgroundTransparency = 1
        Card.ClipsDescendants = true
        Card.Parent = NotificationHolder

        local Inner = Instance.new("TextButton")
        Inner.Size = UDim2.new(1, 0, 1, 0)
        Inner.Position = UDim2.new(1, 0, 0, 0)
        Themed(Inner, "BackgroundColor3", "Surface")
        Inner.BackgroundTransparency = 0.1
        Inner.AutoButtonColor = false
        Inner.Text = ""
        Inner.BorderSizePixel = 0
        Inner.Parent = Card
        Round(Inner, 10)
        Stroke(Inner, "Border", 0.4, 1)

        local IconImg = Instance.new("ImageLabel")
        IconImg.Position = UDim2.new(0, 14, 0, 14)
        IconImg.Size = UDim2.new(0, 20, 0, 20)
        IconImg.BackgroundTransparency = 1
        IconImg.Image = GetIcon(icon)
        IconImg.ImageColor3 = iconColor
        IconImg.Parent = Inner

        local TitleText = Instance.new("TextLabel")
        TitleText.Position = UDim2.new(0, 44, 0, 12)
        TitleText.Size = UDim2.new(1, -54, 0, 18)
        TitleText.BackgroundTransparency = 1
        TitleText.Font = Enum.Font.GothamBold
        Themed(TitleText, "TextColor3", "Text")
        TitleText.TextSize = 14
        TitleText.TextXAlignment = Enum.TextXAlignment.Left
        TitleText.TextTruncate = Enum.TextTruncate.AtEnd
        TitleText.Text = title
        TitleText.Parent = Inner

        local DescText = Instance.new("TextLabel")
        DescText.Position = UDim2.new(0, 44, 0, 32)
        DescText.Size = UDim2.new(1, -54, 0, 22)
        DescText.BackgroundTransparency = 1
        DescText.Font = Enum.Font.Gotham
        Themed(DescText, "TextColor3", "Muted")
        DescText.TextSize = 12
        DescText.TextXAlignment = Enum.TextXAlignment.Left
        DescText.TextTruncate = Enum.TextTruncate.AtEnd
        DescText.Text = content
        DescText.Parent = Inner

        local ProgressBar = Instance.new("Frame")
        ProgressBar.AnchorPoint = Vector2.new(0, 1)
        ProgressBar.Position = UDim2.new(0, 0, 1, 0)
        ProgressBar.Size = UDim2.new(1, 0, 0, 2)
        ProgressBar.BackgroundColor3 = iconColor
        ProgressBar.BorderSizePixel = 0
        ProgressBar.Parent = Inner

        local closed = false
        local notifRef = { Frame = Card }
        local function Close(fast)
            if closed then return end
            closed = true
            local dur = fast and 0.12 or 0.3
            Tween(Inner, TI(dur), { Position = UDim2.new(1, 0, 0, 0) })
            task.delay(dur + 0.05, function()
                for i, n in ipairs(Window.Notifications) do
                    if n == notifRef then table.remove(Window.Notifications, i) break end
                end
                Card:Destroy()
            end)
        end
        notifRef.Close = Close
        table.insert(Window.Notifications, notifRef)

        while #Window.Notifications > MaxNotifs do
            local old = table.remove(Window.Notifications, 1)
            if old and old.Close then old.Close(true) end
        end

        Tween(Inner, TI(0.3), { Position = UDim2.new(0, 0, 0, 0) })
        Tween(ProgressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) })

        Inner.Activated:Connect(function() Close(false) end) -- klik untuk dismiss
        task.delay(duration, function() Close(false) end)
        return notifRef
    end

    -- ───── Confirm dialog (FIX: backdrop cancel, anti double-callback) ─────
    function Window:Confirm(confirmData)
        confirmData = confirmData or {}
        local title = confirmData.Title or "Confirmation"
        local content = confirmData.Content or "Are you sure?"
        local cText = confirmData.ConfirmText or "Confirm"
        local canText = confirmData.CancelText or "Cancel"
        local cb = confirmData.Callback or function() end

        local ModalBackdrop = Instance.new("TextButton")
        ModalBackdrop.Name = "ModalBackdrop"
        ModalBackdrop.Size = UDim2.new(1, 0, 1, 0)
        ModalBackdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        ModalBackdrop.BackgroundTransparency = 1
        ModalBackdrop.AutoButtonColor = false
        ModalBackdrop.Text = ""
        ModalBackdrop.ZIndex = 80
        ModalBackdrop.BorderSizePixel = 0
        ModalBackdrop.Parent = MainWindow
        Round(ModalBackdrop, 12)

        local DialogBox = Instance.new("Frame")
        DialogBox.AnchorPoint = Vector2.new(0.5, 0.5)
        DialogBox.Position = UDim2.new(0.5, 0, 0.5, 12)
        DialogBox.Size = UDim2.new(0, 340, 0, 170)
        Themed(DialogBox, "BackgroundColor3", "Surface")
        DialogBox.BorderSizePixel = 0
        DialogBox.Parent = ModalBackdrop
        Round(DialogBox, 10)
        Stroke(DialogBox, "Border", 0.2, 1)

        -- FIX: cegah klik di dalam dialog "tembus" ke backdrop
        local Blocker = Instance.new("TextButton")
        Blocker.Size = UDim2.new(1, 0, 1, 0)
        Blocker.BackgroundTransparency = 1
        Blocker.AutoButtonColor = false
        Blocker.Text = ""
        Blocker.ZIndex = 1
        Blocker.Parent = DialogBox

        local DTitle = Instance.new("TextLabel")
        DTitle.Position = UDim2.new(0, 20, 0, 18)
        DTitle.Size = UDim2.new(1, -40, 0, 22)
        DTitle.BackgroundTransparency = 1
        DTitle.Font = Enum.Font.GothamBold
        Themed(DTitle, "TextColor3", "Text")
        DTitle.TextSize = 16
        DTitle.TextXAlignment = Enum.TextXAlignment.Left
        DTitle.Text = title
        DTitle.Parent = DialogBox

        local DContent = Instance.new("TextLabel")
        DContent.Position = UDim2.new(0, 20, 0, 46)
        DContent.Size = UDim2.new(1, -40, 0, 48)
        DContent.BackgroundTransparency = 1
        DContent.Font = Enum.Font.Gotham
        Themed(DContent, "TextColor3", "Muted")
        DContent.TextSize = 13
        DContent.TextWrapped = true
        DContent.TextXAlignment = Enum.TextXAlignment.Left
        DContent.Text = content
        DContent.Parent = DialogBox

        local BtnRow = Instance.new("Frame")
        BtnRow.AnchorPoint = Vector2.new(0, 1)
        BtnRow.Position = UDim2.new(0, 20, 1, -16)
        BtnRow.Size = UDim2.new(1, -40, 0, 36)
        BtnRow.BackgroundTransparency = 1
        BtnRow.Parent = DialogBox

        local answered = false
        local function Answer(result)
            if answered then return end
            answered = true
            ModalBackdrop:Destroy()
            task.spawn(cb, result)
        end

        local function CreateDButton(text, isPrimary, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(0.5, -6, 1, 0)
            b.BackgroundColor3 = isPrimary and Akbar.Theme.Accent or Akbar.Theme.Surface2
            b.Font = Enum.Font.GothamBold
            b.Text = text
            b.TextColor3 = isPrimary and Color3.fromRGB(255, 255, 255) or Akbar.Theme.Muted
            b.TextSize = 13
            b.AutoButtonColor = false
            b.BorderSizePixel = 0
            b.Parent = BtnRow
            Round(b, 6)
            b.Activated:Connect(callback)
            return b
        end

        local CancelB = CreateDButton(canText, false, function() Answer(false) end)
        CancelB.Position = UDim2.new(0, 0, 0, 0)
        local ConfirmB = CreateDButton(cText, true, function() Answer(true) end)
        ConfirmB.Position = UDim2.new(0.5, 6, 0, 0)

        ModalBackdrop.Activated:Connect(function() Answer(false) end) -- FIX: klik luar = cancel
        Tween(ModalBackdrop, TI(0.2), { BackgroundTransparency = 0.5 })
        Tween(DialogBox, TI(0.25), { Position = UDim2.new(0.5, 0, 0.5, 0) })
    end

    -- ───── Dialog (FIX: tombol proporsional) ─────
    function Window:Dialog(dialogData)
        dialogData = dialogData or {}
        local title = dialogData.Title or "Akbar"
        local content = dialogData.Content or ""
        local buttons = dialogData.Buttons or { { Name = "OK", Callback = function() end } }

        local ModalBackdrop = Instance.new("TextButton")
        ModalBackdrop.Size = UDim2.new(1, 0, 1, 0)
        ModalBackdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        ModalBackdrop.BackgroundTransparency = 0.5
        ModalBackdrop.AutoButtonColor = false
        ModalBackdrop.Text = ""
        ModalBackdrop.ZIndex = 80
        ModalBackdrop.BorderSizePixel = 0
        ModalBackdrop.Parent = MainWindow
        Round(ModalBackdrop, 12)

        local DialogBox = Instance.new("Frame")
        DialogBox.AnchorPoint = Vector2.new(0.5, 0.5)
        DialogBox.Position = UDim2.new(0.5, 0, 0.5, 12)
        DialogBox.Size = UDim2.new(0, 360, 0, 170)
        Themed(DialogBox, "BackgroundColor3", "Surface")
        DialogBox.BorderSizePixel = 0
        DialogBox.Parent = ModalBackdrop
        Round(DialogBox, 10)
        Stroke(DialogBox, "Border", 0.2, 1)

        local Blocker = Instance.new("TextButton")
        Blocker.Size = UDim2.new(1, 0, 1, 0)
        Blocker.BackgroundTransparency = 1
        Blocker.AutoButtonColor = false
        Blocker.Text = ""
        Blocker.ZIndex = 1
        Blocker.Parent = DialogBox

        local DTitle = Instance.new("TextLabel")
        DTitle.Position = UDim2.new(0, 20, 0, 18)
        DTitle.Size = UDim2.new(1, -40, 0, 22)
        DTitle.BackgroundTransparency = 1
        DTitle.Font = Enum.Font.GothamBold
        Themed(DTitle, "TextColor3", "Text")
        DTitle.TextSize = 16
        DTitle.TextXAlignment = Enum.TextXAlignment.Left
        DTitle.Text = title
        DTitle.Parent = DialogBox

        local DContent = Instance.new("TextLabel")
        DContent.Position = UDim2.new(0, 20, 0, 46)
        DContent.Size = UDim2.new(1, -40, 0, 48)
        DContent.BackgroundTransparency = 1
        DContent.Font = Enum.Font.Gotham
        Themed(DContent, "TextColor3", "Muted")
        DContent.TextSize = 13
        DContent.TextWrapped = true
        DContent.TextXAlignment = Enum.TextXAlignment.Left
        DContent.Text = content
        DContent.Parent = DialogBox

        local BtnRow = Instance.new("Frame")
        BtnRow.AnchorPoint = Vector2.new(0, 1)
        BtnRow.Position = UDim2.new(0, 20, 1, -16)
        BtnRow.Size = UDim2.new(1, -40, 0, 36)
        BtnRow.BackgroundTransparency = 1
        BtnRow.Parent = DialogBox

        local rowLayout = Instance.new("UIListLayout")
        rowLayout.FillDirection = Enum.FillDirection.Horizontal
        rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        rowLayout.Padding = UDim.new(0, 8)
        rowLayout.Parent = BtnRow

        local count = math.max(#buttons, 1)
        for _, btnInfo in ipairs(buttons) do
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1 / count, -8, 1, 0)
            Themed(b, "BackgroundColor3", btnInfo.Primary and "Accent" or "Surface2")
            b.Font = Enum.Font.GothamBold
            Themed(b, "TextColor3", "Text")
            b.TextSize = 12
            b.AutoButtonColor = false
            b.BorderSizePixel = 0
            b.Text = btnInfo.Name or "Button"
            b.Parent = BtnRow
            Round(b, 6)
            b.Activated:Connect(function()
                ModalBackdrop:Destroy()
                if btnInfo.Callback then btnInfo.Callback() end
            end)
        end

        Tween(DialogBox, TI(0.25), { Position = UDim2.new(0.5, 0, 0.5, 0) })
    end

    -- ───── Tab system ─────
    function Window:SelectTab(tab)
        if type(tab) == "string" then
            local name = tab
            tab = nil
            for _, t in ipairs(Window.Tabs) do
                if t.Name == name then tab = t break end
            end
        elseif type(tab) == "number" then
            tab = Window.Tabs[tab]
        end
        if type(tab) ~= "table" or not tab.Page then return end
        if Window.ActiveTab == tab then return end

        if Window.ActiveTab then
            local old = Window.ActiveTab
            old.Page.Visible = false
            old.NavButton.BackgroundTransparency = 1
            old.IconImage.ImageColor3 = Akbar.Theme.Muted
            old.TextLabel.TextColor3 = Akbar.Theme.Muted
        end

        Window.ActiveTab = tab
        tab.Page.Visible = true
        tab.Page.CanvasPosition = Vector2.new(0, 0)
        tab.NavButton.BackgroundTransparency = 0.25
        tab.IconImage.ImageColor3 = Akbar.Theme.Accent
        tab.TextLabel.TextColor3 = Akbar.Theme.Text

        TabHeading.Text = tab.Name
        TabDesc.Text = tab.Desc or ""
    end

    function Window:CreateTab(tabConfig, optionalIcon)
        if type(tabConfig) == "string" then
            tabConfig = { Name = tabConfig, Icon = optionalIcon }
        end
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Name or "Tab"
        local tabDesc = tabConfig.Desc or tabConfig.Description or ""
        local tabIcon = tabConfig.Icon or optionalIcon or "anchor"

        local Tab = { Name = tabName, Desc = tabDesc, Icon = tabIcon, Window = Window }

        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = "Tab_" .. tabName
        TabBtn.Size = UDim2.new(1, 0, 0, 38)
        Themed(TabBtn, "BackgroundColor3", "Surface2")
        TabBtn.BackgroundTransparency = 1
        TabBtn.AutoButtonColor = false
        TabBtn.Text = ""
        TabBtn.BorderSizePixel = 0
        TabBtn.LayoutOrder = #Window.Tabs + 1
        TabBtn.Parent = TabScroll
        Round(TabBtn, 8)
        Tab.NavButton = TabBtn -- FIX: dipisah dari nama "Button" biar tidak tabrakan dengan method :Button() (pembuat komponen tombol)

        local TabIconImg = Instance.new("ImageLabel")
        TabIconImg.Position = UDim2.new(0, 10, 0.5, -9)
        TabIconImg.Size = UDim2.new(0, 18, 0, 18)
        TabIconImg.BackgroundTransparency = 1
        TabIconImg.Image = GetIcon(tabIcon)
        Themed(TabIconImg, "ImageColor3", "Muted")
        TabIconImg.Parent = TabBtn
        Tab.IconImage = TabIconImg

        local TabText = Instance.new("TextLabel")
        TabText.Position = UDim2.new(0, 36, 0, 0)
        TabText.Size = UDim2.new(1, -44, 1, 0)
        TabText.BackgroundTransparency = 1
        TabText.Font = Enum.Font.GothamMedium
        Themed(TabText, "TextColor3", "Muted")
        TabText.TextSize = 13
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.Text = tabName
        TabText.Parent = TabBtn
        Tab.TextLabel = TabText

        TabBtn.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabBtn, TI(0.15), { BackgroundTransparency = 0.45 })
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabBtn, TI(0.15), { BackgroundTransparency = 1 })
            end
        end)
        TabBtn.Activated:Connect(function()
            Window:SelectTab(Tab)
        end)

        local PageScroll = Instance.new("ScrollingFrame")
        PageScroll.Name = "Page_" .. tabName
        PageScroll.Size = UDim2.new(1, 0, 1, 0)
        PageScroll.BackgroundTransparency = 1
        PageScroll.BorderSizePixel = 0
        PageScroll.ScrollBarThickness = 3
        Themed(PageScroll, "ScrollBarImageColor3", "Border")
        PageScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        PageScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        PageScroll.Visible = false
        PageScroll.Parent = PagesContainer
        Tab.Page = PageScroll

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.Parent = PageScroll

        Tab.API = BuildAPI(PageScroll, Tab)
        for k, v in pairs(Tab.API) do
            if type(v) == "function" then Tab[k] = v end
        end

        function Tab:Select() Window:SelectTab(Tab) end

        table.insert(Window.Tabs, Tab)
        if not Window.ActiveTab then
            Window:SelectTab(Tab)
        end
        return Tab
    end

    -- Hook tema: warna tab aktif ikut berubah saat ganti accent
    AddHook(function()
        for _, t in ipairs(Window.Tabs) do
            if Window.ActiveTab == t then
                t.NavButton.BackgroundTransparency = 0.25
                t.IconImage.ImageColor3 = Akbar.Theme.Accent
                t.TextLabel.TextColor3 = Akbar.Theme.Text
            else
                t.NavButton.BackgroundTransparency = 1
                t.IconImage.ImageColor3 = Akbar.Theme.Muted
                t.TextLabel.TextColor3 = Akbar.Theme.Muted
            end
        end
    end)

    function Window:Destroy()
        for _, conn in ipairs(Window.Connections) do
            pcall(function() conn:Disconnect() end)
        end
        Window.Connections = {}
        for i = #ThemeHooks, 1, -1 do
            if ThemeHooks[i][1] == Window then table.remove(ThemeHooks, i) end
        end
        if Window.ScreenGui then Window.ScreenGui:Destroy() end
    end

    -- Inisialisasi: normalisasi ukuran (FIX: support Size dgn Scale) + clamp
    if not Window.SearchEnabled then
        Window:SetSearchEnabled(false)
    end
    task.defer(function()
        RunService.RenderStepped:Wait()
        local abs = MainShadow.AbsoluteSize
        if abs.X > 0 and abs.Y > 0 then
            Window.Size = UDim2.fromOffset(abs.X, abs.Y)
        end
        ClampToViewport()
    end)

    return Window
end

return Akbar

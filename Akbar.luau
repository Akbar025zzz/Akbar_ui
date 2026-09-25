--[[ Akbar UI v1.1 | API-compatible with Airflow + Collapsible ]]

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")
local Players          = game:GetService("Players")
local LocalPlayer      = Players.LocalPlayer

local Akbar = {}
Akbar.Flags   = {}
Akbar.Version = "1.1.0"

Akbar.Theme = {
    Background  = Color3.fromRGB(20, 16, 20),
    Surface     = Color3.fromRGB(24, 19, 24),
    Surface2    = Color3.fromRGB(28, 22, 28),
    Surface3    = Color3.fromRGB(42, 36, 43),
    Stroke      = Color3.fromRGB(40, 32, 41),
    StrokeHover = Color3.fromRGB(88, 70, 90),
    Accent      = Color3.fromRGB(235, 199, 246),
    AccentDark  = Color3.fromRGB(24, 18, 26),
    Text        = Color3.fromRGB(233, 229, 234),
    Muted       = Color3.fromRGB(125, 115, 126),
    Warning     = Color3.fromRGB(240, 176, 108),
    Success     = Color3.fromRGB(150, 220, 170),
    Error       = Color3.fromRGB(240, 120, 120),
}

local function normalize(source, map)
    local opts = {}
    if type(source) == "string" then opts.Name = source
    elseif type(source) == "table" then
        for k, v in pairs(source) do opts[k] = v end
    end
    for from, to in pairs(map or {}) do
        if opts[to] == nil and opts[from] ~= nil then opts[to] = opts[from] end
    end
    if opts.Range then
        opts.Min = opts.Min or opts.Range[1]
        opts.Max = opts.Max or opts.Range[2]
    end
    return opts
end

local function create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then obj[k] = v end
    end
    if props.Parent then obj.Parent = props.Parent end
    return obj
end

local function corner(parent, radius)
    return create("UICorner", { CornerRadius = radius or UDim.new(0, 8), Parent = parent })
end

local function stroke(parent, color, transparency, thickness)
    return create("UIStroke", {
        Color = color or Akbar.Theme.Stroke,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function tween(obj, props, duration, style, direction)
    duration = duration or 0.2
    if duration <= 0 then
        for k, v in pairs(props) do obj[k] = v end
        return
    end
    local tw = TweenService:Create(obj,
        TweenInfo.new(duration, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out),
        props)
    tw:Play()
    return tw
end

local function safeCall(fn, ...)
    if type(fn) ~= "function" then return end
    local ok, err = pcall(fn, ...)
    if not ok then warn("[Akbar] callback error: " .. tostring(err)) end
end

local function finishElement(tab, opts, element, frame, kind)
    element._type = kind
    element._frame = frame
    local window = tab and tab.Window
    if opts.Flag then
        Akbar.Flags[opts.Flag] = element
        if window then
            local oc = opts.Callback
            opts.Callback = function(...)
                if type(oc) == "function" then oc(...) end
                window:_autoSave()
            end
        end
    end
    function element:Destroy()
        if element._destroyed then return end
        element._destroyed = true
        if opts.Flag and Akbar.Flags[opts.Flag] == element then
            Akbar.Flags[opts.Flag] = nil
        end
        if frame then frame:Destroy() end
    end
    return element
end

Akbar.Fonts = {
    Regular = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Regular),
    Medium  = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Medium),
    Bold    = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold),
}

local Window = {}
Window.__index = Window

function Akbar:CreateWindow(cfg)
    cfg = cfg or {}
    local self_ = setmetatable({}, Window)
    self_.Config = cfg
    self_.Tabs = {}
    self_._listeners = {}
    local theme = Akbar.Theme

    local parent = cfg.Parent
    if not parent then
        local ok, core = pcall(function() return game:GetService("CoreGui") end)
        parent = ok and core or LocalPlayer:WaitForChild("PlayerGui")
    end

    local gui = create("ScreenGui", {
        Name = "AkbarUI", ResetOnSpawn = false, IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 9999, Parent = parent,
    })

    local size = cfg.Size or UDim2.fromOffset(640, 480)
    local main = create("Frame", {
        Name = "Main", Size = size,
        Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = theme.Background, BorderSizePixel = 0,
        ClipsDescendants = true, Parent = gui,
    })
    corner(main, 14); stroke(main, theme.Stroke, 1)
    self_.Gui = gui; self_.Main = main

    local topbar = create("Frame", {
        Name = "Topbar", Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = theme.Surface, BorderSizePixel = 0, Parent = main,
    })
    create("Frame", {
        Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = theme.Stroke, BorderSizePixel = 0, Parent = topbar,
    })
    create("TextLabel", {
        Text = cfg.Name or "Akbar", FontFace = Akbar.Fonts.Medium,
        TextSize = 14, TextColor3 = theme.Text, BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(0.5, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = topbar,
    })
    local closeBtn = create("TextButton", {
        Text = "X", FontFace = Akbar.Fonts.Bold, TextSize = 14,
        TextColor3 = theme.Muted, BackgroundTransparency = 1, AutoButtonColor = false,
        Size = UDim2.new(0, 42, 1, 0), Position = UDim2.new(1, -42, 0, 0), Parent = topbar,
    })
    closeBtn.MouseEnter:Connect(function() tween(closeBtn, {TextColor3 = theme.Error}, 0.1) end)
    closeBtn.MouseLeave:Connect(function() tween(closeBtn, {TextColor3 = theme.Muted}, 0.1) end)
    closeBtn.MouseButton1Click:Connect(function() self_:Toggle(false) end)

    local sidebar = create("Frame", {
        Name = "Sidebar", Size = UDim2.new(0, 170, 1, -42),
        Position = UDim2.new(0, 0, 0, 42), BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0, Parent = main,
    })
    create("Frame", {
        Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = theme.Stroke, BorderSizePixel = 0, Parent = sidebar,
    })
    local tabScroll = create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 0, CanvasSize = UDim2.new(), Parent = sidebar,
    })
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = tabScroll,
    })

    local content = create("Frame", {
        Name = "Content", Size = UDim2.new(1, -171, 1, -42),
        Position = UDim2.new(0, 171, 0, 42), BackgroundColor3 = theme.Background,
        BorderSizePixel = 0, Parent = main,
    })
    self_.Content = content

    do
        local dragging, dragStart, startPos = false, nil, nil
        topbar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = input.Position; startPos = main.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                local d = input.Position - dragStart
                main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                          startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
    end

    local kb = cfg.ToggleUIKeybind or "RightControl"
    local kc = typeof(kb) == "EnumItem" and kb or Enum.KeyCode[kb]
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == kc then self_:Toggle() end
    end)

    local openBtn = create("TextButton", {
        Name = "OpenButton", Size = UDim2.new(0, 130, 0, 38),
        Position = UDim2.new(0, 20, 0, 60), BackgroundColor3 = theme.Surface,
        Text = "", AutoButtonColor = false, BorderSizePixel = 0, Visible = false, Parent = gui,
    })
    corner(openBtn, 10); stroke(openBtn, theme.Stroke, 1)
    create("TextLabel", {
        Text = (cfg.OpenButton and cfg.OpenButton.Title) or "Open Akbar",
        FontFace = Akbar.Fonts.Medium, TextSize = 13, TextColor3 = theme.Text,
        BackgroundTransparency = 1, Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 12, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = openBtn,
    })
    openBtn.MouseButton1Click:Connect(function() self_:Toggle(true) end)

    local notifHolder = create("Frame", {
        Name = "Notifs", Size = UDim2.new(0, 300, 1, 0),
        Position = UDim2.new(1, -310, 0, 0), BackgroundTransparency = 1, Parent = gui,
    })
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 8), Parent = notifHolder,
    })

    self_.Visible = true
    function self_:Toggle(state)
        if state == nil then state = not self_.Visible end
        self_.Visible = state
        if state then
            main.Visible = true; openBtn.Visible = false
            tween(main, {Size = size}, 0.18)
        else
            main.Visible = false; openBtn.Visible = true
        end
    end

    function self_:_listen(event, cb)
        local conn = UserInputService[event]:Connect(cb)
        table.insert(self_._listeners, function() conn:Disconnect() end)
        return conn
    end

    function self_:_autoSave()
        if not (cfg.ConfigurationSaving and cfg.ConfigurationSaving.Enabled) then return end
        if self_._autoSaveTimer then task.cancel(self_._autoSaveTimer) end
        self_._autoSaveTimer = task.delay(0.4, function() self_:SaveConfig() end)
    end

    function self_:SaveConfig()
        if not (cfg.ConfigurationSaving and cfg.ConfigurationSaving.Enabled) then return end
        local data = {}
        for flag, element in pairs(Akbar.Flags) do
            if element.Get then
                local ok, v = pcall(function() return element:Get() end)
                if ok then data[flag] = v end
            end
        end
        pcall(function()
            if not isfolder("AkbarUI") then makefolder("AkbarUI") end
            local fn = cfg.ConfigurationSaving.FolderName or "Configs"
            if not isfolder("AkbarUI/"..fn) then makefolder("AkbarUI/"..fn) end
            local file = (cfg.ConfigurationSaving.FileName or "default")..".json"
            writefile("AkbarUI/"..fn.."/"..file, HttpService:JSONEncode(data))
        end)
    end

    function self_:Destroy()
        for _, d in ipairs(self_._listeners) do d() end
        gui:Destroy()
    end

    function self_:Notify(cfg2)
        cfg2 = cfg2 or {}
        local ntype = cfg2.Type or "Info"
        local color = theme.Accent
        if ntype == "Success" then color = theme.Success
        elseif ntype == "Warning" then color = theme.Warning
        elseif ntype == "Error" then color = theme.Error end

        local toast = create("Frame", {
            Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = theme.Surface,
            BorderSizePixel = 0, Parent = notifHolder,
        })
        corner(toast, 10); stroke(toast, theme.Stroke, 1)
        create("Frame", {
            Size = UDim2.new(0, 3, 1, -16), Position = UDim2.new(0, 8, 0, 8),
            BackgroundColor3 = color, BorderSizePixel = 0, Parent = toast,
        })
        create("TextLabel", {
            Text = cfg2.Title or "Akbar", FontFace = Akbar.Fonts.Bold, TextSize = 13,
            TextColor3 = theme.Text, BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 0, 8), Size = UDim2.new(1, -28, 0, 16),
            TextXAlignment = Enum.TextXAlignment.Left, Parent = toast,
        })
        create("TextLabel", {
            Text = cfg2.Content or "", FontFace = Akbar.Fonts.Regular, TextSize = 11.5,
            TextColor3 = theme.Muted, BackgroundTransparency = 1, TextWrapped = true,
            Position = UDim2.new(0, 20, 0, 26), Size = UDim2.new(1, -28, 0, 24),
            TextXAlignment = Enum.TextXAlignment.Left, Parent = toast,
        })
        local notif = { Frame = toast }
        function notif:Dismiss()
            tween(toast, {BackgroundTransparency = 1}, 0.15)
            for _, c in ipairs(toast:GetDescendants()) do
                if c:IsA("TextLabel") then tween(c, {TextTransparency = 1}, 0.15)
                elseif c:IsA("Frame") then tween(c, {BackgroundTransparency = 1}, 0.15)
                elseif c:IsA("UIStroke") then tween(c, {Transparency = 1}, 0.15) end
            end
            task.wait(0.18); toast:Destroy()
        end
        toast.Position = UDim2.new(1, 40, 0, 0)
        tween(toast, {Position = UDim2.new(0, 0, 0, 0)}, 0.2)
        task.delay(cfg2.Duration or 4, function() pcall(function() notif:Dismiss() end) end)
        return notif
    end

    function self_:CreateTab(cfg2)
        cfg2 = cfg2 or {}
        local tabName = cfg2.Name or "Tab"

        local btn = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = theme.Surface2,
            BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Parent = tabScroll,
        })
        corner(btn, 8)
        local iconLabel = create("TextLabel", {
            Text = cfg2.Icon or "*", FontFace = Akbar.Fonts.Medium, TextSize = 14,
            TextColor3 = theme.Muted, BackgroundTransparency = 1,
            Size = UDim2.new(0, 24, 1, 0), Position = UDim2.new(0, 6, 0, 0), Parent = btn,
        })
        local nameLabel = create("TextLabel", {
            Text = tabName, FontFace = Akbar.Fonts.Medium, TextSize = 12.5,
            TextColor3 = theme.Muted, BackgroundTransparency = 1,
            Size = UDim2.new(1, -34, 1, 0), Position = UDim2.new(0, 32, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left, Parent = btn,
        })

        local page = create("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
            BorderSizePixel = 0, ScrollBarThickness = 3,
            ScrollBarImageColor3 = theme.Surface3, CanvasSize = UDim2.new(),
            Visible = false, Parent = content,
        })
        create("UIPadding", {
            PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = page,
        })
        local listLayout = create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = page,
        })
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 24)
        end)

        local tab = {
            Name = tabName, Button = btn, Page = page, List = page,
            Layout = listLayout, Window = self_, _order = 0, _selected = false,
        }
        setmetatable(tab, { __index = TabMethods })

        local function select()
            for _, other in ipairs(self_.Tabs) do
                other._selected = false
                tween(other.Button, {BackgroundTransparency = 1}, 0.1)
                for _, lbl in ipairs(other.Button:GetChildren()) do
                    if lbl:IsA("TextLabel") then lbl.TextColor3 = theme.Muted end
                end
            end
            tab._selected = true
            tween(btn, {BackgroundTransparency = 0, BackgroundColor3 = theme.Surface3}, 0.15)
            iconLabel.TextColor3 = theme.Accent
            nameLabel.TextColor3 = theme.Text
            for _, other in ipairs(self_.Tabs) do
                other.Page.Visible = (other == tab)
            end
        end
        btn.MouseButton1Click:Connect(select)
        btn.MouseEnter:Connect(function()
            if not tab._selected then
                tween(btn, {BackgroundTransparency = 0.7, BackgroundColor3 = theme.Surface2}, 0.1)
            end
        end)
        btn.MouseLeave:Connect(function()
            if not tab._selected then tween(btn, {BackgroundTransparency = 1}, 0.1) end
        end)

        table.insert(self_.Tabs, tab)
        if #self_.Tabs == 1 then select() end
        return tab
    end

    return self_
end

TabMethods = {}
local TM = TabMethods

function TM:_nextOrder()
    self._order = self._order + 1
    return self._order
end

local function makeCard(tab, height)
    local card = create("Frame", {
        Size = UDim2.new(1, 0, 0, height or 56),
        BackgroundColor3 = Akbar.Theme.Surface2, BorderSizePixel = 0,
        LayoutOrder = tab:_nextOrder(), Parent = tab.List,
    })
    corner(card, 8)
    stroke(card, Akbar.Theme.Stroke, 1)
    return card
end

function TM:Section(text)
    if type(text) == "table" then text = text.Name or text.Title or "" end
    local holder = create("Frame", {
        Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1,
        LayoutOrder = self:_nextOrder(), Parent = self.List,
    })
    create("TextLabel", {
        Position = UDim2.fromOffset(2, 8), Size = UDim2.new(1, 0, 0, 16),
        Text = string.upper(tostring(text)), TextSize = 12,
        TextColor3 = Akbar.Theme.Muted, BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = holder,
    })
    return holder
end

function TM:Divider()
    return create("Frame", {
        Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Akbar.Theme.Stroke,
        BorderSizePixel = 0, LayoutOrder = self:_nextOrder(), Parent = self.List,
    })
end

function TM:Label(cfg)
    cfg = normalize(cfg, { Name = "Text", Title = "Text" })
    local lbl = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18), Text = cfg.Text or "",
        TextSize = 13, FontFace = Akbar.Fonts.Regular,
        TextColor3 = cfg.Color or Akbar.Theme.Muted,
        BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = self:_nextOrder(), Parent = self.List,
    })
    return finishElement(self, cfg, {
        Set = function(_, v) lbl.Text = tostring(v) end,
        Get = function() return lbl.Text end,
    }, lbl, "Label")
end

function TM:Paragraph(cfg)
    cfg = normalize(cfg, { Title = "Name" })
    local card = makeCard(self, 70)
    create("TextLabel", {
        Position = UDim2.fromOffset(14, 12), Size = UDim2.new(1, -28, 0, 16),
        Text = cfg.Name or "", TextSize = 13, FontFace = Akbar.Fonts.Medium,
        TextColor3 = Akbar.Theme.Text, BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = card,
    })
    local body = create("TextLabel", {
        Position = UDim2.fromOffset(14, 30), Size = UDim2.new(1, -28, 0, 32),
        Text = cfg.Content or "", TextSize = 12, FontFace = Akbar.Fonts.Regular,
        TextColor3 = Akbar.Theme.Muted, BackgroundTransparency = 1,
        TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top, Parent = card,
    })
    return finishElement(self, cfg, {
        Set = function(_, v) body.Text = v end,
    }, card, "Paragraph")
end

function TM:Button(cfg)
    cfg = normalize(cfg, { Title = "Name", Description = "Desc" })
    local isPrimary = cfg.Style == "Primary"
    local card = create("TextButton", {
        Size = UDim2.new(1, 0, 0, cfg.Desc and 64 or 48),
        BackgroundColor3 = isPrimary and Akbar.Theme.Accent or Akbar.Theme.Surface2,
        BackgroundTransparency = isPrimary and 0.12 or 0,
        BorderSizePixel = 0, Text = "", AutoButtonColor = false,
        LayoutOrder = self:_nextOrder(), Parent = self.List,
    })
    corner(card, 8)
    stroke(card, isPrimary and Akbar.Theme.Accent or Akbar.Theme.Stroke, isPrimary and 0.4 or 1)
    local title = create("TextLabel", {
        Position = UDim2.fromOffset(14, cfg.Desc and 12 or 0),
        Size = UDim2.new(1, -28, cfg.Desc and 0 or 1, cfg.Desc and 18 or 0),
        Text = cfg.Name or "Button", TextSize = 13, FontFace = Akbar.Fonts.Medium,
        TextColor3 = isPrimary and Akbar.Theme.AccentDark or Akbar.Theme.Text,
        BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = card,
    })
    if cfg.Desc then
        create("TextLabel", {
            Position = UDim2.fromOffset(14, 32), Size = UDim2.new(1, -28, 0, 17),
            Text = cfg.Desc, TextSize = 11, FontFace = Akbar.Fonts.Regular,
            TextColor3 = isPrimary and Akbar.Theme.AccentDark or Akbar.Theme.Muted,
            BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = card,
        })
    end
    card.MouseButton1Click:Connect(function() safeCall(cfg.Callback) end)
    return finishElement(self, cfg, {
        SetText = function(_, v) title.Text = v end,
    }, card, "Button")
end

function TM:Toggle(cfg)
    cfg = normalize(cfg, {
        Title = "Name", Description = "Desc",
        CurrentValue = "Default", Value = "Default",
    })
    local card = create("TextButton", {
        Size = UDim2.new(1, 0, 0, cfg.Desc and 64 or 48),
        BackgroundColor3 = Akbar.Theme.Surface2, BorderSizePixel = 0,
        Text = "", AutoButtonColor = false,
        LayoutOrder = self:_nextOrder(), Parent = self.List,
    })
    corner(card, 8); stroke(card, Akbar.Theme.Stroke, 1)
    create("TextLabel", {
        Position = UDim2.fromOffset(14, cfg.Desc and 12 or 0),
        Size = UDim2.new(1, -80, cfg.Desc and 0 or 1, cfg.Desc and 18 or 0),
        Text = cfg.Name or "Toggle", TextSize = 13, FontFace = Akbar.Fonts.Medium,
        TextColor3 = Akbar.Theme.Text, BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = card,
    })
    if cfg.Desc then
        create("TextLabel", {
            Position = UDim2.fromOffset(14, 32), Size = UDim2.new(1, -80, 0, 17),
            Text = cfg.Desc, TextSize = 11, FontFace = Akbar.Fonts.Regular,
            TextColor3 = Akbar.Theme.Muted, BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = card,
        })
    end
    local pill = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(36, 20), BackgroundColor3 = Akbar.Theme.Surface3,
        BorderSizePixel = 0, Parent = card,
    })
    corner(pill, UDim.new(1, 0)); stroke(pill, Akbar.Theme.Stroke, 1)
    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.fromOffset(14, 14), BackgroundColor3 = Color3.fromRGB(255,255,255),
        BorderSizePixel = 0, Parent = pill,
    })
    corner(knob, UDim.new(1, 0))

    local state = { Value = cfg.Default == true }
    local function render(animate)
        local on = state.Value
        local d = animate and 0.25 or 0
        tween(pill, {BackgroundColor3 = on and Akbar.Theme.Accent or Akbar.Theme.Surface3}, d)
        tween(knob, {
            Position = on and UDim2.new(0, 19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
            BackgroundColor3 = on and Akbar.Theme.AccentDark or Color3.fromRGB(255,255,255),
        }, d, Enum.EasingStyle.Back)
    end
    function state:Set(v, silent)
        v = v == true
        if v == state.Value then return end
        state.Value = v
        render(true)
        if not silent then safeCall(cfg.Callback, v) end
    end
    function state:Get() return state.Value end
    render(false)
    card.MouseButton1Click:Connect(function() state:Set(not state.Value) end)
    return finishElement(self, cfg, state, card, "Toggle")
end

function TM:Slider(cfg)
    cfg = normalize(cfg, {
        Title = "Name", Description = "Desc",
        CurrentValue = "Default", Value = "Default", Increment = "Step",
    })
    local min, max = cfg.Min or 0, cfg.Max or 100
    local step = cfg.Step or 1
    local suffix = cfg.Suffix or ""
    local card = makeCard(self, 56)
    create("TextLabel", {
        Position = UDim2.fromOffset(14, 12), Size = UDim2.new(1, -120, 0, 18),
        Text = cfg.Name or "Slider", TextSize = 13, FontFace = Akbar.Fonts.Medium,
        TextColor3 = Akbar.Theme.Text, BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = card,
    })
    local valueLabel = create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 9),
        Size = UDim2.fromOffset(60, 24), Text = tostring(cfg.Default or min)..suffix,
        TextSize = 13, FontFace = Akbar.Fonts.Medium, TextColor3 = Akbar.Theme.Accent,
        BackgroundColor3 = Akbar.Theme.Surface, BorderSizePixel = 0,
        TextXAlignment = Enum.TextXAlignment.Center, Parent = card,
    })
    corner(valueLabel, UDim.new(0, 6)); stroke(valueLabel, Akbar.Theme.Stroke, 1)
    local track = create("Frame", {
        Position = UDim2.new(0, 14, 0, 44), Size = UDim2.new(1, -28, 0, 4),
        BackgroundColor3 = Akbar.Theme.Surface3, BorderSizePixel = 0, Parent = card,
    })
    corner(track, UDim.new(1, 0))
    local fill = create("Frame", {
        Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Akbar.Theme.Accent,
        BorderSizePixel = 0, Parent = track,
    })
    corner(fill, UDim.new(1, 0))
    local state = { Value = math.clamp(cfg.Default or min, min, max) }
    local function snap(v) return math.clamp(math.floor(v/step + 0.5)*step, min, max) end
    local function render(animate)
        local rel = (max - min == 0) and 0 or (state.Value - min)/(max - min)
        tween(fill, {Size = UDim2.new(rel, 0, 1, 0)}, animate and 0.15 or 0)
        valueLabel.Text = tostring(state.Value)..suffix
    end
    function state:Set(v, silent)
        v = snap(tonumber(v) or min)
        if v == state.Value then return end
        state.Value = v
        render(true)
        if not silent then safeCall(cfg.Callback, v) end
    end
    function state:Get() return state.Value end
    render(false)
    local hit = create("TextButton", {
        Position = UDim2.new(0, 8, 0, 36), Size = UDim2.new(1, -16, 0, 28),
        BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Parent = card,
    })
    local dragging = false
    local function fromX(x)
        local rel = math.clamp((x - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1)
        state:Set(min + (max - min)*rel)
    end
    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            fromX(input.Position.X)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            fromX(input.Position.X)
        end
    end)
    return finishElement(self, cfg, state, card, "Slider")
end

function TM:Dropdown(cfg)
    cfg = normalize(cfg, {
        Title = "Name", Description = "Desc",
        CurrentOption = "Default", Value = "Default",
        MultipleOptions = "Multi", Values = "Options",
    })
    local multi = cfg.Multi == true
    local options = cfg.Options or {}
    local selected = {}
    if multi then
        if type(cfg.Default) == "table" then
            for _, v in ipairs(cfg.Default) do selected[v] = true end
        end
    else
        if type(cfg.Default) == "table" then cfg.Default = cfg.Default[1] end
        if cfg.Default ~= nil then selected[cfg.Default] = true end
    end
    local card = makeCard(self, 56)
    create("TextLabel", {
        Position = UDim2.fromOffset(14, 12), Size = UDim2.new(1, -100, 0, 18),
        Text = cfg.Name or "Dropdown", TextSize = 13, FontFace = Akbar.Fonts.Medium,
        TextColor3 = Akbar.Theme.Text, BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = card,
    })
    local display = create("TextLabel", {
        Position = UDim2.fromOffset(14, 32), Size = UDim2.new(1, -100, 0, 17),
        Text = "None", TextSize = 11, FontFace = Akbar.Fonts.Regular,
        TextColor3 = Akbar.Theme.Muted, BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = card,
    })
    local chip = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(60, 28), BackgroundColor3 = Akbar.Theme.Surface,
        BorderSizePixel = 0, Parent = card,
    })
    corner(chip, UDim.new(0, 6)); stroke(chip, Akbar.Theme.Stroke, 1)
    create("TextLabel", {
        Size = UDim2.fromScale(1, 1), Text = "v", TextSize = 14,
        TextColor3 = Akbar.Theme.Muted, BackgroundTransparency = 1, Parent = chip,
    })
    local list = create("Frame", {
        Position = UDim2.new(0, 10, 0, 56), Size = UDim2.new(1, -20, 0, 0),
        BackgroundColor3 = Akbar.Theme.Surface, BorderSizePixel = 0,
        ClipsDescendants = true, Visible = false, ZIndex = 5, Parent = card,
    })
    corner(list, UDim.new(0, 6)); stroke(list, Akbar.Theme.Stroke, 1)
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = list,
    })
    local optionButtons = {}
    local function refreshDisplay()
        local arr = {}
        for _, opt in ipairs(options) do
            if selected[opt] then table.insert(arr, opt) end
        end
        display.Text = #arr > 0 and table.concat(arr, ", ") or "None"
    end
    for _, opt in ipairs(options) do
        local btn = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = Akbar.Theme.Surface,
            BackgroundTransparency = 0.4, BorderSizePixel = 0, Text = tostring(opt),
            TextSize = 12, FontFace = Akbar.Fonts.Regular,
            TextColor3 = Akbar.Theme.Muted, AutoButtonColor = false, Parent = list,
        })
        corner(btn, UDim.new(0, 4))
        btn.MouseButton1Click:Connect(function()
            if multi then
                selected[opt] = not selected[opt]
                refreshDisplay()
                if cfg.Callback then safeCall(cfg.Callback, opt, selected[opt]) end
            else
                for k in pairs(selected) do selected[k] = nil end
                selected[opt] = true
                refreshDisplay()
                if cfg.Callback then safeCall(cfg.Callback, opt) end
            end
        end)
        optionButtons[opt] = btn
    end
    refreshDisplay()
    local open = false
    local function setOpen(v)
        open = v
        list.Visible = true
        tween(list, {Size = UDim2.new(1, -20, 0, open and (#options*30 + 8) or 0)}, 0.2)
        if not open then
            task.delay(0.2, function() if not open then list.Visible = false end end)
        end
    end
    local hit = create("TextButton", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        Text = "", AutoButtonColor = false, Parent = card,
    })
    hit.MouseButton1Click:Connect(function() setOpen(not open) end)
    local element = {
        Set = function(_, value)
            for k in pairs(selected) do selected[k] = nil end
            if type(value) == "table" then
                for _, v in ipairs(value) do selected[v] = true end
            else selected[value] = true end
            refreshDisplay()
        end,
        Get = function()
            local arr = {}
            for k in pairs(selected) do table.insert(arr, k) end
            if multi then return arr end
            return arr[1]
        end,
    }
    return finishElement(self, cfg, element, card, "Dropdown")
end

function TM:Input(cfg)
    cfg = normalize(cfg, {
        Title = "Name", Description = "Desc",
        PlaceholderText = "Placeholder",
        CurrentValue = "Default", Value = "Default",
    })
    local card = makeCard(self, 56)
    create("TextLabel", {
        Position = UDim2.fromOffset(14, 12), Size = UDim2.new(1, -100, 0, 18),
        Text = cfg.Name or "Input", TextSize = 13, FontFace = Akbar.Fonts.Medium,
        TextColor3 = Akbar.Theme.Text, BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = card,
    })
    local box = create("Frame", {
        Position = UDim2.fromOffset(14, 34), Size = UDim2.new(1, -28, 0, 28),
        BackgroundColor3 = Akbar.Theme.Surface, BorderSizePixel = 0, Parent = card,
    })
    corner(box, UDim.new(0, 6)); stroke(box, Akbar.Theme.Stroke, 1)
    local tb = create("TextBox", {
        Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -20, 1, 0),
        BackgroundTransparency = 1, Text = cfg.Default or "",
        PlaceholderText = cfg.Placeholder or "", PlaceholderColor3 = Akbar.Theme.Muted,
        TextColor3 = Akbar.Theme.Text, TextSize = 13, FontFace = Akbar.Fonts.Regular,
        TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = box,
    })
    tb.FocusLost:Connect(function(enter)
        safeCall(cfg.Callback, tb.Text, enter)
    end)
    return finishElement(self, cfg, {
        Set = function(_, v) tb.Text = tostring(v) end,
        Get = function() return tb.Text end,
    }, card, "Input")
end

function TM:Keybind(cfg)
    cfg = normalize(cfg, {
        Title = "Name", Description = "Desc",
        CurrentKeybind = "Default", Value = "Default",
    })
    if type(cfg.Default) == "string" then cfg.Default = Enum.KeyCode[cfg.Default] end
    local card = makeCard(self, 48)
    create("TextLabel", {
        Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -100, 1, 0),
        Text = cfg.Name or "Keybind", TextSize = 13, FontFace = Akbar.Fonts.Medium,
        TextColor3 = Akbar.Theme.Text, BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = card,
    })
    local btn = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(64, 28), BackgroundColor3 = Akbar.Theme.Surface,
        BorderSizePixel = 0, Text = "", AutoButtonColor = false, Parent = card,
    })
    corner(btn, UDim.new(0, 6)); stroke(btn, Akbar.Theme.Stroke, 1)
    local label = create("TextLabel", {
        Size = UDim2.fromScale(1, 1), Text = cfg.Default and cfg.Default.Name or "None",
        TextSize = 12, FontFace = Akbar.Fonts.Medium, TextColor3 = Akbar.Theme.Muted,
        BackgroundTransparency = 1, Parent = btn,
    })
    local state = { Value = cfg.Default, Listening = false }
    local function render()
        label.Text = state.Listening and "..." or (state.Value and state.Value.Name or "None")
    end
    function state:Set(v, silent)
        state.Value = v; state.Listening = false; render()
        if not silent then safeCall(cfg.OnChanged, v) end
    end
    function state:Get() return state.Value end
    render()
    btn.MouseButton1Click:Connect(function()
        state.Listening = not state.Listening; render()
    end)
    if self.Window and self.Window._listen then
        self.Window:_listen("Began", function(input, gp)
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if state.Listening then
                if input.KeyCode == Enum.KeyCode.Escape then
                    state.Listening = false; render()
                else state:Set(input.KeyCode) end
                return
            end
            if not gp and state.Value and input.KeyCode == state.Value then
                safeCall(cfg.Callback, input.KeyCode)
            end
        end)
    end
    return finishElement(self, cfg, state, card, "Keybind")
end

function TM:ColorPicker(cfg)
    cfg = normalize(cfg, {
        Title = "Name", Description = "Desc",
        Color = "Default", CurrentValue = "Default", Value = "Default",
    })
    local color = cfg.Default or Color3.fromRGB(235, 199, 246)
    local card = makeCard(self, 56)
    create("TextLabel", {
        Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -80, 1, 0),
        Text = cfg.Name or "Color", TextSize = 13, FontFace = Akbar.Fonts.Medium,
        TextColor3 = Akbar.Theme.Text, BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = card,
    })
    local preview = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(40, 24), BackgroundColor3 = color,
        BorderSizePixel = 0, Parent = card,
    })
    corner(preview, UDim.new(0, 6)); stroke(preview, Akbar.Theme.Stroke, 1)
    local element = {
        Set = function(_, v) color = v; preview.BackgroundColor3 = v end,
        Get = function() return color end,
    }
    return finishElement(self, cfg, element, card, "ColorPicker")
end

function TM:Collapsible(cfg)
    cfg = normalize(cfg, { Title = "Name" })
    local tab = self
    local container = create("Frame", {
        Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = Akbar.Theme.Surface2,
        BorderSizePixel = 0, ClipsDescendants = true,
        LayoutOrder = tab:_nextOrder(), Parent = tab.List,
    })
    corner(container, 8); stroke(container, Akbar.Theme.Stroke, 1)
    local header = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1,
        Text = "", AutoButtonColor = false, Parent = container,
    })
    create("TextLabel", {
        Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -40, 1, 0),
        Text = cfg.Name or "Group", TextSize = 13, FontFace = Akbar.Fonts.Medium,
        TextColor3 = Akbar.Theme.Text, BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = header,
    })
    local arrow = create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(20, 20), Text = "v", TextSize = 14,
        TextColor3 = Akbar.Theme.Muted, BackgroundTransparency = 1, Parent = header,
    })
    local content = create("Frame", {
        Position = UDim2.fromOffset(0, 42), Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1, Parent = container,
    })
    create("UIPadding", {
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = content,
    })
    local contentLayout = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = content,
    })
    local expanded = false
    local groupObj = {}
    local proxyTab = {
        _order = 0, Window = tab.Window, List = content,
        _nextOrder = function(s) s._order = s._order + 1; return s._order end,
    }
    setmetatable(proxyTab, { __index = TM })
    local methods = {
        "Toggle","Slider","Dropdown","Input","Keybind",
        "ColorPicker","Button","Label","Paragraph","Divider"
    }
    for _, m in ipairs(methods) do
        groupObj[m] = function(_, ...) return proxyTab[m](proxyTab, ...) end
    end
    local function updateSize()
        local ch = contentLayout.AbsoluteContentSize.Y
        local th = expanded and (42 + ch + 10) or 42
        tween(container, {Size = UDim2.new(1, 0, 0, th)}, 0.25, Enum.EasingStyle.Quart)
        tween(content, {Size = UDim2.new(1, 0, 0, ch + 10)}, 0.25, Enum.EasingStyle.Quart)
    end
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if expanded then updateSize() end
    end)
    header.MouseButton1Click:Connect(function()
        expanded = not expanded
        tween(arrow, {Rotation = expanded and 180 or 0}, 0.25)
        updateSize()
    end)
    return groupObj
end

return Akbar
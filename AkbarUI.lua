--[[
    AKBAR UI — WindUI Edition (Full Framework Architecture)
    Brand: AKBAR UI / King Akbar
    Version: 2.0.0-WindStyle (Full Release)
    Features:
      - Bouncy & Elastic Spring Animations (WindUI Style)
      - Zero Mobile Input Lag (ZIndex = 10 Hitbox Overlays & .Activated)
      - Touch Scroll-Lock on Drag (Slider & HSV Canvas)
      - Full HSV Color Picker Panel (SV Canvas, Hue Bar, Hex Input, Presets)
      - Dynamic Dropdowns, Tabs, Collapsible Groups, Steppers, Keybinds
      - Auto JSON Configuration Engine (writefile / readfile fallback)
]]

local Akbar = {}
Akbar.__index = Akbar
Akbar.Version = "2.0.0-WindStyle"
Akbar.AnimationEnabled = true

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local IsMobile = UserInputService.TouchEnabled

-- Theme Tokens
Akbar.Theme = {
    Background = Color3.fromRGB(15, 15, 17),
    Surface = Color3.fromRGB(25, 25, 28),
    Surface2 = Color3.fromRGB(33, 33, 37),
    SurfaceHover = Color3.fromRGB(42, 42, 48),
    Border = Color3.fromRGB(50, 50, 56),
    BorderLight = Color3.fromRGB(70, 70, 78),
    Text = Color3.fromRGB(245, 245, 250),
    Muted = Color3.fromRGB(150, 150, 160),
    Accent = Color3.fromRGB(70, 130, 255),
    AccentDark = Color3.fromRGB(50, 100, 220),
    Success = Color3.fromRGB(46, 204, 113),
    Warning = Color3.fromRGB(241, 196, 15),
    Error = Color3.fromRGB(231, 76, 60),
    GlassTransparency = 0.15,
}

-- Icons Registry
local Icons = {
    ["crown"] = "rbxassetid://7733964719",
    ["anchor"] = "rbxassetid://7733658504",
    ["fish"] = "rbxassetid://7733919783",
    ["pickaxe"] = "rbxassetid://7734053495",
    ["bot"] = "rbxassetid://7733692043",
    ["sprout"] = "rbxassetid://7734068321",
    ["settings"] = "rbxassetid://7734053426",
    ["home"] = "rbxassetid://7733960981",
    ["info"] = "rbxassetid://7733965118",
    ["user"] = "rbxassetid://7734091286",
    ["users"] = "rbxassetid://7734091392",
    ["zap"] = "rbxassetid://7734110803",
    ["shield"] = "rbxassetid://7734056608",
    ["wrench"] = "rbxassetid://7734110303",
    ["refresh-cw"] = "rbxassetid://7734051050",
    ["layout-dashboard"] = "rbxassetid://7733955740",
    ["scroll-text"] = "rbxassetid://7734052335",
    ["search"] = "rbxassetid://7734052925",
    ["x"] = "rbxassetid://7734110595",
    ["minus"] = "rbxassetid://7733911828",
    ["maximize"] = "rbxassetid://7733955511",
    ["chevron-down"] = "rbxassetid://7733717444",
    ["chevron-up"] = "rbxassetid://7733717651",
    ["check"] = "rbxassetid://7733715400",
    ["save"] = "rbxassetid://7734052335",
    ["palette"] = "rbxassetid://7734053495",
    ["fallback"] = "rbxassetid://7733964719"
}

-- Utility Helpers
local function GetIcon(name)
    if not name or name == "" then return Icons["fallback"] end
    name = tostring(name)
    if string.find(name, "rbxassetid://") or string.find(name, "http") then
        return name
    elseif tonumber(name) then
        return "rbxassetid://" .. name
    end
    return Icons[string.lower(name)] or Icons["fallback"]
end

local function Tween(instance, info, properties)
    if not instance then return end
    if not Akbar.AnimationEnabled then
        for prop, val in pairs(properties) do
            instance[prop] = val
        end
        return nil
    end
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

local function SafeParentGui(gui, preferredParent)
    local target = preferredParent or (gethui and gethui()) or CoreGui
    local success, _ = pcall(function() gui.Parent = target end)
    if not success then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
end

local function FindParentScroll(obj)
    local current = obj.Parent
    while current and current ~= game do
        if current:IsA("ScrollingFrame") then return current end
        current = current.Parent
    end
    return nil
end

-- Configuration Engine
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
    if not flag then return end
    self.Flags[flag] = { Get = getter, Set = setter }
end

function ConfigManager:Save(fileName)
    fileName = (fileName or self.DefaultFile) .. ".json"
    local data = {}
    for flag, item in pairs(self.Flags) do
        local val = item.Get()
        if typeof(val) == "Color3" then
            data[flag] = { __type = "Color3", r = val.R, g = val.G, b = val.B }
        elseif typeof(val) == "EnumItem" then
            data[flag] = { __type = "EnumItem", enum = tostring(val.EnumType), name = val.Name }
        else
            data[flag] = val
        end
    end
    
    local encoded = game:GetService("HttpService"):JSONEncode(data)
    if writefile and makefolder then
        pcall(function()
            makefolder(self.Folder)
            writefile(self.Folder .. "/" .. fileName, encoded)
        end)
    else
        _G["AKBAR_CONFIG_" .. self.Folder .. "_" .. fileName] = encoded
    end
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
    else
        content = _G["AKBAR_CONFIG_" .. self.Folder .. "_" .. fileName]
    end

    if not content then return false end
    local success, decoded = pcall(function()
        return game:GetService("HttpService"):JSONDecode(content)
    end)
    if not success or not decoded then return false end

    for flag, val in pairs(decoded) do
        if self.Flags[flag] then
            if type(val) == "table" and val.__type == "Color3" then
                self.Flags[flag].Set(Color3.new(val.r, val.g, val.b))
            elseif type(val) == "table" and val.__type == "EnumItem" then
                local ok, enumVal = pcall(function()
                    return Enum[val.enum][val.name]
                end)
                if ok and enumVal then self.Flags[flag].Set(enumVal) end
            else
                self.Flags[flag].Set(val)
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
        local files = listfiles(self.Folder)
        for _, filePath in ipairs(files) do
            local clean = string.match(filePath, "([^/\\]+)%.json$")
            if clean then table.insert(list, clean) end
        end
    else
        for key, _ in pairs(_G) do
            local clean = string.match(tostring(key), "^AKBAR_CONFIG_" .. self.Folder .. "_(.+)%.json$")
            if clean then table.insert(list, clean) end
        end
    end
    return list
end

function Akbar:SetTheme(newTheme)
    for key, val in pairs(newTheme) do
        if Akbar.Theme[key] ~= nil then Akbar.Theme[key] = val end
    end
end

function Akbar:SetAccentColor(color)
    Akbar.Theme.Accent = color
    Akbar.Theme.AccentDark = Color3.fromRGB(math.clamp(color.R*255 - 20, 0, 255), math.clamp(color.G*255 - 20, 0, 255), math.clamp(color.B*255 - 20, 0, 255))
end

function Akbar:SetAnimations(state)
    Akbar.AnimationEnabled = state and true or false
end

-- Window Construction
function Akbar:CreateWindow(config)
    config = config or {}
    local WindowName = config.Name or "King Akbar"
    local WindowSubtitle = config.LoadingSubtitle or "WindUI Edition"
    local WindowIcon = config.Icon or "crown"
    local ToggleKey = config.ToggleUIKeybind or "RightControl"
    local WindowSize = config.Size or (IsMobile and UDim2.fromOffset(520, 310) or UDim2.fromOffset(720, 480))
    local MinSize = config.MinSize or (IsMobile and Vector2.new(420, 260) or Vector2.new(480, 340))
    local MaxSize = config.MaxSize or (IsMobile and Vector2.new(780, 450) or Vector2.new(1050, 700))
    local MaxNotifs = config.MaxNotifications or 4
    local KeepOnScreen = config.KeepOnScreen ~= false
    local AccordionDefault = config.Accordion or false

    local Window = {
        Tabs = {},
        ActiveTab = nil,
        Connections = {},
        Collapsibles = {},
        Accordion = AccordionDefault,
        Size = WindowSize,
        MinSize = MinSize,
        MaxSize = MaxSize,
        IsMinimized = false,
        IsMaximized = false,
        PreMaximizeSize = WindowSize,
        PreMaximizePos = UDim2.new(0.5, 0, 0.5, 0),
        Config = ConfigManager.new(
            config.ConfigurationSaving and config.ConfigurationSaving.FolderName or "AkbarHub",
            config.ConfigurationSaving and config.ConfigurationSaving.FileName or "default"
        )
    }

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AkbarUI_" .. WindowName:gsub("%s+", "")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    SafeParentGui(ScreenGui, config.Parent)
    Window.ScreenGui = ScreenGui

    local MainShadow = Instance.new("ImageLabel")
    MainShadow.Name = "Shadow"
    MainShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    MainShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainShadow.Size = WindowSize
    MainShadow.BackgroundTransparency = 1
    MainShadow.Image = "rbxassetid://5554236805"
    MainShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    MainShadow.ImageTransparency = 0.3
    MainShadow.ScaleType = Enum.ScaleType.Slice
    MainShadow.SliceCenter = Rect.new(23, 23, 277, 277)
    MainShadow.Parent = ScreenGui
    Window.MainShadow = MainShadow

    local MainWindow = Instance.new("Frame")
    MainWindow.Name = "MainWindow"
    MainWindow.Size = UDim2.new(1, 0, 1, 0)
    MainWindow.BackgroundColor3 = Akbar.Theme.Background
    MainWindow.BackgroundTransparency = Akbar.Theme.GlassTransparency
    MainWindow.ClipsDescendants = true
    MainWindow.Parent = MainShadow
    Window.MainWindow = MainWindow

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainWindow

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Akbar.Theme.Border
    MainStroke.Transparency = 0.2
    MainStroke.Thickness = 1
    MainStroke.Parent = MainWindow

    local NotificationHolder = Instance.new("Frame")
    NotificationHolder.Name = "Notifications"
    NotificationHolder.AnchorPoint = Vector2.new(1, 1)
    NotificationHolder.Position = UDim2.new(1, -12, 1, -12)
    NotificationHolder.Size = UDim2.new(0, IsMobile and 260 or 320, 1, -24)
    NotificationHolder.BackgroundTransparency = 1
    NotificationHolder.ZIndex = 50
    NotificationHolder.Parent = ScreenGui

    local NotifLayout = Instance.new("UIListLayout")
    NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifLayout.Padding = UDim.new(0, 8)
    NotifLayout.Parent = NotificationHolder
    Window.NotificationHolder = NotificationHolder
    Window.Notifications = {}

    local HeaderHeight = IsMobile and 46 or 52
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, HeaderHeight)
    Header.BackgroundColor3 = Akbar.Theme.Surface
    Header.BackgroundTransparency = 0.3
    Header.Parent = MainWindow

    local HeaderLine = Instance.new("Frame")
    HeaderLine.Name = "Divider"
    HeaderLine.AnchorPoint = Vector2.new(0, 1)
    HeaderLine.Position = UDim2.new(0, 0, 1, 0)
    HeaderLine.Size = UDim2.new(1, 0, 0, 1)
    HeaderLine.BackgroundColor3 = Akbar.Theme.Border
    HeaderLine.BorderSizePixel = 0
    HeaderLine.Parent = Header

    local BrandIcon = Instance.new("ImageLabel")
    BrandIcon.Position = UDim2.new(0, 16, 0.5, -10)
    BrandIcon.Size = UDim2.new(0, 20, 0, 20)
    BrandIcon.BackgroundTransparency = 1
    BrandIcon.Image = GetIcon(WindowIcon)
    BrandIcon.ImageColor3 = Akbar.Theme.Accent
    BrandIcon.Active = false
    BrandIcon.Parent = Header

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Position = UDim2.new(0, 44, 0, 6)
    TitleLabel.Size = UDim2.new(0, 180, 0, 18)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = WindowName
    TitleLabel.TextColor3 = Akbar.Theme.Text
    TitleLabel.TextSize = IsMobile and 14 or 15
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Active = false
    TitleLabel.Parent = Header

    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Position = UDim2.new(0, 44, 0, 22)
    SubtitleLabel.Size = UDim2.new(0, 180, 0, 14)
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Font = Enum.Font.Gotham
    SubtitleLabel.Text = WindowSubtitle
    SubtitleLabel.TextColor3 = Akbar.Theme.Muted
    SubtitleLabel.TextSize = 11
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubtitleLabel.Active = false
    SubtitleLabel.Parent = Header

    local Controls = Instance.new("Frame")
    Controls.AnchorPoint = Vector2.new(1, 0.5)
    Controls.Position = UDim2.new(1, -8, 0.5, 0)
    Controls.Size = UDim2.new(0, 70, 0, 30)
    Controls.BackgroundTransparency = 1
    Controls.Parent = Header

    local ControlsLayout = Instance.new("UIListLayout")
    ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
    ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ControlsLayout.Padding = UDim.new(0, 6)
    ControlsLayout.Parent = Controls

    local function CreateHeaderButton(iconName, isClose)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 26, 0, 26)
        btn.BackgroundColor3 = Akbar.Theme.Surface2
        btn.BackgroundTransparency = 0.5
        btn.AutoButtonColor = false
        btn.Text = ""
        btn.Parent = Controls
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local btnIcon = Instance.new("ImageLabel")
        btnIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        btnIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
        btnIcon.Size = UDim2.new(0, 13, 0, 13)
        btnIcon.BackgroundTransparency = 1
        btnIcon.Image = GetIcon(iconName)
        btnIcon.ImageColor3 = Akbar.Theme.Muted
        btnIcon.Active = false
        btnIcon.Parent = btn

        local btnOverlay = Instance.new("TextButton")
        btnOverlay.Size = UDim2.new(1, 0, 1, 0)
        btnOverlay.BackgroundTransparency = 1
        btnOverlay.Text = ""
        btnOverlay.ZIndex = 10
        btnOverlay.Parent = btn

        btnOverlay.Activated:Connect(function()
            if isClose then
                local closeTween = Tween(MainShadow, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                    Size = UDim2.fromOffset(Window.Size.X.Offset * 0.8, Window.Size.Y.Offset * 0.8),
                    ImageTransparency = 1
                })
                Tween(MainWindow, TweenInfo.new(0.3), { BackgroundTransparency = 1 })
                if closeTween then closeTween.Completed:Wait() end
                MainShadow.Visible = false
                MainShadow.Size = Window.Size
                MainShadow.ImageTransparency = 0.3
                MainWindow.BackgroundTransparency = Akbar.Theme.GlassTransparency
            end
        end)
        return btn, btnOverlay
    end

    local MinBtn, MinOverlay = CreateHeaderButton("minus", false)
    local CloseBtn, CloseOverlay = CreateHeaderButton("x", true)

    local BodyContainer = Instance.new("Frame")
    BodyContainer.Position = UDim2.new(0, 0, 0, HeaderHeight)
    BodyContainer.Size = UDim2.new(1, 0, 1, -HeaderHeight)
    BodyContainer.BackgroundTransparency = 1
    BodyContainer.ClipsDescendants = true
    BodyContainer.Parent = MainWindow
    Window.BodyContainer = BodyContainer

    local SidebarWidth = IsMobile and 145 or 190
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, SidebarWidth, 1, 0)
    Sidebar.BackgroundColor3 = Akbar.Theme.Surface
    Sidebar.BackgroundTransparency = 0.5
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = BodyContainer
    Window.Sidebar = Sidebar

    local SidebarRightBorder = Instance.new("Frame")
    SidebarRightBorder.AnchorPoint = Vector2.new(1, 0)
    SidebarRightBorder.Position = UDim2.new(1, 0, 0, 0)
    SidebarRightBorder.Size = UDim2.new(0, 1, 1, 0)
    SidebarRightBorder.BackgroundColor3 = Akbar.Theme.Border
    SidebarRightBorder.BorderSizePixel = 0
    SidebarRightBorder.Parent = Sidebar

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Position = UDim2.new(0, 8, 0, 12)
    TabScroll.Size = UDim2.new(1, -16, 1, -24)
    TabScroll.BackgroundTransparency = 1
    TabScroll.BorderSizePixel = 0
    TabScroll.ScrollBarThickness = 0
    TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabScroll.Parent = Sidebar

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.Parent = TabScroll

    local ContentHolder = Instance.new("Frame")
    ContentHolder.Position = UDim2.new(0, SidebarWidth, 0, 0)
    ContentHolder.Size = UDim2.new(1, -SidebarWidth, 1, 0)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.Parent = BodyContainer
    Window.ContentHolder = ContentHolder

    local ContentHeader = Instance.new("Frame")
    ContentHeader.Size = UDim2.new(1, 0, 0, 44)
    ContentHeader.BackgroundTransparency = 1
    ContentHeader.Parent = ContentHolder

    local ContentHeaderPadding = Instance.new("UIPadding")
    ContentHeaderPadding.PaddingLeft = UDim.new(0, 18)
    ContentHeaderPadding.PaddingTop = UDim.new(0, 8)
    ContentHeaderPadding.Parent = ContentHeader

    local TabHeading = Instance.new("TextLabel")
    TabHeading.Size = UDim2.new(1, 0, 0, 20)
    TabHeading.BackgroundTransparency = 1
    TabHeading.Font = Enum.Font.GothamBold
    TabHeading.Text = "Tab"
    TabHeading.TextColor3 = Akbar.Theme.Text
    TabHeading.TextSize = 16
    TabHeading.TextXAlignment = Enum.TextXAlignment.Left
    TabHeading.Active = false
    TabHeading.Parent = ContentHeader

    local TabDesc = Instance.new("TextLabel")
    TabDesc.Position = UDim2.new(0, 0, 0, 20)
    TabDesc.Size = UDim2.new(1, 0, 0, 14)
    TabDesc.BackgroundTransparency = 1
    TabDesc.Font = Enum.Font.Gotham
    TabDesc.Text = "Description"
    TabDesc.TextColor3 = Akbar.Theme.Muted
    TabDesc.TextSize = 11
    TabDesc.TextXAlignment = Enum.TextXAlignment.Left
    TabDesc.Active = false
    TabDesc.Parent = ContentHeader

    local PagesContainer = Instance.new("Frame")
    PagesContainer.Position = UDim2.new(0, 0, 0, 48)
    PagesContainer.Size = UDim2.new(1, 0, 1, -48)
    PagesContainer.BackgroundTransparency = 1
    PagesContainer.Parent = ContentHolder
    Window.PagesContainer = PagesContainer

    local function ClampToViewport()
        if not KeepOnScreen then return end
        local camera = workspace.CurrentCamera
        local viewportSize = camera and camera.ViewportSize or Vector2.new(1280, 720)
        local currentSize = MainShadow.AbsoluteSize
        local minX = currentSize.X / 2
        local maxX = viewportSize.X - (currentSize.X / 2)
        local minY = currentSize.Y / 2
        local maxY = viewportSize.Y - (currentSize.Y / 2)

        local currentCenter = Vector2.new(MainShadow.AbsolutePosition.X + minX, MainShadow.AbsolutePosition.Y + minY)
        local clampedX = math.clamp(currentCenter.X, minX, math.max(minX, maxX))
        local clampedY = math.clamp(currentCenter.Y, minY, math.max(minY, maxY))
        MainShadow.Position = UDim2.new(0, clampedX, 0, clampedY)
    end

    if workspace.CurrentCamera then
        table.insert(Window.Connections, workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(ClampToViewport))
    end

    local isDragging = false
    local dragStart, startPos

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = MainShadow.Position
            local releaseConn
            releaseConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                    if releaseConn then releaseConn:Disconnect() end
                    ClampToViewport()
                end
            end)
        end
    end)

    table.insert(Window.Connections, UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainShadow.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            if KeepOnScreen then ClampToViewport() end
        end
    end))

    MinOverlay.Activated:Connect(function()
        Window.IsMinimized = not Window.IsMinimized
        if Window.IsMinimized then
            Tween(BodyContainer, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, 0) })
            Tween(MainShadow, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Size = UDim2.fromOffset(MainShadow.AbsoluteSize.X, HeaderHeight) })
        else
            Tween(MainShadow, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = Window.Size })
            Tween(BodyContainer, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 1, -HeaderHeight) })
        end
    end)

    local FloatBtn = Instance.new("ImageButton")
    FloatBtn.Name = "Akbar_ToggleIcon"
    FloatBtn.Size = UDim2.new(0, 44, 0, 44)
    FloatBtn.Position = config.OpenButton and config.OpenButton.Position or UDim2.new(0, 16, 0, 16)
    FloatBtn.BackgroundColor3 = Akbar.Theme.Surface
    FloatBtn.BackgroundTransparency = 0.1
    FloatBtn.Image = GetIcon(WindowIcon)
    FloatBtn.ImageColor3 = Akbar.Theme.Accent
    FloatBtn.Visible = true
    FloatBtn.ZIndex = 120
    SafeParentGui(FloatBtn, ScreenGui)

    local FloatCorner = Instance.new("UICorner")
    FloatCorner.CornerRadius = UDim.new(0.5, 0)
    FloatCorner.Parent = FloatBtn

    local FloatStroke = Instance.new("UIStroke")
    FloatStroke.Color = Akbar.Theme.BorderLight
    FloatStroke.Thickness = 1.5
    FloatStroke.Parent = FloatBtn

    local fDragging, hasMoved, fStart, fPos = false, false, nil, nil

    FloatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            fDragging = true
            hasMoved = false
            fStart = input.Position
            fPos = FloatBtn.Position
            Tween(FloatBtn, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { Size = UDim2.new(0, 38, 0, 38) })
            
            local releaseConn
            releaseConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    fDragging = false
                    Tween(FloatBtn, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 44, 0, 44) })
                    if releaseConn then releaseConn:Disconnect() end
                end
            end)
        end
    end)

    table.insert(Window.Connections, UserInputService.InputChanged:Connect(function(input)
        if fDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - fStart
            if math.abs(delta.X) > 6 or math.abs(delta.Y) > 6 then hasMoved = true end
            FloatBtn.Position = UDim2.new(fPos.X.Scale, fPos.X.Offset + delta.X, fPos.Y.Scale, fPos.Y.Offset + delta.Y)
        end
    end))

    FloatBtn.Activated:Connect(function()
        if not hasMoved then
            if not MainShadow.Visible then
                MainShadow.Visible = true
                MainShadow.Size = UDim2.fromOffset(Window.Size.X.Offset * 0.8, Window.Size.Y.Offset * 0.8)
                MainShadow.ImageTransparency = 1
                MainWindow.BackgroundTransparency = 1
                
                Tween(MainShadow, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = Window.Size, ImageTransparency = 0.3
                })
                Tween(MainWindow, TweenInfo.new(0.4), { BackgroundTransparency = Akbar.Theme.GlassTransparency })
            else
                CloseOverlay.Activated:Fire()
            end
        end
    end)

    table.insert(Window.Connections, UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode.Name == ToggleKey then FloatBtn.Activated:Fire() end
    end))

    function Window:SetAccordion(state) Window.Accordion = state and true or false end
    function Window:SaveConfig(name) Window.Config:Save(name) end
    function Window:LoadConfig(name) return Window.Config:Load(name) end
    function Window:DeleteConfig(name) Window.Config:Delete(name) end
    function Window:ListConfigs() return Window.Config:List() end

    function Window:Notify(notifData)
        notifData = notifData or {}
        local title = notifData.Title or "Akbar UI"
        local content = notifData.Content or ""
        local duration = notifData.Duration or 3.5

        if #Window.Notifications >= MaxNotifs then
            local oldest = table.remove(Window.Notifications, 1)
            if oldest and oldest.Frame then oldest.Frame:Destroy() end
        end

        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, 0, 0, 68)
        Card.BackgroundColor3 = Akbar.Theme.Surface
        Card.BackgroundTransparency = 0.1
        Card.ClipsDescendants = true
        Card.Position = UDim2.new(1, 50, 0, 0)
        Card.Parent = NotificationHolder
        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)
        Instance.new("UIStroke", Card).Color = Akbar.Theme.Border

        local IconImg = Instance.new("ImageLabel")
        IconImg.Position = UDim2.new(0, 14, 0, 14)
        IconImg.Size = UDim2.new(0, 20, 0, 20)
        IconImg.BackgroundTransparency = 1
        IconImg.Image = GetIcon(notifData.Icon or "info")
        IconImg.ImageColor3 = Akbar.Theme.Accent
        IconImg.Active = false
        IconImg.Parent = Card

        local TitleText = Instance.new("TextLabel")
        TitleText.Position = UDim2.new(0, 44, 0, 12)
        TitleText.Size = UDim2.new(1, -54, 0, 18)
        TitleText.BackgroundTransparency = 1
        TitleText.Font = Enum.Font.GothamBold
        TitleText.Text = title
        TitleText.TextColor3 = Akbar.Theme.Text
        TitleText.TextSize = 14
        TitleText.TextXAlignment = Enum.TextXAlignment.Left
        TitleText.Active = false
        TitleText.Parent = Card

        local DescText = Instance.new("TextLabel")
        DescText.Position = UDim2.new(0, 44, 0, 32)
        DescText.Size = UDim2.new(1, -54, 0, 22)
        DescText.BackgroundTransparency = 1
        DescText.Font = Enum.Font.Gotham
        DescText.Text = content
        DescText.TextColor3 = Akbar.Theme.Muted
        DescText.TextSize = 12
        DescText.TextXAlignment = Enum.TextXAlignment.Left
        DescText.TextTruncate = Enum.TextTruncate.AtEnd
        DescText.Active = false
        DescText.Parent = Card

        local ProgressBar = Instance.new("Frame")
        ProgressBar.AnchorPoint = Vector2.new(0, 1)
        ProgressBar.Position = UDim2.new(0, 0, 1, 0)
        ProgressBar.Size = UDim2.new(1, 0, 0, 3)
        ProgressBar.BackgroundColor3 = Akbar.Theme.Accent
        ProgressBar.BorderSizePixel = 0
        ProgressBar.Parent = Card

        local notifRef = { Frame = Card }
        table.insert(Window.Notifications, notifRef)

        Tween(Card, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, 0) })
        Tween(ProgressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 3) })

        task.delay(duration, function()
            local slideOut = Tween(Card, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Position = UDim2.new(1, 50, 0, 0) })
            if slideOut then slideOut.Completed:Wait() end
            for i, n in ipairs(Window.Notifications) do
                if n == notifRef then table.remove(Window.Notifications, i) break end
            end
            Card:Destroy()
        end)
    end

    function Window:Confirm(confirmData)
        confirmData = confirmData or {}
        local title = confirmData.Title or "Confirmation"
        local content = confirmData.Content or "Are you sure?"
        local cText = confirmData.ConfirmText or "Confirm"
        local canText = confirmData.CancelText or "Cancel"
        local cb = confirmData.Callback or function() end

        local ModalBackdrop = Instance.new("TextButton")
        ModalBackdrop.Size = UDim2.new(1, 0, 1, 0)
        ModalBackdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        ModalBackdrop.BackgroundTransparency = 0.4
        ModalBackdrop.Text = ""
        ModalBackdrop.ZIndex = 80
        ModalBackdrop.Parent = MainWindow
        Instance.new("UICorner", ModalBackdrop).CornerRadius = UDim.new(0, 10)

        local DialogBox = Instance.new("Frame")
        DialogBox.AnchorPoint = Vector2.new(0.5, 0.5)
        DialogBox.Position = UDim2.new(0.5, 0, 0.5, 0)
        DialogBox.Size = UDim2.new(0, 320, 0, 150)
        DialogBox.BackgroundColor3 = Akbar.Theme.Surface
        DialogBox.ClipsDescendants = true
        DialogBox.Parent = ModalBackdrop
        Instance.new("UICorner", DialogBox).CornerRadius = UDim.new(0, 10)
        Instance.new("UIStroke", DialogBox).Color = Akbar.Theme.Border

        local DTitle = Instance.new("TextLabel")
        DTitle.Position = UDim2.new(0, 16, 0, 14)
        DTitle.Size = UDim2.new(1, -32, 0, 20)
        DTitle.BackgroundTransparency = 1
        DTitle.Font = Enum.Font.GothamBold
        DTitle.Text = title
        DTitle.TextColor3 = Akbar.Theme.Text
        DTitle.TextSize = 14
        DTitle.TextXAlignment = Enum.TextXAlignment.Left
        DTitle.Active = false
        DTitle.Parent = DialogBox

        local DContent = Instance.new("TextLabel")
        DContent.Position = UDim2.new(0, 16, 0, 38)
        DContent.Size = UDim2.new(1, -32, 0, 42)
        DContent.BackgroundTransparency = 1
        DContent.Font = Enum.Font.Gotham
        DContent.Text = content
        DContent.TextColor3 = Akbar.Theme.Muted
        DContent.TextSize = 12
        DContent.TextWrapped = true
        DContent.TextXAlignment = Enum.TextXAlignment.Left
        DContent.Active = false
        DContent.Parent = DialogBox

        local BtnRow = Instance.new("Frame")
        BtnRow.AnchorPoint = Vector2.new(0, 1)
        BtnRow.Position = UDim2.new(0, 16, 1, -12)
        BtnRow.Size = UDim2.new(1, -32, 0, 32)
        BtnRow.BackgroundTransparency = 1
        BtnRow.Parent = DialogBox

        local function CreateDButton(text, isPrimary, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(0.5, -6, 1, 0)
            b.BackgroundColor3 = isPrimary and Akbar.Theme.Accent or Akbar.Theme.Surface2
            b.Font = Enum.Font.GothamBold
            b.Text = text
            b.TextColor3 = isPrimary and Color3.fromRGB(255, 255, 255) or Akbar.Theme.Muted
            b.TextSize = 12
            b.AutoButtonColor = false
            b.Parent = BtnRow
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

            local bClick = Instance.new("TextButton")
            bClick.Size = UDim2.new(1, 0, 1, 0)
            bClick.BackgroundTransparency = 1
            bClick.Text = ""
            bClick.ZIndex = 85
            bClick.Parent = b

            bClick.Activated:Connect(function()
                ModalBackdrop:Destroy()
                callback()
            end)
            return b
        end

        local CancelB = CreateDButton(canText, false, function() cb(false) end)
        CancelB.Position = UDim2.new(0, 0, 0, 0)
        local ConfirmB = CreateDButton(cText, true, function() cb(true) end)
        ConfirmB.Position = UDim2.new(0.5, 6, 0, 0)
    end

    function Window:Destroy()
        for _, conn in ipairs(Window.Connections) do
            if conn and conn.Disconnect then conn:Disconnect() end
        end
        if Window.ScreenGui then Window.ScreenGui:Destroy() end
    end

    -- Tab System (ZIndex 10 Hitbox Protected)
    function Window:CreateTab(tabConfig, optionalIcon)
        if type(tabConfig) == "string" then
            tabConfig = { Name = tabConfig, Icon = optionalIcon }
        end
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Name or "Tab"
        local tabDesc = tabConfig.Desc or ""
        local tabIcon = tabConfig.Icon or "anchor"

        local Tab = { Name = tabName, Desc = tabDesc, Icon = tabIcon, Window = Window, Components = {}, Collapsibles = {} }

        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = "Tab_" .. tabName
        TabBtn.Size = UDim2.new(1, 0, 0, 36)
        TabBtn.BackgroundColor3 = Akbar.Theme.Surface2
        TabBtn.BackgroundTransparency = 1
        TabBtn.AutoButtonColor = false
        TabBtn.Text = ""
        TabBtn.Parent = TabScroll
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)

        local TabIconImg = Instance.new("ImageLabel")
        TabIconImg.Position = UDim2.new(0, 10, 0.5, -9)
        TabIconImg.Size = UDim2.new(0, 18, 0, 18)
        TabIconImg.BackgroundTransparency = 1
        TabIconImg.Image = GetIcon(tabIcon)
        TabIconImg.ImageColor3 = Akbar.Theme.Muted
        TabIconImg.Active = false
        TabIconImg.Parent = TabBtn

        local TabText = Instance.new("TextLabel")
        TabText.Position = UDim2.new(0, 36, 0, 0)
        TabText.Size = UDim2.new(1, -44, 1, 0)
        TabText.BackgroundTransparency = 1
        TabText.Font = Enum.Font.GothamMedium
        TabText.Text = tabName
        TabText.TextColor3 = Akbar.Theme.Muted
        TabText.TextSize = 13
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.Active = false
        TabText.Parent = TabBtn

        local TabClickArea = Instance.new("TextButton")
        TabClickArea.Size = UDim2.new(1, 0, 1, 0)
        TabClickArea.BackgroundTransparency = 1
        TabClickArea.Text = ""
        TabClickArea.ZIndex = 10
        TabClickArea.Parent = TabBtn

        local PageScroll = Instance.new("ScrollingFrame")
        PageScroll.Name = "Page_" .. tabName
        PageScroll.Size = UDim2.new(1, 0, 1, 0)
        PageScroll.BackgroundTransparency = 1
        PageScroll.BorderSizePixel = 0
        PageScroll.ScrollBarThickness = 2
        PageScroll.ScrollBarImageColor3 = Akbar.Theme.BorderLight
        PageScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        PageScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        PageScroll.Visible = false
        PageScroll.Parent = PagesContainer

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.Parent = PageScroll

        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingLeft = UDim.new(0, 18)
        PagePadding.PaddingRight = UDim.new(0, 18)
        PagePadding.PaddingTop = UDim.new(0, 8)
        PagePadding.PaddingBottom = UDim.new(0, 24)
        PagePadding.Parent = PageScroll

        Tab.Page = PageScroll

        function Tab:Select()
            for _, t in ipairs(Window.Tabs) do
                if t ~= Tab then
                    Tween(t.Button, TweenInfo.new(0.3, Enum.EasingStyle.Sine), { BackgroundTransparency = 1 })
                    Tween(t.Button:FindFirstChildWhichIsA("ImageLabel"), TweenInfo.new(0.3), { ImageColor3 = Akbar.Theme.Muted })
                    Tween(t.Button:FindFirstChildWhichIsA("TextLabel"), TweenInfo.new(0.3), { TextColor3 = Akbar.Theme.Muted })
                    t.Page.Visible = false
                end
            end

            Window.ActiveTab = Tab
            TabHeading.Text = tabName
            TabDesc.Text = tabDesc
            Tab.Page.Visible = true

            Tween(TabBtn, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { Size = UDim2.new(0.95, 0, 0, 32) })
            task.delay(0.1, function()
                Tween(TabBtn, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { 
                    Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 0.1 
                })
            end)
            
            Tween(TabIconImg, TweenInfo.new(0.3), { ImageColor3 = Akbar.Theme.Accent })
            Tween(TabText, TweenInfo.new(0.3), { TextColor3 = Akbar.Theme.Text })
            
            PageScroll.Position = UDim2.new(0, 0, 0, 15)
            Tween(PageScroll, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, 0) })
        end

        local tabEnabled = true
        TabClickArea.Activated:Connect(function()
            if not tabEnabled then return end
            Tab:Select()
        end)

        function Tab:SetEnabled(state)
            tabEnabled = state and true or false
            TabClickArea.Active = tabEnabled
            TabIconImg.ImageTransparency = tabEnabled and 0 or 0.6
            TabText.TextColor3 = tabEnabled and Akbar.Theme.Muted or Color3.fromRGB(80, 85, 100)
        end

        table.insert(Window.Tabs, Tab)
        if #Window.Tabs == 1 then Tab:Select() end

        Akbar:_InjectComponentMethods(Tab, PageScroll)
        return Tab
    end

    Window.Tab = Window.CreateTab
    return Window
end

Akbar.Window = Akbar.CreateWindow

-- Component Factory (ZIndex 10 Hitbox Overlays)
function Akbar:_InjectComponentMethods(targetScope, containerFrame)
    local Window = targetScope.Window or targetScope

    -- 1. COLLAPSIBLE GROUP
    function targetScope:CreateCollapsible(colConfig)
        colConfig = colConfig or {}
        local Group = { IsOpenState = false, Collapsibles = {} }

        local GroupFrame = Instance.new("Frame")
        GroupFrame.Size = UDim2.new(1, 0, 0, 48)
        GroupFrame.BackgroundColor3 = Akbar.Theme.Surface
        GroupFrame.BackgroundTransparency = 0.2
        GroupFrame.ClipsDescendants = true
        GroupFrame.Parent = containerFrame
        Instance.new("UICorner", GroupFrame).CornerRadius = UDim.new(0, 10)
        Instance.new("UIStroke", GroupFrame).Color = Akbar.Theme.Border

        local HeaderBtn = Instance.new("Frame")
        HeaderBtn.Size = UDim2.new(1, 0, 0, 48)
        HeaderBtn.BackgroundTransparency = 1
        HeaderBtn.Parent = GroupFrame

        local IconImg = Instance.new("ImageLabel")
        IconImg.Position = UDim2.new(0, 14, 0.5, -9)
        IconImg.Size = UDim2.new(0, 18, 0, 18)
        IconImg.BackgroundTransparency = 1
        IconImg.Image = GetIcon(colConfig.Icon)
        IconImg.ImageColor3 = Akbar.Theme.Accent
        IconImg.Active = false
        IconImg.Parent = HeaderBtn

        local TitleText = Instance.new("TextLabel")
        TitleText.Position = UDim2.new(0, 40, 0, 15)
        TitleText.Size = UDim2.new(1, -70, 0, 16)
        TitleText.BackgroundTransparency = 1
        TitleText.Font = Enum.Font.GothamBold
        TitleText.Text = colConfig.Name or "Group"
        TitleText.TextColor3 = Akbar.Theme.Text
        TitleText.TextSize = 13
        TitleText.TextXAlignment = Enum.TextXAlignment.Left
        TitleText.Active = false
        TitleText.Parent = HeaderBtn

        local Chevron = Instance.new("ImageLabel")
        Chevron.AnchorPoint = Vector2.new(1, 0.5)
        Chevron.Position = UDim2.new(1, -14, 0.5, 0)
        Chevron.Size = UDim2.new(0, 16, 0, 16)
        Chevron.BackgroundTransparency = 1
        Chevron.Image = GetIcon("chevron-down")
        Chevron.ImageColor3 = Akbar.Theme.Muted
        Chevron.Active = false
        Chevron.Parent = HeaderBtn

        local HeaderClickArea = Instance.new("TextButton")
        HeaderClickArea.Size = UDim2.new(1, 0, 1, 0)
        HeaderClickArea.BackgroundTransparency = 1
        HeaderClickArea.Text = ""
        HeaderClickArea.ZIndex = 10
        HeaderClickArea.Parent = HeaderBtn

        local ContentArea = Instance.new("Frame")
        ContentArea.Position = UDim2.new(0, 0, 0, 48)
        ContentArea.Size = UDim2.new(1, 0, 0, 0)
        ContentArea.BackgroundTransparency = 1
        ContentArea.ClipsDescendants = true
        ContentArea.Parent = GroupFrame

        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 6)
        ContentLayout.Parent = ContentArea

        local ContentPadding = Instance.new("UIPadding")
        ContentPadding.PaddingLeft = UDim.new(0, 12)
        ContentPadding.PaddingRight = UDim.new(0, 12)
        ContentPadding.PaddingTop = UDim.new(0, 6)
        ContentPadding.PaddingBottom = UDim.new(0, 12)
        ContentPadding.Parent = ContentArea

        local function UpdateState(open, instant)
            Group.IsOpenState = open
            if open and Window.Accordion then
                local pool = targetScope.Collapsibles
                if pool then
                    for _, sibling in ipairs(pool) do
                        if sibling ~= Group and sibling.IsOpenState then sibling:Close() end
                    end
                end
            end

            local innerHeight = ContentLayout.AbsoluteContentSize.Y + 18
            local targetHeight = open and (48 + innerHeight) or 48

            if instant then
                Chevron.Rotation = open and 180 or 0
                GroupFrame.Size = UDim2.new(1, 0, 0, targetHeight)
                ContentArea.Size = UDim2.new(1, 0, 0, open and innerHeight or 0)
            else
                Tween(Chevron, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Rotation = open and 180 or 0 })
                Tween(GroupFrame, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, targetHeight) })
                Tween(ContentArea, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, open and innerHeight or 0) })
            end
        end

        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if Group.IsOpenState then
                local innerHeight = ContentLayout.AbsoluteContentSize.Y + 18
                GroupFrame.Size = UDim2.new(1, 0, 0, 48 + innerHeight)
                ContentArea.Size = UDim2.new(1, 0, 0, innerHeight)
            end
        end)

        HeaderClickArea.Activated:Connect(function() UpdateState(not Group.IsOpenState) end)
        function Group:Close() UpdateState(false) end

        Akbar:_InjectComponentMethods(Group, ContentArea)
        if targetScope.Collapsibles then table.insert(targetScope.Collapsibles, Group) end
        if colConfig.Open then task.defer(function() UpdateState(true, true) end) end

        return Group
    end

    -- 2. TOGGLE
    function targetScope:CreateToggle(toggleConfig)
        toggleConfig = toggleConfig or {}
        local Toggle = { Value = toggleConfig.CurrentValue or false }
        local cb = toggleConfig.Callback or function() end

        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 42)
        Frame.BackgroundColor3 = Akbar.Theme.Surface2
        Frame.BackgroundTransparency = 0.5
        Frame.Parent = containerFrame
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

        local Title = Instance.new("TextLabel")
        Title.Position = UDim2.new(0, 14, 0, 0)
        Title.Size = UDim2.new(1, -70, 1, 0)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamMedium
        Title.Text = toggleConfig.Name or "Toggle"
        Title.TextColor3 = Akbar.Theme.Text
        Title.TextSize = 13
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Active = false
        Title.Parent = Frame

        local SwitchTrack = Instance.new("Frame")
        SwitchTrack.AnchorPoint = Vector2.new(1, 0.5)
        SwitchTrack.Position = UDim2.new(1, -14, 0.5, 0)
        SwitchTrack.Size = UDim2.new(0, 40, 0, 22)
        SwitchTrack.BackgroundColor3 = Toggle.Value and Akbar.Theme.Accent or Akbar.Theme.Border
        SwitchTrack.Parent = Frame
        Instance.new("UICorner", SwitchTrack).CornerRadius = UDim.new(1, 0)

        local Knob = Instance.new("Frame")
        Knob.Position = Toggle.Value and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 4, 0.5, -7)
        Knob.Size = UDim2.new(0, 14, 0, 14)
        Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Knob.Parent = SwitchTrack
        Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

        local ClickBtn = Instance.new("TextButton")
        ClickBtn.Size = UDim2.new(1, 0, 1, 0)
        ClickBtn.BackgroundTransparency = 1
        ClickBtn.Text = ""
        ClickBtn.ZIndex = 10
        ClickBtn.Parent = Frame

        local function SetVal(val)
            Toggle.Value = val
            Tween(Knob, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { 
                Position = val and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 4, 0.5, -7),
                Size = UDim2.new(0, 14, 0, 14)
            })
            Tween(SwitchTrack, TweenInfo.new(0.3), { BackgroundColor3 = val and Akbar.Theme.Accent or Akbar.Theme.Border })
            pcall(cb, val)
        end

        ClickBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Tween(Knob, TweenInfo.new(0.15), { Size = UDim2.new(0, 18, 0, 14) })
            end
        end)

        ClickBtn.Activated:Connect(function() SetVal(not Toggle.Value) end)
        function Toggle:Set(val) SetVal(val) end
        function Toggle:Get() return Toggle.Value end

        if toggleConfig.Flag and Window.Config then
            Window.Config:Register(toggleConfig.Flag, function() return Toggle.Value end, function(v) Toggle:Set(v) end)
        end
        return Toggle
    end

    -- 3. BUTTON
    function targetScope:CreateButton(btnConfig)
        btnConfig = btnConfig or {}
        local cb = btnConfig.Callback or function() end
        local style = btnConfig.Style or "Default"

        local Btn = Instance.new("Frame")
        Btn.Size = UDim2.new(1, 0, 0, 42)
        Btn.BackgroundColor3 = style == "Primary" and Akbar.Theme.Accent or Akbar.Theme.Surface2
        Btn.BackgroundTransparency = style == "Primary" and 0.1 or 0.5
        Btn.Parent = containerFrame
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, 0, 1, 0)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamMedium
        Title.Text = btnConfig.Name or "Button"
        Title.TextColor3 = Akbar.Theme.Text
        Title.TextSize = 13
        Title.Active = false
        Title.Parent = Btn

        local BtnClickArea = Instance.new("TextButton")
        BtnClickArea.Size = UDim2.new(1, 0, 1, 0)
        BtnClickArea.BackgroundTransparency = 1
        BtnClickArea.Text = ""
        BtnClickArea.ZIndex = 10
        BtnClickArea.Parent = Btn

        BtnClickArea.Activated:Connect(function()
            Tween(Btn, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { Size = UDim2.new(1, -8, 0, 36) })
            task.delay(0.1, function()
                Tween(Btn, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, 42) })
            end)
            pcall(cb)
        end)

        return { Destroy = function() Btn:Destroy() end }
    end

    -- 4. SLIDER
    function targetScope:CreateSlider(sliderConfig)
        sliderConfig = sliderConfig or {}
        local range = sliderConfig.Range or {0, 100}
        local rangeSpan = math.max(range[2] - range[1], 1e-6)
        local cb = sliderConfig.Callback or function() end

        local Slider = { Value = math.clamp(sliderConfig.CurrentValue or range[1], range[1], range[2]) }

        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 56)
        Frame.BackgroundColor3 = Akbar.Theme.Surface2
        Frame.BackgroundTransparency = 0.5
        Frame.Parent = containerFrame
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

        local Title = Instance.new("TextLabel")
        Title.Position = UDim2.new(0, 14, 0, 10)
        Title.Size = UDim2.new(1, -90, 0, 16)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamMedium
        Title.Text = sliderConfig.Name or "Slider"
        Title.TextColor3 = Akbar.Theme.Text
        Title.TextSize = 13
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Active = false
        Title.Parent = Frame

        local ValLabel = Instance.new("TextLabel")
        ValLabel.AnchorPoint = Vector2.new(1, 0)
        ValLabel.Position = UDim2.new(1, -14, 0, 10)
        ValLabel.Size = UDim2.new(0, 70, 0, 16)
        ValLabel.BackgroundTransparency = 1
        ValLabel.Font = Enum.Font.GothamBold
        ValLabel.Text = tostring(Slider.Value) .. (sliderConfig.Suffix or "")
        ValLabel.TextColor3 = Akbar.Theme.Accent
        ValLabel.TextSize = 12
        ValLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValLabel.Active = false
        ValLabel.Parent = Frame

        local SliderBar = Instance.new("Frame")
        SliderBar.Position = UDim2.new(0, 14, 0, 36)
        SliderBar.Size = UDim2.new(1, -28, 0, 6)
        SliderBar.BackgroundColor3 = Akbar.Theme.Border
        SliderBar.Parent = Frame
        Instance.new("UICorner", SliderBar).CornerRadius = UDim.new(1, 0)

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((Slider.Value - range[1]) / rangeSpan, 0, 1, 0)
        Fill.BackgroundColor3 = Akbar.Theme.Accent
        Fill.Parent = SliderBar
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

        local TouchArea = Instance.new("TextButton")
        TouchArea.Position = UDim2.new(0, 0, 0, -12)
        TouchArea.Size = UDim2.new(1, 0, 1, 24)
        TouchArea.BackgroundTransparency = 1
        TouchArea.Text = ""
        TouchArea.ZIndex = 10
        TouchArea.Parent = SliderBar

        local isDragging = false
        local parentScroll = FindParentScroll(containerFrame)

        local function UpdateFromPercent(percent)
            local raw = range[1] + rangeSpan * math.clamp(percent, 0, 1)
            local inc = sliderConfig.Increment or 1
            local stepped = math.floor((raw / inc) + 0.5) * inc
            stepped = math.clamp(stepped, range[1], range[2])
            Slider.Value = stepped
            ValLabel.Text = tostring(stepped) .. (sliderConfig.Suffix or "")
            Tween(Fill, TweenInfo.new(0.08), { Size = UDim2.new((stepped - range[1]) / rangeSpan, 0, 1, 0) })
            pcall(cb, stepped)
        end

        TouchArea.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                if parentScroll then parentScroll.ScrollingEnabled = false end
                UpdateFromPercent((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X)

                local mc, ec
                mc = UserInputService.InputChanged:Connect(function(mi)
                    if isDragging and (mi.UserInputType == Enum.UserInputType.MouseMovement or mi.UserInputType == Enum.UserInputType.Touch) then
                        UpdateFromPercent((mi.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X)
                    end
                end)
                ec = UserInputService.InputEnded:Connect(function(ei)
                    if ei.UserInputType == Enum.UserInputType.MouseButton1 or ei.UserInputType == Enum.UserInputType.Touch then
                        isDragging = false
                        if parentScroll then parentScroll.ScrollingEnabled = true end
                        if mc then mc:Disconnect() end
                        if ec then ec:Disconnect() end
                    end
                end)
            end
        end)

        function Slider:Set(v)
            local inc = sliderConfig.Increment or 1
            local stepped = math.floor((v / inc) + 0.5) * inc
            local clamped = math.clamp(stepped, range[1], range[2])
            Slider.Value = clamped
            ValLabel.Text = tostring(clamped) .. (sliderConfig.Suffix or "")
            Fill.Size = UDim2.new((clamped - range[1]) / rangeSpan, 0, 1, 0)
            pcall(cb, clamped)
        end
        function Slider:Get() return Slider.Value end

        if sliderConfig.Flag and Window.Config then
            Window.Config:Register(sliderConfig.Flag, function() return Slider.Value end, function(v) Slider:Set(v) end)
        end
        return Slider
    end

    -- 5. STEPPER
    function targetScope:CreateStepper(stepConfig)
        stepConfig = stepConfig or {}
        local range = stepConfig.Range or {0, 100}
        local inc = stepConfig.Increment or 1
        local cb = stepConfig.Callback or function() end
        local Stepper = { Value = math.clamp(stepConfig.CurrentValue or range[1], range[1], range[2]) }

        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 44)
        Frame.BackgroundColor3 = Akbar.Theme.Surface2
        Frame.BackgroundTransparency = 0.5
        Frame.Parent = containerFrame
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

        local Title = Instance.new("TextLabel")
        Title.Position = UDim2.new(0, 14, 0, 0)
        Title.Size = UDim2.new(1, -120, 1, 0)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamMedium
        Title.Text = stepConfig.Name or "Stepper"
        Title.TextColor3 = Akbar.Theme.Text
        Title.TextSize = 13
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Active = false
        Title.Parent = Frame

        local StepperBox = Instance.new("Frame")
        StepperBox.AnchorPoint = Vector2.new(1, 0.5)
        StepperBox.Position = UDim2.new(1, -14, 0.5, 0)
        StepperBox.Size = UDim2.new(0, 96, 0, 26)
        StepperBox.BackgroundColor3 = Akbar.Theme.Border
        StepperBox.Parent = Frame
        Instance.new("UICorner", StepperBox).CornerRadius = UDim.new(0, 6)

        local DecBtn = Instance.new("TextButton")
        DecBtn.Size = UDim2.new(0, 26, 1, 0)
        DecBtn.BackgroundTransparency = 1
        DecBtn.AutoButtonColor = false
        DecBtn.Font = Enum.Font.GothamBold
        DecBtn.Text = "-"
        DecBtn.TextColor3 = Akbar.Theme.Text
        DecBtn.TextSize = 14
        DecBtn.ZIndex = 10
        DecBtn.Parent = StepperBox

        local IncBtn = Instance.new("TextButton")
        IncBtn.AnchorPoint = Vector2.new(1, 0)
        IncBtn.Position = UDim2.new(1, 0, 0, 0)
        IncBtn.Size = UDim2.new(0, 26, 1, 0)
        IncBtn.BackgroundTransparency = 1
        IncBtn.AutoButtonColor = false
        IncBtn.Font = Enum.Font.GothamBold
        IncBtn.Text = "+"
        IncBtn.TextColor3 = Akbar.Theme.Text
        IncBtn.TextSize = 14
        IncBtn.ZIndex = 10
        IncBtn.Parent = StepperBox

        local Display = Instance.new("TextLabel")
        Display.Position = UDim2.new(0, 26, 0, 0)
        Display.Size = UDim2.new(1, -52, 1, 0)
        Display.BackgroundTransparency = 1
        Display.Font = Enum.Font.GothamBold
        Display.Text = tostring(Stepper.Value)
        Display.TextColor3 = Akbar.Theme.Accent
        Display.TextSize = 12
        Display.Active = false
        Display.Parent = StepperBox

        local function Step(amount)
            local n = math.clamp(Stepper.Value + amount, range[1], range[2])
            Stepper.Value = n
            Display.Text = tostring(n)
            pcall(cb, n)
        end

        DecBtn.Activated:Connect(function() Step(-inc) end)
        IncBtn.Activated:Connect(function() Step(inc) end)

        function Stepper:Set(v)
            Stepper.Value = math.clamp(v, range[1], range[2])
            Display.Text = tostring(Stepper.Value)
            pcall(cb, Stepper.Value)
        end
        function Stepper:Get() return Stepper.Value end

        if stepConfig.Flag and Window.Config then
            Window.Config:Register(stepConfig.Flag, function() return Stepper.Value end, function(v) Stepper:Set(v) end)
        end
        return Stepper
    end

    -- 6. DROPDOWN
    function targetScope:CreateDropdown(dropConfig)
        dropConfig = dropConfig or {}
        local options = dropConfig.Options or {}
        local isMulti = dropConfig.MultipleOptions or false
        local cb = dropConfig.Callback or function() end
        local Dropdown = { Open = false, Value = dropConfig.CurrentOption or (isMulti and {} or options[1]), Options = options }

        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 44)
        Frame.BackgroundColor3 = Akbar.Theme.Surface2
        Frame.BackgroundTransparency = 0.5
        Frame.ClipsDescendants = true
        Frame.Parent = containerFrame
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

        local DropBtn = Instance.new("Frame")
        DropBtn.Size = UDim2.new(1, 0, 0, 44)
        DropBtn.BackgroundTransparency = 1
        DropBtn.Parent = Frame

        local Title = Instance.new("TextLabel")
        Title.Position = UDim2.new(0, 14, 0, 0)
        Title.Size = UDim2.new(1, -160, 0, 44)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamMedium
        Title.Text = dropConfig.Name or "Dropdown"
        Title.TextColor3 = Akbar.Theme.Text
        Title.TextSize = 13
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Active = false
        Title.Parent = DropBtn

        local Display = Instance.new("TextLabel")
        Display.AnchorPoint = Vector2.new(1, 0.5)
        Display.Position = UDim2.new(1, -38, 0.5, 0)
        Display.Size = UDim2.new(0, 110, 0, 24)
        Display.BackgroundTransparency = 1
        Display.Font = Enum.Font.Gotham
        Display.Text = isMulti and (#Dropdown.Value > 0 and table.concat(Dropdown.Value, ", ") or "None") or tostring(Dropdown.Value or "None")
        Display.TextColor3 = Akbar.Theme.Muted
        Display.TextSize = 12
        Display.TextTruncate = Enum.TextTruncate.AtEnd
        Display.TextXAlignment = Enum.TextXAlignment.Right
        Display.Active = false
        Display.Parent = DropBtn

        local Chevron = Instance.new("ImageLabel")
        Chevron.AnchorPoint = Vector2.new(1, 0.5)
        Chevron.Position = UDim2.new(1, -14, 0.5, 0)
        Chevron.Size = UDim2.new(0, 16, 0, 16)
        Chevron.BackgroundTransparency = 1
        Chevron.Image = GetIcon("chevron-down")
        Chevron.ImageColor3 = Akbar.Theme.Muted
        Chevron.Active = false
        Chevron.Parent = DropBtn

        local DropClickArea = Instance.new("TextButton")
        DropClickArea.Size = UDim2.new(1, 0, 1, 0)
        DropClickArea.BackgroundTransparency = 1
        DropClickArea.Text = ""
        DropClickArea.ZIndex = 10
        DropClickArea.Parent = DropBtn

        local ListHolder = Instance.new("Frame")
        ListHolder.Position = UDim2.new(0, 8, 0, 46)
        ListHolder.Size = UDim2.new(1, -16, 0, 0)
        ListHolder.BackgroundTransparency = 1
        ListHolder.Parent = Frame

        local ListScroll = Instance.new("ScrollingFrame")
        ListScroll.Size = UDim2.new(1, 0, 1, 0)
        ListScroll.BackgroundTransparency = 1
        ListScroll.BorderSizePixel = 0
        ListScroll.ScrollBarThickness = 2
        ListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        ListScroll.Parent = ListHolder

        local ListLayout = Instance.new("UIListLayout")
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Padding = UDim.new(0, 4)
        ListLayout.Parent = ListScroll

        local function BuildOptions()
            for _, ch in ipairs(ListScroll:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
            for _, opt in ipairs(Dropdown.Options) do
                local isSelected = isMulti and table.find(Dropdown.Value, opt) or (Dropdown.Value == opt)
                local ob = Instance.new("TextButton")
                ob.Size = UDim2.new(1, -4, 0, 28)
                ob.BackgroundColor3 = isSelected and Akbar.Theme.SurfaceHover or Akbar.Theme.Surface
                ob.AutoButtonColor = false
                ob.Font = Enum.Font.Gotham
                ob.Text = "  " .. tostring(opt)
                ob.TextColor3 = isSelected and Akbar.Theme.Accent or Akbar.Theme.Muted
                ob.TextSize = 12
                ob.TextXAlignment = Enum.TextXAlignment.Left
                ob.ZIndex = 10
                ob.Parent = ListScroll
                Instance.new("UICorner", ob).CornerRadius = UDim.new(0, 6)

                ob.Activated:Connect(function()
                    if isMulti then
                        local found = table.find(Dropdown.Value, opt)
                        if found then table.remove(Dropdown.Value, found) else table.insert(Dropdown.Value, opt) end
                        Display.Text = #Dropdown.Value > 0 and table.concat(Dropdown.Value, ", ") or "None"
                        BuildOptions()
                        pcall(cb, Dropdown.Value)
                    else
                        Dropdown.Value = opt
                        Display.Text = tostring(opt)
                        BuildOptions()
                        Dropdown:SetOpen(false)
                        pcall(cb, opt)
                    end
                end)
            end
        end

        local function SetDropdownOpen(state)
            Dropdown.Open = state
            local maxShow = math.min(#Dropdown.Options, 5)
            local targetH = state and (50 + (maxShow * 32)) or 44
            Tween(Chevron, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Rotation = state and 180 or 0 })
            Tween(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, targetH) })
            ListHolder.Size = UDim2.new(1, -16, 0, state and (maxShow * 32) or 0)
        end

        DropClickArea.Activated:Connect(function() SetDropdownOpen(not Dropdown.Open) end)
        function Dropdown:SetOpen(st) SetDropdownOpen(st) end
        function Dropdown:Refresh(newOpts) Dropdown.Options = newOpts BuildOptions() end
        BuildOptions()

        if dropConfig.Flag and Window.Config then
            Window.Config:Register(dropConfig.Flag, function() return Dropdown.Value end, function(v) Dropdown.Value = v BuildOptions() end)
        end
        return Dropdown
    end

    -- 7. INPUT
    function targetScope:CreateInput(inputConfig)
        inputConfig = inputConfig or {}
        local cb = inputConfig.Callback or function() end
        local Input = { Value = inputConfig.CurrentValue or "" }

        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 48)
        Frame.BackgroundColor3 = Akbar.Theme.Surface2
        Frame.BackgroundTransparency = 0.5
        Frame.Parent = containerFrame
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

        local Title = Instance.new("TextLabel")
        Title.Position = UDim2.new(0, 14, 0, 0)
        Title.Size = UDim2.new(0.5, 0, 1, 0)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamMedium
        Title.Text = inputConfig.Name or "Input"
        Title.TextColor3 = Akbar.Theme.Text
        Title.TextSize = 13
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Active = false
        Title.Parent = Frame

        local BoxContainer = Instance.new("Frame")
        BoxContainer.AnchorPoint = Vector2.new(1, 0.5)
        BoxContainer.Position = UDim2.new(1, -14, 0.5, 0)
        BoxContainer.Size = UDim2.new(0.45, 0, 0, 30)
        BoxContainer.BackgroundColor3 = Akbar.Theme.Surface
        BoxContainer.Parent = Frame
        Instance.new("UICorner", BoxContainer).CornerRadius = UDim.new(0, 6)
        Instance.new("UIStroke", BoxContainer).Color = Akbar.Theme.Border

        local TextBox = Instance.new("TextBox")
        TextBox.Size = UDim2.new(1, -12, 1, 0)
        TextBox.Position = UDim2.new(0, 6, 0, 0)
        TextBox.BackgroundTransparency = 1
        TextBox.Font = Enum.Font.Gotham
        TextBox.PlaceholderText = inputConfig.PlaceholderText or "Type here..."
        TextBox.PlaceholderColor3 = Akbar.Theme.Muted
        TextBox.Text = Input.Value
        TextBox.TextColor3 = Akbar.Theme.Text
        TextBox.TextSize = 12
        TextBox.ClearTextOnFocus = false
        TextBox.Parent = BoxContainer

        if inputConfig.Numeric then
            TextBox:GetPropertyChangedSignal("Text"):Connect(function()
                TextBox.Text = TextBox.Text:gsub("%D+", "")
            end)
        end

        TextBox.FocusLost:Connect(function(enterPressed)
            Input.Value = TextBox.Text
            pcall(cb, TextBox.Text, enterPressed)
        end)

        function Input:Set(text) TextBox.Text = tostring(text) Input.Value = tostring(text) pcall(cb, TextBox.Text, false) end
        function Input:Get() return Input.Value end
        return Input
    end

    -- 8. KEYBIND
    function targetScope:CreateKeybind(kbConfig)
        kbConfig = kbConfig or {}
        local Keybind = { Value = kbConfig.CurrentKeybind or "None" }
        local isBinding = false
        local cb = kbConfig.Callback or function() end
        local onChanged = kbConfig.OnChanged or function() end

        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 44)
        Frame.BackgroundColor3 = Akbar.Theme.Surface2
        Frame.BackgroundTransparency = 0.5
        Frame.Parent = containerFrame
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

        local Title = Instance.new("TextLabel")
        Title.Position = UDim2.new(0, 14, 0, 0)
        Title.Size = UDim2.new(1, -120, 1, 0)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamMedium
        Title.Text = kbConfig.Name or "Keybind"
        Title.TextColor3 = Akbar.Theme.Text
        Title.TextSize = 13
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Active = false
        Title.Parent = Frame

        local BindBtn = Instance.new("TextButton")
        BindBtn.AnchorPoint = Vector2.new(1, 0.5)
        BindBtn.Position = UDim2.new(1, -14, 0.5, 0)
        BindBtn.Size = UDim2.new(0, 86, 0, 26)
        BindBtn.BackgroundColor3 = Akbar.Theme.Surface
        BindBtn.AutoButtonColor = false
        BindBtn.Font = Enum.Font.GothamBold
        BindBtn.Text = Keybind.Value
        BindBtn.TextColor3 = Akbar.Theme.Accent
        BindBtn.TextSize = 12
        BindBtn.ZIndex = 10
        BindBtn.Parent = Frame
        Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 6)

        BindBtn.Activated:Connect(function()
            isBinding = true
            BindBtn.Text = "..."
        end)

        table.insert(Window.Connections, UserInputService.InputBegan:Connect(function(inp, proc)
            if isBinding and not proc then
                if inp.UserInputType == Enum.UserInputType.Keyboard then
                    Keybind.Value = (inp.KeyCode == Enum.KeyCode.Escape) and "None" or inp.KeyCode.Name
                    BindBtn.Text = Keybind.Value
                    isBinding = false
                    pcall(onChanged, Keybind.Value)
                end
            elseif not proc and inp.KeyCode.Name == Keybind.Value and Keybind.Value ~= "None" then
                pcall(cb, Keybind.Value)
            end
        end))

        function Keybind:Set(key) Keybind.Value = key BindBtn.Text = key pcall(onChanged, key) end
        function Keybind:Get() return Keybind.Value end
        return Keybind
    end

    -- 9. COLOR PICKER
    function targetScope:CreateColorPicker(cpConfig)
        cpConfig = cpConfig or {}
        local defaultColor = cpConfig.Default or Color3.fromRGB(70, 130, 255)
        local hue, sat, val = Color3.toHSV(defaultColor)
        local ColorPicker = { Value = defaultColor, Open = false }
        local cb = cpConfig.Callback or function() end

        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 44)
        Frame.BackgroundColor3 = Akbar.Theme.Surface2
        Frame.BackgroundTransparency = 0.5
        Frame.ClipsDescendants = true
        Frame.Parent = containerFrame
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

        local MainBtn = Instance.new("Frame")
        MainBtn.Size = UDim2.new(1, 0, 0, 44)
        MainBtn.BackgroundTransparency = 1
        MainBtn.Parent = Frame

        local TitleLbl = Instance.new("TextLabel")
        TitleLbl.Position = UDim2.new(0, 14, 0, 0)
        TitleLbl.Size = UDim2.new(1, -80, 0, 44)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Font = Enum.Font.GothamMedium
        TitleLbl.Text = cpConfig.Name or "Color Picker"
        TitleLbl.TextColor3 = Akbar.Theme.Text
        TitleLbl.TextSize = 13
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
        TitleLbl.Active = false
        TitleLbl.Parent = MainBtn

        local PreviewBox = Instance.new("Frame")
        PreviewBox.AnchorPoint = Vector2.new(1, 0.5)
        PreviewBox.Position = UDim2.new(1, -14, 0.5, 0)
        PreviewBox.Size = UDim2.new(0, 36, 0, 22)
        PreviewBox.BackgroundColor3 = defaultColor
        PreviewBox.Parent = MainBtn
        Instance.new("UICorner", PreviewBox).CornerRadius = UDim.new(0, 6)
        Instance.new("UIStroke", PreviewBox).Color = Akbar.Theme.Border

        local MainClickArea = Instance.new("TextButton")
        MainClickArea.Size = UDim2.new(1, 0, 1, 0)
        MainClickArea.BackgroundTransparency = 1
        MainClickArea.Text = ""
        MainClickArea.ZIndex = 10
        MainClickArea.Parent = MainBtn

        local Canvas = Instance.new("Frame")
        Canvas.Position = UDim2.new(0, 12, 0, 50)
        Canvas.Size = UDim2.new(1, -24, 0, 110)
        Canvas.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        Canvas.ClipsDescendants = true
        Canvas.Parent = Frame
        Instance.new("UICorner", Canvas).CornerRadius = UDim.new(0, 6)

        local SatLayer = Instance.new("Frame")
        SatLayer.Size = UDim2.new(1, 0, 1, 0)
        SatLayer.BackgroundTransparency = 1
        SatLayer.Parent = Canvas
        local SatGrad = Instance.new("UIGradient")
        SatGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
        SatGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
        SatGrad.Parent = SatLayer

        local ValLayer = Instance.new("Frame")
        ValLayer.Size = UDim2.new(1, 0, 1, 0)
        ValLayer.BackgroundTransparency = 1
        ValLayer.Parent = Canvas
        local ValGrad = Instance.new("UIGradient")
        ValGrad.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
        ValGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})
        ValGrad.Rotation = 90
        ValGrad.Parent = ValLayer

        local PickerDot = Instance.new("Frame")
        PickerDot.Size = UDim2.new(0, 12, 0, 12)
        PickerDot.AnchorPoint = Vector2.new(0.5, 0.5)
        PickerDot.Position = UDim2.new(sat, 0, 1 - val, 0)
        PickerDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        PickerDot.ZIndex = 5
        PickerDot.Parent = Canvas
        Instance.new("UICorner", PickerDot).CornerRadius = UDim.new(1, 0)
        Instance.new("UIStroke", PickerDot).Color = Color3.fromRGB(0, 0, 0)

        local CanvasTouchArea = Instance.new("TextButton")
        CanvasTouchArea.Size = UDim2.new(1, 0, 1, 0)
        CanvasTouchArea.BackgroundTransparency = 1
        CanvasTouchArea.Text = ""
        CanvasTouchArea.ZIndex = 10
        CanvasTouchArea.Parent = Canvas

        local HueBar = Instance.new("Frame")
        HueBar.Position = UDim2.new(0, 12, 0, 168)
        HueBar.Size = UDim2.new(1, -24, 0, 16)
        HueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        HueBar.Parent = Frame
        Instance.new("UICorner", HueBar).CornerRadius = UDim.new(1, 0)

        local HueGrad = Instance.new("UIGradient")
        HueGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        })
        HueGrad.Parent = HueBar

        local HueCursor = Instance.new("Frame")
        HueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
        HueCursor.Position = UDim2.new(hue, 0, 0.5, 0)
        HueCursor.Size = UDim2.new(0, 6, 0, 20)
        HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        HueCursor.ZIndex = 5
        HueCursor.Parent = HueBar
        Instance.new("UICorner", HueCursor).CornerRadius = UDim.new(1, 0)
        Instance.new("UIStroke", HueCursor).Color = Color3.fromRGB(30, 30, 30)

        local HueTouchArea = Instance.new("TextButton")
        HueTouchArea.Size = UDim2.new(1, 0, 1, 0)
        HueTouchArea.BackgroundTransparency = 1
        HueTouchArea.Text = ""
        HueTouchArea.ZIndex = 10
        HueTouchArea.Parent = HueBar

        local function UpdateFromHSV()
            local col = Color3.fromHSV(hue, sat, val)
            ColorPicker.Value = col
            Canvas.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
            PickerDot.Position = UDim2.new(sat, 0, 1 - val, 0)
            HueCursor.Position = UDim2.new(hue, 0, 0.5, 0)
            PreviewBox.BackgroundColor3 = col
            pcall(cb, col)
        end

        local svDragging = false
        local svParent = FindParentScroll(containerFrame)

        CanvasTouchArea.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                svDragging = true
                if svParent then svParent.ScrollingEnabled = false end
                sat = math.clamp((input.Position.X - Canvas.AbsolutePosition.X) / Canvas.AbsoluteSize.X, 0, 1)
                val = 1 - math.clamp((input.Position.Y - Canvas.AbsolutePosition.Y) / Canvas.AbsoluteSize.Y, 0, 1)
                UpdateFromHSV()

                local mc, ec
                mc = UserInputService.InputChanged:Connect(function(mi)
                    if svDragging and (mi.UserInputType == Enum.UserInputType.MouseMovement or mi.UserInputType == Enum.UserInputType.Touch) then
                        sat = math.clamp((mi.Position.X - Canvas.AbsolutePosition.X) / Canvas.AbsoluteSize.X, 0, 1)
                        val = 1 - math.clamp((mi.Position.Y - Canvas.AbsolutePosition.Y) / Canvas.AbsoluteSize.Y, 0, 1)
                        UpdateFromHSV()
                    end
                end)
                ec = UserInputService.InputEnded:Connect(function(ei)
                    if ei.UserInputType == Enum.UserInputType.MouseButton1 or ei.UserInputType == Enum.UserInputType.Touch then
                        svDragging = false
                        if svParent then svParent.ScrollingEnabled = true end
                        if mc then mc:Disconnect() end
                        if ec then ec:Disconnect() end
                    end
                end)
            end
        end)

        local hueDragging = false
        HueTouchArea.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                hueDragging = true
                hue = math.clamp((input.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
                UpdateFromHSV()

                local mc, ec
                mc = UserInputService.InputChanged:Connect(function(mi)
                    if hueDragging and (mi.UserInputType == Enum.UserInputType.MouseMovement or mi.UserInputType == Enum.UserInputType.Touch) then
                        hue = math.clamp((mi.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
                        UpdateFromHSV()
                    end
                end)
                ec = UserInputService.InputEnded:Connect(function(ei)
                    if ei.UserInputType == Enum.UserInputType.MouseButton1 or ei.UserInputType == Enum.UserInputType.Touch then
                        hueDragging = false
                        if mc then mc:Disconnect() end
                        if ec then ec:Disconnect() end
                    end
                end)
            end
        end)

        MainClickArea.Activated:Connect(function()
            ColorPicker.Open = not ColorPicker.Open
            Tween(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = ColorPicker.Open and UDim2.new(1, 0, 0, 196) or UDim2.new(1, 0, 0, 44)
            })
        end)

        function ColorPicker:Set(col)
            hue, sat, val = Color3.toHSV(col)
            UpdateFromHSV()
        end
        function ColorPicker:Get() return ColorPicker.Value end
        return ColorPicker
    end

    -- 10. PROGRESS BAR
    function targetScope:CreateProgress(progConfig)
        progConfig = progConfig or {}
        local fmt = progConfig.Format or function(v) return math.floor(v * 100) .. "%" end
        local Progress = { Value = progConfig.CurrentValue or 0 }

        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 44)
        Frame.BackgroundColor3 = Akbar.Theme.Surface2
        Frame.BackgroundTransparency = 0.5
        Frame.Parent = containerFrame
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

        local Title = Instance.new("TextLabel")
        Title.Position = UDim2.new(0, 14, 0, 8)
        Title.Size = UDim2.new(1, -70, 0, 14)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamMedium
        Title.Text = progConfig.Name or "Progress"
        Title.TextColor3 = Akbar.Theme.Text
        Title.TextSize = 12
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Active = false
        Title.Parent = Frame

        local ValueText = Instance.new("TextLabel")
        ValueText.AnchorPoint = Vector2.new(1, 0)
        ValueText.Position = UDim2.new(1, -14, 0, 8)
        ValueText.Size = UDim2.new(0, 60, 0, 14)
        ValueText.BackgroundTransparency = 1
        ValueText.Font = Enum.Font.GothamBold
        ValueText.Text = fmt(Progress.Value)
        ValueText.TextColor3 = Akbar.Theme.Accent
        ValueText.TextSize = 11
        ValueText.TextXAlignment = Enum.TextXAlignment.Right
        ValueText.Active = false
        ValueText.Parent = Frame

        local Track = Instance.new("Frame")
        Track.Position = UDim2.new(0, 14, 0, 28)
        Track.Size = UDim2.new(1, -28, 0, 6)
        Track.BackgroundColor3 = Akbar.Theme.Border
        Track.Parent = Frame
        Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new(math.clamp(Progress.Value, 0, 1), 0, 1, 0)
        Fill.BackgroundColor3 = Akbar.Theme.Accent
        Fill.BorderSizePixel = 0
        Fill.Parent = Track
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

        function Progress:Set(val)
            val = math.clamp(val, 0, 1)
            Progress.Value = val
            ValueText.Text = fmt(val)
            Tween(Fill, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(val, 0, 1, 0) })
        end
        return Progress
    end

    -- 11. LABEL
    function targetScope:CreateLabel(labelConfig)
        labelConfig = labelConfig or {}
        local Label = { Value = labelConfig.Text or "Label" }

        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 32)
        Frame.BackgroundColor3 = Akbar.Theme.Surface2
        Frame.BackgroundTransparency = 0.7
        Frame.Parent = containerFrame
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

        local LText = Instance.new("TextLabel")
        LText.Size = UDim2.new(1, -24, 1, 0)
        LText.Position = UDim2.new(0, 12, 0, 0)
        LText.BackgroundTransparency = 1
        LText.Font = Enum.Font.Gotham
        LText.Text = Label.Value
        LText.TextColor3 = Akbar.Theme.Text
        LText.TextSize = 12
        LText.TextXAlignment = Enum.TextXAlignment.Left
        LText.Active = false
        LText.Parent = Frame

        if labelConfig.UpdateRate and labelConfig.Update then
            task.spawn(function()
                while Frame.Parent do
                    task.wait(labelConfig.UpdateRate)
                    local newText = labelConfig.Update()
                    if newText then LText.Text = tostring(newText) Label.Value = tostring(newText) end
                end
            end)
        end

        function Label:Set(newT) Label.Value = tostring(newT) LText.Text = tostring(newT) end
        return Label
    end

    -- 12. PARAGRAPH
    function targetScope:CreateParagraph(paraConfig)
        paraConfig = paraConfig or {}
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, 0, 0, 0)
        Frame.AutomaticSize = Enum.AutomaticSize.Y
        Frame.BackgroundColor3 = Akbar.Theme.Surface2
        Frame.BackgroundTransparency = 0.6
        Frame.Parent = containerFrame
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

        local Padding = Instance.new("UIPadding")
        Padding.PaddingLeft = UDim.new(0, 14)
        Padding.PaddingRight = UDim.new(0, 14)
        Padding.PaddingTop = UDim.new(0, 10)
        Padding.PaddingBottom = UDim.new(0, 10)
        Padding.Parent = Frame

        local Layout = Instance.new("UIListLayout")
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 4)
        Layout.Parent = Frame

        local TTitle = Instance.new("TextLabel")
        TTitle.Size = UDim2.new(1, 0, 0, 18)
        TTitle.BackgroundTransparency = 1
        TTitle.Font = Enum.Font.GothamBold
        TTitle.Text = paraConfig.Title or "Title"
        TTitle.TextColor3 = Akbar.Theme.Text
        TTitle.TextSize = 13
        TTitle.TextXAlignment = Enum.TextXAlignment.Left
        TTitle.Active = false
        TTitle.Parent = Frame

        local TDesc = Instance.new("TextLabel")
        TDesc.Size = UDim2.new(1, 0, 0, 0)
        TDesc.AutomaticSize = Enum.AutomaticSize.Y
        TDesc.BackgroundTransparency = 1
        TDesc.Font = Enum.Font.Gotham
        TDesc.Text = paraConfig.Content or ""
        TDesc.TextColor3 = Akbar.Theme.Muted
        TDesc.TextSize = 12
        TDesc.TextWrapped = true
        TDesc.TextXAlignment = Enum.TextXAlignment.Left
        TDesc.Active = false
        TDesc.Parent = Frame

        return { Destroy = function() Frame:Destroy() end }
    end

    -- 13. SECTION & DIVIDER
    function targetScope:CreateSection(secName)
        local SecLabel = Instance.new("TextLabel")
        SecLabel.Size = UDim2.new(1, 0, 0, 24)
        SecLabel.BackgroundTransparency = 1
        SecLabel.Font = Enum.Font.GothamBold
        SecLabel.Text = string.upper(secName or "Section")
        SecLabel.TextColor3 = Akbar.Theme.Accent
        SecLabel.TextSize = 11
        SecLabel.TextXAlignment = Enum.TextXAlignment.Left
        SecLabel.Active = false
        SecLabel.Parent = containerFrame
        return SecLabel
    end

    function targetScope:CreateDivider()
        local Line = Instance.new("Frame")
        Line.Size = UDim2.new(1, 0, 0, 1)
        Line.BackgroundColor3 = Akbar.Theme.Border
        Line.BackgroundTransparency = 0.4
        Line.BorderSizePixel = 0
        Line.Parent = containerFrame
        return Line
    end

    -- Component Aliases
    targetScope.Collapsible = targetScope.CreateCollapsible
    targetScope.Toggle = targetScope.CreateToggle
    targetScope.Button = targetScope.CreateButton
    targetScope.Slider = targetScope.CreateSlider
    targetScope.Stepper = targetScope.CreateStepper
    targetScope.Dropdown = targetScope.CreateDropdown
    targetScope.Input = targetScope.CreateInput
    targetScope.Keybind = targetScope.CreateKeybind
    targetScope.ColorPicker = targetScope.CreateColorPicker
    targetScope.Progress = targetScope.CreateProgress
    targetScope.Label = targetScope.CreateLabel
    targetScope.Paragraph = targetScope.CreateParagraph
    targetScope.Section = targetScope.CreateSection
    targetScope.Divider = targetScope.CreateDivider
end

return Akbar

--[[
    AKBAR UI — Modern Dark Glassmorphism UI Framework (Enhanced Edition)
    Brand: AKBAR UI / King Akbar
    Architecture: Modular, Event-Cleaned, Mobile & PC Responsive
]]

local Akbar = {}
Akbar.__index = Akbar
Akbar.Version = "1.1.0"
Akbar.AnimationEnabled = true

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Theme Tokens
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

-- Built-in Lucide & System Icon Registry
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
    if string.find(name, "rbxassetid://") or string.find(name, "http") then
        return name
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
    local success, _ = pcall(function()
        gui.Parent = target
    end)
    if not success then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
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

-- Akbar Theme API
function Akbar:SetTheme(newTheme)
    for key, val in pairs(newTheme) do
        if Akbar.Theme[key] ~= nil then
            Akbar.Theme[key] = val
        end
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
    local WindowSubtitle = config.LoadingSubtitle or "King Akbar"
    local WindowIcon = config.Icon or "crown"
    local ToggleKey = config.ToggleUIKeybind or "RightControl"
    local WindowSize = config.Size or UDim2.fromOffset(760, 520)
    local MinSize = config.MinSize or Vector2.new(480, 360)
    local MaxSize = config.MaxSize or Vector2.new(1100, 750)
    local MaxNotifs = config.MaxNotifications or 5
    local KeepOnScreen = config.KeepOnScreen ~= false
    local AccordionDefault = config.Accordion or false

    local Window = {
        Tabs = {},
        ActiveTab = nil,
        Connections = {},
        Collapsibles = {},
        Accordion = AccordionDefault,
        SearchEnabled = true,
        Size = WindowSize,
        MinSize = MinSize,
        MaxSize = MaxSize,
        IsMinimized = false,
        IsMaximized = false,
        PreMaximizeSize = WindowSize,
        PreMaximizePos = UDim2.new(0.5, 0, 0.5, 0),
        Config = ConfigManager.new(
            config.ConfigurationSaving and config.ConfigurationSaving.FolderName or "AkbarUI",
            config.ConfigurationSaving and config.ConfigurationSaving.FileName or "default"
        )
    }

    -- Root ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AkbarUI_" .. WindowName:gsub("%s+", "")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    SafeParentGui(ScreenGui, config.Parent)
    Window.ScreenGui = ScreenGui

    -- Main Shadow & Container
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
    MainShadow.Parent = ScreenGui
    Window.MainShadow = MainShadow

    local MainWindow = Instance.new("Frame")
    MainWindow.Name = "MainWindow"
    MainWindow.Size = UDim2.new(1, 0, 1, 0)
    MainWindow.BackgroundColor3 = Akbar.Theme.Background
    MainWindow.BackgroundTransparency = Akbar.Theme.GlassTransparency
    MainWindow.ClipsDescendants = false
    MainWindow.Parent = MainShadow
    Window.MainWindow = MainWindow

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainWindow

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Akbar.Theme.Border
    MainStroke.Transparency = 0.3
    MainStroke.Thickness = 1.2
    MainStroke.Parent = MainWindow

    -- Notifications Layer
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
    Window.NotificationHolder = NotificationHolder
    Window.Notifications = {}

    -- Header (Top Bar)
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 52)
    Header.BackgroundColor3 = Akbar.Theme.Surface
    Header.BackgroundTransparency = Akbar.Theme.GlassTransparency
    Header.Parent = MainWindow

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 12)
    HeaderCorner.Parent = Header

    local HeaderMask = Instance.new("Frame")
    HeaderMask.Name = "Mask"
    HeaderMask.AnchorPoint = Vector2.new(0, 1)
    HeaderMask.Position = UDim2.new(0, 0, 1, 0)
    HeaderMask.Size = UDim2.new(1, 0, 0, 12)
    HeaderMask.BackgroundColor3 = Akbar.Theme.Surface
    HeaderMask.BackgroundTransparency = Akbar.Theme.GlassTransparency
    HeaderMask.BorderSizePixel = 0
    HeaderMask.Parent = Header

    local HeaderLine = Instance.new("Frame")
    HeaderLine.Name = "Divider"
    HeaderLine.AnchorPoint = Vector2.new(0, 1)
    HeaderLine.Position = UDim2.new(0, 0, 1, 0)
    HeaderLine.Size = UDim2.new(1, 0, 0, 1)
    HeaderLine.BackgroundColor3 = Akbar.Theme.Border
    HeaderLine.BorderSizePixel = 0
    HeaderLine.Parent = Header

    -- Header Left (Logo + Titles)
    local BrandIcon = Instance.new("ImageLabel")
    BrandIcon.Name = "BrandIcon"
    BrandIcon.Position = UDim2.new(0, 16, 0.5, -12)
    BrandIcon.Size = UDim2.new(0, 24, 0, 24)
    BrandIcon.BackgroundTransparency = 1
    BrandIcon.Image = GetIcon(WindowIcon)
    BrandIcon.ImageColor3 = Akbar.Theme.Accent
    BrandIcon.Parent = Header
    Window.BrandIcon = BrandIcon

    local TitleContainer = Instance.new("Frame")
    TitleContainer.Position = UDim2.new(0, 48, 0, 8)
    TitleContainer.Size = UDim2.new(0, 250, 0, 36)
    TitleContainer.BackgroundTransparency = 1
    TitleContainer.Parent = Header

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, 0, 0, 18)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = WindowName
    TitleLabel.TextColor3 = Akbar.Theme.Text
    TitleLabel.TextSize = 15
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleContainer

    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Name = "Subtitle"
    SubtitleLabel.Position = UDim2.new(0, 0, 0, 18)
    SubtitleLabel.Size = UDim2.new(1, 0, 0, 16)
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Font = Enum.Font.Gotham
    SubtitleLabel.Text = WindowSubtitle
    SubtitleLabel.TextColor3 = Akbar.Theme.Muted
    SubtitleLabel.TextSize = 12
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubtitleLabel.Parent = TitleContainer

    -- Header Right Window Controls
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
        btn.BackgroundColor3 = Akbar.Theme.Surface2
        btn.BackgroundTransparency = 0.5
        btn.AutoButtonColor = false
        btn.Text = ""
        btn.Parent = Controls

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 7)
        btnCorner.Parent = btn

        local btnIcon = Instance.new("ImageLabel")
        btnIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        btnIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
        btnIcon.Size = UDim2.new(0, 14, 0, 14)
        btnIcon.BackgroundTransparency = 1
        btnIcon.Image = GetIcon(iconName)
        btnIcon.ImageColor3 = Akbar.Theme.Muted
        btnIcon.Parent = btn

        btn.MouseEnter:Connect(function()
            Tween(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundColor3 = isClose and Akbar.Theme.Error or Akbar.Theme.SurfaceHover,
                BackgroundTransparency = 0.1
            })
            Tween(btnIcon, TweenInfo.new(0.2), { ImageColor3 = Color3.fromRGB(255, 255, 255) })
        end)

        btn.MouseLeave:Connect(function()
            Tween(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundColor3 = Akbar.Theme.Surface2,
                BackgroundTransparency = 0.5
            })
            Tween(btnIcon, TweenInfo.new(0.2), { ImageColor3 = Akbar.Theme.Muted })
        end)

        return btn
    end

    local MinBtn = CreateHeaderButton("minus", false)
    local MaxBtn = CreateHeaderButton("maximize", false)
    local CloseBtn = CreateHeaderButton("x", true)

    -- Window Body Container (Sidebar + Content)
    local BodyContainer = Instance.new("Frame")
    BodyContainer.Name = "BodyContainer"
    BodyContainer.Position = UDim2.new(0, 0, 0, 52)
    BodyContainer.Size = UDim2.new(1, 0, 1, -52)
    BodyContainer.BackgroundTransparency = 1
    BodyContainer.ClipsDescendants = true
    BodyContainer.Parent = MainWindow
    Window.BodyContainer = BodyContainer

    -- Sidebar (Left)
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 220, 1, 0)
    Sidebar.BackgroundColor3 = Akbar.Theme.Surface
    Sidebar.BackgroundTransparency = 0.3
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = BodyContainer
    Window.Sidebar = Sidebar

    local SidebarRightBorder = Instance.new("Frame")
    SidebarRightBorder.Name = "Border"
    SidebarRightBorder.AnchorPoint = Vector2.new(1, 0)
    SidebarRightBorder.Position = UDim2.new(1, 0, 0, 0)
    SidebarRightBorder.Size = UDim2.new(0, 1, 1, 0)
    SidebarRightBorder.BackgroundColor3 = Akbar.Theme.Border
    SidebarRightBorder.BorderSizePixel = 0
    SidebarRightBorder.Parent = Sidebar

    -- Sidebar Search Box
    local SearchContainer = Instance.new("Frame")
    SearchContainer.Name = "SearchBox"
    SearchContainer.Position = UDim2.new(0, 12, 0, 12)
    SearchContainer.Size = UDim2.new(1, -24, 0, 36)
    SearchContainer.BackgroundColor3 = Akbar.Theme.Surface2
    SearchContainer.BackgroundTransparency = 0.4
    SearchContainer.Parent = Sidebar

    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 8)
    SearchCorner.Parent = SearchContainer

    local SearchStroke = Instance.new("UIStroke")
    SearchStroke.Color = Akbar.Theme.Border
    SearchStroke.Transparency = 0.5
    SearchStroke.Thickness = 1
    SearchStroke.Parent = SearchContainer

    local SearchIcon = Instance.new("ImageLabel")
    SearchIcon.Position = UDim2.new(0, 10, 0.5, -8)
    SearchIcon.Size = UDim2.new(0, 16, 0, 16)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Image = GetIcon("search")
    SearchIcon.ImageColor3 = Akbar.Theme.Muted
    SearchIcon.Parent = SearchContainer

    local SearchInput = Instance.new("TextBox")
    SearchInput.Name = "Input"
    SearchInput.Position = UDim2.new(0, 34, 0, 0)
    SearchInput.Size = UDim2.new(1, -40, 1, 0)
    SearchInput.BackgroundTransparency = 1
    SearchInput.Font = Enum.Font.Gotham
    SearchInput.PlaceholderText = "Search..."
    SearchInput.PlaceholderColor3 = Akbar.Theme.Muted
    SearchInput.Text = ""
    SearchInput.TextColor3 = Akbar.Theme.Text
    SearchInput.TextSize = 13
    SearchInput.TextXAlignment = Enum.TextXAlignment.Left
    SearchInput.ClearTextOnFocus = false
    SearchInput.Parent = SearchContainer

    -- Sidebar Tabs Scroll
    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Name = "TabScroll"
    TabScroll.Position = UDim2.new(0, 8, 0, 58)
    TabScroll.Size = UDim2.new(1, -16, 1, -68)
    TabScroll.BackgroundTransparency = 1
    TabScroll.BorderSizePixel = 0
    TabScroll.ScrollBarThickness = 2
    TabScroll.ScrollBarImageColor3 = Akbar.Theme.Border
    TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabScroll.Parent = Sidebar

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 4)
    TabLayout.Parent = TabScroll

    -- Content Area (Right)
    local ContentHolder = Instance.new("Frame")
    ContentHolder.Name = "ContentArea"
    ContentHolder.Position = UDim2.new(0, 220, 0, 0)
    ContentHolder.Size = UDim2.new(1, -220, 1, 0)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.Parent = BodyContainer
    Window.ContentHolder = ContentHolder

    -- Header inside Content
    local ContentHeader = Instance.new("Frame")
    ContentHeader.Name = "ContentHeader"
    ContentHeader.Size = UDim2.new(1, 0, 0, 58)
    ContentHeader.BackgroundTransparency = 1
    ContentHeader.Parent = ContentHolder

    local ContentHeaderPadding = Instance.new("UIPadding")
    ContentHeaderPadding.PaddingLeft = UDim.new(0, 24)
    ContentHeaderPadding.PaddingRight = UDim.new(0, 24)
    ContentHeaderPadding.PaddingTop = UDim.new(0, 12)
    ContentHeaderPadding.Parent = ContentHeader

    local TabHeading = Instance.new("TextLabel")
    TabHeading.Name = "Heading"
    TabHeading.Size = UDim2.new(1, 0, 0, 22)
    TabHeading.BackgroundTransparency = 1
    TabHeading.Font = Enum.Font.GothamBold
    TabHeading.Text = "Tab"
    TabHeading.TextColor3 = Akbar.Theme.Text
    TabHeading.TextSize = 18
    TabHeading.TextXAlignment = Enum.TextXAlignment.Left
    TabHeading.Parent = ContentHeader

    local TabDesc = Instance.new("TextLabel")
    TabDesc.Name = "Description"
    TabDesc.Position = UDim2.new(0, 0, 0, 22)
    TabDesc.Size = UDim2.new(1, 0, 0, 16)
    TabDesc.BackgroundTransparency = 1
    TabDesc.Font = Enum.Font.Gotham
    TabDesc.Text = "Description"
    TabDesc.TextColor3 = Akbar.Theme.Muted
    TabDesc.TextSize = 12
    TabDesc.TextXAlignment = Enum.TextXAlignment.Left
    TabDesc.Parent = ContentHeader

    local PagesContainer = Instance.new("Frame")
    PagesContainer.Name = "Pages"
    PagesContainer.Position = UDim2.new(0, 0, 0, 58)
    PagesContainer.Size = UDim2.new(1, 0, 1, -58)
    PagesContainer.BackgroundTransparency = 1
    PagesContainer.Parent = ContentHolder
    Window.PagesContainer = PagesContainer

    -- Resize Grip
    local ResizeGrip = Instance.new("ImageButton")
    ResizeGrip.Name = "ResizeGrip"
    ResizeGrip.AnchorPoint = Vector2.new(1, 1)
    ResizeGrip.Position = UDim2.new(1, -2, 1, -2)
    ResizeGrip.Size = UDim2.new(0, 16, 0, 16)
    ResizeGrip.BackgroundTransparency = 1
    ResizeGrip.Image = "rbxassetid://7734053426"
    ResizeGrip.ImageColor3 = Akbar.Theme.Muted
    ResizeGrip.ImageTransparency = 0.5
    ResizeGrip.ZIndex = 20
    ResizeGrip.Parent = MainWindow

    -- Viewport Clamping System
    local function ClampToViewport()
        if not KeepOnScreen then return end
        local camera = workspace.CurrentCamera
        local viewportSize = camera and camera.ViewportSize or Vector2.new(1920, 1080)
        
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

    -- Drag System (Desktop Mouse + Mobile Touch)
    local isDragging = false
    local dragStart = nil
    local startPos = nil

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

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainShadow.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            if KeepOnScreen then ClampToViewport() end
        end
    end)

    -- Resize System
    local isResizing = false
    local resizeStart = nil
    local startSize = nil

    ResizeGrip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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

    UserInputService.InputChanged:Connect(function(input)
        if isResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - resizeStart
            local newX = math.clamp(startSize.X + delta.X, Window.MinSize.X, Window.MaxSize.X)
            local newY = math.clamp(startSize.Y + delta.Y, Window.MinSize.Y, Window.MaxSize.Y)
            MainShadow.Size = UDim2.fromOffset(newX, newY)
            Window.Size = MainShadow.Size
            ClampToViewport()
        end
    end)

    -- Window Controls Behavior
    MinBtn.MouseButton1Click:Connect(function()
        Window.IsMinimized = not Window.IsMinimized
        if Window.IsMinimized then
            Tween(BodyContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, 0) })
            Tween(MainShadow, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(Window.Size.X.Offset, 52) })
        else
            Tween(MainShadow, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = Window.Size })
            Tween(BodyContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 1, -52) })
        end
    end)

    MaxBtn.MouseButton1Click:Connect(function()
        Window.IsMaximized = not Window.IsMaximized
        local camera = workspace.CurrentCamera
        local vSize = camera and camera.ViewportSize or Vector2.new(1920, 1080)

        if Window.IsMaximized then
            Window.PreMaximizeSize = MainShadow.Size
            Window.PreMaximizePos = MainShadow.Position
            Tween(MainShadow, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(vSize.X - 40, vSize.Y - 60),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            })
        else
            Tween(MainShadow, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = Window.PreMaximizeSize,
                Position = Window.PreMaximizePos
            })
        end
    end)

    -- Ubah close agar menyembunyikan frame agar bisa dibuka lagi via Top-Left Icon
    CloseBtn.MouseButton1Click:Connect(function()
        MainShadow.Visible = false
    end)

    -- Search Tab Filtering
    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(SearchInput.Text)
        for _, tab in ipairs(Window.Tabs) do
            if tab.Button then
                if query == "" or string.find(string.lower(tab.Name), query) then
                    tab.Button.Visible = true
                else
                    tab.Button.Visible = false
                end
            end
        end
    end)

    -- 🌟 FLOATING TOGGLE ICON (POJOK KIRI ATAS - MOBILE & PC FRIENDLY)
    local OpenButton = nil
    if config.OpenButton ~= false then
        local btnConfig = config.OpenButton or {}
        local FloatBtn = Instance.new("ImageButton")
        FloatBtn.Name = "Akbar_ToggleIcon"
        FloatBtn.Size = UDim2.new(0, 42, 0, 42)
        -- Posisi default di pojok kiri atas
        FloatBtn.Position = btnConfig.Position or UDim2.new(0, 16, 0, 16)
        FloatBtn.BackgroundColor3 = Akbar.Theme.Surface
        FloatBtn.BackgroundTransparency = 0.2
        FloatBtn.Image = GetIcon(btnConfig.Icon or WindowIcon or "crown")
        FloatBtn.ImageColor3 = Akbar.Theme.Accent
        FloatBtn.Visible = true
        FloatBtn.ZIndex = 120
        SafeParentGui(FloatBtn, ScreenGui)

        local FloatCorner = Instance.new("UICorner")
        FloatCorner.CornerRadius = UDim.new(0, 10)
        FloatCorner.Parent = FloatBtn

        local FloatStroke = Instance.new("UIStroke")
        FloatStroke.Color = Akbar.Theme.BorderLight
        FloatStroke.Transparency = 0.3
        FloatStroke.Thickness = 1.2
        FloatStroke.Parent = FloatBtn

        -- Sistem Dragging untuk Icon
        local fDragging = false
        local fStart = nil
        local fPos = nil
        local hasMoved = false

        FloatBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                fDragging = true
                hasMoved = false
                fStart = input.Position
                fPos = FloatBtn.Position

                local releaseConn
                releaseConn = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        fDragging = false
                        if releaseConn then releaseConn:Disconnect() end
                    end
                end)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if fDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - fStart
                if math.abs(delta.X) > 4 or math.abs(delta.Y) > 4 then
                    hasMoved = true
                end
                FloatBtn.Position = UDim2.new(
                    fPos.X.Scale,
                    fPos.X.Offset + delta.X,
                    fPos.Y.Scale,
                    fPos.Y.Offset + delta.Y
                )
            end
        end)

        -- Fungsi Toggle Buka / Tutup dengan Animasi Halus
        local function ToggleWindow()
            local willOpen = not MainShadow.Visible
            
            Tween(FloatBtn, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 36, 0, 36) })
            task.delay(0.1, function()
                Tween(FloatBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(0, 42, 0, 42) })
            end)

            if willOpen then
                MainShadow.Visible = true
                MainShadow.Size = UDim2.fromOffset(Window.Size.X.Offset * 0.92, Window.Size.Y.Offset * 0.92)
                Tween(MainShadow, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Size = Window.Size
                })
            else
                local closeTween = Tween(MainShadow, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                    Size = UDim2.fromOffset(Window.Size.X.Offset * 0.88, Window.Size.Y.Offset * 0.88)
                })
                if closeTween then closeTween.Completed:Wait() end
                MainShadow.Visible = false
            end
        end

        FloatBtn.MouseButton1Click:Connect(function()
            if not hasMoved then
                ToggleWindow()
            end
        end)

        OpenButton = FloatBtn
    end
    Window.OpenButton = OpenButton

    -- Keybind Toggle Window
    table.insert(Window.Connections, UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode.Name == ToggleKey then
            MainShadow.Visible = not MainShadow.Visible
        end
    end))

    -- Loading Screen Sequence
    if config.Loading and config.Loading.Enabled then
        local lData = config.Loading
        local LoadFrame = Instance.new("Frame")
        LoadFrame.Name = "LoadingScreen"
        LoadFrame.Size = UDim2.new(1, 0, 1, 0)
        LoadFrame.BackgroundColor3 = Akbar.Theme.Background
        LoadFrame.ZIndex = 100
        LoadFrame.Parent = MainWindow

        local LoadCorner = Instance.new("UICorner")
        LoadCorner.CornerRadius = UDim.new(0, 12)
        LoadCorner.Parent = LoadFrame

        local LoadIcon = Instance.new("ImageLabel")
        LoadIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        LoadIcon.Position = UDim2.new(0.5, 0, 0.4, 0)
        LoadIcon.Size = UDim2.new(0, 54, 0, 54)
        LoadIcon.BackgroundTransparency = 1
        LoadIcon.Image = GetIcon(WindowIcon)
        LoadIcon.ImageColor3 = Akbar.Theme.Accent
        LoadIcon.Parent = LoadFrame

        local LoadTitle = Instance.new("TextLabel")
        LoadTitle.AnchorPoint = Vector2.new(0.5, 0)
        LoadTitle.Position = UDim2.new(0.5, 0, 0.4, 36)
        LoadTitle.Size = UDim2.new(1, 0, 0, 24)
        LoadTitle.BackgroundTransparency = 1
        LoadTitle.Font = Enum.Font.GothamBold
        LoadTitle.Text = lData.Title or "AKBAR UI"
        LoadTitle.TextColor3 = Akbar.Theme.Text
        LoadTitle.TextSize = 20
        LoadTitle.Parent = LoadFrame

        local LoadStatus = Instance.new("TextLabel")
        LoadStatus.AnchorPoint = Vector2.new(0.5, 0)
        LoadStatus.Position = UDim2.new(0.5, 0, 0.4, 64)
        LoadStatus.Size = UDim2.new(1, 0, 0, 18)
        LoadStatus.BackgroundTransparency = 1
        LoadStatus.Font = Enum.Font.Gotham
        LoadStatus.Text = lData.Text or "Starting..."
        LoadStatus.TextColor3 = Akbar.Theme.Muted
        LoadStatus.TextSize = 13
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

            Tween(LoadFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 1 })
            Tween(LoadIcon, TweenInfo.new(0.3), { ImageTransparency = 1 })
            Tween(LoadTitle, TweenInfo.new(0.3), { TextTransparency = 1 })
            local fadeOut = Tween(LoadStatus, TweenInfo.new(0.3), { TextTransparency = 1 })
            if fadeOut then fadeOut.Completed:Wait() end
            LoadFrame:Destroy()
        end)
    end

    -- Window Methods
    function Window:SetSize(size)
        MainShadow.Size = size
        Window.Size = size
        ClampToViewport()
    end

    function Window:GetSize()
        return MainShadow.Size
    end

    function Window:SetMinSize(min)
        Window.MinSize = min
    end

    function Window:SetMaxSize(max)
        Window.MaxSize = max
    end

    function Window:SetSearchEnabled(enabled)
        Window.SearchEnabled = enabled
        SearchContainer.Visible = enabled
        TabScroll.Position = enabled and UDim2.new(0, 8, 0, 58) or UDim2.new(0, 8, 0, 12)
        TabScroll.Size = enabled and UDim2.new(1, -16, 1, -68) or UDim2.new(1, -16, 1, -24)
    end

    function Window:SetAccordion(state)
        Window.Accordion = state and true or false
    end

    function Window:SetIcon(iconAsset)
        BrandIcon.Image = GetIcon(iconAsset)
    end

    function Window:SaveConfig(name)
        Window.Config:Save(name)
    end

    function Window:LoadConfig(name)
        return Window.Config:Load(name)
    end

    function Window:DeleteConfig(name)
        Window.Config:Delete(name)
    end

    function Window:ListConfigs()
        return Window.Config:List()
    end

    function Window:Notify(notifData)
        notifData = notifData or {}
        local title = notifData.Title or "Akbar UI"
        local content = notifData.Content or ""
        local duration = notifData.Duration or 3.5
        local icon = notifData.Icon or "info"

        if #Window.Notifications >= MaxNotifs then
            local oldest = table.remove(Window.Notifications, 1)
            if oldest and oldest.Frame then
                oldest.Frame:Destroy()
            end
        end

        local Card = Instance.new("Frame")
        Card.Name = "NotifCard"
        Card.Size = UDim2.new(1, 0, 0, 68)
        Card.BackgroundColor3 = Akbar.Theme.Surface
        Card.BackgroundTransparency = 0.15
        Card.ClipsDescendants = true
        Card.Position = UDim2.new(1, 40, 0, 0)
        Card.Parent = NotificationHolder

        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, 10)
        CardCorner.Parent = Card

        local CardStroke = Instance.new("UIStroke")
        CardStroke.Color = Akbar.Theme.Border
        CardStroke.Thickness = 1
        CardStroke.Parent = Card

        local IconImg = Instance.new("ImageLabel")
        IconImg.Position = UDim2.new(0, 14, 0, 14)
        IconImg.Size = UDim2.new(0, 20, 0, 20)
        IconImg.BackgroundTransparency = 1
        IconImg.Image = GetIcon(icon)
        IconImg.ImageColor3 = Akbar.Theme.Accent
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
        DescText.Parent = Card

        local ProgressBar = Instance.new("Frame")
        ProgressBar.Name = "Progress"
        ProgressBar.AnchorPoint = Vector2.new(0, 1)
        ProgressBar.Position = UDim2.new(0, 0, 1, 0)
        ProgressBar.Size = UDim2.new(1, 0, 0, 2)
        ProgressBar.BackgroundColor3 = Akbar.Theme.Accent
        ProgressBar.BorderSizePixel = 0
        ProgressBar.Parent = Card

        local notifRef = { Frame = Card }
        table.insert(Window.Notifications, notifRef)

        Tween(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0)
        })
        Tween(ProgressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 0, 2)
        })

        task.delay(duration, function()
            local slideOut = Tween(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, 40, 0, 0)
            })
            if slideOut then slideOut.Completed:Wait() end
            for i, n in ipairs(Window.Notifications) do
                if n == notifRef then
                    table.remove(Window.Notifications, i)
                    break
                end
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
        ModalBackdrop.Name = "ModalBackdrop"
        ModalBackdrop.Size = UDim2.new(1, 0, 1, 0)
        ModalBackdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        ModalBackdrop.BackgroundTransparency = 1
        ModalBackdrop.Text = ""
        ModalBackdrop.ZIndex = 80
        ModalBackdrop.Parent = MainWindow

        local ModalCorner = Instance.new("UICorner")
        ModalCorner.CornerRadius = UDim.new(0, 12)
        ModalCorner.Parent = ModalBackdrop

        local DialogBox = Instance.new("Frame")
        DialogBox.AnchorPoint = Vector2.new(0.5, 0.5)
        DialogBox.Position = UDim2.new(0.5, 0, 0.5, 0)
        DialogBox.Size = UDim2.new(0, 340, 0, 170)
        DialogBox.BackgroundColor3 = Akbar.Theme.Surface
        DialogBox.ClipsDescendants = true
        DialogBox.Parent = ModalBackdrop

        local DialogCorner = Instance.new("UICorner")
        DialogCorner.CornerRadius = UDim.new(0, 10)
        DialogCorner.Parent = DialogBox

        local DialogStroke = Instance.new("UIStroke")
        DialogStroke.Color = Akbar.Theme.Border
        DialogStroke.Parent = DialogBox

        local DTitle = Instance.new("TextLabel")
        DTitle.Position = UDim2.new(0, 20, 0, 18)
        DTitle.Size = UDim2.new(1, -40, 0, 22)
        DTitle.BackgroundTransparency = 1
        DTitle.Font = Enum.Font.GothamBold
        DTitle.Text = title
        DTitle.TextColor3 = Akbar.Theme.Text
        DTitle.TextSize = 16
        DTitle.TextXAlignment = Enum.TextXAlignment.Left
        DTitle.Parent = DialogBox

        local DContent = Instance.new("TextLabel")
        DContent.Position = UDim2.new(0, 20, 0, 46)
        DContent.Size = UDim2.new(1, -40, 0, 48)
        DContent.BackgroundTransparency = 1
        DContent.Font = Enum.Font.Gotham
        DContent.Text = content
        DContent.TextColor3 = Akbar.Theme.Muted
        DContent.TextSize = 13
        DContent.TextWrapped = true
        DContent.TextXAlignment = Enum.TextXAlignment.Left
        DContent.Parent = DialogBox

        local BtnRow = Instance.new("Frame")
        BtnRow.AnchorPoint = Vector2.new(0, 1)
        BtnRow.Position = UDim2.new(0, 20, 1, -16)
        BtnRow.Size = UDim2.new(1, -40, 0, 36)
        BtnRow.BackgroundTransparency = 1
        BtnRow.Parent = DialogBox

        local function CreateDButton(text, isPrimary, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(0.5, -6, 1, 0)
            b.BackgroundColor3 = isPrimary and Akbar.Theme.Accent or Akbar.Theme.Surface2
            b.Font = Enum.Font.GothamBold
            b.Text = text
            b.TextColor3 = isPrimary and Color3.fromRGB(255, 255, 255) or Akbar.Theme.Muted
            b.TextSize = 13
            b.AutoButtonColor = false
            b.Parent = BtnRow

            local bc = Instance.new("UICorner")
            bc.CornerRadius = UDim.new(0, 6)
            bc.Parent = b

            b.MouseButton1Click:Connect(function()
                ModalBackdrop:Destroy()
                callback()
            end)
            return b
        end

        local CancelB = CreateDButton(canText, false, function() cb(false) end)
        CancelB.Position = UDim2.new(0, 0, 0, 0)
        local ConfirmB = CreateDButton(cText, true, function() cb(true) end)
        ConfirmB.Position = UDim2.new(0.5, 6, 0, 0)

        Tween(ModalBackdrop, TweenInfo.new(0.2), { BackgroundTransparency = 0.5 })
    end

    function Window:Dialog(dialogData)
        dialogData = dialogData or {}
        local title = dialogData.Title or "Akbar"
        local content = dialogData.Content or ""
        local buttons = dialogData.Buttons or { { Name = "OK", Callback = function() end } }

        local ModalBackdrop = Instance.new("TextButton")
        ModalBackdrop.Name = "DialogBackdrop"
        ModalBackdrop.Size = UDim2.new(1, 0, 1, 0)
        ModalBackdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        ModalBackdrop.BackgroundTransparency = 0.5
        ModalBackdrop.Text = ""
        ModalBackdrop.ZIndex = 80
        ModalBackdrop.Parent = MainWindow

        local ModalCorner = Instance.new("UICorner")
        ModalCorner.CornerRadius = UDim.new(0, 12)
        ModalCorner.Parent = ModalBackdrop

        local DialogBox = Instance.new("Frame")
        DialogBox.AnchorPoint = Vector2.new(0.5, 0.5)
        DialogBox.Position = UDim2.new(0.5, 0, 0.5, 0)
        DialogBox.Size = UDim2.new(0, 360, 0, 170)
        DialogBox.BackgroundColor3 = Akbar.Theme.Surface
        DialogBox.Parent = ModalBackdrop

        local DialogCorner = Instance.new("UICorner")
        DialogCorner.CornerRadius = UDim.new(0, 10)
        DialogCorner.Parent = DialogBox

        local DTitle = Instance.new("TextLabel")
        DTitle.Position = UDim2.new(0, 20, 0, 18)
        DTitle.Size = UDim2.new(1, -40, 0, 22)
        DTitle.BackgroundTransparency = 1
        DTitle.Font = Enum.Font.GothamBold
        DTitle.Text = title
        DTitle.TextColor3 = Akbar.Theme.Text
        DTitle.TextSize = 16
        DTitle.TextXAlignment = Enum.TextXAlignment.Left
        DTitle.Parent = DialogBox

        local DContent = Instance.new("TextLabel")
        DContent.Position = UDim2.new(0, 20, 0, 46)
        DContent.Size = UDim2.new(1, -40, 0, 48)
        DContent.BackgroundTransparency = 1
        DContent.Font = Enum.Font.Gotham
        DContent.Text = content
        DContent.TextColor3 = Akbar.Theme.Muted
        DContent.TextSize = 13
        DContent.TextWrapped = true
        DContent.TextXAlignment = Enum.TextXAlignment.Left
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

        for _, btnInfo in ipairs(buttons) do
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(0, 90, 1, 0)
            b.BackgroundColor3 = Akbar.Theme.Surface2
            b.Font = Enum.Font.GothamBold
            b.Text = btnInfo.Name or "Button"
            b.TextColor3 = Akbar.Theme.Text
            b.TextSize = 12
            b.Parent = BtnRow

            local bc = Instance.new("UICorner")
            bc.CornerRadius = UDim.new(0, 6)
            bc.Parent = b

            b.MouseButton1Click:Connect(function()
                ModalBackdrop:Destroy()
                if btnInfo.Callback then btnInfo.Callback() end
            end)
        end
    end

    function Window:Destroy()
        for _, conn in ipairs(Window.Connections) do
            if conn and conn.Disconnect then conn:Disconnect() end
        end
        if Window.ScreenGui then Window.ScreenGui:Destroy() end
    end

    -- Tab System
    function Window:CreateTab(tabConfig, optionalIcon)
        if type(tabConfig) == "string" then
            tabConfig = { Name = tabConfig, Icon = optionalIcon }
        end
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Name or "Tab"
        local tabDesc = tabConfig.Desc or ""
        local tabIcon = tabConfig.Icon or "anchor"

        local Tab = {
            Name = tabName,
            Desc = tabDesc,
            Icon = tabIcon,
            Window = Window,
            Components = {},
            Collapsibles = {}
        }

        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = "Tab_" .. tabName
        TabBtn.Size = UDim2.new(1, 0, 0, 38)
        TabBtn.BackgroundColor3 = Akbar.Theme.Surface2
        TabBtn.BackgroundTransparency = 1
        TabBtn.AutoButtonColor = false
        TabBtn.Text = ""
        TabBtn.Parent = TabScroll
        Tab.Button = TabBtn

        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 8)
        TabBtnCorner.Parent = TabBtn

        local TabIconImg = Instance.new("ImageLabel")
        TabIconImg.Position = UDim2.new(0, 10, 0.5, -9)
        TabIconImg.Size = UDim2.new(0, 18, 0, 18)
        TabIconImg.BackgroundTransparency = 1
        TabIconImg.Image = GetIcon(tabIcon)
        TabIconImg.ImageColor3 = Akbar.Theme.Muted
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
        TabText.Parent = TabBtn

        local PageScroll = Instance.new("ScrollingFrame")
        PageScroll.Name = "Page_" .. tabName
        PageScroll.Size = UDim2.new(1, 0, 1, 0)
        PageScroll.BackgroundTransparency = 1
        PageScroll.BorderSizePixel = 0
        PageScroll.ScrollBarThickness = 3
        PageScroll.ScrollBarImageColor3 = Akbar.Theme.Border
        PageScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        PageScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        PageScroll.Visible = false
        PageScroll.Parent = PagesContainer

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.Parent = PageScroll

        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingLeft = UDim.new(0, 24)
        PagePadding.PaddingRight = UDim.new(0, 24)
        PagePadding.PaddingTop = UDim.new(0, 8)
        PagePadding.PaddingBottom = UDim.new(0, 24)
        PagePadding.Parent = PageScroll

        Tab.Page = PageScroll

        function Tab:Select()
            for _, t in ipairs(Window.Tabs) do
                if t ~= Tab then
                    Tween(t.Button, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Akbar.Theme.Surface2
                    })
                    Tween(t.Button:FindFirstChildWhichIsA("ImageLabel"), TweenInfo.new(0.25), { ImageColor3 = Akbar.Theme.Muted })
                    Tween(t.Button:FindFirstChildWhichIsA("TextLabel"), TweenInfo.new(0.25), { TextColor3 = Akbar.Theme.Muted })
                    t.Page.Visible = false
                end
            end

            Window.ActiveTab = Tab
            TabHeading.Text = tabName
            TabDesc.Text = tabDesc
            Tab.Page.Visible = true

            Tween(TabBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.2,
                BackgroundColor3 = Akbar.Theme.Surface2
            })
            Tween(TabIconImg, TweenInfo.new(0.25), { ImageColor3 = Akbar.Theme.Accent })
            Tween(TabText, TweenInfo.new(0.25), { TextColor3 = Akbar.Theme.Text })
        end

        TabBtn.MouseButton1Click:Connect(function()
            Tab:Select()
        end)

        table.insert(Window.Tabs, Tab)

        if #Window.Tabs == 1 then
            Tab:Select()
        end

        Akbar:_InjectComponentMethods(Tab, PageScroll)

        return Tab
    end

    Window.Tab = Window.CreateTab

    return Window
end

Akbar.Window = Akbar.CreateWindow

-- Component Factory Injection into Tabs & Collapsible Groups
function Akbar:_InjectComponentMethods(targetScope, containerFrame)
    local Window = targetScope.Window or targetScope

    -- 1. COLLAPSIBLE GROUP
    function targetScope:CreateCollapsible(colConfig)
        colConfig = colConfig or {}
        local colName = colConfig.Name or "Collapsible Group"
        local colDesc = colConfig.Desc or ""
        local colIcon = colConfig.Icon or "fish"
        local startOpen = colConfig.Open or false

        local Group = {
            Name = colName,
            IsOpenState = false,
            Window = Window,
            Tab = targetScope.Tab or targetScope,
            Connections = {},
            Components = {}
        }

        local GroupFrame = Instance.new("Frame")
        GroupFrame.Name = "Collapsible_" .. colName
        GroupFrame.Size = UDim2.new(1, 0, 0, 56)
        GroupFrame.BackgroundColor3 = Akbar.Theme.Surface
        GroupFrame.BackgroundTransparency = 0.2
        GroupFrame.ClipsDescendants = true
        GroupFrame.Parent = containerFrame
        Group.Frame = GroupFrame

        local GroupCorner = Instance.new("UICorner")
        GroupCorner.CornerRadius = UDim.new(0, 10)
        GroupCorner.Parent = GroupFrame

        local GroupStroke = Instance.new("UIStroke")
        GroupStroke.Color = Akbar.Theme.Border
        GroupStroke.Thickness = 1
        GroupStroke.Parent = GroupFrame

        local HeaderBtn = Instance.new("TextButton")
        HeaderBtn.Name = "Header"
        HeaderBtn.Size = UDim2.new(1, 0, 0, 56)
        HeaderBtn.BackgroundTransparency = 1
        HeaderBtn.Text = ""
        HeaderBtn.Parent = GroupFrame

        local IconImg = Instance.new("ImageLabel")
        IconImg.Position = UDim2.new(0, 16, 0.5, -10)
        IconImg.Size = UDim2.new(0, 20, 0, 20)
        IconImg.BackgroundTransparency = 1
        IconImg.Image = GetIcon(colIcon)
        IconImg.ImageColor3 = Akbar.Theme.Accent
        IconImg.Parent = HeaderBtn

        local TitleText = Instance.new("TextLabel")
        TitleText.Position = UDim2.new(0, 48, 0, colDesc ~= "" and 10 or 18)
        TitleText.Size = UDim2.new(1, -90, 0, 18)
        TitleText.BackgroundTransparency = 1
        TitleText.Font = Enum.Font.GothamBold
        TitleText.Text = colName
        TitleText.TextColor3 = Akbar.Theme.Text
        TitleText.TextSize = 14
        TitleText.TextXAlignment = Enum.TextXAlignment.Left
        TitleText.Parent = HeaderBtn

        if colDesc ~= "" then
            local SubText = Instance.new("TextLabel")
            SubText.Position = UDim2.new(0, 48, 0, 28)
            SubText.Size = UDim2.new(1, -90, 0, 16)
            SubText.BackgroundTransparency = 1
            SubText.Font = Enum.Font.Gotham
            SubText.Text = colDesc
            SubText.TextColor3 = Akbar.Theme.Muted
            SubText.TextSize = 11
            SubText.TextXAlignment = Enum.TextXAlignment.Left
            SubText.Parent = HeaderBtn
        end

        local Chevron = Instance.new("ImageLabel")
        Chevron.AnchorPoint = Vector2.new(1, 0.5)
        Chevron.Position = UDim2.new(1, -16, 0.5, 0)
        Chevron.Size = UDim2.new(0, 18, 0, 18)
        Chevron.BackgroundTransparency = 1
        Chevron.Image = GetIcon("chevron-down")
        Chevron.ImageColor3 = Akbar.Theme.Muted
        Chevron.Parent = HeaderBtn

        local ContentArea = Instance.new("Frame")
        ContentArea.Name = "Content"
        ContentArea.Position = UDim2.new(0, 0, 0, 56)
        ContentArea.Size = UDim2.new(1, 0, 0, 0)
        ContentArea.BackgroundTransparency = 1
        ContentArea.ClipsDescendants = true
        ContentArea.Parent = GroupFrame
        Group.ContentArea = ContentArea

        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 6)
        ContentLayout.Parent = ContentArea

        local ContentPadding = Instance.new("UIPadding")
        ContentPadding.PaddingLeft = UDim.new(0, 14)
        ContentPadding.PaddingRight = UDim.new(0, 14)
        ContentPadding.PaddingTop = UDim.new(0, 6)
        ContentPadding.PaddingBottom = UDim.new(0, 14)
        ContentPadding.Parent = ContentArea

        local ContentDivider = Instance.new("Frame")
        ContentDivider.Name = "TopLine"
        ContentDivider.Position = UDim2.new(0, 14, 0, 55)
        ContentDivider.Size = UDim2.new(1, -28, 0, 1)
        ContentDivider.BackgroundColor3 = Akbar.Theme.Border
        ContentDivider.BorderSizePixel = 0
        ContentDivider.Visible = false
        ContentDivider.Parent = GroupFrame

        local function UpdateState(open, instant)
            Group.IsOpenState = open
            ContentDivider.Visible = open

            if open and Window.Accordion then
                local pool = targetScope.Collapsibles or (targetScope.Tab and targetScope.Tab.Collapsibles)
                if pool then
                    for _, sibling in ipairs(pool) do
                        if sibling ~= Group and sibling:IsOpen() then
                            sibling:Close()
                        end
                    end
                end
            end

            local innerHeight = ContentLayout.AbsoluteContentSize.Y + 20
            local targetHeight = open and (56 + innerHeight) or 56
            local targetRot = open and 180 or 0

            if instant or not Akbar.AnimationEnabled then
                Chevron.Rotation = targetRot
                GroupFrame.Size = UDim2.new(1, 0, 0, targetHeight)
                ContentArea.Size = UDim2.new(1, 0, 0, open and innerHeight or 0)
            else
                Tween(Chevron, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Rotation = targetRot })
                Tween(GroupFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, targetHeight) })
                Tween(ContentArea, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, open and innerHeight or 0) })
            end
        end

        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if Group.IsOpenState then
                local innerHeight = ContentLayout.AbsoluteContentSize.Y + 20
                GroupFrame.Size = UDim2.new(1, 0, 0, 56 + innerHeight)
                ContentArea.Size = UDim2.new(1, 0, 0, innerHeight)
            end
        end)

        HeaderBtn.MouseButton1Click:Connect(function()
            UpdateState(not Group.IsOpenState)
        end)

        function Group:Open() UpdateState(true) end
        function Group:Close() UpdateState(false) end
        function Group:Toggle() UpdateState(not Group.IsOpenState) end
        function Group:IsOpen() return Group.IsOpenState end
        function Group:SetOpen(state) UpdateState(state and true or false) end

        function Group:Destroy()
            for _, c in ipairs(Group.Connections) do
                if c and c.Disconnect then c:Disconnect() end
            end
            GroupFrame:Destroy()
        end

        Akbar:_InjectComponentMethods(Group, ContentArea)

        local pool = targetScope.Collapsibles
        if pool then table.insert(pool, Group) end

        if startOpen then
            task.defer(function() UpdateState(true, true) end)
        end

        return Group
    end

    -- 2. TOGGLE
    function targetScope:CreateToggle(toggleConfig)
        toggleConfig = toggleConfig or {}
        local name = toggleConfig.Name or "Toggle"
        local desc = toggleConfig.Desc or ""
        local current = toggleConfig.CurrentValue or false
        local flag = toggleConfig.Flag
        local cb = toggleConfig.Callback or function() end

        local Toggle = { Value = current }

        local Frame = Instance.new("Frame")
        Frame.Name = "Toggle_" .. name
        Frame.Size = UDim2.new(1, 0, 0, desc ~= "" and 48 or 40)
        Frame.BackgroundColor3 = Akbar.Theme.Surface2
        Frame.BackgroundTransparency = 0.5
        Frame.Parent = containerFrame

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = Frame

        local Title = Instance.new("TextLabel")
        Title.Position = UDim2.new(0, 14, 0, desc ~= "" and 7 or 11)
        Title.Size = UDim2.new(1, -70, 0, 16)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamMedium
        Title.Text = name
        Title.TextColor3 = Akbar.Theme.Text
        Title.TextSize = 13
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = Frame

        if desc ~= "" then
            local Sub = Instance.new("TextLabel")
            Sub.Position = UDim2.new(0, 14, 0, 24)
            Sub.Size = UDim2.new(1, -70, 0, 16)
            Sub.BackgroundTransparency = 1
            Sub.Font = Enum.Font.Gotham
            Sub.Text = desc
            Sub.TextColor3 = Akbar.Theme.Muted
            Sub.TextSize = 11
            Sub.TextXAlignment = Enum.TextXAlignment.Left
            Sub.Parent = Frame
        end

        local SwitchTrack = Instance.new("TextButton")
        SwitchTrack.AnchorPoint = Vector2.new(1, 0.5)
        SwitchTrack.Position = UDim2.new(1, -14, 0.5, 0)
        SwitchTrack.Size = UDim2.new(0, 42, 0, 22)
        SwitchTrack.BackgroundColor3 = current and Akbar.Theme.Accent or Akbar.Theme.Border
        SwitchTrack.AutoButtonColor = false
        SwitchTrack.Text = ""
        SwitchTrack.Parent = Frame

        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(1, 0)
        TrackCorner.Parent = SwitchTrack

        local Knob = Instance.new("Frame")
        Knob.Position = current and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        Knob.Size = UDim2.new(0, 16, 0, 16)
        Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Knob.Parent = SwitchTrack

        local KnobCorner = Instance.new("UICorner")
        KnobCorner.CornerRadius = UDim.new(1, 0)
        KnobCorner.Parent = Knob

        local function SetVal(val)
            Toggle.Value = val
            local targetPos = val and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            local targetColor = val and Akbar.Theme.Accent or Akbar.Theme.Border
            Tween(Knob, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = targetPos })
            Tween(SwitchTrack, TweenInfo.new(0.2), { BackgroundColor3 = targetColor })
            pcall(cb, val)
        end

        SwitchTrack.MouseButton1Click:Connect(function()
            SetVal(not Toggle.Value)
        end)

        function Toggle:Set(val) SetVal(val) end
        function Toggle:Get() return Toggle.Value end
        function Toggle:Destroy() Frame:Destroy() end

        if flag and Window.Config then
            Window.Config:Register(flag, function() return Toggle:Get() end, function(v) Toggle:Set(v) end)
        end

        return Toggle
    end

    -- 3. BUTTON
    function targetScope:CreateButton(btnConfig)
        btnConfig = btnConfig or {}
        local name = btnConfig.Name or "Button"
        local desc = btnConfig.Desc or ""
        local icon = btnConfig.Icon or "zap"
        local style = btnConfig.Style or "Default"
        local cb = btnConfig.Callback or function() end

        local Button = {}

        local Btn = Instance.new("TextButton")
        Btn.Name = "Button_" .. name
        Btn.Size = UDim2.new(1, 0, 0, desc ~= "" and 48 or 40)
        Btn.BackgroundColor3 = style == "Primary" and Akbar.Theme.Accent or Akbar.Theme.Surface2
        Btn.BackgroundTransparency = style == "Primary" and 0.1 or 0.4
        Btn.AutoButtonColor = false
        Btn.Text = ""
        Btn.Parent = containerFrame

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = Btn

        local IconImg = Instance.new("ImageLabel")
        IconImg.Position = UDim2.new(0, 14, 0.5, -9)
        IconImg.Size = UDim2.new(0, 18, 0, 18)
        IconImg.BackgroundTransparency = 1
        IconImg.Image = GetIcon(icon)
        IconImg.ImageColor3 = style == "Primary" and Color3.fromRGB(255, 255, 255) or Akbar.Theme.Accent
        IconImg.Parent = Btn

        local Title = Instance.new("TextLabel")
        Title.Position = UDim2.new(0, 42, 0, desc ~= "" and 7 or 11)
        Title.Size = UDim2.new(1, -54, 0, 16)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamMedium
        Title.Text = name
        Title.TextColor3 = Akbar.Theme.Text
        Title.TextSize = 13
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = Btn

        if desc ~= "" then
            local Sub = Instance.new("TextLabel")
            Sub.Position = UDim2.new(0, 42, 0, 24)
            Sub.Size = UDim2.new(1, -54, 0, 16)
            Sub.BackgroundTransparency = 1
            Sub.Font = Enum.Font.Gotham
            Sub.Text = desc
            Sub.TextColor3 = Akbar.Theme.Muted
            Sub.TextSize = 11
            Sub.TextXAlignment = Enum.TextXAlignment.Left
            Sub.Parent = Btn
        end

        Btn.MouseEnter:Connect(function()
            Tween(Btn, TweenInfo.new(0.2), { BackgroundTransparency = style == "Primary" and 0 or 0.2 })
        end)
        Btn.MouseLeave:Connect(function()
            Tween(Btn, TweenInfo.new(0.2), { BackgroundTransparency = style == "Primary" and 0.1 or 0.4 })
        end)
        Btn.MouseButton1Click:Connect(function()
            Tween(Btn, TweenInfo.new(0.1), { Size = UDim2.new(0.98, 0, 0, (desc ~= "" and 48 or 40) - 2) })
            task.wait(0.1)
            Tween(Btn, TweenInfo.new(0.1), { Size = UDim2.new(1, 0, 0, desc ~= "" and 48 or 40) })
            pcall(cb)
        end)

        function Button:Destroy() Btn:Destroy() end
        return Button
    end

    -- 4. SLIDER (Fixed Event Cleanup)
    function targetScope:CreateSlider(sliderConfig)
        sliderConfig = sliderConfig or {}
        local name = sliderConfig.Name or "Slider"
        local desc = sliderConfig.Desc or ""
        local range = sliderConfig.Range or {0, 100}
        local inc = sliderConfig.Increment or 1
        local suffix = sliderConfig.Suffix or ""
        local current = sliderConfig.CurrentValue or range[1]
        local flag = sliderConfig.Flag
        local cb = sliderConfig.Callback or function() end

        local Slider = { Value = current }

        local Frame = Instance.new("Frame")
        Frame.Name = "Slider_" .. name
        Frame.Size = UDim2.new(1, 0, 0, 56)
        Frame.BackgroundColor3 = Akbar.Theme.Surface2
        Frame.BackgroundTransparency = 0.5
        Frame.Parent = containerFrame

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = Frame

        local Title = Instance.new("TextLabel")
        Title.Position = UDim2.new(0, 14, 0, 8)
        Title.Size = UDim2.new(1, -90, 0, 16)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamMedium
        Title.Text = name
        Title.TextColor3 = Akbar.Theme.Text
        Title.TextSize = 13
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = Frame

        local ValLabel = Instance.new("TextLabel")
        ValLabel.AnchorPoint = Vector2.new(1, 0)
        ValLabel.Position = UDim2.new(1, -14, 0, 8)
        ValLabel.Size = UDim2.new(0, 70, 0, 16)
        ValLabel.BackgroundTransparency = 1
        ValLabel.Font = Enum.Font.GothamBold
        ValLabel.Text = tostring(current) .. suffix
        ValLabel.TextColor3 = Akbar.Theme.Accent
        ValLabel.TextSize = 12
        ValLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValLabel.Parent = Frame

        local SliderBar = Instance.new("TextButton")
        SliderBar.Position = UDim2.new(0, 14, 0, 34)
        SliderBar.Size = UDim2.new(1, -28, 0, 6)
        SliderBar.BackgroundColor3 = Akbar.Theme.Border
        SliderBar.AutoButtonColor = false
        SliderBar.Text = ""
        SliderBar.Parent = Frame

        local BarCorner = Instance.new("UICorner")
        BarCorner.CornerRadius = UDim.new(1, 0)
        BarCorner.Parent = SliderBar

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((current - range[1]) / (range[2] - range[1]), 0, 1, 0)
        Fill.BackgroundColor3 = Akbar.Theme.Accent
        Fill.BorderSizePixel = 0
        Fill.Parent = SliderBar

        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(1, 0)
        FillCorner.Parent = Fill

        local function UpdateFromPercent(percent)
            local raw = range[1] + (range[2] - range[1]) * math.clamp(percent, 0, 1)
            local stepped = math.floor((raw / inc) + 0.5) * inc
            stepped = math.clamp(stepped, range[1], range[2])
            Slider.Value = stepped
            ValLabel.Text = tostring(stepped) .. suffix
            Tween(Fill, TweenInfo.new(0.08), { Size = UDim2.new((stepped - range[1]) / (range[2] - range[1]), 0, 1, 0) })
            pcall(cb, stepped)
        end

        local isDragging = false
        SliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                local percent = (input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X
                UpdateFromPercent(percent)

                local moveConn, endConn
                moveConn = UserInputService.InputChanged:Connect(function(moveInput)
                    if isDragging and (moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch) then
                        local curPercent = (moveInput.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X
                        UpdateFromPercent(curPercent)
                    end
                end)

                endConn = UserInputService.InputEnded:Connect(function(endInput)
                    if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                        isDragging = false
                        if moveConn then moveConn:Disconnect() end
                        if endConn then endConn:Disconnect() end
                    end
                end)
            end
        end)

        function Slider:Set(val)
            local clamped = math.clamp(val, range[1], range[2])
            Slider.Value = clamped
            ValLabel.Text = tostring(clamped) .. suffix
            Fill.Size = UDim2.new((clamped - range[1]) / (range[2] - range[1]), 0, 1, 0)
            pcall(cb, clamped)
        end
        function Slider:Get() return Slider.Value end
        function Slider:Destroy() Frame:Destroy() end

        if flag and Window.Config then
            Window.Config:Register(flag, function() return Slider:Get() end, function(v) Slider:Set(v) end)
        end

        return Slider
    end

    -- 5. STEPPER (Added Config Registration)
    function targetScope:CreateStepper(stepConfig)
        stepConfig = stepConfig or {}
        local name = stepConfig.Name or "Stepper"
        local range = stepConfig.Range or {0, 100}
        local inc = stepConfig.Increment or 1
        local current = stepConfig.CurrentValue or range[1]
        local flag = stepConfig.Flag
        local cb = stepConfig.Callback or function() end

        local Stepper = { Value = current }

        local Frame = Instance.new("Frame")
        Frame.Name = "Stepper_" .. name
        Frame.Size = UDim2.new(1, 0, 0, 44)
        Frame.BackgroundColor3 = Akbar.Theme.Surface2
        Frame.BackgroundTransparency = 0.5
        Frame.Parent = containerFrame

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = Frame

        local Title = Instance.new("TextLabel")
        Title.Position = UDim2.new(0, 14, 0, 0)
        Title.Size = UDim2.new(1, -120, 1, 0)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamMedium
        Title.Text = name
        Title.TextColor3 = Akbar.Theme.Text
        Title.TextSize = 13
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = Frame

        local StepperBox = Instance.new("Frame")
        StepperBox.AnchorPoint = Vector2.new(1, 0.5)
        StepperBox.Position = UDim2.new(1, -14, 0.5, 0)
        StepperBox.Size = UDim2.new(0, 96, 0, 26)
        StepperBox.BackgroundColor3 = Akbar.Theme.Border
        StepperBox.Parent = Frame

        local SBCorner = Instance.new("UICorner")
        SBCorner.CornerRadius = UDim.new(0, 6)
        SBCorner.Parent = StepperBox

        local DecBtn = Instance.new("TextButton")
        DecBtn.Size = UDim2.new(0, 26, 1, 0)
        DecBtn.BackgroundTransparency = 1
        DecBtn.Font = Enum.Font.GothamBold
        DecBtn.Text = "-"
        DecBtn.TextColor3 = Akbar.Theme.Text
        DecBtn.TextSize = 14
        DecBtn.Parent = StepperBox

        local IncBtn = Instance.new("TextButton")
        IncBtn.AnchorPoint = Vector2.new(1, 0)
        IncBtn.Position = UDim2.new(1, 0, 0, 0)
        IncBtn.Size = UDim2.new(0, 26, 1, 0)
        IncBtn.BackgroundTransparency = 1
        IncBtn.Font = Enum.Font.GothamBold
        IncBtn.Text = "+"
        IncBtn.TextColor3 = Akbar.Theme.Text
        IncBtn.TextSize = 14
        IncBtn.Parent = StepperBox

        local Display = Instance.new("TextLabel")
        Display.Position = UDim2.new(0, 26, 0, 0)
        Display.Size = UDim2.new(1, -52, 1, 0)
        Display.BackgroundTransparency = 1
        Display.Font = Enum.Font.GothamBold
        Display.Text = tostring(current)
        Display.TextColor3 = Akbar.Theme.Accent
        Display.TextSize = 12
        Display.Parent = StepperBox

        local function Step(amount)
            local n = math.clamp(Stepper.Value + amount, range[1], range[2])
            Stepper.Value = n
            Display.Text = tostring(n)
            pcall(cb, n)
        end

        DecBtn.MouseButton1Click:Connect(function() Step(-inc) end)
        IncBtn.MouseButton1Click:Connect(function() Step(inc) end)

        function Stepper:Set(v)
            Stepper.Value = math.clamp(v, range[1], range[2])
            Display.Text = tostring(Stepper.Value)
            pcall(cb, Stepper.Value)
        end
        function Stepper:Get() return Stepper.Value end
        function Stepper:Destroy() Frame:Destroy() end

        if flag and Window.Config then
            Window.Config:Register(flag, function() return Stepper:Get() end, function(v) Stepper:Set(v) end)
        end

        return Stepper
    end

    -- 6. DROPDOWN (Enhanced Active States)
    function targetScope:CreateDropdown(dropConfig)
        dropConfig = dropConfig or {}
        local name = dropConfig.Name or "Dropdown"
        local options = dropConfig.Options or {}
        local current = dropConfig.CurrentOption or options[1]
        local isMulti = dropConfig.MultipleOptions or false
        local flag = dropConfig.Flag
        local cb = dropConfig.Callback or function() end

        local Dropdown = {
            Open = false,
            Value = isMulti and (type(current) == "table" and current or {current}) or current,
            Options = options
        }

        local Frame = Instance.new("Frame")
        Frame.Name = "Dropdown_" .. name
        Frame.Size = UDim2.new(1, 0, 0, 44)
        Frame.BackgroundColor3 = Akbar.Theme.Surface2
        Frame.BackgroundTransparency = 0.5
        Frame.ClipsDescendants = true
        Frame.Parent = containerFrame

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = Frame

        local DropBtn = Instance.new("TextButton")
        DropBtn.Size = UDim2.new(1, 0, 0, 44)
        DropBtn.BackgroundTransparency = 1
        DropBtn.Text = ""
        DropBtn.Parent = Frame

        local Title = Instance.new("TextLabel")
        Title.Position = UDim2.new(0, 14, 0, 0)
        Title.Size = UDim2.new(1, -160, 0, 44)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamMedium
        Title.Text = name
        Title.TextColor3 = Akbar.Theme.Text
        Title.TextSize = 13
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = DropBtn

        local Display = Instance.new("TextLabel")
        Display.AnchorPoint = Vector2.new(1, 0.5)
        Display.Position = UDim2.new(1, -38, 0.5, 0)
        Display.Size = UDim2.new(0, 110, 0, 24)
        Display.BackgroundTransparency = 1
        Display.Font = Enum.Font.Gotham
        Display.Text = isMulti and table.concat(Dropdown.Value, ", ") or tostring(Dropdown.Value)
        Display.TextColor3 = Akbar.Theme.Muted
        Display.TextSize = 12
        Display.TextTruncate = Enum.TextTruncate.AtEnd
        Display.TextXAlignment = Enum.TextXAlignment.Right
        Display.Parent = DropBtn

        local Chevron = Instance.new("ImageLabel")
        Chevron.AnchorPoint = Vector2.new(1, 0.5)
        Chevron.Position = UDim2.new(1, -14, 0.5, 0)
        Chevron.Size = UDim2.new(0, 16, 0, 16)
        Chevron.BackgroundTransparency = 1
        Chevron.Image = GetIcon("chevron-down")
        Chevron.ImageColor3 = Akbar.Theme.Muted
        Chevron.Parent = DropBtn

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
        ListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        ListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        ListScroll.Parent = ListHolder

        local ListLayout = Instance.new("UIListLayout")
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Padding = UDim.new(0, 4)
        ListLayout.Parent = ListScroll

        local function BuildOptions()
            for _, ch in ipairs(ListScroll:GetChildren()) do
                if ch:IsA("TextButton") then ch:Destroy() end
            end

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
                ob.Parent = ListScroll

                local oc = Instance.new("UICorner")
                oc.CornerRadius = UDim.new(0, 6)
                oc.Parent = ob

                ob.MouseButton1Click:Connect(function()
                    if isMulti then
                        local found = table.find(Dropdown.Value, opt)
                        if found then
                            table.remove(Dropdown.Value, found)
                        else
                            table.insert(Dropdown.Value, opt)
                        end
                        Display.Text = table.concat(Dropdown.Value, ", ")
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
            Tween(Chevron, TweenInfo.new(0.2), { Rotation = state and 180 or 0 })
            Tween(Frame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, targetH) })
            ListHolder.Size = UDim2.new(1, -16, 0, state and (maxShow * 32) or 0)
        end

        DropBtn.MouseButton1Click:Connect(function()
            SetDropdownOpen(not Dropdown.Open)
        end)

        function Dropdown:Set(val)
            Dropdown.Value = val
            Display.Text = isMulti and table.concat(val, ", ") or tostring(val)
            BuildOptions()
            pcall(cb, val)
        end
        function Dropdown:Get() return Dropdown.Value end
        function Dropdown:SetOpen(st) SetDropdownOpen(st) end
        function Dropdown:Refresh(newOpts)
            Dropdown.Options = newOpts
            BuildOptions()
        end
        function Dropdown:Destroy() Frame:Destroy() end

        BuildOptions()

        if flag and Window.Config then
            Window.Config:Register(flag, function() return Dropdown:Get() end, function(v) Dropdown:Set(v) end)
        end

        return Dropdown
    end

    -- 7. INPUT
    function targetScope:CreateInput(inputConfig)
        inputConfig = inputConfig or {}
        local name = inputConfig.Name or "Input"
        local desc = inputConfig.Desc or ""
        local placeholder = inputConfig.PlaceholderText or "Type here..."
        local current = inputConfig.CurrentValue or ""
        local numeric = inputConfig.Numeric or false
        local flag = inputConfig.Flag
        local cb = inputConfig.Callback or function() end

        local Input = { Value = current }

        local Frame = Instance.new("Frame")
        Frame.Name = "Input_" .. name
        Frame.Size = UDim2.new(1, 0, 0, 48)
        Frame.BackgroundColor3 = Akbar.Theme.Surface2
        Frame.BackgroundTransparency = 0.5
        Frame.Parent = containerFrame

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = Frame

        local Title = Instance.new("TextLabel")
        Title.Position = UDim2.new(0, 14, 0, 0)
        Title.Size = UDim2.new(0.5, 0, 1, 0)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamMedium
        Title.Text = name
        Title.TextColor3 = Akbar.Theme.Text
        Title.TextSize = 13
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = Frame

        local BoxContainer = Instance.new("Frame")
        BoxContainer.AnchorPoint = Vector2.new(1, 0.5)
        BoxContainer.Position = UDim2.new(1, -14, 0.5, 0)
        BoxContainer.Size = UDim2.new(0.45, 0, 0, 30)
        BoxContainer.BackgroundColor3 = Akbar.Theme.Surface
        BoxContainer.Parent = Frame

        local BCCorner = Instance.new("UICorner")
        BCCorner.CornerRadius = UDim.new(0, 6)
        BCCorner.Parent = BoxContainer

        local BCStroke = Instance.new("UIStroke")
        BCStroke.Color = Akbar.Theme.Border
        BCStroke.Thickness = 1
        BCStroke.Parent = BoxContainer

        local TextBox = Instance.new("TextBox")
        TextBox.Size = UDim2.new(1, -12, 1, 0)
        TextBox.Position = UDim2.new(0, 6, 0, 0)
        TextBox.BackgroundTransparency = 1
        TextBox.Font = Enum.Font.Gotham
        TextBox.PlaceholderText = placeholder
        TextBox.PlaceholderColor3 = Akbar.Theme.Muted
        TextBox.Text = current
        TextBox.TextColor3 = Akbar.Theme.Text
        TextBox.TextSize = 12
        TextBox.ClearTextOnFocus = false
        TextBox.Parent = BoxContainer

        if numeric then
            TextBox:GetPropertyChangedSignal("Text"):Connect(function()
                TextBox.Text = TextBox.Text:gsub("%D+", "")
            end)
        end

        TextBox.FocusLost:Connect(function(enterPressed)
            Input.Value = TextBox.Text
            pcall(cb, TextBox.Text, enterPressed)
        end)

        function Input:Set(text)
            TextBox.Text = tostring(text)
            Input.Value = tostring(text)
            pcall(cb, TextBox.Text, false)
        end
        function Input:Get() return Input.Value end
        function Input:Destroy() Frame:Destroy() end

        if flag and Window.Config then
            Window.Config:Register(flag, function() return Input:Get() end, function(v) Input:Set(v) end)
        end

        return Input
    end

    -- 8. KEYBIND (Cleaned Event Management)
    function targetScope:CreateKeybind(kbConfig)
        kbConfig = kbConfig or {}
        local name = kbConfig.Name or "Keybind"
        local current = kbConfig.CurrentKeybind or "None"
        local flag = kbConfig.Flag
        local cb = kbConfig.Callback or function() end
        local onChanged = kbConfig.OnChanged or function() end

        local Keybind = { Value = current }
        local isBinding = false

        local Frame = Instance.new("Frame")
        Frame.Name = "Keybind_" .. name
        Frame.Size = UDim2.new(1, 0, 0, 44)
        Frame.BackgroundColor3 = Akbar.Theme.Surface2
        Frame.BackgroundTransparency = 0.5
        Frame.Parent = containerFrame

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = Frame

        local Title = Instance.new("TextLabel")
        Title.Position = UDim2.new(0, 14, 0, 0)
        Title.Size = UDim2.new(1, -120, 1, 0)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamMedium
        Title.Text = name
        Title.TextColor3 = Akbar.Theme.Text
        Title.TextSize = 13
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = Frame

        local BindBtn = Instance.new("TextButton")
        BindBtn.AnchorPoint = Vector2.new(1, 0.5)
        BindBtn.Position = UDim2.new(1, -14, 0.5, 0)
        BindBtn.Size = UDim2.new(0, 86, 0, 26)
        BindBtn.BackgroundColor3 = Akbar.Theme.Surface
        BindBtn.AutoButtonColor = false
        BindBtn.Font = Enum.Font.GothamBold
        BindBtn.Text = current
        BindBtn.TextColor3 = Akbar.Theme.Accent
        BindBtn.TextSize = 12
        BindBtn.Parent = Frame

        local BBCorner = Instance.new("UICorner")
        BBCorner.CornerRadius = UDim.new(0, 6)
        BBCorner.Parent = BindBtn

        BindBtn.MouseButton1Click:Connect(function()
            isBinding = true
            BindBtn.Text = "..."
        end)

        local bindConn = UserInputService.InputBegan:Connect(function(inp, proc)
            if isBinding and not proc then
                if inp.UserInputType == Enum.UserInputType.Keyboard then
                    if inp.KeyCode == Enum.KeyCode.Escape then
                        Keybind.Value = "None"
                    else
                        Keybind.Value = inp.KeyCode.Name
                    end
                    BindBtn.Text = Keybind.Value
                    isBinding = false
                    pcall(onChanged, Keybind.Value)
                end
            elseif not proc and inp.KeyCode.Name == Keybind.Value and Keybind.Value ~= "None" then
                pcall(cb, Keybind.Value)
            end
        end)
        table.insert(Window.Connections, bindConn)

        function Keybind:Set(key)
            Keybind.Value = key
            BindBtn.Text = key
            pcall(onChanged, key)
        end
        function Keybind:Get() return Keybind.Value end
        function Keybind:Destroy() 
            if bindConn then bindConn:Disconnect() end
            Frame:Destroy() 
        end

        if flag and Window.Config then
            Window.Config:Register(flag, function() return Keybind:Get() end, function(v) Keybind:Set(v) end)
        end

        return Keybind
    end

    -- 9. COLOR PICKER (NEW FEATURE)
    function targetScope:CreateColorPicker(cpConfig)
        cpConfig = cpConfig or {}
        local name = cpConfig.Name or "Color Picker"
        local defaultColor = cpConfig.Default or Color3.fromRGB(56, 130, 255)
        local flag = cpConfig.Flag
        local cb = cpConfig.Callback or function() end

        local ColorPicker = { Value = defaultColor, Open = false }

        local Frame = Instance.new("Frame")
        Frame.Name = "ColorPicker_" .. name
        Frame.Size = UDim2.new(1, 0, 0, 44)
        Frame.BackgroundColor3 = Akbar.Theme.Surface2
        Frame.BackgroundTransparency = 0.5
        Frame.ClipsDescendants = true
        Frame.Parent = containerFrame

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = Frame

        local MainBtn = Instance.new("TextButton")
        MainBtn.Size = UDim2.new(1, 0, 0, 44)
        MainBtn.BackgroundTransparency = 1
        MainBtn.Text = ""
        MainBtn.Parent = Frame

        local Title = Instance.new("TextLabel")
        Title.Position = UDim2.new(0, 14, 0, 0)
        Title.Size = UDim2.new(1, -80, 0, 44)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamMedium
        Title.Text = name
        Title.TextColor3 = Akbar.Theme.Text
        Title.TextSize = 13
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = MainBtn

        local PreviewBox = Instance.new("Frame")
        PreviewBox.AnchorPoint = Vector2.new(1, 0.5)
        PreviewBox.Position = UDim2.new(1, -14, 0.5, 0)
        PreviewBox.Size = UDim2.new(0, 36, 0, 22)
        PreviewBox.BackgroundColor3 = defaultColor
        PreviewBox.Parent = MainBtn

        local PCorner = Instance.new("UICorner")
        PCorner.CornerRadius = UDim.new(0, 6)
        PCorner.Parent = PreviewBox

        local PStroke = Instance.new("UIStroke")
        PStroke.Color = Akbar.Theme.Border
        PStroke.Thickness = 1
        PStroke.Parent = PreviewBox

        -- Palet Preset Warna
        local PresetsHolder = Instance.new("Frame")
        PresetsHolder.Position = UDim2.new(0, 14, 0, 48)
        PresetsHolder.Size = UDim2.new(1, -28, 0, 32)
        PresetsHolder.BackgroundTransparency = 1
        PresetsHolder.Parent = Frame

        local PLayout = Instance.new("UIListLayout")
        PLayout.FillDirection = Enum.FillDirection.Horizontal
        PLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        PLayout.Padding = UDim.new(0, 8)
        PLayout.Parent = PresetsHolder

        local presetColors = {
            Color3.fromRGB(56, 130, 255),  -- Blue
            Color3.fromRGB(46, 204, 113),  -- Green
            Color3.fromRGB(241, 196, 15),  -- Yellow
            Color3.fromRGB(231, 76, 60),   -- Red
            Color3.fromRGB(155, 89, 182),  -- Purple
            Color3.fromRGB(255, 255, 255), -- White
            Color3.fromRGB(26, 26, 26)     -- Dark
        }

        local function SetColor(col)
            ColorPicker.Value = col
            PreviewBox.BackgroundColor3 = col
            pcall(cb, col)
        end

        for _, col in ipairs(presetColors) do
            local dot = Instance.new("TextButton")
            dot.Size = UDim2.new(0, 26, 0, 26)
            dot.BackgroundColor3 = col
            dot.Text = ""
            dot.AutoButtonColor = false
            dot.Parent = PresetsHolder

            local dCorner = Instance.new("UICorner")
            dCorner.CornerRadius = UDim.new(1, 0)
            dCorner.Parent = dot

            dot.MouseButton1Click:Connect(function()
                SetColor(col)
            end)
        end

        MainBtn.MouseButton1Click:Connect(function()
            ColorPicker.Open = not ColorPicker.Open
            Tween(Frame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = ColorPicker.Open and UDim2.new(1, 0, 0, 88) or UDim2.new(1, 0, 0, 44)
            })
        end)

        function ColorPicker:Set(col) SetColor(col) end
        function ColorPicker:Get() return ColorPicker.Value end
        function ColorPicker:Destroy() Frame:Destroy() end

        if flag and Window.Config then
            Window.Config:Register(flag, function() return ColorPicker:Get() end, function(v) ColorPicker:Set(v) end)
        end

        return ColorPicker
    end

    -- 10. PROGRESS BAR
    function targetScope:CreateProgress(progConfig)
        progConfig = progConfig or {}
        local name = progConfig.Name or "Progress"
        local current = progConfig.CurrentValue or 0
        local fmt = progConfig.Format or function(v) return math.floor(v * 100) .. "%" end
        local cb = progConfig.Callback or function() end

        local Progress = { Value = current }

        local Frame = Instance.new("Frame")
        Frame.Name = "Progress_" .. name
        Frame.Size = UDim2.new(1, 0, 0, 48)
        Frame.BackgroundColor3 = Akbar.Theme.Surface2
        Frame.BackgroundTransparency = 0.5
        Frame.Parent = containerFrame

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = Frame

        local Title = Instance.new("TextLabel")
        Title.Position = UDim2.new(0, 14, 0, 8)
        Title.Size = UDim2.new(1, -70, 0, 16)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamMedium
        Title.Text = name
        Title.TextColor3 = Akbar.Theme.Text
        Title.TextSize = 13
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = Frame

        local ValueText = Instance.new("TextLabel")
        ValueText.AnchorPoint = Vector2.new(1, 0)
        ValueText.Position = UDim2.new(1, -14, 0, 8)
        ValueText.Size = UDim2.new(0, 60, 0, 16)
        ValueText.BackgroundTransparency = 1
        ValueText.Font = Enum.Font.GothamBold
        ValueText.Text = fmt(current)
        ValueText.TextColor3 = Akbar.Theme.Accent
        ValueText.TextSize = 12
        ValueText.TextXAlignment = Enum.TextXAlignment.Right
        ValueText.Parent = Frame

        local Track = Instance.new("Frame")
        Track.Position = UDim2.new(0, 14, 0, 30)
        Track.Size = UDim2.new(1, -28, 0, 6)
        Track.BackgroundColor3 = Akbar.Theme.Border
        Track.Parent = Frame

        local TCorner = Instance.new("UICorner")
        TCorner.CornerRadius = UDim.new(1, 0)
        TCorner.Parent = Track

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new(math.clamp(current, 0, 1), 0, 1, 0)
        Fill.BackgroundColor3 = Akbar.Theme.Accent
        Fill.BorderSizePixel = 0
        Fill.Parent = Track

        local FCorner = Instance.new("UICorner")
        FCorner.CornerRadius = UDim.new(1, 0)
        FCorner.Parent = Fill

        function Progress:Set(val)
            val = math.clamp(val, 0, 1)
            Progress.Value = val
            ValueText.Text = fmt(val)
            Tween(Fill, TweenInfo.new(0.2), { Size = UDim2.new(val, 0, 1, 0) })
            pcall(cb, val)
        end
        function Progress:Get() return Progress.Value end
        function Progress:Destroy() Frame:Destroy() end

        return Progress
    end

    -- 11. LABEL
    function targetScope:CreateLabel(labelConfig)
        labelConfig = labelConfig or {}
        local text = labelConfig.Text or "Label"
        local rate = labelConfig.UpdateRate
        local updater = labelConfig.Update

        local Label = { Value = text }

        local Frame = Instance.new("Frame")
        Frame.Name = "Label"
        Frame.Size = UDim2.new(1, 0, 0, 32)
        Frame.BackgroundColor3 = Akbar.Theme.Surface2
        Frame.BackgroundTransparency = 0.7
        Frame.Parent = containerFrame

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = Frame

        local LText = Instance.new("TextLabel")
        LText.Size = UDim2.new(1, -24, 1, 0)
        LText.Position = UDim2.new(0, 12, 0, 0)
        LText.BackgroundTransparency = 1
        LText.Font = Enum.Font.Gotham
        LText.Text = text
        LText.TextColor3 = Akbar.Theme.Text
        LText.TextSize = 12
        LText.TextXAlignment = Enum.TextXAlignment.Left
        LText.Parent = Frame

        if rate and updater then
            task.spawn(function()
                while Frame.Parent do
                    task.wait(rate)
                    local newText = updater()
                    if newText then
                        LText.Text = tostring(newText)
                        Label.Value = tostring(newText)
                    end
                end
            end)
        end

        function Label:Set(newT)
            Label.Value = tostring(newT)
            LText.Text = tostring(newT)
        end
        function Label:Get() return Label.Value end
        function Label:Destroy() Frame:Destroy() end

        return Label
    end

    -- 12. PARAGRAPH
    function targetScope:CreateParagraph(paraConfig)
        paraConfig = paraConfig or {}
        local title = paraConfig.Title or "Title"
        local content = paraConfig.Content or ""

        local Paragraph = {}

        local Frame = Instance.new("Frame")
        Frame.Name = "Paragraph"
        Frame.Size = UDim2.new(1, 0, 0, 0)
        Frame.AutomaticSize = Enum.AutomaticSize.Y
        Frame.BackgroundColor3 = Akbar.Theme.Surface2
        Frame.BackgroundTransparency = 0.6
        Frame.Parent = containerFrame

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = Frame

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
        TTitle.Text = title
        TTitle.TextColor3 = Akbar.Theme.Text
        TTitle.TextSize = 13
        TTitle.TextXAlignment = Enum.TextXAlignment.Left
        TTitle.Parent = Frame

        local TDesc = Instance.new("TextLabel")
        TDesc.Size = UDim2.new(1, 0, 0, 0)
        TDesc.AutomaticSize = Enum.AutomaticSize.Y
        TDesc.BackgroundTransparency = 1
        TDesc.Font = Enum.Font.Gotham
        TDesc.Text = content
        TDesc.TextColor3 = Akbar.Theme.Muted
        TDesc.TextSize = 12
        TDesc.TextWrapped = true
        TDesc.TextXAlignment = Enum.TextXAlignment.Left
        TDesc.Parent = Frame

        function Paragraph:Set(newT, newC)
            if newT then TTitle.Text = newT end
            if newC then TDesc.Text = newC end
        end
        function Paragraph:Destroy() Frame:Destroy() end

        return Paragraph
    end

    -- 13. SECTION
    function targetScope:CreateSection(secName)
        secName = secName or "Section"
        local Section = {}

        local SecLabel = Instance.new("TextLabel")
        SecLabel.Name = "Section_" .. secName
        SecLabel.Size = UDim2.new(1, 0, 0, 24)
        SecLabel.BackgroundTransparency = 1
        SecLabel.Font = Enum.Font.GothamBold
        SecLabel.Text = string.upper(secName)
        SecLabel.TextColor3 = Akbar.Theme.Accent
        SecLabel.TextSize = 11
        SecLabel.TextXAlignment = Enum.TextXAlignment.Left
        SecLabel.Parent = containerFrame

        function Section:Set(name) SecLabel.Text = string.upper(name) end
        function Section:Destroy() SecLabel:Destroy() end
        return Section
    end

    -- 14. DIVIDER
    function targetScope:CreateDivider()
        local Divider = {}
        local Line = Instance.new("Frame")
        Line.Name = "Divider"
        Line.Size = UDim2.new(1, 0, 0, 1)
        Line.BackgroundColor3 = Akbar.Theme.Border
        Line.BackgroundTransparency = 0.4
        Line.BorderSizePixel = 0
        Line.Parent = containerFrame

        function Divider:Destroy() Line:Destroy() end
        return Divider
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

--[[
    Hash UI - TOTAL REWRITE
    Style: dark / minimal / purple Hash Hub loading-screen style

    API compatibility:
        local Library = loadstring(game:HttpGet("..."))()
        local UI = Library.Load("ui")
        local Notif = Library.Load("notif")

        local Window = UI:Start({
            Header = "Hash Hub",
            Footer = "Hash Hub | Loaded",
            VisibleKeybind = Enum.KeyCode.RightShift
        })

        local Page = Window:CreatePage({Subject = "Main", Footer = "Main controls"})
        local Section = Page:CreateSection({Header = "Section"})

        Section:CreateButton({Text="Button", Script=function() end})
        Section:CreateCheck({Text="Toggle", Default=false, Script=function(value) end})
        Section:CreateToggle({Text="Toggle", Default=false, Script=function(value) end})
        Section:CreateSlider({Text="Slider", Suffix="", Values={Minimum=1, Maximum=100, Default=50}, Script=function(value) end})
        Section:CreateTextbox({Text="Textbox", Default="", Pattern=nil, Script=function(text) end})
        Section:CreateTextBox(...)
        Section:CreateDropdown({Text="Dropdown", Default="A", Options={"A","B"}, Script=function(value) end})
        Section:CreateKeybind({Text="Keybind", Key=Enum.KeyCode.P, Script=function() end})

        Library:Destroy()
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = {}
local Registry = {
    Guis = {},
    Connections = {},
    Tweens = {},
    Windows = {},
    Notifications = nil
}

local Theme = {
    Bg = Color3.fromRGB(10, 10, 13),
    Bg2 = Color3.fromRGB(16, 16, 21),
    Bg3 = Color3.fromRGB(23, 23, 30),
    Bg4 = Color3.fromRGB(32, 32, 42),
    Bg5 = Color3.fromRGB(42, 42, 55),

    Top = Color3.fromRGB(8, 8, 11),
    Stroke = Color3.fromRGB(70, 63, 92),
    Stroke2 = Color3.fromRGB(45, 42, 58),

    Text = Color3.fromRGB(242, 242, 248),
    Text2 = Color3.fromRGB(195, 195, 207),
    Text3 = Color3.fromRGB(142, 142, 158),
    Text4 = Color3.fromRGB(92, 92, 110),

    Accent = Color3.fromRGB(154, 105, 255),
    Accent2 = Color3.fromRGB(198, 170, 255),
    Accent3 = Color3.fromRGB(105, 68, 190),
    AccentDark = Color3.fromRGB(55, 38, 95),

    Red = Color3.fromRGB(255, 95, 95),
    Green = Color3.fromRGB(120, 235, 170)
}

local function push(t, v)
    table.insert(t, v)
    return v
end

local function connect(sig, fn)
    local c = sig:Connect(fn)
    push(Registry.Connections, c)
    return c
end

local function tween(obj, time, props, style, direction)
    if not obj then return end
    local tw = TweenService:Create(
        obj,
        TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out),
        props
    )
    push(Registry.Tweens, tw)
    tw:Play()
    return tw
end

local function safe(fn, ...)
    local ok, result = pcall(fn, ...)
    if not ok then
        warn("[Hash UI] callback error:", result)
    end
    return ok, result
end

local function new(className, props, children)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    for _, child in ipairs(children or {}) do
        child.Parent = obj
    end
    return obj
end

local function addCorner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
    return c
end

local function addStroke(obj, color, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Stroke
    s.Transparency = transparency or 0.35
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = obj
    return s
end

local function addPadding(obj, l, r, t, b)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, l or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.Parent = obj
    return p
end

local function addGradient(obj, a, b, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, a),
        ColorSequenceKeypoint.new(1, b)
    })
    g.Rotation = rotation or 90
    g.Parent = obj
    return g
end

local function getGuiParent()
    if gethui then
        local ok, parent = pcall(gethui)
        if ok and parent then return parent end
    end
    return CoreGui
end

local function parentGui(gui)
    if syn and syn.protect_gui then
        pcall(function()
            syn.protect_gui(gui)
        end)
    end

    gui.Parent = getGuiParent()
    push(Registry.Guis, gui)
    return gui
end

local function makeScreenGui(name, displayOrder)
    local gui = new("ScreenGui", {
        Name = name or ("HashUI_" .. tostring(math.random(100000, 999999))),
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        DisplayOrder = displayOrder or 999990,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    return parentGui(gui)
end

local function setStroke(strokeObj, props)
    if strokeObj and strokeObj:IsA("UIStroke") then
        tween(strokeObj, 0.15, props)
    end
end

local function getTextWidth(text, size, font)
    local ok, result = pcall(function()
        return TextService:GetTextSize(tostring(text), size or 12, font or Enum.Font.Gotham, Vector2.new(math.huge, math.huge)).X
    end)
    return ok and result or 50
end

local function applyDrag(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragInput = nil
    local startMouse = nil
    local startPos = nil

    connect(handle.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startMouse = input.Position
            startPos = frame.Position

            connect(input.Changed, function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    connect(handle.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    connect(UserInputService.InputChanged, function(input)
        if dragging and input == dragInput then
            local delta = input.Position - startMouse
            local pos = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            tween(frame, 0.065, {Position = pos}, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        end
    end)
end

local function updateCanvas(scroller, layout, extra)
    local function apply()
        scroller.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + (extra or 12))
    end
    apply()
    connect(layout:GetPropertyChangedSignal("AbsoluteContentSize"), apply)
end

local function makeLabel(parent, props)
    props = props or {}
    local label = new("TextLabel", {
        BackgroundTransparency = 1,
        Font = props.Font or Enum.Font.Gotham,
        Text = props.Text or "",
        TextSize = props.TextSize or 12,
        TextColor3 = props.TextColor3 or Theme.Text,
        TextTransparency = props.TextTransparency or 0,
        TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left,
        TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center,
        TextWrapped = props.TextWrapped or false,
        TextTruncate = props.TextTruncate or Enum.TextTruncate.AtEnd,
        RichText = props.RichText or false,
        Size = props.Size or UDim2.fromScale(1, 1),
        Position = props.Position or UDim2.fromOffset(0, 0),
        AnchorPoint = props.AnchorPoint or Vector2.new(0, 0),
        ZIndex = props.ZIndex or 1,
        Parent = parent
    })
    return label
end

local function showLoadingScreen(config)
    config = config or {}

    local gui = makeScreenGui("HashHubLoading", 1000000)

    local bg = new("Frame", {
        Name = "Background",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.Bg,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = gui
    })

    local vignette = new("Frame", {
        Name = "Vignette",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = bg
    })

    local holder = new("Frame", {
        Name = "Holder",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.545),
        Size = UDim2.fromOffset(650, 180),
        BackgroundTransparency = 1,
        Parent = bg
    })

    local scale = new("UIScale", {
        Scale = 0.92,
        Parent = holder
    })

    local row = new("Frame", {
        Name = "TitleRow",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.fromOffset(520, 60),
        BackgroundTransparency = 1,
        Parent = holder
    })

    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = row
    })

    local title = makeLabel(row, {
        Text = config.Title or "hash hub",
        Font = Enum.Font.GothamMedium,
        TextSize = 34,
        TextTransparency = 1,
        TextColor3 = Theme.Text,
        Size = UDim2.fromOffset(0, 60)
    })
    title.AutomaticSize = Enum.AutomaticSize.X
    title.LayoutOrder = 1

    local version = makeLabel(row, {
        Text = config.Version or "[2.6.3]",
        Font = Enum.Font.GothamMedium,
        TextSize = 34,
        TextTransparency = 1,
        TextColor3 = Theme.Accent,
        Size = UDim2.fromOffset(0, 60)
    })
    version.AutomaticSize = Enum.AutomaticSize.X
    version.LayoutOrder = 2

    local lineGlow = new("Frame", {
        Name = "LineGlow",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 70),
        Size = UDim2.fromOffset(0, 2),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = holder
    })
    addCorner(lineGlow, 99)

    local line = new("Frame", {
        Name = "Line",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 70),
        Size = UDim2.fromOffset(0, 1),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = holder
    })
    addCorner(line, 99)

    local subtitle = makeLabel(holder, {
        Text = 'welcome, <font color="rgb(145,110,220)">' .. LocalPlayer.Name .. '</font>, please wait.',
        RichText = true,
        TextSize = 14,
        TextColor3 = Theme.Text2,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 100),
        Size = UDim2.fromOffset(520, 24)
    })

    local dots = makeLabel(holder, {
        Text = "•  •  •",
        Font = Enum.Font.GothamMedium,
        TextSize = 18,
        TextColor3 = Theme.Accent,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 130),
        Size = UDim2.fromOffset(150, 24)
    })

    local alive = true
    task.spawn(function()
        local states = {"•  •  •", "•  •  ◦", "•  ◦  ◦", "◦  ◦  ◦", "•  ◦  ◦", "•  •  ◦"}
        local i = 1
        while alive and dots.Parent do
            dots.Text = states[i]
            i += 1
            if i > #states then i = 1 end
            task.wait(0.18)
        end
    end)

    tween(bg, 0.55, {BackgroundTransparency = 0})
    tween(vignette, 0.85, {BackgroundTransparency = 0.72})
    task.wait(0.15)

    tween(scale, 0.75, {Scale = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    tween(holder, 0.75, {Position = UDim2.fromScale(0.5, 0.5)})
    tween(title, 0.65, {TextTransparency = 0})
    tween(version, 0.65, {TextTransparency = 0})
    task.wait(0.12)

    tween(line, 0.65, {Size = UDim2.fromOffset(230, 1), BackgroundTransparency = 0.1})
    tween(lineGlow, 0.65, {Size = UDim2.fromOffset(280, 2), BackgroundTransparency = 0.78})
    task.wait(0.12)

    tween(subtitle, 0.55, {TextTransparency = 0, Position = UDim2.new(0.5, 0, 0, 94)})
    tween(dots, 0.55, {TextTransparency = 0.12})

    task.wait(tonumber(config.Duration) or 1.35)

    alive = false
    tween(scale, 0.4, {Scale = 0.96}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    tween(holder, 0.4, {Position = UDim2.fromScale(0.5, 0.47)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    tween(title, 0.32, {TextTransparency = 1})
    tween(version, 0.32, {TextTransparency = 1})
    tween(subtitle, 0.32, {TextTransparency = 1, Position = UDim2.new(0.5, 0, 0, 106)})
    tween(dots, 0.25, {TextTransparency = 1})
    tween(line, 0.32, {Size = UDim2.fromOffset(0, 1), BackgroundTransparency = 1})
    tween(lineGlow, 0.32, {Size = UDim2.fromOffset(0, 2), BackgroundTransparency = 1})
    task.wait(0.25)

    tween(bg, 0.5, {BackgroundTransparency = 1})
    tween(vignette, 0.5, {BackgroundTransparency = 1})
    task.wait(0.52)

    if gui and gui.Parent then
        gui:Destroy()
    end
end

local function createNotificationModule()
    if Registry.Notifications then
        return Registry.Notifications
    end

    local gui = makeScreenGui("HashHubNotifications", 999999)

    local holder = new("Frame", {
        Name = "Holder",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -18, 1, -18),
        Size = UDim2.fromOffset(360, 560),
        BackgroundTransparency = 1,
        Parent = gui
    })

    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = holder
    })

    local Notif = {}

    function Notif:Send(config)
        config = config or {}

        local header = tostring(config.Header or config.Title or "Hash Hub")
        local text = tostring(config.Notification or config.Text or "")
        local duration = tonumber(config.Time or config.Duration or 3) or 3

        local card = new("Frame", {
            Name = "Notification",
            Size = UDim2.fromOffset(0, 86),
            BackgroundColor3 = Theme.Bg2,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Parent = holder
        })
        addCorner(card, 11)
        local st = addStroke(card, Theme.Stroke, 1, 1)

        local accent = new("Frame", {
            Name = "Accent",
            Position = UDim2.fromOffset(10, 10),
            Size = UDim2.new(0, 3, 1, -20),
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = card
        })
        addCorner(accent, 99)

        local title = makeLabel(card, {
            Text = header,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextColor3 = Theme.Text,
            TextTransparency = 1,
            Position = UDim2.fromOffset(24, 10),
            Size = UDim2.new(1, -40, 0, 20)
        })

        local body = makeLabel(card, {
            Text = text,
            TextSize = 12,
            TextColor3 = Theme.Text2,
            TextTransparency = 1,
            TextWrapped = true,
            TextYAlignment = Enum.TextYAlignment.Top,
            Position = UDim2.fromOffset(24, 34),
            Size = UDim2.new(1, -40, 0, 42)
        })

        tween(card, 0.3, {Size = UDim2.fromOffset(350, 86), BackgroundTransparency = 0.02})
        tween(st, 0.3, {Transparency = 0.35})
        task.wait(0.04)
        tween(accent, 0.22, {BackgroundTransparency = 0})
        tween(title, 0.22, {TextTransparency = 0})
        tween(body, 0.22, {TextTransparency = 0})

        task.delay(duration, function()
            if not card or not card.Parent then return end
            tween(accent, 0.18, {BackgroundTransparency = 1})
            tween(title, 0.18, {TextTransparency = 1})
            tween(body, 0.18, {TextTransparency = 1})
            tween(st, 0.18, {Transparency = 1})
            tween(card, 0.28, {Size = UDim2.fromOffset(0, 86), BackgroundTransparency = 1})
            task.wait(0.3)
            if card then card:Destroy() end
        end)
    end

    function Notif:Destroy()
        if gui and gui.Parent then gui:Destroy() end
    end

    Registry.Notifications = Notif
    return Notif
end

local function createRipple(parent, x, y)
    local ripple = new("Frame", {
        Name = "Ripple",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(x, y),
        Size = UDim2.fromOffset(0, 0),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        ZIndex = (parent.ZIndex or 1) + 10,
        Parent = parent
    })
    addCorner(ripple, 999)

    tween(ripple, 0.42, {
        Size = UDim2.fromOffset(260, 260),
        BackgroundTransparency = 1
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    task.delay(0.45, function()
        if ripple then ripple:Destroy() end
    end)
end

local function createUIFramework()
    local UI = {}

    function UI:Start(config)
        config = config or {}

        if config.Loading ~= false then
            showLoadingScreen({
                Title = config.LoadingTitle or "hash hub",
                Version = config.Version or config.LoadingVersion or "[2.6.3]",
                Duration = config.LoadingDuration or 1.35
            })
        end

        local gui = makeScreenGui("HashHubRewrite_" .. tostring(math.random(1000, 9999)), 999995)

        local overlay = new("Frame", {
            Name = "DropdownOverlay",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 800,
            Parent = gui
        })

        local shadow = new("Frame", {
            Name = "Shadow",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.515),
            Size = UDim2.fromOffset(790, 620),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = gui
        })
        addCorner(shadow, 22)

        local main = new("Frame", {
            Name = "Main",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.535),
            Size = UDim2.fromOffset(760, 590),
            BackgroundColor3 = Theme.Bg,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Parent = gui
        })
        addCorner(main, 18)
        addGradient(main, Color3.fromRGB(14, 14, 18), Color3.fromRGB(9, 9, 12), 90)
        local mainStroke = addStroke(main, Theme.Stroke, 1, 1)

        local scale = new("UIScale", {
            Scale = 0.96,
            Parent = main
        })

        local topAccent = new("Frame", {
            Name = "TopAccent",
            Size = UDim2.new(1, 0, 0, 2),
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = main
        })

        local topbar = new("Frame", {
            Name = "Topbar",
            Position = UDim2.fromOffset(0, 2),
            Size = UDim2.new(1, 0, 0, 54),
            BackgroundColor3 = Theme.Top,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = main
        })

        local header = makeLabel(topbar, {
            Text = tostring(config.Header or "Hash Hub"),
            Font = Enum.Font.GothamMedium,
            TextSize = 20,
            TextColor3 = Theme.Text,
            TextTransparency = 1,
            Position = UDim2.fromOffset(22, 0),
            Size = UDim2.new(1, -160, 1, 0)
        })

        local headerAccent = new("Frame", {
            Name = "HeaderAccent",
            Position = UDim2.fromOffset(22, 40),
            Size = UDim2.fromOffset(0, 2),
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = topbar
        })
        addCorner(headerAccent, 99)

        local keyText = tostring((config.VisibleKeybind or Enum.KeyCode.RightAlt).Name)
        local keyChip = new("Frame", {
            Name = "KeyChip",
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -16, 0.5, 0),
            Size = UDim2.fromOffset(math.max(92, getTextWidth(keyText, 11, Enum.Font.GothamMedium) + 30), 30),
            BackgroundColor3 = Theme.Bg2,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = topbar
        })
        addCorner(keyChip, 8)
        local keyChipStroke = addStroke(keyChip, Theme.Stroke2, 1, 1)

        local keyLabel = makeLabel(keyChip, {
            Text = keyText,
            Font = Enum.Font.GothamMedium,
            TextSize = 11,
            TextColor3 = Theme.Text3,
            TextTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Center,
            Size = UDim2.fromScale(1, 1)
        })

        local tabHolder = new("Frame", {
            Name = "TabHolder",
            Position = UDim2.fromOffset(18, 72),
            Size = UDim2.new(1, -36, 0, 48),
            BackgroundColor3 = Color3.fromRGB(20, 20, 24),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = main
        })
        addCorner(tabHolder, 14)
        local tabStroke = addStroke(tabHolder, Theme.Stroke2, 1, 1)
        addPadding(tabHolder, 8, 8, 7, 7)

        local tabLayout = new("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = tabHolder
        })

        local pageHolder = new("Frame", {
            Name = "PageHolder",
            Position = UDim2.fromOffset(18, 132),
            Size = UDim2.new(1, -36, 1, -176),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Parent = main
        })

        local footer = makeLabel(main, {
            Text = tostring(config.Footer or "Hash Hub | Loaded"),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = Theme.Text4,
            TextTransparency = 1,
            Position = UDim2.new(0, 22, 1, -36),
            Size = UDim2.new(1, -44, 0, 22)
        })

        applyDrag(main, topbar)

        local window = {
            _gui = gui,
            _main = main,
            _shadow = shadow,
            _pages = {},
            _tabs = {},
            _selected = nil,
            _visible = true,
            _animating = false,
            _dropdownOverlay = overlay,
            _dropdowns = {}
        }

        local function closeAllDropdowns(except)
            for _, dd in ipairs(window._dropdowns) do
                if dd ~= except and dd.Close then
                    dd.Close()
                end
            end
        end

        window.CloseAllDropdowns = closeAllDropdowns

        local function showWindow(state)
            if window._animating then return end
            window._animating = true
            window._visible = state and true or false

            closeAllDropdowns()

            if state then
                shadow.Visible = true
                main.Visible = true
                main.Position = UDim2.fromScale(0.5, 0.535)
                scale.Scale = 0.96
                tween(shadow, 0.28, {BackgroundTransparency = 0.68})
                tween(main, 0.34, {
                    Position = UDim2.fromScale(0.5, 0.5),
                    BackgroundTransparency = 0
                }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                tween(scale, 0.34, {Scale = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                task.wait(0.34)
            else
                tween(shadow, 0.23, {BackgroundTransparency = 1})
                tween(main, 0.23, {
                    Position = UDim2.fromScale(0.5, 0.465),
                    BackgroundTransparency = 1
                }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
                tween(scale, 0.23, {Scale = 0.94}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
                task.wait(0.24)
                main.Visible = false
                shadow.Visible = false
            end

            window._animating = false
        end

        local visibleKey = config.VisibleKeybind or Enum.KeyCode.RightAlt
        connect(UserInputService.InputBegan, function(input, processed)
            if processed then return end
            if input.KeyCode == visibleKey then
                showWindow(not window._visible)
            end
        end)

        connect(overlay.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                closeAllDropdowns()
            end
        end)

        local function selectPage(page)
            if not page then return end
            window._selected = page
            closeAllDropdowns()

            for _, p in ipairs(window._pages) do
                p.Frame.Visible = false
                p.Frame.Position = UDim2.fromOffset(12, 0)
            end

            for pageObj, tabData in pairs(window._tabs) do
                tween(tabData.Button, 0.15, {BackgroundTransparency = 1})
                tween(tabData.Label, 0.15, {TextColor3 = Theme.Text3})
                tween(tabData.Line, 0.15, {BackgroundTransparency = 1, Size = UDim2.fromOffset(24, 2)})
            end

            page.Frame.Visible = true
            page.Frame.Position = UDim2.fromOffset(14, 0)
            tween(page.Frame, 0.22, {Position = UDim2.fromOffset(0, 0)})
            footer.Text = page.Footer

            local tab = window._tabs[page]
            if tab then
                tween(tab.Button, 0.15, {BackgroundTransparency = 0})
                tween(tab.Label, 0.15, {TextColor3 = Theme.Text})
                tween(tab.Line, 0.15, {BackgroundTransparency = 0, Size = UDim2.fromOffset(36, 2)})
            end
        end

        function window:Notify(text, title, duration)
            local notif = createNotificationModule()
            notif:Send({
                Header = title or "Hash Hub",
                Notification = tostring(text),
                Time = duration or 3
            })
        end

        function window:SetVisible(state)
            showWindow(state == true)
        end

        function window:Destroy()
            if gui and gui.Parent then gui:Destroy() end
        end

        function window:CreatePage(pageConfig)
            pageConfig = pageConfig or {}

            local page = {
                Subject = tostring(pageConfig.Subject or "Page"),
                Footer = tostring(pageConfig.Footer or pageConfig.Subject or "Hash Hub"),
                Sections = {}
            }

            local buttonWidth = math.max(92, getTextWidth(page.Subject, 12, Enum.Font.GothamMedium) + 34)
            local tabButton = new("TextButton", {
                Name = "Tab_" .. page.Subject,
                Size = UDim2.fromOffset(buttonWidth + 8, 32),
                BackgroundColor3 = Theme.Bg3,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                Text = "",
                Parent = tabHolder
            })
            addCorner(tabButton, 9)

            local tabLabel = makeLabel(tabButton, {
                Text = page.Subject,
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                TextColor3 = Theme.Text3,
                TextXAlignment = Enum.TextXAlignment.Center,
                Size = UDim2.fromScale(1, 1)
            })

            local tabLine = new("Frame", {
                Name = "Line",
                AnchorPoint = Vector2.new(0.5, 1),
                Position = UDim2.new(0.5, 0, 1, -3),
                Size = UDim2.fromOffset(24, 2),
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = tabButton
            })
            addCorner(tabLine, 99)

            local frame = new("Frame", {
                Name = "Page_" .. page.Subject,
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Visible = false,
                Parent = pageHolder
            })
            page.Frame = frame

            local left = new("ScrollingFrame", {
                Name = "Left",
                Position = UDim2.fromOffset(0, 0),
                Size = UDim2.new(0.5, -8, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Theme.Accent,
                CanvasSize = UDim2.fromOffset(0, 0),
                Parent = frame
            })

            local right = new("ScrollingFrame", {
                Name = "Right",
                Position = UDim2.new(0.5, 8, 0, 0),
                Size = UDim2.new(0.5, -8, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Theme.Accent,
                CanvasSize = UDim2.fromOffset(0, 0),
                Parent = frame
            })

            addPadding(left, 2, 4, 2, 14)
            addPadding(right, 4, 2, 2, 14)

            local leftLayout = new("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10),
                Parent = left
            })

            local rightLayout = new("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10),
                Parent = right
            })

            updateCanvas(left, leftLayout, 18)
            updateCanvas(right, rightLayout, 18)

            page.Left = left
            page.Right = right
            page.LeftLayout = leftLayout
            page.RightLayout = rightLayout

            connect(tabButton.MouseButton1Click, function()
                selectPage(page)
            end)

            connect(tabButton.MouseEnter, function()
                if window._selected ~= page then
                    tween(tabButton, 0.15, {BackgroundTransparency = 0.55})
                    tween(tabLabel, 0.15, {TextColor3 = Theme.Text2})
                end
            end)

            connect(tabButton.MouseLeave, function()
                if window._selected ~= page then
                    tween(tabButton, 0.15, {BackgroundTransparency = 1})
                    tween(tabLabel, 0.15, {TextColor3 = Theme.Text3})
                end
            end)

            push(window._pages, page)
            window._tabs[page] = {
                Button = tabButton,
                Label = tabLabel,
                Line = tabLine
            }

            if not window._selected then
                selectPage(page)
            end

            local pageTools = {}

            function pageTools:CreateSection(sectionConfig)
                sectionConfig = sectionConfig or {}

                local target = leftLayout.AbsoluteContentSize.Y <= rightLayout.AbsoluteContentSize.Y and left or right

                local section = new("Frame", {
                    Name = "Section",
                    Size = UDim2.new(1, -2, 0, 60),
                    BackgroundColor3 = Color3.fromRGB(20, 20, 24),
                    BorderSizePixel = 0,
                    ClipsDescendants = false,
                    Parent = target
                })
                addCorner(section, 15)
                local sectionStroke = addStroke(section, Theme.Stroke2, 0.42, 1)

                local sectionTop = new("Frame", {
                    Name = "SectionTop",
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = Theme.Accent,
                    BackgroundTransparency = 0.2,
                    BorderSizePixel = 0,
                    Parent = section
                })

                local sectionHeader = makeLabel(section, {
                    Text = tostring(sectionConfig.Header or "Section"),
                    Font = Enum.Font.GothamMedium,
                    TextSize = 13,
                    TextColor3 = Theme.Text,
                    Position = UDim2.fromOffset(14, 11),
                    Size = UDim2.new(1, -24, 0, 18)
                })

                local body = new("Frame", {
                    Name = "Body",
                    Position = UDim2.fromOffset(12, 40),
                    Size = UDim2.new(1, -24, 1, -52),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    Parent = section
                })

                local bodyLayout = new("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 8),
                    Parent = body
                })

                local function updateSection()
                    section.Size = UDim2.new(1, -2, 0, bodyLayout.AbsoluteContentSize.Y + 56)
                end
                updateSection()
                connect(bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"), updateSection)

                local sectionTools = {}

                local function componentHolder(height)
                    return new("Frame", {
                        Name = "Component",
                        Size = UDim2.new(1, 0, 0, height),
                        BackgroundTransparency = 1,
                        ClipsDescendants = false,
                        Parent = body
                    })
                end

                local function baseButton(parent, text)
                    local button = new("TextButton", {
                        Name = "Button",
                        Size = UDim2.fromScale(1, 1),
                        BackgroundColor3 = Theme.Bg3,
                        BorderSizePixel = 0,
                        AutoButtonColor = false,
                        Text = "",
                        ClipsDescendants = true,
                        Parent = parent
                    })
                    addCorner(button, 9)
                    local bStroke = addStroke(button, Theme.Stroke2, 0.52, 1)

                    local label = makeLabel(button, {
                        Text = text,
                        Font = Enum.Font.GothamMedium,
                        TextSize = 12,
                        TextColor3 = Theme.Text,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        Position = UDim2.fromOffset(10, 0),
                        Size = UDim2.new(1, -20, 1, 0),
                        ZIndex = button.ZIndex + 1
                    })

                    connect(button.MouseEnter, function()
                        tween(button, 0.15, {BackgroundColor3 = Theme.Bg4})
                        setStroke(bStroke, {Color = Theme.Accent, Transparency = 0.22})
                    end)

                    connect(button.MouseLeave, function()
                        tween(button, 0.15, {BackgroundColor3 = Theme.Bg3})
                        setStroke(bStroke, {Color = Theme.Stroke2, Transparency = 0.52})
                    end)

                    connect(button.MouseButton1Down, function(x, y)
                        tween(button, 0.08, {BackgroundColor3 = Theme.AccentDark})
                    end)

                    connect(button.MouseButton1Up, function()
                        tween(button, 0.1, {BackgroundColor3 = Theme.Bg4})
                    end)

                    return button, label, bStroke
                end

                function sectionTools:CreateButton(buttonConfig)
                    buttonConfig = buttonConfig or {}

                    local holder = componentHolder(36)
                    local button, label = baseButton(holder, tostring(buttonConfig.Text or "Button"))

                    connect(button.MouseButton1Click, function()
                        local pos = UserInputService:GetMouseLocation()
                        local localX = pos.X - button.AbsolutePosition.X
                        local localY = pos.Y - button.AbsolutePosition.Y
                        createRipple(button, localX, localY)
                        safe(buttonConfig.Script or function() end)
                    end)

                    updateSection()

                    local tools = {}
                    function tools.SetText(new)
                        label.Text = tostring(new)
                    end
                    function tools:SetText(new)
                        label.Text = tostring(new)
                    end
                    return tools
                end

                function sectionTools:CreateCheck(checkConfig)
                    checkConfig = checkConfig or {}

                    local state = checkConfig.Default == true
                    local holder = componentHolder(34)

                    local button = new("TextButton", {
                        Name = "Check",
                        Size = UDim2.fromScale(1, 1),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        AutoButtonColor = false,
                        Text = "",
                        Parent = holder
                    })

                    local box = new("Frame", {
                        Name = "Box",
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 2, 0.5, 0),
                        Size = UDim2.fromOffset(20, 20),
                        BackgroundColor3 = state and Theme.Accent or Theme.Bg3,
                        BorderSizePixel = 0,
                        Parent = button
                    })
                    addCorner(box, 6)
                    local boxStroke = addStroke(box, state and Theme.Accent2 or Theme.Stroke2, 0.35, 1)

                    local dot = new("Frame", {
                        Name = "Dot",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = state and UDim2.fromOffset(8, 8) or UDim2.fromOffset(0, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = state and 0 or 1,
                        BorderSizePixel = 0,
                        Parent = box
                    })
                    addCorner(dot, 999)

                    local label = makeLabel(button, {
                        Text = tostring(checkConfig.Text or "Check"),
                        Font = Enum.Font.Gotham,
                        TextSize = 12,
                        TextColor3 = Theme.Text,
                        Position = UDim2.fromOffset(32, 0),
                        Size = UDim2.new(1, -34, 1, 0)
                    })

                    local function setValue(newValue, fire)
                        state = newValue and true or false
                        tween(box, 0.16, {BackgroundColor3 = state and Theme.Accent or Theme.Bg3})
                        tween(boxStroke, 0.16, {
                            Color = state and Theme.Accent2 or Theme.Stroke2,
                            Transparency = state and 0.1 or 0.35
                        })
                        tween(dot, 0.16, {
                            Size = state and UDim2.fromOffset(8, 8) or UDim2.fromOffset(0, 0),
                            BackgroundTransparency = state and 0 or 1
                        })

                        if fire then
                            safe(checkConfig.Script or function() end, state)
                        end
                    end

                    connect(button.MouseEnter, function()
                        tween(label, 0.14, {TextColor3 = Theme.Accent2})
                    end)

                    connect(button.MouseLeave, function()
                        tween(label, 0.14, {TextColor3 = Theme.Text})
                    end)

                    connect(button.MouseButton1Click, function()
                        setValue(not state, true)
                    end)

                    updateSection()

                    local tools = {}
                    function tools.SetText(new)
                        label.Text = tostring(new)
                    end
                    function tools:SetText(new)
                        label.Text = tostring(new)
                    end
                    function tools.SetValue(new)
                        setValue(new, true)
                    end
                    function tools:SetValue(new)
                        setValue(new, true)
                    end
                    function tools.GetValue()
                        return state
                    end
                    function tools:GetValue()
                        return state
                    end

                    return tools
                end

                sectionTools.CreateToggle = sectionTools.CreateCheck

                function sectionTools:CreateSlider(sliderConfig)
                    sliderConfig = sliderConfig or {}
                    sliderConfig.Values = sliderConfig.Values or {}

                    local min = tonumber(sliderConfig.Values.Minimum) or 0
                    local max = tonumber(sliderConfig.Values.Maximum) or 100
                    local value = tonumber(sliderConfig.Values.Default) or min
                    local suffix = tostring(sliderConfig.Suffix or "")
                    if max == min then max = min + 1 end
                    value = math.clamp(value, min, max)

                    local holder = componentHolder(54)

                    local label = makeLabel(holder, {
                        Text = tostring(sliderConfig.Text or "Slider"),
                        Font = Enum.Font.Gotham,
                        TextSize = 12,
                        TextColor3 = Theme.Text,
                        Position = UDim2.fromOffset(0, 0),
                        Size = UDim2.new(1, -72, 0, 18)
                    })

                    local valueLabel = makeLabel(holder, {
                        Text = tostring(value) .. suffix,
                        Font = Enum.Font.GothamMedium,
                        TextSize = 12,
                        TextColor3 = Theme.Accent2,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, 0, 0, 0),
                        Size = UDim2.fromOffset(70, 18)
                    })

                    local bar = new("TextButton", {
                        Name = "SliderBar",
                        Position = UDim2.fromOffset(0, 29),
                        Size = UDim2.new(1, 0, 0, 16),
                        BackgroundColor3 = Theme.Bg3,
                        BorderSizePixel = 0,
                        AutoButtonColor = false,
                        Text = "",
                        ClipsDescendants = true,
                        Parent = holder
                    })
                    addCorner(bar, 999)
                    local barStroke = addStroke(bar, Theme.Stroke2, 0.5, 1)

                    local fill = new("Frame", {
                        Name = "Fill",
                        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                        BackgroundColor3 = Theme.Accent,
                        BorderSizePixel = 0,
                        Parent = bar
                    })
                    addCorner(fill, 999)

                    local knob = new("Frame", {
                        Name = "Knob",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
                        Size = UDim2.fromOffset(14, 14),
                        BackgroundColor3 = Theme.Text,
                        BorderSizePixel = 0,
                        Parent = bar
                    })
                    addCorner(knob, 999)

                    local dragging = false

                    local function applyFromAlpha(alpha, fire)
                        alpha = math.clamp(alpha, 0, 1)
                        local raw = min + ((max - min) * alpha)
                        value = math.floor(raw + 0.5)
                        local realAlpha = (value - min) / (max - min)

                        valueLabel.Text = tostring(value) .. suffix
                        tween(fill, 0.05, {Size = UDim2.new(realAlpha, 0, 1, 0)}, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                        tween(knob, 0.05, {Position = UDim2.new(realAlpha, 0, 0.5, 0)}, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

                        if fire then
                            safe(sliderConfig.Script or function() end, value)
                        end
                    end

                    local function updateFromX(x, fire)
                        local alpha = (x - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X)
                        applyFromAlpha(alpha, fire)
                    end

                    connect(bar.MouseEnter, function()
                        tween(barStroke, 0.14, {Color = Theme.Accent, Transparency = 0.2})
                    end)

                    connect(bar.MouseLeave, function()
                        if not dragging then
                            tween(barStroke, 0.14, {Color = Theme.Stroke2, Transparency = 0.5})
                        end
                    end)

                    connect(bar.MouseButton1Down, function()
                        dragging = true
                        updateFromX(Mouse.X, true)
                    end)

                    connect(UserInputService.InputEnded, function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                            tween(barStroke, 0.14, {Color = Theme.Stroke2, Transparency = 0.5})
                        end
                    end)

                    connect(UserInputService.InputChanged, function(input)
                        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                            updateFromX(input.Position.X, true)
                        end
                    end)

                    updateSection()

                    local tools = {}
                    function tools.SetText(new)
                        label.Text = tostring(new)
                    end
                    function tools:SetText(new)
                        label.Text = tostring(new)
                    end
                    function tools.SetValue(new)
                        new = tonumber(new) or min
                        new = math.clamp(new, min, max)
                        applyFromAlpha((new - min) / (max - min), true)
                    end
                    function tools:SetValue(new)
                        tools.SetValue(new)
                    end
                    function tools.GetValue()
                        return value
                    end
                    function tools:GetValue()
                        return value
                    end
                    function tools.ResetValue()
                        tools.SetValue(min)
                    end
                    function tools:ResetValue()
                        tools.SetValue(min)
                    end

                    return tools
                end

                function sectionTools:CreateTextBox(textBoxConfig)
                    textBoxConfig = textBoxConfig or {}

                    local holder = componentHolder(56)

                    local label = makeLabel(holder, {
                        Text = tostring(textBoxConfig.Text or "Textbox"),
                        Font = Enum.Font.Gotham,
                        TextSize = 12,
                        TextColor3 = Theme.Text,
                        Position = UDim2.fromOffset(0, 0),
                        Size = UDim2.new(1, 0, 0, 18)
                    })

                    local boxFrame = new("Frame", {
                        Name = "TextBoxFrame",
                        Position = UDim2.fromOffset(0, 24),
                        Size = UDim2.new(1, 0, 0, 30),
                        BackgroundColor3 = Theme.Bg3,
                        BorderSizePixel = 0,
                        Parent = holder
                    })
                    addCorner(boxFrame, 9)
                    local boxStroke = addStroke(boxFrame, Theme.Stroke2, 0.5, 1)

                    local box = new("TextBox", {
                        Name = "Input",
                        Position = UDim2.fromOffset(10, 0),
                        Size = UDim2.new(1, -20, 1, 0),
                        BackgroundTransparency = 1,
                        ClearTextOnFocus = false,
                        Font = Enum.Font.Gotham,
                        Text = "",
                        PlaceholderText = tostring(textBoxConfig.Default or ""),
                        TextColor3 = Theme.Text,
                        PlaceholderColor3 = Theme.Text3,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Parent = boxFrame
                    })

                    local function applyPattern(text)
                        text = tostring(text or "")
                        local pattern = tostring(textBoxConfig.Pattern or ""):lower()

                        if pattern == "number" or pattern == "numeric" then
                            return text:gsub("%D", "")
                        elseif pattern == "lower" or pattern == "lowercase" then
                            return text:lower()
                        elseif pattern == "upper" or pattern == "uppercase" then
                            return text:upper()
                        end

                        return text
                    end

                    local function submit()
                        local text = applyPattern(box.Text)
                        box.Text = text
                        safe(textBoxConfig.Script or function() end, text)
                    end

                    connect(box.Focused, function()
                        tween(boxStroke, 0.15, {Color = Theme.Accent, Transparency = 0.18})
                    end)

                    connect(box.FocusLost, function(enterPressed)
                        tween(boxStroke, 0.15, {Color = Theme.Stroke2, Transparency = 0.5})
                        if enterPressed then
                            submit()
                        end
                    end)

                    updateSection()

                    local tools = {}
                    function tools.SetText(new)
                        label.Text = tostring(new)
                    end
                    function tools:SetText(new)
                        label.Text = tostring(new)
                    end
                    function tools.SetInput(new)
                        box.Text = applyPattern(new)
                    end
                    function tools:SetInput(new)
                        box.Text = applyPattern(new)
                    end
                    function tools.GetInput()
                        return box.Text
                    end
                    function tools:GetInput()
                        return box.Text
                    end
                    function tools.Submit()
                        submit()
                    end
                    function tools:Submit()
                        submit()
                    end
                    function tools.ClearInput()
                        box.Text = ""
                    end
                    function tools:ClearInput()
                        box.Text = ""
                    end

                    return tools
                end

                sectionTools.CreateTextbox = sectionTools.CreateTextBox

                function sectionTools:CreateDropdown(dropConfig)
                    dropConfig = dropConfig or {}

                    local selected = tostring(dropConfig.Default or ". . .")
                    local options = dropConfig.Options or {}
                    local optionButtons = {}
                    local opened = false
                    local popup = nil

                    local holder = componentHolder(56)

                    local label = makeLabel(holder, {
                        Text = tostring(dropConfig.Text or "Dropdown"),
                        Font = Enum.Font.Gotham,
                        TextSize = 12,
                        TextColor3 = Theme.Text,
                        Position = UDim2.fromOffset(0, 0),
                        Size = UDim2.new(1, 0, 0, 18)
                    })

                    local button = new("TextButton", {
                        Name = "DropdownButton",
                        Position = UDim2.fromOffset(0, 24),
                        Size = UDim2.new(1, 0, 0, 30),
                        BackgroundColor3 = Theme.Bg3,
                        BorderSizePixel = 0,
                        AutoButtonColor = false,
                        Text = "",
                        Parent = holder
                    })
                    addCorner(button, 9)
                    local btnStroke = addStroke(button, Theme.Stroke2, 0.5, 1)

                    local selectedLabel = makeLabel(button, {
                        Text = selected,
                        Font = Enum.Font.Gotham,
                        TextSize = 12,
                        TextColor3 = Theme.Text,
                        Position = UDim2.fromOffset(10, 0),
                        Size = UDim2.new(1, -40, 1, 0)
                    })

                    local arrow = makeLabel(button, {
                        Text = "⌄",
                        Font = Enum.Font.GothamBold,
                        TextSize = 14,
                        TextColor3 = Theme.Text3,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -7, 0, 0),
                        Size = UDim2.fromOffset(22, 30)
                    })

                    local dropdownController = {}

                    local function destroyPopup()
                        opened = false
                        arrow.Text = "⌄"
                        tween(btnStroke, 0.14, {Color = Theme.Stroke2, Transparency = 0.5})
                        if popup then
                            local old = popup
                            popup = nil
                            tween(old, 0.13, {BackgroundTransparency = 1, Size = UDim2.fromOffset(old.Size.X.Offset, 0)})
                            task.delay(0.15, function()
                                if old then old:Destroy() end
                            end)
                        end
                    end

                    dropdownController.Close = destroyPopup
                    table.insert(window._dropdowns, dropdownController)

                    local function updateSelectedColors()
                        for name, data in pairs(optionButtons) do
                            local active = name == selected
                            if data.Text then
                                data.Text.TextColor3 = active and Theme.Accent2 or Theme.Text2
                            end
                            if data.Bar then
                                data.Bar.BackgroundTransparency = active and 0 or 1
                            end
                            if data.Button then
                                data.Button.BackgroundColor3 = active and Theme.AccentDark or Theme.Bg3
                            end
                        end
                    end

                    local function choose(value, fire)
                        selected = tostring(value)
                        selectedLabel.Text = selected
                        updateSelectedColors()
                        destroyPopup()

                        if fire then
                            safe(dropConfig.Script or function() end, selected)
                        end
                    end

                    local function createPopup()
                        closeAllDropdowns(dropdownController)

                        opened = true
                        arrow.Text = "⌃"
                        tween(btnStroke, 0.14, {Color = Theme.Accent, Transparency = 0.15})

                        local abs = button.AbsolutePosition
                        local size = button.AbsoluteSize
                        local maxHeight = 190
                        local height = math.clamp(#options * 30 + 10, 40, maxHeight)

                        popup = new("Frame", {
                            Name = "DropdownPopup",
                            Position = UDim2.fromOffset(abs.X, abs.Y + size.Y + 5),
                            Size = UDim2.fromOffset(size.X, 0),
                            BackgroundColor3 = Theme.Bg2,
                            BackgroundTransparency = 0,
                            BorderSizePixel = 0,
                            ClipsDescendants = true,
                            ZIndex = 850,
                            Parent = overlay
                        })
                        addCorner(popup, 10)
                        local popupStroke = addStroke(popup, Theme.Stroke, 0.28, 1)

                        local scroller = new("ScrollingFrame", {
                            Name = "Options",
                            Size = UDim2.fromScale(1, 1),
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            ScrollBarThickness = 2,
                            ScrollBarImageColor3 = Theme.Accent,
                            CanvasSize = UDim2.fromOffset(0, 0),
                            ZIndex = 851,
                            Parent = popup
                        })
                        addPadding(scroller, 6, 6, 6, 6)

                        local layout = new("UIListLayout", {
                            SortOrder = Enum.SortOrder.LayoutOrder,
                            Padding = UDim.new(0, 5),
                            Parent = scroller
                        })

                        optionButtons = {}

                        for _, option in ipairs(options) do
                            local opt = tostring(option)

                            local optButton = new("TextButton", {
                                Name = "Option",
                                Size = UDim2.new(1, -4, 0, 25),
                                BackgroundColor3 = opt == selected and Theme.AccentDark or Theme.Bg3,
                                BorderSizePixel = 0,
                                AutoButtonColor = false,
                                Text = "",
                                ZIndex = 852,
                                Parent = scroller
                            })
                            addCorner(optButton, 7)

                            local bar = new("Frame", {
                                Name = "SelectedBar",
                                Position = UDim2.fromOffset(0, 5),
                                Size = UDim2.new(0, 2, 1, -10),
                                BackgroundColor3 = Theme.Accent,
                                BackgroundTransparency = opt == selected and 0 or 1,
                                BorderSizePixel = 0,
                                ZIndex = 853,
                                Parent = optButton
                            })
                            addCorner(bar, 99)

                            local optText = makeLabel(optButton, {
                                Text = opt,
                                Font = Enum.Font.Gotham,
                                TextSize = 12,
                                TextColor3 = opt == selected and Theme.Accent2 or Theme.Text2,
                                Position = UDim2.fromOffset(9, 0),
                                Size = UDim2.new(1, -16, 1, 0),
                                ZIndex = 854
                            })

                            connect(optButton.MouseEnter, function()
                                if selected ~= opt then
                                    tween(optButton, 0.12, {BackgroundColor3 = Theme.Bg4})
                                end
                            end)

                            connect(optButton.MouseLeave, function()
                                if selected ~= opt then
                                    tween(optButton, 0.12, {BackgroundColor3 = Theme.Bg3})
                                end
                            end)

                            connect(optButton.MouseButton1Click, function()
                                choose(opt, true)
                            end)

                            optionButtons[opt] = {
                                Button = optButton,
                                Text = optText,
                                Bar = bar
                            }
                        end

                        task.defer(function()
                            scroller.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 12)
                        end)

                        tween(popup, 0.16, {Size = UDim2.fromOffset(size.X, height)}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                    end

                    connect(button.MouseButton1Click, function()
                        if opened then
                            destroyPopup()
                        else
                            createPopup()
                        end
                    end)

                    connect(button.MouseEnter, function()
                        if not opened then
                            tween(btnStroke, 0.14, {Color = Theme.Accent, Transparency = 0.2})
                        end
                    end)

                    connect(button.MouseLeave, function()
                        if not opened then
                            tween(btnStroke, 0.14, {Color = Theme.Stroke2, Transparency = 0.5})
                        end
                    end)

                    connect(main:GetPropertyChangedSignal("Visible"), function()
                        if not main.Visible then
                            destroyPopup()
                        end
                    end)

                    updateSection()

                    local tools = {}

                    function tools.SetText(new)
                        label.Text = tostring(new)
                    end
                    function tools:SetText(new)
                        label.Text = tostring(new)
                    end

                    function tools.SetValue(new)
                        local value = tostring(new)
                        selected = value
                        selectedLabel.Text = value
                        updateSelectedColors()
                    end
                    function tools:SetValue(new)
                        tools.SetValue(new)
                    end

                    function tools.GetValue()
                        return selected
                    end
                    function tools:GetValue()
                        return selected
                    end

                    function tools.AddOption(option)
                        table.insert(options, tostring(option))
                    end
                    function tools:AddOption(option)
                        tools.AddOption(option)
                    end

                    function tools.RemoveOption(option)
                        option = tostring(option)
                        for i = #options, 1, -1 do
                            if tostring(options[i]) == option then
                                table.remove(options, i)
                            end
                        end
                        if selected == option then
                            selected = tostring(options[1] or ". . .")
                            selectedLabel.Text = selected
                        end
                    end
                    function tools:RemoveOption(option)
                        tools.RemoveOption(option)
                    end

                    function tools.ClearOptions()
                        table.clear(options)
                        selected = ". . ."
                        selectedLabel.Text = selected
                        destroyPopup()
                    end
                    function tools:ClearOptions()
                        tools.ClearOptions()
                    end

                    function tools.Refresh(newOptions)
                        options = {}
                        for _, v in ipairs(newOptions or {}) do
                            table.insert(options, tostring(v))
                        end

                        if not table.find(options, selected) then
                            selected = tostring(options[1] or ". . .")
                            selectedLabel.Text = selected
                        end

                        destroyPopup()
                    end
                    function tools:Refresh(newOptions)
                        tools.Refresh(newOptions)
                    end

                    tools.Update = tools.Refresh
                    tools.update = tools.Refresh

                    return tools
                end

                function sectionTools:CreateKeybind(keybindConfig)
                    keybindConfig = keybindConfig or {}

                    local key = keybindConfig.Key or Enum.KeyCode.P
                    local listening = false

                    local holder = componentHolder(36)

                    local button = new("TextButton", {
                        Name = "Keybind",
                        Size = UDim2.fromScale(1, 1),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        AutoButtonColor = false,
                        Text = "",
                        Parent = holder
                    })

                    local label = makeLabel(button, {
                        Text = tostring(keybindConfig.Text or "Keybind"),
                        Font = Enum.Font.Gotham,
                        TextSize = 12,
                        TextColor3 = Theme.Text,
                        Size = UDim2.new(1, -82, 1, 0)
                    })

                    local chip = new("Frame", {
                        Name = "Chip",
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, 0, 0.5, 0),
                        Size = UDim2.fromOffset(74, 28),
                        BackgroundColor3 = Theme.Bg3,
                        BorderSizePixel = 0,
                        Parent = button
                    })
                    addCorner(chip, 8)
                    local chipStroke = addStroke(chip, Theme.Stroke2, 0.5, 1)

                    local keyLabel = makeLabel(chip, {
                        Text = key.Name,
                        Font = Enum.Font.GothamMedium,
                        TextSize = 11,
                        TextColor3 = Theme.Accent2,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        Size = UDim2.fromScale(1, 1)
                    })

                    connect(button.MouseButton1Click, function()
                        listening = true
                        keyLabel.Text = "..."
                        tween(chipStroke, 0.15, {Color = Theme.Accent, Transparency = 0.15})
                    end)

                    connect(UserInputService.InputBegan, function(input, processed)
                        if listening then
                            if input.KeyCode ~= Enum.KeyCode.Unknown then
                                key = input.KeyCode
                                keyLabel.Text = key.Name
                                listening = false
                                tween(chipStroke, 0.15, {Color = Theme.Stroke2, Transparency = 0.5})
                            end
                            return
                        end

                        if not processed and input.KeyCode == key then
                            safe(keybindConfig.Script or function() end)
                        end
                    end)

                    updateSection()

                    local tools = {}
                    function tools.SetText(new)
                        label.Text = tostring(new)
                    end
                    function tools:SetText(new)
                        label.Text = tostring(new)
                    end
                    function tools.SetKey(new)
                        key = new
                        keyLabel.Text = key.Name
                    end
                    function tools:SetKey(new)
                        tools.SetKey(new)
                    end
                    function tools.GetKey()
                        return key
                    end
                    function tools:GetKey()
                        return key
                    end

                    return tools
                end

                table.insert(page.Sections, sectionTools)
                return sectionTools
            end

            return pageTools
        end

        -- entrance animation
        tween(shadow, 0.32, {BackgroundTransparency = 0.68})
        tween(main, 0.38, {Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 0})
        tween(scale, 0.38, {Scale = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        tween(mainStroke, 0.25, {Transparency = 0.22})
        tween(topAccent, 0.26, {BackgroundTransparency = 0})
        tween(topbar, 0.26, {BackgroundTransparency = 0})
        tween(header, 0.26, {TextTransparency = 0})
        if headerAccent then tween(headerAccent, 0.34, {Size = UDim2.fromOffset(82, 2), BackgroundTransparency = 0.05}) end
        tween(keyChip, 0.26, {BackgroundTransparency = 0})
        tween(keyChipStroke, 0.26, {Transparency = 0.45})
        tween(keyLabel, 0.26, {TextTransparency = 0})
        tween(tabHolder, 0.26, {BackgroundTransparency = 0})
        tween(tabStroke, 0.26, {Transparency = 0.5})
        tween(footer, 0.26, {TextTransparency = 0})

        table.insert(Registry.Windows, window)
        return window
    end

    return UI
end

function Library.Load(name)
    name = tostring(name or ""):lower()

    if name:find("notif", 1, true) then
        return createNotificationModule()
    end

    if name:find("ui", 1, true) then
        return createUIFramework()
    end

    return {}
end

function Library:Destroy()
    for _, tw in ipairs(Registry.Tweens) do
        pcall(function()
            tw:Cancel()
        end)
    end
    table.clear(Registry.Tweens)

    for _, conn in ipairs(Registry.Connections) do
        pcall(function()
            conn:Disconnect()
        end)
    end
    table.clear(Registry.Connections)

    for _, gui in ipairs(Registry.Guis) do
        pcall(function()
            if gui and gui.Parent then
                gui:Destroy()
            end
        end)
    end
    table.clear(Registry.Guis)
    table.clear(Registry.Windows)
    Registry.Notifications = nil
end

Library.Destroy = Library.Destroy

return Library

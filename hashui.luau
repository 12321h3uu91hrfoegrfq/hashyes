--[[

    Hash Hub UI - loading-screen style rewrite
    Reworked to match the dark centered Hash Hub loading screen:
    - Smooth loading intro
    - Smooth RightAlt open/close
    - Fixed dropdown sizing / z-order
    - Working Destroy()
    - Same main API as the old bungiesLibrary UI

    Usage:
        local Library = loadstring(game:HttpGet("..."))()
        local UI = Library.Load("ui")
        local Notif = Library.Load("notif")

        local Window = UI:Start({
            Header = "Hash Hub",
            Version = "2.6.3",
            Footer = "Hash Hub | Loaded",
            VisibleKeybind = Enum.KeyCode.RightAlt
        })

]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGuiService = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local HashHubLibrary = {}
getgenv().ui = false

--// theme
local THEME = {
    Background = Color3.fromRGB(24, 24, 24),
    Background2 = Color3.fromRGB(20, 20, 20),
    Background3 = Color3.fromRGB(16, 16, 16),
    Card = Color3.fromRGB(19, 19, 19),
    Card2 = Color3.fromRGB(22, 22, 22),
    Stroke = Color3.fromRGB(42, 42, 42),
    StrokeSoft = Color3.fromRGB(33, 33, 33),
    Text = Color3.fromRGB(205, 205, 205),
    TextBright = Color3.fromRGB(232, 232, 232),
    Muted = Color3.fromRGB(160, 160, 160),
    Muted2 = Color3.fromRGB(115, 115, 115),
    Purple = Color3.fromRGB(125, 95, 210),
    Purple2 = Color3.fromRGB(95, 71, 170),
    PurpleDark = Color3.fromRGB(58, 43, 105),
    Red = Color3.fromRGB(220, 85, 85)
}

local EASE_FAST = TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local EASE_MED = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local EASE_SLOW = TweenInfo.new(0.48, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function protectGui(gui)
    local parent = nil

    if type(gethui) == "function" then
        pcall(function()
            parent = gethui()
        end)
    end

    if not parent then
        parent = CoreGuiService
    end

    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
        end
    end)

    gui.Parent = parent
end

local function create(className, props, children)
    local obj = Instance.new(className)

    if props then
        for prop, value in pairs(props) do
            obj[prop] = value
        end
    end

    if children then
        for _, child in ipairs(children) do
            child.Parent = obj
        end
    end

    return obj
end

local function tween(obj, info, props)
    local tw = TweenService:Create(obj, info or EASE_FAST, props)
    tw:Play()
    return tw
end

local function corner(obj, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius or 6),
        Parent = obj
    })
end

local function stroke(obj, color, transparency, thickness)
    return create("UIStroke", {
        Color = color or THEME.Stroke,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = obj
    })
end

local function padding(obj, left, right, top, bottom)
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
        Parent = obj
    })
end

local function listLayout(obj, direction, pad)
    return create("UIListLayout", {
        FillDirection = direction or Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, pad or 0),
        Parent = obj
    })
end

local function htmlEscape(str)
    str = tostring(str or "")
    str = str:gsub("&", "&amp;")
    str = str:gsub("<", "&lt;")
    str = str:gsub(">", "&gt;")
    return str
end

local function genKey()
    local chars = {}
    for i = string.byte("A"), string.byte("Z") do
        table.insert(chars, string.char(i))
    end
    for i = string.byte("0"), string.byte("9") do
        table.insert(chars, string.char(i))
    end

    local function part()
        local t = {}
        for i = 1, 5 do
            t[i] = chars[math.random(1, #chars)]
        end
        return table.concat(t)
    end

    return "hashhub_[" .. part() .. "-" .. part() .. "-" .. part() .. "-" .. part() .. "]"
end

local function makeText(parent, props)
    props = props or {}

    local label = create("TextLabel", {
        Parent = parent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Font = props.Font or Enum.Font.Gotham,
        Text = props.Text or "",
        TextColor3 = props.Color or THEME.Text,
        TextSize = props.Size or 13,
        TextTransparency = props.TextTransparency or 0,
        RichText = props.RichText or false,
        TextXAlignment = props.X or Enum.TextXAlignment.Left,
        TextYAlignment = props.Y or Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Size = props.GuiSize or UDim2.new(1, 0, 1, 0),
        Position = props.Position or UDim2.new(),
        ZIndex = props.ZIndex or 1
    })

    return label
end

local function setGradient(obj, c1, c2, rot)
    local grad = obj:FindFirstChildOfClass("UIGradient")
    if not grad then
        grad = create("UIGradient", {Parent = obj})
    end

    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c1),
        ColorSequenceKeypoint.new(1, c2 or c1)
    })
    grad.Rotation = rot or 90
    return grad
end

local function makeButtonVisual(parent, height)
    local holder = create("Frame", {
        Parent = parent,
        BackgroundColor3 = THEME.Card2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, height or 30),
        ClipsDescendants = true
    })

    corner(holder, 6)
    stroke(holder, THEME.StrokeSoft, 0.15, 1)
    setGradient(holder, Color3.fromRGB(25, 25, 25), Color3.fromRGB(20, 20, 20))

    return holder
end

local function connectHover(frame, normalStroke, hoverStroke, normalBg, hoverBg)
    local s = frame:FindFirstChildOfClass("UIStroke")

    frame.MouseEnter:Connect(function()
        if s then
            tween(s, EASE_FAST, {Color = hoverStroke or THEME.Purple, Transparency = 0})
        end
        if hoverBg then
            tween(frame, EASE_FAST, {BackgroundColor3 = hoverBg})
        end
    end)

    frame.MouseLeave:Connect(function()
        if s then
            tween(s, EASE_FAST, {Color = normalStroke or THEME.StrokeSoft, Transparency = 0.15})
        end
        if normalBg then
            tween(frame, EASE_FAST, {BackgroundColor3 = normalBg})
        end
    end)
end

local function makeDrag(handle, target, latency)
    local dragging = false
    local dragInput
    local startMouse
    local startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startMouse = input.Position
            startPos = target.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging and startMouse and startPos then
            local delta = input.Position - startMouse
            local newPos = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )

            tween(target, TweenInfo.new(latency or 0.055, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Position = newPos
            })
        end
    end)
end

local function showLoadingScreen(config)
    config = config or {}

    if config.Loading == false then
        return
    end

    local version = tostring(config.Version or "2.6.3")
    local titleText = string.lower(config.Header or "hash hub")
    local duration = tonumber(config.LoadingTime or 1.45) or 1.45
    local display = htmlEscape(LocalPlayer.DisplayName or LocalPlayer.Name)

    local gui = create("ScreenGui", {
        Name = "HashHub_Loading",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global
    })

    protectGui(gui)

    local bg = create("Frame", {
        Parent = gui,
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = THEME.Background,
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })

    local holder = create("Frame", {
        Parent = bg,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.525),
        Size = UDim2.fromOffset(560, 150),
        BackgroundTransparency = 1
    })

    local title = makeText(holder, {
        GuiSize = UDim2.fromOffset(560, 42),
        Position = UDim2.fromScale(0, 0.18),
        Text = htmlEscape(titleText) .. ' <font color="rgb(125,95,210)">[' .. htmlEscape(version) .. ']</font>',
        RichText = true,
        Font = Enum.Font.Gotham,
        Size = 30,
        Color = THEME.Text,
        TextTransparency = 1,
        X = Enum.TextXAlignment.Center
    })

    local line = create("Frame", {
        Parent = holder,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.52),
        Size = UDim2.fromOffset(112, 1),
        BackgroundColor3 = Color3.fromRGB(55, 55, 55),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })

    local purpleLine = create("Frame", {
        Parent = holder,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.52),
        Size = UDim2.fromOffset(0, 1),
        BackgroundColor3 = THEME.Purple,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0
    })

    local sub = makeText(holder, {
        GuiSize = UDim2.fromOffset(560, 28),
        Position = UDim2.fromScale(0, 0.59),
        Text = 'welcome, <font color="rgb(125,95,210)">' .. display .. '</font>, please wait.',
        RichText = true,
        Font = Enum.Font.Gotham,
        Size = 14,
        Color = THEME.Muted,
        TextTransparency = 1,
        X = Enum.TextXAlignment.Center
    })

    tween(bg, EASE_SLOW, {BackgroundTransparency = 0})
    task.wait(0.08)
    tween(holder, EASE_SLOW, {Position = UDim2.fromScale(0.5, 0.505)})
    tween(title, EASE_MED, {TextTransparency = 0})
    task.wait(0.12)
    tween(line, EASE_FAST, {BackgroundTransparency = 0.1})
    tween(purpleLine, EASE_SLOW, {Size = UDim2.fromOffset(112, 1)})
    task.wait(0.08)
    tween(sub, EASE_MED, {TextTransparency = 0})

    local alive = true
    task.spawn(function()
        while alive and gui.Parent do
            tween(purpleLine, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0.08
            })
            task.wait(0.9)
            tween(purpleLine, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0.55
            })
            task.wait(0.9)
        end
    end)

    task.wait(duration)

    alive = false
    tween(holder, EASE_MED, {Position = UDim2.fromScale(0.5, 0.49)})
    tween(title, EASE_FAST, {TextTransparency = 1})
    tween(sub, EASE_FAST, {TextTransparency = 1})
    tween(line, EASE_FAST, {BackgroundTransparency = 1})
    tween(purpleLine, EASE_FAST, {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(0, 1)
    })

    task.wait(0.22)
    local out = tween(bg, EASE_MED, {BackgroundTransparency = 1})
    out.Completed:Wait()
    gui:Destroy()
end

function HashHubLibrary.Load(selectedLibrary)
    selectedLibrary = string.lower(tostring(selectedLibrary or ""))

    if string.find(selectedLibrary, "ui") then
        getgenv().ui = true

        local Interface = {}

        function Interface:Start(Configuration)
            Configuration = Configuration or {}

            local header = Configuration.Header or "Hash Hub"
            local version = tostring(Configuration.Version or "2.6.3")
            local footerDefault = "welcome, " .. (LocalPlayer.DisplayName or LocalPlayer.Name) .. ", please wait."
            local footer = Configuration.Footer or footerDefault
            local visKey = Configuration.VisibleKeybind or Enum.KeyCode.RightAlt

            showLoadingScreen(Configuration)

            local screen = create("ScreenGui", {
                Name = genKey(),
                IgnoreGuiInset = true,
                ResetOnSpawn = false,
                ZIndexBehavior = Enum.ZIndexBehavior.Global,
                Enabled = true
            })

            protectGui(screen)

            local dim = create("Frame", {
                Parent = screen,
                Size = UDim2.fromScale(1, 1),
                BackgroundColor3 = THEME.Background,
                BackgroundTransparency = 1,
                BorderSizePixel = 0
            })

            local window = create("CanvasGroup", {
                Parent = dim,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.525),
                Size = UDim2.fromOffset(590, 470),
                BackgroundColor3 = THEME.Card,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                GroupTransparency = 1
            })

            corner(window, 12)
            stroke(window, THEME.StrokeSoft, 0.03, 1)
            setGradient(window, Color3.fromRGB(22, 22, 22), Color3.fromRGB(15, 15, 15), 90)

            local winScale = create("UIScale", {
                Parent = window,
                Scale = 0.965
            })

            local headerFrame = create("Frame", {
                Parent = window,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 102)
            })

            local title = makeText(headerFrame, {
                GuiSize = UDim2.new(1, -40, 0, 42),
                Position = UDim2.new(0, 20, 0, 16),
                Text = htmlEscape(string.lower(header)) .. ' <font color="rgb(125,95,210)">[' .. htmlEscape(version) .. ']</font>',
                RichText = true,
                Font = Enum.Font.Gotham,
                Size = 25,
                Color = THEME.Text,
                X = Enum.TextXAlignment.Center
            })

            local tinyFooter = makeText(headerFrame, {
                GuiSize = UDim2.new(1, -40, 0, 22),
                Position = UDim2.new(0, 20, 0, 58),
                Text = htmlEscape(footer),
                RichText = true,
                Font = Enum.Font.Gotham,
                Size = 13,
                Color = THEME.Muted,
                X = Enum.TextXAlignment.Center
            })

            local divider = create("Frame", {
                Parent = headerFrame,
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.new(0.5, 0, 0, 85),
                Size = UDim2.fromOffset(112, 1),
                BackgroundColor3 = Color3.fromRGB(55, 55, 55),
                BorderSizePixel = 0
            })

            local activeDivider = create("Frame", {
                Parent = headerFrame,
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.new(0.5, 0, 0, 85),
                Size = UDim2.fromOffset(112, 1),
                BackgroundColor3 = THEME.Purple,
                BackgroundTransparency = 0.4,
                BorderSizePixel = 0
            })

            local tabBar = create("Frame", {
                Parent = window,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 18, 0, 103),
                Size = UDim2.new(1, -36, 0, 36),
                ClipsDescendants = true
            })

            local tabList = listLayout(tabBar, Enum.FillDirection.Horizontal, 8)
            tabList.VerticalAlignment = Enum.VerticalAlignment.Center
            tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

            local body = create("Frame", {
                Parent = window,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 18, 0, 145),
                Size = UDim2.new(1, -36, 1, -163)
            })

            local pages = {}
            local pageButtons = {}
            local selectedPage = nil
            local visible = true
            local destroyed = false
            local dragLatency = 0.055

            makeDrag(headerFrame, window, dragLatency)

            local function showWindow(state)
                if destroyed then
                    return
                end

                visible = state

                if state then
                    screen.Enabled = true
                    window.Visible = true

                    tween(dim, EASE_MED, {BackgroundTransparency = 0.08})
                    tween(window, EASE_SLOW, {
                        Position = UDim2.fromScale(0.5, 0.5),
                        GroupTransparency = 0
                    })
                    tween(winScale, EASE_SLOW, {Scale = 1})
                else
                    tween(dim, EASE_MED, {BackgroundTransparency = 1})
                    tween(winScale, EASE_MED, {Scale = 0.965})
                    local closeTween = tween(window, EASE_MED, {
                        Position = UDim2.fromScale(0.5, 0.485),
                        GroupTransparency = 1
                    })

                    task.spawn(function()
                        closeTween.Completed:Wait()
                        if not visible and not destroyed then
                            screen.Enabled = false
                        end
                    end)
                end
            end

            local function selectPage(pageData)
                if selectedPage == pageData then
                    return
                end

                for _, data in ipairs(pages) do
                    if data.Page == pageData.Page then
                        data.Page.Visible = true
                        tween(data.Page, EASE_MED, {GroupTransparency = 0})
                    else
                        local pg = data.Page
                        tween(pg, EASE_FAST, {GroupTransparency = 1})
                        task.delay(0.16, function()
                            if selectedPage ~= data and pg.Parent then
                                pg.Visible = false
                            end
                        end)
                    end
                end

                for btn, data in pairs(pageButtons) do
                    local isActive = data == pageData
                    local line = btn:FindFirstChild("Accent")
                    local txt = btn:FindFirstChild("Text")

                    tween(btn, EASE_FAST, {
                        BackgroundTransparency = isActive and 0 or 0.55,
                        BackgroundColor3 = isActive and Color3.fromRGB(24, 24, 24) or Color3.fromRGB(18, 18, 18)
                    })

                    if line then
                        tween(line, EASE_FAST, {
                            Size = isActive and UDim2.new(1, -14, 0, 1) or UDim2.new(0, 0, 0, 1),
                            BackgroundTransparency = isActive and 0.15 or 1
                        })
                    end

                    if txt then
                        tween(txt, EASE_FAST, {
                            TextColor3 = isActive and THEME.TextBright or THEME.Muted
                        })
                    end
                end

                selectedPage = pageData
                tinyFooter.Text = htmlEscape(pageData.Footer or footer)
            end

            local InterfaceTools = {}

            function InterfaceTools:CreatePage(Configuration_Page)
                Configuration_Page = Configuration_Page or {}

                local subject = Configuration_Page.Subject or "page"
                local pageFooter = Configuration_Page.Footer or footer

                local buttonWidth = math.max(68, TextService:GetTextSize(subject, 13, Enum.Font.Gotham, Vector2.new(math.huge, 22)).X + 28)

                local tabButton = create("TextButton", {
                    Parent = tabBar,
                    BackgroundColor3 = Color3.fromRGB(18, 18, 18),
                    BackgroundTransparency = 0.55,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Text = "",
                    Size = UDim2.fromOffset(buttonWidth, 28)
                })

                corner(tabButton, 7)
                stroke(tabButton, THEME.StrokeSoft, 0.35, 1)

                local tabText = makeText(tabButton, {
                    GuiSize = UDim2.new(1, -16, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    Text = subject,
                    Font = Enum.Font.Gotham,
                    Size = 13,
                    Color = THEME.Muted,
                    X = Enum.TextXAlignment.Center
                })
                tabText.Name = "Text"

                local accent = create("Frame", {
                    Name = "Accent",
                    Parent = tabButton,
                    AnchorPoint = Vector2.new(0.5, 1),
                    Position = UDim2.new(0.5, 0, 1, -4),
                    Size = UDim2.new(0, 0, 0, 1),
                    BackgroundColor3 = THEME.Purple,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0
                })

                corner(accent, 2)

                local page = create("CanvasGroup", {
                    Parent = body,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.fromScale(1, 1),
                    Visible = false,
                    GroupTransparency = 1
                })

                local left = create("ScrollingFrame", {
                    Parent = page,
                    Active = true,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(0.5, -6, 1, 0),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = THEME.Purple,
                    ScrollBarImageTransparency = 0.35
                })

                local right = create("ScrollingFrame", {
                    Parent = page,
                    Active = true,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.5, 6, 0, 0),
                    Size = UDim2.new(0.5, -6, 1, 0),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = THEME.Purple,
                    ScrollBarImageTransparency = 0.35
                })

                local leftLayout = listLayout(left, Enum.FillDirection.Vertical, 10)
                local rightLayout = listLayout(right, Enum.FillDirection.Vertical, 10)
                padding(left, 0, 4, 0, 8)
                padding(right, 4, 0, 0, 8)

                local function updateCanvas()
                    left.CanvasSize = UDim2.new(0, 0, 0, leftLayout.AbsoluteContentSize.Y + 12)
                    right.CanvasSize = UDim2.new(0, 0, 0, rightLayout.AbsoluteContentSize.Y + 12)
                end

                leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
                rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

                local pageData = {
                    Page = page,
                    Footer = pageFooter,
                    Left = left,
                    Right = right,
                    LeftLayout = leftLayout,
                    RightLayout = rightLayout,
                    UpdateCanvas = updateCanvas
                }

                table.insert(pages, pageData)
                pageButtons[tabButton] = pageData

                tabButton.MouseButton1Click:Connect(function()
                    selectPage(pageData)
                end)

                tabButton.MouseEnter:Connect(function()
                    if selectedPage ~= pageData then
                        tween(tabButton, EASE_FAST, {BackgroundTransparency = 0.25})
                        tween(tabText, EASE_FAST, {TextColor3 = THEME.Text})
                    end
                end)

                tabButton.MouseLeave:Connect(function()
                    if selectedPage ~= pageData then
                        tween(tabButton, EASE_FAST, {BackgroundTransparency = 0.55})
                        tween(tabText, EASE_FAST, {TextColor3 = THEME.Muted})
                    end
                end)

                if not selectedPage then
                    selectPage(pageData)
                end

                local PageTools = {}

                function PageTools:CreateSection(Configuration_Section)
                    Configuration_Section = Configuration_Section or {}

                    local sectionHeader = Configuration_Section.Header or "section"
                    local parentColumn

                    if pageData.LeftLayout.AbsoluteContentSize.Y <= pageData.RightLayout.AbsoluteContentSize.Y then
                        parentColumn = pageData.Left
                    else
                        parentColumn = pageData.Right
                    end

                    local section = create("Frame", {
                        Parent = parentColumn,
                        BackgroundColor3 = THEME.Card2,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, -2, 0, 44),
                        ClipsDescendants = false
                    })

                    corner(section, 9)
                    stroke(section, THEME.StrokeSoft, 0.16, 1)
                    setGradient(section, Color3.fromRGB(23, 23, 23), Color3.fromRGB(18, 18, 18), 90)

                    local purpleTop = create("Frame", {
                        Parent = section,
                        BackgroundColor3 = THEME.Purple,
                        BackgroundTransparency = 0.2,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 1)
                    })

                    local sectionList = listLayout(section, Enum.FillDirection.Vertical, 6)
                    sectionList.HorizontalAlignment = Enum.HorizontalAlignment.Center
                    padding(section, 10, 10, sectionHeader == "" and 11 or 12, 10)

                    local headerLabel = nil
                    if sectionHeader ~= "" then
                        headerLabel = makeText(section, {
                            GuiSize = UDim2.new(1, 0, 0, 20),
                            Text = sectionHeader,
                            Font = Enum.Font.Gotham,
                            Size = 13,
                            Color = THEME.TextBright,
                            X = Enum.TextXAlignment.Left
                        })
                        headerLabel.LayoutOrder = 1
                    end

                    local function updateSection()
                        local h = sectionList.AbsoluteContentSize.Y + 22
                        section.Size = UDim2.new(1, -2, 0, math.max(h, 42))
                        pageData.UpdateCanvas()
                    end

                    sectionList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSection)
                    task.defer(updateSection)

                    local SectionTools = {}

                    function SectionTools:CreateButton(Configuration_Button)
                        Configuration_Button = Configuration_Button or {}

                        local text = Configuration_Button.Text or "button"
                        local callback = Configuration_Button.Script or function() end

                        local frame = makeButtonVisual(section, 32)
                        frame.LayoutOrder = 10
                        connectHover(frame, THEME.StrokeSoft, THEME.Purple)

                        local button = create("TextButton", {
                            Parent = frame,
                            BackgroundTransparency = 1,
                            Text = "",
                            AutoButtonColor = false,
                            Size = UDim2.fromScale(1, 1)
                        })

                        local label = makeText(button, {
                            GuiSize = UDim2.new(1, -22, 1, 0),
                            Position = UDim2.new(0, 11, 0, 0),
                            Text = text,
                            Font = Enum.Font.Gotham,
                            Size = 13,
                            Color = THEME.Text,
                            X = Enum.TextXAlignment.Center
                        })

                        button.MouseButton1Down:Connect(function()
                            tween(frame, EASE_FAST, {BackgroundColor3 = Color3.fromRGB(16, 16, 16)})
                            tween(label, EASE_FAST, {TextColor3 = THEME.Purple})
                        end)

                        button.MouseButton1Up:Connect(function()
                            tween(frame, EASE_FAST, {BackgroundColor3 = THEME.Card2})
                            tween(label, EASE_FAST, {TextColor3 = THEME.Text})
                        end)

                        button.MouseButton1Click:Connect(function()
                            pcall(callback)
                        end)

                        updateSection()

                        local ButtonTools = {}

                        function ButtonTools.SetText(newText)
                            label.Text = tostring(newText)
                        end

                        function ButtonTools.Destroy()
                            frame:Destroy()
                            updateSection()
                        end

                        return ButtonTools
                    end

                    local function makeToggleRow(text, defaultValue, callback, repeating, latency)
                        local row = create("TextButton", {
                            Parent = section,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 28),
                            LayoutOrder = 10,
                            AutoButtonColor = false,
                            Text = ""
                        })

                        local label = makeText(row, {
                            GuiSize = UDim2.new(1, -52, 1, 0),
                            Position = UDim2.new(0, 0, 0, 0),
                            Text = text,
                            Font = Enum.Font.Gotham,
                            Size = 13,
                            Color = THEME.Text,
                            X = Enum.TextXAlignment.Left
                        })

                        local hit = create("Frame", {
                            Parent = row,
                            AnchorPoint = Vector2.new(1, 0.5),
                            Position = UDim2.new(1, 0, 0.5, 0),
                            Size = UDim2.fromOffset(38, 18),
                            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                            BorderSizePixel = 0
                        })

                        corner(hit, 20)
                        stroke(hit, THEME.StrokeSoft, 0.2, 1)

                        local knob = create("Frame", {
                            Parent = hit,
                            AnchorPoint = Vector2.new(0, 0.5),
                            Position = UDim2.new(0, 3, 0.5, 0),
                            Size = UDim2.fromOffset(12, 12),
                            BackgroundColor3 = THEME.Muted2,
                            BorderSizePixel = 0
                        })

                        corner(knob, 20)

                        local enabled = defaultValue and true or false
                        local loopId = 0

                        local function paint()
                            tween(hit, EASE_FAST, {
                                BackgroundColor3 = enabled and THEME.PurpleDark or Color3.fromRGB(30, 30, 30)
                            })

                            tween(knob, EASE_FAST, {
                                Position = enabled and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                                BackgroundColor3 = enabled and THEME.Purple or THEME.Muted2
                            })
                        end

                        local function runCallback()
                            loopId += 1
                            local thisLoop = loopId

                            if repeating and enabled and latency and latency > 0 then
                                task.spawn(function()
                                    while enabled and thisLoop == loopId do
                                        pcall(callback, true)
                                        task.wait(latency)
                                    end
                                end)
                            else
                                pcall(callback, enabled)
                            end
                        end

                        row.MouseButton1Click:Connect(function()
                            enabled = not enabled
                            paint()
                            runCallback()
                        end)

                        paint()
                        updateSection()

                        local tools = {}

                        function tools.SetText(newText)
                            label.Text = tostring(newText)
                        end

                        function tools.SetValue(value)
                            enabled = value and true or false
                            paint()
                            runCallback()
                        end

                        function tools.GetValue()
                            return enabled
                        end

                        function tools.Destroy()
                            row:Destroy()
                            updateSection()
                        end

                        return tools
                    end

                    function SectionTools:CreateToggle(Configuration_Toggle)
                        Configuration_Toggle = Configuration_Toggle or {}

                        return makeToggleRow(
                            Configuration_Toggle.Text or "toggle",
                            Configuration_Toggle.Default or false,
                            Configuration_Toggle.Script or function() end,
                            true,
                            Configuration_Toggle.Latency or 0
                        )
                    end

                    function SectionTools:CreateCheck(Configuration_Check)
                        Configuration_Check = Configuration_Check or {}

                        return makeToggleRow(
                            Configuration_Check.Text or "check",
                            Configuration_Check.Default or false,
                            Configuration_Check.Script or function() end,
                            false,
                            0
                        )
                    end

                    function SectionTools:CreateDropdown(Configuration_Dropdown)
                        Configuration_Dropdown = Configuration_Dropdown or {}

                        local text = Configuration_Dropdown.Text or "dropdown"
                        local default = Configuration_Dropdown.Default or ". . ."
                        local options = Configuration_Dropdown.Options or {}
                        local callback = Configuration_Dropdown.Script or function() end

                        local holder = create("Frame", {
                            Parent = section,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 56),
                            LayoutOrder = 10,
                            ZIndex = 10
                        })

                        local label = makeText(holder, {
                            GuiSize = UDim2.new(1, 0, 0, 18),
                            Text = text,
                            Font = Enum.Font.Gotham,
                            Size = 13,
                            Color = THEME.Text,
                            X = Enum.TextXAlignment.Left,
                            ZIndex = 11
                        })

                        local box = create("Frame", {
                            Parent = holder,
                            Position = UDim2.new(0, 0, 0, 22),
                            Size = UDim2.new(1, 0, 0, 30),
                            BackgroundColor3 = THEME.Card2,
                            BorderSizePixel = 0,
                            ClipsDescendants = true,
                            ZIndex = 11
                        })

                        corner(box, 7)
                        stroke(box, THEME.StrokeSoft, 0.12, 1)
                        setGradient(box, Color3.fromRGB(25, 25, 25), Color3.fromRGB(19, 19, 19), 90)

                        local topButton = create("TextButton", {
                            Parent = box,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 30),
                            AutoButtonColor = false,
                            Text = "",
                            ZIndex = 12
                        })

                        local selectedText = makeText(topButton, {
                            GuiSize = UDim2.new(1, -42, 1, 0),
                            Position = UDim2.new(0, 11, 0, 0),
                            Text = tostring(default),
                            Font = Enum.Font.Gotham,
                            Size = 13,
                            Color = THEME.Text,
                            X = Enum.TextXAlignment.Left,
                            ZIndex = 13
                        })

                        local arrow = makeText(topButton, {
                            GuiSize = UDim2.new(0, 28, 1, 0),
                            Position = UDim2.new(1, -32, 0, 0),
                            Text = "⌄",
                            Font = Enum.Font.Gotham,
                            Size = 18,
                            Color = THEME.Muted,
                            X = Enum.TextXAlignment.Center,
                            ZIndex = 13
                        })

                        local menu = create("Frame", {
                            Parent = box,
                            Position = UDim2.new(0, 0, 0, 31),
                            Size = UDim2.new(1, 0, 0, 0),
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            ClipsDescendants = true,
                            ZIndex = 12
                        })

                        local menuList = listLayout(menu, Enum.FillDirection.Vertical, 4)
                        padding(menu, 6, 6, 4, 6)

                        local optionButtons = {}
                        local open = false

                        local function recalc()
                            local menuHeight = menuList.AbsoluteContentSize.Y + 10
                            if open then
                                holder.Size = UDim2.new(1, 0, 0, 56 + menuHeight)
                                tween(box, EASE_MED, {Size = UDim2.new(1, 0, 0, 31 + menuHeight)})
                                tween(menu, EASE_MED, {Size = UDim2.new(1, 0, 0, menuHeight)})
                            else
                                holder.Size = UDim2.new(1, 0, 0, 56)
                                tween(box, EASE_MED, {Size = UDim2.new(1, 0, 0, 30)})
                                tween(menu, EASE_MED, {Size = UDim2.new(1, 0, 0, 0)})
                            end
                            updateSection()
                        end

                        local function setOpen(state)
                            open = state
                            tween(arrow, EASE_FAST, {Rotation = open and 180 or 0})
                            recalc()
                        end

                        local function addOption(option)
                            option = tostring(option)

                            local opt = create("TextButton", {
                                Parent = menu,
                                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                                BackgroundTransparency = 0.15,
                                BorderSizePixel = 0,
                                AutoButtonColor = false,
                                Text = "",
                                Size = UDim2.new(1, 0, 0, 24),
                                ZIndex = 13
                            })

                            corner(opt, 6)
                            stroke(opt, THEME.StrokeSoft, 0.45, 1)

                            local optText = makeText(opt, {
                                GuiSize = UDim2.new(1, -14, 1, 0),
                                Position = UDim2.new(0, 7, 0, 0),
                                Text = option,
                                Font = Enum.Font.Gotham,
                                Size = 12,
                                Color = THEME.Muted,
                                X = Enum.TextXAlignment.Left,
                                ZIndex = 14
                            })

                            opt.MouseEnter:Connect(function()
                                tween(opt, EASE_FAST, {BackgroundTransparency = 0})
                                tween(optText, EASE_FAST, {TextColor3 = THEME.TextBright})
                            end)

                            opt.MouseLeave:Connect(function()
                                tween(opt, EASE_FAST, {BackgroundTransparency = 0.15})
                                tween(optText, EASE_FAST, {TextColor3 = THEME.Muted})
                            end)

                            opt.MouseButton1Click:Connect(function()
                                selectedText.Text = option
                                setOpen(false)
                                pcall(callback, option)
                            end)

                            optionButtons[option] = opt
                            recalc()
                        end

                        for _, option in pairs(options) do
                            addOption(option)
                        end

                        topButton.MouseButton1Click:Connect(function()
                            setOpen(not open)
                        end)

                        connectHover(box, THEME.StrokeSoft, THEME.Purple)
                        updateSection()

                        local DropdownTools = {}

                        function DropdownTools.SetText(newText)
                            label.Text = tostring(newText)
                        end

                        function DropdownTools.SetValue(newValue)
                            selectedText.Text = tostring(newValue)
                            pcall(callback, tostring(newValue))
                        end

                        function DropdownTools.AddOption(option)
                            addOption(option)
                        end

                        function DropdownTools.RemoveOption(option)
                            option = tostring(option)
                            if optionButtons[option] then
                                optionButtons[option]:Destroy()
                                optionButtons[option] = nil
                                recalc()
                            end
                        end

                        function DropdownTools.Clear()
                            for _, opt in pairs(optionButtons) do
                                opt:Destroy()
                            end
                            table.clear(optionButtons)
                            recalc()
                        end

                        function DropdownTools.Destroy()
                            holder:Destroy()
                            updateSection()
                        end

                        return DropdownTools
                    end

                    function SectionTools:CreateSlider(Configuration_Slider)
                        Configuration_Slider = Configuration_Slider or {}
                        Configuration_Slider.Values = Configuration_Slider.Values or {}

                        local text = Configuration_Slider.Text or "slider"
                        local suffix = Configuration_Slider.Suffix or ""
                        local min = tonumber(Configuration_Slider.Values.Minimum) or 0
                        local max = tonumber(Configuration_Slider.Values.Maximum) or 100
                        local default = tonumber(Configuration_Slider.Values.Default) or min
                        local callback = Configuration_Slider.Script or function() end

                        if max <= min then
                            max = min + 1
                        end

                        local holder = create("Frame", {
                            Parent = section,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 52),
                            LayoutOrder = 10
                        })

                        local label = makeText(holder, {
                            GuiSize = UDim2.new(1, -64, 0, 18),
                            Text = text,
                            Font = Enum.Font.Gotham,
                            Size = 13,
                            Color = THEME.Text,
                            X = Enum.TextXAlignment.Left
                        })

                        local valueLabel = makeText(holder, {
                            GuiSize = UDim2.new(0, 64, 0, 18),
                            Position = UDim2.new(1, -64, 0, 0),
                            Text = tostring(default) .. suffix,
                            Font = Enum.Font.Gotham,
                            Size = 12,
                            Color = THEME.Muted,
                            X = Enum.TextXAlignment.Right
                        })

                        local bar = create("TextButton", {
                            Parent = holder,
                            Position = UDim2.new(0, 0, 0, 26),
                            Size = UDim2.new(1, 0, 0, 18),
                            BackgroundColor3 = Color3.fromRGB(28, 28, 28),
                            BorderSizePixel = 0,
                            AutoButtonColor = false,
                            Text = "",
                            ClipsDescendants = true
                        })

                        corner(bar, 8)
                        stroke(bar, THEME.StrokeSoft, 0.24, 1)

                        local fill = create("Frame", {
                            Parent = bar,
                            Size = UDim2.new(0, 0, 1, 0),
                            BackgroundColor3 = THEME.Purple,
                            BackgroundTransparency = 0.1,
                            BorderSizePixel = 0
                        })

                        corner(fill, 8)

                        local current = default
                        local dragging = false

                        local function percentFromValue(value)
                            return math.clamp((value - min) / (max - min), 0, 1)
                        end

                        local function valueFromX(x)
                            local pct = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
                            return math.floor((min + ((max - min) * pct)) + 0.5)
                        end

                        local function setValue(value, fire)
                            current = math.clamp(tonumber(value) or min, min, max)
                            valueLabel.Text = tostring(current) .. suffix
                            tween(fill, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                                Size = UDim2.new(percentFromValue(current), 0, 1, 0)
                            })
                            if fire then
                                pcall(callback, current)
                            end
                        end

                        local function updateFromInput(input)
                            setValue(valueFromX(input.Position.X), true)
                        end

                        bar.MouseButton1Down:Connect(function()
                            dragging = true
                            setValue(valueFromX(Mouse.X), true)
                        end)

                        UserInputService.InputChanged:Connect(function(input)
                            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                                updateFromInput(input)
                            end
                        end)

                        UserInputService.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                dragging = false
                            end
                        end)

                        connectHover(bar, THEME.StrokeSoft, THEME.Purple)
                        setValue(default, false)
                        updateSection()

                        local SliderTools = {}

                        function SliderTools.SetValue(newValue)
                            setValue(newValue, true)
                        end

                        function SliderTools.ResetValue()
                            setValue(default, true)
                        end

                        function SliderTools.SetText(newText)
                            label.Text = tostring(newText)
                        end

                        function SliderTools.GetValue()
                            return current
                        end

                        function SliderTools.Destroy()
                            holder:Destroy()
                            updateSection()
                        end

                        return SliderTools
                    end

                    function SectionTools:CreateTextBox(Configuration_TextBox)
                        Configuration_TextBox = Configuration_TextBox or {}

                        local text = Configuration_TextBox.Text or "textbox"
                        local placeholder = Configuration_TextBox.Placeholder or Configuration_TextBox.Default or "type here..."
                        local callback = Configuration_TextBox.Script or function() end

                        local holder = create("Frame", {
                            Parent = section,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 58),
                            LayoutOrder = 10
                        })

                        local label = makeText(holder, {
                            GuiSize = UDim2.new(1, 0, 0, 18),
                            Text = text,
                            Font = Enum.Font.Gotham,
                            Size = 13,
                            Color = THEME.Text,
                            X = Enum.TextXAlignment.Left
                        })

                        local box = create("Frame", {
                            Parent = holder,
                            Position = UDim2.new(0, 0, 0, 24),
                            Size = UDim2.new(1, 0, 0, 30),
                            BackgroundColor3 = Color3.fromRGB(26, 26, 26),
                            BorderSizePixel = 0,
                            ClipsDescendants = true
                        })

                        corner(box, 7)
                        stroke(box, THEME.StrokeSoft, 0.18, 1)

                        local input = create("TextBox", {
                            Parent = box,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, -18, 1, 0),
                            Position = UDim2.new(0, 9, 0, 0),
                            Font = Enum.Font.Gotham,
                            TextSize = 13,
                            TextColor3 = THEME.TextBright,
                            PlaceholderText = placeholder,
                            PlaceholderColor3 = THEME.Muted2,
                            Text = "",
                            ClearTextOnFocus = false,
                            TextXAlignment = Enum.TextXAlignment.Left
                        })

                        input.Focused:Connect(function()
                            local s = box:FindFirstChildOfClass("UIStroke")
                            if s then
                                tween(s, EASE_FAST, {Color = THEME.Purple, Transparency = 0})
                            end
                        end)

                        input.FocusLost:Connect(function(enterPressed)
                            local s = box:FindFirstChildOfClass("UIStroke")
                            if s then
                                tween(s, EASE_FAST, {Color = THEME.StrokeSoft, Transparency = 0.18})
                            end
                            pcall(callback, input.Text, enterPressed)
                        end)

                        updateSection()

                        local TextBoxTools = {}

                        function TextBoxTools.SetText(newText)
                            label.Text = tostring(newText)
                        end

                        function TextBoxTools.SetInput(newText)
                            input.Text = tostring(newText)
                        end

                        function TextBoxTools.ClearInput()
                            input.Text = ""
                        end

                        function TextBoxTools.Destroy()
                            holder:Destroy()
                            updateSection()
                        end

                        return TextBoxTools
                    end

                    function SectionTools:CreateKeybind(Configuration_Keybind)
                        Configuration_Keybind = Configuration_Keybind or {}

                        local text = Configuration_Keybind.Text or "keybind"
                        local key = Configuration_Keybind.Key or Enum.KeyCode.P
                        local callback = Configuration_Keybind.Script or function() end
                        local listening = false

                        local row = create("Frame", {
                            Parent = section,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 32),
                            LayoutOrder = 10
                        })

                        local label = makeText(row, {
                            GuiSize = UDim2.new(1, -88, 1, 0),
                            Text = text,
                            Font = Enum.Font.Gotham,
                            Size = 13,
                            Color = THEME.Text,
                            X = Enum.TextXAlignment.Left
                        })

                        local keyButton = create("TextButton", {
                            Parent = row,
                            AnchorPoint = Vector2.new(1, 0.5),
                            Position = UDim2.new(1, 0, 0.5, 0),
                            Size = UDim2.fromOffset(76, 26),
                            BackgroundColor3 = Color3.fromRGB(26, 26, 26),
                            BorderSizePixel = 0,
                            AutoButtonColor = false,
                            Text = key.Name,
                            Font = Enum.Font.Gotham,
                            TextSize = 12,
                            TextColor3 = THEME.Muted
                        })

                        corner(keyButton, 7)
                        stroke(keyButton, THEME.StrokeSoft, 0.18, 1)

                        keyButton.MouseButton1Click:Connect(function()
                            listening = true
                            keyButton.Text = "..."
                            tween(keyButton, EASE_FAST, {TextColor3 = THEME.Purple})
                        end)

                        UserInputService.InputBegan:Connect(function(input, gameProcessed)
                            if input.UserInputType ~= Enum.UserInputType.Keyboard then
                                return
                            end

                            if listening then
                                listening = false
                                key = input.KeyCode
                                keyButton.Text = key.Name
                                tween(keyButton, EASE_FAST, {TextColor3 = THEME.Muted})
                                return
                            end

                            if input.KeyCode == key and not gameProcessed then
                                pcall(callback)
                            end
                        end)

                        updateSection()

                        local KeybindTools = {}

                        function KeybindTools.SetText(newText)
                            label.Text = tostring(newText)
                        end

                        function KeybindTools.SetKey(newKey)
                            key = newKey
                            keyButton.Text = key.Name
                        end

                        function KeybindTools.Destroy()
                            row:Destroy()
                            updateSection()
                        end

                        return KeybindTools
                    end

                    function SectionTools:CreateLabel(Configuration_Label)
                        Configuration_Label = Configuration_Label or {}

                        local holder = create("Frame", {
                            Parent = section,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 22),
                            LayoutOrder = 10
                        })

                        local label = makeText(holder, {
                            GuiSize = UDim2.new(1, 0, 1, 0),
                            Text = Configuration_Label.Text or "label",
                            Font = Enum.Font.Gotham,
                            Size = 13,
                            Color = THEME.Muted,
                            X = Configuration_Label.Alignment or Enum.TextXAlignment.Left
                        })

                        updateSection()

                        local LabelTools = {}

                        function LabelTools.SetText(newText)
                            label.Text = tostring(newText)
                        end

                        function LabelTools.Destroy()
                            holder:Destroy()
                            updateSection()
                        end

                        return LabelTools
                    end

                    function SectionTools:CreateDivider()
                        local holder = create("Frame", {
                            Parent = section,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 10),
                            LayoutOrder = 10
                        })

                        local line = create("Frame", {
                            Parent = holder,
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromScale(0.5, 0.5),
                            Size = UDim2.new(1, -4, 0, 1),
                            BackgroundColor3 = Color3.fromRGB(48, 48, 48),
                            BackgroundTransparency = 0.35,
                            BorderSizePixel = 0
                        })

                        updateSection()

                        return line
                    end

                    function SectionTools.SetHeader(newHeader)
                        if headerLabel then
                            headerLabel.Text = tostring(newHeader)
                        end
                    end

                    function SectionTools.Destroy()
                        section:Destroy()
                        pageData.UpdateCanvas()
                    end

                    return SectionTools
                end

                function PageTools.SetSubject(newSubject)
                    subject = tostring(newSubject)
                    tabText.Text = subject

                    local newWidth = math.max(68, TextService:GetTextSize(subject, 13, Enum.Font.Gotham, Vector2.new(math.huge, 22)).X + 28)
                    tween(tabButton, EASE_FAST, {Size = UDim2.fromOffset(newWidth, 28)})
                end

                function PageTools.SetFooter(newFooter)
                    pageData.Footer = tostring(newFooter)
                    if selectedPage == pageData then
                        tinyFooter.Text = htmlEscape(newFooter)
                    end
                end

                function PageTools.Destroy()
                    page:Destroy()
                    tabButton:Destroy()

                    for i, data in ipairs(pages) do
                        if data == pageData then
                            table.remove(pages, i)
                            break
                        end
                    end

                    pageButtons[tabButton] = nil

                    if selectedPage == pageData then
                        selectedPage = nil
                        if pages[1] then
                            selectPage(pages[1])
                        end
                    end
                end

                return PageTools
            end

            function InterfaceTools.SetHeader(newHeader)
                title.Text = htmlEscape(string.lower(tostring(newHeader))) .. ' <font color="rgb(125,95,210)">[' .. htmlEscape(version) .. ']</font>'
            end

            function InterfaceTools.SetFooter(newFooter)
                footer = tostring(newFooter)
                tinyFooter.Text = htmlEscape(footer)
            end

            function InterfaceTools.SetDragLatency(newLatency)
                dragLatency = tonumber(newLatency) or dragLatency
            end

            function InterfaceTools.SetVisibleKeybind(newKey)
                visKey = newKey
            end

            function InterfaceTools.Show()
                showWindow(true)
            end

            function InterfaceTools.Hide()
                showWindow(false)
            end

            function InterfaceTools.Toggle()
                showWindow(not visible)
            end

            function InterfaceTools.Destroy()
                destroyed = true
                local out = tween(window, EASE_FAST, {
                    GroupTransparency = 1,
                    Position = UDim2.fromScale(0.5, 0.485)
                })
                tween(dim, EASE_FAST, {BackgroundTransparency = 1})
                task.spawn(function()
                    out.Completed:Wait()
                    if screen then
                        screen:Destroy()
                    end
                end)
            end

            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then
                    return
                end

                if input.KeyCode == visKey then
                    showWindow(not visible)
                end
            end)

            tween(dim, EASE_MED, {BackgroundTransparency = 0.08})
            task.wait(0.03)
            tween(window, EASE_SLOW, {
                Position = UDim2.fromScale(0.5, 0.5),
                GroupTransparency = 0
            })
            tween(winScale, EASE_SLOW, {Scale = 1})

            task.spawn(function()
                while screen.Parent and not destroyed do
                    tween(activeDivider, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                        BackgroundTransparency = 0.1
                    })
                    task.wait(1.2)
                    tween(activeDivider, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                        BackgroundTransparency = 0.55
                    })
                    task.wait(1.2)
                end
            end)

            return InterfaceTools
        end

        return Interface
    end

    if string.find(selectedLibrary, "notif") then
        local notifications = create("ScreenGui", {
            Name = "HashHub_Notifications",
            IgnoreGuiInset = true,
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Global
        })

        protectGui(notifications)

        local holder = create("Frame", {
            Parent = notifications,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 24, 0, 58),
            Size = UDim2.new(0, 360, 1, -80)
        })

        local layout = listLayout(holder, Enum.FillDirection.Vertical, 8)

        local NotificationLibrary = {}

        function NotificationLibrary:Send(Configuration)
            Configuration = Configuration or {}

            local header = Configuration.Header or "hash hub"
            local note = Configuration.Notification or "notification"
            local time = tonumber(Configuration.Time or 3) or 3

            local noteSize = TextService:GetTextSize(note, 13, Enum.Font.Gotham, Vector2.new(320, math.huge))
            local height = math.clamp(noteSize.Y + 56, 74, 150)

            local card = create("CanvasGroup", {
                Parent = holder,
                BackgroundColor3 = THEME.Card,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 350, 0, height),
                GroupTransparency = 1
            })

            corner(card, 10)
            stroke(card, THEME.StrokeSoft, 0.08, 1)
            setGradient(card, Color3.fromRGB(22, 22, 22), Color3.fromRGB(16, 16, 16), 90)

            local accent = create("Frame", {
                Parent = card,
                BackgroundColor3 = THEME.Purple,
                BackgroundTransparency = 0.15,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 14, 0, 13),
                Size = UDim2.new(0, 76, 0, 1)
            })

            local headerLabel = makeText(card, {
                GuiSize = UDim2.new(1, -28, 0, 22),
                Position = UDim2.new(0, 14, 0, 17),
                Text = tostring(header),
                Font = Enum.Font.Gotham,
                Size = 14,
                Color = THEME.TextBright,
                X = Enum.TextXAlignment.Left
            })

            local noteLabel = makeText(card, {
                GuiSize = UDim2.new(1, -28, 1, -44),
                Position = UDim2.new(0, 14, 0, 42),
                Text = tostring(note),
                Font = Enum.Font.Gotham,
                Size = 13,
                Color = THEME.Muted,
                X = Enum.TextXAlignment.Left,
                Y = Enum.TextYAlignment.Top
            })

            noteLabel.TextWrapped = true
            noteLabel.TextTruncate = Enum.TextTruncate.None

            local scale = create("UIScale", {
                Parent = card,
                Scale = 0.96
            })

            card.Position = UDim2.new(0, -26, 0, 0)

            tween(card, EASE_MED, {
                GroupTransparency = 0,
                Position = UDim2.new(0, 0, 0, 0)
            })
            tween(scale, EASE_MED, {Scale = 1})

            task.delay(time, function()
                if not card.Parent then
                    return
                end

                tween(scale, EASE_FAST, {Scale = 0.96})
                local out = tween(card, EASE_FAST, {
                    GroupTransparency = 1,
                    Position = UDim2.new(0, -26, 0, 0)
                })

                out.Completed:Wait()

                if card.Parent then
                    card:Destroy()
                end
            end)
        end

        return NotificationLibrary
    end
end

return HashHubLibrary

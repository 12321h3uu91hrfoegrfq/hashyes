-- hashui.luau
-- Hash Hub UI library styled after the provided OpenViz reference.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local HashUI = {}

local Theme = {
    Window = Color3.fromRGB(24, 24, 26),
    Top = Color3.fromRGB(28, 28, 30),
    Sidebar = Color3.fromRGB(29, 29, 31),
    Content = Color3.fromRGB(24, 24, 25),
    Card = Color3.fromRGB(28, 28, 30),
    CardAlt = Color3.fromRGB(33, 33, 35),
    Input = Color3.fromRGB(30, 30, 32),
    Stroke = Color3.fromRGB(58, 58, 62),
    SoftStroke = Color3.fromRGB(45, 45, 48),
    Text = Color3.fromRGB(232, 232, 235),
    Muted = Color3.fromRGB(170, 170, 176),
    Dim = Color3.fromRGB(118, 118, 126),
    Accent = Color3.fromRGB(166, 102, 214),
    AccentDark = Color3.fromRGB(62, 42, 78),
}

local function guiParent()
    if gethui then
        local ok, result = pcall(gethui)
        if ok and result then return result end
    end
    return PlayerGui
end

local function new(className, props, children)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = obj
        end
    end
    return obj
end

local function corner(r)
    return new("UICorner", { CornerRadius = UDim.new(0, r or 6) })
end

local function stroke(color, transparency)
    return new("UIStroke", {
        Color = color or Theme.Stroke,
        Transparency = transparency or 0,
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function pad(l, r, t, b)
    return new("UIPadding", {
        PaddingLeft = UDim.new(0, l or 0),
        PaddingRight = UDim.new(0, r or l or 0),
        PaddingTop = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or t or 0),
    })
end

local function tween(obj, time, props)
    local tw = TweenService:Create(obj, TweenInfo.new(time or 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function clearGui(name)
    local parent = guiParent()
    local old = parent:FindFirstChild(name)
    if old then old:Destroy() end
end

local function safeCall(callback, ...)
    if not callback then return end
    local args = table.pack(...)
    task.spawn(function()
        local ok, err = pcall(function()
            callback(table.unpack(args, 1, args.n))
        end)
        if not ok then
            warn("HashUI callback error: " .. tostring(err))
        end
    end)
end

local function textSize(text, size, font)
    return TextService:GetTextSize(tostring(text), size, font, Vector2.new(2000, 100))
end

local function updateCanvas(scroller, layout)
    local function apply()
        scroller.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(apply)
    task.defer(apply)
end

local function buttonHover(button, normal, hover)
    button.MouseEnter:Connect(function()
        tween(button, 0.12, { BackgroundColor3 = hover })
    end)
    button.MouseLeave:Connect(function()
        tween(button, 0.12, { BackgroundColor3 = normal })
    end)
end

local function normalizeTabName(name)
    local n = tostring(name)
    if n == "Library Functions" then
        return "UI Settings"
    end
    if n == "Misc" then
        return "Utility & Misc"
    end
    return n
end

local function sidebarGroupFor(name)
    if name == "Library Functions" then
        return "Settings"
    end
    return "Main"
end

local function tabIcon(name)
    if name == "Visualizer" then return "o" end
    if name == "Audio" then return "~" end
    if name == "Misc" then return "/" end
    return "#"
end

local function targetColumn(kind)
    if kind == "dropdown" or kind == "slider" then
        return "right"
    end
    return "left"
end

function HashUI:Intro(version, displayName, holdTime)
    clearGui("HashHubIntro")

    local gui = new("ScreenGui", {
        Name = "HashHubIntro",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = guiParent(),
    })

    local bg = new("Frame", {
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Parent = gui,
    })

    local titleFont = Enum.Font.Gotham
    local titleSize = 42
    local nameText = "hash hub"
    local versionText = "[" .. tostring(version or "2.6.3") .. "]"
    local nameW = math.ceil(textSize(nameText, titleSize, titleFont).X)
    local verW = math.ceil(textSize(versionText, titleSize, titleFont).X)
    local gap = 12
    local totalW = nameW + gap + verW

    local holder = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.52),
        Size = UDim2.fromOffset(560, 116),
        Parent = bg,
    })

    local titleRow = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.fromOffset(totalW, 54),
        Parent = holder,
    })

    local title = new("TextLabel", {
        BackgroundTransparency = 1,
        Font = titleFont,
        Size = UDim2.fromOffset(nameW, 54),
        Text = nameText,
        TextColor3 = Theme.Text,
        TextSize = titleSize,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleRow,
    })

    local ver = new("TextLabel", {
        BackgroundTransparency = 1,
        Font = titleFont,
        Position = UDim2.fromOffset(nameW + gap, 0),
        Size = UDim2.fromOffset(verW, 54),
        Text = versionText,
        TextColor3 = Theme.Accent,
        TextSize = titleSize,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleRow,
    })

    local sub = new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        RichText = true,
        Position = UDim2.fromOffset(0, 62),
        Size = UDim2.new(1, 0, 0, 22),
        Text = 'welcome, <font color="rgb(166,102,214)">' .. tostring(displayName or LocalPlayer.Name) .. '</font>, please wait.',
        TextColor3 = Theme.Muted,
        TextSize = 13,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = holder,
    })

    local line = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0, 56),
        Size = UDim2.fromOffset(0, 1),
        Parent = holder,
    })

    tween(bg, 0.35, { BackgroundTransparency = 0 })
    task.wait(0.12)
    tween(title, 0.35, { TextTransparency = 0 })
    tween(ver, 0.35, { TextTransparency = 0 })
    tween(line, 0.4, { BackgroundTransparency = 0, Size = UDim2.fromOffset(math.min(totalW, 310), 1) })
    task.wait(0.08)
    tween(sub, 0.35, { TextTransparency = 0 })
    task.wait(holdTime or 2.1)
    tween(title, 0.22, { TextTransparency = 1 })
    tween(ver, 0.22, { TextTransparency = 1 })
    tween(sub, 0.22, { TextTransparency = 1 })
    tween(line, 0.22, { BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 1) })
    task.wait(0.14)
    tween(bg, 0.32, { BackgroundTransparency = 1 })
    task.wait(0.35)
    gui:Destroy()
end

function HashUI:Window(title, accent, toggleKey)
    clearGui("HashHubUI")
    Theme.Accent = accent or Theme.Accent
    Theme.AccentDark = Color3.fromRGB(
        math.floor(Theme.Accent.R * 255 * 0.38),
        math.floor(Theme.Accent.G * 255 * 0.38),
        math.floor(Theme.Accent.B * 255 * 0.38)
    )

    local window = {
        Tabs = {},
        Current = nil,
        Key = toggleKey or Enum.KeyCode.RightShift,
        Visible = true,
    }

    local gui = new("ScreenGui", {
        Name = "HashHubUI",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = guiParent(),
    })
    window.Gui = gui

    local root = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Window,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(930, 550),
        Parent = gui,
    }, {
        corner(4),
        stroke(Theme.Stroke, 0.2),
    })
    window.Root = root

    local sidebar = new("Frame", {
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 210, 1, 0),
        Parent = root,
    })

    local brand = new("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 14),
        Size = UDim2.new(1, -28, 0, 38),
        Parent = sidebar,
    })

    local logo = new("Frame", {
        BackgroundColor3 = Color3.fromRGB(38, 38, 42),
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(32, 32),
        Parent = brand,
    }, {
        corner(16),
        stroke(Theme.Accent, 0.05),
    })

    new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Size = UDim2.fromScale(1, 1),
        Text = "h",
        TextColor3 = Theme.Text,
        TextSize = 19,
        Parent = logo,
    })

    new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Position = UDim2.fromOffset(42, 0),
        Size = UDim2.new(1, -42, 0, 32),
        Text = "Hash Hub",
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = brand,
    })

    local nav = new("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, 62),
        Size = UDim2.new(1, -20, 1, -122),
        Parent = sidebar,
    })

    local navLayout = new("UIListLayout", {
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = nav,
    })

    local groups = {}
    local function ensureGroup(name)
        if groups[name] then return groups[name] end
        local label = new("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Size = UDim2.new(1, 0, 0, 18),
            Text = name,
            TextColor3 = Theme.Muted,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = nav,
        }, {
            pad(8, 0, 0, 0),
        })
        groups[name] = label
        return label
    end
    ensureGroup("Main")

    local userBox = new("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 1, -14),
        Size = UDim2.new(1, -28, 0, 42),
        Parent = sidebar,
    })

    local avatar = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(42, 42, 45),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(30, 30),
        Parent = userBox,
    }, {
        corner(15),
    })

    new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Size = UDim2.fromScale(1, 1),
        Text = string.sub(LocalPlayer.Name, 1, 1),
        TextColor3 = Theme.Accent,
        TextSize = 16,
        Parent = avatar,
    })

    new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.fromOffset(39, 2),
        Size = UDim2.new(1, -39, 0, 19),
        Text = LocalPlayer.DisplayName,
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = userBox,
    })

    new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.fromOffset(39, 21),
        Size = UDim2.new(1, -39, 0, 16),
        Text = LocalPlayer.Name,
        TextColor3 = Theme.Muted,
        TextSize = 11,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = userBox,
    })

    local topbar = new("Frame", {
        BackgroundColor3 = Theme.Top,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(210, 0),
        Size = UDim2.new(1, -210, 0, 40),
        Parent = root,
    })

    new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.fromOffset(16, 0),
        Size = UDim2.new(0, 120, 1, 0),
        Text = ":)",
        TextColor3 = Theme.Muted,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topbar,
    })

    local rightTools = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(112, 24),
        Parent = topbar,
    })
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 9),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = rightTools,
    })
    for _, txt in ipairs({ "Q", "!", "", "", "" }) do
        local dot = new(txt == "" and "Frame" or "TextLabel", {
            BackgroundColor3 = Color3.fromRGB(78, 78, 82),
            BorderSizePixel = 0,
            Size = UDim2.fromOffset(13, 13),
            Parent = rightTools,
        }, {
            corner(7),
        })
        if txt ~= "" then
            dot.BackgroundTransparency = 1
            dot.Font = Enum.Font.GothamMedium
            dot.Text = txt
            dot.TextColor3 = Color3.fromRGB(105, 105, 110)
            dot.TextSize = 15
        end
    end

    local content = new("Frame", {
        BackgroundColor3 = Theme.Content,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(210, 40),
        Size = UDim2.new(1, -210, 1, -40),
        Parent = root,
    })

    local pages = new("Frame", {
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Position = UDim2.fromOffset(12, 12),
        Size = UDim2.new(1, -24, 1, -12),
        Parent = content,
    })

    local dragging = false
    local dragStart
    local startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = root.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    local function setVisible(value)
        window.Visible = value
        gui.Enabled = value
    end
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == window.Key then
            setVisible(not window.Visible)
        end
    end)

    function window:SelectTab(tabOrName)
        local selected
        if type(tabOrName) == "table" then
            selected = tabOrName
        elseif type(tabOrName) == "number" then
            selected = self.Tabs[tabOrName]
        else
            for _, tab in ipairs(self.Tabs) do
                if tab.Name == tostring(tabOrName) then
                    selected = tab
                    break
                end
            end
        end
        if not selected then return end
        for _, tab in ipairs(self.Tabs) do
            local active = tab == selected
            tab.Page.Visible = active
            tab.Button.BackgroundColor3 = active and Color3.fromRGB(34, 34, 37) or Theme.Sidebar
            tab.Button.TextColor3 = active and Theme.Accent or Theme.Muted
            tab.Icon.TextColor3 = active and Theme.Accent or Theme.Muted
        end
        self.Current = selected
    end

    function window:Destroy()
        if self.Gui then self.Gui:Destroy() end
    end

    local function makePanel(parent, titleText)
        local panel = new("Frame", {
            BackgroundColor3 = Theme.Card,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = parent,
        }, {
            corner(6),
            stroke(Theme.Stroke, 0.15),
        })
        new("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Position = UDim2.fromOffset(10, 8),
            Size = UDim2.new(1, -20, 0, 18),
            Text = titleText,
            TextColor3 = Theme.Muted,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = panel,
        })
        local scroller = new("ScrollingFrame", {
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Position = UDim2.fromOffset(10, 36),
            ScrollBarImageColor3 = Theme.Accent,
            ScrollBarThickness = 3,
            Size = UDim2.new(1, -20, 1, -46),
            Parent = panel,
        })
        local layout = new("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = scroller,
        })
        updateCanvas(scroller, layout)
        return scroller
    end

    local function controlParent(tab, kind)
        if targetColumn(kind) == "right" then
            return tab.Right
        end
        return tab.Left
    end

    local function makeControlBase(parent, height)
        return new("Frame", {
            BackgroundColor3 = Theme.CardAlt,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, height),
            Parent = parent,
        }, {
            corner(5),
            stroke(Theme.SoftStroke, 0.35),
        })
    end

    function window:Tab(rawName)
        local name = tostring(rawName)
        local group = sidebarGroupFor(name)
        ensureGroup(group)

        local tab = {
            Name = name,
            DisplayName = normalizeTabName(name),
        }

        local button = new("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = Theme.Sidebar,
            BorderSizePixel = 0,
            Font = Enum.Font.GothamMedium,
            Size = UDim2.new(1, 0, 0, 36),
            Text = "    " .. tab.DisplayName,
            TextColor3 = Theme.Muted,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = nav,
        }, {
            corner(5),
        })
        button.MouseEnter:Connect(function()
            if window.Current ~= tab then
                tween(button, 0.12, { BackgroundColor3 = Color3.fromRGB(34, 34, 37) })
            end
        end)
        button.MouseLeave:Connect(function()
            if window.Current ~= tab then
                tween(button, 0.12, { BackgroundColor3 = Theme.Sidebar })
            end
        end)

        local icon = new("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Position = UDim2.fromOffset(10, 0),
            Size = UDim2.fromOffset(18, 36),
            Text = tabIcon(name),
            TextColor3 = Theme.Muted,
            TextSize = 17,
            Parent = button,
        })

        local page = new("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Visible = false,
            Parent = pages,
        })

        local columns = new("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = page,
        })
        new("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 12),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = columns,
        })

        local leftWrap = new("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -6, 1, 0),
            Parent = columns,
        })
        local rightWrap = new("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -6, 1, 0),
            Parent = columns,
        })

        tab.Left = makePanel(leftWrap, "Controls")
        tab.Right = makePanel(rightWrap, name == "Visualizer" and "Preset Configuration" or "Configuration")
        tab.Button = button
        tab.Icon = icon
        tab.Page = page

        button.MouseButton1Click:Connect(function()
            window:SelectTab(tab)
        end)

        function tab:Section(label)
            local parent = self.Left
            local section = new("Frame", {
                BackgroundColor3 = Theme.AccentDark,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 1),
                Parent = parent,
            })
            return section
        end

        function tab:Button(label, callback)
            local parent = controlParent(self, "button")
            local buttonObj = new("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = Theme.CardAlt,
                BorderSizePixel = 0,
                Font = Enum.Font.GothamMedium,
                Size = UDim2.new(1, 0, 0, 38),
                Text = tostring(label),
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = parent,
            }, {
                corner(5),
                stroke(Theme.SoftStroke, 0.4),
                pad(10, 10, 0, 0),
            })
            buttonHover(buttonObj, Theme.CardAlt, Color3.fromRGB(38, 38, 40))
            buttonObj.MouseButton1Click:Connect(function()
                safeCall(callback)
            end)
            return buttonObj
        end

        function tab:Textbox(label, numericOnly, callback)
            local parent = controlParent(self, "textbox")
            local frame = new("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 34),
                Parent = parent,
            })
            new("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Size = UDim2.new(0.52, -6, 1, 0),
                Text = tostring(label),
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame,
            })
            local box = new("TextBox", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Theme.Input,
                BorderSizePixel = 0,
                ClearTextOnFocus = false,
                Font = Enum.Font.Gotham,
                PlaceholderText = numericOnly and "0" or "Username here...",
                PlaceholderColor3 = Theme.Muted,
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(0.48, 0, 0, 28),
                Text = "",
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = frame,
            }, {
                corner(5),
                stroke(Theme.Stroke, 0.15),
            })
            box.FocusLost:Connect(function()
                local text = box.Text
                if numericOnly then
                    text = text:match("%-?%d+%.?%d*") or ""
                    box.Text = text
                end
                safeCall(callback, text)
            end)
            return box
        end

        function tab:Dropdown(label, options, callback)
            local parent = controlParent(self, "dropdown")
            local items = {}
            for _, item in ipairs(options or {}) do
                table.insert(items, tostring(item))
            end
            local selected = items[1] or "--"
            local open = false
            local optionButtons = {}

            local frame = makeControlBase(parent, 66)
            frame.ClipsDescendants = true
            frame.BackgroundTransparency = 1
            frame.UIStroke.Transparency = 1

            new("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Size = UDim2.new(1, 0, 0, 22),
                Text = tostring(label),
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame,
            })
            local header = new("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = Theme.Input,
                BorderSizePixel = 0,
                Font = Enum.Font.Gotham,
                Position = UDim2.fromOffset(0, 30),
                Size = UDim2.new(1, 0, 0, 32),
                Text = "",
                Parent = frame,
            }, {
                corner(5),
                stroke(Theme.Stroke, 0.15),
            })
            local chosen = new("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Position = UDim2.fromOffset(10, 0),
                Size = UDim2.new(1, -40, 1, 0),
                Text = selected,
                TextColor3 = Theme.Muted,
                TextSize = 13,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = header,
            })
            local arrow = new("TextLabel", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Position = UDim2.new(1, -8, 0, 0),
                Size = UDim2.fromOffset(20, 32),
                Text = "v",
                TextColor3 = Theme.Muted,
                TextSize = 13,
                Parent = header,
            })
            local list = new("ScrollingFrame", {
                Active = true,
                BackgroundColor3 = Theme.Input,
                BorderSizePixel = 0,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                Position = UDim2.fromOffset(0, 66),
                ScrollBarImageColor3 = Theme.Accent,
                ScrollBarThickness = 3,
                Size = UDim2.new(1, 0, 0, 0),
                Parent = frame,
            }, {
                corner(5),
                pad(4, 4, 4, 4),
            })
            local listLayout = new("UIListLayout", {
                Padding = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = list,
            })
            local function clear()
                for _, item in ipairs(optionButtons) do item:Destroy() end
                optionButtons = {}
            end
            local function resize()
                local visible = math.min(#items, 5)
                local listH = visible * 28 + 8
                frame.Size = UDim2.new(1, 0, 0, open and (70 + listH) or 66)
                list.Size = UDim2.new(1, 0, 0, open and listH or 0)
                arrow.Text = open and "^" or "v"
            end
            local function rebuild()
                clear()
                for _, item in ipairs(items) do
                    local opt = new("TextButton", {
                        AutoButtonColor = false,
                        BackgroundColor3 = item == selected and Theme.AccentDark or Theme.Input,
                        BorderSizePixel = 0,
                        Font = Enum.Font.Gotham,
                        Size = UDim2.new(1, 0, 0, 24),
                        Text = item,
                        TextColor3 = item == selected and Theme.Text or Theme.Muted,
                        TextSize = 12,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Parent = list,
                    }, {
                        corner(4),
                    })
                    opt.MouseButton1Click:Connect(function()
                        selected = item
                        chosen.Text = selected
                        open = false
                        rebuild()
                        resize()
                        safeCall(callback, selected)
                    end)
                    table.insert(optionButtons, opt)
                end
                task.defer(function()
                    list.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 8)
                end)
            end
            header.MouseButton1Click:Connect(function()
                open = not open
                resize()
            end)
            rebuild()
            resize()

            local api = {}
            function api:Refresh(newOptions)
                items = {}
                for _, item in ipairs(newOptions or {}) do
                    table.insert(items, tostring(item))
                end
                local found = false
                for _, item in ipairs(items) do
                    if item == selected then found = true break end
                end
                if not found then
                    selected = items[1] or "--"
                    chosen.Text = selected
                end
                rebuild()
                resize()
            end
            api.Update = api.Refresh
            api.update = api.Refresh
            function api:Set(value)
                selected = tostring(value)
                chosen.Text = selected
                rebuild()
                safeCall(callback, selected)
            end
            function api:Get()
                return selected
            end
            return api
        end

        function tab:Slider(label, min, max, default, callback)
            local parent = controlParent(self, "slider")
            min = tonumber(min) or 0
            max = tonumber(max) or 100
            local value = math.clamp(tonumber(default) or min, min, max)
            local frame = new("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 46),
                Parent = parent,
            })
            new("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Size = UDim2.new(1, -70, 0, 20),
                Text = tostring(label),
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame,
            })
            local val = new("TextLabel", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Position = UDim2.new(1, 0, 0, 0),
                Size = UDim2.fromOffset(70, 20),
                Text = "",
                TextColor3 = Theme.Text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = frame,
            })
            local bar = new("Frame", {
                BackgroundColor3 = Color3.fromRGB(55, 55, 58),
                BorderSizePixel = 0,
                Position = UDim2.fromOffset(0, 30),
                Size = UDim2.new(1, 0, 0, 4),
                Parent = frame,
            }, {
                corner(3),
            })
            local fill = new("Frame", {
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 0, 1, 0),
                Parent = bar,
            }, {
                corner(3),
            })
            local knob = new("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(245, 245, 247),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.fromOffset(8, 8),
                Parent = bar,
            }, {
                corner(4),
            })
            local hit = new("TextButton", {
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(-2, 22),
                Size = UDim2.new(1, 4, 0, 24),
                Text = "",
                Parent = frame,
            })
            local draggingSlider = false
            local function apply(alpha, fire)
                alpha = math.clamp(alpha, 0, 1)
                value = min + ((max - min) * alpha)
                value = math.floor(value * 100 + 0.5) / 100
                fill.Size = UDim2.new(alpha, 0, 1, 0)
                knob.Position = UDim2.new(alpha, 0, 0.5, 0)
                local shown = math.abs(value - math.floor(value)) < 0.001 and tostring(math.floor(value)) or string.format("%.2f", value)
                val.Text = shown .. "/" .. tostring(max)
                if fire then safeCall(callback, value) end
            end
            local function fromInput(input, fire)
                apply((input.Position.X - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X), fire)
            end
            hit.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = true
                    fromInput(input, true)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    fromInput(input, true)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = false
                end
            end)
            apply((value - min) / math.max(1, max - min), false)
            return {
                Set = function(_, newValue)
                    value = math.clamp(tonumber(newValue) or value, min, max)
                    apply((value - min) / math.max(1, max - min), true)
                end,
                Get = function()
                    return value
                end,
            }
        end

        function tab:Toggle(label, default, callback)
            local parent = controlParent(self, "toggle")
            local state = default == true
            local frame = new("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 34),
                Parent = parent,
            })
            new("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Size = UDim2.new(1, -48, 1, 0),
                Text = tostring(label),
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame,
            })
            local hit = new("TextButton", {
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = "",
                Parent = frame,
            })
            local box = new("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(58, 58, 62),
                BorderSizePixel = 0,
                Position = UDim2.new(1, -2, 0.5, 0),
                Size = UDim2.fromOffset(20, 20),
                Parent = frame,
            }, {
                corner(5),
                stroke(Theme.SoftStroke, 0.2),
            })
            local function apply(fire)
                box.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(58, 58, 62)
                if fire then safeCall(callback, state) end
            end
            hit.MouseButton1Click:Connect(function()
                state = not state
                apply(true)
            end)
            return {
                Set = function(_, value)
                    state = value == true
                    apply(true)
                end,
                Get = function()
                    return state
                end,
            }
        end

        function tab:Bind(label, key, callback)
            local currentKey = key or Enum.KeyCode.RightShift
            local waiting = false
            local button = self:Button(tostring(label) .. "    " .. currentKey.Name, function()
                waiting = true
                button.Text = tostring(label) .. "    ..."
            end)
            UserInputService.InputBegan:Connect(function(input, processed)
                if processed then return end
                if waiting and input.KeyCode ~= Enum.KeyCode.Unknown then
                    currentKey = input.KeyCode
                    waiting = false
                    button.Text = tostring(label) .. "    " .. currentKey.Name
                    return
                end
                if input.KeyCode == currentKey then
                    safeCall(callback)
                end
            end)
            return {
                Set = function(_, newKey)
                    currentKey = newKey
                    button.Text = tostring(label) .. "    " .. currentKey.Name
                end,
                Get = function()
                    return currentKey
                end,
            }
        end

        table.insert(window.Tabs, tab)
        if #window.Tabs == 1 then
            window:SelectTab(tab)
        end
        return tab
    end

    return window
end

function HashUI:Notification(title, message, footer, duration)
    local gui = guiParent():FindFirstChild("HashHubUI")
    if not gui then return end
    local holder = gui:FindFirstChild("HashHubNotifications")
    if not holder then
        holder = new("Frame", {
            AnchorPoint = Vector2.new(1, 1),
            BackgroundTransparency = 1,
            Name = "HashHubNotifications",
            Position = UDim2.new(1, -18, 1, -18),
            Size = UDim2.fromOffset(300, 360),
            Parent = gui,
        })
        new("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Parent = holder,
        })
    end
    local card = new("Frame", {
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(292, 74),
        Parent = holder,
    }, {
        corner(6),
        stroke(Theme.Stroke, 0.15),
        pad(12, 12, 8, 8),
    })
    new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Size = UDim2.new(1, 0, 0, 20),
        Text = tostring(footer or title or "Hash Hub"),
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })
    new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.fromOffset(0, 24),
        Size = UDim2.new(1, 0, 0, 34),
        Text = tostring(message or ""),
        TextColor3 = Theme.Muted,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = card,
    })
    new("Frame", {
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = card,
    })
    task.delay(duration or 3, function()
        if card then card:Destroy() end
    end)
end

return HashUI

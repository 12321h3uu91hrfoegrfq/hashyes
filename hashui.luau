-- hashui.luau
-- Minimal Hash Hub UI, styled after the loading screen.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local HashUI = {}

local Theme = {
    Bg = Color3.fromRGB(25, 25, 25),
    Surface = Color3.fromRGB(18, 18, 20),
    Surface2 = Color3.fromRGB(28, 28, 31),
    Surface3 = Color3.fromRGB(36, 36, 40),
    Stroke = Color3.fromRGB(50, 50, 56),
    Text = Color3.fromRGB(226, 226, 230),
    Muted = Color3.fromRGB(166, 166, 174),
    Dim = Color3.fromRGB(110, 110, 120),
    Accent = Color3.fromRGB(138, 101, 212),
}

local function parentGui()
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then
            return hui
        end
    end
    return PlayerGui
end

local function new(className, props, children)
    local inst = Instance.new(className)
    for key, value in pairs(props or {}) do
        inst[key] = value
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = inst
        end
    end
    return inst
end

local function corner(radius)
    return new("UICorner", { CornerRadius = UDim.new(0, radius or 6) })
end

local function stroke(color, transparency)
    return new("UIStroke", {
        Color = color or Theme.Stroke,
        Transparency = transparency or 0,
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function pad(left, right, top, bottom)
    return new("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or left or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or top or 0),
    })
end

local function tween(inst, time, props)
    local tw = TweenService:Create(inst, TweenInfo.new(time or 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function destroyExisting(name)
    local parent = parentGui()
    local existing = parent:FindFirstChild(name)
    if existing then
        existing:Destroy()
    end
end

local function textWidth(text, size, font)
    return math.ceil(TextService:GetTextSize(tostring(text), size, font, Vector2.new(2000, 100)).X)
end

local function setCanvas(scroller, layout)
    local function update()
        scroller.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 14)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
    task.defer(update)
end

local function safeCall(callback, ...)
    if callback then
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
end

local function styleButton(button)
    button.MouseEnter:Connect(function()
        tween(button, 0.12, { BackgroundColor3 = Theme.Surface3 })
    end)
    button.MouseLeave:Connect(function()
        tween(button, 0.12, { BackgroundColor3 = Theme.Surface2 })
    end)
end

function HashUI:Intro(version, displayName, holdTime)
    destroyExisting("HashHubIntro")

    local gui = new("ScreenGui", {
        Name = "HashHubIntro",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = parentGui(),
    })

    local bg = new("Frame", {
        BackgroundColor3 = Theme.Bg,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Parent = gui,
    })

    local holder = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.52),
        Size = UDim2.fromOffset(520, 112),
        Parent = bg,
    })

    local titleFont = Enum.Font.Gotham
    local titleSize = 42
    local nameText = "hash hub"
    local versionText = "[" .. tostring(version or "2.6.3") .. "]"
    local gap = 12
    local nameW = textWidth(nameText, titleSize, titleFont)
    local verW = textWidth(versionText, titleSize, titleFont)
    local totalW = nameW + gap + verW

    local titleRow = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.fromOffset(totalW, 52),
        Parent = holder,
    })

    local title = new("TextLabel", {
        BackgroundTransparency = 1,
        Font = titleFont,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromOffset(nameW, 52),
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
        Size = UDim2.fromOffset(verW, 52),
        Text = versionText,
        TextColor3 = Theme.Accent,
        TextSize = titleSize,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleRow,
    })

    local line = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0, 58),
        Size = UDim2.fromOffset(0, 1),
        Parent = holder,
    })

    local sub = new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        RichText = true,
        Position = UDim2.fromOffset(0, 74),
        Size = UDim2.new(1, 0, 0, 22),
        Text = 'welcome, <font color="rgb(138,101,212)">' .. tostring(displayName or LocalPlayer.Name) .. '</font>, please wait.',
        TextColor3 = Theme.Muted,
        TextSize = 13,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = holder,
    })

    tween(bg, 0.35, { BackgroundTransparency = 0 })
    task.wait(0.12)
    tween(title, 0.35, { TextTransparency = 0 })
    tween(ver, 0.35, { TextTransparency = 0 })
    tween(line, 0.4, { BackgroundTransparency = 0, Size = UDim2.fromOffset(math.min(totalW, 300), 1) })
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
    destroyExisting("HashHubUI")
    Theme.Accent = accent or Theme.Accent

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
        Parent = parentGui(),
    })
    window.Gui = gui

    local root = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(600, 430),
        Parent = gui,
    }, {
        corner(8),
        stroke(Theme.Stroke, 0.2),
    })
    window.Root = root

    local header = new("Frame", {
        BackgroundColor3 = Theme.Bg,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 70),
        Parent = root,
    }, {
        corner(8),
        pad(20, 20, 12, 0),
    })

    new("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = Theme.Bg,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 8),
        Parent = header,
    })

    local titleLabel = new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Size = UDim2.new(1, -50, 0, 32),
        Text = tostring(title or "hash hub"),
        TextColor3 = Theme.Text,
        TextSize = 24,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header,
    })

    new("Frame", {
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 43),
        Size = UDim2.fromOffset(170, 1),
        Parent = header,
    })

    local close = new("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        AutoButtonColor = false,
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Font = Enum.Font.Gotham,
        Position = UDim2.new(1, 0, 0, 4),
        Size = UDim2.fromOffset(32, 32),
        Text = "x",
        TextColor3 = Theme.Muted,
        TextSize = 14,
        Parent = header,
    }, {
        corner(6),
        stroke(Theme.Stroke, 0.1),
    })

    local body = new("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 70),
        Size = UDim2.new(1, 0, 1, -70),
        Parent = root,
    })

    local sidebar = new("Frame", {
        BackgroundColor3 = Color3.fromRGB(20, 20, 23),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 155, 1, 0),
        Parent = body,
    }, {
        pad(10, 10, 12, 12),
    })

    new("UIListLayout", {
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = sidebar,
    })

    local content = new("Frame", {
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Position = UDim2.fromOffset(155, 0),
        Size = UDim2.new(1, -155, 1, 0),
        Parent = body,
    }, {
        pad(14, 14, 14, 14),
    })

    local pages = new("Frame", {
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Size = UDim2.fromScale(1, 1),
        Parent = content,
    })

    local dragging = false
    local dragStart
    local startPos

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = root.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local function setVisible(value)
        window.Visible = value
        gui.Enabled = value
    end

    close.MouseButton1Click:Connect(function()
        setVisible(false)
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == window.Key then
            setVisible(not window.Visible)
        end
    end)

    function window:SelectTab(tabOrName)
        local selected = nil
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
            tab.PageFrame.Visible = active
            tab.SideButton.BackgroundColor3 = active and Theme.Surface2 or Color3.fromRGB(20, 20, 23)
            tab.SideButton.TextColor3 = active and Theme.Text or Theme.Muted
            tab.SideLine.BackgroundTransparency = active and 0 or 1
        end
        self.Current = selected
    end

    function window:Destroy()
        gui:Destroy()
    end

    local function makeControl(parent, height)
        local frame = new("Frame", {
            BackgroundColor3 = Theme.Surface2,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, height),
            Parent = parent,
        }, {
            corner(6),
            stroke(Theme.Stroke, 0.25),
        })
        return frame
    end

    function window:Tab(name)
        local tab = {
            Name = tostring(name),
        }

        local sideButton = new("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = Color3.fromRGB(20, 20, 23),
            BorderSizePixel = 0,
            Font = Enum.Font.Gotham,
            Size = UDim2.new(1, 0, 0, 36),
            Text = tab.Name,
            TextColor3 = Theme.Muted,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = sidebar,
        }, {
            corner(5),
            pad(10, 10, 0, 0),
        })

        local sideLine = new("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -6, 0.5, 0),
            Size = UDim2.fromOffset(3, 18),
            Parent = sideButton,
        }, {
            corner(3),
        })

        local page = new("ScrollingFrame", {
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarImageColor3 = Theme.Accent,
            ScrollBarThickness = 3,
            Size = UDim2.fromScale(1, 1),
            Visible = false,
            Parent = pages,
        }, {
            pad(2, 8, 2, 8),
        })

        local layout = new("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = page,
        })
        setCanvas(page, layout)

        tab.SideButton = sideButton
        tab.SideLine = sideLine
        tab.PageFrame = page

        sideButton.MouseButton1Click:Connect(function()
            window:SelectTab(tab)
        end)

        function tab:Section(label)
            return new("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Size = UDim2.new(1, 0, 0, 18),
                Text = tostring(label),
                TextColor3 = Theme.Dim,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = page,
            })
        end

        function tab:Button(label, callback)
            local button = new("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = Theme.Surface2,
                BorderSizePixel = 0,
                Font = Enum.Font.Gotham,
                Size = UDim2.new(1, 0, 0, 38),
                Text = tostring(label),
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = page,
            }, {
                corner(6),
                stroke(Theme.Stroke, 0.25),
                pad(12, 12, 0, 0),
            })
            styleButton(button)
            button.MouseButton1Click:Connect(function()
                safeCall(callback)
            end)
            return button
        end

        function tab:Toggle(label, default, callback)
            local state = default == true
            local frame = makeControl(page, 42)
            local labelObj = new("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Position = UDim2.fromOffset(12, 0),
                Size = UDim2.new(1, -72, 1, 0),
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
            local pill = new("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(56, 56, 62),
                BorderSizePixel = 0,
                Position = UDim2.new(1, -12, 0.5, 0),
                Size = UDim2.fromOffset(40, 20),
                Parent = frame,
            }, {
                corner(10),
            })
            local knob = new("Frame", {
                BackgroundColor3 = Theme.Text,
                BorderSizePixel = 0,
                Position = state and UDim2.fromOffset(22, 3) or UDim2.fromOffset(3, 3),
                Size = UDim2.fromOffset(14, 14),
                Parent = pill,
            }, {
                corner(7),
            })
            local function apply(fire)
                pill.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(56, 56, 62)
                knob.Position = state and UDim2.fromOffset(22, 3) or UDim2.fromOffset(3, 3)
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

        function tab:Slider(label, min, max, default, callback)
            min = tonumber(min) or 0
            max = tonumber(max) or 100
            local value = math.clamp(tonumber(default) or min, min, max)
            local frame = makeControl(page, 62)
            new("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Position = UDim2.fromOffset(12, 7),
                Size = UDim2.new(1, -80, 0, 20),
                Text = tostring(label),
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame,
            })
            local valueLabel = new("TextLabel", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Position = UDim2.new(1, -12, 0, 7),
                Size = UDim2.fromOffset(64, 20),
                Text = tostring(value),
                TextColor3 = Theme.Accent,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = frame,
            })
            local bar = new("Frame", {
                BackgroundColor3 = Color3.fromRGB(52, 52, 58),
                BorderSizePixel = 0,
                Position = UDim2.fromOffset(12, 39),
                Size = UDim2.new(1, -24, 0, 5),
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
            local hit = new("TextButton", {
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(8, 28),
                Size = UDim2.new(1, -16, 0, 28),
                Text = "",
                Parent = frame,
            })
            local draggingSlider = false
            local function setAlpha(alpha, fire)
                alpha = math.clamp(alpha, 0, 1)
                value = min + ((max - min) * alpha)
                value = math.floor(value * 100 + 0.5) / 100
                fill.Size = UDim2.new(alpha, 0, 1, 0)
                valueLabel.Text = math.abs(value - math.floor(value)) < 0.001 and tostring(math.floor(value)) or string.format("%.2f", value)
                if fire then safeCall(callback, value) end
            end
            local function inputToValue(input, fire)
                setAlpha((input.Position.X - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X), fire)
            end
            hit.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = true
                    inputToValue(input, true)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    inputToValue(input, true)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = false
                end
            end)
            setAlpha((value - min) / math.max(1, max - min), false)
            return {
                Set = function(_, newValue)
                    value = math.clamp(tonumber(newValue) or value, min, max)
                    setAlpha((value - min) / math.max(1, max - min), true)
                end,
                Get = function()
                    return value
                end,
            }
        end

        function tab:Textbox(label, numericOnly, callback)
            local frame = makeControl(page, 44)
            new("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Position = UDim2.fromOffset(12, 0),
                Size = UDim2.new(0.45, -16, 1, 0),
                Text = tostring(label),
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame,
            })
            local box = new("TextBox", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel = 0,
                ClearTextOnFocus = false,
                Font = Enum.Font.Gotham,
                PlaceholderText = numericOnly and "0" or "...",
                PlaceholderColor3 = Theme.Dim,
                Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.new(0.55, -6, 0, 28),
                Text = "",
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame,
            }, {
                corner(5),
                stroke(Theme.Stroke, 0.25),
                pad(8, 8, 0, 0),
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
            local items = {}
            for _, item in ipairs(options or {}) do
                table.insert(items, tostring(item))
            end
            local selected = items[1] or ""
            local open = false
            local optionButtons = {}

            local frame = makeControl(page, 44)
            frame.ClipsDescendants = true
            local headerButton = new("TextButton", {
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 44),
                Text = "",
                Parent = frame,
            })
            new("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Position = UDim2.fromOffset(12, 0),
                Size = UDim2.new(0.45, -12, 0, 44),
                Text = tostring(label),
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = headerButton,
            })
            local chosen = new("TextLabel", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Position = UDim2.new(1, -34, 0, 0),
                Size = UDim2.new(0.55, -42, 0, 44),
                Text = selected,
                TextColor3 = Theme.Accent,
                TextSize = 13,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = headerButton,
            })
            local arrow = new("TextLabel", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Position = UDim2.new(1, -12, 0, 0),
                Size = UDim2.fromOffset(18, 44),
                Text = "v",
                TextColor3 = Theme.Muted,
                TextSize = 13,
                Parent = headerButton,
            })
            local list = new("ScrollingFrame", {
                Active = true,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                Position = UDim2.fromOffset(8, 44),
                ScrollBarImageColor3 = Theme.Accent,
                ScrollBarThickness = 3,
                Size = UDim2.new(1, -16, 0, 0),
                Parent = frame,
            })
            local listLayout = new("UIListLayout", {
                Padding = UDim.new(0, 5),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = list,
            })
            local function clearOptions()
                for _, button in ipairs(optionButtons) do
                    button:Destroy()
                end
                optionButtons = {}
            end
            local function resize()
                local visible = math.min(#items, 6)
                local h = open and (44 + visible * 31 + 8) or 44
                frame.Size = UDim2.new(1, 0, 0, h)
                list.Size = UDim2.new(1, -16, 0, open and (visible * 31) or 0)
                arrow.Text = open and "^" or "v"
            end
            local function rebuild()
                clearOptions()
                for _, item in ipairs(items) do
                    local button = new("TextButton", {
                        AutoButtonColor = false,
                        BackgroundColor3 = item == selected and Color3.fromRGB(43, 36, 58) or Theme.Surface,
                        BorderSizePixel = 0,
                        Font = Enum.Font.Gotham,
                        Size = UDim2.new(1, 0, 0, 26),
                        Text = item,
                        TextColor3 = item == selected and Theme.Text or Theme.Muted,
                        TextSize = 13,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Parent = list,
                    }, {
                        corner(5),
                    })
                    button.MouseButton1Click:Connect(function()
                        selected = item
                        chosen.Text = selected
                        open = false
                        rebuild()
                        resize()
                        safeCall(callback, selected)
                    end)
                    table.insert(optionButtons, button)
                end
                task.defer(function()
                    list.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 4)
                end)
            end
            headerButton.MouseButton1Click:Connect(function()
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
                    selected = items[1] or ""
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

        function tab:Bind(label, key, callback)
            local currentKey = key or Enum.KeyCode.RightShift
            local waiting = false
            local button = self:Button(tostring(label) .. ": " .. currentKey.Name, function()
                waiting = true
                button.Text = tostring(label) .. ": ..."
            end)
            UserInputService.InputBegan:Connect(function(input, processed)
                if processed then return end
                if waiting and input.KeyCode ~= Enum.KeyCode.Unknown then
                    currentKey = input.KeyCode
                    waiting = false
                    button.Text = tostring(label) .. ": " .. currentKey.Name
                    return
                end
                if input.KeyCode == currentKey then
                    safeCall(callback)
                end
            end)
            return {
                Set = function(_, newKey)
                    currentKey = newKey
                    button.Text = tostring(label) .. ": " .. currentKey.Name
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
    local gui = parentGui():FindFirstChild("HashHubUI")
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
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(292, 72),
        Parent = holder,
    }, {
        corner(7),
        stroke(Theme.Stroke, 0.2),
        pad(12, 12, 8, 8),
    })
    new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Size = UDim2.new(1, 0, 0, 20),
        Text = tostring(footer or title or "hash hub"),
        TextColor3 = Theme.Text,
        TextSize = 14,
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
        TextSize = 13,
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

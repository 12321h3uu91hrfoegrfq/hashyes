-- hashui.luau
-- Custom Hash Hub UI library.
-- Usage:
-- local lib = loadstring(readfile("hashui.luau"))()
-- local win = lib:Window("Hash Hub Visualizer", Color3.fromRGB(138, 101, 212), Enum.KeyCode.RightShift)

local HashUI = {}
HashUI.__index = HashUI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local THEME = {
    Background = Color3.fromRGB(25, 25, 25),
    Panel = Color3.fromRGB(29, 29, 31),
    PanelAlt = Color3.fromRGB(34, 34, 37),
    Stroke = Color3.fromRGB(58, 58, 63),
    StrokeSoft = Color3.fromRGB(45, 45, 50),
    Text = Color3.fromRGB(224, 224, 226),
    Muted = Color3.fromRGB(170, 170, 176),
    Dim = Color3.fromRGB(116, 116, 124),
    Accent = Color3.fromRGB(138, 101, 212),
    AccentSoft = Color3.fromRGB(97, 72, 150),
    Success = Color3.fromRGB(113, 207, 145),
    Danger = Color3.fromRGB(229, 95, 95),
}

local function make(className, props, children)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    for _, child in ipairs(children or {}) do
        child.Parent = obj
    end
    return obj
end

local function corner(radius)
    return make("UICorner", { CornerRadius = UDim.new(0, radius or 6) })
end

local function stroke(color, thickness, transparency)
    return make("UIStroke", {
        Color = color or THEME.Stroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function padding(l, r, t, b)
    return make("UIPadding", {
        PaddingLeft = UDim.new(0, l or 0),
        PaddingRight = UDim.new(0, r or l or 0),
        PaddingTop = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or t or 0),
    })
end

local function tween(obj, time, props, style, direction)
    local info = TweenInfo.new(
        time or 0.18,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

local function getGuiParent()
    if gethui then
        local ok, result = pcall(gethui)
        if ok and result then return result end
    end
    if syn and syn.protect_gui then
        local protected = make("ScreenGui", {})
        local ok = pcall(function()
            syn.protect_gui(protected)
        end)
        if ok then
            protected:Destroy()
            return playerGui
        end
    end
    return playerGui
end

local function clearExisting(name)
    local parent = getGuiParent()
    local found = parent:FindFirstChild(name)
    if found then found:Destroy() end
end

local function autoCanvas(scroller, layout, extra)
    local function update()
        scroller.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + (extra or 16))
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
    task.defer(update)
end

local function connectHover(btn, enterProps, leaveProps)
    btn.MouseEnter:Connect(function()
        tween(btn, 0.12, enterProps)
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, 0.12, leaveProps)
    end)
end

local function makeText(parent, text, size, color, font)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, size + 8),
        Font = font or Enum.Font.Gotham,
        Text = text or "",
        TextColor3 = color or THEME.Text,
        TextSize = size,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = parent,
    })
end

local function makeIcon(parent, text)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(24, 24),
        Font = Enum.Font.GothamMedium,
        Text = text or "",
        TextColor3 = THEME.Text,
        TextSize = 17,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = parent,
    })
end

local function makeButtonBase(parent, height)
    local btn = make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = THEME.PanelAlt,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, height or 36),
        Font = Enum.Font.Gotham,
        Text = "",
        TextColor3 = THEME.Text,
        TextSize = 14,
        Parent = parent,
    }, {
        corner(6),
        stroke(THEME.StrokeSoft, 1, 0),
    })
    connectHover(btn, { BackgroundColor3 = Color3.fromRGB(39, 39, 43) }, { BackgroundColor3 = THEME.PanelAlt })
    return btn
end

function HashUI:Intro(version, displayName, holdTime)
    clearExisting("HashHubIntro")

    local gui = make("ScreenGui", {
        Name = "HashHubIntro",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = getGuiParent(),
    })

    local bg = make("Frame", {
        BackgroundColor3 = THEME.Background,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Parent = gui,
    })

    local holder = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.55),
        Size = UDim2.fromOffset(420, 112),
        Parent = bg,
    })

    local titleRow = make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 42),
        Parent = holder,
    })

    local title = make("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        RichText = true,
        Size = UDim2.new(1, 0, 1, 0),
        Text = 'hash hub <font color="rgb(138,101,212)">[' .. tostring(version or "2.6.3") .. "]</font>",
        TextColor3 = THEME.Text,
        TextSize = 30,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = titleRow,
    })

    local line = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = THEME.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0, 42),
        Size = UDim2.fromOffset(0, 1),
        Parent = holder,
    })

    local subtitle = make("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        RichText = true,
        Position = UDim2.fromOffset(0, 58),
        Size = UDim2.new(1, 0, 0, 28),
        Text = 'welcome, <font color="rgb(138,101,212)">' .. tostring(displayName or player.Name) .. "</font>, please wait.",
        TextColor3 = THEME.Muted,
        TextSize = 14,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = holder,
    })

    tween(bg, 0.35, { BackgroundTransparency = 0 })
    task.wait(0.12)
    tween(title, 0.35, { TextTransparency = 0 })
    tween(line, 0.45, { BackgroundTransparency = 0, Size = UDim2.fromOffset(226, 1) })
    task.wait(0.1)
    tween(subtitle, 0.35, { TextTransparency = 0 })

    task.wait(holdTime or 2.2)

    tween(title, 0.25, { TextTransparency = 1 })
    tween(subtitle, 0.25, { TextTransparency = 1 })
    tween(line, 0.25, { BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 1) })
    task.wait(0.12)
    tween(bg, 0.35, { BackgroundTransparency = 1 })
    task.wait(0.38)
    gui:Destroy()
end

function HashUI:Window(title, accent, toggleKey)
    clearExisting("HashHubUI")
    THEME.Accent = accent or THEME.Accent
    THEME.AccentSoft = Color3.new(THEME.Accent.R * 0.7, THEME.Accent.G * 0.7, THEME.Accent.B * 0.7)

    local window = {
        Tabs = {},
        CurrentTab = nil,
        ToggleKey = toggleKey or Enum.KeyCode.RightShift,
        Visible = true,
    }

    local gui = make("ScreenGui", {
        Name = "HashHubUI",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = getGuiParent(),
    })
    window.Gui = gui

    local root = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = THEME.Panel,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.52),
        Size = UDim2.fromOffset(560, 430),
        Parent = gui,
    }, {
        corner(8),
        stroke(THEME.Stroke, 1, 0),
    })
    window.Root = root

    local shadow = make("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.62,
        Position = UDim2.fromScale(0.5, 0.5),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        Size = UDim2.new(1, 34, 1, 34),
        ZIndex = 0,
        Parent = root,
    })

    local top = make("Frame", {
        BackgroundColor3 = THEME.Background,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 62),
        ZIndex = 2,
        Parent = root,
    }, {
        corner(8),
        padding(18, 18, 10, 8),
    })

    make("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = THEME.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 8),
        ZIndex = 2,
        Parent = top,
    })

    local titleLabel = make("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        RichText = true,
        Size = UDim2.new(1, -44, 0, 30),
        Text = tostring(title or "hash hub"),
        TextColor3 = THEME.Text,
        TextSize = 24,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = top,
    })

    local accentLine = make("Frame", {
        BackgroundColor3 = THEME.Accent,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 41),
        Size = UDim2.fromOffset(170, 1),
        ZIndex = 3,
        Parent = top,
    })

    local close = make("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        AutoButtonColor = false,
        BackgroundColor3 = Color3.fromRGB(22, 22, 24),
        BorderSizePixel = 0,
        Font = Enum.Font.GothamMedium,
        Position = UDim2.new(1, 0, 0, 4),
        Size = UDim2.fromOffset(30, 30),
        Text = "x",
        TextColor3 = THEME.Muted,
        TextSize = 16,
        ZIndex = 4,
        Parent = top,
    }, {
        corner(6),
        stroke(THEME.StrokeSoft, 1, 0),
    })
    connectHover(close, { BackgroundColor3 = Color3.fromRGB(42, 31, 37), TextColor3 = THEME.Text }, { BackgroundColor3 = Color3.fromRGB(22, 22, 24), TextColor3 = THEME.Muted })

    local body = make("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 62),
        Size = UDim2.new(1, 0, 1, -62),
        ZIndex = 2,
        Parent = root,
    })

    local tabsPanel = make("Frame", {
        BackgroundColor3 = Color3.fromRGB(22, 22, 24),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 150, 1, 0),
        ZIndex = 2,
        Parent = body,
    }, {
        padding(10, 10, 12, 12),
    })

    local tabsLayout = make("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabsPanel,
    })

    local content = make("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(150, 0),
        Size = UDim2.new(1, -150, 1, 0),
        ZIndex = 2,
        Parent = body,
    }, {
        padding(14, 14, 14, 14),
    })

    local pages = make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 2,
        Parent = content,
    })

    local dragging = false
    local dragStart
    local startPos

    top.InputBegan:Connect(function(input)
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
            root.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    local function setVisible(isVisible)
        window.Visible = isVisible
        if isVisible then
            gui.Enabled = true
            root.Size = UDim2.fromOffset(540, 414)
            root.BackgroundTransparency = 1
            tween(root, 0.18, {
                Size = UDim2.fromOffset(560, 430),
                BackgroundTransparency = 0,
            })
        else
            tween(root, 0.15, {
                Size = UDim2.fromOffset(540, 414),
                BackgroundTransparency = 1,
            })
            task.delay(0.16, function()
                if not window.Visible and gui then gui.Enabled = false end
            end)
        end
    end

    close.MouseButton1Click:Connect(function()
        setVisible(false)
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == window.ToggleKey then
            setVisible(not window.Visible)
        end
    end)

    function window:SelectTab(nameOrIndex)
        local selected
        if typeof(nameOrIndex) == "number" then
            selected = self.Tabs[nameOrIndex]
        else
            for _, tab in ipairs(self.Tabs) do
                if tab.Name == nameOrIndex then
                    selected = tab
                    break
                end
            end
        end
        if not selected then return end

        for _, tab in ipairs(self.Tabs) do
            local active = tab == selected
            tab.Page.Visible = active
            tab.Button.BackgroundColor3 = active and THEME.PanelAlt or Color3.fromRGB(22, 22, 24)
            tab.Button.TextColor3 = active and THEME.Text or THEME.Muted
            tab.Accent.BackgroundTransparency = active and 0 or 1
        end
        self.CurrentTab = selected
    end

    function window:Destroy()
        if self.Gui then self.Gui:Destroy() end
    end

    function window:Tab(name)
        local tab = {
            Name = tostring(name),
            Window = self,
        }

        local tabButton = make("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = Color3.fromRGB(22, 22, 24),
            BorderSizePixel = 0,
            Font = Enum.Font.Gotham,
            Size = UDim2.new(1, 0, 0, 38),
            Text = tostring(name),
            TextColor3 = THEME.Muted,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 3,
            Parent = tabsPanel,
        }, {
            corner(6),
            padding(12, 10, 0, 0),
        })

        local tabAccent = make("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = THEME.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -8, 0.5, 0),
            Size = UDim2.fromOffset(3, 18),
            ZIndex = 4,
            Parent = tabButton,
        }, {
            corner(3),
        })

        local scroller = make("ScrollingFrame", {
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarImageColor3 = THEME.Accent,
            ScrollBarThickness = 3,
            Size = UDim2.fromScale(1, 1),
            Visible = false,
            ZIndex = 2,
            Parent = pages,
        }, {
            padding(2, 8, 2, 8),
        })

        local list = make("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = scroller,
        })
        autoCanvas(scroller, list, 18)

        tab.Button = tabButton
        tab.Accent = tabAccent
        tab.Page = scroller
        tab.List = list

        tabButton.MouseButton1Click:Connect(function()
            self:SelectTab(tab.Name)
        end)

        connectHover(tabButton, {
            BackgroundColor3 = Color3.fromRGB(31, 31, 34),
            TextColor3 = THEME.Text,
        }, {
            BackgroundColor3 = self.CurrentTab == tab and THEME.PanelAlt or Color3.fromRGB(22, 22, 24),
            TextColor3 = self.CurrentTab == tab and THEME.Text or THEME.Muted,
        })

        function tab:Section(label)
            local section = makeText(self.Page, label, 13, THEME.Dim, Enum.Font.GothamMedium)
            section.Size = UDim2.new(1, 0, 0, 20)
            return section
        end

        function tab:Button(label, callback)
            local btn = makeButtonBase(self.Page, 38)
            local lbl = make("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Position = UDim2.fromOffset(12, 0),
                Size = UDim2.new(1, -48, 1, 0),
                Text = tostring(label),
                TextColor3 = THEME.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = btn,
            })
            local icon = makeIcon(btn, ">")
            icon.AnchorPoint = Vector2.new(1, 0.5)
            icon.Position = UDim2.new(1, -14, 0.5, 0)

            btn.MouseButton1Click:Connect(function()
                if callback then task.spawn(callback) end
            end)
            return btn
        end

        function tab:Toggle(label, default, callback)
            local state = default == true
            local btn = makeButtonBase(self.Page, 42)
            local lbl = make("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Position = UDim2.fromOffset(12, 0),
                Size = UDim2.new(1, -68, 1, 0),
                Text = tostring(label),
                TextColor3 = THEME.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = btn,
            })

            local pill = make("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = state and THEME.Accent or Color3.fromRGB(54, 54, 59),
                BorderSizePixel = 0,
                Position = UDim2.new(1, -12, 0.5, 0),
                Size = UDim2.fromOffset(40, 20),
                Parent = btn,
            }, {
                corner(10),
            })

            local knob = make("Frame", {
                BackgroundColor3 = Color3.fromRGB(240, 240, 242),
                BorderSizePixel = 0,
                Position = state and UDim2.fromOffset(22, 3) or UDim2.fromOffset(3, 3),
                Size = UDim2.fromOffset(14, 14),
                Parent = pill,
            }, {
                corner(7),
            })

            local function apply(fire)
                tween(pill, 0.14, { BackgroundColor3 = state and THEME.Accent or Color3.fromRGB(54, 54, 59) })
                tween(knob, 0.14, { Position = state and UDim2.fromOffset(22, 3) or UDim2.fromOffset(3, 3) })
                if fire and callback then task.spawn(callback, state) end
            end

            btn.MouseButton1Click:Connect(function()
                state = not state
                apply(true)
            end)

            apply(false)
            if callback then task.spawn(callback, state) end

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

            local holder = make("Frame", {
                BackgroundColor3 = THEME.PanelAlt,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 64),
                Parent = self.Page,
            }, {
                corner(6),
                stroke(THEME.StrokeSoft, 1, 0),
                padding(12, 12, 8, 8),
            })

            local lbl = make("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Size = UDim2.new(1, -60, 0, 22),
                Text = tostring(label),
                TextColor3 = THEME.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = holder,
            })

            local valLbl = make("TextLabel", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Position = UDim2.new(1, 0, 0, 0),
                Size = UDim2.fromOffset(56, 22),
                Text = tostring(value),
                TextColor3 = THEME.Accent,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = holder,
            })

            local bar = make("Frame", {
                BackgroundColor3 = Color3.fromRGB(49, 49, 54),
                BorderSizePixel = 0,
                Position = UDim2.fromOffset(0, 36),
                Size = UDim2.new(1, 0, 0, 6),
                Parent = holder,
            }, {
                corner(3),
            })

            local fill = make("Frame", {
                BackgroundColor3 = THEME.Accent,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 0, 1, 0),
                Parent = bar,
            }, {
                corner(3),
            })

            local hit = make("TextButton", {
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 28),
                Position = UDim2.fromOffset(0, 26),
                Text = "",
                Parent = holder,
            })

            local draggingSlider = false

            local function setFromAlpha(alpha, fire)
                alpha = math.clamp(alpha, 0, 1)
                local raw = min + ((max - min) * alpha)
                value = math.floor(raw * 100 + 0.5) / 100
                if math.abs(value - math.floor(value)) < 0.001 then
                    valLbl.Text = tostring(math.floor(value))
                else
                    valLbl.Text = string.format("%.2f", value)
                end
                fill.Size = UDim2.new(alpha, 0, 1, 0)
                if fire and callback then task.spawn(callback, value) end
            end

            local function updateFromInput(input, fire)
                local alpha = (input.Position.X - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X)
                setFromAlpha(alpha, fire)
            end

            hit.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = true
                    updateFromInput(input, true)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateFromInput(input, true)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = false
                end
            end)

            setFromAlpha((value - min) / math.max(1, max - min), false)
            if callback then task.spawn(callback, value) end

            return {
                Set = function(_, newValue)
                    value = math.clamp(tonumber(newValue) or value, min, max)
                    setFromAlpha((value - min) / math.max(1, max - min), true)
                end,
                Get = function()
                    return value
                end,
            }
        end

        function tab:Textbox(label, numericOnly, callback)
            local holder = make("Frame", {
                BackgroundColor3 = THEME.PanelAlt,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 46),
                Parent = self.Page,
            }, {
                corner(6),
                stroke(THEME.StrokeSoft, 1, 0),
                padding(12, 12, 0, 0),
            })

            local lbl = make("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Size = UDim2.new(0.45, -6, 1, 0),
                Text = tostring(label),
                TextColor3 = THEME.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = holder,
            })

            local box = make("TextBox", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Color3.fromRGB(24, 24, 26),
                BorderSizePixel = 0,
                ClearTextOnFocus = false,
                Font = Enum.Font.Gotham,
                PlaceholderColor3 = THEME.Dim,
                PlaceholderText = numericOnly and "0" or "...",
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(0.55, -6, 0, 30),
                Text = "",
                TextColor3 = THEME.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = holder,
            }, {
                corner(5),
                stroke(THEME.StrokeSoft, 1, 0.2),
                padding(8, 8, 0, 0),
            })

            box.FocusLost:Connect(function()
                local text = box.Text
                if numericOnly then
                    text = text:match("%-?%d+%.?%d*") or ""
                    box.Text = text
                end
                if callback then task.spawn(callback, text) end
            end)

            return box
        end

        function tab:Dropdown(label, options, callback)
            local values = {}
            for _, item in ipairs(options or {}) do table.insert(values, tostring(item)) end
            local selected = values[1] or ""
            local open = false

            local holder = make("Frame", {
                BackgroundColor3 = THEME.PanelAlt,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Size = UDim2.new(1, 0, 0, 46),
                Parent = self.Page,
            }, {
                corner(6),
                stroke(THEME.StrokeSoft, 1, 0),
            })

            local header = make("TextButton", {
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 46),
                Text = "",
                Parent = holder,
            })

            local lbl = make("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Position = UDim2.fromOffset(12, 0),
                Size = UDim2.new(0.48, -12, 1, 0),
                Text = tostring(label),
                TextColor3 = THEME.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = header,
            })

            local chosen = make("TextLabel", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Position = UDim2.new(1, -34, 0, 0),
                Size = UDim2.new(0.52, -38, 1, 0),
                Text = selected,
                TextColor3 = THEME.Accent,
                TextSize = 13,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = header,
            })

            local arrow = make("TextLabel", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Position = UDim2.new(1, -12, 0.5, 0),
                Size = UDim2.fromOffset(18, 18),
                Text = "v",
                TextColor3 = THEME.Muted,
                TextSize = 14,
                Parent = header,
            })

            local listFrame = make("ScrollingFrame", {
                Active = true,
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(8, 46),
                Size = UDim2.new(1, -16, 0, 0),
                BorderSizePixel = 0,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarImageColor3 = THEME.Accent,
                ScrollBarThickness = 3,
                Parent = holder,
            })

            local listLayout = make("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                Padding = UDim.new(0, 5),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = listFrame,
            })

            local optionButtons = {}

            local function resize()
                local visibleCount = math.min(#values, 7)
                local listHeight = math.max(0, visibleCount * 31)
                local targetHeight = open and (52 + listHeight) or 46
                tween(holder, 0.16, { Size = UDim2.new(1, 0, 0, targetHeight) })
                tween(listFrame, 0.16, { Size = UDim2.new(1, -16, 0, open and listHeight or 0) })
                arrow.Text = open and "^" or "v"
            end

            local function buildOptions()
                for _, obj in ipairs(optionButtons) do obj:Destroy() end
                table.clear(optionButtons)

                for _, value in ipairs(values) do
                    local opt = make("TextButton", {
                        AutoButtonColor = false,
                        BackgroundColor3 = value == selected and Color3.fromRGB(42, 36, 54) or Color3.fromRGB(25, 25, 28),
                        BorderSizePixel = 0,
                        Font = Enum.Font.Gotham,
                        Size = UDim2.new(1, 0, 0, 26),
                        Text = value,
                        TextColor3 = value == selected and THEME.Text or THEME.Muted,
                        TextSize = 13,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Parent = listFrame,
                    }, {
                        corner(5),
                    })
                    connectHover(opt, { BackgroundColor3 = Color3.fromRGB(43, 43, 48), TextColor3 = THEME.Text }, { BackgroundColor3 = value == selected and Color3.fromRGB(42, 36, 54) or Color3.fromRGB(25, 25, 28), TextColor3 = value == selected and THEME.Text or THEME.Muted })
                    opt.MouseButton1Click:Connect(function()
                        selected = value
                        chosen.Text = selected
                        open = false
                        buildOptions()
                        resize()
                        if callback then task.spawn(callback, selected) end
                    end)
                    table.insert(optionButtons, opt)
                end
                task.defer(function()
                    listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 4)
                end)
            end

            header.MouseButton1Click:Connect(function()
                open = not open
                resize()
            end)

            buildOptions()
            resize()

            local api = {}

            function api:Refresh(newOptions)
                table.clear(values)
                for _, item in ipairs(newOptions or {}) do table.insert(values, tostring(item)) end
                if not table.find(values, selected) then
                    selected = values[1] or ""
                    chosen.Text = selected
                end
                buildOptions()
                resize()
            end

            api.update = api.Refresh
            api.Update = api.Refresh

            function api:Set(value)
                selected = tostring(value)
                chosen.Text = selected
                buildOptions()
                if callback then task.spawn(callback, selected) end
            end

            function api:Get()
                return selected
            end

            return api
        end

        function tab:Bind(label, key, callback)
            local currentKey = key or Enum.KeyCode.RightShift
            local waiting = false
            local holder = makeButtonBase(self.Page, 42)

            local lbl = make("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Position = UDim2.fromOffset(12, 0),
                Size = UDim2.new(1, -126, 1, 0),
                Text = tostring(label),
                TextColor3 = THEME.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = holder,
            })

            local keyLbl = make("TextLabel", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Color3.fromRGB(24, 24, 26),
                BorderSizePixel = 0,
                Font = Enum.Font.GothamMedium,
                Position = UDim2.new(1, -12, 0.5, 0),
                Size = UDim2.fromOffset(92, 28),
                Text = currentKey.Name,
                TextColor3 = THEME.Accent,
                TextSize = 13,
                Parent = holder,
            }, {
                corner(5),
                stroke(THEME.StrokeSoft, 1, 0.2),
            })

            holder.MouseButton1Click:Connect(function()
                waiting = true
                keyLbl.Text = "..."
            end)

            UserInputService.InputBegan:Connect(function(input, processed)
                if processed then return end
                if waiting and input.KeyCode ~= Enum.KeyCode.Unknown then
                    currentKey = input.KeyCode
                    keyLbl.Text = currentKey.Name
                    waiting = false
                    return
                end
                if input.KeyCode == currentKey and callback then
                    task.spawn(callback)
                end
            end)

            return {
                Set = function(_, newKey)
                    currentKey = newKey
                    keyLbl.Text = currentKey.Name
                end,
                Get = function()
                    return currentKey
                end,
            }
        end

        table.insert(self.Tabs, tab)
        if not self.CurrentTab then
            self:SelectTab(tab.Name)
        end

        return tab
    end

    tween(root, 0.18, { Position = UDim2.fromScale(0.5, 0.5) })
    return window
end

function HashUI:Notification(title, message, footer, duration)
    local gui = getGuiParent():FindFirstChild("HashHubUI")
    if not gui then
        gui = make("ScreenGui", {
            Name = "HashHubUI",
            IgnoreGuiInset = true,
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            Parent = getGuiParent(),
        })
    end

    local holder = gui:FindFirstChild("HashHubNotifications")
    if not holder then
        holder = make("Frame", {
            AnchorPoint = Vector2.new(1, 1),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -18, 1, -18),
            Size = UDim2.fromOffset(300, 360),
            Parent = gui,
        })
        make("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Parent = holder,
        })
    end

    local card = make("Frame", {
        BackgroundColor3 = Color3.fromRGB(24, 24, 26),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(292, 78),
        Parent = holder,
    }, {
        corner(7),
        stroke(THEME.StrokeSoft, 1, 0),
        padding(12, 12, 8, 8),
    })

    local titleLabel = make("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Size = UDim2.new(1, 0, 0, 20),
        Text = tostring(footer or title or "Hash Hub"),
        TextColor3 = THEME.Text,
        TextSize = 14,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })

    local msgLabel = make("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Position = UDim2.fromOffset(0, 24),
        Size = UDim2.new(1, 0, 0, 34),
        Text = tostring(message or ""),
        TextColor3 = THEME.Muted,
        TextSize = 13,
        TextTransparency = 1,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = card,
    })

    local line = make("Frame", {
        BackgroundColor3 = THEME.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = card,
    })

    tween(card, 0.18, { BackgroundTransparency = 0 })
    tween(titleLabel, 0.18, { TextTransparency = 0 })
    tween(msgLabel, 0.18, { TextTransparency = 0 })
    tween(line, 0.18, { BackgroundTransparency = 0 })

    task.delay(duration or 3, function()
        if not card.Parent then return end
        tween(card, 0.2, { BackgroundTransparency = 1 })
        tween(titleLabel, 0.2, { TextTransparency = 1 })
        tween(msgLabel, 0.2, { TextTransparency = 1 })
        tween(line, 0.2, { BackgroundTransparency = 1 })
        task.wait(0.22)
        if card then card:Destroy() end
    end)
end

return HashUI

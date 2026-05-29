--[[
    HashUI Refined
    Clean replacement for the old Bungie/Hash UI library.
    API-compatible with: Load("ui"), Load("notif"), Start, CreatePage, CreateSection,
    CreateButton, CreateCheck, CreateToggle, CreateDropdown, CreateSlider,
    CreateTextbox, CreateKeybind, CreateLabel, CreateDivider.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer:GetMouse()

local Library = {}
local ENV = (getgenv and getgenv()) or _G
ENV.ui = false

local COLORS = {
    Accent = Color3.fromRGB(132, 100, 213),
    AccentDark = Color3.fromRGB(93, 71, 152),
    Bg = Color3.fromRGB(18, 18, 22),
    Bg2 = Color3.fromRGB(24, 24, 30),
    Bg3 = Color3.fromRGB(31, 31, 38),
    Stroke = Color3.fromRGB(48, 48, 58),
    Text = Color3.fromRGB(235, 235, 240),
    Muted = Color3.fromRGB(170, 170, 180),
    Off = Color3.fromRGB(45, 45, 54),
}

local function create(className, props, children)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    for _, child in ipairs(children or {}) do
        child.Parent = obj
    end
    return obj
end

local function tween(obj, time, props)
    local tw = TweenService:Create(obj, TweenInfo.new(time or 0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), props)
    tw:Play()
    return tw
end

local function safeParent(gui)
    local ok = pcall(function()
        gui.Parent = CoreGui
    end)
    if not ok or not gui.Parent then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

local function corner(radius)
    return create("UICorner", {CornerRadius = UDim.new(0, radius or 6)})
end

local function stroke(color, thickness, transparency)
    return create("UIStroke", {
        Color = color or COLORS.Stroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function padding(l, r, t, b)
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, l or 0),
        PaddingRight = UDim.new(0, r or 0),
        PaddingTop = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
    })
end

local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function buttonVisual(btn)
    btn.MouseEnter:Connect(function()
        tween(btn, 0.12, {BackgroundColor3 = COLORS.Bg3})
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, 0.12, {BackgroundColor3 = COLORS.Bg2})
    end)
end

function Library.Load(selectedLibrary)
    selectedLibrary = tostring(selectedLibrary or ""):lower()

    if selectedLibrary:find("notif") then
        local notifications = create("ScreenGui", {
            Name = "HashUI_Notifications",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        })
        safeParent(notifications)

        local holder = create("Frame", {
            Name = "Holder",
            Parent = notifications,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 18, 0, 55),
            Size = UDim2.new(0, 330, 1, -70),
        }, {
            create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
            })
        })

        local NotificationLibrary = {}
        function NotificationLibrary:Send(config)
            config = config or {}
            local header = tostring(config.Header or "HashUI")
            local body = tostring(config.Notification or config.Text or "Notification")
            local lifetime = tonumber(config.Time or 3) or 3

            local card = create("Frame", {
                Parent = holder,
                BackgroundColor3 = COLORS.Bg2,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 320, 0, 0),
                ClipsDescendants = true,
            }, {corner(8), stroke(COLORS.Accent, 1, 0.15)})

            create("Frame", {
                Parent = card,
                BackgroundColor3 = COLORS.Accent,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0, 4, 1, 0),
            })

            create("TextLabel", {
                Parent = card,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 7),
                Size = UDim2.new(1, -24, 0, 18),
                Font = Enum.Font.GothamSemibold,
                Text = header,
                TextColor3 = COLORS.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
            })

            create("TextLabel", {
                Parent = card,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 28),
                Size = UDim2.new(1, -24, 0, 32),
                Font = Enum.Font.Gotham,
                Text = body,
                TextColor3 = COLORS.Muted,
                TextSize = 13,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
            })

            tween(card, 0.18, {BackgroundTransparency = 0, Size = UDim2.new(0, 320, 0, 68)})
            task.delay(lifetime, function()
                if card and card.Parent then
                    tween(card, 0.18, {BackgroundTransparency = 1, Size = UDim2.new(0, 320, 0, 0)})
                    task.wait(0.2)
                    if card then card:Destroy() end
                end
            end)
        end
        return NotificationLibrary
    end

    if selectedLibrary:find("ui") then
        local Interface = {}

        function Interface:Start(config)
            config = config or {}
            ENV.ui = true

            local gui = create("ScreenGui", {
                Name = "HashUI",
                ResetOnSpawn = false,
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            })
            safeParent(gui)

            local main = create("Frame", {
                Parent = gui,
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = COLORS.Bg,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(0, 560, 0, 420),
                ClipsDescendants = true,
            }, {corner(10), stroke(COLORS.Stroke, 1, 0)})

            local topbar = create("Frame", {
                Parent = main,
                BackgroundColor3 = COLORS.Bg2,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 42),
            })

            local accentLine = create("Frame", {
                Parent = topbar,
                BackgroundColor3 = COLORS.Accent,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, -2),
                Size = UDim2.new(1, 0, 0, 2),
            })

            local title = create("TextLabel", {
                Parent = topbar,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 16, 0, 0),
                Size = UDim2.new(1, -32, 1, 0),
                Font = Enum.Font.GothamSemibold,
                Text = tostring(config.Header or "Hash Hub"),
                TextColor3 = COLORS.Text,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
            })

            local tabBar = create("Frame", {
                Parent = main,
                BackgroundColor3 = COLORS.Bg,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 42),
                Size = UDim2.new(1, 0, 0, 38),
            }, {
                padding(10, 10, 6, 6),
                create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 6),
                })
            })

            local pages = create("Frame", {
                Parent = main,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 80),
                Size = UDim2.new(1, 0, 1, -108),
            })

            local footer = create("TextLabel", {
                Parent = main,
                BackgroundColor3 = COLORS.Bg2,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, -28),
                Size = UDim2.new(1, 0, 0, 28),
                Font = Enum.Font.Gotham,
                Text = tostring(config.Footer or "HashUI"),
                TextColor3 = COLORS.Muted,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, {padding(12, 12, 0, 0)})

            makeDraggable(main, topbar)

            local visibleKey = config.VisibleKeybind or Enum.KeyCode.RightAlt
            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed and input.KeyCode == visibleKey then
                    main.Visible = not main.Visible
                end
            end)

            local pageButtons = {}
            local pageFrames = {}

            local function selectPage(pageFrame, pageButton, pageFooter)
                for _, frame in ipairs(pageFrames) do
                    frame.Visible = false
                end
                for _, btn in ipairs(pageButtons) do
                    btn.BackgroundColor3 = COLORS.Bg2
                    btn.TextColor3 = COLORS.Muted
                end
                pageFrame.Visible = true
                pageButton.BackgroundColor3 = COLORS.Accent
                pageButton.TextColor3 = COLORS.Text
                footer.Text = pageFooter or footer.Text
            end

            local InterfaceTools = {}

            function InterfaceTools:CreatePage(pageConfig)
                pageConfig = pageConfig or {}
                local subject = tostring(pageConfig.Subject or "Page")
                local pageFooter = tostring(pageConfig.Footer or subject)

                local textSize = TextService:GetTextSize(subject, 13, Enum.Font.GothamSemibold, Vector2.new(math.huge, 20))
                local tabButton = create("TextButton", {
                    Parent = tabBar,
                    BackgroundColor3 = COLORS.Bg2,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, math.max(65, textSize.X + 24), 1, -2),
                    AutoButtonColor = false,
                    Font = Enum.Font.GothamSemibold,
                    Text = subject,
                    TextColor3 = COLORS.Muted,
                    TextSize = 13,
                }, {corner(7)})

                local page = create("Frame", {
                    Parent = pages,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Visible = false,
                })

                local left = create("ScrollingFrame", {
                    Parent = page,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(0.5, -15, 1, 0),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = COLORS.Accent,
                }, {
                    padding(0, 0, 8, 8),
                    create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
                })

                local right = create("ScrollingFrame", {
                    Parent = page,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.5, 5, 0, 0),
                    Size = UDim2.new(0.5, -15, 1, 0),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = COLORS.Accent,
                }, {
                    padding(0, 0, 8, 8),
                    create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
                })

                table.insert(pageButtons, tabButton)
                table.insert(pageFrames, page)

                local function updateCanvas()
                    local lLayout = left:FindFirstChildOfClass("UIListLayout")
                    local rLayout = right:FindFirstChildOfClass("UIListLayout")
                    left.CanvasSize = UDim2.new(0, 0, 0, lLayout.AbsoluteContentSize.Y + 16)
                    right.CanvasSize = UDim2.new(0, 0, 0, rLayout.AbsoluteContentSize.Y + 16)
                end

                tabButton.MouseButton1Click:Connect(function()
                    selectPage(page, tabButton, pageFooter)
                end)

                if #pageFrames == 1 then
                    selectPage(page, tabButton, pageFooter)
                end

                local PageTools = {}

                function PageTools:CreateSection(sectionConfig)
                    sectionConfig = sectionConfig or {}
                    local parent = left.AbsoluteCanvasSize.Y <= right.AbsoluteCanvasSize.Y and left or right
                    local layout = parent:FindFirstChildOfClass("UIListLayout")
                    if left.CanvasSize.Y.Offset <= right.CanvasSize.Y.Offset then
                        parent = left
                    else
                        parent = right
                    end

                    local section = create("Frame", {
                        Parent = parent,
                        BackgroundColor3 = COLORS.Bg2,
                        Size = UDim2.new(1, -4, 0, 40),
                        AutomaticSize = Enum.AutomaticSize.Y,
                    }, {
                        corner(8), stroke(COLORS.Stroke, 1, 0.2), padding(10, 10, 8, 10),
                        create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 7)})
                    })

                    local sectionHeader = create("TextLabel", {
                        Parent = section,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 20),
                        Font = Enum.Font.GothamSemibold,
                        Text = tostring(sectionConfig.Header or "Section"),
                        TextColor3 = COLORS.Text,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })

                    if sectionHeader.Text == "" then
                        sectionHeader.Visible = false
                        sectionHeader.Size = UDim2.new(1, 0, 0, 0)
                    end

                    local function refresh()
                        task.defer(updateCanvas)
                    end

                    local SectionTools = {}

                    function SectionTools:CreateButton(btnConfig)
                        btnConfig = btnConfig or {}
                        local btn = create("TextButton", {
                            Parent = section,
                            BackgroundColor3 = COLORS.Bg3,
                            Size = UDim2.new(1, 0, 0, 30),
                            AutoButtonColor = false,
                            Font = Enum.Font.Gotham,
                            Text = tostring(btnConfig.Text or "Button"),
                            TextColor3 = COLORS.Text,
                            TextSize = 13,
                        }, {corner(6), stroke(COLORS.Stroke, 1, 0.45)})
                        buttonVisual(btn)
                        btn.MouseButton1Click:Connect(function()
                            task.spawn(btnConfig.Script or function() end)
                        end)
                        refresh()
                        return {
                            SetText = function(_, new) btn.Text = tostring(new) end,
                            Destroy = function() btn:Destroy(); refresh() end,
                        }
                    end

                    function SectionTools:CreateCheck(checkConfig)
                        checkConfig = checkConfig or {}
                        local enabled = checkConfig.Default == true
                        local btn = create("TextButton", {
                            Parent = section,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 26),
                            AutoButtonColor = false,
                            Font = Enum.Font.Gotham,
                            Text = "",
                        })
                        local box = create("Frame", {
                            Parent = btn,
                            BackgroundColor3 = enabled and COLORS.Accent or COLORS.Off,
                            Position = UDim2.new(0, 0, 0.5, -7),
                            Size = UDim2.new(0, 14, 0, 14),
                        }, {corner(4), stroke(COLORS.Stroke, 1, 0.35)})
                        local label = create("TextLabel", {
                            Parent = btn,
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 24, 0, 0),
                            Size = UDim2.new(1, -24, 1, 0),
                            Font = Enum.Font.Gotham,
                            Text = tostring(checkConfig.Text or "Check"),
                            TextColor3 = COLORS.Text,
                            TextSize = 13,
                            TextXAlignment = Enum.TextXAlignment.Left,
                        })
                        btn.MouseButton1Click:Connect(function()
                            enabled = not enabled
                            tween(box, 0.12, {BackgroundColor3 = enabled and COLORS.Accent or COLORS.Off})
                            task.spawn(checkConfig.Script or function() end, enabled)
                        end)
                        refresh()
                        return {
                            SetText = function(_, new) label.Text = tostring(new) end,
                            Set = function(_, state) enabled = state == true; box.BackgroundColor3 = enabled and COLORS.Accent or COLORS.Off end,
                            Get = function() return enabled end,
                            Destroy = function() btn:Destroy(); refresh() end,
                        }
                    end

                    function SectionTools:CreateToggle(toggleConfig)
                        toggleConfig = toggleConfig or {}
                        local loopDelay = tonumber(toggleConfig.Latency or 0.1) or 0.1
                        local tools = SectionTools:CreateCheck({
                            Text = toggleConfig.Text or "Toggle",
                            Default = toggleConfig.Default,
                            Script = function(state)
                                if state then
                                    task.spawn(function()
                                        while tools.Get() do
                                            pcall(toggleConfig.Script or function() end)
                                            task.wait(loopDelay)
                                        end
                                    end)
                                end
                            end,
                        })
                        return tools
                    end

                    function SectionTools:CreateDropdown(dropConfig)
                        dropConfig = dropConfig or {}
                        local holder = create("Frame", {
                            Parent = section,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 54),
                            ClipsDescendants = true,
                        })
                        local label = create("TextLabel", {
                            Parent = holder,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 18),
                            Font = Enum.Font.Gotham,
                            Text = tostring(dropConfig.Text or "Dropdown"),
                            TextColor3 = COLORS.Text,
                            TextSize = 13,
                            TextXAlignment = Enum.TextXAlignment.Left,
                        })
                        local selected = create("TextButton", {
                            Parent = holder,
                            BackgroundColor3 = COLORS.Bg3,
                            Position = UDim2.new(0, 0, 0, 22),
                            Size = UDim2.new(1, 0, 0, 28),
                            AutoButtonColor = false,
                            Font = Enum.Font.Gotham,
                            Text = tostring(dropConfig.Default or "Select"),
                            TextColor3 = COLORS.Muted,
                            TextSize = 13,
                            TextXAlignment = Enum.TextXAlignment.Left,
                        }, {corner(6), stroke(COLORS.Stroke, 1, 0.45), padding(8, 8, 0, 0)})
                        local optionsHolder = create("Frame", {
                            Parent = holder,
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 0, 0, 54),
                            Size = UDim2.new(1, 0, 0, 0),
                        }, {create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})})
                        local open = false
                        local optionButtons = {}

                        local function resize()
                            local count = 0
                            for _, child in ipairs(optionsHolder:GetChildren()) do
                                if child:IsA("TextButton") then count += 1 end
                            end
                            local h = open and (54 + count * 30 + math.max(0, count - 1) * 4) or 54
                            tween(holder, 0.16, {Size = UDim2.new(1, 0, 0, h)})
                            refresh()
                        end

                        local function addOption(option)
                            local optionText = tostring(option)
                            local opt = create("TextButton", {
                                Parent = optionsHolder,
                                BackgroundColor3 = COLORS.Bg3,
                                Size = UDim2.new(1, 0, 0, 30),
                                AutoButtonColor = false,
                                Font = Enum.Font.Gotham,
                                Text = optionText,
                                TextColor3 = COLORS.Text,
                                TextSize = 13,
                            }, {corner(6), stroke(COLORS.Stroke, 1, 0.55)})
                            buttonVisual(opt)
                            opt.MouseButton1Click:Connect(function()
                                selected.Text = optionText
                                open = false
                                resize()
                                task.spawn(dropConfig.Script or function() end, optionText)
                            end)
                            optionButtons[optionText] = opt
                            resize()
                        end

                        for _, option in ipairs(dropConfig.Options or {}) do
                            addOption(option)
                        end

                        selected.MouseButton1Click:Connect(function()
                            open = not open
                            resize()
                        end)
                        refresh()
                        return {
                            SetText = function(_, new) label.Text = tostring(new) end,
                            AddOption = function(_, option) addOption(option) end,
                            RemoveOption = function(_, option)
                                option = tostring(option)
                                if optionButtons[option] then optionButtons[option]:Destroy(); optionButtons[option] = nil; resize() end
                            end,
                            Destroy = function() holder:Destroy(); refresh() end,
                        }
                    end

                    function SectionTools:CreateSlider(sliderConfig)
                        sliderConfig = sliderConfig or {}
                        local values = sliderConfig.Values or {}
                        local min = tonumber(values.Minimum or 0) or 0
                        local max = tonumber(values.Maximum or 100) or 100
                        local current = math.clamp(tonumber(values.Default or min) or min, min, max)
                        local suffix = tostring(sliderConfig.Suffix or "")

                        local holder = create("Frame", {Parent = section, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 48)})
                        local label = create("TextLabel", {
                            Parent = holder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18),
                            Font = Enum.Font.Gotham, Text = tostring(sliderConfig.Text or "Slider"), TextColor3 = COLORS.Text,
                            TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
                        })
                        local valueLabel = create("TextLabel", {
                            Parent = holder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18),
                            Font = Enum.Font.Gotham, Text = tostring(current) .. suffix, TextColor3 = COLORS.Muted,
                            TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right,
                        })
                        local bar = create("TextButton", {
                            Parent = holder, BackgroundColor3 = COLORS.Bg3, BorderSizePixel = 0,
                            Position = UDim2.new(0, 0, 0, 28), Size = UDim2.new(1, 0, 0, 12),
                            Text = "", AutoButtonColor = false,
                        }, {corner(6)})
                        local fill = create("Frame", {
                            Parent = bar, BackgroundColor3 = COLORS.Accent, BorderSizePixel = 0,
                            Size = UDim2.new((current - min) / math.max(max - min, 1), 0, 1, 0),
                        }, {corner(6)})

                        local dragging = false
                        local function setFromX(x, call)
                            local pct = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
                            current = math.floor(min + (max - min) * pct)
                            valueLabel.Text = tostring(current) .. suffix
                            fill.Size = UDim2.new(pct, 0, 1, 0)
                            if call then task.spawn(sliderConfig.Script or function() end, current) end
                        end
                        bar.MouseButton1Down:Connect(function()
                            dragging = true
                            if Mouse then setFromX(Mouse.X, true) end
                        end)
                        UserInputService.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                        end)
                        UserInputService.InputChanged:Connect(function(input)
                            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                                setFromX(input.Position.X, true)
                            end
                        end)
                        refresh()
                        return {
                            SetText = function(_, new) label.Text = tostring(new) end,
                            SetValue = function(_, new) current = math.clamp(tonumber(new) or min, min, max); local pct = (current - min) / math.max(max - min, 1); fill.Size = UDim2.new(pct, 0, 1, 0); valueLabel.Text = tostring(current) .. suffix end,
                            GetValue = function() return current end,
                            Destroy = function() holder:Destroy(); refresh() end,
                        }
                    end

                    function SectionTools:CreateTextbox(textConfig)
                        textConfig = textConfig or {}
                        local holder = create("Frame", {Parent = section, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 52)})
                        local label = create("TextLabel", {
                            Parent = holder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18),
                            Font = Enum.Font.Gotham, Text = tostring(textConfig.Text or "Textbox"), TextColor3 = COLORS.Text,
                            TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
                        })
                        local box = create("TextBox", {
                            Parent = holder, BackgroundColor3 = COLORS.Bg3, Position = UDim2.new(0, 0, 0, 22), Size = UDim2.new(1, 0, 0, 30),
                            ClearTextOnFocus = false, Font = Enum.Font.Gotham, PlaceholderText = tostring(textConfig.Default or ""), Text = "",
                            TextColor3 = COLORS.Text, PlaceholderColor3 = COLORS.Muted, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
                        }, {corner(6), stroke(COLORS.Stroke, 1, 0.45), padding(8, 8, 0, 0)})
                        box.FocusLost:Connect(function(enterPressed)
                            if enterPressed then task.spawn(textConfig.Script or function() end, box.Text) end
                        end)
                        refresh()
                        return {
                            SetText = function(_, new) label.Text = tostring(new) end,
                            SetInput = function(_, new) box.Text = tostring(new) end,
                            ClearInput = function() box.Text = "" end,
                            Destroy = function() holder:Destroy(); refresh() end,
                        }
                    end

                    function SectionTools:CreateKeybind(keyConfig)
                        keyConfig = keyConfig or {}
                        local key = keyConfig.Key or Enum.KeyCode.P
                        local waiting = false
                        local btn = create("TextButton", {
                            Parent = section, BackgroundColor3 = COLORS.Bg3, Size = UDim2.new(1, 0, 0, 30), AutoButtonColor = false,
                            Font = Enum.Font.Gotham, Text = tostring(keyConfig.Text or "Keybind") .. "  [" .. key.Name .. "]",
                            TextColor3 = COLORS.Text, TextSize = 13,
                        }, {corner(6), stroke(COLORS.Stroke, 1, 0.45)})
                        buttonVisual(btn)
                        btn.MouseButton1Click:Connect(function()
                            waiting = true
                            btn.Text = tostring(keyConfig.Text or "Keybind") .. "  [...]"
                        end)
                        UserInputService.InputBegan:Connect(function(input, gameProcessed)
                            if gameProcessed then return end
                            if waiting and input.KeyCode ~= Enum.KeyCode.Unknown then
                                key = input.KeyCode
                                waiting = false
                                btn.Text = tostring(keyConfig.Text or "Keybind") .. "  [" .. key.Name .. "]"
                            elseif input.KeyCode == key then
                                task.spawn(keyConfig.Script or function() end)
                            end
                        end)
                        refresh()
                        return {
                            SetText = function(_, new) btn.Text = tostring(new) .. "  [" .. key.Name .. "]" end,
                            SetKey = function(_, newKey) key = newKey; btn.Text = tostring(keyConfig.Text or "Keybind") .. "  [" .. key.Name .. "]" end,
                            Destroy = function() btn:Destroy(); refresh() end,
                        }
                    end

                    function SectionTools:CreateLabel(labelConfig)
                        labelConfig = labelConfig or {}
                        local lbl = create("TextLabel", {
                            Parent = section, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20),
                            Font = Enum.Font.Gotham, Text = tostring(labelConfig.Text or "Label"), TextColor3 = COLORS.Muted,
                            TextSize = 13, TextXAlignment = labelConfig.Alignment or Enum.TextXAlignment.Left,
                        })
                        refresh()
                        return {SetText = function(_, new) lbl.Text = tostring(new) end, Destroy = function() lbl:Destroy(); refresh() end}
                    end

                    function SectionTools:CreateDivider()
                        local line = create("Frame", {Parent = section, BackgroundColor3 = COLORS.Stroke, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1)})
                        refresh()
                        return {Destroy = function() line:Destroy(); refresh() end}
                    end

                    function SectionTools.SetHeader(_, new)
                        sectionHeader.Text = tostring(new)
                    end

                    refresh()
                    return SectionTools
                end

                function PageTools.SetSubject(_, new)
                    tabButton.Text = tostring(new)
                end
                function PageTools.SetFooter(_, new)
                    pageFooter = tostring(new)
                    if page.Visible then footer.Text = pageFooter end
                end
                return PageTools
            end

            function InterfaceTools.SetHeader(_, new) title.Text = tostring(new) end
            function InterfaceTools.SetFooter(_, new) footer.Text = tostring(new) end
            function InterfaceTools.SetVisibleKeybind(_, new) visibleKey = new end
            function InterfaceTools.SetDragLatency(_) end -- kept for old scripts; dragging is instant now
            function InterfaceTools.Destroy() gui:Destroy() end

            return InterfaceTools
        end

        return Interface
    end

    return Library
end

return Library

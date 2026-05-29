-- hashui.luau | full original patched to Hash Hub loading-screen style
-- kept original API + components; changed visual style/animations only
--  //    stop looking here
--  //    made by bungie#4857


--/ Locals
local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()

--/ Services
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local InputService = game:GetService("UserInputService")
local CoreGuiService = game:GetService("CoreGui")
local ContentService = game:GetService("ContentProvider")

-- / Main Library
local bungiesLibrary = {}

--// global cleanup support, so Library:Destroy() works from scripts
bungiesLibrary._activeGuis = bungiesLibrary._activeGuis or {}
function bungiesLibrary:Destroy()
    for i = #self._activeGuis, 1, -1 do
        local gui = self._activeGuis[i]
        if gui and gui.Parent then
            pcall(function()
                gui:Destroy()
            end)
        end
        table.remove(self._activeGuis, i)
    end
    getgenv().ui = false
end

getgenv().ui = false
function bungiesLibrary.Load(SelectedLibrary)
    SelectedLibrary = tostring(SelectedLibrary or "")
    local selectedLower = string.lower(SelectedLibrary)
    if string.find(selectedLower, "ui", 1, true) then
        ui = true

        -- Tweening
        local TweenAmount = 1
        local TweenTable = {
            Default = {
                TweenInfo.new(0.17, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0)
            }
        }
        local CreateTween = function(Name, Information)
            TweenAmount = TweenAmount + 1
            Name = Name or "Tween-" .. tostring(TweenAmount)

            Information = {
                Speed = Information.Speed or 0.17,
                Style = Information.Style or Enum.EasingStyle.Sine,
                Direction = Information.Direction or Enum.EasingDirection.InOut,
                LoopAmount = Information.LoopAmount or 0,
                Reverse = Information.Reverse or false,
                Delay = Information.Delay or 0
            }

            TweenTable[Name] =
                TweenInfo.new(
                Information.Speed,
                Information.Style,
                Information.Direction,
                Information.LoopAmount,
                Information.Reverse,
                Information.Delay
            )
        end

        -- Dragging
        local Drag = function(Information)
            Information = {
                Object = Information.Object,
                Latency = Information.Latency or 0.06
            }

            toggled = nil
            input = nil
            start = nil

            function updateInput(input)
                local Delta = input.Position - start
                local Position =
                    UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + Delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + Delta.Y
                )
                game:GetService("TweenService"):Create(
                    Information.Object,
                    TweenInfo.new(Information.Latency),
                    {Position = Position}
                ):Play()
            end

            Information.Object.InputBegan:Connect(
                function(inp)
                    if (inp.UserInputType == Enum.UserInputType.MouseButton1) then
                        toggled = true
                        start = inp.Position
                        startPos = Information.Object.Position
                        inp.Changed:Connect(
                            function()
                                if inp.UserInputState == Enum.UserInputState.End then
                                    toggled = false
                                end
                            end
                        )
                    end
                end
            )

            Information.Object.InputChanged:Connect(
                function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseMovement then
                        input = inp
                    end
                end
            )

            game:GetService("UserInputService").InputChanged:Connect(
                function(inp)
                    if inp == input and toggled then
                        updateInput(inp)
                    end
                end
            )
        end

        -- String Generator
        local function genKey()
            local real = ""
            local chars = {}
            local function setChar(a, z)
                for i = string.byte(a), string.byte(z) do
                    table.insert(chars, string.char(i))
                end
            end
            local function getKey()
                local keys = {
                    key1 = {},
                    key2 = {},
                    key3 = {},
                    key4 = {}
                }
                for real1 = 1, 5 do
                    keys.key1[real1] = tostring(chars[math.random(1, #chars)])
                end
                for real2 = 1, 5 do
                    keys.key2[real2] = tostring(chars[math.random(1, #chars)])
                end
                for real3 = 1, 5 do
                    keys.key3[real3] = tostring(chars[math.random(1, #chars)])
                end
                for real4 = 1, 5 do
                    keys.key4[real4] = tostring(chars[math.random(1, #chars)])
                end
                return "ui_[" ..
                    table.concat(keys.key1) ..
                        "-" ..
                            table.concat(keys.key2) ..
                                "-" .. table.concat(keys.key3) .. "-" .. table.concat(keys.key4) .. "]"
            end
            setChar("A", "Z")
            setChar("0", "9")
            return getKey()
        end


        --// Built-in Hash Hub loading screen
        local function ShowHashHubLoadingScreen(LoadingConfiguration)
            LoadingConfiguration = LoadingConfiguration or {}

            local loadingGui = Instance.new("ScreenGui")
            loadingGui.Name = "HashHubLoading"
            loadingGui.IgnoreGuiInset = true
            loadingGui.ResetOnSpawn = false
            loadingGui.DisplayOrder = 999999
            loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            loadingGui.Parent = CoreGuiService
            table.insert(bungiesLibrary._activeGuis, loadingGui)

            local bg = Instance.new("Frame")
            bg.Name = "Background"
            bg.Size = UDim2.fromScale(1, 1)
            bg.BackgroundColor3 = Color3.fromRGB(20, 20, 21)
            bg.BackgroundTransparency = 1
            bg.BorderSizePixel = 0
            bg.Parent = loadingGui

            local vignette = Instance.new("Frame")
            vignette.Name = "Vignette"
            vignette.AnchorPoint = Vector2.new(0.5, 0.5)
            vignette.Position = UDim2.fromScale(0.5, 0.5)
            vignette.Size = UDim2.fromScale(1, 1)
            vignette.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            vignette.BackgroundTransparency = 1
            vignette.BorderSizePixel = 0
            vignette.Parent = bg

            local holder = Instance.new("Frame")
            holder.Name = "Holder"
            holder.AnchorPoint = Vector2.new(0.5, 0.5)
            holder.Position = UDim2.fromScale(0.5, 0.54)
            holder.Size = UDim2.fromOffset(620, 170)
            holder.BackgroundTransparency = 1
            holder.Parent = bg

            local scale = Instance.new("UIScale")
            scale.Scale = 0.94
            scale.Parent = holder

            local titleRow = Instance.new("Frame")
            titleRow.Name = "TitleRow"
            titleRow.AnchorPoint = Vector2.new(0.5, 0)
            titleRow.Position = UDim2.new(0.5, 0, 0, 0)
            titleRow.Size = UDim2.fromOffset(430, 54)
            titleRow.BackgroundTransparency = 1
            titleRow.Parent = holder

            local titleLayout = Instance.new("UIListLayout")
            titleLayout.FillDirection = Enum.FillDirection.Horizontal
            titleLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            titleLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            titleLayout.SortOrder = Enum.SortOrder.LayoutOrder
            titleLayout.Padding = UDim.new(0, 8)
            titleLayout.Parent = titleRow

            local title = Instance.new("TextLabel")
            title.Name = "Title"
            title.BackgroundTransparency = 1
            title.AutomaticSize = Enum.AutomaticSize.X
            title.Size = UDim2.fromOffset(0, 54)
            title.Font = Enum.Font.GothamMedium
            title.Text = LoadingConfiguration.Title or "hash hub"
            title.TextSize = 31
            title.TextColor3 = Color3.fromRGB(232, 232, 235)
            title.TextTransparency = 1
            title.TextXAlignment = Enum.TextXAlignment.Center
            title.LayoutOrder = 1
            title.Parent = titleRow

            local version = Instance.new("TextLabel")
            version.Name = "Version"
            version.BackgroundTransparency = 1
            version.AutomaticSize = Enum.AutomaticSize.X
            version.Size = UDim2.fromOffset(0, 54)
            version.Font = Enum.Font.GothamMedium
            version.Text = LoadingConfiguration.Version or "[2.6.3]"
            version.TextSize = 31
            version.TextColor3 = Color3.fromRGB(135, 105, 215)
            version.TextTransparency = 1
            version.TextXAlignment = Enum.TextXAlignment.Center
            version.LayoutOrder = 2
            version.Parent = titleRow

            local underlineGlow = Instance.new("Frame")
            underlineGlow.Name = "UnderlineGlow"
            underlineGlow.AnchorPoint = Vector2.new(0.5, 0)
            underlineGlow.Position = UDim2.new(0.5, 0, 0, 61)
            underlineGlow.Size = UDim2.fromOffset(0, 1)
            underlineGlow.BackgroundColor3 = Color3.fromRGB(135, 105, 215)
            underlineGlow.BackgroundTransparency = 1
            underlineGlow.BorderSizePixel = 0
            underlineGlow.Parent = holder

            local underline = Instance.new("Frame")
            underline.Name = "Underline"
            underline.AnchorPoint = Vector2.new(0.5, 0)
            underline.Position = UDim2.new(0.5, 0, 0, 61)
            underline.Size = UDim2.fromOffset(0, 1)
            underline.BackgroundColor3 = Color3.fromRGB(135, 105, 215)
            underline.BackgroundTransparency = 1
            underline.BorderSizePixel = 0
            underline.Parent = holder

            local subtitle = Instance.new("TextLabel")
            subtitle.Name = "Subtitle"
            subtitle.AnchorPoint = Vector2.new(0.5, 0)
            subtitle.Position = UDim2.new(0.5, 0, 0, 88)
            subtitle.Size = UDim2.fromOffset(500, 22)
            subtitle.BackgroundTransparency = 1
            subtitle.Font = Enum.Font.Gotham
            subtitle.TextSize = 14
            subtitle.RichText = true
            subtitle.TextTransparency = 1
            subtitle.TextColor3 = Color3.fromRGB(165, 165, 170)
            subtitle.Text = 'welcome, <font color="rgb(145,110,220)">' .. Player.Name .. '</font>, please wait.'
            subtitle.TextXAlignment = Enum.TextXAlignment.Center
            subtitle.Parent = holder

            local dots = Instance.new("TextLabel")
            dots.Name = "Dots"
            dots.AnchorPoint = Vector2.new(0.5, 0)
            dots.Position = UDim2.new(0.5, 0, 0, 116)
            dots.Size = UDim2.fromOffset(120, 20)
            dots.BackgroundTransparency = 1
            dots.Font = Enum.Font.GothamMedium
            dots.TextSize = 18
            dots.TextColor3 = Color3.fromRGB(135, 105, 215)
            dots.TextTransparency = 1
            dots.Text = "•  •  •"
            dots.Parent = holder

            local alive = true
            task.spawn(function()
                local states = {
                    "•  •  •",
                    "•  •  ◦",
                    "•  ◦  ◦",
                    "◦  ◦  ◦",
                    "•  ◦  ◦",
                    "•  •  ◦",
                }

                local index = 1
                while alive and dots.Parent do
                    dots.Text = states[index]
                    index += 1
                    if index > #states then
                        index = 1
                    end
                    task.wait(0.22)
                end
            end)

            local function quickTween(obj, time, props, style, direction)
                local tw = TweenService:Create(
                    obj,
                    TweenInfo.new(time or 0.5, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out),
                    props
                )
                tw:Play()
                return tw
            end

            quickTween(bg, 0.65, {BackgroundTransparency = 0})
            quickTween(vignette, 0.9, {BackgroundTransparency = 0.72})
            task.wait(0.2)

            quickTween(scale, 0.8, {Scale = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            quickTween(holder, 0.8, {Position = UDim2.fromScale(0.5, 0.5)})
            quickTween(title, 0.75, {TextTransparency = 0})
            quickTween(version, 0.75, {TextTransparency = 0})

            task.wait(0.16)

            quickTween(underline, 0.7, {
                Size = UDim2.fromOffset(220, 1),
                BackgroundTransparency = 0.15
            })

            quickTween(underlineGlow, 0.7, {
                Size = UDim2.fromOffset(260, 1),
                BackgroundTransparency = 0.72
            })

            task.wait(0.16)

            quickTween(subtitle, 0.7, {
                TextTransparency = 0,
                Position = UDim2.new(0.5, 0, 0, 82)
            })

            task.wait(0.12)
            quickTween(dots, 0.6, {TextTransparency = 0.15})
            task.wait(LoadingConfiguration.Duration or 1.75)

            alive = false

            quickTween(scale, 0.55, {Scale = 0.96}, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
            quickTween(holder, 0.55, {Position = UDim2.fromScale(0.5, 0.47)}, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
            quickTween(title, 0.45, {TextTransparency = 1})
            quickTween(version, 0.45, {TextTransparency = 1})
            quickTween(subtitle, 0.45, {
                TextTransparency = 1,
                Position = UDim2.new(0.5, 0, 0, 94)
            })
            quickTween(dots, 0.35, {TextTransparency = 1})
            quickTween(underline, 0.45, {
                Size = UDim2.fromOffset(0, 1),
                BackgroundTransparency = 1
            })
            quickTween(underlineGlow, 0.45, {
                Size = UDim2.fromOffset(0, 1),
                BackgroundTransparency = 1
            })

            task.wait(0.32)

            quickTween(bg, 0.7, {BackgroundTransparency = 1})
            quickTween(vignette, 0.7, {BackgroundTransparency = 1})

            task.wait(0.75)
            alive = false
            if loadingGui and loadingGui.Parent then
                loadingGui:Destroy()
            end
        end


        -- Window function
        local Interface = {}
        function Interface:Start(Configuration)
            ui = true
            Configuration = Configuration or {}
            Configuration = {
                Header = Configuration.Header or "undefined header",
                Footer = Configuration.Footer or
                    "undefined footer  |   " ..
                        game.Players.LocalPlayer.Name ..
                            " | " .. os.date("%d") .. "/" .. os.date("%m") .. "/" .. os.date("%Y"),
                VisibleKeybind = Configuration.VisibleKeybind or Enum.KeyCode.RightAlt
            }

            pcall(function()
                ShowHashHubLoadingScreen({
                    Title = "hash hub",
                    Version = "[2.6.3]",
                    Duration = 1.75
                })
            end)

            local private = Instance.new("ScreenGui")
            local design = Instance.new("Frame")
            local design_1 = Instance.new("Frame")
            local layout_design_1 = Instance.new("UIListLayout")
            local background = Instance.new("Frame")
            local container_tabs = Instance.new("Frame")
            local header_label = Instance.new("TextLabel")
            local padding_header_label = Instance.new("UIPadding")
            local footer_label = Instance.new("TextLabel")
            local padding_footer_label = Instance.new("UIPadding")
            local cut_tab_buttons = Instance.new("Frame")
            local cut_header = Instance.new("Frame")
            local cut_footer = Instance.new("Frame")
            local container_tab_buttons = Instance.new("Frame")
            local layout_tab_buttons = Instance.new("UIListLayout")
            local padding_tab_buttons = Instance.new("UIPadding")
            local layout_design = Instance.new("UIListLayout")

            private.Name = genKey()
            private.Parent = CoreGuiService
            table.insert(bungiesLibrary._activeGuis, private)

            design.Name = "design"
            design.Parent = private
            design.AnchorPoint = Vector2.new(0.5, 0.5)
            design.BackgroundColor3 = Color3.fromRGB(135, 105, 215)
            design.BorderColor3 = Color3.fromRGB(18, 18, 20)
            design.Position = UDim2.new(0.5, 0, 0.5, 0)
            design.Size = UDim2.new(0, 513, 0, 585)
            design.BackgroundTransparency = 0
            design.ClipsDescendants = false

            local designScale = Instance.new("UIScale")
            designScale.Name = "hashhub_smooth_scale"
            designScale.Scale = 1
            designScale.Parent = design

            local designCorner = Instance.new("UICorner")
            designCorner.CornerRadius = UDim.new(0, 8)
            designCorner.Parent = design

            local designStroke = Instance.new("UIStroke")
            designStroke.Color = Color3.fromRGB(135, 105, 215)
            designStroke.Transparency = 0.25
            designStroke.Thickness = 1
            designStroke.Parent = design
            designLatency = 0.075
            Drag(
                {
                    Object = design,
                    Latency = designLatency
                }
            )
            local visKey = Configuration.VisibleKeybind
            local windowVisible = true
            local toggleBusy = false
            local function setWindowVisible(state)
                if toggleBusy or windowVisible == state then return end
                toggleBusy = true
                windowVisible = state

                if state then
                    design.Visible = true
                    designScale.Scale = 0.965
                    design.BackgroundTransparency = 0.25
                    TweenService:Create(designScale, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Scale = 1}):Play()
                    TweenService:Create(design, TweenInfo.new(0.20, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
                    task.delay(0.25, function()
                        toggleBusy = false
                    end)
                else
                    TweenService:Create(designScale, TweenInfo.new(0.20, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Scale = 0.94}):Play()
                    TweenService:Create(design, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {BackgroundTransparency = 0.45}):Play()
                    task.delay(0.20, function()
                        design.Visible = false
                        toggleBusy = false
                    end)
                end
            end

            UserInputService.InputBegan:Connect(
                function(i, gameProcessed)
                    if gameProcessed then return end
                    if i.KeyCode == visKey then
                        setWindowVisible(not windowVisible)
                    end
                end
            )

            design_1.Name = "design_1"
            design_1.Parent = design
            design_1.AnchorPoint = Vector2.new(0.5, 0.5)
            design_1.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
            design_1.BorderColor3 = Color3.fromRGB(18, 18, 20)
            design_1.Position = UDim2.new(0.5, 0, 0.5, 0)
            design_1.Size = UDim2.new(0, 509, 0, 581)

            local design1Corner = Instance.new("UICorner")
            design1Corner.CornerRadius = UDim.new(0, 7)
            design1Corner.Parent = design_1

            layout_design_1.Name = "layout_design_1"
            layout_design_1.Parent = design_1
            layout_design_1.HorizontalAlignment = Enum.HorizontalAlignment.Center
            layout_design_1.SortOrder = Enum.SortOrder.LayoutOrder
            layout_design_1.VerticalAlignment = Enum.VerticalAlignment.Center

            background.Name = "background"
            background.Parent = design_1
            background.AnchorPoint = Vector2.new(0.5, 0.5)
            background.BackgroundColor3 = Color3.fromRGB(20, 20, 21)
            background.BorderColor3 = Color3.fromRGB(18, 18, 20)
            background.Position = UDim2.new(0.5, 0, 0.5, 0)
            background.Size = UDim2.new(0, 505, 0, 577)

            local backgroundCorner = Instance.new("UICorner")
            backgroundCorner.CornerRadius = UDim.new(0, 6)
            backgroundCorner.Parent = background

            container_tabs.Name = "container_tabs"
            container_tabs.Parent = background
            container_tabs.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
            container_tabs.BorderSizePixel = 0
            container_tabs.Position = UDim2.new(0.00100000005, 0, 0.0869999975, 0)
            container_tabs.Size = UDim2.new(0, 504, 0, 507)

            header_label.Name = "header_label"
            header_label.Parent = background
            header_label.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
            header_label.BorderSizePixel = 0
            header_label.Size = UDim2.new(0, 505, 0, 19)
            header_label.Font = Enum.Font.Gotham
            header_label.LineHeight = 1.150
            header_label.Text = Configuration.Header
            header_label.TextColor3 = Color3.fromRGB(232, 232, 232)
            header_label.TextSize = 16.000
            header_label.TextStrokeColor3 = Color3.fromRGB(16, 16, 16)
            header_label.TextStrokeTransparency = 0.300
            header_label.TextXAlignment = Enum.TextXAlignment.Left
            header_label.TextTruncate = "AtEnd"

            padding_header_label.Name = "padding_header_label"
            padding_header_label.Parent = header_label
            padding_header_label.PaddingLeft = UDim.new(0, 5)

            footer_label.Name = "footer_label"
            footer_label.Parent = background
            footer_label.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
            footer_label.BackgroundTransparency = 0.300
            footer_label.BorderSizePixel = 0
            footer_label.Position = UDim2.new(0, 0, 0.967071056, 0)
            footer_label.Size = UDim2.new(0, 505, 0, 19)
            footer_label.Font = Enum.Font.Gotham
            footer_label.LineHeight = 1.150
            footer_label.Text = Configuration.Footer
            footer_label.TextColor3 = Color3.fromRGB(70, 60, 95)
            footer_label.TextSize = 15.000
            footer_label.TextStrokeColor3 = Color3.fromRGB(16, 16, 16)
            footer_label.TextStrokeTransparency = 0.500
            footer_label.TextXAlignment = Enum.TextXAlignment.Left
            footer_label.TextTruncate = "AtEnd"

            padding_footer_label.Name = "padding_footer_label"
            padding_footer_label.Parent = footer_label
            padding_footer_label.PaddingLeft = UDim.new(0, 5)

            cut_tab_buttons.Name = "cut_tab_buttons"
            cut_tab_buttons.Parent = background
            cut_tab_buttons.BackgroundColor3 = Color3.fromRGB(60, 52, 82)
            cut_tab_buttons.BorderSizePixel = 0
            cut_tab_buttons.Position = UDim2.new(0, 0, 0.0849220082, 0)
            cut_tab_buttons.Size = UDim2.new(0, 505, 0, 1)

            cut_header.Name = "cut_header"
            cut_header.Parent = background
            cut_header.BackgroundColor3 = Color3.fromRGB(60, 52, 82)
            cut_header.BackgroundTransparency = 0.300
            cut_header.BorderSizePixel = 0
            cut_header.Position = UDim2.new(0, 0, 0.031195838, 0)
            cut_header.Size = UDim2.new(0, 505, 0, 1)

            cut_footer.Name = "cut_footer"
            cut_footer.Parent = background
            cut_footer.BackgroundColor3 = Color3.fromRGB(60, 52, 82)
            cut_footer.BackgroundTransparency = 0.600
            cut_footer.BorderSizePixel = 0
            cut_footer.Position = UDim2.new(0, 0, 0.965337932, 0)
            cut_footer.Size = UDim2.new(0, 505, 0, 1)

            container_tab_buttons.Name = "container_tab_buttons"
            container_tab_buttons.Parent = background
            container_tab_buttons.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
            container_tab_buttons.BorderSizePixel = 0
            container_tab_buttons.Position = UDim2.new(0, 0, 0.0329289436, 0)
            container_tab_buttons.Size = UDim2.new(0, 505, 0, 30)

            layout_tab_buttons.Name = "layout_tab_buttons"
            layout_tab_buttons.Parent = container_tab_buttons
            layout_tab_buttons.FillDirection = Enum.FillDirection.Horizontal
            layout_tab_buttons.SortOrder = Enum.SortOrder.LayoutOrder
            layout_tab_buttons.VerticalAlignment = Enum.VerticalAlignment.Bottom
            layout_tab_buttons.Padding = UDim.new(0, 4)

            padding_tab_buttons.Name = "padding_tab_buttons"
            padding_tab_buttons.Parent = container_tab_buttons
            padding_tab_buttons.PaddingBottom = UDim.new(0, -1)
            padding_tab_buttons.PaddingLeft = UDim.new(0, 6)
            padding_tab_buttons.PaddingRight = UDim.new(0, 6)

            layout_design.Name = "layout_design"
            layout_design.Parent = design
            layout_design.HorizontalAlignment = Enum.HorizontalAlignment.Center
            layout_design.SortOrder = Enum.SortOrder.LayoutOrder
            layout_design.VerticalAlignment = Enum.VerticalAlignment.Center

            local InterfaceTools = {}
            local isFirstPageAdded = true
            function InterfaceTools:CreatePage(Configuration_Page)
                Configuration_Page = Configuration_Page or {}
                Configuration_Page = {
                    Subject = Configuration_Page.Subject or "undefined subject",
                    Footer = Configuration_Page.Footer or "undefined footer"
                }

                local button_tab = Instance.new("TextButton")
                local cut_button_tab = Instance.new("Frame")
                local layout_button_tab = Instance.new("UIListLayout")
                local tab = Instance.new("Frame")
                local container_component_right = Instance.new("ScrollingFrame")
                local layout_components_right = Instance.new("UIListLayout")
                local padding_components_right = Instance.new("UIPadding")
                local container_component_left = Instance.new("ScrollingFrame")
                local layout_components_left = Instance.new("UIListLayout")
                local padding_components_left = Instance.new("UIPadding")
                local layout_tab = Instance.new("UIListLayout")

                button_tab.Name = "button_tab"
                button_tab.Parent = container_tab_buttons
                button_tab.BackgroundColor3 = Color3.fromRGB(21, 21, 23)
                button_tab.BackgroundTransparency = 0.4
                button_tab.BorderColor3 = Color3.fromRGB(60, 52, 82)
                button_tab.Position = UDim2.new(0.0118811885, 0, 0.233333334, 0)
                button_tab.Size = UDim2.new(0, math.max(15, button_tab.TextBounds.X), 0, 22)
                button_tab.AutoButtonColor = false
                button_tab.Font = Enum.Font.Gotham
                button_tab.LineHeight = 1.150
                button_tab.Text = Configuration_Page.Subject
                button_tab.TextColor3 = Color3.fromRGB(180, 180, 180)
                button_tab.TextSize = 14.000
                button_tab.TextStrokeColor3 = Color3.fromRGB(16, 16, 16)
                button_tab.TextStrokeTransparency = 0.300
                button_tab.BorderMode = "Inset"
                button_tab.TextTransparency = 0.4

                local newTabButtonSize =
                    TextService:GetTextSize(
                    button_tab.Text,
                    button_tab.TextSize,
                    button_tab.Font,
                    Vector2.new(math.huge, math.huge)
                )
                button_tab.Size = UDim2.new(0, 12 + newTabButtonSize.X, 0, 22)

                cut_button_tab.Name = "cut_button_tab"
                cut_button_tab.Parent = button_tab
                cut_button_tab.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
                cut_button_tab.BorderColor3 = Color3.fromRGB(24, 24, 26)
                cut_button_tab.Position = UDim2.new(0, 0, 1, 0)
                cut_button_tab.Size = UDim2.new(0, button_tab.Size.X.Offset - 4, 0, 1)
                cut_button_tab.ZIndex = 2
                cut_button_tab.Visible = false

                layout_button_tab.Name = "layout_button_tab"
                layout_button_tab.Parent = button_tab
                layout_button_tab.HorizontalAlignment = Enum.HorizontalAlignment.Center
                layout_button_tab.SortOrder = Enum.SortOrder.LayoutOrder
                layout_button_tab.VerticalAlignment = Enum.VerticalAlignment.Bottom

                tab.Name = "tab"
                tab.Parent = container_tabs
                tab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                tab.BackgroundTransparency = 1.000
                tab.Size = UDim2.new(0, 504, 0, 507)
                tab.Visible = false

                container_component_right.Name = "container_component_right"
                container_component_right.Parent = tab
                container_component_right.Active = true
                container_component_right.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                container_component_right.BackgroundTransparency = 1.000
                container_component_right.BorderSizePixel = 0
                container_component_right.Size = UDim2.new(0, 252, 0, 507)
                container_component_right.ScrollBarThickness = 0

                layout_components_right.Name = "layout_components_right"
                layout_components_right.Parent = container_component_right
                layout_components_right.HorizontalAlignment = Enum.HorizontalAlignment.Center
                layout_components_right.SortOrder = Enum.SortOrder.LayoutOrder
                layout_components_right.Padding = UDim.new(0, 5)

                padding_components_right.Name = "padding_components_right"
                padding_components_right.Parent = container_component_right
                padding_components_right.PaddingTop = UDim.new(0, 10)

                container_component_left.Name = "container_component_left"
                container_component_left.Parent = tab
                container_component_left.Active = true
                container_component_left.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                container_component_left.BackgroundTransparency = 1.000
                container_component_left.BorderSizePixel = 0
                container_component_left.Size = UDim2.new(0, 252, 0, 507)
                container_component_left.CanvasSize = UDim2.new(0, 0, 0, 0)
                container_component_left.ScrollBarThickness = 0

                layout_components_left.Name = "layout_components_left"
                layout_components_left.Parent = container_component_left
                layout_components_left.HorizontalAlignment = Enum.HorizontalAlignment.Center
                layout_components_left.SortOrder = Enum.SortOrder.LayoutOrder
                layout_components_left.Padding = UDim.new(0, 5)

                padding_components_left.Name = "padding_components_left"
                padding_components_left.Parent = container_component_left
                padding_components_left.PaddingTop = UDim.new(0, 10)

                layout_tab.Name = "layout_tab"
                layout_tab.Parent = tab
                layout_tab.FillDirection = Enum.FillDirection.Horizontal
                layout_tab.SortOrder = Enum.SortOrder.LayoutOrder
                layout_tab.VerticalAlignment = Enum.VerticalAlignment.Center

                local function updateSize()
                    local csL, csR =
                        layout_components_left.AbsoluteContentSize.Y,
                        layout_components_right.AbsoluteContentSize.Y
                    container_component_left.CanvasSize = UDim2.new(0, 0, 0, csL + 9)
                    container_component_right.CanvasSize = UDim2.new(0, 0, 0, csR + 9)
                end

                local PageIsVisible = false

                if isFirstPageAdded then
                    PageIsVisible = true
                    tab.Visible = true
                    button_tab.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
                    button_tab.BackgroundTransparency = 0
                    button_tab.TextColor3 = Color3.fromRGB(222, 222, 222)
                    button_tab.TextTransparency = 0
                    button_tab.TextStrokeTransparency = 0.3
                    button_tab.Size = UDim2.new(0, button_tab.Size.X.Offset, 0, 24)
                    cut_button_tab.Visible = true
                    footer_label.Text = Configuration_Page.Footer
                    updateSize()
                end

                button_tab.MouseButton1Click:Connect(
                    function()
                        for i, v in next, container_tabs:GetChildren() do
                            if v:IsA("Frame") then
                                v.Visible = false
                            end
                        end
                        for i, v in next, container_tab_buttons:GetChildren() do
                            if v:IsA("TextButton") then
                                v.BackgroundColor3 = Color3.fromRGB(21, 21, 23)
                                v.BackgroundTransparency = 0.4
                                v.TextColor3 = Color3.fromRGB(180, 180, 180)
                                v.TextTransparency = 0.4
                                v.TextStrokeTransparency = 0.4
                                v.Size = UDim2.new(0, v.Size.X.Offset, 0, 22)
                                for z, x in next, v:GetChildren() do
                                    if x:IsA("Frame") then
                                        x.Visible = false
                                    end
                                end
                            end
                        end
                        tab.Visible = true
                        button_tab.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
                        button_tab.BackgroundTransparency = 0
                        button_tab.TextColor3 = Color3.fromRGB(222, 222, 222)
                        button_tab.TextTransparency = 0
                        button_tab.TextStrokeTransparency = 0.3
                        button_tab.Size = UDim2.new(0, button_tab.Size.X.Offset, 0, 24)
                        cut_button_tab.Visible = true
                        footer_label.Text = Configuration_Page.Footer
                        updateSize()
                    end
                )

                isFirstPageAdded = false

                local PageTools = {}
                function PageTools:CreateSection(Configuration_Section)
                    Configuration_Section = Configuration_Section or {}
                    Configuration_Section = {
                        Header = Configuration_Section.Header or "Section"
                    }

                    local alignedContainer
                    if layout_components_left.AbsoluteContentSize.Y > layout_components_right.AbsoluteContentSize.Y then
                        alignedContainer = container_component_right
                    else
                        alignedContainer = container_component_left
                    end

                    local section = Instance.new("Frame")
                    local layout_section = Instance.new("UIListLayout")
                    local section_design = Instance.new("Frame")
                    local section_header = Instance.new("TextLabel")
                    local padding_section_header = Instance.new("UIPadding")
                    local constraint_section = Instance.new("UISizeConstraint")

                    section.Name = "section"
                    section.Parent = alignedContainer
                    section.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
                    section.BorderColor3 = Color3.fromRGB(29, 29, 32)
                    section.Position = UDim2.new(0.0317460336, 0, 0.0197238661, 0)
                    section.Size = UDim2.new(0, 236, 0, 1)

                    layout_section.Name = "layout_section"
                    layout_section.Parent = section
                    layout_section.HorizontalAlignment = Enum.HorizontalAlignment.Center
                    layout_section.SortOrder = Enum.SortOrder.LayoutOrder
                    layout_section.Padding = UDim.new(0, 3)

                    section_design.Name = "section_design"
                    section_design.Parent = section
                    section_design.BackgroundColor3 = Color3.fromRGB(135, 105, 215)
                    section_design.BorderSizePixel = 0
                    section_design.Size = UDim2.new(0, 236, 0, 1)

                    section_header.Name = "section_header"
                    section_header.Parent = section
                    section_header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    section_header.BackgroundTransparency = 1.000
                    section_header.BorderSizePixel = 0
                    section_header.Position = UDim2.new(0, 0, 0.0399999991, 0)
                    section_header.Size = UDim2.new(0, 236, 0, 18)
                    section_header.Font = Enum.Font.Gotham
                    section_header.LineHeight = 1.150
                    section_header.Text = Configuration_Section.Header
                    section_header.TextColor3 = Color3.fromRGB(225, 225, 225)
                    section_header.TextSize = 14.000
                    section_header.TextStrokeColor3 = Color3.fromRGB(14, 14, 14)
                    section_header.TextStrokeTransparency = 0.300
                    section_header.TextXAlignment = Enum.TextXAlignment.Left
                    section_header.TextTruncate = "AtEnd"

                    padding_section_header.Name = "padding_section_header"
                    padding_section_header.Parent = section_header
                    padding_section_header.PaddingLeft = UDim.new(0, 7)

                    local sectionCorner = Instance.new("UICorner")
                    sectionCorner.CornerRadius = UDim.new(0, 6)
                    sectionCorner.Parent = section

                    local sectionStroke = Instance.new("UIStroke")
                    sectionStroke.Color = Color3.fromRGB(50, 45, 66)
                    sectionStroke.Transparency = 0.35
                    sectionStroke.Thickness = 1
                    sectionStroke.Parent = section

                    constraint_section.Name = "constraint_section"
                    constraint_section.Parent = section
                    constraint_section.MinSize = Vector2.new(236, 26)

                    if Configuration_Section.Header == "" then
                        section_header:Destroy()
                    end

                    updateSize()

                    local function updateSection()
                        local sc = layout_section.AbsoluteContentSize.Y
                        section.Size = UDim2.new(0, 236, 0, sc + 4)
                    end

                    local SectionTools = {}
                    function SectionTools:CreateButton(Configuration_Button)
                        Configuration_Button = Configuration_Button or {}
                        Configuration_Button = {
                            Text = Configuration_Button.Text or "button",
                            Script = Configuration_Button.Script or function()
                                end
                        }

                        local design_button = Instance.new("Frame")
                        local layout_design_button = Instance.new("UIListLayout")
                        local button = Instance.new("TextButton")
                        local gradient_design_button = Instance.new("UIGradient")
                        local layout_button = Instance.new("UIListLayout")
                        local button_text = Instance.new("TextLabel")
                        local gradient_design_button_2 = Instance.new("UIGradient")

                        design_button.Name = "design_button"
                        design_button.Parent = section
                        design_button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        design_button.BorderColor3 = Color3.fromRGB(70, 60, 95)
                        design_button.Size = UDim2.new(0, 221, 0, 22)

                        layout_design_button.Name = "layout_design_button"
                        layout_design_button.Parent = design_button
                        layout_design_button.HorizontalAlignment = Enum.HorizontalAlignment.Center
                        layout_design_button.SortOrder = Enum.SortOrder.LayoutOrder
                        layout_design_button.VerticalAlignment = Enum.VerticalAlignment.Center

                        button.Name = "button"
                        button.Parent = design_button
                        button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        button.BorderSizePixel = 0
                        button.Size = UDim2.new(0, 219, 0, 20)
                        button.AutoButtonColor = false
                        button.Font = Enum.Font.Gotham
                        button.Text = ""
                        button.TextColor3 = Color3.fromRGB(225, 225, 225)
                        button.TextSize = 14.000

                        gradient_design_button.Color =
                            ColorSequence.new {
                            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(24, 24, 26)),
                            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(28, 28, 31))
                        }
                        gradient_design_button.Rotation = 90
                        gradient_design_button.Name = "gradient_design_button"
                        gradient_design_button.Parent = button

                        layout_button.Name = "layout_button"
                        layout_button.Parent = button
                        layout_button.HorizontalAlignment = Enum.HorizontalAlignment.Center
                        layout_button.SortOrder = Enum.SortOrder.LayoutOrder
                        layout_button.VerticalAlignment = Enum.VerticalAlignment.Center

                        button_text.Name = "button_text"
                        button_text.Parent = button
                        button_text.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        button_text.BackgroundTransparency = 1.000
                        button_text.Size = UDim2.new(0, 219, 0, 20)
                        button_text.Font = Enum.Font.Gotham
                        button_text.LineHeight = 1
                        button_text.Text = Configuration_Button.Text
                        button_text.TextColor3 = Color3.fromRGB(220, 220, 220)
                        button_text.TextSize = 14.000
                        button_text.TextStrokeColor3 = Color3.fromRGB(14, 14, 14)
                        button_text.TextStrokeTransparency = 0.300

                        gradient_design_button_2.Color =
                            ColorSequence.new {
                            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(20, 20, 21)),
                            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(29, 29, 32))
                        }
                        gradient_design_button_2.Rotation = 90
                        gradient_design_button_2.Name = "gradient_design_button"
                        gradient_design_button_2.Parent = design_button

                        local buttonCorner = Instance.new("UICorner")
                        buttonCorner.CornerRadius = UDim.new(0, 4)
                        buttonCorner.Parent = design_button

                        local innerButtonCorner = Instance.new("UICorner")
                        innerButtonCorner.CornerRadius = UDim.new(0, 3)
                        innerButtonCorner.Parent = button

                        updateSection()
                        updateSize()

                        button.MouseEnter:Connect(
                            function()
                                gradient_design_button_2.Color =
                                    ColorSequence.new {
                                    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(145, 110, 220)),
                                    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(92, 68, 158))
                                }
                            end
                        )
                        button.MouseLeave:Connect(
                            function()
                                gradient_design_button_2.Color =
                                    ColorSequence.new {
                                    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(35, 35, 39)),
                                    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(31, 31, 35))
                                }
                            end
                        )

                        button.MouseButton1Down:Connect(
                            function()
                                gradient_design_button.Color =
                                    ColorSequence.new {
                                    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(21, 21, 23)),
                                    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(28, 28, 31))
                                }
                            end
                        )
                        button.MouseButton1Up:Connect(
                            function()
                                gradient_design_button.Color =
                                    ColorSequence.new {
                                    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(47, 47, 47)),
                                    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(42, 42, 42))
                                }
                                wait(.2)
                                gradient_design_button.Color =
                                    ColorSequence.new {
                                    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(31, 31, 31)),
                                    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(29, 29, 32))
                                }
                            end
                        )

                        button.MouseButton1Click:Connect(
                            function()
                                Configuration_Button.Script()
                            end
                        )

                        local ButtonTools = {}
                        function ButtonTools.SetText(new)
                            button_text.Text = new
                        end
                        function SetLocalButtonText(new)
                            button_text.Text = new
                        end
                        return ButtonTools
                    end
                    function SectionTools:CreateToggle(Configuration_Toggle)
                        Configuration_Toggle = Configuration_Toggle or {}
                        Configuration_Toggle = {
                            Text = Configuration_Toggle.Text or "toggle",
                            Latency = Configuration_Toggle.Latency or 0,
                            Script = Configuration_Toggle.Script or function()
                                    print("toggled")
                                end
                        }

                        local button_toggle = Instance.new("TextButton")
                        local layout_button_toggle = Instance.new("UIListLayout")
                        local design_button_toggle = Instance.new("Frame")
                        local layout_design_button_toggle = Instance.new("UIListLayout")
                        local gradient_design_button_toggle = Instance.new("UIGradient")
                        local design_button_toggle_2 = Instance.new("Frame")
                        local layout_design_button_toggle_2 = Instance.new("UIListLayout")
                        local gradient_design_button_toggle_2 = Instance.new("UIGradient")
                        local padding_button_toggle = Instance.new("UIPadding")

                        button_toggle.Name = "button_toggle"
                        button_toggle.Parent = section
                        button_toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        button_toggle.BackgroundTransparency = 1.000
                        button_toggle.Position = UDim2.new(0, 0, 0.109170303, 0)
                        button_toggle.Size = UDim2.new(0, 236, 0, 22)
                        button_toggle.Font = Enum.Font.Gotham
                        button_toggle.LineHeight = 1.250
                        button_toggle.Text = "        " .. Configuration_Toggle.Text
                        button_toggle.TextColor3 = Color3.fromRGB(220, 220, 220)
                        button_toggle.TextSize = 14.000
                        button_toggle.TextStrokeColor3 = Color3.fromRGB(14, 14, 14)
                        button_toggle.TextStrokeTransparency = 0.300
                        button_toggle.TextXAlignment = Enum.TextXAlignment.Left

                        layout_button_toggle.Name = "layout_button_toggle"
                        layout_button_toggle.Parent = button_toggle
                        layout_button_toggle.SortOrder = Enum.SortOrder.LayoutOrder
                        layout_button_toggle.VerticalAlignment = Enum.VerticalAlignment.Center

                        design_button_toggle.Name = "design_button_toggle"
                        design_button_toggle.Parent = button_toggle
                        design_button_toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        design_button_toggle.BorderColor3 = Color3.fromRGB(70, 60, 95)
                        design_button_toggle.Position = UDim2.new(0, 0, 0.192307696, 0)
                        design_button_toggle.Size = UDim2.new(0, 14, 0, 14)

                        layout_design_button_toggle.Name = "layout_design_button_toggle"
                        layout_design_button_toggle.Parent = design_button_toggle
                        layout_design_button_toggle.HorizontalAlignment = Enum.HorizontalAlignment.Center
                        layout_design_button_toggle.SortOrder = Enum.SortOrder.LayoutOrder
                        layout_design_button_toggle.VerticalAlignment = Enum.VerticalAlignment.Center

                        gradient_design_button_toggle.Color =
                            ColorSequence.new {
                            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(35, 35, 39)),
                            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(31, 31, 35))
                        }
                        gradient_design_button_toggle.Rotation = 90
                        gradient_design_button_toggle.Name = "gradient_design_button_toggle"
                        gradient_design_button_toggle.Parent = design_button_toggle

                        design_button_toggle_2.Name = "design_button_toggle_2"
                        design_button_toggle_2.Parent = design_button_toggle
                        design_button_toggle_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        design_button_toggle_2.BorderColor3 = Color3.fromRGB(70, 60, 95)
                        design_button_toggle_2.BorderSizePixel = 0
                        design_button_toggle_2.Position = UDim2.new(0, 0, 0.192307696, 0)
                        design_button_toggle_2.Size = UDim2.new(0, 12, 0, 12)

                        layout_design_button_toggle_2.Name = "layout_design_button_toggle_2"
                        layout_design_button_toggle_2.Parent = design_button_toggle_2
                        layout_design_button_toggle_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
                        layout_design_button_toggle_2.SortOrder = Enum.SortOrder.LayoutOrder
                        layout_design_button_toggle_2.VerticalAlignment = Enum.VerticalAlignment.Center

                        gradient_design_button_toggle_2.Color =
                            ColorSequence.new {
                            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(24, 24, 26)),
                            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(28, 28, 31))
                        }
                        gradient_design_button_toggle_2.Rotation = 90
                        gradient_design_button_toggle_2.Name = "gradient_design_button_toggle_2"
                        gradient_design_button_toggle_2.Parent = design_button_toggle_2

                        padding_button_toggle.Name = "padding_button_toggle"
                        padding_button_toggle.Parent = button_toggle
                        padding_button_toggle.PaddingLeft = UDim.new(0, 8)

                        updateSection()
                        updateSize()

                        local ToggleEnabled = false
                        button_toggle.MouseButton1Click:Connect(
                            function()
                                ToggleEnabled = not ToggleEnabled
                                local ToggleGradient =
                                    ToggleEnabled and
                                    ColorSequence.new {
                                        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(135, 105, 215)),
                                        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(88, 64, 150))
                                    } or
                                    ColorSequence.new {
                                        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(24, 24, 26)),
                                        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(28, 28, 31))
                                    }
                                gradient_design_button_toggle_2.Color = ToggleGradient

                                while ToggleEnabled and wait(Configuration_Toggle.Latency) do
                                    Configuration_Toggle.Script()
                                end
                            end
                        )

                        button_toggle.MouseEnter:Connect(
                            function()
                                gradient_design_button_toggle.Color =
                                    ColorSequence.new {
                                    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(145, 110, 220)),
                                    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(92, 68, 158))
                                }
                            end
                        )
                        button_toggle.MouseLeave:Connect(
                            function()
                                gradient_design_button_toggle.Color =
                                    ColorSequence.new {
                                    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(35, 35, 39)),
                                    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(31, 31, 35))
                                }
                            end
                        )

                        local ToggleTools = {}
                        function SetLocalToggleText(new)
                            button_toggle.Text = new
                        end
                        function ToggleTools.SetText(new)
                            button_toggle.Text = new
                        end
                        return ToggleTools
                    end
                    function SectionTools:CreateDropdown(Configuration_Dropdown)
                        Configuration_Dropdown = Configuration_Dropdown or {}
                        Configuration_Dropdown = {
                            Text = Configuration_Dropdown.Text or "dropdown",
                            Default = Configuration_Dropdown.Default or ". . .",
                            Options = Configuration_Dropdown.Options or {},
                            Script = Configuration_Dropdown.Script or function() end
                        }

                        local selectedValue = tostring(Configuration_Dropdown.Default)
                        local dropdownIsOpen = false
                        local optionButtons = {}

                        local holder_dropdown = Instance.new("Frame")
                        local label_dropdown = Instance.new("TextLabel")
                        local design_dropdown = Instance.new("Frame")
                        local dropdown_corner = Instance.new("UICorner")
                        local dropdown_stroke = Instance.new("UIStroke")
                        local button_dropdown = Instance.new("TextButton")
                        local button_dropdown_text = Instance.new("TextLabel")
                        local button_dropdown_arrow = Instance.new("TextLabel")
                        local dropdown_container = Instance.new("Frame")
                        local dropdown_container_corner = Instance.new("UICorner")
                        local layout_dropdown_container = Instance.new("UIListLayout")
                        local padding_dropdown_container = Instance.new("UIPadding")

                        holder_dropdown.Name = "holder_dropdown"
                        holder_dropdown.Parent = section
                        holder_dropdown.BackgroundTransparency = 1
                        holder_dropdown.Size = UDim2.new(0, 221, 0, 48)
                        holder_dropdown.ClipsDescendants = false
                        holder_dropdown.ZIndex = 100

                        label_dropdown.Name = "label_dropdown"
                        label_dropdown.Parent = holder_dropdown
                        label_dropdown.BackgroundTransparency = 1
                        label_dropdown.Position = UDim2.new(0, 0, 0, 0)
                        label_dropdown.Size = UDim2.new(1, 0, 0, 16)
                        label_dropdown.Font = Enum.Font.GothamMedium
                        label_dropdown.Text = Configuration_Dropdown.Text
                        label_dropdown.TextColor3 = Color3.fromRGB(225, 225, 230)
                        label_dropdown.TextSize = 12
                        label_dropdown.TextStrokeTransparency = 1
                        label_dropdown.TextXAlignment = Enum.TextXAlignment.Left
                        label_dropdown.ZIndex = 101

                        design_dropdown.Name = "design_dropdown"
                        design_dropdown.Parent = holder_dropdown
                        design_dropdown.BackgroundColor3 = Color3.fromRGB(25, 25, 29)
                        design_dropdown.BorderSizePixel = 0
                        design_dropdown.ClipsDescendants = true
                        design_dropdown.Position = UDim2.new(0, 0, 0, 19)
                        design_dropdown.Size = UDim2.new(0, 221, 0, 27)
                        design_dropdown.ZIndex = 102

                        dropdown_corner.CornerRadius = UDim.new(0, 6)
                        dropdown_corner.Parent = design_dropdown

                        dropdown_stroke.Parent = design_dropdown
                        dropdown_stroke.Color = Color3.fromRGB(62, 62, 70)
                        dropdown_stroke.Thickness = 1
                        dropdown_stroke.Transparency = 0.15

                        button_dropdown.Name = "button_dropdown"
                        button_dropdown.Parent = design_dropdown
                        button_dropdown.BackgroundTransparency = 1
                        button_dropdown.Size = UDim2.new(1, 0, 0, 27)
                        button_dropdown.AutoButtonColor = false
                        button_dropdown.Text = ""
                        button_dropdown.ZIndex = 110

                        button_dropdown_text.Name = "button_dropdown_text"
                        button_dropdown_text.Parent = button_dropdown
                        button_dropdown_text.BackgroundTransparency = 1
                        button_dropdown_text.Position = UDim2.new(0, 10, 0, 0)
                        button_dropdown_text.Size = UDim2.new(1, -34, 1, 0)
                        button_dropdown_text.Font = Enum.Font.Gotham
                        button_dropdown_text.Text = selectedValue
                        button_dropdown_text.TextColor3 = Color3.fromRGB(232, 232, 238)
                        button_dropdown_text.TextSize = 12
                        button_dropdown_text.TextXAlignment = Enum.TextXAlignment.Left
                        button_dropdown_text.TextTruncate = Enum.TextTruncate.AtEnd
                        button_dropdown_text.ZIndex = 111

                        button_dropdown_arrow.Name = "button_dropdown_arrow"
                        button_dropdown_arrow.Parent = button_dropdown
                        button_dropdown_arrow.BackgroundTransparency = 1
                        button_dropdown_arrow.Position = UDim2.new(1, -25, 0, 0)
                        button_dropdown_arrow.Size = UDim2.new(0, 20, 1, 0)
                        button_dropdown_arrow.Font = Enum.Font.GothamBold
                        button_dropdown_arrow.Text = "⌄"
                        button_dropdown_arrow.TextColor3 = Color3.fromRGB(165, 165, 175)
                        button_dropdown_arrow.TextSize = 14
                        button_dropdown_arrow.ZIndex = 111

                        dropdown_container.Name = "dropdown_container"
                        dropdown_container.Parent = design_dropdown
                        dropdown_container.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
                        dropdown_container.BorderSizePixel = 0
                        dropdown_container.Position = UDim2.new(0, 5, 0, 32)
                        dropdown_container.Size = UDim2.new(1, -10, 0, 0)
                        dropdown_container.ClipsDescendants = true
                        dropdown_container.ZIndex = 120

                        dropdown_container_corner.CornerRadius = UDim.new(0, 5)
                        dropdown_container_corner.Parent = dropdown_container

                        padding_dropdown_container.Parent = dropdown_container
                        padding_dropdown_container.PaddingTop = UDim.new(0, 4)
                        padding_dropdown_container.PaddingBottom = UDim.new(0, 4)
                        padding_dropdown_container.PaddingLeft = UDim.new(0, 4)
                        padding_dropdown_container.PaddingRight = UDim.new(0, 4)

                        layout_dropdown_container.Name = "layout_dropdown_container"
                        layout_dropdown_container.Parent = dropdown_container
                        layout_dropdown_container.SortOrder = Enum.SortOrder.LayoutOrder
                        layout_dropdown_container.Padding = UDim.new(0, 4)

                        local function getOptionsHeight()
                            local count = 0
                            for _ in pairs(optionButtons) do
                                count += 1
                            end

                            if count <= 0 then
                                return 0
                            end

                            return math.min(layout_dropdown_container.AbsoluteContentSize.Y + 10, 180)
                        end

                        local function refreshHolderSize()
                            local optionHeight = dropdownIsOpen and getOptionsHeight() or 0
                            local totalHeight = dropdownIsOpen and (58 + optionHeight) or 48

                            holder_dropdown.Size = UDim2.new(0, 221, 0, totalHeight)
                            dropdown_container.Size = UDim2.new(1, -10, 0, optionHeight)

                            TweenService:Create(
                                design_dropdown,
                                TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                {Size = UDim2.new(0, 221, 0, dropdownIsOpen and (36 + optionHeight) or 27)}
                            ):Play()

                            button_dropdown_arrow.Text = dropdownIsOpen and "⌃" or "⌄"

                            pcall(updateSection)
                            pcall(updateSize)
                        end

                        local function clearSelectedColors()
                            for _, data in pairs(optionButtons) do
                                if data.Label then
                                    data.Label.TextColor3 = Color3.fromRGB(210, 210, 218)
                                end
                                if data.Bar then
                                    data.Bar.BackgroundTransparency = 1
                                end
                                if data.Button then
                                    data.Button.BackgroundColor3 = Color3.fromRGB(26, 26, 31)
                                end
                            end
                        end

                        local function choose(option, fireCallback)
                            selectedValue = tostring(option)
                            button_dropdown_text.Text = selectedValue
                            clearSelectedColors()

                            local data = optionButtons[selectedValue]
                            if data then
                                data.Label.TextColor3 = Color3.fromRGB(190, 160, 255)
                                data.Bar.BackgroundTransparency = 0
                                data.Button.BackgroundColor3 = Color3.fromRGB(31, 29, 39)
                            end

                            dropdownIsOpen = false
                            refreshHolderSize()

                            if fireCallback then
                                pcall(Configuration_Dropdown.Script, selectedValue)
                            end
                        end

                        local function addOption(option)
                            option = tostring(option)
                            if optionButtons[option] then return end

                            local option_button = Instance.new("TextButton")
                            local option_corner = Instance.new("UICorner")
                            local selected_bar = Instance.new("Frame")
                            local option_text = Instance.new("TextLabel")

                            option_button.Name = "button_dropdown_option"
                            option_button.Parent = dropdown_container
                            option_button.BackgroundColor3 = Color3.fromRGB(26, 26, 31)
                            option_button.BorderSizePixel = 0
                            option_button.Size = UDim2.new(1, 0, 0, 25)
                            option_button.AutoButtonColor = false
                            option_button.Text = ""
                            option_button.ZIndex = 125

                            option_corner.CornerRadius = UDim.new(0, 4)
                            option_corner.Parent = option_button

                            selected_bar.Name = "selected_bar"
                            selected_bar.Parent = option_button
                            selected_bar.BackgroundColor3 = Color3.fromRGB(125, 88, 220)
                            selected_bar.BorderSizePixel = 0
                            selected_bar.Position = UDim2.new(0, 0, 0, 5)
                            selected_bar.Size = UDim2.new(0, 2, 1, -10)
                            selected_bar.BackgroundTransparency = 1
                            selected_bar.ZIndex = 126

                            option_text.Name = "button_dropdown_text"
                            option_text.Parent = option_button
                            option_text.BackgroundTransparency = 1
                            option_text.Position = UDim2.new(0, 9, 0, 0)
                            option_text.Size = UDim2.new(1, -14, 1, 0)
                            option_text.Font = Enum.Font.Gotham
                            option_text.Text = option
                            option_text.TextColor3 = Color3.fromRGB(210, 210, 218)
                            option_text.TextSize = 12
                            option_text.TextXAlignment = Enum.TextXAlignment.Left
                            option_text.TextTruncate = Enum.TextTruncate.AtEnd
                            option_text.ZIndex = 126

                            option_button.MouseEnter:Connect(function()
                                if selectedValue ~= option then
                                    option_button.BackgroundColor3 = Color3.fromRGB(34, 34, 40)
                                end
                            end)

                            option_button.MouseLeave:Connect(function()
                                if selectedValue ~= option then
                                    option_button.BackgroundColor3 = Color3.fromRGB(26, 26, 31)
                                end
                            end)

                            option_button.MouseButton1Click:Connect(function()
                                choose(option, true)
                            end)

                            optionButtons[option] = {
                                Button = option_button,
                                Label = option_text,
                                Bar = selected_bar
                            }

                            if selectedValue == option then
                                choose(option, false)
                            else
                                refreshHolderSize()
                            end
                        end

                        local function removeOption(option)
                            option = tostring(option)
                            local data = optionButtons[option]
                            if data and data.Button then
                                data.Button:Destroy()
                            end
                            optionButtons[option] = nil
                            refreshHolderSize()
                        end

                        local function clearOptions()
                            for option, data in pairs(optionButtons) do
                                if data and data.Button then
                                    data.Button:Destroy()
                                end
                                optionButtons[option] = nil
                            end
                            refreshHolderSize()
                        end

                        local function setOptions(newOptions)
                            clearOptions()
                            for _, option in ipairs(newOptions or {}) do
                                addOption(option)
                            end

                            if not optionButtons[selectedValue] then
                                local first = (newOptions or {})[1]
                                if first ~= nil then
                                    choose(first, false)
                                else
                                    selectedValue = ". . ."
                                    button_dropdown_text.Text = selectedValue
                                end
                            else
                                choose(selectedValue, false)
                            end

                            refreshHolderSize()
                        end

                        button_dropdown.MouseButton1Click:Connect(function()
                            dropdownIsOpen = not dropdownIsOpen
                            refreshHolderSize()
                        end)

                        button_dropdown.MouseEnter:Connect(function()
                            dropdown_stroke.Color = Color3.fromRGB(125, 88, 220)
                        end)

                        button_dropdown.MouseLeave:Connect(function()
                            dropdown_stroke.Color = Color3.fromRGB(62, 62, 70)
                        end)

                        setOptions(Configuration_Dropdown.Options)

                        if optionButtons[selectedValue] then
                            choose(selectedValue, false)
                        else
                            button_dropdown_text.Text = selectedValue
                        end

                        refreshHolderSize()

                        local DropdownTools = {}

                        function DropdownTools.SetText(new)
                            label_dropdown.Text = tostring(new)
                        end

                        function DropdownTools.SetValue(new)
                            if not optionButtons[tostring(new)] then
                                addOption(new)
                            end
                            choose(new, false)
                        end

                        function DropdownTools.GetValue()
                            return selectedValue
                        end

                        function DropdownTools.AddOption(option)
                            addOption(option)
                        end

                        function DropdownTools.RemoveOption(option)
                            removeOption(option)
                        end

                        function DropdownTools.ClearOptions()
                            clearOptions()
                        end

                        -- Compatibility aliases for scripts that call :Refresh(), :Update(), or :update()
                        function DropdownTools.Refresh(newOptions)
                            setOptions(newOptions or {})
                        end

                        function DropdownTools.Update(newOptions)
                            setOptions(newOptions or {})
                        end

                        function DropdownTools.update(newOptions)
                            setOptions(newOptions or {})
                        end

                        AddLocalDropdownOption = addOption
                        RemoveLocalDropdownOption = removeOption
                        SetLocalDropdownText = function(new)
                            label_dropdown.Text = tostring(new)
                        end

                        return DropdownTools
                    end

function SectionTools:CreateSlider(Configuration_Slider)
                        Configuration_Slider = Configuration_Slider or {}
                        Configuration_Slider.Values = Configuration_Slider.Values or {}
                        Configuration_Slider = {
                            Text = Configuration_Slider.Text or "slider",
                            Suffix = Configuration_Slider.Suffix or "",
                            Values = {
                                Minimum = Configuration_Slider.Values.Minimum or 0,
                                Maximum = Configuration_Slider.Values.Maximum or 100,
                                Default = Configuration_Slider.Values.Default or 0
                            },
                            Script = Configuration_Slider.Script or function()
                                end
                        }

                        local holder_slider = Instance.new("Frame")
                        local layout_holder_slider = Instance.new("UIListLayout")
                        local label_holder_slider = Instance.new("TextLabel")
                        local design_slider = Instance.new("Frame")
                        local layout_design_slider = Instance.new("UIListLayout")
                        local gradient_design_slider = Instance.new("UIGradient")
                        local button_slider = Instance.new("TextButton")
                        local gradient_button_slider = Instance.new("UIGradient")
                        local design_2_slider = Instance.new("Frame")
                        local gradient_design_2_slider = Instance.new("UIGradient")
                        local padding_design_2_slider = Instance.new("UIPadding")
                        local layout_button_slider = Instance.new("UIListLayout")
                        local padding_button_slider = Instance.new("UIPadding")
                        local antiLayoutSliderFolder = Instance.new("Folder")
                        local button_slider_value = Instance.new("TextLabel")
                        local antiLayoutSliderFolder_2 = Instance.new("Folder")
                        local invisible_slider_cut = Instance.new("Frame")
                        local gradient_invisible_slider_cut = Instance.new("UIGradient")
                        local layout_antiLayoutSliderFolder = Instance.new("UIListLayout")
                        local padding_antiLayoutSliderFolder = Instance.new("UIPadding")

                        holder_slider.Name = "holder_slider"
                        holder_slider.Parent = section
                        holder_slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        holder_slider.BackgroundTransparency = 1.000
                        holder_slider.Position = UDim2.new(0.0317796618, 0, 0.208333328, 0)
                        holder_slider.Size = UDim2.new(0, 221, 0, 32)

                        layout_holder_slider.Name = "layout_holder_slider"
                        layout_holder_slider.Parent = holder_slider
                        layout_holder_slider.SortOrder = Enum.SortOrder.LayoutOrder
                        layout_holder_slider.Padding = UDim.new(0, 2)

                        label_holder_slider.Name = "label_holder_slider"
                        label_holder_slider.Parent = holder_slider
                        label_holder_slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        label_holder_slider.BackgroundTransparency = 1.000
                        label_holder_slider.Position = UDim2.new(0, 0, 0.615384638, 0)
                        label_holder_slider.Size = UDim2.new(0, 223, 0, 14)
                        label_holder_slider.Font = Enum.Font.Gotham
                        label_holder_slider.Text = Configuration_Slider.Text
                        label_holder_slider.TextColor3 = Color3.fromRGB(225, 225, 225)
                        label_holder_slider.TextSize = 13.000
                        label_holder_slider.TextStrokeColor3 = Color3.fromRGB(15, 15, 15)
                        label_holder_slider.TextStrokeTransparency = 0.300
                        label_holder_slider.TextXAlignment = Enum.TextXAlignment.Left

                        design_slider.Name = "design_slider"
                        design_slider.Parent = holder_slider
                        design_slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        design_slider.BorderColor3 = Color3.fromRGB(70, 60, 95)
                        design_slider.ClipsDescendants = true
                        design_slider.Position = UDim2.new(0, 0, 0.533333361, 0)
                        design_slider.Size = UDim2.new(0, 221, 0, 14)

                        layout_design_slider.Name = "layout_design_slider"
                        layout_design_slider.Parent = design_slider
                        layout_design_slider.HorizontalAlignment = Enum.HorizontalAlignment.Center
                        layout_design_slider.SortOrder = Enum.SortOrder.LayoutOrder
                        layout_design_slider.VerticalAlignment = Enum.VerticalAlignment.Center
                        layout_design_slider.Padding = UDim.new(0, 1)

                        gradient_design_slider.Color =
                            ColorSequence.new {
                            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(20, 20, 21)),
                            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(29, 29, 32))
                        }
                        gradient_design_slider.Rotation = 90
                        gradient_design_slider.Name = "gradient_design_slider"
                        gradient_design_slider.Parent = design_slider

                        button_slider.Name = "button_slider"
                        button_slider.Parent = design_slider
                        button_slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        button_slider.BorderColor3 = Color3.fromRGB(70, 60, 95)
                        button_slider.Size = UDim2.new(0, 217, 0, 10)
                        button_slider.AutoButtonColor = false
                        button_slider.Font = Enum.Font.Gotham
                        button_slider.Text = ""
                        button_slider.TextColor3 = Color3.fromRGB(0, 0, 0)
                        button_slider.TextSize = 14.000
                        button_slider.ClipsDescendants = true

                        gradient_button_slider.Color =
                            ColorSequence.new {
                            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(24, 24, 26)),
                            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(28, 28, 31))
                        }
                        gradient_button_slider.Rotation = 90
                        gradient_button_slider.Name = "gradient_button_slider"
                        gradient_button_slider.Parent = button_slider

                        design_2_slider.Name = "design_2_slider"
                        design_2_slider.Parent = button_slider
                        design_2_slider.AnchorPoint = Vector2.new(0.5, 0.5)
                        design_2_slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        design_2_slider.BorderSizePixel = 0
                        design_2_slider.Position = UDim2.new(0.0311059915, 0, 0.5, 0)
                        design_2_slider.Size = UDim2.new(0, 0, 0, 8)

                        gradient_design_2_slider.Color =
                            ColorSequence.new {
                            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(135, 105, 215)),
                            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(88, 64, 150))
                        }
                        gradient_design_2_slider.Rotation = 90
                        gradient_design_2_slider.Name = "gradient_design_2_slider"
                        gradient_design_2_slider.Parent = design_2_slider

                        padding_design_2_slider.Name = "padding_design_2_slider"
                        padding_design_2_slider.Parent = design_2_slider
                        padding_design_2_slider.PaddingRight = UDim.new(0, 1)

                        layout_button_slider.Name = "layout_button_slider"
                        layout_button_slider.Parent = button_slider
                        layout_button_slider.SortOrder = Enum.SortOrder.LayoutOrder
                        layout_button_slider.VerticalAlignment = Enum.VerticalAlignment.Center

                        padding_button_slider.Name = "padding_button_slider"
                        padding_button_slider.Parent = button_slider
                        padding_button_slider.PaddingLeft = UDim.new(0, 1)

                        antiLayoutSliderFolder.Parent = button_slider

                        button_slider_value.Name = "button_slider_value"
                        button_slider_value.Parent = antiLayoutSliderFolder
                        button_slider_value.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        button_slider_value.BackgroundTransparency = 1.000
                        button_slider_value.Size = UDim2.new(0, 217, 0, 10)
                        button_slider_value.Font = Enum.Font.Gotham
                        button_slider_value.LineHeight = 1.400
                        button_slider_value.Text = "0%"
                        button_slider_value.TextColor3 = Color3.fromRGB(225, 225, 225)
                        button_slider_value.TextSize = 12.000

                        antiLayoutSliderFolder_2.Name = "antiLayoutSliderFolder_2"
                        antiLayoutSliderFolder_2.Parent = button_slider

                        invisible_slider_cut.Name = "invisible_slider_cut"
                        invisible_slider_cut.Parent = antiLayoutSliderFolder_2
                        invisible_slider_cut.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        invisible_slider_cut.BorderSizePixel = 0
                        invisible_slider_cut.Position = UDim2.new(1, 0, 0.100000001, 0)
                        invisible_slider_cut.Size = UDim2.new(0, 1, 0, 10)
                        invisible_slider_cut.ZIndex = 4

                        gradient_invisible_slider_cut.Color =
                            ColorSequence.new {
                            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(24, 24, 26)),
                            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(28, 28, 31))
                        }
                        gradient_invisible_slider_cut.Rotation = 90
                        gradient_invisible_slider_cut.Name = "gradient_invisible_slider_cut"
                        gradient_invisible_slider_cut.Parent = invisible_slider_cut

                        layout_antiLayoutSliderFolder.Name = "layout_antiLayoutSliderFolder"
                        layout_antiLayoutSliderFolder.Parent = antiLayoutSliderFolder_2
                        layout_antiLayoutSliderFolder.HorizontalAlignment = Enum.HorizontalAlignment.Right
                        layout_antiLayoutSliderFolder.SortOrder = Enum.SortOrder.LayoutOrder
                        layout_antiLayoutSliderFolder.VerticalAlignment = Enum.VerticalAlignment.Center

                        padding_antiLayoutSliderFolder.Name = "padding_antiLayoutSliderFolder"
                        padding_antiLayoutSliderFolder.Parent = antiLayoutSliderFolder_2
                        padding_antiLayoutSliderFolder.PaddingRight = UDim.new(0, 2)

                        design_slider.MouseEnter:Connect(
                            function()
                                gradient_design_slider.Color =
                                    ColorSequence.new {
                                    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(145, 110, 220)),
                                    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(92, 68, 158))
                                }
                            end
                        )
                        design_slider.MouseLeave:Connect(
                            function()
                                gradient_design_slider.Color =
                                    ColorSequence.new {
                                    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(20, 20, 21)),
                                    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(29, 29, 32))
                                }
                            end
                        )

                        local partial_1 = Configuration_Slider.Values.Maximum - Configuration_Slider.Values.Minimum
                        local partial_2 = Configuration_Slider.Values.Default - Configuration_Slider.Values.Minimum
                        local partial_3 = partial_2 / partial_1
                        local partial_4 = partial_3 * button_slider.AbsoluteSize.X
                        design_2_slider.Size = UDim2.new(0, partial_4, 0, 8)
                        button_slider_value.Text = Configuration_Slider.Values.Default .. Configuration_Slider.Suffix

                        CreateTween(
                            "slider_drag",
                            {
                                Speed = 0.013,
                                Style = Enum.EasingStyle.Sine,
                                Direction = Enum.EasingDirection.InOut,
                                LoopAmount = 0,
                                Reverse = false,
                                Delay = 0
                            }
                        )

                        local ValueNum = Configuration_Slider.Values.Default
                        local function updateSlider()
                            TweenService:Create(
                                design_2_slider,
                                TweenTable["slider_drag"],
                                {
                                    Size = UDim2.new(
                                        0,
                                        math.clamp(
                                            Mouse.X - design_2_slider.AbsolutePosition.X,
                                            0,
                                            button_slider.AbsoluteSize.X
                                        ),
                                        0,
                                        8
                                    )
                                }
                            ):Play()
                            ValueNum =
                                math.floor(
                                (((tonumber(Configuration_Slider.Values.Maximum) -
                                    tonumber(Configuration_Slider.Values.Minimum)) /
                                    button_slider.AbsoluteSize.X) *
                                    design_2_slider.AbsoluteSize.X) +
                                    tonumber(Configuration_Slider.Values.Minimum)
                            ) or 0.00
                            button_slider_value.Text = ValueNum .. Configuration_Slider.Suffix
                            pcall(
                                function()
                                    Configuration_Slider.Script(ValueNum)
                                end
                            )

                            button_slider_value.Text = ValueNum .. Configuration_Slider.Suffix
                            moveconnection =
                                Mouse.Move:Connect(
                                function()
                                    ValueNum =
                                        math.floor(
                                        (((tonumber(Configuration_Slider.Values.Maximum) -
                                            tonumber(Configuration_Slider.Values.Minimum)) /
                                            button_slider.AbsoluteSize.X) *
                                            design_2_slider.AbsoluteSize.X) +
                                            tonumber(Configuration_Slider.Values.Minimum)
                                    )
                                    button_slider_value.Text = ValueNum .. Configuration_Slider.Suffix
                                    pcall(
                                        function()
                                            Configuration_Slider.Script(ValueNum)
                                        end
                                    )
                                    TweenService:Create(
                                        design_2_slider,
                                        TweenTable["slider_drag"],
                                        {
                                            Size = UDim2.new(
                                                0,
                                                math.clamp(
                                                    Mouse.X - design_2_slider.AbsolutePosition.X,
                                                    0,
                                                    button_slider.AbsoluteSize.X
                                                ),
                                                0,
                                                8
                                            )
                                        }
                                    ):Play()
                                end
                            )

                            releaseconnection =
                                UserInputService.InputEnded:Connect(
                                function(Mouse_2)
                                    if Mouse_2.UserInputType == Enum.UserInputType.MouseButton1 then
                                        ValueNum =
                                            math.floor(
                                            (((tonumber(Configuration_Slider.Values.Maximum) -
                                                tonumber(Configuration_Slider.Values.Minimum)) /
                                                button_slider.AbsoluteSize.X) *
                                                design_2_slider.AbsoluteSize.X) +
                                                tonumber(Configuration_Slider.Values.Minimum)
                                        )
                                        button_slider_value.Text = ValueNum .. Configuration_Slider.Suffix
                                        pcall(
                                            function()
                                                Configuration_Slider.Script(ValueNum)
                                            end
                                        )
                                        TweenService:Create(
                                            design_2_slider,
                                            TweenTable["slider_drag"],
                                            {
                                                Size = UDim2.new(
                                                    0,
                                                    math.clamp(
                                                        Mouse.X - design_2_slider.AbsolutePosition.X,
                                                        0,
                                                        button_slider.AbsoluteSize.X
                                                    ),
                                                    0,
                                                    8
                                                )
                                            }
                                        ):Play()
                                        moveconnection:Disconnect()
                                        releaseconnection:Disconnect()
                                    end
                                end
                            )
                        end
                        button_slider.MouseButton1Down:Connect(
                            function()
                                updateSlider()
                            end
                        )

                        updateSection()
                        updateSize()
                        local SliderTools = {}
                        function SliderTools.SetValue(new)
                            local newValue = new - Configuration_Slider.Values.Minimum
                            local newValue_2 = newValue / partial_1
                            local newValue_3 = newValue_2 * button_slider.AbsoluteSize.X
                            design_2_slider.Size = UDim2.new(0, newValue_3, 0, 8)
                            button_slider_value.Text = new .. Configuration_Slider.Suffix
                            Configuration_Slider.Script()
                        end
                        function SetLocalSliderValue(new)
                            local newValue = new - Configuration_Slider.Values.Minimum
                            local newValue_2 = newValue / partial_1
                            local newValue_3 = newValue_2 * button_slider.AbsoluteSize.X
                            design_2_slider.Size = UDim2.new(0, newValue_3, 0, 8)
                            button_slider_value.Text = new .. Configuration_Slider.Suffix
                            Configuration_Slider.Script()
                        end
                        function SliderTools.ResetValue()
                            design_2_slider.Size = UDim2.new(0, 0, 0, 8)
                            button_slider_value.Text = 0 .. Configuration_Slider.Suffix
                            Configuration_Slider.Script()
                        end
                        function ResetLocalSliderValue()
                            design_2_slider.Size = UDim2.new(0, 0, 0, 8)
                            button_slider_value.Text = 0 .. Configuration_Slider.Suffix
                            Configuration_Slider.Script()
                        end
                        function SliderTools.SetText(new)
                            label_holder_slider.Text = new
                        end
                        function SetLocalSliderText(new)
                            label_holder_slider.Text = new
                        end
                        return SliderTools
                    end
                    function SectionTools:CreateTextBox(Configuration_TextBox)
                        Configuration_TextBox = Configuration_TextBox or {}
                        Configuration_TextBox = {
                            Text = Configuration_TextBox.Text or "textbox",
                            Default = Configuration_TextBox.Default or "",
                            Pattern = Configuration_TextBox.Pattern or nil,
                            Script = Configuration_TextBox.Script or function() end
                        }

                        local holder_textbox = Instance.new("Frame")
                        local label_textbox = Instance.new("TextLabel")
                        local design_textbox = Instance.new("Frame")
                        local textbox_corner = Instance.new("UICorner")
                        local textbox_stroke = Instance.new("UIStroke")
                        local box = Instance.new("TextBox")

                        holder_textbox.Name = "holder_textbox"
                        holder_textbox.Parent = section
                        holder_textbox.BackgroundTransparency = 1
                        holder_textbox.Size = UDim2.new(0, 221, 0, 48)

                        label_textbox.Name = "label_textbox"
                        label_textbox.Parent = holder_textbox
                        label_textbox.BackgroundTransparency = 1
                        label_textbox.Position = UDim2.new(0, 0, 0, 0)
                        label_textbox.Size = UDim2.new(1, 0, 0, 16)
                        label_textbox.Font = Enum.Font.GothamMedium
                        label_textbox.Text = Configuration_TextBox.Text
                        label_textbox.TextColor3 = Color3.fromRGB(225, 225, 230)
                        label_textbox.TextSize = 12
                        label_textbox.TextStrokeTransparency = 1
                        label_textbox.TextXAlignment = Enum.TextXAlignment.Left

                        design_textbox.Name = "design_textbox"
                        design_textbox.Parent = holder_textbox
                        design_textbox.BackgroundColor3 = Color3.fromRGB(25, 25, 29)
                        design_textbox.BorderSizePixel = 0
                        design_textbox.Position = UDim2.new(0, 0, 0, 19)
                        design_textbox.Size = UDim2.new(0, 221, 0, 27)

                        textbox_corner.CornerRadius = UDim.new(0, 6)
                        textbox_corner.Parent = design_textbox

                        textbox_stroke.Parent = design_textbox
                        textbox_stroke.Color = Color3.fromRGB(62, 62, 70)
                        textbox_stroke.Thickness = 1
                        textbox_stroke.Transparency = 0.15

                        box.Name = "textbox"
                        box.Parent = design_textbox
                        box.BackgroundTransparency = 1
                        box.Position = UDim2.new(0, 10, 0, 0)
                        box.Size = UDim2.new(1, -20, 1, 0)
                        box.ClearTextOnFocus = false
                        box.Font = Enum.Font.Gotham
                        box.PlaceholderText = tostring(Configuration_TextBox.Default)
                        box.Text = ""
                        box.TextColor3 = Color3.fromRGB(232, 232, 238)
                        box.PlaceholderColor3 = Color3.fromRGB(135, 135, 145)
                        box.TextSize = 12
                        box.TextXAlignment = Enum.TextXAlignment.Left
                        box.TextTruncate = Enum.TextTruncate.AtEnd

                        local function applyPattern(text)
                            text = tostring(text or "")
                            local pattern = tostring(Configuration_TextBox.Pattern or ""):lower()
                            if pattern == "lower" or pattern == "lowercase" then
                                return text:lower()
                            elseif pattern == "upper" or pattern == "uppercase" then
                                return text:upper()
                            elseif pattern == "number" or pattern == "numeric" then
                                return text:gsub("%D", "")
                            end
                            return text
                        end

                        local function submit()
                            local text = applyPattern(box.Text)
                            box.Text = text
                            pcall(Configuration_TextBox.Script, text)
                        end

                        box.Focused:Connect(function()
                            textbox_stroke.Color = Color3.fromRGB(125, 88, 220)
                        end)
                        box.FocusLost:Connect(function(enterPressed)
                            textbox_stroke.Color = Color3.fromRGB(62, 62, 70)
                            if enterPressed then
                                submit()
                            end
                        end)

                        updateSection()
                        updateSize()

                        local TextBoxTools = {}
                        function TextBoxTools.SetText(new)
                            label_textbox.Text = tostring(new)
                        end
                        function TextBoxTools.SetInput(new)
                            box.Text = applyPattern(new)
                        end
                        function TextBoxTools.GetInput()
                            return box.Text
                        end
                        function TextBoxTools.Submit()
                            submit()
                        end
                        function TextBoxTools.ClearInput()
                            box.Text = ""
                        end
                        SetLocalTextBoxText = function(new) label_textbox.Text = tostring(new) end
                        return TextBoxTools
                    end
                    SectionTools.CreateTextbox = SectionTools.CreateTextBox
                    function SectionTools:CreateKeybind(Configuration_Keybind)
                        Configuration_Keybind = Configuration_Keybind or {}
                        Configuration_Keybind = {
                            Text = Configuration_Keybind.Text or "keybind",
                            Key = Configuration_Keybind.Key or Enum.KeyCode.P,
                            Script = Configuration_Keybind.Script or function()
                                end
                        }

                        local design_keybind = Instance.new("Frame")
                        local layout_design_keybind = Instance.new("UIListLayout")
                        local label_keybind = Instance.new("TextLabel")
                        local anti_keybind_layout = Instance.new("Folder")
                        local design_keybind_2 = Instance.new("Frame")
                        local gradient_design_keybind_2 = Instance.new("UIGradient")
                        local layout_design_keybind_2 = Instance.new("UIListLayout")
                        local design_textbox_3 = Instance.new("Frame")
                        local gradient_design_textbox_3 = Instance.new("UIGradient")
                        local layout_design_textbox_3 = Instance.new("UIListLayout")
                        local button_keybind = Instance.new("TextButton")
                        local layout_anti_keybind_layout = Instance.new("UIListLayout")

                        design_keybind.Name = "design_keybind"
                        design_keybind.Parent = section
                        design_keybind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        design_keybind.BackgroundTransparency = 1.000
                        design_keybind.Position = UDim2.new(0.0169491526, 0, 0.390625, 0)
                        design_keybind.Size = UDim2.new(0, 224, 0, 16)

                        layout_design_keybind.Name = "layout_design_keybind"
                        layout_design_keybind.Parent = design_keybind
                        layout_design_keybind.SortOrder = Enum.SortOrder.LayoutOrder
                        layout_design_keybind.VerticalAlignment = Enum.VerticalAlignment.Center

                        label_keybind.Name = "label_keybind"
                        label_keybind.Parent = design_keybind
                        label_keybind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        label_keybind.BackgroundTransparency = 1.000
                        label_keybind.Size = UDim2.new(0, 232, 0, 16)
                        label_keybind.Font = Enum.Font.Gotham
                        label_keybind.Text = " " .. Configuration_Keybind.Text
                        label_keybind.TextColor3 = Color3.fromRGB(225, 225, 225)
                        label_keybind.TextSize = 13.000
                        label_keybind.TextXAlignment = Enum.TextXAlignment.Left

                        anti_keybind_layout.Name = "anti_keybind_layout"
                        anti_keybind_layout.Parent = design_keybind

                        design_keybind_2.Name = "design_keybind_2"
                        design_keybind_2.Parent = anti_keybind_layout
                        design_keybind_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        design_keybind_2.BorderColor3 = Color3.fromRGB(70, 60, 95)
                        design_keybind_2.Position = UDim2.new(0.912946403, 0, 0.0625, 0)
                        design_keybind_2.Size = UDim2.new(0, 26, 0, 14)

                        gradient_design_keybind_2.Color =
                            ColorSequence.new {
                            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(35, 35, 39)),
                            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(31, 31, 35))
                        }
                        gradient_design_keybind_2.Rotation = 90
                        gradient_design_keybind_2.Name = "gradient_design_keybind_2"
                        gradient_design_keybind_2.Parent = design_keybind_2

                        layout_design_keybind_2.Name = "layout_design_keybind_2"
                        layout_design_keybind_2.Parent = design_keybind_2
                        layout_design_keybind_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
                        layout_design_keybind_2.SortOrder = Enum.SortOrder.LayoutOrder
                        layout_design_keybind_2.VerticalAlignment = Enum.VerticalAlignment.Center

                        design_textbox_3.Name = "design_textbox_3"
                        design_textbox_3.Parent = design_keybind_2
                        design_textbox_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        design_textbox_3.BorderSizePixel = 0
                        design_textbox_3.Position = UDim2.new(2.04166675, 0, 0.0714285746, 0)
                        design_textbox_3.Size = UDim2.new(0, 24, 0, 12)

                        gradient_design_textbox_3.Color =
                            ColorSequence.new {
                            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(24, 24, 26)),
                            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(28, 28, 31))
                        }
                        gradient_design_textbox_3.Rotation = 90
                        gradient_design_textbox_3.Name = "gradient_design_textbox_3"
                        gradient_design_textbox_3.Parent = design_textbox_3

                        layout_design_textbox_3.Name = "layout_design_textbox_3"
                        layout_design_textbox_3.Parent = design_textbox_3
                        layout_design_textbox_3.HorizontalAlignment = Enum.HorizontalAlignment.Center
                        layout_design_textbox_3.SortOrder = Enum.SortOrder.LayoutOrder
                        layout_design_textbox_3.VerticalAlignment = Enum.VerticalAlignment.Center

                        button_keybind.Name = "button_keybind"
                        button_keybind.Parent = design_textbox_3
                        button_keybind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        button_keybind.BackgroundTransparency = 1.000
                        button_keybind.Size = UDim2.new(0, 24, 0, 12)
                        button_keybind.Font = Enum.Font.Gotham
                        button_keybind.LineHeight = 1.100
                        button_keybind.Text = ". . ."
                        button_keybind.TextColor3 = Color3.fromRGB(190, 190, 190)
                        button_keybind.TextSize = 12.000

                        layout_anti_keybind_layout.Name = "layout_anti_keybind_layout"
                        layout_anti_keybind_layout.Parent = anti_keybind_layout
                        layout_anti_keybind_layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                        layout_anti_keybind_layout.SortOrder = Enum.SortOrder.LayoutOrder
                        layout_anti_keybind_layout.VerticalAlignment = Enum.VerticalAlignment.Center

                        local shorts = {
                            RightAlt = "RA",
                            LeftAlt = "LA",
                            RightControl = "RC",
                            LeftControl = "LC",
                            LeftShift = "LS",
                            RightShift = "RS",
                            MouseButton1 = "M1",
                            MouseButton2 = "M2",
                            Return = "ENT",
                            Backspace = "BP",
                            Tab = "TAB",
                            CapsLock = "CL",
                            Escape = "ESC",
                            Insert = "INS"
                        }
                        button_keybind.Text = shorts[Configuration_Keybind.Key.Name] or Configuration_Keybind.Key.Name
                        
                        local chosenKeybind = Configuration_Keybind.Key
                        button_keybind.MouseButton1Click:Connect(
                            function()
                                button_keybind.Text = ". . ."
                                local inputWait = UserInputService.InputBegan:wait()
                                if inputWait.KeyCode.Name ~= "Unknown" then
                                    local K = shorts[inputWait.KeyCode.Name] or inputWait.KeyCode.Name
                                    button_keybind.Text = K
                                    chosenKeybind = inputWait.KeyCode.Name
                                end
                            end
                        )
                        UserInputService.InputBegan:Connect(
                            function(c, p)
                                if not p then
                                    if c.KeyCode.Name == chosenKeybind then
                                        Configuration_Keybind.Script(chosenKeybind)
                                    end
                                end
                            end
                        )

                        design_keybind.MouseEnter:Connect(
                            function()
                                gradient_design_keybind_2.Color =
                                    ColorSequence.new {
                                    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(145, 110, 220)),
                                    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(92, 68, 158))
                                }
                            end
                        )
                        design_keybind.MouseLeave:Connect(
                            function()
                                gradient_design_keybind_2.Color =
                                    ColorSequence.new {
                                    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(35, 35, 39)),
                                    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(31, 31, 35))
                                }
                            end
                        )

                        updateSection()
                        updateSize()

                        local KeybindTools = {}
                        function KeybindTools.SetText(new)
                            label_keybind.Text = " " .. new
                        end
                        function SetLocalKeybindText(new)
                            label_keybind.Text = " " .. new
                        end
                        return KeybindTools
                    end
                    function SectionTools:CreateCheck(Configuration_Check)
                        Configuration_Check = Configuration_Check or {}
                        Configuration_Check = {
                            Text = Configuration_Check.Text or "check",
                            Script = Configuration_Check.Script or function()
                                end
                        }

                        local button_toggle = Instance.new("TextButton")
                        local layout_button_toggle = Instance.new("UIListLayout")
                        local design_button_toggle = Instance.new("Frame")
                        local layout_design_button_toggle = Instance.new("UIListLayout")
                        local gradient_design_button_toggle = Instance.new("UIGradient")
                        local design_button_toggle_2 = Instance.new("Frame")
                        local layout_design_button_toggle_2 = Instance.new("UIListLayout")
                        local gradient_design_button_toggle_2 = Instance.new("UIGradient")
                        local padding_button_toggle = Instance.new("UIPadding")

                        button_toggle.Name = "button_toggle"
                        button_toggle.Parent = section
                        button_toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        button_toggle.BackgroundTransparency = 1.000
                        button_toggle.Position = UDim2.new(0, 0, 0.109170303, 0)
                        button_toggle.Size = UDim2.new(0, 236, 0, 22)
                        button_toggle.Font = Enum.Font.Gotham
                        button_toggle.LineHeight = 1.250
                        button_toggle.Text = "        " .. Configuration_Check.Text
                        button_toggle.TextColor3 = Color3.fromRGB(220, 220, 220)
                        button_toggle.TextSize = 14.000
                        button_toggle.TextStrokeColor3 = Color3.fromRGB(14, 14, 14)
                        button_toggle.TextStrokeTransparency = 0.300
                        button_toggle.TextXAlignment = Enum.TextXAlignment.Left

                        layout_button_toggle.Name = "layout_button_toggle"
                        layout_button_toggle.Parent = button_toggle
                        layout_button_toggle.SortOrder = Enum.SortOrder.LayoutOrder
                        layout_button_toggle.VerticalAlignment = Enum.VerticalAlignment.Center

                        design_button_toggle.Name = "design_button_toggle"
                        design_button_toggle.Parent = button_toggle
                        design_button_toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        design_button_toggle.BorderColor3 = Color3.fromRGB(70, 60, 95)
                        design_button_toggle.Position = UDim2.new(0, 0, 0.192307696, 0)
                        design_button_toggle.Size = UDim2.new(0, 14, 0, 14)

                        local corner_design_button_toggle = Instance.new("UICorner")

                        corner_design_button_toggle.CornerRadius = UDim.new(0, 100)
                        corner_design_button_toggle.Name = "corner_design_button_toggle"
                        corner_design_button_toggle.Parent = design_button_toggle

                        layout_design_button_toggle.Name = "layout_design_button_toggle"
                        layout_design_button_toggle.Parent = design_button_toggle
                        layout_design_button_toggle.HorizontalAlignment = Enum.HorizontalAlignment.Center
                        layout_design_button_toggle.SortOrder = Enum.SortOrder.LayoutOrder
                        layout_design_button_toggle.VerticalAlignment = Enum.VerticalAlignment.Center

                        gradient_design_button_toggle.Color =
                            ColorSequence.new {
                            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(35, 35, 39)),
                            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(31, 31, 35))
                        }
                        gradient_design_button_toggle.Rotation = 90
                        gradient_design_button_toggle.Name = "gradient_design_button_toggle"
                        gradient_design_button_toggle.Parent = design_button_toggle

                        design_button_toggle_2.Name = "design_button_toggle_2"
                        design_button_toggle_2.Parent = design_button_toggle
                        design_button_toggle_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        design_button_toggle_2.BorderColor3 = Color3.fromRGB(70, 60, 95)
                        design_button_toggle_2.BorderSizePixel = 0
                        design_button_toggle_2.Position = UDim2.new(0, 0, 0.192307696, 0)
                        design_button_toggle_2.Size = UDim2.new(0, 12, 0, 12)

                        local corner_design_button_toggle_2 = Instance.new("UICorner")

                        corner_design_button_toggle_2.CornerRadius = UDim.new(0, 100)
                        corner_design_button_toggle_2.Name = "corner_design_button_toggle_2"
                        corner_design_button_toggle_2.Parent = design_button_toggle_2

                        layout_design_button_toggle_2.Name = "layout_design_button_toggle_2"
                        layout_design_button_toggle_2.Parent = design_button_toggle_2
                        layout_design_button_toggle_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
                        layout_design_button_toggle_2.SortOrder = Enum.SortOrder.LayoutOrder
                        layout_design_button_toggle_2.VerticalAlignment = Enum.VerticalAlignment.Center

                        gradient_design_button_toggle_2.Color =
                            ColorSequence.new {
                            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(24, 24, 26)),
                            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(28, 28, 31))
                        }
                        gradient_design_button_toggle_2.Rotation = 90
                        gradient_design_button_toggle_2.Name = "gradient_design_button_toggle_2"
                        gradient_design_button_toggle_2.Parent = design_button_toggle_2

                        padding_button_toggle.Name = "padding_button_toggle"
                        padding_button_toggle.Parent = button_toggle
                        padding_button_toggle.PaddingLeft = UDim.new(0, 8)

                        updateSection()
                        updateSize()

                        local ToggleEnabled = false
                        button_toggle.MouseButton1Click:Connect(
                            function()
                                ToggleEnabled = not ToggleEnabled
                                local ToggleGradient =
                                    ToggleEnabled and
                                    ColorSequence.new {
                                        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(135, 105, 215)),
                                        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(88, 64, 150))
                                    } or
                                    ColorSequence.new {
                                        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(24, 24, 26)),
                                        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(28, 28, 31))
                                    }
                                gradient_design_button_toggle_2.Color = ToggleGradient

                                if ToggleEnabled then
                                    Configuration_Check.Script(true)
                                else
                                    Configuration_Check.Script(false)
                                end
                            end
                        )

                        button_toggle.MouseEnter:Connect(
                            function()
                                gradient_design_button_toggle.Color =
                                    ColorSequence.new {
                                    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(145, 110, 220)),
                                    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(92, 68, 158))
                                }
                            end
                        )
                        button_toggle.MouseLeave:Connect(
                            function()
                                gradient_design_button_toggle.Color =
                                    ColorSequence.new {
                                    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(35, 35, 39)),
                                    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(31, 31, 35))
                                }
                            end
                        )

                        local CheckTools = {}
                        function SetLocalCheckText(new)
                            button_toggle.Text = "        " .. new
                        end
                        function CheckTools.SetText(new)
                            button_toggle.Text = "        " .. new
                        end
                        function DestroyLocalCheck()
                            button_toggle:Destroy()
                            UpdateSection()
                            UpdateSize()
                        end
                        function CheckTools.Destroy()
                            button_toggle:Destroy()
                            UpdateSection()
                            UpdateSize()
                        end                        
                        return CheckTools
                    end
                    function SectionTools:CreateLabel(Configuration_Label)
                        Configuration_Label = Configuration_Label or {}
                        Configuration_Label = {
                            Text = Configuration_Label.Text or "label",
                            Alignment = Configuration_Label.Alignment or Enum.TextXAlignment.Left
                        }

                        local holder_label = Instance.new("Frame")
                        local layout_label = Instance.new("UIListLayout")
                        local label = Instance.new("TextLabel")

                        holder_label.Name = "holder_label"
                        holder_label.Parent = section
                        holder_label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        holder_label.BackgroundTransparency = 1.000
                        holder_label.Position = UDim2.new(0.0169491526, 0, 0.390625, 0)
                        holder_label.Size = UDim2.new(0, 224, 0, 16)

                        layout_label.Name = "layout_label"
                        layout_label.Parent = holder_label
                        layout_label.SortOrder = Enum.SortOrder.LayoutOrder
                        layout_label.VerticalAlignment = Enum.VerticalAlignment.Center

                        label.Name = "label"
                        label.Parent = holder_label
                        label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        label.BackgroundTransparency = 1.000
                        label.Size = UDim2.new(0, 232, 0, 16)
                        label.Font = Enum.Font.Gotham
                        label.Text = " " .. Configuration_Label.Text
                        label.TextColor3 = Color3.fromRGB(225, 225, 225)
                        label.TextSize = 13.000
                        label.TextXAlignment = Configuration_Label.Alignment
                        label.TextTruncate = "AtEnd"
                        updateSection()
                        updateSize()

                        local LabelTools = {}
                        function LabelTools.SetText(new)
                            label.Text = " " .. new
                        end
                        return LabelTools
                    end
                    function SectionTools:CreateDivider()
                        local holder_cut = Instance.new("Frame")
                        local layout_cut = Instance.new("UIListLayout")
                        local cut = Instance.new("Frame")

                        holder_cut.Name = "holder_cut"
                        holder_cut.Parent = section
                        holder_cut.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        holder_cut.BackgroundTransparency = 1.000
                        holder_cut.Position = UDim2.new(0.0254237279, 0, 0.733333349, 0)
                        holder_cut.Size = UDim2.new(0, 224, 0, 3)

                        layout_cut.Name = "layout_cut"
                        layout_cut.Parent = holder_cut
                        layout_cut.HorizontalAlignment = Enum.HorizontalAlignment.Center
                        layout_cut.SortOrder = Enum.SortOrder.LayoutOrder
                        layout_cut.VerticalAlignment = Enum.VerticalAlignment.Center

                        cut.Name = "cut"
                        cut.Parent = holder_cut
                        cut.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                        cut.BorderSizePixel = 0
                        cut.Size = UDim2.new(0, 218, 0, 1)
                        updateSection()
                        updateSize()
                    end
                    function SectionTools.SetHeader(new)
                        section_header.Text = new
                    end
                    return SectionTools
                end
                function PageTools.SetSubject(new)
                    button_tab.Text = new
                    local newTabButtonSize =
                        TextService:GetTextSize(
                        button_tab.Text,
                        button_tab.TextSize,
                        button_tab.Font,
                        Vector2.new(math.huge, math.huge)
                    )
                    button_tab.Size = UDim2.new(0, 12 + newTabButtonSize.X, 0, button_tab.Size.Y.Offset)
                    cut_button_tab.Size = UDim2.new(0, button_tab.Size.X.Offset - 4, 0, 1)
                end
                function PageTools.SetFooter(new)
                    footer_label.Text = new
                end
                return PageTools
            end
            function InterfaceTools.SetHeader(new)
                header_label.Text = new
            end
            function InterfaceTools.SetFooter(new)
                footer_label.Text = new
            end
            function InterfaceTools.SetDragLatency(new)
                designLatency = new
            end
            function InterfaceTools.SetVisibleKeybind(new)
                visKey = new
            end
            function InterfaceTools.Destroy()
                pcall(function()
                    TweenService:Create(designScale, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Scale = 0.92}):Play()
                    TweenService:Create(design, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
                    task.wait(0.2)
                    if private and private.Parent then
                        private:Destroy()
                    end
                    for i = #bungiesLibrary._activeGuis, 1, -1 do
                        if bungiesLibrary._activeGuis[i] == private then
                            table.remove(bungiesLibrary._activeGuis, i)
                        end
                    end
                    getgenv().ui = false
                end)
            end
            return InterfaceTools
        end
        return Interface
    end
    if string.find(selectedLower, "notif", 1, true) then
        local notifications = Instance.new("ScreenGui")
        local layout_notifications = Instance.new("UIListLayout")
        local padding_notifications = Instance.new("UIPadding")

        notifications.Name = "notifications"
        notifications.Parent = CoreGuiService
        table.insert(bungiesLibrary._activeGuis, notifications)
        notifications.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        layout_notifications.Name = "layout_notifications"
        layout_notifications.Parent = notifications
        layout_notifications.SortOrder = Enum.SortOrder.LayoutOrder
        layout_notifications.Padding = UDim.new(0, 4)

        padding_notifications.Name = "padding_notifications"
        padding_notifications.Parent = notifications
        padding_notifications.PaddingLeft = UDim.new(0, 25)
        padding_notifications.PaddingTop = UDim.new(0, 60)

        local NotificationLibrary = {}
        function NotificationLibrary:Send(Configuration)
            Configuration = {
                Header = Configuration.Header or "undefined header",
                Notification = Configuration.Notification or "undefined notification",
                Time = Configuration.Time or 3
            }

            local design = Instance.new("Frame")
            local layout_design = Instance.new("UIListLayout")
            local design_1 = Instance.new("Frame")
            local layout_design_1 = Instance.new("UIListLayout")
            local haeder_notification = Instance.new("TextLabel")
            local padding_header_notification = Instance.new("UIPadding")
            local design_2_cutoff = Instance.new("Frame")
            local gradient_design_2_cutoff = Instance.new("UIGradient")
            local note_notification = Instance.new("TextLabel")
            local padding_note_notification = Instance.new("UIPadding")

            design.Name = "design"
            design.Parent = notifications
            design.BackgroundColor3 = Color3.fromRGB(135, 105, 215)
            design.BorderColor3 = Color3.fromRGB(18, 18, 20)
            design.Position = UDim2.new(0.0193798449, 0, 0.0727272704, 0)
            design.Size = UDim2.new(0, 332, 0, 70)

            layout_design.Name = "layout_design"
            layout_design.Parent = design
            layout_design.HorizontalAlignment = Enum.HorizontalAlignment.Center
            layout_design.SortOrder = Enum.SortOrder.LayoutOrder
            layout_design.VerticalAlignment = Enum.VerticalAlignment.Center

            design_1.Name = "design_1"
            design_1.Parent = design
            design_1.AnchorPoint = Vector2.new(0.5, 0.5)
            design_1.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
            design_1.BorderColor3 = Color3.fromRGB(18, 18, 20)
            design_1.BorderSizePixel = 2
            design_1.Position = UDim2.new(0.5, 0, 0.432098776, 0)
            design_1.Size = UDim2.new(0, 326, 0, 64)

            layout_design_1.Name = "layout_design_1"
            layout_design_1.Parent = design_1
            layout_design_1.HorizontalAlignment = Enum.HorizontalAlignment.Center
            layout_design_1.SortOrder = Enum.SortOrder.LayoutOrder

            haeder_notification.Name = "haeder_notification"
            haeder_notification.Parent = design_1
            haeder_notification.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
            haeder_notification.BorderSizePixel = 0
            haeder_notification.Position = UDim2.new(0.193251535, 0, -0.0681818202, 0)
            haeder_notification.Size = UDim2.new(0, 326, 0, 24)
            haeder_notification.Font = Enum.Font.Gotham
            haeder_notification.Text = Configuration.Header
            haeder_notification.TextColor3 = Color3.fromRGB(232, 232, 232)
            haeder_notification.TextSize = 15.000
            haeder_notification.TextXAlignment = Enum.TextXAlignment.Left

            padding_header_notification.Name = "padding_header_notification"
            padding_header_notification.Parent = haeder_notification
            padding_header_notification.PaddingBottom = UDim.new(0, 4)
            padding_header_notification.PaddingLeft = UDim.new(0, 4)
            padding_header_notification.PaddingRight = UDim.new(0, 4)
            padding_header_notification.PaddingTop = UDim.new(0, 2)

            design_2_cutoff.Name = "design_2_cutoff"
            design_2_cutoff.Parent = design_1
            design_2_cutoff.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            design_2_cutoff.BorderSizePixel = 0
            design_2_cutoff.Position = UDim2.new(0, 0, 1, 0)
            design_2_cutoff.Size = UDim2.new(0, 326, 0, 1)

            gradient_design_2_cutoff.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(135, 105, 215)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(88, 64, 150))}
            gradient_design_2_cutoff.Rotation = 90
            gradient_design_2_cutoff.Name = "gradient_design_2_cutoff"
            gradient_design_2_cutoff.Parent = design_2_cutoff

            note_notification.Name = "note_notification"
            note_notification.Parent = design_1
            note_notification.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
            note_notification.BorderSizePixel = 0
            note_notification.Position = UDim2.new(0, 0, 0.333333343, 0)
            note_notification.Size = UDim2.new(0, 326, 0, 33)
            note_notification.Font = Enum.Font.Gotham
            note_notification.Text = Configuration.Notification
            note_notification.TextColor3 = Color3.fromRGB(232, 232, 232)
            note_notification.TextSize = 12.000
            note_notification.TextWrapped = false
            note_notification.TextXAlignment = Enum.TextXAlignment.Left
            note_notification.TextYAlignment = Enum.TextYAlignment.Top

            padding_note_notification.Name = "padding_note_notification"
            padding_note_notification.Parent = note_notification
            padding_note_notification.PaddingBottom = UDim.new(0, 0)
            padding_note_notification.PaddingLeft = UDim.new(0, 4)
            padding_note_notification.PaddingRight = UDim.new(0, 4)
            padding_note_notification.PaddingTop = UDim.new(0, 4)
        
            local newNotificationSize = TextService:GetTextSize(note_notification.Text, note_notification.TextSize, note_notification.Font, Vector2.new(math.huge, math.huge))
            local notifCorner = Instance.new("UICorner")
            notifCorner.CornerRadius = UDim.new(0, 7)
            notifCorner.Parent = design

            local notifStroke = Instance.new("UIStroke")
            notifStroke.Color = Color3.fromRGB(135, 105, 215)
            notifStroke.Transparency = 0.3
            notifStroke.Thickness = 1
            notifStroke.Parent = design

            design.Size = UDim2.new(0, 332, 0, newNotificationSize.Y + 40)
            design_1.Size = UDim2.new(0, 326, 0, newNotificationSize.Y + 34)
            note_notification.Size = UDim2.new(0, 326, 0, newNotificationSize.Y)
            
            function des()
                wait(Configuration.Time)
                design:Destroy()
            end
            coroutine.wrap(des)(design, Configuration.Time)
        end
        return NotificationLibrary
    end
end
bungiesLibrary.__version = "hashui_full_v11_dropdown_textbox_loaderfix"
return bungiesLibrary

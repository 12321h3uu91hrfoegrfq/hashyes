-- hashui.luau
-- Hash Hub adapter for Starlight UI.
-- Keeps the old Hash Hub API working:
-- lib:Window(), win:Tab(), tab:Button/Toggle/Slider/Textbox/Dropdown/Bind(), lib:Notification()

local HashUI = {}

local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function icon(name, source)
    local ok, result = pcall(function()
        return NebulaIcons:GetIcon(name, source or "Lucide")
    end)
    return ok and result or nil
end

local function safe(callback, ...)
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

local function safeMethod(object, names, ...)
    if not object then return nil end
    local args = table.pack(...)
    for _, name in ipairs(names) do
        local fn = object[name]
        if type(fn) == "function" then
            local ok, result = pcall(function()
                return fn(object, table.unpack(args, 1, args.n))
            end)
            if ok then return result end
        end
    end
    return nil
end

local function tabIcon(name)
    if name == "Visualizer" then return icon("sparkles", "Lucide") or icon("view_in_ar", "Material") end
    if name == "Audio" then return icon("music", "Lucide") end
    if name == "Misc" then return icon("wrench", "Lucide") end
    return icon("settings", "Lucide")
end

local function groupNameForTab(name, column)
    if name == "Visualizer" then
        return column == 1 and "Controls" or "Preset Configuration"
    end
    if name == "Audio" then
        return column == 1 and "Audio Controls" or "Playback"
    end
    if name == "Misc" then
        return column == 1 and "Utility" or "Server"
    end
    return column == 1 and "Library" or "Settings"
end

local function routeColumn(kind)
    if kind == "dropdown" or kind == "slider" then
        return 2
    end
    return 1
end

function HashUI:Intro()
    -- hash.luau already owns its loading screen.
end

function HashUI:Window(title, _accent, toggleKey)
    local adapter = {}
    adapter._tabs = {}
    adapter._counter = 0

    adapter._window = Starlight:CreateWindow({
        Name = tostring(title or "Hash Hub"),
        Subtitle = "2.6.3",
        Icon = 0,
        LoadingSettings = {
            Title = "Hash Hub",
            Subtitle = "welcome, " .. tostring(LocalPlayer and LocalPlayer.Name or "user"),
        },
        FileSettings = {
            ConfigFolder = "HashHub",
        },
    })

    adapter._section = adapter._window:CreateTabSection("Hash Hub")

    local function nextId(prefix)
        adapter._counter += 1
        return prefix .. tostring(adapter._counter)
    end

    function adapter:Tab(name)
        local tabAdapter = {
            Name = tostring(name),
            _counter = 0,
        }

        tabAdapter._tab = self._section:CreateTab({
            Name = tabAdapter.Name,
            Icon = tabIcon(tabAdapter.Name),
            Columns = 2,
        }, nextId("Tab"))

        tabAdapter._groups = {
            [1] = tabAdapter._tab:CreateGroupbox({
                Name = groupNameForTab(tabAdapter.Name, 1),
                Column = 1,
            }, nextId("Group")),
            [2] = tabAdapter._tab:CreateGroupbox({
                Name = groupNameForTab(tabAdapter.Name, 2),
                Column = 2,
            }, nextId("Group")),
        }

        local function id(prefix)
            tabAdapter._counter += 1
            return prefix .. tostring(tabAdapter._counter)
        end

        local function group(kind)
            return tabAdapter._groups[routeColumn(kind)] or tabAdapter._groups[1]
        end

        function tabAdapter:Section(label)
            local g = group("button")
            if g.CreateParagraph then
                return g:CreateParagraph({
                    Name = tostring(label),
                    Content = "",
                }, id("Section"))
            end
            return g:CreateButton({ Name = tostring(label) }, id("Section"))
        end

        function tabAdapter:Button(label, callback)
            return group("button"):CreateButton({
                Name = tostring(label),
                Icon = icon("play", "Lucide"),
                Style = 2,
                Callback = function()
                    safe(callback)
                end,
            }, id("Button"))
        end

        function tabAdapter:Toggle(label, default, callback)
            local control = group("toggle"):CreateToggle({
                Name = tostring(label),
                CurrentValue = default == true,
                Style = 2,
                Callback = function(value)
                    safe(callback, value)
                end,
            }, id("Toggle"))

            return {
                Raw = control,
                Set = function(_, value)
                    return safeMethod(control, { "Set", "set", "SetValue", "Update" }, value == true)
                end,
                Get = function()
                    if control and control.Values and control.Values.CurrentValue ~= nil then
                        return control.Values.CurrentValue
                    end
                    if control and control.CurrentValue ~= nil then
                        return control.CurrentValue
                    end
                    return nil
                end,
            }
        end

        function tabAdapter:Slider(label, min, max, default, callback)
            local increment = 1
            if max and min and (max - min) <= 5 then
                increment = 0.1
            end

            local control = group("slider"):CreateSlider({
                Name = tostring(label),
                Icon = icon("chart-no-axes-column-increasing", "Lucide") or icon("bar-chart", "Lucide"),
                Range = { tonumber(min) or 0, tonumber(max) or 100 },
                CurrentValue = tonumber(default) or tonumber(min) or 0,
                Increment = increment,
                Callback = function(value)
                    safe(callback, value)
                end,
            }, id("Slider"))

            return {
                Raw = control,
                Set = function(_, value)
                    return safeMethod(control, { "Set", "set", "SetValue", "Update" }, tonumber(value))
                end,
                Get = function()
                    if control and control.Values and control.Values.CurrentValue ~= nil then
                        return control.Values.CurrentValue
                    end
                    if control and control.CurrentValue ~= nil then
                        return control.CurrentValue
                    end
                    return nil
                end,
            }
        end

        function tabAdapter:Textbox(label, numericOnly, callback)
            local control = group("textbox"):CreateInput({
                Name = tostring(label),
                Icon = icon("text-cursor-input", "Lucide"),
                CurrentValue = "",
                PlaceholderText = numericOnly and "0" or "Enter text...",
                Callback = function(text)
                    text = tostring(text or "")
                    if numericOnly then
                        text = text:match("%-?%d+%.?%d*") or ""
                    end
                    safe(callback, text)
                end,
            }, id("Input"))

            return control
        end

        function tabAdapter:Dropdown(label, options, callback)
            local opts = {}
            for _, value in ipairs(options or {}) do
                table.insert(opts, tostring(value))
            end

            local labelControl = group("dropdown"):CreateButton({
                Name = tostring(label),
                Icon = icon("chevrons-up-down", "Lucide"),
                Style = 2,
            }, id("DropdownLabel"))

            local control
            if labelControl and type(labelControl.AddDropdown) == "function" then
                control = labelControl:AddDropdown({
                    Options = opts,
                    CurrentOptions = opts[1] and { opts[1] } or {},
                    Callback = function(selected)
                        if type(selected) == "table" then
                            selected = selected[1]
                        end
                        safe(callback, tostring(selected or ""))
                    end,
                }, id("Dropdown"))
            elseif group("dropdown").CreateDropdown then
                control = group("dropdown"):CreateDropdown({
                    Name = tostring(label),
                    Options = opts,
                    CurrentOptions = opts[1] and { opts[1] } or {},
                    Callback = function(selected)
                        if type(selected) == "table" then
                            selected = selected[1]
                        end
                        safe(callback, tostring(selected or ""))
                    end,
                }, id("Dropdown"))
            end

            local api = {
                Raw = control,
                _options = opts,
            }

            function api:Refresh(newOptions)
                self._options = {}
                for _, value in ipairs(newOptions or {}) do
                    table.insert(self._options, tostring(value))
                end
                safeMethod(control, {
                    "Refresh", "refresh", "UpdateOptions", "SetOptions", "Update", "Set"
                }, self._options)
            end
            api.Update = api.Refresh
            api.update = api.Refresh

            function api:Set(value)
                safeMethod(control, { "Set", "set", "Select", "Update" }, tostring(value))
            end

            function api:Get()
                if control and control.Values then
                    return control.Values.CurrentOption or control.Values.CurrentOptions
                end
                return nil
            end

            return api
        end

        function tabAdapter:Bind(label, key, callback)
            local button = group("button"):CreateButton({
                Name = tostring(label),
                Icon = icon("keyboard", "Lucide"),
                Style = 2,
            }, id("BindButton"))

            local control
            if button and type(button.AddBind) == "function" then
                control = button:AddBind({
                    HoldToInteract = false,
                    CurrentValue = key and key.Name or "RightShift",
                    Callback = function()
                        safe(callback)
                    end,
                }, id("Bind"))
            else
                UserInputService.InputBegan:Connect(function(input, processed)
                    if processed then return end
                    if input.KeyCode == key then
                        safe(callback)
                    end
                end)
            end

            return control or button
        end

        table.insert(self._tabs, tabAdapter)
        return tabAdapter
    end

    function adapter:SelectTab()
        -- Starlight handles selection internally.
    end

    function adapter:Destroy()
        safeMethod(self._window, { "Destroy", "destroy" })
    end

    if toggleKey then
        UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == toggleKey then
                safeMethod(adapter._window, { "Toggle", "toggle", "SetVisible" })
            end
        end)
    end

    return adapter
end

function HashUI:Notification(_title, message, footer, duration)
    return Starlight:Notification({
        Title = tostring(footer or "Hash Hub"),
        Icon = icon("sparkles", "Lucide"),
        Content = tostring(message or ""),
    }, "HashHubNotification" .. tostring(math.random(100000, 999999)))
end

return HashUI

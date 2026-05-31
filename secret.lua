print("HASH HUB")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerName = (LocalPlayer and (LocalPlayer.DisplayName ~= "" and LocalPlayer.DisplayName or LocalPlayer.Name)) or "player"

local VERSION = "2.6.3"
local AUTO_HIDE_AFTER = 4.5 -- auto fade out after 4.5 seconds

--// SIZE CONTROL
--// The last one was too tiny. This scales the whole center title block up.
local CENTER_SCALE = 1.65
local TITLE_TEXT_SIZE = 28
local SUBTITLE_TEXT_SIZE = 13
local UNDERLINE_WIDTH = 165

local DARK = Color3.fromRGB(25, 25, 25)
local DARK_2 = Color3.fromRGB(28, 28, 28)
local PURPLE = Color3.fromRGB(120, 94, 190)
local WHITE = Color3.fromRGB(242, 242, 242)
local TEXT = Color3.fromRGB(205, 205, 210)
local MUTED = Color3.fromRGB(170, 170, 178)

local function safeParent()
    local ok, core = pcall(function()
        return game:GetService("CoreGui")
    end)

    if ok and core then
        return core
    end

    return LocalPlayer:WaitForChild("PlayerGui")
end

pcall(function()
    local old = safeParent():FindFirstChild("HashHubVideoLoader")
    if old then
        old:Destroy()
    end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "HashHubVideoLoader"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.DisplayOrder = 999999
gui.Parent = safeParent()

local bg = Instance.new("Frame")
bg.Name = "Background"
bg.Parent = gui
bg.Size = UDim2.fromScale(1, 1)
bg.Position = UDim2.fromScale(0, 0)
bg.BackgroundColor3 = DARK
bg.BackgroundTransparency = 1
bg.BorderSizePixel = 0
bg.ZIndex = 1

local bars = Instance.new("Frame")
bars.Name = "WipeBars"
bars.Parent = gui
bars.Size = UDim2.fromScale(1, 1)
bars.BackgroundTransparency = 1
bars.ClipsDescendants = false
bars.ZIndex = 5

local function tween(obj, time, props, style, dir)
    local info = TweenInfo.new(
        time,
        style or Enum.EasingStyle.Quint,
        dir or Enum.EasingDirection.Out
    )

    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

local function makeBar(name, color, x, width, z)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Parent = bars
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.fromScale(x, 0.5)
    frame.Size = UDim2.fromScale(width, 1.15)
    frame.BackgroundColor3 = color
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.ZIndex = z or 6
    return frame
end

--// Initial stripe layout from the video.
local leftPurple = makeBar("LeftPurple", PURPLE, 0.34, 0.14, 6)
local leftWhite = makeBar("LeftWhite", WHITE, 0.45, 0.072, 7)
local centerDark = makeBar("CenterDark", DARK_2, 0.50, 0.11, 8)
local rightWhite = makeBar("RightWhite", WHITE, 0.55, 0.072, 7)
local rightPurple = makeBar("RightPurple", PURPLE, 0.66, 0.14, 6)

local center = Instance.new("Frame")
center.Name = "CenterText"
center.Parent = bg
center.AnchorPoint = Vector2.new(0.5, 0.5)
center.Position = UDim2.fromScale(0.5, 0.505)
center.Size = UDim2.fromOffset(420, 120)
center.BackgroundTransparency = 1
center.ZIndex = 10

local centerScale = Instance.new("UIScale")
centerScale.Name = "CenterScale"
centerScale.Parent = center
centerScale.Scale = CENTER_SCALE

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Parent = center
title.AnchorPoint = Vector2.new(0.5, 0.5)
title.Position = UDim2.fromScale(0.5, 0.33)
title.Size = UDim2.fromOffset(420, 34)
title.BackgroundTransparency = 1
title.Font = Enum.Font.Gotham
title.TextSize = TITLE_TEXT_SIZE
title.RichText = true
title.Text = 'hash hub <font color="rgb(120,94,190)">[' .. VERSION .. ']</font>'
title.TextColor3 = TEXT
title.TextTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Center
title.TextYAlignment = Enum.TextYAlignment.Center
title.ZIndex = 11

local underline = Instance.new("Frame")
underline.Name = "Underline"
underline.Parent = center
underline.AnchorPoint = Vector2.new(0.5, 0.5)
underline.Position = UDim2.fromScale(0.5, 0.50)
underline.Size = UDim2.fromOffset(0, 1)
underline.BackgroundColor3 = PURPLE
underline.BackgroundTransparency = 1
underline.BorderSizePixel = 0
underline.ZIndex = 11

local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.Parent = center
subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
subtitle.Position = UDim2.fromScale(0.5, 0.66)
subtitle.Size = UDim2.fromOffset(420, 22)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = SUBTITLE_TEXT_SIZE
subtitle.RichText = true
subtitle.Text = 'welcome, <font color="rgb(120,94,190)">' .. PlayerName .. '</font>, please wait.'
subtitle.TextColor3 = MUTED
subtitle.TextTransparency = 1
subtitle.TextXAlignment = Enum.TextXAlignment.Center
subtitle.TextYAlignment = Enum.TextYAlignment.Center
subtitle.ZIndex = 11

--// Slightly lower at first for the soft title rise.
center.Position = UDim2.fromScale(0.5, 0.518)

local Loader = {}
local hiding = false

function Loader.Hide()
    if hiding or not gui.Parent then
        return
    end

    hiding = true

    tween(center, 0.35, {
        Position = UDim2.fromScale(0.5, 0.49)
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)

    tween(title, 0.28, {TextTransparency = 1}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    tween(subtitle, 0.28, {TextTransparency = 1}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    tween(underline, 0.28, {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(0, 1)
    }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

    task.wait(0.22)

    local out = tween(bg, 0.55, {
        BackgroundTransparency = 1
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)

    out.Completed:Wait()
    gui:Destroy()
end

function Loader.SetSubtitle(text)
    subtitle.Text = tostring(text or "")
end

function Loader.SetVersion(version)
    VERSION = tostring(version or VERSION)
    title.Text = 'hash hub <font color="rgb(120,94,190)">[' .. VERSION .. ']</font>'
end

getgenv().HashHubLoader = Loader

--// Opening animation.
task.spawn(function()
    -- Fade the dark overlay in as the bars sweep.
    tween(bg, 0.42, {BackgroundTransparency = 0}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    -- Bars spread outward while the middle dark panel eats the whole screen.
    tween(centerDark, 0.58, {
        Size = UDim2.fromScale(1.12, 1.15)
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    tween(leftWhite, 0.58, {
        Position = UDim2.fromScale(-0.075, 0.5)
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    tween(leftPurple, 0.58, {
        Position = UDim2.fromScale(-0.25, 0.5)
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    tween(rightWhite, 0.58, {
        Position = UDim2.fromScale(1.075, 0.5)
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    local last = tween(rightPurple, 0.58, {
        Position = UDim2.fromScale(1.25, 0.5)
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    last.Completed:Wait()

    bars.Visible = false
    bg.BackgroundTransparency = 0

    -- Text fades in after the wipe, like the video.
    task.wait(0.05)

    tween(center, 0.65, {
        Position = UDim2.fromScale(0.5, 0.505)
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    tween(title, 0.48, {
        TextTransparency = 0
    }, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

    task.wait(0.12)

    tween(underline, 0.42, {
        Size = UDim2.fromOffset(UNDERLINE_WIDTH, 1),
        BackgroundTransparency = 0.15
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    task.wait(0.08)

    tween(subtitle, 0.42, {
        TextTransparency = 0
    }, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

    if type(AUTO_HIDE_AFTER) == "number" then
        task.wait(AUTO_HIDE_AFTER)
        Loader.Hide()
    end
end)

local player = LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local function notify(text)
    print("[Hash Hub]: " .. tostring(text))
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Hash Hub",
            Text = text,
            Duration = 5
        })
    end)
end


local orbiting = false
local orbitStartTime = tick()
local tracked = {}
local visualizerDisabledScripts = {}
local idxCounter = 0
local lookLocked = false
local targetPlayer = player
local visualizerAnchorRotation = CFrame.new()

local audioVisualizerEnabled = true
local maxRadiusBoost = 8
local visualizerSensitivity = 1
local smoothingFactor = 0.15
local currentRadiusBoost = 0
local loudnessThreshold = 10

local currentSpeed = 2
local currentSize = 5
local currentHeight = 1
local netlessEnabled = true
local netlessVector = Vector3.new(0,0,-31)
local sessionSeed = math.random(1, 100000)

local audioId = nil
local audioPitch = 1
local dupeTargetAmount = 5
local antiFlingEnabled = false
local stealToolsEnabled = false

local function isBoomboxTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    local lowerName = string.lower(tool.Name or "")
    return lowerName:find("boombox", 1, true) ~= nil
        or tool:FindFirstChild("PlayAudio", true) ~= nil
        or tool:FindFirstChild("Remote", true) ~= nil
end

local function collectBoomboxTools()
    local tools = {}
    local seen = {}
    local function scan(container)
        if not container then return end
        for _, tool in ipairs(container:GetChildren()) do
            if isBoomboxTool(tool) and not seen[tool] then
                seen[tool] = true
                table.insert(tools, tool)
            end
        end
    end
    scan(player.Character)
    scan(player:FindFirstChild("Backpack"))
    return tools
end

local function getAudioPitchArg()
    return tostring(math.clamp(tonumber(audioPitch) or 1, 0.1, 3))
end

local function fireAudioRemote(remote, id, preferPlayAudio)
    if not remote or not id then return false end

    local pitch = getAudioPitchArg()
    local numericPitch = tonumber(pitch) or 1
    local attempts

    if remote:IsA("RemoteFunction") then
        if preferPlayAudio then
            attempts = {
                function() return remote:InvokeServer("PlayAudio", tostring(id), pitch, "0", "0") end,
                function() return remote:InvokeServer("PlayAudio", tostring(id), numericPitch, 0, 0) end,
                function() return remote:InvokeServer(id, numericPitch) end,
                function() return remote:InvokeServer(id) end,
                function() return remote:InvokeServer("PlaySong", id, numericPitch) end,
            }
        else
            attempts = {
                function() return remote:InvokeServer("PlaySong", id, numericPitch) end,
                function() return remote:InvokeServer("PlaySong", id) end,
                function() return remote:InvokeServer(id, numericPitch) end,
                function() return remote:InvokeServer(id) end,
                function() return remote:InvokeServer("PlayAudio", tostring(id), pitch, "0", "0") end,
            }
        end
    elseif remote:IsA("RemoteEvent") then
        if preferPlayAudio then
            attempts = {
                function() return remote:FireServer("PlayAudio", tostring(id), pitch, "0", "0") end,
                function() return remote:FireServer("PlayAudio", tostring(id), numericPitch, 0, 0) end,
                function() return remote:FireServer("PlaySong", id, numericPitch) end,
                function() return remote:FireServer("PlaySong", id) end,
                function() return remote:FireServer("Pitch", numericPitch) end,
                function() return remote:FireServer("SetPitch", numericPitch) end,
                function() return remote:FireServer("PlaybackSpeed", numericPitch) end,
            }
        else
            attempts = {
                function() return remote:FireServer("PlaySong", id, numericPitch) end,
                function() return remote:FireServer("PlaySong", id) end,
                function() return remote:FireServer("Pitch", numericPitch) end,
                function() return remote:FireServer("SetPitch", numericPitch) end,
                function() return remote:FireServer("PlaybackSpeed", numericPitch) end,
                function() return remote:FireServer("PlayAudio", tostring(id), pitch, "0", "0") end,
                function() return remote:FireServer("PlayAudio", tostring(id), numericPitch, 0, 0) end,
            }
        end
    else
        return false
    end

    for _, attempt in ipairs(attempts) do
        local ok = pcall(attempt)
        if ok then
            return true
        end
    end
    return false
end

local function playBoomboxTool(tool, id)
    if not tool or not id then return false end
    local played = false
    local playAudio = tool:FindFirstChild("PlayAudio", true)
    if playAudio then
        played = fireAudioRemote(playAudio, id, true)
    end

    if not played then
        local remote = tool:FindFirstChild("Remote", true)
        if remote then
            played = fireAudioRemote(remote, id, false)
        end
    end

    return played
end

_G._8zrtsVizMassPlay = _G._8zrtsVizMassPlay or function(id)
    local prev = audioId
    audioId = id
    pcall(function()
        local char = player.Character
        if not char or not char:FindFirstChild("Humanoid") then return end

        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if isBoomboxTool(tool) then tool.Parent = char end
            end
        end

        local tools = {}
        for _, tool in ipairs(char:GetChildren()) do
            if isBoomboxTool(tool) then table.insert(tools, tool) end
        end
        for _, tool in ipairs(tools) do
            task.spawn(function()
                playBoomboxTool(tool, audioId)
            end)
        end
    end)
    audioId = prev
end


local activeCustomPresetName = "None"

local customPresets = {}
local customPresetNames = {"None"}

local Preset1, Preset2, Preset3, Preset4, Preset5, Preset6, Preset7, Preset8, Preset9, Preset10, Preset11 = true, false, false, false, false, false, false, false, false, false, false

_G.Distance = _G.Distance or 5
_G.Speed = _G.Speed or 1
_G.VisAngle = _G.VisAngle or "X"

local function buildNodeMap(preset)
    local map = {}
    for _, node in ipairs(preset.Nodes or {}) do map[node.ID] = node end
    for _, tool in ipairs(preset.Tools or {}) do map[tool.ID] = tool end
    return map
end

local function getNodeWorldCF(nodeID, t, nodeMap, memo, hrpCF, audioPulse)
    if memo[nodeID] then return memo[nodeID] end

    if nodeID == "HRP" then
        memo["HRP"] = hrpCF
        return hrpCF
    end

    local node = nodeMap[nodeID]
    if not node then
        memo[nodeID] = CFrame.new()
        return CFrame.new()
    end

    local parentCF = getNodeWorldCF(node.ParentID, t, nodeMap, memo, hrpCF, audioPulse)

    local effectiveSens = 0
    if node.Speed == nil then
        local parentNode = nodeMap[node.ParentID]
        if parentNode and parentNode.Sens ~= nil then
            effectiveSens = tonumber(parentNode.Sens) or 0
        elseif node.Sens ~= nil then
            effectiveSens = tonumber(node.Sens) or 0
        end
    end

    local pulseMult = 1 + ((audioPulse / 5) * (effectiveSens / 100))
    local relPos = Vector3.new(node.pos.x, node.pos.y, node.pos.z) * pulseMult
    local relCF  = CFrame.new(relPos) * CFrame.Angles(node.rot.x, node.rot.y, node.rot.z)

    local worldCF
    if node.Speed ~= nil then
        local spd = (node.Speed or 2) * currentSpeed * 0.15
        worldCF = parentCF * relCF * CFrame.Angles(0, t * spd, 0)
    else
        worldCF = parentCF * relCF
    end

    memo[nodeID] = worldCF
    return worldCF
end

local function refreshCustomPresets()
    table.clear(customPresets)
    table.clear(customPresetNames)
    table.insert(customPresetNames, "None")

    print("HashHub: Checking for custom presets...")
    print("HashHub: isfolder function exists:", isfolder ~= nil)
    print("HashHub: listfiles function exists:", listfiles ~= nil)

    if isfolder and isfolder("HashHub") and listfiles then
        print("HashHub: HashHub folder found, scanning files...")
        for _, filePath in ipairs(listfiles("HashHub")) do
            print("HashHub: Found file:", filePath)
            if filePath:match("%.json$") then
                local ok, fileData = pcall(function() return readfile(filePath) end)
                if ok then
                    local ok2, decoded = pcall(function() return HttpService:JSONDecode(fileData) end)
                    if ok2 and decoded and decoded.Type == "NodeGraph" and decoded.Nodes and decoded.Tools then
                        local name = decoded.Name or filePath:match("([^/\\]+)%.json$")
                        decoded._nodeMap = buildNodeMap(decoded)
                        customPresets[name] = decoded
                        table.insert(customPresetNames, name)
                        print("HashHub: Loaded NodeGraph preset -> " .. name)
                    elseif ok2 and decoded then
                        if decoded.Points then
                            warn("HashHub: '" .. (filePath:match("([^/\\]+)%.json$") or filePath)
                                .. "' uses the OLD spline format. Re-export it from the new Preset Builder.")
                        else
                            warn("HashHub: Unrecognised preset format in " .. filePath)
                        end
                    else
                        warn("HashHub: Failed to decode JSON from " .. filePath)
                    end
                else
                    warn("HashHub: Failed to read file " .. filePath)
                end
            end
        end
    else
        warn("HashHub: Custom presets not available - HashHub folder not found or executor doesn't support file functions")
    end

    if CustomPresetsDropdown then
        pcall(function() CustomPresetsDropdown:Refresh(customPresetNames) end)
        pcall(function() CustomPresetsDropdown:update(customPresetNames)  end)
        pcall(function() CustomPresetsDropdown:Update(customPresetNames)  end)
    end
end
refreshCustomPresets()

local activeCustomPresetName = "None"

task.spawn(function()
    local lastContent = ""
    while task.wait(1) do
        if activePreset and activePreset.Type == "NodeGraph" and activeCustomPresetName ~= "None" then
            local filePath = "HashHub/" .. activeCustomPresetName .. ".json"
            if isfile and isfile(filePath) then
                local ok, fileData = pcall(readfile, filePath)
                if ok and fileData ~= lastContent then
                    local ok2, decoded = pcall(function() return HttpService:JSONDecode(fileData) end)
                    if ok2 and decoded and decoded.Type == "NodeGraph" and decoded.Nodes and decoded.Tools then
                        decoded._nodeMap = buildNodeMap(decoded)
                        activePreset.Nodes    = decoded.Nodes
                        activePreset.Tools    = decoded.Tools
                        activePreset._nodeMap = decoded._nodeMap
                        lastContent = fileData
                        print("HashHub: Live-reloaded -> " .. activeCustomPresetName)
                    else
                        warn("HashHub: Live-reload failed for " .. activeCustomPresetName .. " — check JSON syntax / NodeGraph format.")
                    end
                end
            end
        end
    end
end)
local function safePcall(fn, ...) return pcall(fn, ...) end
local function countTracked()
    local n = 0
    for _ in pairs(tracked) do n = n + 1 end
    return n
end

local function getMaxLoudness()
    local maxLoudness = 0
    for _, data in pairs(tracked) do
        if not data.sound or not data.sound.Parent then
            if data.handle and data.handle.Parent then
                data.sound = data.handle.Parent:FindFirstChildWhichIsA("Sound", true)
            end
        end
        if data.sound and data.sound.IsPlaying then
            if data.sound.PlaybackLoudness > maxLoudness then
                maxLoudness = data.sound.PlaybackLoudness
            end
        end
    end
    local myChar = player.Character
    if myChar then
        for _, item in ipairs(myChar:GetChildren()) do
            if item:IsA("Tool") then
                local s = item:FindFirstChildWhichIsA("Sound", true)
                if s and s.IsPlaying and s.PlaybackLoudness > maxLoudness then
                    maxLoudness = s.PlaybackLoudness
                end
            end
        end
    end
    return maxLoudness
end

local function setupMovers(handle)
    local att = Instance.new("Attachment")
    att.Name = "OrbitAtt"
    att.Parent = handle

    local alignPos = Instance.new("AlignPosition")
    alignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
    alignPos.Attachment0 = att
    alignPos.MaxForce = math.huge
    alignPos.Responsiveness = 400
    alignPos.RigidityEnabled = true
    alignPos.ApplyAtCenterOfMass = true
    alignPos.Parent = handle

    local alignRot = Instance.new("AlignOrientation")
    alignRot.Mode = Enum.OrientationAlignmentMode.OneAttachment
    alignRot.Attachment0 = att
    alignRot.MaxTorque = math.huge
    alignRot.Responsiveness = 400
    alignRot.RigidityEnabled = true
    alignRot.Parent = handle

    return alignPos, alignRot, att
end

trackTool = function(tool)
    if not tool or not tool:IsA("Tool") then return end
    if tracked[tool] then return end
    local handle = tool:FindFirstChild("Handle")
    if not handle then return end
    local sound = tool:FindFirstChildWhichIsA("Sound", true)
    idxCounter = idxCounter + 1
    safePcall(function()
        handle.Massless = true
        handle.CanCollide = false
        handle.AssemblyLinearVelocity = Vector3.new(0, 4, 0)
    end)
    visualizerDisabledScripts[tool] = {}
    for _, d in ipairs(tool:GetDescendants()) do
        if d:IsA("LocalScript") then
            visualizerDisabledScripts[tool][d] = d.Disabled
            safePcall(function() d.Disabled = true end)
        end
    end
    local ap, ao, att = setupMovers(handle)
    tracked[tool] = {
        handle = handle, sound = sound,
        alignPos = ap, alignRot = ao, att = att,
        index = idxCounter, netlessAllowed = false, startTime = tick()
    }
    task.delay(0.2, function() if tracked[tool] then tracked[tool].netlessAllowed = true end end)
end

local function untrackAndDestroy(tool)
    local data = tracked[tool]
    if not data then return end
    if visualizerDisabledScripts[tool] then
        for scriptObj, wasDisabled in pairs(visualizerDisabledScripts[tool]) do
            safePcall(function() if scriptObj and scriptObj.Parent then scriptObj.Disabled = wasDisabled end end)
        end
        visualizerDisabledScripts[tool] = nil
    end
    safePcall(function()
        if data.alignPos then data.alignPos:Destroy() end
        if data.alignRot then data.alignRot:Destroy() end
        if data.att      then data.att:Destroy()      end
    end)
    tracked[tool] = nil
end

local function setToolAnim(id)
    if not character then return end
    local animScript = character:FindFirstChild("Animate")
    if animScript then
        local toolNone = animScript:FindFirstChild("toolnone")
        if toolNone then
            local anim = toolNone:FindFirstChild("ToolNoneAnim")
            if anim then anim.AnimationId = id end
        end
    end
end

local function stopVisualizer()
    orbiting = false
    idxCounter = 0
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 16
        player.Character.Humanoid.JumpPower = 50
        workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
    end
    for tool, _ in pairs(tracked) do untrackAndDestroy(tool) end
    tracked = {}
    visualizerDisabledScripts = {}
    for _, jjj in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
        if jjj:IsA("Tool") then
            local h = jjj:FindFirstChild("Handle")
            if h then
                safePcall(function()
                    h.AssemblyLinearVelocity = Vector3.zero
                    h.AssemblyAngularVelocity = Vector3.zero
                end)
            end
            jjj.Parent = game.Players.LocalPlayer.Backpack
        end
    end
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        if player.Character.Humanoid.RigType == Enum.HumanoidRigType.R15 then
            setToolAnim("http://www.roblox.com/asset/?id=507768375")
        elseif player.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 then
            setToolAnim("rbxassetid://182393478")
        end
    end
end

local function startVisualizer()
    stopVisualizer()
    orbiting = true
    orbitStartTime = tick()
    idxCounter = 0
    sessionSeed = math.random(1, 100000)
    setToolAnim("rbxassetid://0")

    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local _, anchorYaw = char.HumanoidRootPart.CFrame:ToOrientation()
        visualizerAnchorRotation = CFrame.Angles(0, anchorYaw, 0)
    end

    for _, jjj in ipairs(game.Players.LocalPlayer.Character:GetChildren()) do
        if jjj:IsA("Tool") then jjj.Parent = game.Players.LocalPlayer.Backpack end
    end

    for _, jjj in ipairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if jjj:IsA("Tool") then trackTool(jjj) end
    end
end

local function syncAudioPlayback()
    if not audioId then
        notify("No audio ID set")
        return
    end

    task.spawn(function()
        local char = player.Character
        if not char or not char:FindFirstChild("Humanoid") then return end

        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if isBoomboxTool(tool) then
                    pcall(function() tool.Parent = char end)
                end
            end
        end

        RunService.Heartbeat:Wait()

        local tools = {}
        for _, tool in ipairs(collectBoomboxTools()) do
            if tool.Parent == char then
                table.insert(tools, tool)
            end
        end

        local success = 0
        for _, tool in ipairs(tools) do
            task.spawn(function()
                if playBoomboxTool(tool, audioId) then
                    success += 1
                end
            end)
        end

        task.wait(0.15)
        notify("Synced " .. tostring(success) .. "/" .. tostring(#tools) .. " boombox(es)")
    end)
end


local function computeTargetPos(index, t, hrp)
    local i = index or 1
    local total = math.max(1, countTracked())
    local vf = hrp.CFrame

    local PBL = 0
    local ToolFind = player.Character and player.Character:FindFirstChildOfClass('Tool')
    if ToolFind and ToolFind:FindFirstChild('Handle') and ToolFind['Handle']:FindFirstChild('Sound') then
        PBL = ToolFind['Handle']['Sound']['PlaybackLoudness'] * 0.02
    end

    local sensVal = 1
    local bassVal = 1

    local Volume = PBL
    local Radius = Volume * 1 * (sensVal/5)
    local Spin = t * 5 * currentSpeed + (_G.Speed or 1)
    local Spin2 = t * 100 * (currentSpeed/5) + (_G.Speed or 1)
    local TiltSensitivity = Volume * (bassVal/20)

    local function AngleFromSettings(angle, str)
        if str == "X" then
            return CFrame.Angles(angle, 0, 0)
        elseif str == "Y" then
            return CFrame.Angles(0, angle, 0)
        elseif str == "Z" then
            return CFrame.Angles(0, 0, angle)
        end
    end

    local Z = (_G.Distance or 5) + Volume / (1 ~= 100 and (100 - 1) or .01)

    if activePreset and activePreset.Type == "NodeGraph" then
        local toolData = activePreset._nodeMap[toolId]
        if toolData then
            local worldCF = getNodeWorldCF(toolData.ParentID, t, activePreset._nodeMap, {}, hrp.CFrame, Volume)
            return worldCF.Position
        end
    end

    if Preset1 then
        local Iterator = math.rad(Spin + (i * (360 / total)))
        local P = CFrame.new(hrp.Position) * AngleFromSettings(Iterator, _G.VisAngle) * CFrame.new(0, 0, Z)
        return P.p

    elseif Preset2 then
        local spacing = ((_G.Distance or 5) * 0.4) + (Radius * 0.2)
        local centerOffset = (i - (total / 2) - 0.5) * spacing
        local waveVal = math.sin((t * currentSpeed) + (i * 0.5)) * 1.5
        local linePos = Vector3.new(centerOffset, waveVal, 0)
        local rotationAngle = t * currentSpeed
        local rotatedX = linePos.X * math.cos(rotationAngle) - linePos.Z * math.sin(rotationAngle)
        local rotatedZ = linePos.X * math.sin(rotationAngle) + linePos.Z * math.cos(rotationAngle)
        return vf:PointToWorldSpace(Vector3.new(rotatedX, linePos.Y, rotatedZ))

    elseif Preset3 then
        local spacing = ((_G.Distance or 5) * 0.4) + (Radius * 0.2)
        local centerOffset = (i - (total / 2) - 0.5) * spacing
        local waveVal = math.sin((t * currentSpeed) + (i * 0.5)) * 1.5
        local lineOffset = (i % 2 == 0) and 2 or -2
        local linePos = Vector3.new(centerOffset, waveVal, lineOffset)
        local rotationAngle = t * currentSpeed
        local rotatedX = linePos.X * math.cos(rotationAngle) - linePos.Z * math.sin(rotationAngle)
        local rotatedZ = linePos.X * math.sin(rotationAngle) + linePos.Z * math.cos(rotationAngle)
        return vf:PointToWorldSpace(Vector3.new(rotatedX, linePos.Y, rotatedZ))

    elseif Preset4 then
        local angle = math.rad(Spin + (i * (360 / total)))
        local r = 5 + Radius * 2
        local x = math.cos(angle * 3) * r
        local y = math.sin(angle * 2 + t) * (Radius * 2)
        local z = math.sin(angle * 3) * r
        return vf:PointToWorldSpace(Vector3.new(x, y, z))

    elseif Preset5 then
        local angle = math.rad(Spin2 + (i * (360 / total)))
        local r = 3 + Radius
        local wave1 = math.sin(angle * 4 + t * 3) * (Radius * 1.5)
        local wave2 = math.cos(angle * 2 - t * 2) * Radius
        return vf:PointToWorldSpace(Vector3.new(math.cos(angle) * r + wave1, wave2, math.sin(angle) * r + wave1))

    elseif Preset6 then
        return vf:PointToWorldSpace(Vector3.new(0, 0, .9))

    elseif Preset7 then
        local rightArm = hrp.Parent:FindFirstChild("Right Arm")
        if rightArm then
            return (rightArm.CFrame * CFrame.new(0, -1.5, 0)).p
        else
            return vf:PointToWorldSpace(Vector3.new(1.5, 0, 0))
        end

    elseif Preset8 then
        local angle = math.rad(Spin + (i * (360 / total)))
        local r = 4 + math.sin(t + i * 0.5) * 2
        local height = math.sin(angle * 3 + t * 2) * (Radius * 2)
        local wave = math.cos(angle * 2) * Radius
        return vf:PointToWorldSpace(Vector3.new(math.cos(angle) * r + wave, height, math.sin(angle) * r + wave))

    elseif Preset9 then
        local angle = math.rad(Spin2 + (i * (360 / total)))
        local r = 5 * (1 + Radius)
        local wave1 = math.sin(angle * 2 + t * 3) * (Radius * 2)
        local wave2 = math.cos(angle * 3 - t * 2) * (Radius)
        return vf:PointToWorldSpace(Vector3.new(math.cos(angle) * r, wave1 + wave2, math.sin(angle) * r))

    elseif Preset10 then
        local Iterator = math.rad(Spin + (i * (360 / total)))
        local P = CFrame.new(hrp.Position) * AngleFromSettings(Iterator, _G.VisAngle) * CFrame.new(0, 0, Z)
        local wave = math.sin(Iterator * 3 + t * 2) * (Radius * 2)
        return P.p + Vector3.new(0, wave, 0)

    elseif Preset11 then
        local angle = math.rad(Spin + (i * (360 / total)))
        local r = 4 + Radius * 1.5
        local spiralOffset = (i / total) * 2
        local wave = math.sin(angle * 5 + t * 4) * (Radius * 1.5)
        local height = math.cos(angle * 3 + t) * Radius
        return vf:PointToWorldSpace(Vector3.new(math.cos(angle) * r * spiralOffset, height + wave, math.sin(angle) * r * spiralOffset))
    end

    local angle = t*2 + i*0.5
    local r = 5
    return vf:PointToWorldSpace(Vector3.new(math.cos(angle)*r, 0, math.sin(angle)*r))
end


local spyTracked = {}
local nameCache = {}
local findValidAudio

local source = readfile("hashui.lua")

local fn, err = loadstring(source)
assert(fn, "HashUI compile error: " .. tostring(err))

local Library = fn()
assert(type(Library) == "table", "HashUI returned nil")
assert(type(Library.Load) == "function", "Library.Load missing")

local UI = Library.Load("ui")
local Notif = Library.Load("notif")

assert(UI, "UI failed to load")
assert(Notif, "Notif failed to load")

local Window = UI:Start({
    Header = "Hash Hub",
    Footer = "Hash Hub | Loaded",
    VisibleKeybind = Enum.KeyCode.RightShift
})

local function notify(message, title)
    Notif:Send({
        Header = title or "Hash Hub",
        Notification = tostring(message),
        Time = 3
    })
end

notify("UI loaded successfully. Press RightShift to hide/show.")

local VisualizerPage = Window:CreatePage({
    Subject = "Visualizer",
    Footer = "Visualizer controls"
})

local AudioPage = Window:CreatePage({
    Subject = "Audio",
    Footer = "Audio controls"
})

local MiscPage = Window:CreatePage({
    Subject = "Misc",
    Footer = "Misc tools"
})

local VizSection = VisualizerPage:CreateSection({Header = "Visualizer"})
local VizControls = VisualizerPage:CreateSection({Header = "Controls"})

VizSection:CreateButton({
    Text = "Circle",
    Script = function()
        Preset1, Preset2, Preset3, Preset4, Preset5, Preset6, Preset7, Preset8, Preset9, Preset10, Preset11 = true, false, false, false, false, false, false, false, false, false, false
        activeCustomPresetName = "None"
        activePreset = nil
        notify("Preset: Circle")
    end
})

VizSection:CreateButton({
    Text = "Line",
    Script = function()
        Preset1, Preset2, Preset3, Preset4, Preset5, Preset6, Preset7, Preset8, Preset9, Preset10, Preset11 = false, true, false, false, false, false, false, false, false, false, false
        activeCustomPresetName = "None"
        activePreset = nil
        notify("Preset: Line")
    end
})

VizSection:CreateButton({
    Text = "Globe",
    Script = function()
        Preset1, Preset2, Preset3, Preset4, Preset5, Preset6, Preset7, Preset8, Preset9, Preset10, Preset11 = false, false, true, false, false, false, false, false, false, false, false
        activeCustomPresetName = "None"
        activePreset = nil
        notify("Preset: Globe")
    end
})

VizSection:CreateButton({
    Text = "DoubleRing",
    Script = function()
        Preset1, Preset2, Preset3, Preset4, Preset5, Preset6, Preset7, Preset8, Preset9, Preset10, Preset11 = false, false, false, true, false, false, false, false, false, false, false
        activeCustomPresetName = "None"
        activePreset = nil
        notify("Preset: DoubleRing")
    end
})

VizSection:CreateButton({
    Text = "DoubleLine",
    Script = function()
        Preset1, Preset2, Preset3, Preset4, Preset5, Preset6, Preset7, Preset8, Preset9, Preset10, Preset11 = false, false, false, false, true, false, false, false, false, false, false
        activeCustomPresetName = "None"
        activePreset = nil
        notify("Preset: DoubleLine")
    end
})

VizSection:CreateButton({
    Text = "Backpack",
    Script = function()
        Preset1, Preset2, Preset3, Preset4, Preset5, Preset6, Preset7, Preset8, Preset9, Preset10, Preset11 = false, false, false, false, false, true, false, false, false, false, false
        activeCustomPresetName = "None"
        activePreset = nil
        notify("Preset: Backpack")
    end
})

VizSection:CreateButton({
    Text = "Lowhold",
    Script = function()
        Preset1, Preset2, Preset3, Preset4, Preset5, Preset6, Preset7, Preset8, Preset9, Preset10, Preset11 = false, false, false, false, false, false, true, false, false, false, false
        activeCustomPresetName = "None"
        activePreset = nil
        notify("Preset: Lowhold")
    end
})

VizSection:CreateButton({
    Text = "Hyperbolic",
    Script = function()
        Preset1, Preset2, Preset3, Preset4, Preset5, Preset6, Preset7, Preset8, Preset9, Preset10, Preset11 = false, false, false, false, false, false, false, true, false, false, false
        activeCustomPresetName = "None"
        activePreset = nil
        notify("Preset: Hyperbolic")
    end
})

VizSection:CreateButton({
    Text = "Sine",
    Script = function()
        Preset1, Preset2, Preset3, Preset4, Preset5, Preset6, Preset7, Preset8, Preset9, Preset10, Preset11 = false, false, false, false, false, false, false, false, true, false, false
        activeCustomPresetName = "None"
        activePreset = nil
        notify("Preset: Sine")
    end
})

VizSection:CreateButton({
    Text = "Circle 2",
    Script = function()
        Preset1, Preset2, Preset3, Preset4, Preset5, Preset6, Preset7, Preset8, Preset9, Preset10, Preset11 = false, false, false, false, false, false, false, false, false, true, false
        activeCustomPresetName = "None"
        activePreset = nil
        notify("Preset: Circle 2")
    end
})

VizSection:CreateButton({
    Text = "Circle 3",
    Script = function()
        Preset1, Preset2, Preset3, Preset4, Preset5, Preset6, Preset7, Preset8, Preset9, Preset10, Preset11 = false, false, false, false, false, false, false, false, false, false, true
        activeCustomPresetName = "None"
        activePreset = nil
        notify("Preset: Circle 3")
    end
})

VizSection:CreateButton({
    Text = "planetary2",
    Script = function()
        Preset1, Preset2, Preset3, Preset4, Preset5, Preset6, Preset7, Preset8, Preset9, Preset10, Preset11 = false, false, false, false, false, false, false, false, false, false, false
        local preset = customPresets["planetary2"]
        if preset then
            activeCustomPresetName = "planetary2"
            activePreset = preset
            notify("Custom Preset: planetary2")
        else
            notify("planetary2 not found in HashHub folder")
        end
    end
})

print("Custom presets loaded: " .. #customPresetNames)
for i, name in ipairs(customPresetNames) do
    print("  - " .. name)
end

if #customPresetNames > 1 then
    print("Creating custom presets dropdown...")
    CustomPresetsDropdown = VizSection:CreateDropdown({
        Text = "Custom Presets",
        Values = customPresetNames,
        Default = "None",
        Script = function(value)
            if value == "None" then
                activeCustomPresetName = "None"
                activePreset = nil
                notify("Custom Preset: None")
            else
                local preset = customPresets[value]
                if preset then
                    Preset1, Preset2, Preset3, Preset4, Preset5, Preset6, Preset7, Preset8, Preset9, Preset10, Preset11 = false, false, false, false, false, false, false, false, false, false, false
                    activeCustomPresetName = value
                    activePreset = preset
                    notify("Custom Preset: " .. value)
                end
            end
        end
    })
    print("Dropdown created successfully")
else
    print("No custom presets found, skipping dropdown creation")
end

VizControls:CreateTextbox({
    Text = "Distance",
    Default = "5",
    Script = function(text)
        _G.Distance = tonumber(text) or 5
    end
})

VizControls:CreateTextbox({
    Text = "Speed",
    Default = "1",
    Script = function(text)
        _G.Speed = tonumber(text) or 1
    end
})

VizControls:CreateButton({
    Text = "Vis Angle: X",
    Script = function()
        _G.VisAngle = "X"
        notify("Vis Angle: X")
    end
})

VizControls:CreateButton({
    Text = "Vis Angle: Y",
    Script = function()
        _G.VisAngle = "Y"
        notify("Vis Angle: Y")
    end
})

VizControls:CreateButton({
    Text = "Vis Angle: Z",
    Script = function()
        _G.VisAngle = "Z"
        notify("Vis Angle: Z")
    end
})

VizSection:CreateSlider({
    Text = "Speed",
    Suffix = "",
    Values = {
        Minimum = 1,
        Maximum = 50,
        Default = 10
    },
    Script = function(v)
        currentSpeed = v * 0.1
    end
})

VizSection:CreateCheck({
    Text = "Audio Visualize (React)",
    Default = true,
    Script = function(b)
        audioVisualizerEnabled = b
    end
})

VizSection:CreateButton({
    Text = "Visualize",
    Script = function()
        stopVisualizer()
        orbiting = true
        orbitStartTime = tick()
        idxCounter = 0
        sessionSeed = math.random(1, 100000)
        setToolAnim("rbxassetid://0")

        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local _, anchorYaw = char.HumanoidRootPart.CFrame:ToOrientation()
            visualizerAnchorRotation = CFrame.Angles(0, anchorYaw, 0)
        end

        for _, jjj in ipairs(game.Players.LocalPlayer.Character:GetChildren()) do
            if jjj:IsA("Tool") then jjj.Parent = game.Players.LocalPlayer.Backpack end
        end

        if player.Character and player.Character:FindFirstChild("Humanoid") then
            workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
        end

        if player.Backpack then
            for _, tool in ipairs(player.Backpack:GetChildren()) do
                if tool:IsA("Tool") then tool.Parent = player.Character end
            end
        end
        for _, jjj in ipairs(game.Players.LocalPlayer.Character:GetChildren()) do
            if jjj:IsA("Tool") then jjj.Parent = game.Players.LocalPlayer.Backpack end
        end

        for _, tool in ipairs(player:WaitForChild("Backpack"):GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                tool.Parent = player.Character
                tool.Parent = player.Backpack
                tool.Parent = player.Character
                tool.Parent = player.Backpack
                if player.Character:FindFirstChild("Humanoid") then
                    tool.Parent = player.Character:FindFirstChild("Humanoid")
                end
                tool.Parent = player.Character
                RunService.Heartbeat:Wait()
                trackTool(tool)
            end
        end
        notify("Visualizer started with " .. #tracked .. " tools")
    end
})

VizControls:CreateButton({
    Text = "Demesh",
    Script = function()
        for _, container in ipairs({player.Backpack, player.Character}) do
            for _, v in ipairs(container:GetChildren()) do
                if v.Name:lower():match('boombox') then
                    pcall(function() v.Handle.Mesh:Destroy() end)
                end
            end
        end
        notify("Demeshed all boomboxes")
    end
})

VizControls:CreateTextbox({
    Text = "Target Player",
    Default = "",
    Script = function(text)
        if text == "" then targetPlayer = player; return end
        for _, p in ipairs(Players:GetPlayers()) do
            if string.sub(string.lower(p.Name), 1, #text) == string.lower(text)
            or string.sub(string.lower(p.DisplayName), 1, #text) == string.lower(text) then
                targetPlayer = p; return
            end
        end
        if not targetPlayer then targetPlayer = player end
    end
})

VizControls:CreateTextbox({
    Text = "Dupe Amount",
    Default = "5",
    Script = function(text)
        local n = tonumber(text)
        if n and n > 0 then dupeTargetAmount = n end
    end
})

VizControls:CreateButton({
    Text = "Start Dupe",
    Script = function()
        task.spawn(function()
            local me = game.Players.LocalPlayer
            local character = me.Character or me.CharacterAdded:Wait()
            local humanoid = character:WaitForChild("Humanoid")
            local backpack = me:WaitForChild("Backpack")
            local begin = character.HumanoidRootPart.CFrame

            local tools = backpack:GetChildren()
            for _, tool in ipairs(tools) do
                if tool:IsA("Tool") then
                    humanoid:EquipTool(tool)
                    humanoid:UnequipTools()
                end
            end
            humanoid.Health = 0

            local respawnTime = Players.RespawnTime
            task.wait(respawnTime - 0.2)

            for _, tool in ipairs(tools) do
                if tool and tool.Parent then
                    tool.Parent = character  
                    tool.Parent = workspace 
                end
            end

            local newHumanoid = me.CharacterAdded:Wait():WaitForChild("Humanoid")

            task.wait(0.1)

            for _, tool in ipairs(tools) do
                if tool and tool.Parent == workspace then
                    newHumanoid:EquipTool(tool)
                end
            end

            newHumanoid.Parent.HumanoidRootPart.CFrame = begin
            notify("Dupe done! Total tools: " .. #me.Backpack:GetChildren())
        end)
    end
})

local AudioControls = AudioPage:CreateSection({Header = "Audio Controls"})
local AudioPlayback = AudioPage:CreateSection({Header = "Playback"})

AudioControls:CreateTextbox({
    Text = "Audio ID",
    Default = "",
    Script = function(text)
        local id = string.match(text, "%d+")
        if id then
            audioId = tonumber(id)
            if player.Character then
                for _, tool in ipairs(player.Character:GetChildren()) do
                    if isBoomboxTool(tool) then
                        playBoomboxTool(tool, audioId)
                    end
                end
            end
        end
    end
})

AudioControls:CreateSlider({
    Text = "Pitch",
    Suffix = "x",
    Values = {
        Minimum = 1,
        Maximum = 30,
        Default = 10
    },
    Script = function(v)
        audioPitch = math.clamp((tonumber(v) or 10) / 10, 0.1, 3)
    end
})

AudioPlayback:CreateButton({
    Text = "Apply Pitch / Replay",
    Script = function()
        if not audioId then
            notify("No audio ID set")
            return
        end

        local success = 0
        for _, tool in ipairs(collectBoomboxTools()) do
            if playBoomboxTool(tool, audioId) then
                success += 1
            end
        end
        notify("Applied pitch to " .. tostring(success) .. " boombox(es).")
    end
})

AudioPlayback:CreateButton({
    Text = "Sync Audio",
    Script = function()
        syncAudioPlayback()
    end
})

AudioPlayback:CreateButton({
    Text = "Mass Play",
    Script = function()
        _G._8zrtsVizMassPlay = _G._8zrtsVizMassPlay or function(id)
            local prev = audioId
            audioId = id
            pcall(function()
                local char = player.Character
                if not char or not char:FindFirstChild("Humanoid") then return end

                local backpack = player:FindFirstChild("Backpack")
                if backpack then
                    for _, tool in ipairs(backpack:GetChildren()) do
                        if isBoomboxTool(tool) then tool.Parent = char end
                    end
                end

                local tools = {}
                for _, tool in ipairs(char:GetChildren()) do
                    if isBoomboxTool(tool) then table.insert(tools, tool) end
                end
                for _, tool in ipairs(tools) do
                    task.spawn(function()
                        playBoomboxTool(tool, audioId)
                    end)
                end
            end)
            audioId = prev
        end

        if not audioId then
            print("Hash Hub: No audio ID set")
            return
        end

        task.spawn(function()
            local char = player.Character
            if not char or not char:FindFirstChild("Humanoid") then return end

            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                for _, tool in ipairs(backpack:GetChildren()) do
                    if isBoomboxTool(tool) then tool.Parent = char end
                end
            end

            local tools = {}
            for _, tool in ipairs(char:GetChildren()) do
                if isBoomboxTool(tool) then table.insert(tools, tool) end
            end

            for _, tool in ipairs(tools) do
                task.spawn(function()
                    playBoomboxTool(tool, audioId)
                end)
            end

            task.wait(0.1)
            print("Mass Play finished -> " .. #tools .. " boomboxes triggered")
        end)
    end
})

local MiscUtility = MiscPage:CreateSection({Header = "Utility"})
local MiscServer = MiscPage:CreateSection({Header = "Server"})

MiscUtility:CreateCheck({
    Text = "Anti Fling",
    Script = function(b)
        antiFlingEnabled = b
    end
})

MiscUtility:CreateCheck({
    Text = "Steal Tools",
    Script = function(b)
        stealToolsEnabled = b
    end
})

MiscUtility:CreateCheck({
    Text = "Toggle Audio Spy",
    Script = function(b)
        audioSpyEnabled = b
        if not b then
            for _,d in pairs(spyTracked) do if d.bb then d.bb:Destroy() end end
            for k in pairs(spyTracked) do spyTracked[k] = nil end
        end
    end
})

MiscServer:CreateButton({
    Text = "Copy Ids in Server",
    Script = function()
        local lines = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local obj, id = findValidAudio and findValidAudio(p.Character)
                if id then
                    table.insert(lines, p.Name.." was playing \""..id.."\", \""..(nameCache[id] or "Unknown Name").."\" atm")
                end
            end
        end
        if #lines > 0 then
            local str = table.concat(lines, "\n")
            if setclipboard then setclipboard(str) elseif toclipboard then toclipboard(str) end
        end
    end
})

MiscServer:CreateButton({
    Text = "Useless Button",
    Script = function()
        print("This was gonna be the destroy gui button but nah")
    end
})

local SPY_RANGE = 40

local BLACKLIST = {
    ["Climbing"]=true,["Died"]=true,["GettingUp"]=true,["Swimming"]=true,
    ["Jumping"]=true,["Landing"]=true,["Splash"]=true,["FreeFalling"]=true,
    ["Running"]=true
}

local spyScreenGui = Instance.new("ScreenGui")
spyScreenGui.Name = "AudioSpyCore"
spyScreenGui.ResetOnSpawn = false
spyScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
spyScreenGui.Parent = (syn and syn.protect_gui and syn.protect_gui(spyScreenGui) and player:WaitForChild("PlayerGui"))
                   or (gethui and gethui())
                   or player:WaitForChild("PlayerGui")

local function fmtTime(s)
    s = s or 0
    return string.format("%d:%02d", math.floor(s/60), math.floor(s%60))
end
local function extractId(s)
    s = tostring(s or "")
    return tonumber(s:match("rbxassetid://(%d+)"))
        or tonumber(s:match("[?&]id=(%d+)"))
        or tonumber(s:match("(%d+)"))
        or 0
end
local function getName(id)
    if id <= 0 then return "Unknown" end
    if nameCache[id] then return nameCache[id] end
    pcall(function() nameCache[id] = MarketplaceService:GetProductInfo(id, Enum.InfoType.Asset).Name end)
    return nameCache[id] or "Unknown ("..id..")"
end
function findValidAudio(char)
    for _, obj in ipairs(char:GetDescendants()) do
        if not BLACKLIST[obj.Name] then
            if obj:IsA("Sound") and obj.IsPlaying then
                local id = extractId(obj.SoundId)
                if id > 0 then
                    return obj, id, obj.Parent:IsA("BasePart") and obj.Parent or char:FindFirstChild("Head")
                end
            elseif obj:IsA("AudioPlayer") then
                local id = extractId(obj.AssetId)
                if id > 0 then return obj, id, char:FindFirstChild("Head") end
            end
        end
    end
end

local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
    return c
end

local function addStroke(parent, color, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(50, 50, 56)
    s.Transparency = transparency or 0
    s.Thickness = 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function makeSpyBB(adornee)
    local bb = Instance.new("BillboardGui", spyScreenGui)
    bb.Name = "HashHubAudioSpy"
    bb.Size = UDim2.new(0, 250, 0, 104)
    bb.StudsOffset = Vector3.new(0, 3.1, 0)
    bb.AlwaysOnTop = true
    bb.Adornee = adornee
    bb.MaxDistance = SPY_RANGE + 20
    bb.Active = true

    local m = Instance.new("Frame", bb)
    m.Name = "Card"
    m.Size = UDim2.new(1, 0, 1, -10)
    m.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
    m.BorderSizePixel = 0
    m.BackgroundTransparency = 0.04
    m.Active = true
    addCorner(m, 8)
    addStroke(m, Color3.fromRGB(52, 52, 58), 0.18)

    local pad = Instance.new("UIPadding", m)
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.PaddingTop = UDim.new(0, 7)
    pad.PaddingBottom = UDim.new(0, 7)

    local nameLbl = Instance.new("TextLabel", m)
    nameLbl.Name = "AudioName"
    nameLbl.Size = UDim2.new(1, -76, 0, 22)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Font = Enum.Font.GothamMedium
    nameLbl.TextColor3 = Color3.fromRGB(226, 226, 230)
    nameLbl.TextSize = 13
    nameLbl.Text = "Loading..."
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left

    local tag = Instance.new("TextLabel", m)
    tag.Name = "Tag"
    tag.AnchorPoint = Vector2.new(1, 0)
    tag.Position = UDim2.new(1, 0, 0, 1)
    tag.Size = UDim2.fromOffset(66, 20)
    tag.BackgroundColor3 = Color3.fromRGB(38, 32, 52)
    tag.BorderSizePixel = 0
    tag.Font = Enum.Font.GothamMedium
    tag.TextColor3 = Color3.fromRGB(176, 143, 240)
    tag.TextSize = 10
    tag.Text = "AUDIO"
    addCorner(tag, 5)

    local accent = Instance.new("Frame", m)
    accent.Name = "Accent"
    accent.BackgroundColor3 = Color3.fromRGB(138, 101, 212)
    accent.BorderSizePixel = 0
    accent.Position = UDim2.fromOffset(0, 27)
    accent.Size = UDim2.new(1, 0, 0, 1)

    local idRow = Instance.new("Frame", m)
    idRow.Name = "IdRow"
    idRow.Size = UDim2.new(1, 0, 0, 28)
    idRow.Position = UDim2.new(0, 0, 0, 35)
    idRow.BackgroundTransparency = 1

    local idLbl = Instance.new("TextLabel", idRow)
    idLbl.Name = "AudioId"
    idLbl.Size = UDim2.new(1, -82, 1, 0)
    idLbl.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
    idLbl.BorderSizePixel = 0
    idLbl.Font = Enum.Font.Gotham
    idLbl.TextColor3 = Color3.fromRGB(190, 190, 198)
    idLbl.TextSize = 12
    idLbl.TextXAlignment = Enum.TextXAlignment.Left
    idLbl.Text = "ID: ..."
    addCorner(idLbl, 5)
    addStroke(idLbl, Color3.fromRGB(45, 45, 50), 0.35)
    local idPad = Instance.new("UIPadding", idLbl)
    idPad.PaddingLeft = UDim.new(0, 8)

    local copyBtn = Instance.new("TextButton", idRow)
    copyBtn.Name = "CopyBtn"
    copyBtn.Size = UDim2.new(0, 74, 1, 0)
    copyBtn.Position = UDim2.new(1, -74, 0, 0)
    copyBtn.BackgroundColor3 = Color3.fromRGB(38, 32, 52)
    copyBtn.BorderSizePixel = 0
    copyBtn.Font = Enum.Font.GothamMedium
    copyBtn.TextColor3 = Color3.fromRGB(226, 226, 230)
    copyBtn.TextSize = 11
    copyBtn.Text = "COPY"
    copyBtn.Active = true
    copyBtn.Selectable = true
    copyBtn.AutoButtonColor = false
    addCorner(copyBtn, 5)
    addStroke(copyBtn, Color3.fromRGB(70, 55, 105), 0.2)

    local statLbl = Instance.new("TextLabel", m)
    statLbl.Name = "Stats"
    statLbl.Size = UDim2.new(1, 0, 0, 18)
    statLbl.Position = UDim2.new(0, 0, 0, 68)
    statLbl.BackgroundTransparency = 1
    statLbl.Font = Enum.Font.Gotham
    statLbl.TextColor3 = Color3.fromRGB(145, 145, 154)
    statLbl.TextSize = 11
    statLbl.TextXAlignment = Enum.TextXAlignment.Left
    statLbl.Text = "0:00 / 0:00 | L: 0"

    return bb, nameLbl, idLbl, statLbl, copyBtn
end

RunService.Heartbeat:Connect(function()
    if not audioSpyEnabled or not player.Character then return end
    local myRoot = player.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local activePlrs = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp and (myRoot.Position - hrp.Position).Magnitude <= SPY_RANGE then
                local obj, id, parentPart = findValidAudio(p.Character)
                if id then
                    activePlrs[p] = true
                    if not spyTracked[p] then
                        local bb, nLbl, iLbl, sLbl, btn = makeSpyBB(parentPart or hrp)
                        spyTracked[p] = {bb=bb, nLbl=nLbl, iLbl=iLbl, sLbl=sLbl, fetch=0, cur=0}
                        btn.MouseButton1Click:Connect(function()
                            local s = tostring(spyTracked[p].cur)
                            if setclipboard then setclipboard(s) elseif toclipboard then toclipboard(s) end
                            btn.Text = "COPIED"
                            btn.BackgroundColor3 = Color3.fromRGB(138, 101, 212)
                            task.delay(1, function()
                                pcall(function()
                                    btn.Text = "COPY"
                                    btn.BackgroundColor3 = Color3.fromRGB(38, 32, 52)
                                end)
                            end)
                        end)
                    end
                    local d = spyTracked[p]
                    if d then
                        d.cur = id
                        d.bb.Adornee = parentPart or hrp
                        if d.fetch ~= id then
                            d.fetch = id d.nLbl.Text = "Fetching..."
                            task.spawn(function()
                                local nm = getName(id)
                                if d.fetch == id and d.bb.Parent then d.nLbl.Text = nm end
                            end)
                        end
                        d.iLbl.Text = "ID: "..id
                        local loudness = (obj:IsA("Sound") and obj.PlaybackLoudness) or 0
                        local curT = (obj:IsA("Sound") and obj.TimePosition)   or 0
                        local maxT = (obj:IsA("Sound") and obj.TimeLength)      or 0
                        d.sLbl.Text = fmtTime(curT).." / "..fmtTime(maxT).." | L: "..math.floor(loudness)
                    end
                end
            end
        end
    end
    for p, d in pairs(spyTracked) do
        if not activePlrs[p] then if d.bb then d.bb:Destroy() end spyTracked[p] = nil end
    end
end)
Players.PlayerRemoving:Connect(function(p)
    if spyTracked[p] then spyTracked[p].bb:Destroy() spyTracked[p] = nil end
end)

player.CharacterAdded:Connect(function(char)
    character = char
    targetPlayer = player
    stopVisualizer()
end)

task.spawn(function()
    while task.wait(0.3) do
        if antiFlingEnabled then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    for _, part in ipairs(p.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                            part.Massless = true
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if stealToolsEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
            for _, j in ipairs(workspace:GetChildren()) do
                if j:IsA("Tool") then
                    player.Character.Humanoid:EquipTool(j)
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    for tool, data in pairs(tracked) do
        local h = data.handle
        if h and h.Parent and netlessEnabled then
            pcall(function()
                h.AssemblyLinearVelocity = netlessVector
            end)
        end
    end
end)

RunService.Heartbeat:Connect(function(dt)
    if not orbiting or not player.Character then return end

    for tool in pairs(tracked) do
        if not tool.Parent or tool.Parent == player.Backpack then
            stopVisualizer()
            print('Visualizer: tool left — stopping')
            return
        end
    end

    local tChar = (targetPlayer and targetPlayer.Parent) and targetPlayer.Character or player.Character
    local hrp   = tChar and tChar:FindFirstChild('HumanoidRootPart')
    if not hrp then return end
    if tChar:FindFirstChild('Humanoid') and tChar.Humanoid.Health <= 0 then return end

    local t = tick() - orbitStartTime

    for tool, data in pairs(tracked) do
        local h = data.handle
        if not (h and h.Parent) then
            untrackAndDestroy(tool)
        else
            safePcall(function()
                h.Massless = true
                h.CanCollide = false
                if netlessEnabled and data.netlessAllowed then
                    h.AssemblyLinearVelocity = netlessVector
                end
            end)

            local tPos = computeTargetPos(data.index, t, hrp)

            local tRot
            local i = data.index
            local total = countTracked()

            local PBL = 0
            local ToolFind = player.Character and player.Character:FindFirstChildOfClass('Tool')
            if ToolFind and ToolFind:FindFirstChild('Handle') and ToolFind['Handle']:FindFirstChild('Sound') then
                PBL = ToolFind['Handle']['Sound']['PlaybackLoudness'] * 0.02
            end
            local sensVal = 1
            local bassVal = 1
            local Volume = PBL
            local TiltSensitivity = Volume * (bassVal/10)
            local Spin = t * 5

            if activePreset and activePreset.Type == "NodeGraph" then
                local toolData = activePreset._nodeMap[toolId]
                if toolData then
                    local worldCF = getNodeWorldCF(toolData.ParentID, t, activePreset._nodeMap, {}, hrp.CFrame, Volume)
                    tRot = worldCF
                else
                    tRot = CFrame.lookAt(tPos, hrp.Position)
                end
            elseif Preset1 then
                tRot = CFrame.lookAt(tPos, hrp.Position) * CFrame.Angles(-1.3 + TiltSensitivity, 0, 0)
            elseif Preset2 then
                tRot = hrp.CFrame * CFrame.new((i * 3) - (total * 1.6 / 2), 0, 0)
            elseif Preset3 then
                tRot = CFrame.lookAt(tPos, hrp.Position) * CFrame.Angles(-1.3 + PBL, 0, 0)
            elseif Preset4 then
                tRot = CFrame.lookAt(tPos, hrp.Position)
            elseif Preset5 then
                tRot = hrp.CFrame * CFrame.new((i * 3) - (total * 1.6 / 2), 0, 0) * CFrame.Angles(0, 0, 0)
            elseif Preset6 then
                tRot = hrp.CFrame * CFrame.new((i * 3) - (total * 1.6 / 2), 0, 0) * CFrame.Angles(0, math.rad(-180), math.rad(-60))
            elseif Preset7 then
                local rightArm = hrp.Parent:FindFirstChild("Right Arm")
                if rightArm then
                    tRot = rightArm.CFrame * CFrame.new((i * 3) - (total * 1.6 / 2), 0, 0) * CFrame.Angles(0, math.rad(90), 0)
                else
                    tRot = hrp.CFrame * CFrame.new((i * 3) - (total * 1.6 / 2), 0, 0) * CFrame.Angles(0, math.rad(90), 0)
                end
            elseif Preset8 then
                tRot = CFrame.lookAt(tPos, hrp.Position) * CFrame.Angles(-1.3 + PBL/2, 0, 0)
            elseif Preset9 then
                tRot = CFrame.lookAt(tPos, hrp.Position)
            elseif Preset10 then
                tRot = CFrame.lookAt(tPos, hrp.Position) * CFrame.Angles(-1.3 + TiltSensitivity, math.sin(t + i) * 0.3, 0)
            elseif Preset11 then
                tRot = CFrame.lookAt(tPos, hrp.Position) * CFrame.Angles(-1.3 + PBL, math.cos(t*2 + i) * 0.3, 0)
            else
                tRot = CFrame.lookAt(tPos, hrp.Position)
            end

            safePcall(function()
                data.handle.AssemblyLinearVelocity = (netlessEnabled and data.netlessAllowed) and netlessVector or Vector3.zero
                data.handle.AssemblyAngularVelocity = Vector3.zero
                data.alignPos.Position = tPos
                data.alignRot.CFrame   = tRot
            end)
        end
    end
end)

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

if not getgenv().HashHubTeleportScript then
    getgenv().HashHubTeleportScript = readfile("hash.lua")
end

TeleportService.TeleportInitiated:Connect(function()
    task.wait(2)
    loadstring(getgenv().HashHubTeleportScript)()
end)


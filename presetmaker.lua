--[[
    OpenViz Architect - Preset Maker
    A tool for creating and previewing boombox/rotator node presets
    
    Usage: Press P to toggle the editor
    Controls:
    - Click to select parts
    - Ctrl+Click to parent selected part to target rotator
    - Use handles to move/rotate selected parts
]]

-- Services
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Player references
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Configuration
local Config = {
    MESH_ID = "http://www.roblox.com/asset/?id=212302951",
    TEXTURE_ID = "http://www.roblox.com/asset/?id=212303049",
    SCALE = Vector3.new(4, 4, 4),
    VERTEX_COLOR = Vector3.new(1, 1, 1),
    ROTATOR_COLOR = Color3.fromRGB(90, 255, 150),
    EDITOR_Y = 2000,
    GUI_ICONS = {
        PRESET_MAKER = "1283965824",
        ROTATOR_PROPS = "12690726311",
        EXPLORER = "11956055886"
    },
    -- UI Color Scheme - Glassmorphism Theme
    UI = {
        -- Glass effect colors
        GLASS_BG = Color3.fromRGB(10, 10, 15),
        GLASS_SURFACE = Color3.fromRGB(20, 20, 30),
        GLASS_SURFACE_LIGHT = Color3.fromRGB(30, 30, 45),
        
        -- Background colors
        BG_PRIMARY = Color3.fromRGB(8, 8, 12),
        BG_SECONDARY = Color3.fromRGB(15, 15, 22),
        BG_TERTIARY = Color3.fromRGB(22, 22, 32),
        BG_INPUT = Color3.fromRGB(28, 28, 38),
        
        -- Border colors
        BORDER = Color3.fromRGB(50, 50, 70),
        BORDER_LIGHT = Color3.fromRGB(70, 70, 90),
        
        -- Text colors
        TEXT_PRIMARY = Color3.fromRGB(245, 245, 250),
        TEXT_SECONDARY = Color3.fromRGB(163, 163, 185),
        TEXT_MUTED = Color3.fromRGB(100, 100, 120),
        
        -- Button colors
        BTN_PRIMARY = Color3.fromRGB(88, 56, 250),
        BTN_PRIMARY_HOVER = Color3.fromRGB(71, 37, 229),
        BTN_SUCCESS = Color3.fromRGB(16, 185, 129),
        BTN_SUCCESS_HOVER = Color3.fromRGB(5, 150, 105),
        BTN_WARNING = Color3.fromRGB(245, 158, 11),
        BTN_WARNING_HOVER = Color3.fromRGB(217, 119, 6),
        BTN_DANGER = Color3.fromRGB(239, 68, 68),
        BTN_DANGER_HOVER = Color3.fromRGB(220, 38, 38),
        BTN_INFO = Color3.fromRGB(59, 130, 246),
        BTN_INFO_HOVER = Color3.fromRGB(37, 99, 235),
        
        -- Accent colors
        ACCENT = Color3.fromRGB(139, 92, 246),
        ACCENT_GLOW = Color3.fromRGB(167, 139, 250),
        
        -- Selection colors
        SELECTED = Color3.fromRGB(88, 56, 250),
        SELECTED_DIM = Color3.fromRGB(67, 35, 201),
        
        -- Tab colors
        TAB_ACTIVE = Color3.fromRGB(30, 30, 45),
        TAB_INACTIVE = Color3.fromRGB(20, 20, 30),
        
        -- Divider
        DIVIDER = Color3.fromRGB(40, 40, 55),
    }
}

-- State management
local State = {
    isEditing = false,
    isRunning = false,
    selectedPart = nil,
    editorFloor = nil,
    originalPosition = nil,
    lastDistance = 0,
    lastAngle = 0,
    idCounter = 0,
    previewStartTime = 0
}

-- Workspace folders
local Folders = {
    ghosts = Instance.new("Folder", workspace),
    preview = Instance.new("Folder", workspace)
}
Folders.ghosts.Name = "OpenViz_Ghosts"
Folders.preview.Name = "OpenViz_Preview"

-- GUI setup
local Gui = Instance.new("ScreenGui", (gethui and gethui()) or player:WaitForChild("PlayerGui"))
Gui.Name = "OpenViz_Architect"
Gui.Enabled = false

-- UI Layout Containers
local Layout = {
    sidebar = nil,
    toolbar = nil,
    statusbar = nil,
    content = nil
}

-- UI Components
local Components = {
    nodeList = nil,
    propertiesPanel = nil,
    toolsPanel = nil,
    previewPanel = nil
}

-- UI Inputs
local Inputs = {
    presetName = nil,
    moveSnap = nil,
    rotationSnap = nil,
    speed = nil,
    sensitivity = nil
}

-- UI State
local UIState = {
    activeTab = "nodes",
    isPanelCollapsed = false
}

-- Manipulation handles
local Handles = {
    move = Instance.new("Handles", Gui),
    rotate = Instance.new("ArcHandles", Gui)
}
Handles.move.Style = Enum.HandlesStyle.Movement
Handles.move.Color3 = Color3.fromRGB(90, 160, 255)
Handles.rotate.Color3 = Color3.fromRGB(200, 100, 255)

-- ============================================================================
-- UI Component System
-- ============================================================================

local function createGlassFrame(parent, size, position, transparency)
    local frame = Instance.new("Frame", parent)
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = Config.UI.GLASS_SURFACE
    frame.BackgroundTransparency = transparency or 0.3
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Config.UI.BORDER
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    
    return frame
end

local function createDivider(parent, position, size)
    local divider = Instance.new("Frame", parent)
    divider.Size = size or UDim2.new(1, 0, 0, 1)
    divider.Position = position
    divider.BackgroundColor3 = Config.UI.DIVIDER
    divider.BorderSizePixel = 0
    divider.BackgroundTransparency = 0.5
    return divider
end

local function createTabButton(parent, text, tabId, position, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = position
    btn.BackgroundColor3 = Config.UI.TAB_INACTIVE
    btn.Text = text
    btn.TextColor3 = Config.UI.TEXT_SECONDARY
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)
    
    local indicator = Instance.new("Frame", btn)
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 3, 1, 0)
    indicator.Position = UDim2.new(0, 0, 0, 0)
    indicator.BackgroundColor3 = Config.UI.ACCENT
    indicator.BorderSizePixel = 0
    indicator.BackgroundTransparency = 1
    local indCorner = Instance.new("UICorner", indicator)
    indCorner.CornerRadius = UDim.new(0, 2)
    
    local function updateState()
        if UIState.activeTab == tabId then
            btn.BackgroundColor3 = Config.UI.TAB_ACTIVE
            btn.TextColor3 = Config.UI.TEXT_PRIMARY
            indicator.BackgroundTransparency = 0
        else
            btn.BackgroundColor3 = Config.UI.TAB_INACTIVE
            btn.TextColor3 = Config.UI.TEXT_SECONDARY
            indicator.BackgroundTransparency = 1
        end
    end
    
    btn.MouseButton1Click:Connect(function()
        UIState.activeTab = tabId
        updateState()
        if callback then callback() end
    end)
    
    btn.MouseEnter:Connect(function()
        if UIState.activeTab ~= tabId then
            btn.BackgroundColor3 = Config.UI.GLASS_SURFACE_LIGHT
        end
    end)
    
    btn.MouseLeave:Connect(function()
        updateState()
    end)
    
    updateState()
    return btn
end

local function createInputField(parent, text, position, placeholder, width)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(width or 1, 0, 0, 36)
    container.Position = position
    container.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(1, 0, 0, 14)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = placeholder
    label.TextColor3 = Config.UI.TEXT_MUTED
    label.Font = Enum.Font.Gotham
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local box = Instance.new("TextBox", container)
    box.Size = UDim2.new(1, 0, 0, 22)
    box.Position = UDim2.new(0, 0, 1, -22)
    box.Text = text
    box.PlaceholderText = ""
    box.PlaceholderColor3 = Config.UI.TEXT_MUTED
    box.BackgroundColor3 = Config.UI.BG_INPUT
    box.TextColor3 = Config.UI.TEXT_PRIMARY
    box.ClearTextOnFocus = false
    box.Font = Enum.Font.Gotham
    box.TextSize = 12
    box.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner", box)
    corner.CornerRadius = UDim.new(0, 6)
    
    local stroke = Instance.new("UIStroke", box)
    stroke.Color = Config.UI.BORDER
    stroke.Thickness = 1
    stroke.Transparency = 0.7
    
    box.Focused:Connect(function()
        stroke.Color = Config.UI.ACCENT
        stroke.Transparency = 0
    end)
    
    box.FocusLost:Connect(function()
        stroke.Color = Config.UI.BORDER
        stroke.Transparency = 0.7
    end)
    
    return box
end

local function createActionButton(parent, text, position, style, callback, fullWidth)
    local button = Instance.new("TextButton", parent)
    button.Size = UDim2.new(fullWidth and 1 or 0.9, 0, 0, 36)
    button.Position = position
    button.BackgroundColor3 = Config.UI["BTN_" .. style:upper()] or Config.UI.BTN_PRIMARY
    button.Text = text
    button.TextColor3 = Config.UI.TEXT_PRIMARY
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    
    local corner = Instance.new("UICorner", button)
    corner.CornerRadius = UDim.new(0, 8)
    
    local hoverColor = Config.UI["BTN_" .. style:upper() .. "_HOVER"] or Config.UI.BTN_PRIMARY_HOVER
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = hoverColor
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Config.UI["BTN_" .. style:upper()] or Config.UI.BTN_PRIMARY
    end)
    
    button.MouseButton1Click:Connect(callback)
    return button
end

local function createIconButton(parent, iconId, position, size, tooltip, callback)
    local button = Instance.new("ImageButton", parent)
    button.Size = UDim2.new(0, size or 32, 0, size or 32)
    button.Position = position
    button.BackgroundColor3 = Config.UI.GLASS_SURFACE
    button.BackgroundTransparency = 0.5
    button.Image = "rbxassetid://" .. iconId
    button.ImageColor3 = Config.UI.TEXT_SECONDARY
    button.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner", button)
    corner.CornerRadius = UDim.new(0, 6)
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Config.UI.GLASS_SURFACE_LIGHT
        button.ImageColor3 = Config.UI.TEXT_PRIMARY
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Config.UI.GLASS_SURFACE
        button.BackgroundTransparency = 0.5
        button.ImageColor3 = Config.UI.TEXT_SECONDARY
    end)
    
    button.MouseButton1Click:Connect(callback)
    return button
end

-- ============================================================================
-- Node Management Functions
-- ============================================================================

local function findNodeById(id)
    for _, node in ipairs(Folders.ghosts:GetChildren()) do
        if node:GetAttribute("ID") == id then
            return node
        end
    end
    return nil
end

local function getParentWorldCFrame(node)
    local parentId = node:GetAttribute("ParentID")
    
    if parentId == "HRP" then
        local character = player.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        return humanoidRootPart and humanoidRootPart.CFrame or CFrame.new()
    end
    
    local parentNode = findNodeById(parentId)
    return parentNode and parentNode.CFrame or CFrame.new()
end

local function updateRelativeOffsets()
    for _, node in ipairs(Folders.ghosts:GetChildren()) do
        local relativeCFrame = getParentWorldCFrame(node):ToObjectSpace(node.CFrame)
        local rotX, rotY, rotZ = relativeCFrame:ToEulerAnglesXYZ()
        
        node:SetAttribute("RelPosX", relativeCFrame.Position.X)
        node:SetAttribute("RelPosY", relativeCFrame.Position.Y)
        node:SetAttribute("RelPosZ", relativeCFrame.Position.Z)
        node:SetAttribute("RelRotX", rotX)
        node:SetAttribute("RelRotY", rotY)
        node:SetAttribute("RelRotZ", rotZ)
    end
end

local function drawConnectionBeams()
    -- Clear existing beams
    for _, node in ipairs(Folders.ghosts:GetChildren()) do
        local beam = node:FindFirstChild("LinkBeam")
        local att0 = node:FindFirstChild("Att0")
        local att1 = node:FindFirstChild("Att1")
        
        if beam then beam:Destroy() end
        if att0 then att0:Destroy() end
        if att1 then att1:Destroy() end
    end
    
    -- Create new beams
    for _, node in ipairs(Folders.ghosts:GetChildren()) do
        local parentNode = findNodeById(node:GetAttribute("ParentID"))
        
        if parentNode then
            local attachment0 = Instance.new("Attachment", node)
            attachment0.Name = "Att0"
            
            local attachment1 = Instance.new("Attachment", parentNode)
            attachment1.Name = "Att1"
            
            local beam = Instance.new("Beam", node)
            beam.Name = "LinkBeam"
            beam.Attachment0 = attachment0
            beam.Attachment1 = attachment1
            beam.FaceCamera = true
            beam.Width0 = 0.1
            beam.Width1 = 0.1
            beam.Color = ColorSequence.new(Color3.fromRGB(90, 160, 255))
            beam.Transparency = NumberSequence.new(0.5)
        end
    end
end

-- ============================================================================
-- Node List Component
-- ============================================================================

local nodeListScrollFrame = nil
local nodeListLayout = nil

local function refreshNodeList()
    if not nodeListScrollFrame then return end
    
    for _, child in ipairs(nodeListScrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local count = 0
    for _, node in ipairs(Folders.ghosts:GetChildren()) do
        local nodeType = node:GetAttribute("Type")
        local button = Instance.new("TextButton", nodeListScrollFrame)
        
        button.Size = UDim2.new(1, -12, 0, 32)
        button.BackgroundColor3 = (node == State.selectedPart) 
            and Config.UI.SELECTED 
            or Config.UI.BG_TERTIARY
        button.BackgroundTransparency = (node == State.selectedPart) and 0 or 0.5
        button.Text = "  " .. nodeType .. "  [" .. node:GetAttribute("ID") .. "]"
        button.TextColor3 = (nodeType == "Rotator") 
            and Config.ROTATOR_COLOR 
            or Config.UI.TEXT_SECONDARY
        button.Font = Enum.Font.GothamMedium
        button.TextSize = 12
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.BorderSizePixel = 0
        button.AutoButtonColor = false
        
        local corner = Instance.new("UICorner", button)
        corner.CornerRadius = UDim.new(0, 6)
        
        button.MouseEnter:Connect(function()
            if node ~= State.selectedPart then
                button.BackgroundColor3 = Config.UI.GLASS_SURFACE_LIGHT
                button.BackgroundTransparency = 0.3
            end
        end)
        
        button.MouseLeave:Connect(function()
            if node ~= State.selectedPart then
                button.BackgroundColor3 = Config.UI.BG_TERTIARY
                button.BackgroundTransparency = 0.5
            end
        end)
        
        button.MouseButton1Click:Connect(function()
            _G.SelectPart(node)
        end)
        
        count = count + 1
    end
    
    nodeListScrollFrame.CanvasSize = UDim2.new(0, 0, 0, count * 36)
end

-- ============================================================================
-- Selection Functions
-- ============================================================================

_G.SelectPart = function(part)
    if State.isRunning then return end
    
    State.selectedPart = part
    Handles.move.Adornee = part
    Handles.rotate.Adornee = part
    
    if part and part:GetAttribute("Type") == "Rotator" then
        Components.propertiesPanel.Visible = true
        Inputs.speed.Text = tostring(part:GetAttribute("Speed") or 0)
        Inputs.sensitivity.Text = tostring(part:GetAttribute("Sens") or 0)
    else
        Components.propertiesPanel.Visible = false
    end
    
    refreshNodeList()
end

-- ============================================================================
-- Node Creation Functions
-- ============================================================================

local function createNode(nodeType, startCFrame)
    State.idCounter = State.idCounter + 1
    
    local part = Instance.new("Part", Folders.ghosts)
    part.Size = Vector3.new(1, 1, 1)
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 0.4
    part.CFrame = startCFrame or player.Character.HumanoidRootPart.CFrame
    
    part:SetAttribute("Type", nodeType)
    part:SetAttribute("ID", tostring(State.idCounter))
    part:SetAttribute("ParentID", "HRP")
    
    if nodeType == "Boombox" then
        local mesh = Instance.new("SpecialMesh", part)
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = Config.MESH_ID
        mesh.TextureId = Config.TEXTURE_ID
        mesh.Scale = Config.SCALE
        mesh.VertexColor = Config.VERTEX_COLOR
    elseif nodeType == "Rotator" then
        part.Shape = Enum.PartType.Block
        part.Size = Vector3.new(1.5, 1.5, 1.5)
        part.Material = Enum.Material.Neon
        part.Color = Config.ROTATOR_COLOR
        part:SetAttribute("Speed", 2)
        part:SetAttribute("Sens", 50)
    end
    
    updateRelativeOffsets()
    drawConnectionBeams()
    refreshNodeList()
    _G.SelectPart(part)
    
    return part
end

-- ============================================================================
-- Simulation Functions
-- ============================================================================

local function getSimulatedCFrame(nodeId, time, memo)
    if memo[nodeId] then
        return memo[nodeId]
    end
    
    if nodeId == "HRP" then
        local character = player.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        local cframe = humanoidRootPart and humanoidRootPart.CFrame or CFrame.new()
        memo[nodeId] = cframe
        return cframe
    end
    
    local node = findNodeById(nodeId)
    if not node then
        memo[nodeId] = CFrame.new()
        return CFrame.new()
    end
    
    local parentCFrame = getSimulatedCFrame(node:GetAttribute("ParentID"), time, memo)
    local relativeCFrame = CFrame.new(
        node:GetAttribute("RelPosX"),
        node:GetAttribute("RelPosY"),
        node:GetAttribute("RelPosZ")
    ) * CFrame.Angles(
        node:GetAttribute("RelRotX"),
        node:GetAttribute("RelRotY"),
        node:GetAttribute("RelRotZ")
    )
    
    local worldCFrame
    if node:GetAttribute("Type") == "Rotator" then
        local speed = node:GetAttribute("Speed") or 2
        worldCFrame = parentCFrame * relativeCFrame * CFrame.Angles(0, time * speed, 0)
    else
        worldCFrame = parentCFrame * relativeCFrame
    end
    
    memo[nodeId] = worldCFrame
    return worldCFrame
end

-- ============================================================================
-- Editor Toggle Functions
-- ============================================================================

local function toggleEditor(enabled)
    State.isEditing = enabled
    Gui.Enabled = enabled
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    if enabled then
        -- Enable editor mode
        State.originalPosition = humanoidRootPart.CFrame
        humanoidRootPart.CFrame = CFrame.new(0, Config.EDITOR_Y, 0)
        humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        
        if humanoid then
            humanoid.WalkSpeed = 0
        end
        
        -- Create editor floor
        State.editorFloor = Instance.new("Part", workspace)
        State.editorFloor.Size = Vector3.new(400, 1, 400)
        State.editorFloor.Position = Vector3.new(0, Config.EDITOR_Y - 5, 0)
        State.editorFloor.Anchored = true
        State.editorFloor.Transparency = 0.8
        State.editorFloor.Color = Color3.fromRGB(20, 20, 25)
        State.editorFloor.Material = Enum.Material.Neon
        
        updateRelativeOffsets()
        drawConnectionBeams()
    else
        -- Disable editor mode
        if State.editorFloor then
            State.editorFloor:Destroy()
            State.editorFloor = nil
        end
        
        Folders.ghosts:ClearAllChildren()
        Folders.preview:ClearAllChildren()
        
        State.isRunning = false
        _G.SelectPart(nil)
        
        if humanoid then
            humanoid.WalkSpeed = 16
        end
        
        if State.originalPosition then
            humanoidRootPart.CFrame = State.originalPosition
        end
    end
end

-- ============================================================================
-- UI Event Handlers
-- ============================================================================

local function setupUIEventHandlers()
    -- Property input handlers
    Inputs.speed.FocusLost:Connect(function()
        if State.selectedPart then
            State.selectedPart:SetAttribute("Speed", tonumber(Inputs.speed.Text) or 0)
        end
    end)
    
    Inputs.sensitivity.FocusLost:Connect(function()
        if State.selectedPart then
            State.selectedPart:SetAttribute("Sens", tonumber(Inputs.sensitivity.Text) or 0)
        end
    end)
    
    -- Handle drag start
    Handles.move.MouseButton1Down:Connect(function()
        State.lastDistance = 0
    end)
    
    Handles.rotate.MouseButton1Down:Connect(function()
        State.lastAngle = 0
    end)
    
    -- Handle movement
    Handles.move.MouseDrag:Connect(function(face, distance)
        if not State.selectedPart then return end
        
        local snap = tonumber(Inputs.moveSnap.Text) or 0
        local delta = distance - State.lastDistance
        
        if snap > 0 then
            local snapped = math.floor(distance / snap) * snap
            delta = snapped - State.lastDistance
            if delta == 0 then return end
            State.lastDistance = snapped
        else
            State.lastDistance = distance
        end
        
        State.selectedPart.CFrame = State.selectedPart.CFrame * CFrame.new(Vector3.FromNormalId(face) * delta)
        updateRelativeOffsets()
        drawConnectionBeams()
    end)
    
    -- Handle rotation
    Handles.rotate.MouseDrag:Connect(function(axis, angle)
        if not State.selectedPart then return end
        
        local snap = tonumber(Inputs.rotationSnap.Text) or 0
        local delta = angle - State.lastAngle
        
        if snap > 0 then
            local radSnap = math.rad(snap)
            local snapped = math.floor(angle / radSnap) * radSnap
            delta = snapped - State.lastAngle
            if delta == 0 then return end
            State.lastAngle = snapped
        else
            State.lastAngle = angle
        end
        
        State.selectedPart.CFrame = State.selectedPart.CFrame * CFrame.fromAxisAngle(Vector3.FromAxis(axis), delta)
        updateRelativeOffsets()
    end)
end

-- ============================================================================
-- Button Callbacks
-- ============================================================================

local function setupButtonCallbacks()
    local toolsParent = Components.toolsPanel
    local yOffset = 0
    
    -- Add Rotator button
    createActionButton(toolsParent, "+ Rotator", UDim2.new(0, 10, 0, yOffset), "success", function()
        createNode("Rotator")
    end, true)
    yOffset = yOffset + 44
    
    -- Add Boombox at part button
    createActionButton(toolsParent, "+ Boombox", UDim2.new(0, 10, 0, yOffset), "primary", function()
        if State.selectedPart and not State.isRunning then
            local newNode = createNode("Boombox", State.selectedPart.CFrame)
            newNode:SetAttribute("ParentID", State.selectedPart:GetAttribute("ParentID"))
            updateRelativeOffsets()
            drawConnectionBeams()
        end
    end, true)
    yOffset = yOffset + 44
    
    -- Copy Selected button
    createActionButton(toolsParent, "Copy Selected", UDim2.new(0, 10, 0, yOffset), "warning", function()
        if not State.selectedPart or State.isRunning then return end
        
        local selectedType = State.selectedPart:GetAttribute("Type")
        local newNode = createNode(selectedType, State.selectedPart.CFrame)
        newNode:SetAttribute("ParentID", "HRP")
        
        if selectedType == "Rotator" then
            newNode:SetAttribute("Speed", State.selectedPart:GetAttribute("Speed"))
            newNode:SetAttribute("Sens", State.selectedPart:GetAttribute("Sens"))
            
            local oldId = State.selectedPart:GetAttribute("ID")
            local newId = newNode:GetAttribute("ID")
            
            for _, child in ipairs(Folders.ghosts:GetChildren()) do
                if child:GetAttribute("ParentID") == oldId then
                    local copiedChild = createNode(child:GetAttribute("Type"), child.CFrame)
                    copiedChild:SetAttribute("ParentID", newId)
                end
            end
        end
        
        updateRelativeOffsets()
        drawConnectionBeams()
    end, true)
    yOffset = yOffset + 44
    
    -- Delete Selected button
    createActionButton(toolsParent, "Delete Selected", UDim2.new(0, 10, 0, yOffset), "danger", function()
        if not State.selectedPart or State.isRunning then return end
        
        local deleteId = State.selectedPart:GetAttribute("ID")
        
        for _, child in ipairs(Folders.ghosts:GetChildren()) do
            if child:GetAttribute("ParentID") == deleteId then
                child:Destroy()
            end
        end
        
        State.selectedPart:Destroy()
        _G.SelectPart(nil)
        drawConnectionBeams()
        refreshNodeList()
    end, true)
    yOffset = yOffset + 54
    
    createDivider(toolsParent, UDim2.new(0, 10, 0, yOffset), UDim2.new(1, -20, 0, 1))
    yOffset = yOffset + 14
    
    -- Toggle Preview button
    createActionButton(toolsParent, "Toggle Preview", UDim2.new(0, 10, 0, yOffset), "info", function()
        State.isRunning = not State.isRunning
        _G.SelectPart(nil)
        
        if State.isRunning then
            State.previewStartTime = tick()
            Handles.move.Adornee = nil
            Handles.rotate.Adornee = nil
            
            for _, part in ipairs(Folders.ghosts:GetChildren()) do
                part.Transparency = 1
            end
            
            Folders.preview:ClearAllChildren()
            for _, ghost in ipairs(Folders.ghosts:GetChildren()) do
                if ghost:GetAttribute("Type") == "Boombox" then
                    local preview = Instance.new("Part", Folders.preview)
                    preview.Anchored = true
                    preview.CanCollide = false
                    preview.Size = Vector3.new(1, 1, 1)
                    preview:SetAttribute("SourceID", ghost:GetAttribute("ID"))
                    
                    local mesh = Instance.new("SpecialMesh", preview)
                    mesh.MeshType = Enum.MeshType.FileMesh
                    mesh.MeshId = Config.MESH_ID
                    mesh.TextureId = Config.TEXTURE_ID
                    mesh.Scale = Config.SCALE
                    mesh.VertexColor = Config.VERTEX_COLOR
                end
            end
        else
            Folders.preview:ClearAllChildren()
            
            for _, part in ipairs(Folders.ghosts:GetChildren()) do
                part.Transparency = 0.4
            end
            
            drawConnectionBeams()
        end
    end, true)
    yOffset = yOffset + 44
    
    -- Save Preset button
    createActionButton(toolsParent, "Save Preset", UDim2.new(0, 10, 0, yOffset), "success", function()
        updateRelativeOffsets()
        
        local data = {
            Name = Inputs.presetName.Text,
            Type = "NodeGraph",
            Nodes = {},
            Tools = {}
        }
        
        for _, part in ipairs(Folders.ghosts:GetChildren()) do
            local item = {
                ID = part:GetAttribute("ID"),
                ParentID = part:GetAttribute("ParentID"),
                pos = {
                    x = part:GetAttribute("RelPosX"),
                    y = part:GetAttribute("RelPosY"),
                    z = part:GetAttribute("RelPosZ")
                },
                rot = {
                    x = part:GetAttribute("RelRotX"),
                    y = part:GetAttribute("RelRotY"),
                    z = part:GetAttribute("RelRotZ")
                }
            }
            
            if part:GetAttribute("Type") == "Rotator" then
                item.Speed = part:GetAttribute("Speed")
                item.Sens = part:GetAttribute("Sens")
                table.insert(data.Nodes, item)
            else
                table.insert(data.Tools, item)
            end
        end
        
        if writefile then
            if not isfolder("OpenViz") then
                makefolder("OpenViz")
            end
            writefile("OpenViz/" .. Inputs.presetName.Text .. ".json", HttpService:JSONEncode(data))
            print("Architect: Saved → OpenViz/" .. Inputs.presetName.Text .. ".json")
        end
    end, true)
end

-- ============================================================================
-- Input Handling
-- ============================================================================

local function setupInputHandling()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        -- Toggle editor with P key
        if input.KeyCode == Enum.KeyCode.P then
            toggleEditor(not State.isEditing)
            return
        end
        
        if not State.isEditing or State.isRunning then return end
        
        -- Handle mouse clicks
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local target = mouse.Target
            
            if target and target.Parent == Folders.ghosts then
                -- Ctrl+Click to parent selected part to target rotator
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) 
                    and State.selectedPart 
                    and State.selectedPart ~= target 
                    and target:GetAttribute("Type") == "Rotator" then
                    State.selectedPart:SetAttribute("ParentID", target:GetAttribute("ID"))
                    updateRelativeOffsets()
                    drawConnectionBeams()
                else
                    _G.SelectPart(target)
                end
            else
                _G.SelectPart(nil)
            end
        end
    end)
end

-- ============================================================================
-- Simulation Loop
-- ============================================================================

local function setupSimulationLoop()
    RunService.Heartbeat:Connect(function()
        if not State.isRunning then return end
        
        local time = tick() - State.previewStartTime
        local memo = {}
        
        for _, previewPart in ipairs(Folders.preview:GetChildren()) do
            local sourceId = previewPart:GetAttribute("SourceID")
            if sourceId then
                previewPart.CFrame = getSimulatedCFrame(sourceId, time, memo)
            end
        end
    end)
end

-- ============================================================================
-- UI Layout Initialization
-- ============================================================================

local function buildSidebarLayout()
    -- Main sidebar container
    Layout.sidebar = createGlassFrame(Gui, UDim2.new(0, 280, 1, 0), UDim2.new(0, 0, 0, 0), 0.1)
    
    -- Header/Logo area
    local header = Instance.new("Frame", Layout.sidebar)
    header.Size = UDim2.new(1, 0, 0, 60)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Config.UI.GLASS_SURFACE_LIGHT
    header.BackgroundTransparency = 0.5
    header.BorderSizePixel = 0
    local headerCorner = Instance.new("UICorner", header)
    headerCorner.CornerRadius = UDim.new(0, 12)
    
    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "OpenViz"
    title.TextColor3 = Config.UI.ACCENT
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Center
    
    -- Tab navigation
    local tabsContainer = Instance.new("Frame", Layout.sidebar)
    tabsContainer.Size = UDim2.new(1, 0, 0, 50)
    tabsContainer.Position = UDim2.new(0, 0, 0, 65)
    tabsContainer.BackgroundTransparency = 1
    
    createTabButton(tabsContainer, "Nodes", "nodes", UDim2.new(0, 10, 0, 0), function()
        Components.nodeList.Visible = true
        Components.toolsPanel.Visible = false
    end)
    
    createTabButton(tabsContainer, "Tools", "tools", UDim2.new(0, 10, 0, 42), function()
        Components.nodeList.Visible = false
        Components.toolsPanel.Visible = true
    end)
    
    -- Node List Panel
    Components.nodeList = createGlassFrame(Layout.sidebar, UDim2.new(1, -20, 1, -230), UDim2.new(0, 10, 0, 120), 0.2)
    
    nodeListScrollFrame = Instance.new("ScrollingFrame", Components.nodeList)
    nodeListScrollFrame.Size = UDim2.new(1, 0, 1, 0)
    nodeListScrollFrame.Position = UDim2.new(0, 0, 0, 0)
    nodeListScrollFrame.BackgroundTransparency = 1
    nodeListScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    nodeListScrollFrame.ScrollBarThickness = 3
    nodeListScrollFrame.ScrollBarImageColor3 = Config.UI.BORDER
    
    nodeListLayout = Instance.new("UIListLayout", nodeListScrollFrame)
    nodeListLayout.Padding = UDim.new(0, 4)
    
    -- Tools Panel (initially hidden)
    Components.toolsPanel = createGlassFrame(Layout.sidebar, UDim2.new(1, -20, 1, -230), UDim2.new(0, 10, 0, 120), 0.2)
    Components.toolsPanel.Visible = false
    
    -- Properties Panel (for rotator settings)
    Components.propertiesPanel = createGlassFrame(Layout.sidebar, UDim2.new(1, -20, 0, 100), UDim2.new(0, 10, 1, -110), 0.2)
    Components.propertiesPanel.Visible = false
    
    -- Status bar
    Layout.statusbar = Instance.new("Frame", Layout.sidebar)
    Layout.statusbar.Size = UDim2.new(1, 0, 0, 40)
    Layout.statusbar.Position = UDim2.new(0, 0, 1, -40)
    Layout.statusbar.BackgroundColor3 = Config.UI.GLASS_SURFACE_LIGHT
    Layout.statusbar.BackgroundTransparency = 0.5
    Layout.statusbar.BorderSizePixel = 0
    local statusCorner = Instance.new("UICorner", Layout.statusbar)
    statusCorner.CornerRadius = UDim.new(0, 0, 0, 0, 0, 12, 0, 12)
    
    local statusText = Instance.new("TextLabel", Layout.statusbar)
    statusText.Size = UDim2.new(1, -10, 1, 0)
    statusText.Position = UDim2.new(0, 10, 0, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Press P to toggle editor"
    statusText.TextColor3 = Config.UI.TEXT_MUTED
    statusText.Font = Enum.Font.Gotham
    statusText.TextSize = 11
    statusText.TextXAlignment = Enum.TextXAlignment.Left
end

local function setupPropertyInputs()
    local parent = Components.propertiesPanel
    local yOffset = 10
    
    local titleLabel = Instance.new("TextLabel", parent)
    titleLabel.Size = UDim2.new(1, 0, 0, 20)
    titleLabel.Position = UDim2.new(0, 10, 0, yOffset)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Rotator Properties"
    titleLabel.TextColor3 = Config.UI.TEXT_PRIMARY
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    yOffset = yOffset + 30
    
    Inputs.speed = createInputField(parent, "", UDim2.new(0, 10, 0, yOffset), "Rotation Speed", 1)
    yOffset = yOffset + 42
    
    Inputs.sensitivity = createInputField(parent, "", UDim2.new(0, 10, 0, yOffset), "Music Sensitivity", 1)
end

local function setupToolInputs()
    local parent = Components.toolsPanel
    local yOffset = 10
    
    Inputs.presetName = createInputField(parent, "", UDim2.new(0, 10, 0, yOffset), "Preset Name", 1)
    yOffset = yOffset + 42
    
    createDivider(parent, UDim2.new(0, 10, 0, yOffset), UDim2.new(1, -20, 0, 1))
    yOffset = yOffset + 14
    
    Inputs.moveSnap = createInputField(parent, "", UDim2.new(0, 10, 0, yOffset), "Move Snap (Studs)", 1)
    yOffset = yOffset + 42
    
    Inputs.rotationSnap = createInputField(parent, "", UDim2.new(0, 10, 0, yOffset), "Rotation Snap (Deg)", 1)
    yOffset = yOffset + 54
end

local function initialize()
    buildSidebarLayout()
    setupPropertyInputs()
    setupToolInputs()
    
    setupUIEventHandlers()
    setupButtonCallbacks()
    setupInputHandling()
    setupSimulationLoop()
    
    print("OpenViz Architect initialized. Press P to start.")
end

initialize()

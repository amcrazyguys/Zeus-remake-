local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

if CoreGui:FindFirstChild("DeltaPC_UI") then
    CoreGui.DeltaPC_UI:Destroy()
end

local Config = {
    EspActive = false,
    SkinChangerActive = false,
    NoRecoil = false,
    FlyActive = false,
    FlySpeed = 60,
    TargetSkinColor = Color3.fromRGB(255, 0, 128),
    TargetMaterial = Enum.Material.ForceField
}

local EspObjects = {}
local ActiveConnections = {}

local DeltaUI = Instance.new("ScreenGui")
DeltaUI.Name = "DeltaPC_UI"
DeltaUI.Parent = CoreGui
DeltaUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 460, 0, 360)
MainFrame.Position = UDim2.new(0.5, -230, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 16, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = DeltaUI

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(147, 51, 234)
UIStroke.Thickness = 1.2
UIStroke.Parent = MainFrame

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 50, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(12, 10, 16)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, 0, 0, 50)
Logo.BackgroundTransparency = 1
Logo.Text = "Δ"
Logo.TextColor3 = Color3.fromRGB(147, 51, 234)
Logo.TextSize = 24
Logo.Font = Enum.Font.SourceSansBold
Logo.Parent = Sidebar

local ScrollContent = Instance.new("ScrollingFrame")
ScrollContent.Size = UDim2.new(1, -65, 1, -20)
ScrollContent.Position = UDim2.new(0, 55, 0, 10)
ScrollContent.BackgroundTransparency = 1
ScrollContent.BorderSizePixel = 0
ScrollContent.ScrollBarThickness = 2
ScrollContent.CanvasSize = UDim2.new(0, 0, 0, 400)
ScrollContent.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ScrollContent

local Toggles = {}

local function createToggle(name, configKey, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 35)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = ScrollContent

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(0.7, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = name
    TextLabel.TextColor3 = Color3.fromRGB(160, 155, 175)
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.TextSize = 13
    TextLabel.Font = Enum.Font.Code
    TextLabel.Parent = ToggleFrame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 42, 0, 20)
    Button.Position = UDim2.new(0.76, 0, 0.2, 0)
    Button.BackgroundColor3 = Color3.fromRGB(30, 24, 40)
    Button.Text = ""
    Button.BorderSizePixel = 0
    Button.Parent = ToggleFrame

    Toggles[configKey] = Button

    local function updateVisual(state)
        local targetColor = state and Color3.fromRGB(147, 51, 234) or Color3.fromRGB(30, 24, 40)
        TweenService:Create(Button, TweenInfo.new(0.15), {BackgroundColor3 = targetColor}):Play()
    end

    Button.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        if callback then callback(Config[configKey]) end
        updateVisual(Config[configKey])
    end)

    return updateVisual
end

local function applyZeroLagSkin(tool)
    if not Config.SkinChangerActive or not tool:IsA("Tool") then return end
    for _, part in ipairs(tool:GetDescendants()) do
        if part:IsA("MeshPart") or part:IsA("BasePart") or part:IsA("SpecialMesh") then
            if part:IsA("SpecialMesh") then
                part.TextureId = "" 
            else
                part.Material = Config.TargetMaterial
                part.Color = Config.TargetSkinColor
                part.Reflectance = 0
            end
        end
    end
end

local function setupCharacterSkinListener(char)
    if not char then return end
    local conn = char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            task.defer(applyZeroLagSkin, child)
        end
    end)
    table.insert(ActiveConnections, conn)
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then
            task.defer(applyZeroLagSkin, child)
        end
    end
end

local updateSkinVisual = createToggle("Visual Skin Changer", "SkinChangerActive", function(val)
    if val and LocalPlayer.Character then
        setupCharacterSkinListener(LocalPlayer.Character)
    else
        for _, conn in ipairs(ActiveConnections) do conn:Disconnect() end
        table.clear(ActiveConnections)
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    if Config.SkinChangerActive then
        task.defer(setupCharacterSkinListener, char)
    end
end)

local updateEspVisual = createToggle("Player ESP Boxes", "EspActive", function(val)
    if not val then
        for _, v in pairs(EspObjects) do if v.Box then v.Box:Destroy() end end
        table.clear(EspObjects)
    end
end)

local updateRecoilVisual = createToggle("Rage No Recoil", "NoRecoil")
local updateFlyVisual = createToggle("Rage Fly Mode", "FlyActive")

local ConfigFrame = Instance.new("Frame")
ConfigFrame.Size = UDim2.new(1, -10, 0, 45)
ConfigFrame.BackgroundTransparency = 1
ConfigFrame.Parent = ScrollContent

local ConfigLabel = Instance.new("TextLabel")
ConfigLabel.Size = UDim2.new(0.3, 0, 1, 0)
ConfigLabel.BackgroundTransparency = 1
ConfigLabel.Text = "PRESETS:"
ConfigLabel.TextColor3 = Color3.fromRGB(147, 51, 234)
ConfigLabel.TextXAlignment = Enum.TextXAlignment.Left
ConfigLabel.TextSize = 13
ConfigLabel.Font = Enum.Font.Code
ConfigLabel.Parent = ConfigFrame

local function createConfigButton(name, posX, loadFunc)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 85, 0, 26)
    Btn.Position = UDim2.new(0.35, posX, 0.2, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(30, 24, 40)
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 12
    Btn.Font = Enum.Font.SourceSansBold
    Btn.BorderSizePixel = 0
    Btn.Parent = ConfigFrame

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = Btn

    Btn.MouseButton1Click:Connect(loadFunc)
end

local function setConfigState(esp, skin, recoil, fly)
    Config.EspActive = esp
    Config.SkinChangerActive = skin
    Config.NoRecoil = recoil
    Config.FlyActive = fly

    updateEspVisual(esp)
    updateSkinVisual(skin)
    updateRecoilVisual(recoil)
    updateFlyVisual(fly)

    if skin and LocalPlayer.Character then
        setupCharacterSkinListener(LocalPlayer.Character)
    else
        for _, conn in ipairs(ActiveConnections) do conn:Disconnect() end
        table.clear(ActiveConnections)
    end
end

createConfigButton("LEGIT", 0, function()
    setConfigState(true, true, false, false)
end)

createConfigButton("RAGE", 95, function()
    setConfigState(true, true, true, true)
end)

local function createEsp(player)
    if EspObjects[player] then return end
    local Box = Instance.new("BoxHandleAdornment")
    Box.Size = Vector3.new(3.8, 5.2, 1)
    Box.AlwaysOnTop = true
    Box.ZIndex = 4
    Box.Translucency = 0.65
    Box.Color3 = Color3.fromRGB(147, 51, 234)
    Box.Adornee = nil
    Box.Parent = CoreGui
    EspObjects[player] = { Box = Box }
end

RunService.RenderStepped:Connect(function()
    if Config.EspActive then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                
                if root and humanoid and humanoid.Health > 0 then
                    if not EspObjects[player] then createEsp(player) end
                    local esp = EspObjects[player]
                    if esp and esp.Box then
                        esp.Box.Adornee = player.Character
                    end
                else
                    if EspObjects[player] then EspObjects[player].Box.Adornee = nil end
                end
            end
        end
    end

    if Config.NoRecoil and LocalPlayer.Character then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v.Name == "WeaponConfig" and v:IsA("ModuleScript") then
                local success, weaponData = pcall(require, v)
                if success and type(weaponData) == "table" then
                    weaponData.Recoil = 0
                    weaponData.Spread = 0
                    weaponData.MinSpread = 0
                    weaponData.MaxSpread = 0
                end
            end
        end
    end

    if Config.FlyActive and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if root and humanoid then
            humanoid.PlatformStand = true
            local moveDirection = humanoid.MoveDirection
            local cameraCFrame = Camera.CFrame
            local flyVector = Vector3.new(0, 0, 0)
            
            if moveDirection.Magnitude > 0 then
                flyVector = cameraCFrame:VectorToWorldSpace(Vector3.new(
                    UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or (UserInputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0),
                    0,
                    UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or (UserInputService:IsKeyDown(Enum.KeyCode.W) and -1 or 0)
            if flyVector.Magnitude > 0 then
                root.Velocity = flyVector.Unit * Config.FlySpeed
            else
                root.Velocity = Vector3.new(0, 0, 0)
            end
        end
    else
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.PlatformStand then
                humanoid.PlatformStand = false
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)


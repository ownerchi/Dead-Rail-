local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local KillAuraRange = 15
local AutoPickupRange = 20
local FlySpeed = 50

local KillAuraEnabled = false
local AutoPickupEnabled = false
local FlyEnabled = false
local GodModeEnabled = false
local AimbotEnabled = false

local flying = false
local bodyVelocity, bodyGyro

local function startFly()
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0,0,0)
    bodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
    bodyVelocity.Parent = hrp
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.Parent = hrp
    flying = true
end

local function stopFly()
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    flying = false
end

local function getNearestTarget(range)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = character.HumanoidRootPart
    local nearest = nil
    local nearestDist = math.huge
    for _, npc in pairs(workspace:GetChildren()) do
        if npc:IsA("Model") and npc ~= character and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
            local npcHrp = npc:FindFirstChild("HumanoidRootPart")
            if npcHrp then
                local dist = (npcHrp.Position - hrp.Position).Magnitude
                if dist < range and dist < nearestDist then
                    nearest = npc
                    nearestDist = dist
                end
            end
        end
    end
    return nearest
end

local function attackTarget(target)
    if not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 then return end
    local character = LocalPlayer.Character
    if not character then return end
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local targetHrp = target:FindFirstChild("HumanoidRootPart")
        if hrp and targetHrp then
            hrp.CFrame = CFrame.new(hrp.Position, targetHrp.Position)
        end
        pcall(function() tool:Activate() end)
    end
end

local function autoPickup()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart
    for _, item in pairs(workspace:GetChildren()) do
        if item:IsA("BasePart") and (item.Name:lower():find("tool") or item.Name:lower():find("item")) then
            local dist = (item.Position - hrp.Position).Magnitude
            if dist < AutoPickupRange then
                pcall(function()
                    item.CFrame = hrp.CFrame
                end)
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if GodModeEnabled then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.Health = character.Humanoid.MaxHealth
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if AimbotEnabled then
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        local target = getNearestTarget(50)
        if target then
            local hrp = character.HumanoidRootPart
            local targetHrp = target:FindFirstChild("HumanoidRootPart")
            if targetHrp then
                hrp.CFrame = CFrame.new(hrp.Position, targetHrp.Position)
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if KillAuraEnabled then
        local target = getNearestTarget(KillAuraRange)
        if target then attackTarget(target) end
    end
    if AutoPickupEnabled then
        autoPickup()
    end
    if FlyEnabled and flying then
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp and bodyVelocity and bodyGyro then
            local cam = workspace.CurrentCamera
            local moveDir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
            moveDir = Vector3.new(moveDir.X,0,moveDir.Z).Unit
            if moveDir.Magnitude > 0 then
                bodyVelocity.Velocity = moveDir * FlySpeed + Vector3.new(0,0,0)
                bodyGyro.CFrame = cam.CFrame
            else
                bodyVelocity.Velocity = Vector3.new(0,0,0)
            end
        end
    end
end)

local function createGui()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UltraHubGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 280)
    frame.Position = UDim2.new(0, 20, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    frame.Active = true
    frame.Draggable = true
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "Ultra Hub Dead Rail"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Parent = frame
    local function createToggle(text, y, getState, setState)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.6, 0, 0, 30)
        lbl.Position = UDim2.new(0, 10, 0, y)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 18
        lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.35, 0, 0, 30)
        btn.Position = UDim2.new(0.65, 0, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 18
        btn.Text = "OFF"
        btn.Parent = frame
        local function updateBtn()
            if getState() then
                btn.Text = "ON"
                btn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            else
                btn.Text = "OFF"
                btn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
            end
        end
        updateBtn()
        btn.MouseButton1Click:Connect(function()
            setState(not getState())
            updateBtn()
        end)
    end
    createToggle("Kill Aura", 40, function() return KillAuraEnabled end, function(v) KillAuraEnabled = v end)
    createToggle("Auto Pickup", 80, function() return AutoPickupEnabled end, function(v) AutoPickupEnabled = v end)
    createToggle("Fly", 120, function() return FlyEnabled end, function(v)
        FlyEnabled = v
        if FlyEnabled then startFly() else stopFly() end
    end)
    createToggle("God Mode", 160, function() return GodModeEnabled end, function(v) GodModeEnabled = v end)
    createToggle("Aimbot", 200, function() return AimbotEnabled end, function(v) AimbotEnabled = v end)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 40, 0, 30)
    closeBtn.Position = UDim2.new(1, -45, 0, 2)
    closeBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.Text = "X"
    closeBtn.Parent = frame
    closeBtn.MouseButton1Click:Connect(function()
        screenGui.Enabled = not screenGui.Enabled
    end)
end

createGui()

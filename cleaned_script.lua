-- ══════════════════════════════════════════════════════
--   MINIMAL MENU | Fly + Noclip + Магнит + Авто-урон
--   Iron Soul Dungeon | PC + Mobile | FIXED
-- ══════════════════════════════════════════════════════

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local flyEnabled    = false
local noclipEnabled = false
local magnetEnabled = false
local flySpeed      = 50
local magnetRadius  = 50
local flyConn, noclipConn, magnetConn, autoHitConn

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MinimalMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 510)
Frame.Position = UDim2.new(0.5, -130, 0.5, -255)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "✦  MENU"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.Font = Enum.Font.ArialBold  -- ИСПРАВЛЕНО
Title.TextSize = 15
Title.Parent = Frame

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0.85, 0, 0, 1)
Divider.Position = UDim2.new(0.075, 0, 0, 42)
Divider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Divider.BorderSizePixel = 0
Divider.Parent = Frame

local function createToggle(labelText, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 42)
    btn.Position = UDim2.new(0.075, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.Parent = Frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0.05, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Arial  -- ИСПРАВЛЕНО
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btn

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 36, 0, 20)
    dot.Position = UDim2.new(1, -46, 0.5, -10)
    dot.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    dot.BorderSizePixel = 0
    dot.Parent = btn
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
    knob.BorderSizePixel = 0
    knob.Parent = dot
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        local dGoal = active
            and {BackgroundColor3 = Color3.fromRGB(100, 200, 120)}
            or  {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}
        local kGoal = active
            and {Position = UDim2.new(0, 19, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255,255,255)}
            or  {Position = UDim2.new(0,  3, 0.5, -7), BackgroundColor3 = Color3.fromRGB(180,180,180)}
        TweenService:Create(dot,  TweenInfo.new(0.2), dGoal):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), kGoal):Play()
        callback(active)
    end)
    return btn
end

local function createSlider(yPos, defaultVal, maxVal, labelPrefix, onChanged)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.85, 0, 0, 18)
    lbl.Position = UDim2.new(0.075, 0, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelPrefix .. defaultVal
    lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    lbl.Font = Enum.Font.Arial  -- ИСПРАВЛЕНО
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = Frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0.85, 0, 0, 6)
    track.Position = UDim2.new(0.075, 0, 0, yPos + 24)
    track.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    track.BorderSizePixel = 0
    track.Parent = Frame
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(defaultVal / maxVal, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 200, 120)
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(defaultVal / maxVal, -9, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    knob.Text = ""
    knob.BorderSizePixel = 0
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function update(inputPos)
        local rel = math.clamp((inputPos.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(rel * maxVal)
        lbl.Text = labelPrefix .. val
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -9, 0.5, -9)
        onChanged(val)
    end

    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (
            i.UserInputType == Enum.UserInputType.MouseMovement or
            i.UserInputType == Enum.UserInputType.Touch
        ) then update(i.Position) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ══════════════════════════════
--            FLY
-- ══════════════════════════════
local function stopFly()
    flyEnabled = false
    if flyConn then flyConn:Disconnect() end
    local char = player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bg = hrp:FindFirstChildOfClass("BodyGyro")
            local bv = hrp:FindFirstChildOfClass("BodyVelocity")
            if bg then bg:Destroy() end
            if bv then bv:Destroy() end
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

local function startFly()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    hum.PlatformStand = true

    local bg = Instance.new("BodyGyro", hrp)
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.P = 1e4

    local bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.new(0, 0, 0)  -- ИСПРАВЛЕНО

    flyConn = RunService.Heartbeat:Connect(function()
        if not flyEnabled then return end
        local move = Vector3.new(0, 0, 0)  -- ИСПРАВЛЕНО
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then move = move + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
        bv.Velocity = move.Magnitude > 0 and move.Unit * flySpeed or Vector3.new(0, 0, 0)  -- ИСПРАВЛЕНО
        bg.CFrame = camera.CFrame
    end)
end

-- ══════════════════════════════
--           МАГНИТ
-- ══════════════════════════════
local function getMobs(origin, radius)
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= player.Character then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                if (hrp.Position - origin).Magnitude <= radius then
                    table.insert(list, obj)
                end
            end
        end
    end
    return list
end

local function getTallestHeight(mobs)
    local maxH = 5
    for _, mob in ipairs(mobs) do
        for _, part in ipairs(mob:GetDescendants()) do
            if part:IsA("BasePart") then
                local ok, sizeY = pcall(function() return part.Size.Y end)
                if ok and sizeY and sizeY > maxH then maxH = sizeY end
            end
        end
    end
    return maxH
end

local function startMagnet()
    if magnetConn then magnetConn:Disconnect() end
    magnetConn = RunService.Heartbeat:Connect(function()
        if not magnetEnabled then return end
        local char = player.Character
        if not char then return end
        local myHRP = char:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        local origin = myHRP.Position
        local mobs = getMobs(origin, magnetRadius)
        if #mobs == 0 then return end

        local center = Vector3.new(origin.X, origin.Y - 5, origin.Z)

        for i, mob in ipairs(mobs) do
            local hrp = mob:FindFirstChild("HumanoidRootPart")
            if hrp then
                local angle = (i / #mobs) * math.pi * 2
                local r = math.min(i * 0.4, 3)
                local pos = Vector3.new(
                    center.X + math.cos(angle) * r,
                    center.Y,
                    center.Z + math.sin(angle) * r
                )
                pcall(function() hrp.CFrame = CFrame.new(pos) end)
            end
        end

        local tallest = getTallestHeight(mobs)
        local targetY = center.Y + tallest + 2
        local bv = myHRP:FindFirstChildOfClass("BodyVelocity")
        if not bv then
            bv = Instance.new("BodyVelocity", myHRP)
            bv.MaxForce = Vector3.new(0, 1e5, 0)
        end
        bv.Velocity = Vector3.new(0, math.clamp((targetY - myHRP.Position.Y) * 10, -50, 50), 0)
    end)
end

-- ══════════════════════════════
--   АВТО-УРОН 100м / 0.1 сек
-- ══════════════════════════════
local function startAutoHit()
    if autoHitConn then autoHitConn:Disconnect() end
    local timer = 0
    autoHitConn = RunService.Heartbeat:Connect(function(dt)
        timer = timer + dt
        if timer < 0.1 then return end
        timer = 0

        local char = player.Character
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then return end
        local myHRP = char:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= char then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 0 then
                    if (hrp.Position - myHRP.Position).Magnitude <= 100 then
                        pcall(function() hum:TakeDamage(hum.MaxHealth * 0.3) end)
                        for _, re in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                            if re:IsA("RemoteEvent") then
                                local n = re.Name:lower()
                                if n:find("damage") or n:find("hit") or n:find("attack") or n:find("dmg") then
                                    pcall(function() re:FireServer(obj, hum, 999) end)
                                    pcall(function() re:FireServer(hum, 999) end)
                                    pcall(function() re:FireServer(obj) end)
                                end
                            end
                        end
                        for _, v in ipairs(tool:GetDescendants()) do
                            if v:IsA("RemoteEvent") then
                                pcall(function() v:FireServer(hrp.Position) end)
                                pcall(function() v:FireServer(obj, hrp.Position) end)
                                pcall(function() v:FireServer(hum) end)
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function stopAutoHit()
    if autoHitConn then autoHitConn:Disconnect() end
end

-- ══════════════════════════════
--           UI
-- ══════════════════════════════
createToggle("✈  Fly", 58, function(state)
    flyEnabled = state
    if state then startFly() else stopFly() end
end)

createSlider(110, flySpeed, 500, "Скорость: ", function(val) flySpeed = val end)

createToggle("👻  Noclip", 158, function(state)
    noclipEnabled = state
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            local char = player.Character
            if not char then return end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() end
        local char = player.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end
end)

local div2 = Instance.new("Frame")
div2.Size = UDim2.new(0.85, 0, 0, 1)
div2.Position = UDim2.new(0.075, 0, 0, 212)
div2.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
div2.BorderSizePixel = 0
div2.Parent = Frame

local magTitle = Instance.new("TextLabel")
magTitle.Size = UDim2.new(0.85, 0, 0, 20)
magTitle.Position = UDim2.new(0.075, 0, 0, 218)
magTitle.BackgroundTransparency = 1
magTitle.Text = "🧲  МАГНИТ"
magTitle.TextColor3 = Color3.fromRGB(100, 200, 120)
magTitle.Font = Enum.Font.ArialBold  -- ИСПРАВЛЕНО
magTitle.TextSize = 12
magTitle.TextXAlignment = Enum.TextXAlignment.Left
magTitle.Parent = Frame

createToggle("  Включить", 244, function(state)
    magnetEnabled = state
    if state then
        startMagnet()
        startAutoHit()
    else
        if magnetConn then magnetConn:Disconnect() end
        stopAutoHit()
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bv = hrp:FindFirstChildOfClass("BodyVelocity")
                if bv then bv:Destroy() end
            end
        end
    end
end)

createSlider(296, magnetRadius, 200, "Радиус: ", function(val) magnetRadius = val end)

local div3 = Instance.new("Frame")
div3.Size = UDim2.new(0.85, 0, 0, 1)
div3.Position = UDim2.new(0.075, 0, 0, 352)
div3.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
div3.BorderSizePixel = 0
div3.Parent = Frame

local autoTitle = Instance.new("TextLabel")
autoTitle.Size = UDim2.new(0.85, 0, 0, 20)
autoTitle.Position = UDim2.new(0.075, 0, 0, 358)
autoTitle.BackgroundTransparency = 1
autoTitle.Text = "⚔️  АВТО-УДАР (100м)"
autoTitle.TextColor3 = Color3.fromRGB(200, 150, 100)
autoTitle.Font = Enum.Font.ArialBold  -- ИСПРАВЛЕНО
autoTitle.TextSize = 12
autoTitle.TextXAlignment = Enum.TextXAlignment.Left
autoTitle.Parent = Frame

createToggle("  Атака в радиусе", 380, function(state)
    if state then startAutoHit() else stopAutoHit() end
end)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0.85, 0, 0, 36)
closeBtn.Position = UDim2.new(0.075, 0, 0, 462)
closeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✕  Закрыть"
closeBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
closeBtn.Font = Enum.Font.Arial  -- ИСПРАВЛЕНО
closeBtn.TextSize = 13
closeBtn.Parent = Frame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Mobile drag
local touchStart, frameStart
Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        touchStart = input.Position
        frameStart = Frame.Position
    end
end)
Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and touchStart then
        local delta = input.Position - touchStart
        Frame.Position = UDim2.new(
            frameStart.X.Scale, frameStart.X.Offset + delta.X,
            frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
        )
    end
end)
Frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then touchStart = nil end
end)        local kGoal = active
            and {Position = UDim2.new(0, 19, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255,255,255)}
            or  {Position = UDim2.new(0,  3, 0.5, -7), BackgroundColor3 = Color3.fromRGB(180,180,180)}
        TweenService:Create(dot,  TweenInfo.new(0.2), dGoal):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), kGoal):Play()
        callback(active)
    end)
    return btn
end

-- ── Helper: Слайдер ──
local function createSlider(yPos, defaultVal, maxVal, labelPrefix, onChanged)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.85, 0, 0, 18)
    lbl.Position = UDim2.new(0.075, 0, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelPrefix .. defaultVal
    lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = Frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0.85, 0, 0, 6)
    track.Position = UDim2.new(0.075, 0, 0, yPos + 24)
    track.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    track.BorderSizePixel = 0
    track.Parent = Frame
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(defaultVal / maxVal, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 200, 120)
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(defaultVal / maxVal, -9, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    knob.Text = ""
    knob.BorderSizePixel = 0
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function update(inputPos)
        local rel = math.clamp((inputPos.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(rel * maxVal)
        lbl.Text = labelPrefix .. val
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -9, 0.5, -9)
        onChanged(val)
    end

    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (
            i.UserInputType == Enum.UserInputType.MouseMovement or
            i.UserInputType == Enum.UserInputType.Touch
        ) then
            update(i.Position)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ══════════════════════════════
--          FLY
-- ══════════════════════════════
local function stopFly()
    flyEnabled = false
    if flyConn then flyConn:Disconnect() end
    local char = player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bg = hrp:FindFirstChildOfClass("BodyGyro")
            local bv = hrp:FindFirstChildOfClass("BodyVelocity")
            if bg then bg:Destroy() end
            if bv then bv:Destroy() end
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

local function startFly()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    hum.PlatformStand = true

    local bg = Instance.new("BodyGyro", hrp)
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.P = 1e4

    local bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.zero

    flyConn = RunService.Heartbeat:Connect(function()
        if not flyEnabled then return end
        local move = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then move = move + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
        bv.Velocity = move.Magnitude > 0 and move.Unit * flySpeed or Vector3.zero
        bg.CFrame = camera.CFrame
    end)
end

-- ══════════════════════════════
--         МАГНИТ
-- ══════════════════════════════
local function getMobs(origin, radius)
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= player.Character then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                if (hrp.Position - origin).Magnitude <= radius then
                    table.insert(list, obj)
                end
            end
        end
    end
    return list
end

-- ✅ ИСПРАВЛЕНО: без GetExtentsSize
local function getTallestHeight(mobs)
    local maxH = 5
    for _, mob in ipairs(mobs) do
        for _, part in ipairs(mob:GetDescendants()) do
            if part:IsA("BasePart") then
                local ok, sizeY = pcall(function()
                    return part.Size.Y
                end)
                if ok and sizeY and sizeY > maxH then
                    maxH = sizeY
                end
            end
        end
    end
    return maxH
end

local function startMagnet()
    if magnetConn then magnetConn:Disconnect() end
    magnetConn = RunService.Heartbeat:Connect(function()
        if not magnetEnabled then return end
        local char = player.Character
        if not char then return end
        local myHRP = char:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        local origin = myHRP.Position
        local mobs = getMobs(origin, magnetRadius)
        if #mobs == 0 then return end

        local center = Vector3.new(origin.X, origin.Y - 5, origin.Z)

        for i, mob in ipairs(mobs) do
            local hrp = mob:FindFirstChild("HumanoidRootPart")
            if hrp then
                local angle = (i / #mobs) * math.pi * 2
                local r = math.min(i * 0.4, 3)
                local pos = Vector3.new(
                    center.X + math.cos(angle) * r,
                    center.Y,
                    center.Z + math.sin(angle) * r
                )
                pcall(function() hrp.CFrame = CFrame.new(pos) end)
            end
        end

        local tallest = getTallestHeight(mobs)
        local targetY = center.Y + tallest + 2
        local bv = myHRP:FindFirstChildOfClass("BodyVelocity")
        if not bv then
            bv = Instance.new("BodyVelocity", myHRP)
            bv.MaxForce = Vector3.new(0, 1e5, 0)
        end
        bv.Velocity = Vector3.new(0, math.clamp((targetY - myHRP.Position.Y) * 10, -50, 50), 0)
    end)
end

-- ══════════════════════════════
--   АВТО-УРОН (100м / 0.1 сек)
-- ══════════════════════════════
local function startAutoHit()
    if autoHitConn then autoHitConn:Disconnect() end
    local timer = 0

    autoHitConn = RunService.Heartbeat:Connect(function(dt)
        timer = timer + dt
        if timer < 0.1 then return end
        timer = 0

        local char = player.Character
        if not char then return end

        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then return end

        local myHRP = char:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= char then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 0 then
                    if (hrp.Position - myHRP.Position).Magnitude <= 100 then

                        -- Способ 1: прямой урон
                        pcall(function()
                            hum:TakeDamage(hum.MaxHealth * 0.3)
                        end)

                        -- Способ 2: RemoteEvent из ReplicatedStorage
                        for _, re in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                            if re:IsA("RemoteEvent") then
                                local n = re.Name:lower()
                                if n:find("damage") or n:find("hit")
                                or n:find("attack") or n:find("dmg") then
                                    pcall(function() re:FireServer(obj, hum, 999) end)
                                    pcall(function() re:FireServer(hum, 999) end)
                                    pcall(function() re:FireServer(obj) end)
                                end
                            end
                        end

                        -- Способ 3: RemoteEvent внутри Tool
                        for _, v in ipairs(tool:GetDescendants()) do
                            if v:IsA("RemoteEvent") then
                                pcall(function() v:FireServer(hrp.Position) end)
                                pcall(function() v:FireServer(obj, hrp.Position) end)
                                pcall(function() v:FireServer(hum) end)
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function stopAutoHit()
    if autoHitConn then autoHitConn:Disconnect() end
end

-- ══════════════════════════════
--          UI КНОПКИ
-- ══════════════════════════════

-- ✈ FLY
createToggle("✈  Fly", 58, function(state)
    flyEnabled = state
    if state then startFly() else stopFly() end
end)

createSlider(110, flySpeed, 500, "Скорость: ", function(val)
    flySpeed = val
end)

-- 👻 NOCLIP
createToggle("👻  Noclip", 158, function(state)
    noclipEnabled = state
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            local char = player.Character
            if not char then return end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() end
        local char = player.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end
end)

-- ── Разделитель ──
local div2 = Instance.new("Frame")
div2.Size = UDim2.new(0.85, 0, 0, 1)
div2.Position = UDim2.new(0.075, 0, 0, 212)
div2.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
div2.BorderSizePixel = 0
div2.Parent = Frame

-- 🧲 МАГНИТ
local magTitle = Instance.new("TextLabel")
magTitle.Size = UDim2.new(0.85, 0, 0, 20)
magTitle.Position = UDim2.new(0.075, 0, 0, 218)
magTitle.BackgroundTransparency = 1
magTitle.Text = "🧲  МАГНИТ"
magTitle.TextColor3 = Color3.fromRGB(100, 200, 120)
magTitle.Font = Enum.Font.GothamBold
magTitle.TextSize = 12
magTitle.TextXAlignment = Enum.TextXAlignment.Left
magTitle.Parent = Frame

createToggle("  Включить", 244, function(state)
    magnetEnabled = state
    if state then
        startMagnet()
        startAutoHit()
    else
        if magnetConn then magnetConn:Disconnect() end
        stopAutoHit()
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bv = hrp:FindFirstChildOfClass("BodyVelocity")
                if bv then bv:Destroy() end
            end
        end
    end
end)

createSlider(296, magnetRadius, 200, "Радиус: ", function(val)
    magnetRadius = val
end)

-- ── Разделитель ──
local div3 = Instance.new("Frame")
div3.Size = UDim2.new(0.85, 0, 0, 1)
div3.Position = UDim2.new(0.075, 0, 0, 352)
div3.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
div3.BorderSizePixel = 0
div3.Parent = Frame

-- ⚔️ АВТО-УДАР
local autoTitle = Instance.new("TextLabel")
autoTitle.Size = UDim2.new(0.85, 0, 0, 20)
autoTitle.Position = UDim2.new(0.075, 0, 0, 358)
autoTitle.BackgroundTransparency = 1
autoTitle.Text = "⚔️  АВТО-УДАР (100м)"
autoTitle.TextColor3 = Color3.fromRGB(200, 150, 100)
autoTitle.Font = Enum.Font.GothamBold
autoTitle.TextSize = 12
autoTitle.TextXAlignment = Enum.TextXAlignment.Left
autoTitle.Parent = Frame

createToggle("  Атака в радиусе", 380, function(state)
    if state then startAutoHit() else stopAutoHit() end
end)

-- ✕ ЗАКРЫТЬ
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0.85, 0, 0, 36)
closeBtn.Position = UDim2.new(0.075, 0, 0, 462)
closeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✕  Закрыть"
closeBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
closeBtn.Font = Enum.Font.Gotham
closeBtn.TextSize = 13
closeBtn.Parent = Frame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- ══════════════════════════════
--   MOBILE: перетаскивание
-- ══════════════════════════════
local touchStart, frameStart
Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        touchStart = input.Position
        frameStart = Frame.Position
    end
end)
Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and touchStart then
        local delta = input.Position - touchStart
        Frame.Position = UDim2.new(
            frameStart.X.Scale, frameStart.X.Offset + delta.X,
            frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
        )
    end
end)
Frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        touchStart = nil
    end
end)        if #mobs == 0 then return end

        -- 1. Притягиваем всех мобов под игрока
        local center = Vector3.new(origin.X, origin.Y - 5, origin.Z)
        for i, mob in ipairs(mobs) do
            local hrp = mob:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- Телепортируем моба кучкой под игроком (небольшой разброс)
                local angle = (i / #mobs) * math.pi * 2
                local spreadR = math.min(i * 0.4, 3) -- компактная куча
                local targetPos = Vector3.new(
                    center.X + math.cos(angle) * spreadR,
                    center.Y,
                    center.Z + math.sin(angle) * spreadR
                )
                pcall(function()
                    hrp.CFrame = CFrame.new(targetPos)
                end)
            end
        end

        -- 2. Поднимаем игрока на 2м выше самого высокого моба
        local tallest = getTallestHeight(mobs)
        local targetPlayerY = center.Y + tallest + 2

        -- Плавно перемещаем игрока вверх
        local bv = myHRP:FindFirstChildOfClass("BodyVelocity")
        if not bv then
            bv = Instance.new("BodyVelocity", myHRP)
            bv.MaxForce = Vector3.new(0, 1e5, 0)
        end
        local dy = targetPlayerY - myHRP.Position.Y
        bv.Velocity = Vector3.new(0, math.clamp(dy * 10, -50, 50), 0)
    end)
end

-- ══════════════════════════════
--   UI: КНОПКА МАГНИТ + СЛАЙДЕР
-- ══════════════════════════════

-- Расширяем Frame под новые элементы
Frame.Size = UDim2.new(0, 260, 0, 480)

-- Разделитель перед магнитом
local div2 = Instance.new("Frame")
div2.Size = UDim2.new(0.85, 0, 0, 1)
div2.Position = UDim2.new(0.075, 0, 0, 215)
div2.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
div2.BorderSizePixel = 0
div2.Parent = Frame

-- Заголовок секции
local magnetTitle = Instance.new("TextLabel")
magnetTitle.Size = UDim2.new(0.85, 0, 0, 20)
magnetTitle.Position = UDim2.new(0.075, 0, 0, 222)
magnetTitle.BackgroundTransparency = 1
magnetTitle.Text = "🧲  МАГНИТ"
magnetTitle.TextColor3 = Color3.fromRGB(100, 200, 120)
magnetTitle.Font = Enum.Font.GothamBold
magnetTitle.TextSize = 12
magnetTitle.TextXAlignment = Enum.TextXAlignment.Left
magnetTitle.Parent = Frame

-- Кнопка Toggle Магнит
createToggle("  Включить", 248, function(state)
    magnetEnabled = state
    if state then
        startMagnet()
        startAutoHit()
    else
        if magnetConn   then magnetConn:Disconnect()   end
        if autoHitConn  then autoHitConn:Disconnect()  end
        -- Убираем BodyVelocity если был
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bv = hrp:FindFirstChildOfClass("BodyVelocity")
                if bv then bv:Destroy() end
            end
        end
    end
end)

-- Лейбл радиуса
local radLabel = Instance.new("TextLabel")
radLabel.Size = UDim2.new(0.85, 0, 0, 20)
radLabel.Position = UDim2.new(0.075, 0, 0, 300)
radLabel.BackgroundTransparency = 1
radLabel.Text = "Радиус: " .. magnetRadius .. " м"
radLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
radLabel.Font = Enum.Font.Gotham
radLabel.TextSize = 12
radLabel.TextXAlignment = Enum.TextXAlignment.Left
radLabel.Parent = Frame

-- Слайдер радиуса
local radTrack = Instance.new("Frame")
radTrack.Size = UDim2.new(0.85, 0, 0, 6)
radTrack.Position = UDim2.new(0.075, 0, 0, 326)
radTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
radTrack.BorderSizePixel = 0
radTrack.Parent = Frame
Instance.new("UICorner", radTrack).CornerRadius = UDim.new(1, 0)

local radFill = Instance.new("Frame")
radFill.Size = UDim2.new(magnetRadius / 200, 0, 1, 0)
radFill.BackgroundColor3 = Color3.fromRGB(100, 200, 120)
radFill.BorderSizePixel = 0
radFill.Parent = radTrack
Instance.new("UICorner", radFill).CornerRadius = UDim.new(1, 0)

local radKnob = Instance.new("TextButton")
radKnob.Size = UDim2.new(0, 18, 0, 18)
radKnob.Position = UDim2.new(magnetRadius / 200, -9, 0.5, -9)
radKnob.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
radKnob.Text = ""
radKnob.BorderSizePixel = 0
radKnob.Parent = radTrack
Instance.new("UICorner", radKnob).CornerRadius = UDim.new(1, 0)

local radDragging = false
local function updateRadSlider(inputPos)
    local absPos  = radTrack.AbsolutePosition
    local absSize = radTrack.AbsoluteSize
    local rel = math.clamp((inputPos.X - absPos.X) / absSize.X, 0, 1)
    magnetRadius = math.floor(rel * 200)
    radLabel.Text = "Радиус: " .. magnetRadius .. " м"
    radFill.Size = UDim2.new(rel, 0, 1, 0)
    radKnob.Position = UDim2.new(rel, -9, 0.5, -9)
end

radKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        radDragging = true
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if radDragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement or
        input.UserInputType == Enum.UserInputType.Touch
    ) then
        updateRadSlider(input.Position)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        radDragging = false
    end
end)

-- ── Кнопка Close (обновлённая позиция) ──
-- Найди в старом скрипте closeBtn и измени Position на:
-- closeBtn.Position = UDim2.new(0.075, 0, 0, 430)
-- или удали старый closeBtn и добавь новый:
local closeBtn2 = Instance.new("TextButton")
closeBtn2.Size = UDim2.new(0.85, 0, 0, 38)
closeBtn2.Position = UDim2.new(0.075, 0, 0, 430)
closeBtn2.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
closeBtn2.BorderSizePixel = 0
closeBtn2.Text = "✕  Закрыть"
closeBtn2.TextColor3 = Color3.fromRGB(180, 180, 180)
closeBtn2.Font = Enum.Font.Gotham
closeBtn2.TextSize = 13
closeBtn2.Parent = Frame
Instance.new("UICorner", closeBtn2).CornerRadius = UDim.new(0, 8)
closeBtn2.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

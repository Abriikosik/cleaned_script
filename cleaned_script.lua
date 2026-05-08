-- NexusHub | Linux-style Menu
-- Noclip | Fly | Teleport
-- Работает в большинстве экзекуторов (Synapse X, KRNL, Fluxus и т.д.)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp  = char:WaitForChild("HumanoidRootPart")
local hum  = char:WaitForChild("Humanoid")

-- ──────────────────────────────────────────
--  STATE
-- ──────────────────────────────────────────
local state = {
    noclip    = false,
    fly       = false,
    flySpeed  = 60,
    menuOpen  = true,
}

local flyConn, noclipConn, bodyVel, bodyGyro

-- ──────────────────────────────────────────
--  GUI
-- ──────────────────────────────────────────
local sg = Instance.new("ScreenGui")
sg.Name = "NexusHub"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = gethui and gethui() or lp.PlayerGui

-- Main window
local win = Instance.new("Frame")
win.Name = "Window"
win.Size = UDim2.new(0, 320, 0, 380)
win.Position = UDim2.new(0, 40, 0, 80)
win.BackgroundColor3 = Color3.fromRGB(14, 16, 20)
win.BorderSizePixel = 0
win.Active = true
win.Draggable = true
win.Parent = sg

Instance.new("UICorner", win).CornerRadius = UDim.new(0, 6)

local border = Instance.new("UIStroke", win)
border.Color = Color3.fromRGB(50, 200, 120)
border.Thickness = 1
border.Transparency = 0.4

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
titleBar.BorderSizePixel = 0
titleBar.Parent = win
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 6)

local titleFix = Instance.new("Frame") -- fix bottom corners of titlebar
titleFix.Size = UDim2.new(1, 0, 0.5, 0)
titleFix.Position = UDim2.new(0, 0, 0.5, 0)
titleFix.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -80, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "[ nexus@roblox ] ~ # menu"
titleLabel.TextColor3 = Color3.fromRGB(50, 200, 120)
titleLabel.TextSize = 12
titleLabel.Font = Enum.Font.Code
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Close / hide button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -30, 0.5, -12)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

-- Content frame
local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -32)
content.Position = UDim2.new(0, 0, 0, 32)
content.BackgroundTransparency = 1
content.Parent = win

local layout = Instance.new("UIListLayout", content)
layout.Padding = UDim.new(0, 0)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local padding = Instance.new("UIPadding", content)
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.PaddingTop = UDim.new(0, 10)

-- ──────────────────────────────────────────
--  HELPERS
-- ──────────────────────────────────────────
local function makeSection(labelText)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = "─── " .. labelText .. " ───"
    lbl.TextColor3 = Color3.fromRGB(70, 130, 100)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = content
end

local function makeToggle(labelText, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 34)
    row.BackgroundTransparency = 1
    row.Parent = content

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "> " .. labelText
    lbl.TextColor3 = Color3.fromRGB(180, 200, 185)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local togBtn = Instance.new("TextButton")
    togBtn.Size = UDim2.new(0, 52, 0, 22)
    togBtn.Position = UDim2.new(1, -52, 0.5, -11)
    togBtn.BackgroundColor3 = Color3.fromRGB(35, 45, 40)
    togBtn.BorderSizePixel = 0
    togBtn.Text = "[ OFF ]"
    togBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
    togBtn.TextSize = 11
    togBtn.Font = Enum.Font.Code
    togBtn.Parent = row
    Instance.new("UICorner", togBtn).CornerRadius = UDim.new(0, 3)

    local on = false
    togBtn.MouseButton1Click:Connect(function()
        on = not on
        if on then
            togBtn.Text = "[ ON ]"
            togBtn.TextColor3 = Color3.fromRGB(50, 220, 120)
            togBtn.BackgroundColor3 = Color3.fromRGB(20, 50, 35)
        else
            togBtn.Text = "[ OFF ]"
            togBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
            togBtn.BackgroundColor3 = Color3.fromRGB(35, 45, 40)
        end
        callback(on)
    end)
    return togBtn
end

local function makeButton(labelText, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(18, 30, 24)
    btn.BorderSizePixel = 0
    btn.Text = "$ " .. labelText
    btn.TextColor3 = Color3.fromRGB(50, 200, 120)
    btn.TextSize = 13
    btn.Font = Enum.Font.Code
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    Instance.new("UIPadding", btn).PaddingLeft = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(40, 80, 55)
    stroke.Thickness = 1

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(22, 45, 32)
        stroke.Color = Color3.fromRGB(50, 200, 120)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(18, 30, 24)
        stroke.Color = Color3.fromRGB(40, 80, 55)
    end)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function makeSlider(labelText, min, max, default, onChange)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundTransparency = 1
    container.Parent = content

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = "> " .. labelText .. ":  " .. tostring(default)
    lbl.TextColor3 = Color3.fromRGB(150, 180, 160)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 26)
    track.BackgroundColor3 = Color3.fromRGB(30, 40, 35)
    track.BorderSizePixel = 0
    track.Parent = container
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(50, 200, 120)
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

    local dragging = false
    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local abs = track.AbsolutePosition.X
            local w   = track.AbsoluteSize.X
            local t   = math.clamp((inp.Position.X - abs) / w, 0, 1)
            local val = math.floor(min + t * (max - min))
            fill.Size = UDim2.new(t, 0, 1, 0)
            lbl.Text = "> " .. labelText .. ":  " .. tostring(val)
            onChange(val)
        end
    end)
end

-- ──────────────────────────────────────────
--  BUILD MENU
-- ──────────────────────────────────────────
makeSection("MOVEMENT")

makeToggle("Noclip", function(on)
    state.noclip = on
    if on then
        noclipConn = RunService.Stepped:Connect(function()
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        if hum then hum.PlatformStand = false end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
end)

makeToggle("Fly", function(on)
    state.fly = on
    if on then
        hum.PlatformStand = true

        bodyVel = Instance.new("BodyVelocity", hrp)
        bodyVel.Velocity = Vector3.zero
        bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)

        bodyGyro = Instance.new("BodyGyro", hrp)
        bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bodyGyro.D = 100

        flyConn = RunService.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end

            bodyVel.Velocity = dir.Magnitude > 0
                and dir.Unit * state.flySpeed
                or Vector3.zero

            bodyGyro.CFrame = cam.CFrame
        end)
    else
        if flyConn then flyConn:Disconnect() flyConn = nil end
        if bodyVel  then bodyVel:Destroy()  bodyVel  = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        hum.PlatformStand = false
    end
end)

makeSlider("Fly Speed", 10, 200, 60, function(v) state.flySpeed = v end)

makeSection("TELEPORT")

makeButton("Goto Cursor  [Click Part]", function()
    -- Телепорт по клику мыши на часть карты
    local mouse = lp:GetMouse()
    local conn
    conn = mouse.Button1Down:Connect(function()
        conn:Disconnect()
        if mouse.Target then
            hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
    end)
end)

makeButton("Teleport to Player", function()
    -- Телепорт к случайному игроку из списка
    local others = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(others, p)
        end
    end
    if #others == 0 then return end
    local target = others[math.random(1, #others)]
    hrp.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(2, 0, 0)
end)

makeButton("Teleport to Spawn", function()
    local spawns = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
    if spawns then
        hrp.CFrame = CFrame.new(spawns.Position + Vector3.new(0, 5, 0))
    end
end)

makeSection("MISC")

makeButton("Reset Character", function()
    hum.Health = 0
end)

-- ──────────────────────────────────────────
--  KEYBIND: RShift toggle menu
-- ──────────────────────────────────────────
closeBtn.MouseButton1Click:Connect(function()
    win.Visible = false
end)

UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        win.Visible = not win.Visible
    end
end)

-- ──────────────────────────────────────────
--  RESPAWN HANDLING
-- ──────────────────────────────────────────
lp.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp  = newChar:WaitForChild("HumanoidRootPart")
    hum  = newChar:WaitForChild("Humanoid")
    -- сбрасываем состояния при смерти
    state.noclip = false
    state.fly    = false
    if flyConn    then flyConn:Disconnect()    flyConn    = nil end
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
end)

print("[NexusHub] Loaded. RShift = toggle menu")

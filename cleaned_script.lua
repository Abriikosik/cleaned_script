-- ═══════════════════════════════════════════════
--   ROBLOX MENU SCRIPT  |  LocalScript
--   Features: Fly, Noclip, Nodelay
--   Info:     Nickname, UserId, Ping, FPS
--   Size:     1024 x 1024 px
-- ═══════════════════════════════════════════════

local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UserInputService= game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")
local Stats           = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

local isFlyEnabled     = false
local isNoclipEnabled  = false
local isNodelayEnabled = false
local FlySpeed         = 100
local flyBodyVelocity  = nil
local flyBodyGyro      = nil
local nodelayConns     = {}
local noclipConn       = nil
local menuOpen         = true

-- ── Helpers ──────────────────────────────────────────────────────────────────

local function getCharParts()
    local char   = LocalPlayer.Character
    if not char then return nil, nil, nil end
    local hrp    = char:FindFirstChild("HumanoidRootPart")
    local hum    = char:FindFirstChildOfClass("Humanoid")
    return char, hrp, hum
end

-- ── GUI Build ─────────────────────────────────────────────────────────────────

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "CustomMenu"
ScreenGui.ResetOnSpawn    = false
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset  = true
ScreenGui.Parent          = PlayerGui

-- Toggle button (always visible)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size            = UDim2.new(0, 80, 0, 32)
ToggleBtn.Position        = UDim2.new(0, 12, 0, 12)
ToggleBtn.BackgroundColor3= Color3.fromRGB(25, 25, 35)
ToggleBtn.TextColor3      = Color3.fromRGB(0, 200, 255)
ToggleBtn.Text            = "[ MENU ]"
ToggleBtn.Font            = Enum.Font.Code
ToggleBtn.TextSize        = 14
ToggleBtn.BorderSizePixel = 0
ToggleBtn.ZIndex          = 10
ToggleBtn.Parent          = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

-- Main frame
local MainFrame = Instance.new("Frame")
MainFrame.Name            = "MainFrame"
MainFrame.Size            = UDim2.new(0, 1024, 0, 1024)
MainFrame.Position        = UDim2.new(0.5, -512, 0.5, -512)
MainFrame.BackgroundColor3= Color3.fromRGB(13, 13, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants= true
MainFrame.Parent          = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size             = UDim2.new(1, 0, 0, 56)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
TitleBar.BorderSizePixel  = 0
TitleBar.Parent           = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size           = UDim2.new(1, -70, 1, 0)
TitleLabel.Position       = UDim2.new(0, 18, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text           = "⚡  MENU  |  Roblox"
TitleLabel.Font           = Enum.Font.Code
TitleLabel.TextSize       = 20
TitleLabel.TextColor3     = Color3.fromRGB(0, 200, 255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent         = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size             = UDim2.new(0, 40, 0, 40)
CloseBtn.Position         = UDim2.new(1, -50, 0.5, -20)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text             = "✕"
CloseBtn.Font             = Enum.Font.Code
CloseBtn.TextSize         = 18
CloseBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
CloseBtn.BorderSizePixel  = 0
CloseBtn.Parent           = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

-- ── Info Panel ────────────────────────────────────────────────────────────────

local InfoPanel = Instance.new("Frame")
InfoPanel.Size            = UDim2.new(1, -40, 0, 180)
InfoPanel.Position        = UDim2.new(0, 20, 0, 70)
InfoPanel.BackgroundColor3= Color3.fromRGB(18, 18, 28)
InfoPanel.BorderSizePixel = 0
InfoPanel.Parent          = MainFrame
Instance.new("UICorner", InfoPanel).CornerRadius = UDim.new(0, 10)

local function makeInfoRow(parent, labelText, yOffset)
    local row = Instance.new("Frame")
    row.Size              = UDim2.new(1, -24, 0, 34)
    row.Position          = UDim2.new(0, 12, 0, yOffset)
    row.BackgroundTransparency = 1
    row.Parent            = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(0, 220, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text              = labelText
    lbl.Font              = Enum.Font.Code
    lbl.TextSize          = 15
    lbl.TextColor3        = Color3.fromRGB(120, 130, 160)
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.Parent            = row

    local val = Instance.new("TextLabel")
    val.Size              = UDim2.new(1, -230, 1, 0)
    val.Position          = UDim2.new(0, 230, 0, 0)
    val.BackgroundTransparency = 1
    val.Text              = "..."
    val.Font              = Enum.Font.Code
    val.TextSize          = 15
    val.TextColor3        = Color3.fromRGB(0, 200, 255)
    val.TextXAlignment    = Enum.TextXAlignment.Left
    val.Parent            = row

    return val
end

local ValNick    = makeInfoRow(InfoPanel, "  Никнейм",    8)
local ValUserId  = makeInfoRow(InfoPanel, "  UserId",    42)
local ValPing    = makeInfoRow(InfoPanel, "  Ping",      76)
local ValFPS     = makeInfoRow(InfoPanel, "  FPS",      110)
local ValAge     = makeInfoRow(InfoPanel, "  Дней в игре",144)

-- Fill static info immediately
ValNick.Text   = LocalPlayer.Name
ValUserId.Text = tostring(LocalPlayer.UserId)
ValAge.Text    = tostring(LocalPlayer.AccountAge) .. " дн."

-- ── Feature Buttons Helper ────────────────────────────────────────────────────

local function makeToggleButton(parent, label, posY)
    local btn = Instance.new("TextButton")
    btn.Size              = UDim2.new(1, -40, 0, 56)
    btn.Position          = UDim2.new(0, 20, 0, posY)
    btn.BackgroundColor3  = Color3.fromRGB(22, 22, 35)
    btn.Text              = label .. "   [ OFF ]"
    btn.Font              = Enum.Font.Code
    btn.TextSize          = 17
    btn.TextColor3        = Color3.fromRGB(160, 160, 200)
    btn.TextXAlignment    = Enum.TextXAlignment.Left
    btn.BorderSizePixel   = 0
    btn.Parent            = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local stripe = Instance.new("Frame")
    stripe.Size           = UDim2.new(0, 4, 1, -12)
    stripe.Position       = UDim2.new(1, -20, 0, 6)
    stripe.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    stripe.BorderSizePixel= 0
    stripe.Parent         = btn
    Instance.new("UICorner", stripe).CornerRadius = UDim.new(0, 2)

    return btn, stripe
end

-- ── Fly Section ───────────────────────────────────────────────────────────────

local FlyBtn, FlyStripe = makeToggleButton(MainFrame, "✈  Fly", 270)

-- Speed slider
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size           = UDim2.new(1, -40, 0, 28)
SpeedLabel.Position       = UDim2.new(0, 20, 0, 340)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text           = "Скорость Fly:  100  (0 — 6767)"
SpeedLabel.Font           = Enum.Font.Code
SpeedLabel.TextSize       = 14
SpeedLabel.TextColor3     = Color3.fromRGB(100, 110, 150)
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent         = MainFrame

local SliderBg = Instance.new("Frame")
SliderBg.Size             = UDim2.new(1, -40, 0, 10)
SliderBg.Position         = UDim2.new(0, 20, 0, 374)
SliderBg.BackgroundColor3 = Color3.fromRGB(30, 30, 46)
SliderBg.BorderSizePixel  = 0
SliderBg.Parent           = MainFrame
Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(0, 5)

local SliderFill = Instance.new("Frame")
SliderFill.Size           = UDim2.new(FlySpeed / 6767, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
SliderFill.BorderSizePixel= 0
SliderFill.Parent         = SliderBg
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 5)

local SliderThumb = Instance.new("TextButton")
SliderThumb.Size          = UDim2.new(0, 22, 0, 22)
SliderThumb.AnchorPoint   = Vector2.new(0.5, 0.5)
SliderThumb.Position      = UDim2.new(FlySpeed / 6767, 0, 0.5, 0)
SliderThumb.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
SliderThumb.Text          = ""
SliderThumb.BorderSizePixel= 0
SliderThumb.ZIndex        = 2
SliderThumb.Parent        = SliderBg
Instance.new("UICorner", SliderThumb).CornerRadius = UDim.new(0.5, 0)

-- Slider drag logic
local dragging = false
SliderThumb.MouseButton1Down:Connect(function()
    dragging = true
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
RunService.RenderStepped:Connect(function()
    if dragging then
        local mouseX  = UserInputService:GetMouseLocation().X
        local bgPos   = SliderBg.AbsolutePosition.X
        local bgWidth = SliderBg.AbsoluteSize.X
        local ratio   = math.clamp((mouseX - bgPos) / bgWidth, 0, 1)
        FlySpeed      = math.floor(ratio * 6767)
        SliderFill.Size     = UDim2.new(ratio, 0, 1, 0)
        SliderThumb.Position= UDim2.new(ratio, 0, 0.5, 0)
        SpeedLabel.Text     = "Скорость Fly:  " .. FlySpeed .. "  (0 — 6767)"
    end
end)

-- ── Noclip Section ────────────────────────────────────────────────────────────

local NoclipBtn, NoclipStripe = makeToggleButton(MainFrame, "👻  Noclip", 410)

-- ── Nodelay Section ───────────────────────────────────────────────────────────

local NodelayBtn, NodelayStripe = makeToggleButton(MainFrame, "⚡  Nodelay", 482)

local NodelayDesc = Instance.new("TextLabel")
NodelayDesc.Size          = UDim2.new(1, -40, 0, 30)
NodelayDesc.Position      = UDim2.new(0, 24, 0, 544)
NodelayDesc.BackgroundTransparency = 1
NodelayDesc.Text          = "Все предметы используются без задержки и кулдауна"
NodelayDesc.Font          = Enum.Font.Code
NodelayDesc.TextSize      = 13
NodelayDesc.TextColor3    = Color3.fromRGB(80, 90, 120)
NodelayDesc.TextXAlignment= Enum.TextXAlignment.Left
NodelayDesc.Parent        = MainFrame

-- ── Key Hint ─────────────────────────────────────────────────────────────────

local HintLabel = Instance.new("TextLabel")
HintLabel.Size            = UDim2.new(1, -40, 0, 30)
HintLabel.Position        = UDim2.new(0, 20, 1, -50)
HintLabel.BackgroundTransparency = 1
HintLabel.Text            = "Открыть/закрыть меню: RightShift  |  Закрыть: кнопка ✕"
HintLabel.Font            = Enum.Font.Code
HintLabel.TextSize        = 13
HintLabel.TextColor3      = Color3.fromRGB(60, 70, 100)
HintLabel.TextXAlignment  = Enum.TextXAlignment.Left
HintLabel.Parent          = MainFrame

-- ══════════════════════════════════════════════════════════════════════════════
-- LOGIC
-- ══════════════════════════════════════════════════════════════════════════════

-- ── Menu Toggle ───────────────────────────────────────────────────────────────

local function toggleMenu(state)
    menuOpen = state
    MainFrame.Visible = menuOpen
    ToggleBtn.Text    = menuOpen and "[ MENU ]" or "[ MENU ]"
end

CloseBtn.MouseButton1Click:Connect(function() toggleMenu(false) end)
ToggleBtn.MouseButton1Click:Connect(function() toggleMenu(not menuOpen) end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        toggleMenu(not menuOpen)
    end
end)

-- ── Fly Logic ─────────────────────────────────────────────────────────────────

local function startFly()
    local _, hrp, hum = getCharParts()
    if not hrp or not hum then return end

    hum.PlatformStand = true

    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(9e8, 9e8, 9e8)
    flyBodyGyro.P         = 9e4
    flyBodyGyro.CFrame    = hrp.CFrame
    flyBodyGyro.Parent    = hrp

    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.Velocity   = Vector3.zero
    flyBodyVelocity.MaxForce   = Vector3.new(9e8, 9e8, 9e8)
    flyBodyVelocity.P          = 9e4
    flyBodyVelocity.Parent     = hrp
end

local function stopFly()
    local _, hrp, hum = getCharParts()
    if flyBodyGyro    then flyBodyGyro:Destroy();    flyBodyGyro    = nil end
    if flyBodyVelocity then flyBodyVelocity:Destroy(); flyBodyVelocity = nil end
    if hum then hum.PlatformStand = false end
end

local function updateFly()
    if not isFlyEnabled or not flyBodyVelocity or not flyBodyGyro then return end
    local _, hrp, _ = getCharParts()
    if not hrp then return end

    local cam  = workspace.CurrentCamera
    local dir  = Vector3.zero
    local cf   = cam.CFrame

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector  end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector  end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end

    flyBodyGyro.CFrame     = cf
    flyBodyVelocity.Velocity = dir.Magnitude > 0 and (dir.Unit * FlySpeed) or Vector3.zero
end

FlyBtn.MouseButton1Click:Connect(function()
    isFlyEnabled = not isFlyEnabled
    if isFlyEnabled then
        startFly()
        FlyBtn.Text          = "✈  Fly   [ ON ]"
        FlyBtn.TextColor3    = Color3.fromRGB(0, 200, 255)
        FlyStripe.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    else
        stopFly()
        FlyBtn.Text          = "✈  Fly   [ OFF ]"
        FlyBtn.TextColor3    = Color3.fromRGB(160, 160, 200)
        FlyStripe.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    end
end)

-- ── Noclip Logic ──────────────────────────────────────────────────────────────

local function startNoclip()
    noclipConn = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function stopNoclip()
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

NoclipBtn.MouseButton1Click:Connect(function()
    isNoclipEnabled = not isNoclipEnabled
    if isNoclipEnabled then
        startNoclip()
        NoclipBtn.Text        = "👻  Noclip   [ ON ]"
        NoclipBtn.TextColor3  = Color3.fromRGB(0, 200, 255)
        NoclipStripe.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    else
        stopNoclip()
        NoclipBtn.Text        = "👻  Noclip   [ OFF ]"
        NoclipBtn.TextColor3  = Color3.fromRGB(160, 160, 200)
        NoclipStripe.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    end
end)

-- ── Nodelay Logic ─────────────────────────────────────────────────────────────
-- Hooks all Tool objects in the character's backpack and removes ManualActivationOnly
-- and resets Enabled flag instantly so there is no cooldown between uses.

local function hookTool(tool)
    -- Remove any existing activation cooldown
    if tool:IsA("Tool") then
        tool.ManualActivationOnly = false
        -- Hook Deactivated to instantly re-enable the tool
        local conn = tool.Deactivated:Connect(function()
            if isNodelayEnabled then
                task.defer(function()
                    tool.Enabled = true
                end)
            end
        end)
        table.insert(nodelayConns, conn)
    end
end

local function startNodelay()
    -- Hook current backpack tools
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do hookTool(t) end
        table.insert(nodelayConns, bp.ChildAdded:Connect(hookTool))
    end
    -- Hook equipped tool
    local char = LocalPlayer.Character
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") then hookTool(t) end
        end
        table.insert(nodelayConns, char.ChildAdded:Connect(function(c)
            if c:IsA("Tool") then hookTool(c) end
        end))
    end
end

local function stopNodelay()
    for _, c in ipairs(nodelayConns) do
        if c and typeof(c) == "RBXScriptConnection" then
            c:Disconnect()
        end
    end
    nodelayConns = {}
end

NodelayBtn.MouseButton1Click:Connect(function()
    isNodelayEnabled = not isNodelayEnabled
    if isNodelayEnabled then
        startNodelay()
        NodelayBtn.Text        = "⚡  Nodelay   [ ON ]"
        NodelayBtn.TextColor3  = Color3.fromRGB(0, 200, 255)
        NodelayStripe.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    else
        stopNodelay()
        NodelayBtn.Text        = "⚡  Nodelay   [ OFF ]"
        NodelayBtn.TextColor3  = Color3.fromRGB(160, 160, 200)
        NodelayStripe.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    end
end)

-- ── Per-frame Update (Ping, FPS, Fly) ────────────────────────────────────────

local lastTime  = tick()
local frameCount = 0
local currentFPS = 0

RunService.RenderStepped:Connect(function()
    -- FPS
    frameCount = frameCount + 1
    local now  = tick()
    if now - lastTime >= 0.5 then
        currentFPS = math.floor(frameCount / (now - lastTime))
        frameCount = 0
        lastTime   = now
        ValFPS.Text  = tostring(currentFPS) .. " fps"
    end

    -- Ping
    ValPing.Text = tostring(math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())) .. " ms"

    -- Fly update
    updateFly()
end)

-- ── Character respawn reconnection ───────────────────────────────────────────

LocalPlayer.CharacterAdded:Connect(function()
    -- Re-enable active features after respawn
    task.wait(1)
    if isFlyEnabled  then startFly()     end
    if isNoclipEnabled then startNoclip() end
    if isNodelayEnabled then stopNodelay(); startNodelay() end
end)

-- ── Draggable menu ────────────────────────────────────────────────────────────

local draggingMenu = false
local dragStart, frameStart

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingMenu = true
        dragStart    = input.Position
        frameStart   = MainFrame.Position
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingMenu = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingMenu and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            frameStart.X.Scale,
            frameStart.X.Offset + delta.X,
            frameStart.Y.Scale,
            frameStart.Y.Offset + delta.Y
        )
    end
end)

-- ═══════════════════════════════════════════════
-- Script ready.  RightShift = toggle menu.
-- ═══════════════════════════════════════════════    return btn
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

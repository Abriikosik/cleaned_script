-- Minimalist Roblox Menu | Fly + Noclip
-- Works with most executors (e.g. Synapse, KRNL, Fluxus)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ══════════════════════════════
--         STATE
-- ══════════════════════════════
local flyEnabled   = false
local noclipEnabled = false
local flySpeed     = 50
local flyConn, noclipConn

-- ══════════════════════════════
--         GUI
-- ══════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MinimalMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 320)
Frame.Position = UDim2.new(0.5, -130, 0.5, -160)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true -- PC drag
Frame.Parent = ScreenGui

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "✦  MENU"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.Parent = Frame

-- Divider
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0.85, 0, 0, 1)
Divider.Position = UDim2.new(0.075, 0, 0, 42)
Divider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Divider.BorderSizePixel = 0
Divider.Parent = Frame

-- ── Helper: Create Toggle Button ──
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
    label.Font = Enum.Font.Gotham
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
        local goal = active
            and {BackgroundColor3 = Color3.fromRGB(100, 200, 120)}
            or  {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}
        local knobGoal = active
            and {Position = UDim2.new(0, 19, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255,255,255)}
            or  {Position = UDim2.new(0,  3, 0.5, -7), BackgroundColor3 = Color3.fromRGB(180,180,180)}
        TweenService:Create(dot,  TweenInfo.new(0.2), goal):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), knobGoal):Play()
        callback(active)
    end)
    return btn
end

-- ── Fly Toggle ──
createToggle("✈  Fly", 58, function(state)
    flyEnabled = state
    if state then
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        hum.PlatformStand = true

        local bg = Instance.new("BodyGyro", hrp)
        bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
        bg.P = 1e4

        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1e5,1e5,1e5)
        bv.Velocity = Vector3.zero

        flyConn = RunService.Heartbeat:Connect(function()
            if not flyEnabled then return end
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                move = move + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                move = move - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                move = move - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                move = move + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                move = move + Vector3.new(0,1,0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                move = move - Vector3.new(0,1,0)
            end
            bv.Velocity = move.Magnitude > 0 and move.Unit * flySpeed or Vector3.zero
            bg.CFrame = camera.CFrame
        end)
    else
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
end)

-- ── Speed Slider Label ──
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.85, 0, 0, 20)
speedLabel.Position = UDim2.new(0.075, 0, 0, 110)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Fly Speed: " .. flySpeed
speedLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 12
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = Frame

-- ── Slider Track ──
local sliderTrack = Instance.new("Frame")
sliderTrack.Size = UDim2.new(0.85, 0, 0, 6)
sliderTrack.Position = UDim2.new(0.075, 0, 0, 136)
sliderTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
sliderTrack.BorderSizePixel = 0
sliderTrack.Parent = Frame
Instance.new("UICorner", sliderTrack).CornerRadius = UDim.new(1, 0)

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(flySpeed/500, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(100, 200, 120)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderTrack
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

local sliderKnob = Instance.new("TextButton")
sliderKnob.Size = UDim2.new(0, 18, 0, 18)
sliderKnob.Position = UDim2.new(flySpeed/500, -9, 0.5, -9)
sliderKnob.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
sliderKnob.Text = ""
sliderKnob.BorderSizePixel = 0
sliderKnob.Parent = sliderTrack
Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

-- Slider drag logic (PC + Mobile)
local dragging = false
local function updateSlider(inputPos)
    local absPos = sliderTrack.AbsolutePosition
    local absSize = sliderTrack.AbsoluteSize
    local rel = math.clamp((inputPos.X - absPos.X) / absSize.X, 0, 1)
    flySpeed = math.floor(rel * 500)
    speedLabel.Text = "Fly Speed: " .. flySpeed
    sliderFill.Size = UDim2.new(rel, 0, 1, 0)
    sliderKnob.Position = UDim2.new(rel, -9, 0.5, -9)
end

sliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input.Position)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ── Noclip Toggle ──
createToggle("👻  Noclip", 160, function(state)
    noclipEnabled = state
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            local char = player.Character
            if not char then return end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() end
        local char = player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end)

-- ── Close Button ──
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0.85, 0, 0, 38)
closeBtn.Position = UDim2.new(0.075, 0, 0, 262)
closeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✕  Close"
closeBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
closeBtn.Font = Enum.Font.Gotham
closeBtn.TextSize = 13
closeBtn.Parent = Frame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ══════════════════════════════
--   MOBILE: drag Frame by touch
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
end)
	local IconLabel = Instance.new("TextLabel")
	IconLabel.Size = UDim2.new(0, 35, 1, 0)
	IconLabel.Position = UDim2.new(0, 8, 0, 0)
	IconLabel.BackgroundTransparency = 1
	IconLabel.Text = icon
	IconLabel.TextScaled = true
	IconLabel.Font = Enum.Font.GothamBold
	IconLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
	IconLabel.Parent = Btn

	local NameLabel = Instance.new("TextLabel")
	NameLabel.Size = UDim2.new(1, -55, 1, 0)
	NameLabel.Position = UDim2.new(0, 48, 0, 0)
	NameLabel.BackgroundTransparency = 1
	NameLabel.Text = name
	NameLabel.TextXAlignment = Enum.TextXAlignment.Left
	NameLabel.TextScaled = true
	NameLabel.Font = Enum.Font.Gotham
	NameLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
	NameLabel.Parent = Btn

	Btn.MouseEnter:Connect(function()
		TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 80, 120)}):Play()
		TweenService:Create(BtnStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(0, 200, 255)}):Play()
	end)

	Btn.MouseLeave:Connect(function()
		TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 30)}):Play()
		TweenService:Create(BtnStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(30, 30, 50)}):Play()
	end)

	Btn.MouseButton1Click:Connect(function()
		TweenService:Create(Btn, TweenInfo.new(0.05), {BackgroundColor3 = Color3.fromRGB(0, 200, 255)}):Play()
		task.delay(0.1, function()
			TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 80, 120)}):Play()
		end)
		if callback then callback() end
	end)
end

-- // Кнопки
CreateButton("Нет реакции", "👻", function() print("[ GHOST ] в разработке") end)
CreateButton("ESP",         "👁",  function() print("[ ESP ] в разработке")   end)
CreateButton("Speed Hack",  "⚡",  function() print("[ SPEED ] в разработке") end)
CreateButton("Fly",         "🛸",  function() print("[ FLY ] в разработке")   end)
CreateButton("Aimbot",      "🎯",  function() print("[ AIM ] в разработке")   end)
CreateButton("Teleport",    "🌀",  function() print("[ TP ] в разработке")    end)
CreateButton("Anti-AFK",    "🔄",  function() print("[ AFK ] в разработке")   end)

-- // Закрыть кнопкой ✕
CloseBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = false
end)

-- // ФИХ ХОТКЕЯ — без gpe, RightControl вместо Insert
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.RightControl then
		MainFrame.Visible = not MainFrame.Visible
	end
end)

-- // Drag
local dragging, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

print("[ GHOST MENU ] Загружено! RightControl — показать/скрыть")
-- // Функция создания кнопки
local function CreateButton(name, icon, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 45)
    Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    Btn.BorderSizePixel = 0
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Btn.Parent = ScrollFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Btn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(30, 30, 50)
    BtnStroke.Thickness = 1
    BtnStroke.Parent = Btn

    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(0, 35, 1, 0)
    IconLabel.Position = UDim2.new(0, 8, 0, 0)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = icon
    IconLabel.TextScaled = true
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    IconLabel.Parent = Btn

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -55, 1, 0)
    NameLabel.Position = UDim2.new(0, 48, 0, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = name
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.TextScaled = true
    NameLabel.Font = Enum.Font.Gotham
    NameLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    NameLabel.Parent = Btn

    -- Hover анимация
    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(0, 80, 120)
        }):Play()
        TweenService:Create(BtnStroke, TweenInfo.new(0.15), {
            Color = Color3.fromRGB(0, 200, 255)
        }):Play()
    end)

    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        }):Play()
        TweenService:Create(BtnStroke, TweenInfo.new(0.15), {
            Color = Color3.fromRGB(30, 30, 50)
        }):Play()
    end)

    Btn.MouseButton1Click:Connect(function()
        -- Клик-вспышка
        TweenService:Create(Btn, TweenInfo.new(0.05), {
            BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        }):Play()
        task.delay(0.1, function()
            TweenService:Create(Btn, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(0, 80, 120)
            }):Play()
        end)
        if callback then callback() end
    end)

    return Btn
end

-- // Кнопки (сюда добавляй свои функции)
CreateButton("Нет реакции", "👻", function()
    print("[ GHOST ] Функция 1 — в разработке")
end)

CreateButton("ESP", "👁", function()
    print("[ ESP ] Функция 2 — в разработке")
end)

CreateButton("Speed Hack", "⚡", function()
    print("[ SPEED ] Функция 3 — в разработке")
end)

CreateButton("Fly", "🛸", function()
    print("[ FLY ] Функция 4 — в разработке")
end)

CreateButton("Aimbot", "🎯", function()
    print("[ AIM ] Функция 5 — в разработке")
end)

CreateButton("Teleport", "🌀", function()
    print("[ TP ] Функция 6 — в разработке")
end)

CreateButton("Anti-AFK", "🔄", function()
    print("[ AFK ] Функция 7 — в разработке")
end)

-- // Закрыть / показать (клавиша Insert)
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- // Drag (перетаскивание окна)
local dragging, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("[ GHOST MENU ] Загружено. Insert — показать/скрыть.")            
            playerButton.MouseLeave:Connect(function()
                playerButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            end)
            
            yOffset = yOffset + 40
        end
    end
    
    -- Обновляем размер канваса
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Обновляем список при входе/выходе игрока
Players.PlayerAdded:Connect(function()
    refreshPlayerList()
end)

Players.PlayerRemoving:Connect(function()
    refreshPlayerList()
end)

-- Первоначальное обновление
refreshPlayerList()actionsLabel.TextSize = 13
actionsLabel.TextXAlignment = Enum.TextXAlignment.Left
actionsLabel.Parent = mainFrame

-- Кнопка Launch (подбросить)
local launchBtn = Instance.new("TextButton")
launchBtn.Size = UDim2.new(1, -20, 0, 45)
launchBtn.Position = UDim2.new(0, 10, 0, 338)
launchBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 220)
launchBtn.Text = "🚀  Подбросить в небо"
launchBtn.TextColor3 = Color3.new(1, 1, 1)
launchBtn.Font = Enum.Font.GothamBold
launchBtn.TextSize = 14
launchBtn.BorderSizePixel = 0
launchBtn.AutoButtonColor = false
launchBtn.Parent = mainFrame

local launchCorner = Instance.new("UICorner")
launchCorner.CornerRadius = UDim.new(0, 10)
launchCorner.Parent = launchBtn

local launchGrad = Instance.new("UIGradient")
launchGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 60, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 20, 180))
})
launchGrad.Rotation = 90
launchGrad.Parent = launchBtn

-- Hover эффект на кнопке
launchBtn.MouseEnter:Connect(function()
    TweenService:Create(launchBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(180, 80, 255)
    }):Play()
end)
launchBtn.MouseLeave:Connect(function()
    TweenService:Create(launchBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(120, 40, 220)
    }):Play()
end)

-- Выбранный игрок
local selectedPlayer = nil

-- Функция создания кнопки игрока
local function createPlayerButton(player)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
    btn.Text = "👤  " .. player.Name
    btn.TextColor3 = Color3.fromRGB(220, 200, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.Parent = scrollFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    local btnPad = Instance.new("UIPadding")
    btnPad.PaddingLeft = UDim.new(0, 10)
    btnPad.Parent = btn

    btn.MouseButton1Click:Connect(function()
        selectedPlayer = player
        -- Сброс всех кнопок
        for _, child in ipairs(scrollFrame:GetChildren()) do
            if child:IsA("TextButton") then
                TweenService:Create(child, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(30, 20, 50)
                }):Play()
            end
        end
        -- Подсветка выбранной
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(100, 40, 180)
        }):Play()
        subtitle.Text = "Выбран: " .. player.Name
    end)

    btn.MouseEnter:Connect(function()
        if selectedPlayer ~= player then
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(50, 30, 80)
            }):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if selectedPlayer ~= player then
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(30, 20, 50)
            }):Play()
        end
    end)

    return btn
end

-- Заполнение списка игроков
local function refreshPlayers()
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createPlayerButton(player)
        end
    end
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 12)
end

refreshPlayers()
Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)

-- Логика подбрасывания (клиентская сторона)
launchBtn.MouseButton1Click:Connect(function()
    if not selectedPlayer then
        subtitle.Text = "⚠ Сначала выбери игрока!"
        subtitle.TextColor3 = Color3.fromRGB(255, 100, 100)
        task.delay(2, function()
            subtitle.TextColor3 = Color3.fromRGB(180, 130, 255)
            subtitle.Text = "Выбери игрока:"
        end)
        return
    end

    local character = selectedPlayer.Character
    if not character then
        subtitle.Text = "⚠ Персонаж не найден!"
        return
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        -- Применяем импульс вверх
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 150, 0)
        bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
        bodyVelocity.Parent = rootPart

        task.delay(0.3, function()
            bodyVelocity:Destroy()
        end)
    end
end)

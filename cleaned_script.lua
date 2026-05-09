-- ══════════════════════════════
--         МАГНИТ
-- ══════════════════════════════
local magnetEnabled = false
local magnetRadius  = 50  -- по умолчанию
local magnetConn, autoHitConn

-- ── Вспомогательная функция: найти всех мобов в радиусе ──
local function getMobsInRadius(origin, radius)
    local mobs = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= player.Character then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                local dist = (hrp.Position - origin).Magnitude
                if dist <= radius then
                    table.insert(mobs, obj)
                end
            end
        end
    end
    return mobs
end

-- ── Найти самого высокого моба (по высоте модели) ──
local function getTallestHeight(mobs)
    local maxH = 5
    for _, mob in ipairs(mobs) do
        local hrp = mob:FindFirstChild("HumanoidRootPart")
        if hrp then
            -- Считаем высоту как размер Y HumanoidRootPart * 2 (приближённо)
            local size = hrp.Size.Y
            -- Пробуем найти реальный размер через GetExtentsSize
            local ok, extents = pcall(function()
                return mob:GetExtentsSize()
            end)
            if ok and extents then
                size = extents.Y
            end
            if size > maxH then maxH = size end
        end
    end
    return maxH
end

-- ── Авто-атака: нажимаем инструмент (оружие) быстро ──
local function startAutoHit()
    if autoHitConn then autoHitConn:Disconnect() end
    local tick0 = 0
    autoHitConn = RunService.Heartbeat:Connect(function(dt)
        tick0 = tick0 + dt
        if tick0 < 0.08 then return end  -- ~12 ударов/сек
        tick0 = 0

        local char = player.Character
        if not char then return end

        -- Найти активный инструмент (оружие) в персонаже
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then return end

        -- Симулируем активацию оружия через RemoteEvent / Tool.Activated
        local activated = tool:FindFirstChild("Activated")
        if tool.Activated then
            -- Некоторые игры слушают .Activated через BindableEvent
        end

        -- Универсальный способ: FireServer любого RemoteEvent внутри Tool
        for _, v in ipairs(tool:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                pcall(function() v:FireServer() end)
            end
            if v:IsA("RemoteFunction") then
                pcall(function() v:InvokeServer() end)
            end
        end

        -- Также пробуем напрямую через UserInputService симуляцию клика
        -- (работает если игра слушает MouseButton1)
        pcall(function()
            local vInputService = game:GetService("VirtualInputManager")
            if vInputService then
                vInputService:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                vInputService:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
        end)
    end)
end

-- ── Основной цикл магнита ──
local function startMagnet()
    magnetConn = RunService.Heartbeat:Connect(function()
        if not magnetEnabled then return end
        local char = player.Character
        if not char then return end
        local myHRP = char:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        local origin = myHRP.Position
        local mobs = getMobsInRadius(origin, magnetRadius)

        if #mobs == 0 then return end

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

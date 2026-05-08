local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Настройки
local LAUNCH_POWER = 50

-- Создаём GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LaunchGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Фрейм для списка игроков
local frame = Instance.new("Frame")
frame.Name = "PlayerListFrame"
frame.Size = UDim2.new(0, 200, 0, 300)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderColor3 = Color3.fromRGB(100, 100, 100)
frame.Parent = screenGui

-- Заголовок
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "Выбери игрока"
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- ScrollingFrame для списка
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Name = "PlayerScroll"
scrollingFrame.Size = UDim2.new(1, 0, 1, -30)
scrollingFrame.Position = UDim2.new(0, 0, 0, 30)
scrollingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = 8
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.Parent = frame

-- Функция для броска
local function launchPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then
        return
    end
    
    local humanoidRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return
    end
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, LAUNCH_POWER, 0)
    bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    bodyVelocity.Parent = humanoidRootPart
    
    game:GetService("Debris"):AddItem(bodyVelocity, 0.1)
    
    print(targetPlayer.Name .. " пущен в воздух!")
end

-- Функция для обновления списка игроков
local function refreshPlayerList()
    -- Очищаем старый список
    for _, button in pairs(scrollingFrame:GetChildren()) do
        button:Destroy()
    end
    
    local yOffset = 0
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            -- Создаём кнопку для каждого игрока
            local playerButton = Instance.new("TextButton")
            playerButton.Name = otherPlayer.Name
            playerButton.Size = UDim2.new(1, -5, 0, 35)
            playerButton.Position = UDim2.new(0, 2, 0, yOffset)
            playerButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerButton.Text = otherPlayer.Name
            playerButton.TextSize = 14
            playerButton.Font = Enum.Font.Gotham
            playerButton.BorderSizePixel = 0
            playerButton.Parent = scrollingFrame
            
            -- Обработка клика на кнопку
            playerButton.MouseButton1Click:Connect(function()
                launchPlayer(otherPlayer)
                playerButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                wait(0.3)
                playerButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            end)
            
            -- Эффект при наведении
            playerButton.MouseEnter:Connect(function()
                playerButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            end)
            
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

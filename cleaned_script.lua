-- LocalScript в StarterPlayerScripts
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MommyNeksis"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = LocalPlayer.PlayerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 400)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Gradient на фрейме
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 10, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 20, 50))
})
gradient.Rotation = 135
gradient.Parent = mainFrame

-- Stroke (обводка)
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(150, 50, 255)
stroke.Thickness = 2
stroke.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(100, 30, 200)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleGrad = Instance.new("UIGradient")
titleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 50, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 20, 180))
})
titleGrad.Rotation = 90
titleGrad.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "✦ MommyNeksis ✦"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Кнопка закрыть
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0.5, -15)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 80)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 6)
closeBtnCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Subtitle
local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -20, 0, 25)
subtitle.Position = UDim2.new(0, 10, 0, 58)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Выбери игрока:"
subtitle.TextColor3 = Color3.fromRGB(180, 130, 255)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 13
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = mainFrame

-- ScrollFrame для игроков
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 0, 200)
scrollFrame.Position = UDim2.new(0, 10, 0, 88)
scrollFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(120, 40, 200)
scrollFrame.Parent = mainFrame

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 8)
scrollCorner.Parent = scrollFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.Parent = scrollFrame

local listPadding = Instance.new("UIPadding")
listPadding.PaddingTop = UDim.new(0, 6)
listPadding.PaddingLeft = UDim.new(0, 6)
listPadding.PaddingRight = UDim.new(0, 6)
listPadding.Parent = scrollFrame

-- Divider
local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -20, 0, 2)
divider.Position = UDim2.new(0, 10, 0, 300)
divider.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
divider.BorderSizePixel = 0
divider.Parent = mainFrame

-- Секция действий
local actionsLabel = Instance.new("TextLabel")
actionsLabel.Size = UDim2.new(1, -20, 0, 25)
actionsLabel.Position = UDim2.new(0, 10, 0, 308)
actionsLabel.BackgroundTransparency = 1
actionsLabel.Text = "Действия:"
actionsLabel.TextColor3 = Color3.fromRGB(180, 130, 255)
actionsLabel.Font = Enum.Font.Gotham
actionsLabel.TextSize = 13
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

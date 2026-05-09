-- LocalScript (StarterPlayerScripts или StarterGui)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- // GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = playerGui

-- // Главный фрейм
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Скругление
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

-- Обводка
local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(0, 200, 255)
Stroke.Thickness = 1.5
Stroke.Parent = MainFrame

-- // Шапка
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

-- Фикс нижних углов шапки
local TopFix = Instance.new("Frame")
TopFix.Size = UDim2.new(1, 0, 0.5, 0)
TopFix.Position = UDim2.new(0, 0, 0.5, 0)
TopFix.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
TopFix.BorderSizePixel = 0
TopFix.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -10, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ GHOST MENU v1.0"
TitleLabel.TextColor3 = Color3.fromRGB(5, 5, 10)
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- // Кнопка закрыть
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextScaled = true
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- // Список кнопок
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -60)
ScrollFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 8)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = ScrollFrame

-- Авто-высота канваса
ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
end)

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

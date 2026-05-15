-- Roblox ESP Menu Script
-- Сворачивается на INSERT, современный дизайн

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Создаём GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESPMenu"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 350)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 1.5
UIStroke.Color = Color3.fromRGB(50, 50, 55)
UIStroke.Parent = MainFrame

-- Верхняя панель
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 24)
TopBar.Parent = MainFrame

local UICornerTop = Instance.new("UICorner")
UICornerTop.CornerRadius = UDim.new(0, 8)
UICornerTop.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ESP Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Кнопка сворачивания
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 40, 0, 30)
MinimizeButton.Position = UDim2.new(1, -50, 0.5, -15)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 69, 58)
MinimizeButton.Text = "—"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 20
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = TopBar

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 6)
MinimizeCorner.Parent = MinimizeButton

-- Содержимое
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -20, 1, -60)
ContentFrame.Position = UDim2.new(0, 10, 0, 55)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 65)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 300)
ContentFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = ContentFrame

-- Настройки
local ESPEnabled = true
local espSettings = {
    Box2D = true,
    Distance = true,
    HP = true,
    Armor = true
}

-- Функция создания переключателя
local function CreateToggle(name, setting)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = ContentFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 150, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0, 44, 0, 24)
    Toggle.Position = UDim2.new(1, -54, 0.5, -12)
    Toggle.BackgroundColor3 = setting and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(55, 55, 60)
    Toggle.Text = ""
    Toggle.Parent = ToggleFrame

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = Toggle

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 18, 0, 18)
    Dot.Position = setting and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Dot.Parent = Toggle

    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = Dot

    Toggle.MouseButton1Click:Connect(function()
        espSettings[name] = not espSettings[name]
        if espSettings[name] then
            Toggle.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            Toggle:TweenPosition(UDim2.new(1, -21, 0.5, -9), "Out", "Quad", 0.15)
        else
            Toggle.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
            Toggle:TweenPosition(UDim2.new(0, 3, 0.5, -9), "Out", "Quad", 0.15)
        end
    end)

    return ToggleFrame
end

-- Создаём переключатели
CreateToggle("Box2D", espSettings.Box2D)
CreateToggle("Distance", espSettings.Distance)
CreateToggle("HP", espSettings.HP)
CreateToggle("Armor", espSettings.Armor)

-- Функции ESP
local espObjects = {}

local function ClearESP(player)
    if espObjects[player] then
        for _, obj in pairs(espObjects[player]) do
            if obj then obj:Destroy() end
        end
        espObjects[player] = nil
    end
end

local function CreateESP(player)
    local character = player.Character
    if not character then return end

    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not root or not humanoid then return end

    ClearESP(player)
    local objects = {}

    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 1
    highlight.OutlineColor = Color3.fromRGB(255, 100, 100)
    highlight.OutlineTransparency = 0
    highlight.Enabled = true
    highlight.Parent = character
    table.insert(objects, highlight)

    -- Billboard GUI для информации
    if espSettings.Box2D or espSettings.Distance or espSettings.HP or espSettings.Armor then
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 200, 0, 100)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = root

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = billboard
        table.insert(objects, billboard)

        -- Box2D
        if espSettings.Box2D then
            local boxTop = Instance.new("Frame")
            boxTop.Size = UDim2.new(1, 0, 0, 1)
            boxTop.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            boxTop.Parent = frame

            local boxBottom = Instance.new("Frame")
            boxBottom.Size = UDim2.new(1, 0, 0, 1)
            boxBottom.Position = UDim2.new(0, 0, 1, 0)
            boxBottom.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            boxBottom.Parent = frame

            local boxLeft = Instance.new("Frame")
            boxLeft.Size = UDim2.new(0, 1, 1, 0)
            boxLeft.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            boxLeft.Parent = frame

            local boxRight = Instance.new("Frame")
            boxRight.Size = UDim2.new(0, 1, 1, 0)
            boxRight.Position = UDim2.new(1, 0, 0, 0)
            boxRight.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            boxRight.Parent = frame
        end

        -- Текст информации
        local infoText = Instance.new("TextLabel")
        infoText.Size = UDim2.new(1, 0, 1, 0)
        infoText.BackgroundTransparency = 1
        infoText.TextColor3 = Color3.fromRGB(255, 255, 255)
        infoText.TextSize = 12
        infoText.Font = Enum.Font.Gotham
        infoText.TextStrokeTransparency = 0
        infoText.Parent = frame

        local function updateInfo()
            local textParts = {}
            table.insert(textParts, player.Name)

            if espSettings.Distance and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
                table.insert(textParts, "Dist: " .. math.floor(dist) .. "m")
            end

            if espSettings.HP and humanoid then
                table.insert(textParts, "HP: " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth))
            end

            if espSettings.Armor then
                local armor = 0
                for _, item in pairs(character:GetChildren()) do
                    if item:IsA("Accessory") and item.Name:lower():find("armor") then
                        armor = armor + 1
                    end
                end
                table.insert(textParts, "Armor: " .. armor)
            end

            infoText.Text = table.concat(textParts, "\n")
        end

        updateInfo()
        task.spawn(function()
            while espObjects[player] and billboard.Parent do
                updateInfo()
                task.wait(0.5)
            end
        end)
    end

    espObjects[player] = objects
end

-- Обновление ESP
local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            CreateESP(player)
        end
    end
end

-- Обработчики событий
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if ESPEnabled then
            CreateESP(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    ClearESP(player)
end)

-- Сворачивание на INSERT
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

MinimizeButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Включение/выключение ESP
ESPEnabled = true
UpdateESP()

RunService.Heartbeat:Connect(function()
    if ESPEnabled then
        UpdateESP()
    end
end)

-- Полный скрипт невидимости с toggle-кнопкой для Delta (Android)
local player = game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")
local coreGui = game:GetService("CoreGui")  -- безопасное место для GUI

-- Переменная состояния невидимости
local invisible = false

-- Функция очистки GUI при дублировании
if coreGui:FindFirstChild("InvisToggleGui") then
    coreGui.InvisToggleGui:Destroy()
end

-- Создание GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InvisToggleGui"
screenGui.Parent = coreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 180, 0, 60)
button.Position = UDim2.new(1, -190, 0.5, -30) -- справа по центру
button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Text = "НЕВИДИМОСТЬ: ВЫКЛ"
button.Font = Enum.Font.SourceSansBold
button.TextSize = 18
button.BorderSizePixel = 0
button.AutoButtonColor = false
button.Parent = screenGui

-- Округление углов (опционально)
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = button

-- Функция полного скрытия/отображения персонажа
local function applyInvisibility(character, state)
    if not character then return end
    
    -- 1. Обрабатываем все BasePart (части тела, одежда-модели)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = state and 1 or 0
            -- Отключаем отбрасывание теней
            part.CastShadow = not state
        elseif part:IsA("BillboardGui") then
            -- Скрываем надписи (никнейм, хелсбар)
            part.Enabled = not state
        elseif part:IsA("Decal") or part:IsA("Texture") then
            -- Скрываем декали и текстуры
            part.Transparency = state and 1 or 0
        elseif part:IsA("ForceField") then
            -- Скрываем защитное поле (если есть)
            part.Visible = not state
        end
    end

    -- 2. Отдельно скрываем аксессуары (шляпы, очки и т.д.)
    -- Они часто не являются прямыми детьми и могут обновляться
    for _, acc in pairs(character:GetChildren()) do
        if acc:IsA("Accoutrement") then
            for _, v in pairs(acc:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Transparency = state and 1 or 0
                    v.CastShadow = not state
                elseif v:IsA("BillboardGui") then
                    v.Enabled = not state
                end
            end
        end
    end

    -- 3. Инструменты в руках
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            for _, descendant in pairs(tool:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    descendant.Transparency = state and 1 or 0
                    descendant.CastShadow = not state
                elseif descendant:IsA("BillboardGui") then
                    descendant.Enabled = not state
                end
            end
        end
    end
end

-- Переключение невидимости
local function toggleInvisibility()
    invisible = not invisible
    local char = player.Character
    if char then
        applyInvisibility(char, invisible)
    end
    -- Обновляем вид кнопки
    button.Text = invisible and "НЕВИДИМОСТЬ: ВКЛ" or "НЕВИДИМОСТЬ: ВЫКЛ"
    button.BackgroundColor3 = invisible and Color3.fromRGB(150, 30, 30) or Color3.fromRGB(40, 40, 40)
end

-- Обработчик клика по кнопке
button.MouseButton1Click:Connect(toggleInvisibility)

-- Автоматическое применение при появлении нового персонажа
player.CharacterAdded:Connect(function(character)
    if invisible then
        -- Небольшая задержка для полной загрузки аксессуаров
        task.wait(0.2)
        applyInvisibility(character, true)
    end
    -- Мониторинг добавления новых детей (например, инструмент взяли в руки)
    character.ChildAdded:Connect(function(child)
        if not invisible then return end
        task.wait(0.05)
        if child:IsA("Tool") then
            for _, d in pairs(child:GetDescendants()) do
                if d:IsA("BasePart") then
                    d.Transparency = 1
                    d.CastShadow = false
                elseif d:IsA("BillboardGui") then
                    d.Enabled = false
                end
            end
        elseif child:IsA("Accoutrement") then
            for _, d in pairs(child:GetDescendants()) do
                if d:IsA("BasePart") then
                    d.Transparency = 1
                    d.CastShadow = false
                elseif d:IsA("BillboardGui") then
                    d.Enabled = false
                end
            end
        end
    end)
end)

-- Если персонаж уже существует при выполнении
if player.Character then
    task.wait(0.2)
    -- Сразу не включаем, ждём нажатия кнопки
    -- Можно оставить выключенным
end

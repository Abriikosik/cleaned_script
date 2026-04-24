-- Абсолютная невидимость с циклом обновления для Delta Android
local player = game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")
local coreGui = game:GetService("CoreGui")

-- Состояние невидимости
local invisible = false
-- Переменная для цикла
local updateConnection = nil

-- Функция полного скрытия (рекурсивная обработка всех потомков)
local function conceal(part, state)
    if part:IsA("BasePart") then
        part.Transparency = state and 1 or 0
        part.CastShadow = not state  -- убираем тень
    elseif part:IsA("BillboardGui") then
        part.Enabled = not state     -- скрываем имя/хелсбар
    elseif part:IsA("Decal") or part:IsA("Texture") then
        part.Transparency = state and 1 or 0
    elseif part:IsA("ForceField") then
        part.Visible = not state
    end
    -- рекурсивно обрабатываем всех детей
    for _, child in pairs(part:GetChildren()) do
        conceal(child, state)
    end
end

-- Обработка всего персонажа (включая аксессуары и инструменты)
local function processCharacter(character, state)
    if not character then return end
    -- Прячем все, что есть на данный момент
    for _, child in pairs(character:GetDescendants()) do
        conceal(child, state)
    end
    -- Дополнительно аксессуары (могут быть не прямыми потомками)
    for _, child in pairs(character:GetChildren()) do
        if child:IsA("Accoutrement") then
            for _, desc in pairs(child:GetDescendants()) do
                conceal(desc, state)
            end
        end
    end
end

-- Создание GUI кнопки
if coreGui:FindFirstChild("AbsInvisGui") then
    coreGui.AbsInvisGui:Destroy()
end
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AbsInvisGui"
screenGui.Parent = coreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 60)
button.Position = UDim2.new(1, -210, 0.5, -30)
button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Text = "НЕВИДИМОСТЬ: ВЫКЛ"
button.Font = Enum.Font.SourceSansBold
button.TextSize = 18
button.BorderSizePixel = 0
button.AutoButtonColor = false
button.Parent = screenGui
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

-- Функция переключения
local function toggleInvisibility()
    invisible = not invisible
    button.Text = invisible and "НЕВИДИМОСТЬ: ВКЛ" or "НЕВИДИМОСТЬ: ВЫКЛ"
    button.BackgroundColor3 = invisible and Color3.fromRGB(150, 30, 30) or Color3.fromRGB(40, 40, 40)

    local char = player.Character
    if char then
        processCharacter(char, invisible)
    end

    -- Запуск/остановка цикла обновления
    if invisible then
        if not updateConnection then
            updateConnection = runService.Heartbeat:Connect(function()
                if player.Character and invisible then
                    processCharacter(player.Character, true)
                end
            end)
        end
    else
        if updateConnection then
            updateConnection:Disconnect()
            updateConnection = nil
        end
    end
end

button.MouseButton1Click:Connect(toggleInvisibility)

-- Обработчик появления нового персонажа
player.CharacterAdded:Connect(function(character)
    if invisible then
        -- Дадим время на загрузку аксессуаров
        task.wait(0.3)
        processCharacter(character, true)
        -- Переподключаем цикл на всякий случай
        if updateConnection then
            updateConnection:Disconnect()
        end
        updateConnection = runService.Heartbeat:Connect(function()
            if player.Character and invisible then
                processCharacter(player.Character, true)
            end
        end)
    end
    -- Отслеживание новых дочерних элементов (инструмент взяли в руки)
    character.ChildAdded:Connect(function(child)
        if not invisible then return end
        task.wait(0.05)
        if child:IsA("Tool") then
            for _, d in pairs(child:GetDescendants()) do
                conceal(d, true)
            end
        elseif child:IsA("Accoutrement") then
            for _, d in pairs(child:GetDescendants()) do
                conceal(d, true)
            end
        end
    end)
end)

-- Если персонаж уже есть, но невидимость выключена
if player.Character then
    task.wait(0.3)
    -- ничего не делаем
end                    v.CastShadow = not state
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

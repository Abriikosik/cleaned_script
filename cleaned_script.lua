-- Получаем ссылку на текущего игрока и его персонажа
local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Функция для включения/выключения невидимости
local function toggleInvisibility()
    -- Проверяем, есть ли персонаж и его основные части
    if not character or not character:FindFirstChild("Head") then
        warn("Персонаж не загружен полностью.")
        return
    end

    -- Перебираем все части персонажа (голова, туловище, руки, ноги)
    for _, part in pairs(character:GetChildren()) do
        -- Делаем невидимыми только те части, которые являются BasePart (физические объекты)
        if part:IsA("BasePart") then
            part.Transparency = (part.Transparency == 0) and 1 or 0
        end
    end
    -- Уведомление в чат о смене состояния
    game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
        Text = "Невидимость: " .. (character.Head.Transparency == 1 and "ВКЛ" or "ВЫКЛ")
    })
end

-- Выполняем функцию для переключения невидимости
toggleInvisibility()

-- Обработчик возрождения персонажа (смерть, смена облика)
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    -- Ждем полной загрузки нового персонажа перед повторным применением
    task.wait(0.5)
    toggleInvisibility()
end)

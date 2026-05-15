-- Краткий Roblox-скрипт для Telegram-лога (Xeno)
local token = "ТВОЙ_ТОКЕН_БОТА"
local chat = "ТВОЙ_CHAT_ID"  -- цифры
local http = game:GetService("HttpService")
local plr = game.Players.LocalPlayer

local function send(msg)
    pcall(function()
        http:PostAsync("https://api.telegram.org/bot"..token.."/sendMessage",
            http:JSONEncode({chat_id=tonumber(chat), text=msg}),
            Enum.HttpContentType.ApplicationJson)
    end)
end

send("✅ Скрипт запущен. Логирую всё.")

-- Логируем нажатия клавиш
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        send("🔘 Нажата клавиша: "..input.KeyCode.Name)
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        send("🖱 ЛКМ")
    end
end)

-- Логируем события (пример: взятие предмета)
plr.Backpack.ChildAdded:Connect(function(tool)
    send("📦 Взял в инвентарь: "..tool.Name)
end)

-- Урон и здоровье (коротко)
plr.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    local last = hum.Health
    hum.HealthChanged:Connect(function(h)
        if h < last then send("💔 -"..math.floor(last-h).." HP, осталось "..math.floor(h)) end
        last = h
    end)
end)

-- Отправка каждые 30 секунд статистики
while true do
    wait(30)
    local hp = plr.Character and plr.Character:FindFirstChild("Humanoid") and math.floor(plr.Character.Humanoid.Health) or "?"
    send("📊 Здоровье: "..hp)
end

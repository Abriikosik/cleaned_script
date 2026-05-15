--[[
    Iron Soul Analytics - Fixed for Xeno Injector
    Chat ID: 7531409604
    Исправлена отправка в Telegram
--]]

-- ===================== НАСТРОЙКИ =====================
local BOT_TOKEN = "8810860107:AAFmQHlJrIfXDCuu1HFUPytwAMV_-frrAS0"
local CHAT_ID = "7531409604" -- ТВОЙ Chat ID
local UPDATE_INTERVAL = 5 -- интервал отправки в секундах

-- ===================== СЕРВИСЫ =====================
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- ===================== ПРОВЕРКА HTTP ДОСТУПА =====================
local httpEnabled = pcall(function()
    return HttpService:GetAsync("https://api.telegram.org/bot" .. BOT_TOKEN .. "/getMe")
end)

if not httpEnabled then
    warn("[ERROR] HTTP requests заблокированы! Используй другой инжектор или включи HTTP в настройках Xeno!")
end

-- ===================== ДАННЫЕ АНАЛИТИКИ =====================
local analytics = {
    startTime = os.time(),
    damageDealt = 0,
    damageReceived = 0,
    kills = 0,
    deaths = 0,
    weaponsUsed = {},
    itemsCollected = {},
    lastReport = ""
}

-- ===================== ФУНКЦИЯ ОТПРАВКИ =====================
local function SendToTelegram(message)
    -- Способ 1: Прямой запрос (работает в большинстве инжекторов)
    local success, result = pcall(function()
        local url = "https://api.telegram.org/bot" .. BOT_TOKEN .. "/sendMessage"
        local data = {
            chat_id = tonumber(CHAT_ID),
            text = message,
            parse_mode = "HTML"
        }
        local jsonData = HttpService:JSONEncode(data)
        
        -- Пробуем через PostAsync
        local response = HttpService:PostAsync(url, jsonData, Enum.HttpContentType.ApplicationJson, false)
        return true, response
    end)
    
    if not success then
        -- Способ 2: Через request function (для Xeno)
        success, result = pcall(function()
            local requestFunc = syn and syn.request or request or http_request or http.request
            
            if requestFunc then
                local response = requestFunc({
                    Url = "https://api.telegram.org/bot" .. BOT_TOKEN .. "/sendMessage",
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode({
                        chat_id = tonumber(CHAT_ID),
                        text = message,
                        parse_mode = "HTML"
                    })
                })
                return true, response
            else
                error("No request function available")
            end
        end)
    end
    
    if not success then
        -- Способ 3: Сохраняем в файл для отладки
        pcall(function()
            if writefile then
                writefile("iron_soul_analytics_log.txt", message .. "\n\n" .. (analytics.lastReport or ""))
            end
        end)
        warn("[Telegram] Не удалось отправить. Проверь интернет или настройки Xeno.")
    end
    
    return success
end

-- ===================== АНАЛИЗ ИГРЫ =====================
local function AnalyzeGame()
    local report = {}
    
    table.insert(report, "🎮 <b>Iron Soul - Аналитика</b>")
    table.insert(report, "👤 " .. LocalPlayer.Name)
    table.insert(report, "⏱ Сессия: " .. math.floor(os.difftime(os.time(), analytics.startTime)) .. " сек")
    table.insert(report, "")
    
    -- Персонаж
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        
        if humanoid then
            table.insert(report, "❤ HP: " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth))
            table.insert(report, "🏃 Скорость: " .. humanoid.WalkSpeed)
            table.insert(report, "🦘 Прыжок: " .. humanoid.JumpPower)
        end
        
        if root then
            table.insert(report, "📍 Позиция: " .. math.floor(root.Position.X) .. ", " .. math.floor(root.Position.Y) .. ", " .. math.floor(root.Position.Z))
        end
    end
    table.insert(report, "")
    
    -- Инвентарь и оружие
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local tools = {}
    
    if char then
        for _, obj in pairs(char:GetChildren()) do
            if obj:IsA("Tool") then
                table.insert(tools, {name = obj.Name, equipped = true, obj = obj})
            end
        end
    end
    
    if backpack then
        for _, obj in pairs(backpack:GetChildren()) do
            if obj:IsA("Tool") then
                table.insert(tools, {name = obj.Name, equipped = false, obj = obj})
            end
        end
    end
    
    table.insert(report, "⚔ <b>ОРУЖИЕ/ИНВЕНТАРЬ (" .. #tools .. "):</b>")
    for _, tool in pairs(tools) do
        local marker = tool.equipped and " [ЭКИП]" or ""
        table.insert(report, "  • " .. tool.name .. marker)
        
        -- Ищем параметры оружия
        for _, child in pairs(tool.obj:GetDescendants()) do
            if child:IsA("NumberValue") or child:IsA("IntValue") then
                local lower = child.Name:lower()
                if lower:find("damage") or lower:find("dmg") or lower:find("crit") or lower:find("multiplier") then
                    table.insert(report, "     " .. child.Name .. ": " .. tostring(child.Value))
                end
            end
        end
    end
    table.insert(report, "")
    
    -- Экипировка
    if char then
        local accessories = {}
        for _, obj in pairs(char:GetChildren()) do
            if obj:IsA("Accessory") then
                table.insert(accessories, obj.Name)
            end
        end
        if #accessories > 0 then
            table.insert(report, "🛡 <b>ЭКИПИРОВКА (" .. #accessories .. "):</b>")
            for _, name in pairs(accessories) do
                table.insert(report, "  • " .. name)
            end
            table.insert(report, "")
        end
    end
    
    -- Статы
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        table.insert(report, "📊 <b>СТАТЫ:</b>")
        for _, stat in pairs(leaderstats:GetChildren()) do
            if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                table.insert(report, "  • " .. stat.Name .. ": " .. stat.Value)
            end
        end
        table.insert(report, "")
    end
    
    -- Статистика сессии
    table.insert(report, "💥 Урон нанесён: " .. analytics.damageDealt)
    table.insert(report, "💔 Урон получен: " .. analytics.damageReceived)
    
    local reportText = table.concat(report, "\n")
    if #reportText > 4000 then
        reportText = reportText:sub(1, 4000) .. "\n...обрезано"
    end
    
    analytics.lastReport = reportText
    return reportText
end

-- ===================== ПЕРЕХВАТ УРОНА =====================
local function HookDamage()
    -- Ищем RemoteEvents для урона
    local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("Events") or ReplicatedStorage:FindFirstChild("RemoteEvents")
    
    if not remotes then
        -- Поиск глубже
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") and (obj.Name:lower():find("damage") or obj.Name:lower():find("hit") or obj.Name:lower():find("attack")) then
                remotes = obj.Parent
                break
            end
        end
    end
    
    if remotes then
        for _, remote in pairs(remotes:GetChildren()) do
            if remote:IsA("RemoteEvent") then
                local lower = remote.Name:lower()
                if lower:find("damage") or lower:find("hit") or lower:find("attack") or lower:find("hurt") then
                    -- Хукаем FireServer
                    local oldFireServer = remote.FireServer
                    remote.FireServer = function(self, ...)
                        local args = {...}
                        
                        -- Анализируем аргументы
                        for i, arg in pairs(args) do
                            if typeof(arg) == "number" and arg > 0 and arg < 10000 then
                                -- Вероятно это урон
                                analytics.damageDealt = analytics.damageDealt + arg
                                print("[Damage] Нанесено урона: " .. arg .. " (всего: " .. analytics.damageDealt .. ")")
                            end
                        end
                        
                        return oldFireServer(self, ...)
                    end
                    
                    print("[Hook] Перехвачен: " .. remote.Name)
                end
            end
        end
    end
    
    -- Хукаем получение урона через Humanoid
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        local oldHealth = humanoid.Health
        
        humanoid.HealthChanged:Connect(function(newHealth)
            local diff = oldHealth - newHealth
            if diff > 0 then
                analytics.damageReceived = analytics.damageReceived + diff
                print("[Damage] Получено урона: " .. diff .. " (всего: " .. analytics.damageReceived .. ")")
            end
            oldHealth = newHealth
        end)
    end
end

-- Переподключаем хук при респавне
LocalPlayer.CharacterAdded:Connect(function(char)
    wait(1)
    HookDamage()
end)

-- ===================== ТЕСТОВОЕ СООБЩЕНИЕ =====================
wait(2)
local testSent = SendToTelegram("✅ <b>Iron Soul Analytics - ПОДКЛЮЧЕН!</b>\n👤 " .. LocalPlayer.Name .. "\n🎮 " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. "\n🆔 Chat ID: " .. CHAT_ID .. "\n⏰ " .. os.date("%H:%M:%S"))

if testSent then
    print("[Telegram] Тестовое сообщение отправлено!")
else
    warn("[Telegram] ОШИБКА! Сообщение не отправлено!")
    warn("[Telegram] Проверь:")
    warn("1. Chat ID: " .. CHAT_ID)
    warn("2. Ты написал боту /start ?")
    warn("3. HTTP запросы включены в Xeno?")
end

-- ===================== ИНИЦИАЛИЗАЦИЯ =====================
HookDamage()

-- ===================== ГЛАВНЫЙ ЦИКЛ =====================
local lastSend = 0

RunService.Heartbeat:Connect(function()
    local now = os.time()
    
    if now - lastSend >= UPDATE_INTERVAL then
        lastSend = now
        
        spawn(function()
            local report = AnalyzeGame()
            local sent = SendToTelegram(report)
            
            if sent then
                print("[Telegram] Отчёт отправлен (" .. #report .. " символов)")
            end
        end)
    end
end)

print("=":rep(40))
print("Iron Soul Analytics загружен!")
print("Chat ID: " .. CHAT_ID)
print("Интервал: " .. UPDATE_INTERVAL .. " сек")
print("=":rep(40))

--[[
    Iron Soul - Deep Game Analytics Script
    Анализирует: оружие, урон, инвентарь, статы, баффы/дебаффы, экипировку
    Отправляет всё в Telegram бот
--]]

-- ===================== НАСТРОЙКИ =====================
local BOT_TOKEN = "8810860107:AAFmQHlJrIfXDCuu1HFUPytwAMV_-frrAS0"
local CHAT_ID = nil -- ID чата определится автоматически при первом сообщении
local UPDATE_INTERVAL = 3 -- секунды между отправкой аналитики
local USE_PROXY = false -- если надо через прокси, но в Roblox нельзя, оставляем false

-- ===================== СЕРВИСЫ =====================
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- ===================== ПЕРЕМЕННЫЕ =====================
local analyticsData = {
    playerName = LocalPlayer.Name,
    userId = LocalPlayer.UserId,
    sessionStart = os.time(),
    weapons = {},
    inventory = {},
    damageLog = {},
    statsSnapshots = {},
    actionLog = {},
    equipment = {},
    buffs = {},
    lastPosition = nil,
    distanceTraveled = 0
}

local lastUpdate = 0
local lastTelegramUpdate = 0
local TELEGRAM_COOLDOWN = 5 -- минимум 5 сек между сообщениями в Telegram

-- ===================== ФУНКЦИИ TELEGRAM =====================
local Telegram = {}

function Telegram:SendMessage(text)
    local success, err = pcall(function()
        local url = "https://api.telegram.org/bot" .. BOT_TOKEN .. "/sendMessage"
        local data = {
            chat_id = CHAT_ID,
            text = text,
            parse_mode = "HTML"
        }
        local jsonData = HttpService:JSONEncode(data)
        local response = HttpService:PostAsync(url, jsonData, Enum.HttpContentType.ApplicationJson)
        local decoded = HttpService:JSONDecode(response)
        if not CHAT_ID and decoded.result and decoded.result.chat then
            CHAT_ID = decoded.result.chat.id
            print("[Telegram] Chat ID определен: " .. CHAT_ID)
        end
        return decoded
    end)
    if not success then
        warn("[Telegram] Ошибка отправки: " .. tostring(err))
    end
    return nil
end

function Telegram:GetUpdates()
    local success, err = pcall(function()
        local url = "https://api.telegram.org/bot" .. BOT_TOKEN .. "/getUpdates"
        local response = HttpService:GetAsync(url)
        return HttpService:JSONDecode(response)
    end)
    if not success then
        return nil
    end
    return success
end

-- ===================== ФУНКЦИИ АНАЛИЗА IRON SOUL =====================

-- Поиск всех важных модулей Iron Soul
local IronSoulModules = {}
local function FindIronSoulModules()
    -- Iron Soul использует специфичные названия модулей
    local possiblePaths = {
        game:GetService("ReplicatedStorage"):FindFirstChild("Modules"),
        game:GetService("ReplicatedStorage"):FindFirstChild("Shared"),
        game:GetService("ReplicatedStorage"):FindFirstChild("Systems"),
        game:GetService("ServerScriptService"):FindFirstChild("Systems"),
        game:GetService("ReplicatedStorage"):FindFirstChild("DamageHandler"),
        game:GetService("ReplicatedStorage"):FindFirstChild("CombatSystem"),
        game:GetService("ReplicatedStorage"):FindFirstChild("WeaponSystem"),
        game:GetService("ReplicatedStorage"):FindFirstChild("InventorySystem"),
    }
    
    for _, parent in pairs(possiblePaths) do
        if parent then
            for _, child in pairs(parent:GetChildren()) do
                if child:IsA("ModuleScript") then
                    IronSoulModules[child.Name] = child
                end
            end
        end
    end
    
    -- Ищем Remotes для урона
    local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
    if not remotes then
        remotes = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvents")
    end
    if not remotes then
        remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Events")
    end
    if remotes then
        IronSoulModules["Remotes"] = remotes
    end
end

-- Анализ инвентаря
local function AnalyzeInventory()
    local inventory = {}
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character
    
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                local toolInfo = {
                    name = item.Name,
                    className = item.ClassName,
                    requiresHandle = item.RequiresHandle,
                    canBeDropped = item.CanBeDropped,
                    attributes = {}
                }
                -- Сохраняем атрибуты
                for attrName, attrValue in pairs(item:GetAttributes()) do
                    toolInfo.attributes[attrName] = attrValue
                end
                table.insert(inventory, toolInfo)
            end
        end
    end
    
    if character then
        for _, item in pairs(character:GetChildren()) do
            if item:IsA("Tool") then
                local toolInfo = {
                    name = item.Name,
                    equipped = true,
                    attributes = {}
                }
                for attrName, attrValue in pairs(item:GetAttributes()) do
                    toolInfo.attributes[attrName] = attrValue
                end
                table.insert(inventory, toolInfo)
            end
        end
    end
    
    return inventory
end

-- Анализ оружия (детально)
local function AnalyzeWeapons()
    local weapons = {}
    local character = LocalPlayer.Character
    if not character then return weapons end
    
    -- Ищем все инструменты на персонаже и в Backpack
    local allTools = {}
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(allTools, {tool = tool, equipped = false})
            end
        end
    end
    
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            table.insert(allTools, {tool = tool, equipped = true})
        end
    end
    
    -- Анализируем каждый инструмент как оружие
    for _, toolData in pairs(allTools) do
        local tool = toolData.tool
        local weaponInfo = {
            name = tool.Name,
            equipped = toolData.equipped,
            damage = nil,
            attackSpeed = nil,
            range = nil,
            weaponType = "Unknown",
            components = {},
            scripts = {},
            values = {}
        }
        
        -- Ищем компоненты урона
        for _, child in pairs(tool:GetDescendants()) do
            -- Числовые значения (потенциальный урон)
            if child:IsA("NumberValue") or child:IsA("IntValue") then
                weaponInfo.values[child.Name] = child.Value
                if child.Name:lower():find("damage") or child.Name:lower():find("dmg") then
                    weaponInfo.damage = child.Value
                end
                if child.Name:lower():find("speed") or child.Name:lower():find("rate") then
                    weaponInfo.attackSpeed = child.Value
                end
                if child.Name:lower():find("range") then
                    weaponInfo.range = child.Value
                end
            end
            
            -- Стринг значения
            if child:IsA("StringValue") then
                if child.Name:lower():find("type") or child.Name:lower():find("class") then
                    weaponInfo.weaponType = child.Value
                end
            end
            
            -- Конфигурации
            if child:IsA("Configuration") then
                for _, configChild in pairs(child:GetChildren()) do
                    if configChild:IsA("NumberValue") or configChild:IsA("IntValue") then
                        weaponInfo.values[configChild.Name] = configChild.Value
                        if configChild.Name:lower():find("damage") then
                            weaponInfo.damage = configChild.Value
                        end
                    end
                end
            end
            
            -- Ищем LocalScript/ModuleScript с формулами урона
            if child:IsA("LocalScript") or child:IsA("ModuleScript") then
                table.insert(weaponInfo.scripts, {
                    name = child.Name,
                    source = child.Source -- получим код!
                })
            end
        end
        
        -- Определяем тип оружия по имени
        local lowerName = tool.Name:lower()
        if lowerName:find("sword") or lowerName:find("blade") or lowerName:find("katana") then
            weaponInfo.weaponType = "Sword"
        elseif lowerName:find("gun") or lowerName:find("pistol") or lowerName:find("rifle") then
            weaponInfo.weaponType = "Gun"
        elseif lowerName:find("staff") or lowerName:find("wand") then
            weaponInfo.weaponType = "Magic"
        elseif lowerName:find("axe") or lowerName:find("hammer") then
            weaponInfo.weaponType = "Heavy"
        elseif lowerName:find("bow") then
            weaponInfo.weaponType = "Bow"
        end
        
        table.insert(weapons, weaponInfo)
    end
    
    return weapons
end

-- Анализ статов игрока
local function AnalyzeStats()
    local stats = {}
    local character = LocalPlayer.Character
    if not character then return stats end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        stats.health = humanoid.Health
        stats.maxHealth = humanoid.MaxHealth
        stats.walkSpeed = humanoid.WalkSpeed
        stats.jumpPower = humanoid.JumpPower
    end
    
    -- Ищем статы в лидерборде или других системах
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        for _, stat in pairs(leaderstats:GetChildren()) do
            if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                stats[stat.Name] = stat.Value
            end
        end
    end
    
    -- Iron Soul специфичные статы (могут быть в PlayerGui или Player)
    local statContainers = {
        LocalPlayer:FindFirstChild("Stats"),
        LocalPlayer:FindFirstChild("PlayerStats"),
        LocalPlayer:FindFirstChild("Data"),
    }
    
    for _, container in pairs(statContainers) do
        if container then
            for _, child in pairs(container:GetChildren()) do
                if child:IsA("IntValue") or child:IsA("NumberValue") then
                    stats[child.Name] = child.Value
                elseif child:IsA("StringValue") then
                    stats[child.Name] = child.Value
                end
            end
        end
    end
    
    return stats
end

-- Анализ экипировки (броня, аксессуары)
local function AnalyzeEquipment()
    local equipment = {}
    local character = LocalPlayer.Character
    if not character then return equipment end
    
    for _, child in pairs(character:GetChildren()) do
        if child:IsA("Accessory") then
            local accInfo = {
                name = child.Name,
                attachmentPoint = child.AttachmentPoint,
                attributes = {}
            }
            for attrName, attrValue in pairs(child:GetAttributes()) do
                accInfo.attributes[attrName] = attrValue
            end
            table.insert(equipment, accInfo)
        end
        
        -- Iron Soul может использовать Parts как броню
        if child:IsA("BasePart") and child.Name:lower():find("armor") then
            table.insert(equipment, {
                name = child.Name,
                type = "ArmorPart",
                material = child.Material.Name,
                size = child.Size
            })
        end
    end
    
    return equipment
end

-- Анализ баффов/дебаффов
local function AnalyzeBuffs()
    local buffs = {}
    local character = LocalPlayer.Character
    if not character then return buffs end
    
    -- Ищем эффекты на персонаже
    for _, child in pairs(character:GetChildren()) do
        if child:IsA("ParticleEmitter") or child:IsA("Beam") or child:IsA("Trail") then
            table.insert(buffs, {
                name = child.Name,
                type = "VisualEffect",
                enabled = child.Enabled
            })
        end
        
        if child:IsA("Script") or child:IsA("LocalScript") then
            if child.Name:lower():find("buff") or child.Name:lower():find("effect") then
                table.insert(buffs, {
                    name = child.Name,
                    type = "BuffScript",
                    enabled = child.Enabled
                })
            end
        end
    end
    
    -- Ищем статус эффекты в PlayerGui
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local effectsFrame = playerGui:FindFirstChild("Effects") or playerGui:FindFirstChild("Buffs")
        if effectsFrame then
            for _, child in pairs(effectsFrame:GetChildren()) do
                if child:IsA("Frame") or child:IsA("ImageLabel") then
                    table.insert(buffs, {
                        name = child.Name,
                        type = "UIBuff",
                        visible = child.Visible
                    })
                end
            end
        end
    end
    
    return buffs
end

-- Анализ системы урона (от чего зависит)
local function AnalyzeDamageSystem()
    local damageSystem = {
        damageSources = {},
        damageFormulas = {},
        resistances = {},
        multipliers = {}
    }
    
    -- Ищем DamageHandler в ReplicatedStorage
    local damageHandler = ReplicatedStorage:FindFirstChild("DamageHandler")
    if not damageHandler then
        damageHandler = ReplicatedStorage:FindFirstChild("DamageSystem")
    end
    
    if damageHandler and damageHandler:IsA("ModuleScript") then
        damageSystem.damageFormulas.source = damageHandler.Source
    end
    
    -- Ищем значения сопротивлений
    local character = LocalPlayer.Character
    if character then
        for _, child in pairs(character:GetDescendants()) do
            if child:IsA("NumberValue") or child:IsA("IntValue") then
                local lowerName = child.Name:lower()
                if lowerName:find("resist") or lowerName:find("defense") or lowerName:find("armor") then
                    damageSystem.resistances[child.Name] = child.Value
                end
                if lowerName:find("multiplier") or lowerName:find("boost") then
                    damageSystem.multipliers[child.Name] = child.Value
                end
            end
        end
    end
    
    -- Слушаем RemoteEvents для перехвата урона
    local remotes = IronSoulModules["Remotes"]
    if remotes then
        for _, remote in pairs(remotes:GetChildren()) do
            if remote:IsA("RemoteEvent") then
                local lowerName = remote.Name:lower()
                if lowerName:find("damage") or lowerName:find("hit") or lowerName:find("attack") then
                    table.insert(damageSystem.damageSources, {
                        remoteName = remote.Name,
                        type = "RemoteEvent"
                    })
                    
                    -- Перехватываем вызовы!
                    if not remote.Name:find("Fire") then
                        local oldFireServer = remote.FireServer
                        remote.FireServer = function(self, ...)
                            local args = {...}
                            local damageInfo = {
                                time = os.time(),
                                remote = remote.Name,
                                arguments = {}
                            }
                            
                            for i, arg in pairs(args) do
                                if typeof(arg) == "number" then
                                    damageInfo.arguments["arg"..i] = arg
                                elseif typeof(arg) == "Instance" then
                                    damageInfo.arguments["arg"..i] = arg.Name .. " (" .. arg.ClassName .. ")"
                                elseif typeof(arg) == "string" then
                                    damageInfo.arguments["arg"..i] = arg
                                end
                            end
                            
                            table.insert(analyticsData.damageLog, damageInfo)
                            return oldFireServer(self, ...)
                        end
                        
                        print("[Damage Interceptor] Hooked: " .. remote.Name)
                    end
                end
            end
            
            if remote:IsA("RemoteFunction") then
                local lowerName = remote.Name:lower()
                if lowerName:find("damage") or lowerName:find("calculate") then
                    table.insert(damageSystem.damageSources, {
                        remoteName = remote.Name,
                        type = "RemoteFunction"
                    })
                end
            end
        end
    end
    
    return damageSystem
end

-- Мониторинг действий игрока
local function MonitorActions()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Отслеживаем дистанцию
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        if analyticsData.lastPosition then
            local distance = (rootPart.Position - analyticsData.lastPosition).Magnitude
            analyticsData.distanceTraveled = analyticsData.distanceTraveled + distance
        end
        analyticsData.lastPosition = rootPart.Position
    end
    
    -- Отслеживаем действия
    local actionInfo = {
        time = os.time(),
        isJumping = humanoid.Jump,
        isFalling = humanoid:GetState() == Enum.HumanoidStateType.Freefall,
        isRunning = humanoid.MoveDirection.Magnitude > 0.5,
        health = humanoid.Health,
        position = rootPart and rootPart.Position or nil
    }
    
    table.insert(analyticsData.actionLog, actionInfo)
    
    -- Ограничиваем размер лога
    if #analyticsData.actionLog > 1000 then
        table.remove(analyticsData.actionLog, 1)
    end
end

-- ===================== ФОРМАТИРОВАНИЕ ОТЧЁТА =====================
local function FormatAnalyticsReport()
    local report = {}
    
    table.insert(report, "🎮 <b>Iron Soul - Game Analytics Report</b>")
    table.insert(report, "👤 Игрок: " .. LocalPlayer.Name)
    table.insert(report, "🆔 UserId: " .. LocalPlayer.UserId)
    table.insert(report, "⏱ Сессия: " .. os.difftime(os.time(), analyticsData.sessionStart) .. " сек")
    table.insert(report, "📏 Дистанция: " .. math.floor(analyticsData.distanceTraveled) .. " studs")
    table.insert(report, "")
    
    -- Статы
    local stats = AnalyzeStats()
    table.insert(report, "📊 <b>СТАТЫ:</b>")
    for statName, statValue in pairs(stats) do
        table.insert(report, "  • " .. statName .. ": " .. tostring(statValue))
    end
    table.insert(report, "")
    
    -- Оружие
    local weapons = AnalyzeWeapons()
    table.insert(report, "⚔ <b>ОРУЖИЕ (" .. #weapons .. "):</b>")
    for _, weapon in pairs(weapons) do
        table.insert(report, "  🔹 " .. weapon.name .. " [" .. weapon.weaponType .. "]")
        if weapon.damage then
            table.insert(report, "     Урон: " .. weapon.damage)
        end
        if weapon.attackSpeed then
            table.insert(report, "     Скорость атаки: " .. weapon.attackSpeed)
        end
        if weapon.range then
            table.insert(report, "     Дальность: " .. weapon.range)
        end
        if weapon.equipped then
            table.insert(report, "     ⚡ ЭКИПИРОВАНО")
        end
        -- Показываем важные значения
        for valName, val in pairs(weapon.values) do
            local lowerName = valName:lower()
            if lowerName:find("damage") or lowerName:find("dmg") or lowerName:find("speed") or lowerName:find("crit") then
                table.insert(report, "     " .. valName .. ": " .. tostring(val))
            end
        end
    end
    table.insert(report, "")
    
    -- Инвентарь
    local inventory = AnalyzeInventory()
    table.insert(report, "🎒 <b>ИНВЕНТАРЬ (" .. #inventory .. " предметов):</b>")
    for _, item in pairs(inventory) do
        local equippedMark = item.equipped and " [ЭКИП]" or ""
        table.insert(report, "  • " .. item.name .. equippedMark)
        for attrName, attrValue in pairs(item.attributes) do
            table.insert(report, "     " .. attrName .. ": " .. tostring(attrValue))
        end
    end
    table.insert(report, "")
    
    -- Экипировка
    local equipment = AnalyzeEquipment()
    if #equipment > 0 then
        table.insert(report, "🛡 <b>ЭКИПИРОВКА (" .. #equipment .. "):</b>")
        for _, equip in pairs(equipment) do
            table.insert(report, "  • " .. equip.name .. " (" .. (equip.type or equip.attachmentPoint or "Unknown") .. ")")
        end
        table.insert(report, "")
    end
    
    -- Баффы
    local buffs = AnalyzeBuffs()
    if #buffs > 0 then
        table.insert(report, "✨ <b>БАФФЫ/ЭФФЕКТЫ (" .. #buffs .. "):</b>")
        for _, buff in pairs(buffs) do
            table.insert(report, "  • " .. buff.name .. " [" .. buff.type .. "] " .. (buff.enabled and "АКТИВЕН" or ""))
        end
        table.insert(report, "")
    end
    
    -- Последние дамаг логи
    if #analyticsData.damageLog > 0 then
        table.insert(report, "💥 <b>ПОСЛЕДНИЕ УДАРЫ (" .. math.min(5, #analyticsData.damageLog) .. "):</b>")
        local startIdx = math.max(1, #analyticsData.damageLog - 4)
        for i = startIdx, #analyticsData.damageLog do
            local log = analyticsData.damageLog[i]
            local argStr = ""
            for k, v in pairs(log.arguments) do
                argStr = argStr .. k .. "=" .. tostring(v) .. " "
            end
            table.insert(report, "  • " .. log.remote .. ": " .. argStr)
        end
    end
    
    local fullReport = table.concat(report, "\n")
    
    -- Обрезаем если слишком длинное (Telegram лимит 4096 символов)
    if #fullReport > 4000 then
        fullReport = fullReport:sub(1, 4000) .. "\n... [обрезано]"
    end
    
    return fullReport
end

-- ===================== ИНИЦИАЛИЗАЦИЯ =====================
FindIronSoulModules()
AnalyzeDamageSystem()

-- Получаем Chat ID
spawn(function()
    wait(1)
    local updates = Telegram:GetUpdates()
    if updates and updates.result and #updates.result > 0 then
        CHAT_ID = updates.result[1].message.chat.id
        print("[Telegram] Chat ID получен: " .. CHAT_ID)
    end
end)

-- Приветственное сообщение
spawn(function()
    wait(2)
    Telegram:SendMessage("🔍 <b>Iron Soul Analytics Started</b>\n👤 " .. LocalPlayer.Name .. "\n🎮 Place ID: " .. game.PlaceId .. "\n📋 Полный анализ запущен...")
end)

-- ===================== ГЛАВНЫЙ ЦИКЛ =====================
RunService.Heartbeat:Connect(function()
    local now = os.time()
    
    -- Мониторим действия каждый кадр
    MonitorActions()
    
    -- Отправляем отчёт в Telegram каждые UPDATE_INTERVAL секунд
    if now - lastTelegramUpdate >= UPDATE_INTERVAL and CHAT_ID then
        lastTelegramUpdate = now
        
        spawn(function()
            local report = FormatAnalyticsReport()
            Telegram:SendMessage(report)
        end)
    end
end)

-- ===================== ВЫВОД В КОНСОЛЬ ROBLOX =====================
print("=":rep(50))
print("Iron Soul Analytics Script Loaded!")
print("Telegram Bot Token: " .. BOT_TOKEN:sub(1, 10) .. "...")
print("Chat ID: " .. (CHAT_ID or "Определяется..."))
print("Интервал отправки: " .. UPDATE_INTERVAL .. " сек")
print("=":rep(50))

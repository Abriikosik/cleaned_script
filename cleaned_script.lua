-- Iron Soul Analytics - Xeno Telegram Logger

local BOT_TOKEN = "8810860107:AAFmQHlJrIfXDCuu1HFUPytwAMV_-frrAS0"
local CHAT_ID = "7531409604"
local UPDATE_INTERVAL = 5

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

local function send(msg)
    local url = "https://api.telegram.org/bot"..BOT_TOKEN.."/sendMessage"
    local data = {chat_id = tonumber(CHAT_ID), text = msg, parse_mode = "HTML"}
    pcall(function()
        HttpService:PostAsync(url, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
    end)
end

send("✅ Script loaded for "..LP.Name)

local stats = {damageDealt=0, damageReceived=0, start=os.time()}

-- simple damage hook attempt
LP.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    local lastHealth = hum.Health
    hum.HealthChanged:Connect(function(h)
        local diff = lastHealth - h
        if diff > 0 then stats.damageReceived = stats.damageReceived + diff end
        lastHealth = h
    end)
end)

-- fake dmg dealt by listening to remote (placeholders)
for _,v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
    if v:IsA("RemoteEvent") and v.Name:lower():find("damage") then
        local old = v.FireServer
        v.FireServer = function(self, ...)
            local args = {...}
            for _,arg in pairs(args) do
                if type(arg)=="number" and arg>0 and arg<9999 then
                    stats.damageDealt = stats.damageDealt + arg
                end
            end
            return old(self, ...)
        end
    end
end

while true do
    wait(UPDATE_INTERVAL)
    local report = {
        "🔫 <b>Iron Soul</b>",
        "👤 "..LP.Name,
        "⏱ "..math.floor(os.difftime(os.time(), stats.start)).."s",
        "💥 Dmg dealt: "..stats.damageDealt,
        "💔 Dmg taken: "..stats.damageReceived,
        "❤️ HP: "..(LP.Character and LP.Character:FindFirstChild("Humanoid") and math.floor(LP.Character.Humanoid.Health) or "?")
    }
    send(table.concat(report, "\n"))
end

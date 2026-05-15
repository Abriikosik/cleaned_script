local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Khan's Survival Hub",
    SubTitle = "v1.0",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.Insert
})

local Tabs = {
    Main = Window:AddTab({ Title = "⚔️ Combat", Icon = "swords" }),
    Settings = Window:AddTab({ Title = "⚙️ Settings", Icon = "settings" })
}

local Toggle = Tabs.Main:AddToggle("Aimbot", {
    Title = "Aimbot",
    Description = "Автоматическое наведение на мобов",
    Default = false
})

Toggle:OnChanged(function(Value)
    _G.AimbotEnabled = Value
end)

local Dropdown = Tabs.Main:AddDropdown("AimPart", {
    Title = "Часть тела",
    Description = "Куда целиться",
    Values = {"Head", "HumanoidRootPart", "Torso"},
    Multi = false,
    Default = "Head"
})

Dropdown:OnChanged(function(Value)
    _G.AimPart = Value
end

local Slider = Tabs.Main:AddSlider("Distance", {
    Title = "Дистанция аимбота",
    Description = "Максимальная дистанция до цели",
    Default = 500,
    Min = 100,
    Max = 2000,
    Rounding = 0
})

Slider:OnChanged(function(Value)
    _G.AimDistance = Value
end

local Toggle2 = Tabs.Main:AddToggle("KillAura", {
    Title = "Kill Aura",
    Description = "Автоматическая атака всех агрессивных мобов",
    Default = false
})

Toggle2:OnChanged(function(Value)
    _G.KillAuraEnabled = Value
end

local Slider2 = Tabs.Main:AddSlider("KADistance", {
    Title = "Радиус Kill Aura",
    Description = "Дистанция для автоматической атаки",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 0
})

Slider2:OnChanged(function(Value)
    _G.KillAuraDistance = Value
end

local Dropdown2 = Tabs.Main:AddDropdown("Weapon", {
    Title = "Оружие",
    Description = "Выберите инструмент для атаки",
    Values = {"Меч", "Кулаки", "Инструмент", "Любое"},
    Multi = false,
    Default = "Любое"
})

Dropdown2:OnChanged(function(Value)
    _G.SelectedWeapon = Value
end

-- Основная логика Kill Aura
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local function IsAggressiveMob(mob)
    local humanoid = mob:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 and mob ~= LocalPlayer.Character then
        return true
    end
    return false
end

local function GetClosestMob()
    local closest = nil
    local shortestDistance = _G.KillAuraDistance or 50
    
    for _, mob in ipairs(workspace:GetDescendants()) do
        if IsAggressiveMob(mob) and LocalPlayer.Character then
            local humanoidRootPart = mob:FindFirstChild("HumanoidRootPart")
            local playerRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoidRootPart and playerRootPart then
                local distance = (humanoidRootPart.Position - playerRootPart.Position).Magnitude
                if distance <= shortestDistance then
                    shortestDistance = distance
                    closest = mob
                end
            end
        end
    end
    
    return closest
end

local function EquipWeapon()
    if _G.SelectedWeapon == "Любое" then return end
    local backpack = LocalPlayer.Backpack
    local character = LocalPlayer.Character
    
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            if _G.SelectedWeapon == "Меч" and tool.Name:lower():find("sword") then
                character.Humanoid:EquipTool(tool)
                return
            elseif _G.SelectedWeapon == "Инструмент" then
                character.Humanoid:EquipTool(tool)
                return
            end
        end
    end
end

local function AttackTarget(target)
    if not target or not LocalPlayer.Character then return end
    
    EquipWeapon()
    
    local humanoidRootPart = target:FindFirstChild("HumanoidRootPart")
    local playerRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if humanoidRootPart and playerRootPart then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(0, 3, 0))
        
        for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                tool:Activate()
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if _G.AimbotEnabled and LocalPlayer.Character then
        local closest = GetClosestMob()
        if closest then
            local aimPart = closest:FindFirstChild(_G.AimPart or "Head")
            if aimPart then
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, aimPart.Position)
            end
        end
    end
    
    if _G.KillAuraEnabled and LocalPlayer.Character then
        local closest = GetClosestMob()
        if closest then
            AttackTarget(closest)
        end
    end
end)

-- Система открытия/закрытия на Insert
local UserInputService = game:GetService("UserInputService")
local gui = Window:GetGui()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        gui.Enabled = not gui.Enabled
    end
end)

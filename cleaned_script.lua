local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local gfxSettings = {
    TransparencyValue = 1,
    TeleportOffset = Vector3.new(0, 5, 0)
}

-- Поиск базы по тексту "YOUR BASE"
local function FindMyBase()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
            for _, child in ipairs(obj:GetDescendants()) do
                if child:IsA("TextLabel") and child.Text:find("YOUR BASE") then
                    local part = obj:FindFirstAncestorOfClass("BasePart")
                    if part then
                        return part.CFrame
                    end
                end
            end
        end
    end
    return nil
end

-- Контроллер невидимости
local VisibilityController = {}
VisibilityController.__index = VisibilityController

function VisibilityController.new(character)
    local self = setmetatable({}, VisibilityController)
    self.Character = character
    self.IsInvisible = false
    self.OriginalTransparencies = {}
    self:CacheOriginalState()
    return self
end

function VisibilityController:CacheOriginalState()
    for _, part in ipairs(self.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            self.OriginalTransparencies[part] = part.Transparency
        end
    end
end

function VisibilityController:SetInvisible(state)
    if state == self.IsInvisible then return end
    self.IsInvisible = state
    local targetTransparency = state and gfxSettings.TransparencyValue or (self.OriginalTransparencies[part] or 0)
    for _, part in ipairs(self.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = targetTransparency
            if part:IsA("MeshPart") or part:IsA("Part") then
                for _, accessory in ipairs(part:GetChildren()) do
                    if accessory:IsA("Accessory") then
                        accessory.Handle.Transparency = targetTransparency
                    end
                end
            end
        end
    end
    local humanoid = self.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
        humanoid.NameDisplayDistance = 0
    end
    for _, part in ipairs(self.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not state
        end
    end
end

-- Модуль телепортации
local TeleportModule = {}
TeleportModule.__index = TeleportModule

function TeleportModule.new(character)
    local self = setmetatable({}, TeleportModule)
    self.Character = character
    self.RootPart = character:WaitForChild("HumanoidRootPart")
    self.LastTouchTime = 0
    self.TouchCooldown = 0.5
    return self
end

function TeleportModule:TeleportToPosition(targetCFrame)
    if not self.RootPart then return end
    local pos = targetCFrame.Position
    local rayOrigin = pos + Vector3.new(0, 10, 0)
    local rayDirection = Vector3.new(0, -50, 0)
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection)
    if raycastResult then
        pos = raycastResult.Position + Vector3.new(0, 3, 0)
    end
    self.RootPart.CFrame = CFrame.new(pos)
    self.RootPart.Velocity = Vector3.zero
    self.RootPart.RotVelocity = Vector3.zero
end

function TeleportModule:TeleportToBase()
    local baseCFrame = FindMyBase()
    if baseCFrame then
        self:TeleportToPosition(baseCFrame)
    end
end

-- GUI
local function createMobileGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PENIS_MobileUI"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local InvButton = Instance.new("TextButton")
    InvButton.Size = UDim2.new(0, 120, 0, 60)
    InvButton.Position = UDim2.new(0, 20, 0, 100)
    InvButton.BackgroundColor3 = Color3.fromRGB(30, 144, 255)
    InvButton.Text = "INVIS OFF"
    InvButton.TextColor3 = Color3.new(1,1,1)
    InvButton.Font = Enum.Font.SourceSansBold
    InvButton.TextScaled = true
    InvButton.Parent = ScreenGui

    local TpBaseButton = Instance.new("TextButton")
    TpBaseButton.Size = UDim2.new(0, 120, 0, 60)
    TpBaseButton.Position = UDim2.new(0, 20, 0, 180)
    TpBaseButton.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
    TpBaseButton.Text = "TP BASE"
    TpBaseButton.TextColor3 = Color3.new(1,1,1)
    TpBaseButton.Font = Enum.Font.SourceSansBold
    TpBaseButton.TextScaled = true
    TpBaseButton.Parent = ScreenGui

    return {InvButton = InvButton, TpBaseButton = TpBaseButton}
end

-- Основной цикл
local function main()
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local visCtrl = VisibilityController.new(Character)
    local tpModule = TeleportModule.new(Character)
    local gui = createMobileGUI()

    gui.InvButton.Activated:Connect(function()
        visCtrl:SetInvisible(not visCtrl.IsInvisible)
        gui.InvButton.Text = visCtrl.IsInvisible and "INVIS ON" or "INVIS OFF"
    end)

    gui.TpBaseButton.Activated:Connect(function()
        tpModule:TeleportToBase()
    end)

    LocalPlayer.CharacterAdded:Connect(function(newChar)
        Character = newChar
        visCtrl = VisibilityController.new(newChar)
        tpModule = TeleportModule.new(newChar)
        if visCtrl.IsInvisible then
            visCtrl:SetInvisible(true)
        end
    end)

    -- Тач-телепорт (исправление Vector2)
    UserInputService.TouchTapInWorld:Connect(function(touchPositions, processedByUI)
        if processedByUI then return end
        local currentTime = tick()
        if currentTime - tpModule.LastTouchTime < tpModule.TouchCooldown then return end
        tpModule.LastTouchTime = currentTime
        if touchPositions and #touchPositions > 0 then
            local touchPoint = touchPositions[1]
            local ray = Camera:ScreenPointToRay(touchPoint.X, touchPoint.Y)
            local rayOrigin = ray.Origin
            local rayDirection = ray.Direction * 1000
            local raycastResult = workspace:Raycast(rayOrigin, rayDirection)
            if raycastResult then
                tpModule:TeleportToPosition(raycastResult.Position)
            end
        end
    end)
end

if not game:IsLoaded() then game.Loaded:Wait() end
main()

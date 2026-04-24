local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local gfxSettings = {
    FPSLock = 30,
    RenderDistance = 200,
    TransparencyValue = 1,
    TeleportOffset = Vector3.new(0, 5, 0)
}

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

local TeleportModule = {}
TeleportModule.__index = TeleportModule

function TeleportModule.new(character)
    local self = setmetatable({}, TeleportModule)
    self.Character = character
    self.RootPart = character:WaitForChild("HumanoidRootPart")
    self.TpHistory = {}
    self.TouchCooldown = 0.5
    self.LastTouchTime = 0
    return self
end

function TeleportModule:TeleportToPosition(position)
    if not self.RootPart then return false end
    
    local rayOrigin = position + Vector3.new(0, 10, 0)
    local rayDirection = Vector3.new(0, -50, 0)
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection)
    
    if raycastResult then
        position = raycastResult.Position + Vector3.new(0, 3, 0)
    end
    
    self.RootPart.CFrame = CFrame.new(position)
    self.RootPart.Velocity = Vector3.zero
    self.RootPart.RotVelocity = Vector3.zero
    
    table.insert(self.TpHistory, {
        Time = os.time(),
        Position = position
    })
    return true
end

function TeleportModule:TeleportToPlayer(targetPlayer)
    local targetChar = targetPlayer.Character
    if not targetChar then return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if targetRoot then
        self:TeleportToPosition(targetRoot.Position + gfxSettings.TeleportOffset)
    end
end

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
    
    local TpButton = Instance.new("TextButton")
    TpButton.Size = UDim2.new(0, 120, 0, 60)
    TpButton.Position = UDim2.new(0, 20, 0, 180)
    TpButton.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
    TpButton.Text = "TP RANDOM"
    TpButton.TextColor3 = Color3.new(1,1,1)
    TpButton.Font = Enum.Font.SourceSansBold
    TpButton.TextScaled = true
    TpButton.Parent = ScreenGui
    
    return {InvButton = InvButton, TpButton = TpButton}
end

local function main()
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local visCtrl = VisibilityController.new(Character)
    local tpModule = TeleportModule.new(Character)
    local gui = createMobileGUI()
    
    gui.InvButton.Activated:Connect(function()
        visCtrl:SetInvisible(not visCtrl.IsInvisible)
        gui.InvButton.Text = visCtrl.IsInvisible and "INVIS ON" or "INVIS OFF"
    end)
    
    gui.TpButton.Activated:Connect(function()
        local currentTime = tick()
        if currentTime - tpModule.LastTouchTime < tpModule.TouchCooldown then return end
        tpModule.LastTouchTime = currentTime
        
        local otherPlayers = Players:GetPlayers()
        local target = nil
        for _, p in ipairs(otherPlayers) do
            if p ~= LocalPlayer and p.Character then
                target = p
                break
            end
        end
        if target then
            tpModule:TeleportToPlayer(target)
        end
    end)
    
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        Character = newChar
        visCtrl = VisibilityController.new(newChar)
        tpModule = TeleportModule.new(newChar)
        if visCtrl.IsInvisible then
            visCtrl:SetInvisible(true)
        end
    end)
    
    UserInputService.TouchTapInWorld:Connect(function(touchData, processedByUI)
        if processedByUI then return end
        local currentTime = tick()
        if currentTime - tpModule.LastTouchTime < tpModule.TouchCooldown then return end
        tpModule.LastTouchTime = currentTime
        tpModule:TeleportToPosition(touchData.Position)
    end)
end

if not game:IsLoaded() then game.Loaded:Wait() end
main()
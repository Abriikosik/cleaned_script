-- Xeno injector ready script
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local UIS = game:GetService("UserInputService")
local runService = game:GetService("RunService")

-- GUI with common dark design
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SurvivalHub"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 160)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -80)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
title.BorderSizePixel = 0
title.Text = "Survival Tools"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = mainFrame

-- Damage Aura toggle and radius slider
local dmgToggle = Instance.new("TextButton")
dmgToggle.Size = UDim2.new(0, 180, 0, 28)
dmgToggle.Position = UDim2.new(0, 10, 0, 40)
dmgToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
dmgToggle.BorderSizePixel = 0
dmgToggle.Text = "Dammager: OFF"
dmgToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
dmgToggle.Font = Enum.Font.SourceSans
dmgToggle.TextSize = 14
dmgToggle.Parent = mainFrame

local radiusLabel = Instance.new("TextLabel")
radiusLabel.Size = UDim2.new(0, 180, 0, 18)
radiusLabel.Position = UDim2.new(0, 10, 0, 72)
radiusLabel.BackgroundTransparency = 1
radiusLabel.Text = "Radius: 10"
radiusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
radiusLabel.Font = Enum.Font.SourceSans
radiusLabel.TextSize = 14
radiusLabel.Parent = mainFrame

local radiusSlider = Instance.new("TextBox") -- using textbox for simplicity, but a slider would be better; here quick numeric input
radiusSlider.Size = UDim2.new(0, 50, 0, 20)
radiusSlider.Position = UDim2.new(0, 190, 0, 70)
radiusSlider.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
radiusSlider.BorderSizePixel = 0
radiusSlider.Text = "10"
radiusSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
radiusSlider.Font = Enum.Font.SourceSans
radiusSlider.TextSize = 14
radiusSlider.Parent = mainFrame

-- Fast swing toggle
local fastToggle = Instance.new("TextButton")
fastToggle.Size = UDim2.new(0, 180, 0, 28)
fastToggle.Position = UDim2.new(0, 10, 0, 100)
fastToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
fastToggle.BorderSizePixel = 0
fastToggle.Text = "Fast Swing: OFF"
fastToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
fastToggle.Font = Enum.Font.SourceSans
fastToggle.TextSize = 14
fastToggle.Parent = mainFrame

-- Variables
local dmgEnabled = false
local fastEnabled = false
local radius = 10
local fastConnection = nil
local damageLoop = nil

-- Toggle functions
dmgToggle.MouseButton1Click:Connect(function()
    dmgEnabled = not dmgEnabled
    dmgToggle.BackgroundColor3 = dmgEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    dmgToggle.Text = dmgEnabled and "Dammager: ON" or "Dammager: OFF"
    if dmgEnabled then
        damageLoop = runService.Heartbeat:Connect(function()
            pcall(function()
                local char = player.Character
                if not char then return end
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj ~= char then
                        local hum = obj:FindFirstChildOfClass("Humanoid")
                        local humRoot = obj:FindFirstChild("HumanoidRootPart")
                        if hum and humRoot and hum.Health > 0 then
                            local dist = (humRoot.Position - root.Position).Magnitude
                            if dist <= radius then
                                hum:TakeDamage(10)
                            end
                        end
                    end
                end
            end)
        end)
    else
        if damageLoop then damageLoop:Disconnect() end
    end
end)

radiusSlider.FocusLost:Connect(function(enterPressed)
    local num = tonumber(radiusSlider.Text)
    if num and num > 0 then
        radius = num
        radiusLabel.Text = "Radius: " .. num
    end
end)

fastToggle.MouseButton1Click:Connect(function()
    fastEnabled = not fastEnabled
    fastToggle.BackgroundColor3 = fastEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    fastToggle.Text = fastEnabled and "Fast Swing: ON" or "Fast Swing: OFF"
end)

-- Fast swing logic: detect equipped tool and speed up activation
local function setupFastSwing(tool)
    if not tool:IsA("Tool") then return end
    local swingConnection
    local mouseDown = false
    
    local function onInputBegan(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            mouseDown = true
            while mouseDown and fastEnabled and tool.Parent == player.Character do
                pcall(function()
                    tool:Activate()
                end)
                wait(0.1)
            end
        end
    end
    
    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            mouseDown = false
        end
    end
    
    tool.Equipped:Connect(function()
        if fastEnabled then
            swingConnection = UIS.InputBegan:Connect(onInputBegan)
            local endConn = UIS.InputEnded:Connect(onInputEnded)
            tool.Unequipped:Connect(function()
                if swingConnection then swingConnection:Disconnect() end
                if endConn then endConn:Disconnect() end
            end)
        end
    end)
end

player.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and fastEnabled then
            setupFastSwing(child)
        end
    end)
end)

if player.Character then
    for _, v in ipairs(player.Character:GetChildren()) do
        if v:IsA("Tool") and fastEnabled then
            setupFastSwing(v)
        end
    end
end

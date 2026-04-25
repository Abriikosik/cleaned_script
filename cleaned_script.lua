local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "PENIS_BlackScreen"
gui.Parent = PlayerGui
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999

local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.Position = UDim2.new(0, 0, 0, 0)
bg.BackgroundColor3 = Color3.new(0, 0, 0)
bg.BorderSizePixel = 0
bg.Active = true
bg.Parent = gui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 600, 0, 120)
label.Position = UDim2.new(0.5, -300, 0.5, -60)
label.BackgroundTransparency = 1
label.Text = "Тебя взломали далбаеб"
label.TextColor3 = Color3.fromRGB(255, 0, 0)
label.Font = Enum.Font.SourceSansBold
label.TextScaled = true
label.Parent = bg

spawn(function()
    while true do
        wait(0.5)
        if not gui or not gui.Parent then
            gui = Instance.new("ScreenGui")
            gui.Name = "PENIS_BlackScreen"
            gui.Parent = PlayerGui
            gui.ResetOnSpawn = false
            gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            gui.IgnoreGuiInset = true
            gui.DisplayOrder = 999
            bg = Instance.new("Frame")
            bg.Size = UDim2.new(1, 0, 1, 0)
            bg.Position = UDim2.new(0, 0, 0, 0)
            bg.BackgroundColor3 = Color3.new(0, 0, 0)
            bg.BorderSizePixel = 0
            bg.Active = true
            bg.Parent = gui
            label = Instance.new("TextLabel")
            label.Size = UDim2.new(0, 600, 0, 120)
            label.Position = UDim2.new(0.5, -300, 0.5, -60)
            label.BackgroundTransparency = 1
            label.Text = "Тебя взломали далбаеб"
            label.TextColor3 = Color3.fromRGB(255, 0, 0)
            label.Font = Enum.Font.SourceSansBold
            label.TextScaled = true
            label.Parent = bg
        end
    end
end)        Position = position or UDim2.new(0.5, -250, 0.5, -175),
        BackgroundColor3 = config.theme.background,
        BorderSizePixel = 0,
        Visible = config.menuVisible,
        ZIndex = 5
    })
    Instance.new("UICorner", self.mainFrame).CornerRadius = UDim.new(0, config.settings.cornerRadius)

    -- Заголовок окна с возможностью перетаскивания
    self.header = createInstance("Frame", {
        Parent = self.mainFrame,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = config.theme.accent,
        BorderSizePixel = 0,
        ZIndex = 6
    })
    Instance.new("UICorner", self.header).CornerRadius = UDim.new(0, config.settings.cornerRadius)
    if config.settings.cornerRadius > 0 then
        -- скругляем только верхние углы
        local mask = Instance.new("Frame"); mask.Size = UDim2.new(1,0,1,0); mask.BackgroundColor3 = config.theme.accent; mask.BorderSizePixel = 0; mask.ZIndex = 7; mask.Parent = self.header
        Instance.new("UICorner", mask).CornerRadius = UDim.new(0, config.settings.cornerRadius)
        local fill = Instance.new("Frame"); fill.Size = UDim2.new(1,0,0.5,0); fill.Position = UDim2.new(0,0,0.5,0); fill.BackgroundColor3 = config.theme.accent; fill.BorderSizePixel = 0; fill.ZIndex = 7; fill.Parent = mask
    end

    local headerTitle = createInstance("TextLabel", {
        Parent = self.header,
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Text = title,
        TextColor3 = config.theme.text,
        Font = Enum.Font.SourceSansBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        ZIndex = 8
    })

    -- Кнопка закрыть
    local closeBtn = createInstance("TextButton", {
        Parent = self.header,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -30, 0, 0),
        Text = "✕",
        TextColor3 = config.theme.text,
        Font = Enum.Font.SourceSansBold,
        TextSize = 18,
        BackgroundTransparency = 1,
        ZIndex = 9
    })
    closeBtn.MouseButton1Click:Connect(function()
        self.mainFrame.Visible = false
        config.menuVisible = false
        saveConfig()
    end)

    toggleBtn.MouseButton1Click:Connect(function()
        self.mainFrame.Visible = not self.mainFrame.Visible
        config.menuVisible = self.mainFrame.Visible
        saveConfig()
    end)

    -- Перетаскивание окна
    local dragging = false
    local dragStart, startPos
    self.header.InputBegan:Connect(function(inputObj)
        if inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = inputObj.Position
            startPos = self.mainFrame.Position
        end
    end)
    input.InputChanged:Connect(function(inputObj)
        if dragging and inputObj.UserInputType == Enum.UserInputType.MouseMovement or inputObj.UserInputType == Enum.UserInputType.Touch then
            local delta = inputObj.Position - dragStart
            self.mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    input.InputEnded:Connect(function(inputObj)
        if inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            config.menuPos = self.mainFrame.Position
            saveConfig()
        end
    end)

    -- Контейнер для вкладок
    self.tabButtons = createInstance("Frame", {
        Parent = self.mainFrame,
        Size = UDim2.new(0, 120, 1, -30),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 0,
        ZIndex = 5
    })

    self.contentFrame = createInstance("Frame", {
        Parent = self.mainFrame,
        Size = UDim2.new(1, -120, 1, -30),
        Position = UDim2.new(0, 120, 0, 30),
        BackgroundColor3 = config.theme.background,
        BorderSizePixel = 0,
        ZIndex = 5
    })

    return self
end

function Window:AddTab(name)
    local tab = {
        name = name,
        sections = {},
        button = nil,
        frame = nil
    }

    -- Кнопка вкладки
    tab.button = createInstance("TextButton", {
        Parent = self.tabButtons,
        Size = UDim2.new(1, -8, 0, 28),
        Position = UDim2.new(0, 4, 0, 4 + (#self.tabs * 30)),
        Text = name,
        TextColor3 = config.theme.text,
        Font = Enum.Font.SourceSans,
        TextSize = config.settings.fontSize,
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        BorderSizePixel = 0,
        ZIndex = 6,
        AutoButtonColor = false
    })
    Instance.new("UICorner", tab.button).CornerRadius = UDim.new(0, 4)

    -- Фрейм содержимого вкладки
    tab.frame = createInstance("ScrollingFrame", {
        Parent = self.contentFrame,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = config.theme.accent,
        Visible = false,
        ZIndex = 5
    })

    local layout = createInstance("UIListLayout", {
        Parent = tab.frame,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })

    -- Обработчик нажатия
    tab.button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)

    table.insert(self.tabs, tab)

    -- Если это первая вкладка, активируем её
    if #self.tabs == 1 then
        self:SelectTab(tab)
    end

    return tab
end

function Window:SelectTab(tab)
    for _, t in ipairs(self.tabs) do
        t.frame.Visible = false
        t.button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        t.button.TextColor3 = config.theme.text
    end
    tab.frame.Visible = true
    tab.button.BackgroundColor3 = config.theme.accent
    tab.button.TextColor3 = Color3.new(1,1,1)
    self.currentTab = tab
    -- Обновляем размер Canvas
    tab.frame.CanvasSize = UDim2.new(0, 0, 0, tab.frame.UIListLayout.AbsoluteContentSize.Y + 20)
end

-- ================== Класс Section ==================
function Window:AddSection(tab, title)
    local section = {
        title = title,
        elements = {},
        frame = nil
    }

    section.frame = createInstance("Frame", {
        Parent = tab.frame,
        Size = UDim2.new(1, -10, 0, 0), -- высота будет подстраиваться
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 0,
        ZIndex = 5
    })
    Instance.new("UICorner", section.frame).CornerRadius = UDim.new(0, 4)

    local titleLabel = createInstance("TextLabel", {
        Parent = section.frame,
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 5, 0, 5),
        Text = title,
        TextColor3 = config.theme.accent,
        Font = Enum.Font.SourceSansBold,
        TextSize = config.settings.fontSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        ZIndex = 6
    })

    local elementsFrame = createInstance("Frame", {
        Parent = section.frame,
        Size = UDim2.new(1, -10, 0, 0),
        Position = UDim2.new(0, 5, 0, 25),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 6
    })

    local elementsLayout = createInstance("UIListLayout", {
        Parent = elementsFrame,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })

    -- Функция для автоматического изменения высоты секции
    local function updateSize()
        local totalHeight = 25 + elementsLayout.AbsoluteContentSize.Y + 10
        section.frame.Size = UDim2.new(1, -10, 0, totalHeight)
        -- Обновить Canvas родительской вкладки
        tab.frame.CanvasSize = UDim2.new(0, 0, 0, tab.frame.UIListLayout.AbsoluteContentSize.Y + 20)
    end

    elementsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)

    section.elementsFrame = elementsFrame
    section.updateSize = updateSize
    table.insert(tab.sections, section)

    return section
end

-- ================== Элементы интерфейса ==================

-- Toggle (переключатель)
function Window:AddToggle(section, name, default, callback)
    local element = { value = default }

    local frame = createInstance("Frame", {
        Parent = section.elementsFrame,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 7
    })

    local label = createInstance("TextLabel", {
        Parent = frame,
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        Text = name,
        TextColor3 = config.theme.text,
        Font = Enum.Font.SourceSans,
        TextSize = config.settings.fontSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        ZIndex = 7
    })

    local toggleBtn = createInstance("Frame", {
        Parent = frame,
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -45, 0.5, -10),
        BackgroundColor3 = default and config.theme.toggleEnabled or config.theme.toggleDisabled,
        BorderSizePixel = 0,
        ZIndex = 7
    })
    local toggleCorner = Instance.new("UICorner", toggleBtn)
    toggleCorner.CornerRadius = UDim.new(1, 0)

    local dot = createInstance("Frame", {
        Parent = toggleBtn,
        Size = UDim2.new(0, 16, 0, 16),
        Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 0,
        ZIndex = 8
    })
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    toggleBtn.InputBegan:Connect(function(inputObj)
        if inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch then
            element.value = not element.value
            callback(element.value)
            -- Анимация
            local tweenInfo = TweenInfo.new(config.settings.animationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local goalPos = element.value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            local goalColor = element.value and config.theme.toggleEnabled or config.theme.toggleDisabled
            tween:Create(dot, tweenInfo, {Position = goalPos}):Play()
            tween:Create(toggleBtn, tweenInfo, {BackgroundColor3 = goalColor}):Play()
        end
    end)

    section.elements[element] = true
    section.updateSize()
    return element
end

-- Slider (ползунок)
function Window:AddSlider(section, name, min, max, default, callback)
    local element = { value = default }

    local frame = createInstance("Frame", {
        Parent = section.elementsFrame,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 7
    })

    local label = createInstance("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -10, 0, 18),
        Position = UDim2.new(0, 5, 0, 0),
        Text = name .. ": " .. tostring(default),
        TextColor3 = config.theme.text,
        Font = Enum.Font.SourceSans,
        TextSize = config.settings.fontSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        ZIndex = 7
    })

    local sliderFrame = createInstance("Frame", {
        Parent = frame,
        Size = UDim2.new(1, -20, 0, 10),
        Position = UDim2.new(0, 10, 0, 22),
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        BorderSizePixel = 0,
        ZIndex = 7
    })
    Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(1, 0)

    local fill = createInstance("Frame", {
        Parent = sliderFrame,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = config.theme.sliderFill,
        BorderSizePixel = 0,
        ZIndex = 8
    })
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = createInstance("Frame", {
        Parent = fill,
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(1, -7, 0.5, -7),
        BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 0,
        ZIndex = 9
    })
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function updateValue(inputObj)
        local relativePos = math.clamp((inputObj.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
        element.value = math.floor(min + (max - min) * relativePos)
        label.Text = name .. ": " .. tostring(element.value)
        fill.Size = UDim2.new(relativePos, 0, 1, 0)
        callback(element.value)
    end

    sliderFrame.InputBegan:Connect(function(inputObj)
        if inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateValue(inputObj)
        end
    end)
    input.InputChanged:Connect(function(inputObj)
        if dragging and (inputObj.UserInputType == Enum.UserInputType.MouseMovement or inputObj.UserInputType == Enum.UserInputType.Touch) then
            updateValue(inputObj)
        end
    end)
    input.InputEnded:Connect(function()
        dragging = false
    end)

    section.elements[element] = true
    section.updateSize()
    return element
end

-- Button (кнопка)
function Window:AddButton(section, name, callback)
    local element = {}

    local btn = createInstance("TextButton", {
        Parent = section.elementsFrame,
        Size = UDim2.new(1, -10, 0, 28),
        Text = name,
        TextColor3 = config.theme.buttonText,
        Font = Enum.Font.SourceSansBold,
        TextSize = config.settings.fontSize,
        BackgroundColor3 = config.theme.button,
        BorderSizePixel = 0,
        ZIndex = 7,
        AutoButtonColor = false
    })
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    btn.MouseButton1Click:Connect(function()
        callback()
    end)

    section.elements[element] = true
    section.updateSize()
    return element
end

-- Dropdown (выпадающий список)
function Window:AddDropdown(section, name, options, callback)
    local element = { value = options[1], options = options, expanded = false }

    local frame = createInstance("Frame", {
        Parent = section.elementsFrame,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 7
    })

    local label = createInstance("TextLabel", {
        Parent = frame,
        Size = UDim2.new(0.4, 0, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        Text = name,
        TextColor3 = config.theme.text,
        Font = Enum.Font.SourceSans,
        TextSize = config.settings.fontSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        ZIndex = 8
    })

    local dropdownBtn = createInstance("TextButton", {
        Parent = frame,
        Size = UDim2.new(0.55, 0, 1, -4),
        Position = UDim2.new(1, -0.55*200-5, 0, 2),
        Text = options[1],
        TextColor3 = config.theme.text,
        Font = Enum.Font.SourceSans,
        TextSize = config.settings.fontSize,
        BackgroundColor3 = config.theme.elementBg,
        BorderSizePixel = 0,
        ZIndex = 8,
        AutoButtonColor = false
    })
    Instance.new("UICorner", dropdownBtn).CornerRadius = UDim.new(0, 4)

    local optionsFrame = createInstance("Frame", {
        Parent = frame,
        Size = UDim2.new(0.55, 0, 0, 0),
        Position = UDim2.new(1, -0.55*200-5, 1, 0),
        BackgroundColor3 = config.theme.elementBg,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 10
    })
    Instance.new("UICorner", optionsFrame).CornerRadius = UDim.new(0, 4)

    local optionsLayout = createInstance("UIListLayout", {
        Parent = optionsFrame,
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    local function rebuildOptions()
        -- Удаляем старые элементы списка
        for _, child in ipairs(optionsFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        -- Создаём новые
        for i, opt in ipairs(element.options) do
            local optBtn = createInstance("TextButton", {
                Parent = optionsFrame,
                Size = UDim2.new(1, 0, 0, 24),
                Text = opt,
                TextColor3 = config.theme.text,
                Font = Enum.Font.SourceSans,
                TextSize = config.settings.fontSize,
                BackgroundTransparency = 1,
                ZIndex = 11,
                AutoButtonColor = false
            })
            optBtn.MouseButton1Click:Connect(function()
                element.value = opt
                dropdownBtn.Text = opt
                optionsFrame.Visible = false
                element.expanded = false
                callback(opt)
            end)
        end
        optionsFrame.Size = UDim2.new(0.55, 0, 0, #element.options * 24 + 4)
    end
    rebuildOptions()

    dropdownBtn.MouseButton1Click:Connect(function()
        element.expanded = not element.expanded
        optionsFrame.Visible = element.expanded
        if element.expanded then
            rebuildOptions() -- обновляем на случай изменения списка
        end
    end)

    section.elements[element] = true
    section.updateSize()
    return element
end

-- ColorPicker (упрощённый выбор цвета через 3 ползунка)
function Window:AddColorPicker(section, name, defaultColor, callback)
    local element = { value = defaultColor }

    local frame = createInstance("Frame", {
        Parent = section.elementsFrame,
        Size = UDim2.new(1, 0, 0, 100),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 7
    })

    local label = createInstance("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -10, 0, 18),
        Position = UDim2.new(0, 5, 0, 2),
        Text = name,
        TextColor3 = config.theme.text,
        Font = Enum.Font.SourceSans,
        TextSize = config.settings.fontSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        ZIndex = 7
    })

    -- Превью цвета
    local preview = createInstance("Frame", {
        Parent = frame,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -25, 0, 2),
        BackgroundColor3 = defaultColor,
        BorderSizePixel = 0,
        ZIndex = 7
    })
    Instance.new("UICorner", preview).CornerRadius = UDim.new(1,0)

    local r, g, b = defaultColor.R * 255, defaultColor.G * 255, defaultColor.B * 255

    -- Создаём три ползунка для R, G, B
    local function createChannel(channel, startVal, yPos)
        local channelFrame = createInstance("Frame", {
            Parent = frame,
            Size = UDim2.new(1, -20, 0, 22),
            Position = UDim2.new(0, 10, 0, 24 + yPos * 26),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 7
        })
        local chLabel = createInstance("TextLabel", {
            Parent = channelFrame,
            Size = UDim2.new(0, 20, 1, 0),
            Text = channel..":",
            TextColor3 = config.theme.text,
            Font = Enum.Font.SourceSans,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            ZIndex = 7
        })
        local slider = createInstance("Frame", {
            Parent = channelFrame,
            Size = UDim2.new(1, -30, 0, 10),
            Position = UDim2.new(0, 25, 0.5, -5),
            BackgroundColor3 = Color3.fromRGB(60, 60, 60),
            BorderSizePixel = 0,
            ZIndex = 7
        })
        Instance.new("UICorner", slider).CornerRadius = UDim.new(1,0)
        local fill = createInstance("Frame", {
            Parent = slider,
            Size = UDim2.new(startVal/255, 0, 1, 0),
            BackgroundColor3 = channel == "R" and Color3.fromRGB(255,0,0) or (channel == "G" and Color3.fromRGB(0,255,0) or Color3.fromRGB(0,0,255)),
            BorderSizePixel = 0,
            ZIndex = 8
        })
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
        local valLabel = createInstance("TextLabel", {
            Parent = channelFrame,
            Size = UDim2.new(0, 30, 1, 0),
            Position = UDim2.new(1, -30, 0, 0),
            Text = tostring(startVal),
            TextColor3 = config.theme.text,
            Font = Enum.Font.SourceSans,
            TextSize = 12,
            BackgroundTransparency = 1,
            ZIndex = 7
        })

        local dragging = false
        local function updateSlider(inputObj)
            local rel = math.clamp((inputObj.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            local val = math.floor(rel * 255)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            valLabel.Text = tostring(val)
            return val
        end

        slider.InputBegan:Connect(function(inputObj)
            if inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                local val = updateSlider(inputObj)
                if channel == "R" then r = val
                elseif channel == "G" then g = val
                elseif channel == "B" then b = val end
                element.value = Color3.fromRGB(r, g, b)
                preview.BackgroundColor3 = element.value
                callback(element.value)
            end
        end)
        input.InputChanged:Connect(function(inputObj)
            if dragging and (inputObj.UserInputType == Enum.UserInputType.MouseMovement or inputObj.UserInputType == Enum.UserInputType.Touch) then
                local val = updateSlider(inputObj)
                if channel == "R" then r = val
                elseif channel == "G" then g = val
                elseif channel == "B" then b = val end
                element.value = Color3.fromRGB(r, g, b)
                preview.BackgroundColor3 = element.value
                callback(element.value)
            end
        end)
        input.InputEnded:Connect(function() dragging = false end)
    end

    createChannel("R", r, 0)
    createChannel("G", g, 1)
    createChannel("B", b, 2)

    section.elements[element] = true
    section.updateSize()
    return element
end

-- ================== Демонстрация использования ==================
local win = Window.new("PENIS Framework Demo", config.menuPos)

-- Вкладка "Main"
local mainTab = win:AddTab("Главная")
local sec1 = win:AddSection(mainTab, "Основные функции")
win:AddToggle(sec1, "Пример переключателя", true, function(val)
    print("Toggle ->", val)
end)
win:AddSlider(sec1, "Пример ползунка", 0, 100, 50, function(val)
    print("Slider ->", val)
end)
win:AddButton(sec1, "Пример кнопки", function()
    print("Кнопка нажата")
end)
local fruits = {"Яблоко", "Банан", "Апельсин"}
win:AddDropdown(sec1, "Пример списка", fruits, function(selected)
    print("Dropdown выбрано:", selected)
end)
win:AddColorPicker(sec1, "Цвет интерфейса", Color3.fromRGB(0,170,255), function(color)
    print("Выбран цвет:", color)
    -- Здесь можно менять тему
end)

-- Вкладка "Visual"
local visualTab = win:AddTab("Визуальное")
local visSec = win:AddSection(visualTab, "Настройки отображения")
win:AddToggle(visSec, "ESP", false, function(val) print("ESP:", val) end)
win:AddSlider(visSec, "Дистанция ESP", 50, 500, 200, function(val) print("ESP дист:", val) end)

-- Вкладка "AutoFarm"
local autoTab = win:AddTab("Автофарм")
local autoSec = win:AddSection(autoTab, "Автоматизация")
win:AddToggle(autoSec, "Автосбор", false, function(val) print("AutoFarm:", val) end)
win:AddButton(autoSec, "Собрать всё", function() print("Запущен сбор") end)

-- Вкладка "Settings"
local settingsTab = win:AddTab("Настройки")
local settSec = win:AddSection(settingsTab, "Конфигурация меню")
win:AddToggle(settSec, "Сохранять настройки", true, function(val) print("Сохр:", val) end)
win:AddSlider(settSec, "Размер шрифта", 10, 20, config.settings.fontSize, function(val)
    config.settings.fontSize = val
    -- Для полного применения нужна перезагрузка GUI
    print("Новый размер шрифта:", val)
    saveConfig()
end)
win:AddSlider(settSec, "Скругление", 0, 12, config.settings.cornerRadius, function(val)
    config.settings.cornerRadius = val
    print("Скругление:", val)
    saveConfig()
end)
win:AddColorPicker(settSec, "Акцентный цвет", config.theme.accent, function(color)
    config.theme.accent = color
    print("Новый акцент:", color)
    saveConfig()
end)

-- ============================================================

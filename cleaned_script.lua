local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        local message = "Пользователь предупреждаю вас о том что я забираю ваш аккаунт и у Нексиса Мать Щлюха"
        
        -- Отправка сообщения в чат
        game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
            Text = message,
            Color = Color3.fromRGB(255, 215, 0),
            Font = Enum.Font.GothamBold,
            FontSize = Enum.FontSize.Size18
        })
    end)
end)

-- Shi Wei X Sicheys - v1.3 -
-- Giao diện đơn giản, bỏ loading, fix lỗi HTTP

-- UI Library
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

-- Window chính
local Window = OrionLib:MakeWindow({Name = "Shi Wei X Sicheys - v1.3 -", HidePremium = false, SaveConfig = true, ConfigFolder = "ShiweiHub"})

-- Tab Font
local FontTab = Window:MakeTab({
    Name = "Font Changer",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local Fonts = {
    {Name = "Gotham", Enum = Enum.Font.Gotham},
    {Name = "Arcade (Minecraft)", Enum = Enum.Font.Arcade},
    {Name = "Code", Enum = Enum.Font.Code},
    {Name = "Fantasy", Enum = Enum.Font.Fantasy},
    {Name = "Roboto", Enum = Enum.Font.Roboto},
    {Name = "SourceSans", Enum = Enum.Font.SourceSans},
    {Name = "Arial", Enum = Enum.Font.Arial}
}

for _, font in ipairs(Fonts) do
    FontTab:AddButton({
        Name = font.Name,
        Callback = function()
            for _, obj in ipairs(game:GetDescendants()) do
                if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                    obj.Font = font.Enum
                end
            end
            OrionLib:MakeNotification({
                Name = "Font Changed",
                Content = "Đã đổi sang font: " .. font.Name,
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    })
end

-- Tab Discord + Facebook
local SocialTab = Window:MakeTab({
    Name = "Social Links",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

SocialTab:AddButton({
    Name = "Copy Discord Link",
    Callback = function()
        setclipboard("https://discord.gg/VRUeqKfDq2")
        OrionLib:MakeNotification({
            Name = "Discord",
            Content = "Đã copy link Discord!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

SocialTab:AddButton({
    Name = "Copy Facebook Link",
    Callback = function()
        setclipboard("https://www.facebook.com/share/1JBQN79NvP/")
        OrionLib:MakeNotification({
            Name = "Facebook",
            Content = "Đã copy link Facebook!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

-- Kết thúc
OrionLib:Init()

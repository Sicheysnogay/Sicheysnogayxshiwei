-- shiwei-v1.2.lua
-- Shi Wei X Sicheys - v1.2 -
-- Features: graphics scale, FPS display, fog toggle, visual boost (bloom/cc), server tools

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Shi Wei X Sicheys - v1.2 -",
    LoadingTitle = "Shi Wei Hub",
    LoadingSubtitle = "by shi wei",
    ConfigurationSaving = {
       Enabled = true,
       FolderName = "ShiweiHub",
       FileName = "shiwei-v1.2"
    }
})

-- Tabs
local HomeTab = Window:CreateTab("Home", 4483362458)
local GraphicsTab = Window:CreateTab("Graphics", 4483362458)
local FPS_Tab = Window:CreateTab("FPS", 4483362458)
local ServerTab = Window:CreateTab("Server", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- Links
HomeTab:CreateParagraph({Title="Author", Content="shi wei"})
HomeTab:CreateButton({Name="Discord Invite", Callback=function()
    if setclipboard then pcall(setclipboard, "https://discord.gg/VRUeqKfDq2") end
    Rayfield:Notify({Title="Copied", Content="Discord link đã copy!", Duration=3})
end})
HomeTab:CreateButton({Name="Facebook Link", Callback=function()
    if setclipboard then pcall(setclipboard, "https://www.facebook.com/share/1JBQN79NvP/") end
    Rayfield:Notify({Title="Copied", Content="Facebook link đã copy!", Duration=3})
end})

-- Graphics controls (scale 20%..90%)
-- We'll map scale to some Lighting + PostEffect adjustments
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

-- Ensure Bloom and ColorCorrection exist
local function getOrCreatePostEffect(className, name)
    local found = Lighting:FindFirstChild(name)
    if found and found.ClassName == className then return found end
    local obj = Instance.new(className)
    obj.Name = name
    obj.Parent = Lighting
    return obj
end
local Bloom = getOrCreatePostEffect("BloomEffect", "Shiwei_Bloom")
local CC = getOrCreatePostEffect("ColorCorrection", "Shiwei_Color")
local Blur = getOrCreatePostEffect("BlurEffect", "Shiwei_Blur")

-- Store original values to restore
local original = {
    Bloom = Bloom.Intensity,
    Brightness = Lighting.Brightness,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd,
    CC_Contrast = CC.Contrast,
    CC_Saturation = CC.Saturation,
    Blur_Size = Blur.Size
}

-- Apply graphics scale (20..90)
local function applyGraphicsScale(pct)
    pct = math.clamp(pct, 20, 90)
    local t = (pct - 20) / (90 - 20) -- 0..1
    -- adjust Bloom intensity 0.2..2.0
    Bloom.Intensity = 0.2 + t * (2.0 - 0.2)
    -- brightness 1..3
    Lighting.Brightness = 1 + t * 2
    Lighting.OutdoorAmbient = Color3.fromHSV(0.58, 0.2 + t*0.5, 0.6 + t*0.4)
    -- subtle blur for lower quality -> reduce blur when quality high
    Blur.Size = 6 * (1 - t)
    -- color correction contrast/saturation
    CC.Contrast = -0.1 + t * 0.4
    CC.Saturation = -0.2 + t * 0.6
end

-- Slider control
GraphicsTab:CreateSlider({
    Name = "Graphics Scale (20% - 90%)",
    Range = {20, 90},
    Increment = 5,
    Suffix = "%",
    CurrentValue = 60,
    Flag = "graphics_scale",
    Callback = function(value)
        applyGraphicsScale(value)
    end
})

-- Fog toggle (remove fog)
local fogRemoved = false
GraphicsTab:CreateToggle({
    Name = "Remove Fog",
    CurrentValue = false,
    Callback = function(state)
        fogRemoved = state
        if state then
            Lighting.FogStart = 1e6
            Lighting.FogEnd = 1e9
        else
            Lighting.FogStart = original.FogStart or 0
            Lighting.FogEnd = original.FogEnd or 100000
        end
    end
})

-- Visual boost (approximate 'RTX-like' look using effects)
local boostEnabled = false
GraphicsTab:CreateToggle({
    Name = "Visual Boost (bloom/cc)",
    CurrentValue = false,
    Callback = function(state)
        boostEnabled = state
        if state then
            Bloom.Intensity = Bloom.Intensity * 1.6
            CC.Contrast = CC.Contrast + 0.12
            CC.Saturation = CC.Saturation + 0.1
        else
            Bloom.Intensity = original.Bloom
            CC.Contrast = original.CC_Contrast
            CC.Saturation = original.CC_Saturation
        end
    end
})

-- FPS display
local fpsLabel = nil
local showFPS = false
local lastTime = tick()
local frameCount = 0
local fpsConn = nil

local function createFPSLabel()
    if fpsLabel and fpsLabel.Parent then return fpsLabel end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ShiweiFPS"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")
    fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(0,120,0,30)
    fpsLabel.Position = UDim2.new(0,10,0,10)
    fpsLabel.BackgroundTransparency = 0.5
    fpsLabel.BackgroundColor3 = Color3.new(0,0,0)
    fpsLabel.TextColor3 = Color3.new(1,1,1)
    fpsLabel.TextScaled = true
    fpsLabel.Font = Enum.Font.Gotham
    fpsLabel.Text = "FPS: ..."
    fpsLabel.Parent = screenGui
    return fpsLabel
end

local function startFPS()
    if fpsConn then return end
    createFPSLabel()
    fpsConn = RunService.RenderStepped:Connect(function(dt)
        frameCount = frameCount + 1
        local now = tick()
        if now - lastTime >= 1 then
            local fps = math.floor(frameCount / (now - lastTime) + 0.5)
            if fpsLabel then fpsLabel.Text = "FPS: "..tostring(fps) end
            frameCount = 0
            lastTime = now
        end
    end)
end

local function stopFPS()
    if fpsConn then fpsConn:Disconnect(); fpsConn = nil end
    if fpsLabel then fpsLabel:Destroy(); fpsLabel = nil end
end

FPS_Tab:CreateToggle({
    Name = "Show FPS",
    CurrentValue = false,
    Callback = function(state)
        showFPS = state
        if state then startFPS() else stopFPS() end
    end
})

-- Server tools
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

local function getPlayerCount()
    return #Players:GetPlayers()
end

local playersLabel = ServerTab:CreateLabel("Players in server: " .. tostring(getPlayerCount()))
-- update players count every 5 seconds
spawn(function()
    while true do
        pcall(function()
            playersLabel:Set("Players in server: " .. tostring(getPlayerCount()))
        end)
        wait(5)
    end
end)

-- Show current game's name (best effort)
local ok, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
if ok and info and info.Name then
    ServerTab:CreateLabel("Game: "..tostring(info.Name))
end

-- Rejoin server
ServerTab:CreateButton({Name = "Rejoin Server", Callback = function()
    TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
end})

-- Join random other server with less players (uses Roblox servers API if executor supports http)
ServerTab:CreateButton({Name = "Join Low Pop Server", Callback = function()
    local success = false
    local placeId = tostring(game.PlaceId)
    local requestFunc = nil
    if syn and syn.request then requestFunc = syn.request
    elseif http and http.request then requestFunc = http.request
    elseif request then requestFunc = request end
    if requestFunc then
        local cursor = ""
        repeat
            local url = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?limit=100"..(cursor ~= "" and ("&cursor="..cursor) or "")
            local res = nil
            pcall(function() res = requestFunc({Url = url, Method = "GET"}) end)
            if res and res.Body then
                local data = nil
                pcall(function() data = HttpService:JSONDecode(res.Body) end)
                if data and data.data then
                    for _, s in ipairs(data.data) do
                        if s.playing and s.playing < (Players.MaxPlayers or 10) then
                            pcall(function()
                                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, Players.LocalPlayer)
                            end)
                            success = true
                            break
                        end
                    end
                    cursor = data.nextPageCursor or ""
                else
                    break
                end
            else
                break
            end
        until success or cursor == ""
    end
    if not success then
        Rayfield:Notify({Title="Info", Content="Không thể tìm server ít người (hoặc HTTP bị chặn).", Duration=4})
    end
end})

-- Safety: apply default graphics scale at load
applyGraphicsScale(60)

Rayfield:Notify({Title="Shiwei", Content="Loaded v1.2", Duration=3})

-- End of file

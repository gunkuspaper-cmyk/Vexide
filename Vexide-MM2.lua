-- Vexide-MM2 (Murder Mystery 2 Edition) - Ported to WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Transparency setup (must be before CreateWindow)
WindUI.TransparencyValue = 0.15

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ==================== WINDOW ====================
local Window = WindUI:CreateWindow({
    Title = "Vexide-MM2",
    Author = "Murder Mystery 2",
    Icon = "sword",
    Theme = "Dark",
    Folder = "VexideMM2",
    Size = UDim2.fromOffset(680, 460),
    ToggleKey = Enum.KeyCode.Insert,
    Transparent = true,
})

-- ==================== TABS ====================
local mm2Tab        = Window:Tab({ Title = "Main",       Icon = "sword" })
local visualsTab    = Window:Tab({ Title = "Visuals",    Icon = "eye" })
local movementTab   = Window:Tab({ Title = "Movement",   Icon = "move" })
local teleportsTab  = Window:Tab({ Title = "Teleports",  Icon = "map-pin" })
local automationTab = Window:Tab({ Title = "Automation", Icon = "bot" })
local miscTab       = Window:Tab({ Title = "Misc",       Icon = "settings" })

-- ==================== HELPERS ====================
local function GetMurderer()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and (plr.Character:FindFirstChild("Knife") or (plr:FindFirstChild("Backpack") and plr.Backpack:FindFirstChild("Knife"))) then
            return plr
        end
    end
    return nil
end

local function GetSheriff()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and (plr.Character:FindFirstChild("Gun") or (plr:FindFirstChild("Backpack") and plr.Backpack:FindFirstChild("Gun"))) then
            return plr
        end
    end
    return nil
end

-- ==================== MAIN ====================

local silentAimEnabled = false
if getrawmetatable then
    local gmt = getrawmetatable(game)
    setreadonly(gmt, false)
    local oldNamecall = gmt.__namecall
    gmt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if silentAimEnabled and (method == "FireServer" or method == "fireServer") and tostring(self) == "Shoot" then
            local m = GetMurderer()
            if m and m.Character and m.Character:FindFirstChild("HumanoidRootPart") then
                args[1] = m.Character.HumanoidRootPart.Position
                return oldNamecall(self, unpack(args))
            end
        end
        return oldNamecall(self, ...)
    end)
end

mm2Tab:Toggle({
    Title = "Silent Aim",
    Desc = "Sheriff shots lock onto murderer",
    Value = false,
    Callback = function(state)
        silentAimEnabled = state
    end,
})

local autoShootLoop = nil
mm2Tab:Toggle({
    Title = "Auto Shoot",
    Desc = "Automatically shoot the murderer",
    Value = false,
    Callback = function(state)
        if state then
            autoShootLoop = task.spawn(function()
                while true do
                    local m = GetMurderer()
                    if m and m.Character and m.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun") then
                        local gun = LocalPlayer.Character.Gun
                        if gun:FindFirstChild("Shoot") then
                            gun.Shoot:FireServer(m.Character.HumanoidRootPart.Position)
                        end
                    end
                    task.wait(0.3)
                end
            end)
        else
            if autoShootLoop then task.cancel(autoShootLoop) end
        end
    end,
})

mm2Tab:Button({
    Title = "Kill All",
    Desc = "Teleport to every player (Murderer only)",
    Callback = function()
        local knife = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Knife") or (LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Knife"))
        if knife then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
                    task.wait(0.1)
                end
            end
        end
    end,
})

local autoCoinLoop = nil
mm2Tab:Toggle({
    Title = "Auto Coins",
    Desc = "Farm all coins on the map",
    Value = false,
    Callback = function(state)
        if state then
            autoCoinLoop = task.spawn(function()
                while true do
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local coinContainer = nil
                        for _, v in ipairs(Workspace:GetDescendants()) do
                            if v.Name == "CoinContainer" or v.Name == "CoinServer" or (v.Name == "Coin" and v:IsA("BasePart")) then
                                if v.Name == "Coin" then coinContainer = v.Parent break end
                            end
                        end
                        if coinContainer then
                            for _, coin in ipairs(coinContainer:GetChildren()) do
                                if coin:IsA("BasePart") and coin.Name == "Coin" and coin.Transparency < 0.9 then
                                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                        LocalPlayer.Character.HumanoidRootPart.CFrame = coin.CFrame
                                        task.wait(0.12)
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.3)
                end
            end)
        else
            if autoCoinLoop then task.cancel(autoCoinLoop) end
        end
    end,
})

local knifeAuraLoop = nil
mm2Tab:Toggle({
    Title = "Knife Aura",
    Desc = "Auto attack nearby players",
    Value = false,
    Callback = function(state)
        if state then
            knifeAuraLoop = task.spawn(function()
                while true do
                    local knife = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Knife")
                    if knife then
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                                if dist < 15 then
                                    knife:Activate()
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        else
            if knifeAuraLoop then task.cancel(knifeAuraLoop) end
        end
    end,
})

local autoGunLoop = nil
mm2Tab:Toggle({
    Title = "Auto Grab Gun",
    Desc = "Pick up dropped gun automatically",
    Value = false,
    Callback = function(state)
        if state then
            autoGunLoop = task.spawn(function()
                while true do
                    local gunDrop = Workspace:FindFirstChild("GunDrop", true)
                    if gunDrop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = gunDrop.CFrame
                    end
                    task.wait(0.5)
                end
            end)
        else
            if autoGunLoop then task.cancel(autoGunLoop) end
        end
    end,
})

local hitboxSize = 2
mm2Tab:Slider({
    Title = "Hitbox Size",
    Desc = "Expand player hitboxes",
    Step = 1,
    Value = { Min = 2, Max = 20, Default = 2 },
    Callback = function(val)
        hitboxSize = val
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                plr.Character.HumanoidRootPart.Size = Vector3.new(val, val, val)
                plr.Character.HumanoidRootPart.Transparency = 0.7
            end
        end
    end,
})

mm2Tab:Button({
    Title = "Announce Roles",
    Desc = "Say murderer & sheriff in chat",
    Callback = function()
        local m = GetMurderer()
        local s = GetSheriff()
        local msg = "Murderer: " .. (m and m.Name or "Unknown") .. " | Sheriff: " .. (s and s.Name or "None/Dead")
        local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if chatEvents and chatEvents:FindFirstChild("SayMessageRequest") then
            chatEvents.SayMessageRequest:FireServer(msg, "All")
        end
    end,
})

local isSpectating = false
mm2Tab:Toggle({
    Title = "Spectate Murderer",
    Value = false,
    Callback = function(state)
        isSpectating = state
        if isSpectating then
            task.spawn(function()
                while isSpectating do
                    local m = GetMurderer()
                    if m and m.Character and m.Character:FindFirstChild("Humanoid") then
                        Workspace.CurrentCamera.CameraSubject = m.Character.Humanoid
                    end
                    task.wait(0.5)
                end
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
                end
            end)
        else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
            end
        end
    end,
})

local autoDodgeLoop = nil
mm2Tab:Toggle({
    Title = "Auto Dodge",
    Desc = "Escape when murderer is close",
    Value = false,
    Callback = function(state)
        if state then
            autoDodgeLoop = task.spawn(function()
                while true do
                    local m = GetMurderer()
                    if m and m ~= LocalPlayer and m.Character and m.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - m.Character.HumanoidRootPart.Position).Magnitude
                        if dist < 12 then
                            local escapeDir = (LocalPlayer.Character.HumanoidRootPart.Position - m.Character.HumanoidRootPart.Position).Unit
                            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + (escapeDir * 20)
                        end
                    end
                    task.wait(0.1)
                end
            end)
        else
            if autoDodgeLoop then task.cancel(autoDodgeLoop) end
        end
    end,
})

-- ==================== VISUALS ====================

local roleHighlights = {}
visualsTab:Toggle({
    Title = "Role ESP",
    Desc = "Highlight Murderer & Sheriff",
    Value = false,
    Callback = function(state)
        if state then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local color = Color3.fromRGB(0, 255, 100)
                    if plr == GetMurderer() then
                        color = Color3.fromRGB(255, 0, 50)
                    elseif plr == GetSheriff() then
                        color = Color3.fromRGB(0, 150, 255)
                    end
                    local hl = Instance.new("Highlight")
                    hl.Name = "MM2RoleESP"
                    hl.FillColor = color
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.Parent = plr.Character
                    table.insert(roleHighlights, hl)
                end
            end
        else
            for _, hl in ipairs(roleHighlights) do if hl then hl:Destroy() end end
            roleHighlights = {}
        end
    end,
})

local gunHighlights = {}
visualsTab:Toggle({
    Title = "Gun Drop ESP",
    Value = false,
    Callback = function(state)
        if state then
            local gunDrop = Workspace:FindFirstChild("GunDrop", true)
            if gunDrop then
                local hl = Instance.new("Highlight")
                hl.Name = "GunESP"
                hl.FillColor = Color3.fromRGB(255, 215, 0)
                hl.Parent = gunDrop
                table.insert(gunHighlights, hl)
            end
        else
            for _, hl in ipairs(gunHighlights) do if hl then hl:Destroy() end end
            gunHighlights = {}
        end
    end,
})

local tracerAdornment = nil
local tracerConn = nil
visualsTab:Toggle({
    Title = "Murderer Tracer",
    Value = false,
    Callback = function(state)
        if state then
            tracerAdornment = Instance.new("LineHandleAdornment")
            tracerAdornment.Name = "MurdererTracer"
            tracerAdornment.Color3 = Color3.fromRGB(255, 0, 0)
            tracerAdornment.Thickness = 3
            tracerAdornment.AlwaysOnTop = true
            tracerAdornment.Adornee = Workspace

            tracerConn = RunService.RenderStepped:Connect(function()
                local m = GetMurderer()
                if m and m.Character and m.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                    local mPos = m.Character.HumanoidRootPart.Position
                    tracerAdornment.Parent = Workspace
                    tracerAdornment.CFrame = CFrame.lookAt(myPos, mPos)
                    tracerAdornment.Length = (mPos - myPos).Magnitude
                else
                    tracerAdornment.Length = 0
                end
            end)
        else
            if tracerConn then tracerConn:Disconnect() end
            if tracerAdornment then tracerAdornment:Destroy() end
        end
    end,
})

local nameTags = {}
visualsTab:Toggle({
    Title = "Name Tags",
    Desc = "Show player names",
    Value = false,
    Callback = function(state)
        if state then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "MM2NameTag"
                    bb.Adornee = plr.Character.Head
                    bb.Size = UDim2.new(0, 100, 0, 30)
                    bb.StudsOffset = Vector3.new(0, 2, 0)
                    bb.AlwaysOnTop = true
                    bb.Parent = plr.Character

                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = plr.Name
                    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                    lbl.TextSize = 12
                    lbl.Font = Enum.Font.GothamBold
                    lbl.Parent = bb
                    table.insert(nameTags, bb)
                end
            end
        else
            for _, tag in ipairs(nameTags) do if tag then tag:Destroy() end end
            nameTags = {}
        end
    end,
})

local originalAmbient = Lighting.Ambient
visualsTab:Toggle({
    Title = "Fullbright",
    Value = false,
    Callback = function(state)
        Lighting.Ambient = state and Color3.fromRGB(255, 255, 255) or originalAmbient
    end,
})

local origFogEnd = Lighting.FogEnd
visualsTab:Toggle({
    Title = "No Fog",
    Value = false,
    Callback = function(state)
        Lighting.FogEnd = state and 9e9 or origFogEnd
    end,
})

local crosshairFrame = nil
visualsTab:Toggle({
    Title = "Crosshair",
    Value = false,
    Callback = function(state)
        if state then
            if not crosshairFrame then
                local gui = Instance.new("ScreenGui")
                gui.Name = "VexideCrosshair"
                gui.ResetOnSpawn = false
                pcall(function() gui.Parent = game:GetService("CoreGui") end)
                if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

                crosshairFrame = Instance.new("Frame")
                crosshairFrame.Size = UDim2.new(0, 8, 0, 8)
                crosshairFrame.Position = UDim2.new(0.5, -4, 0.5, -4)
                crosshairFrame.BackgroundColor3 = Color3.fromRGB(108, 92, 231)
                crosshairFrame.BorderSizePixel = 0
                crosshairFrame.Parent = gui
                local crCorner = Instance.new("UICorner")
                crCorner.CornerRadius = UDim.new(1, 0)
                crCorner.Parent = crosshairFrame
            end
            crosshairFrame.Visible = true
        else
            if crosshairFrame then crosshairFrame.Visible = false end
        end
    end,
})

local coinHighlights = {}
visualsTab:Toggle({
    Title = "Coin ESP",
    Value = false,
    Callback = function(state)
        if state then
            for _, v in ipairs(Workspace:GetDescendants()) do
                if (v.Name == "Coin" or v.Name == "CoinContainer") and v:IsA("BasePart") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "CoinHighlight"
                    hl.FillColor = Color3.fromRGB(255, 215, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.Parent = v
                    table.insert(coinHighlights, hl)
                end
            end
        else
            for _, hl in ipairs(coinHighlights) do if hl then hl:Destroy() end end
            coinHighlights = {}
        end
    end,
})

local alertLoop = nil
visualsTab:Toggle({
    Title = "Proximity Alert",
    Desc = "Notify when murderer is near",
    Value = false,
    Callback = function(state)
        if state then
            alertLoop = task.spawn(function()
                while true do
                    local m = GetMurderer()
                    if m and m ~= LocalPlayer and m.Character and m.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - m.Character.HumanoidRootPart.Position).Magnitude
                        if dist <= 25 then
                            WindUI:Notify({
                                Title = "DANGER",
                                Content = "Murderer is near!",
                                Icon = "alert-triangle",
                                Duration = 2,
                            })
                        end
                    end
                    task.wait(1.5)
                end
            end)
        else
            if alertLoop then task.cancel(alertLoop) end
        end
    end,
})

local rainbowLoop = nil
visualsTab:Toggle({
    Title = "Rainbow Tool",
    Desc = "Rainbow color on held tool",
    Value = false,
    Callback = function(state)
        if state then
            rainbowLoop = task.spawn(function()
                local hue = 0
                while true do
                    hue = (hue + 0.01) % 1
                    local color = Color3.fromHSV(hue, 1, 1)
                    if LocalPlayer.Character then
                        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                        if tool then
                            for _, part in ipairs(tool:GetDescendants()) do
                                if part:IsA("BasePart") or part:IsA("MeshPart") then
                                    part.Color = color
                                end
                            end
                        end
                    end
                    task.wait(0.03)
                end
            end)
        else
            if rainbowLoop then task.cancel(rainbowLoop) end
        end
    end,
})

-- ==================== MOVEMENT ====================

local currentWalkSpeed = 16
local currentJumpPower = 50

LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = currentWalkSpeed
    hum.UseJumpPower = true
    hum.JumpPower = currentJumpPower
end)

RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum.WalkSpeed ~= currentWalkSpeed then hum.WalkSpeed = currentWalkSpeed end
        if hum.JumpPower ~= currentJumpPower then hum.UseJumpPower = true hum.JumpPower = currentJumpPower end
    end
end)

movementTab:Slider({
    Title = "Walk Speed",
    Step = 1,
    Value = { Min = 16, Max = 120, Default = 16 },
    Callback = function(val)
        currentWalkSpeed = val
    end,
})

movementTab:Slider({
    Title = "Jump Power",
    Step = 1,
    Value = { Min = 50, Max = 250, Default = 50 },
    Callback = function(val)
        currentJumpPower = val
    end,
})

local flying = false
local flySpeed = 60
movementTab:Toggle({
    Title = "Fly",
    Value = false,
    Callback = function(state)
        flying = state
        if flying then
            task.spawn(function()
                while flying do
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                        local hrp = LocalPlayer.Character.HumanoidRootPart
                        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                        hum.PlatformStand = true

                        local cam = Workspace.CurrentCamera
                        local moveDir = Vector3.zero

                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end

                        if moveDir.Magnitude > 0 then
                            hrp.AssemblyLinearVelocity = moveDir.Unit * flySpeed
                        else
                            hrp.AssemblyLinearVelocity = Vector3.zero
                        end
                    end
                    task.wait()
                end
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    LocalPlayer.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false
                end
            end)
        else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false
            end
        end
    end,
})

local noclip = false
local noclipConn = nil
movementTab:Toggle({
    Title = "Noclip",
    Value = false,
    Callback = function(state)
        noclip = state
        if noclip then
            noclipConn = RunService.Stepped:Connect(function()
                if noclip and LocalPlayer.Character then
                    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        else
            if noclipConn then noclipConn:Disconnect() end
        end
    end,
})

local bhopConnection = nil
movementTab:Toggle({
    Title = "Bunny Hop",
    Value = false,
    Callback = function(state)
        if state then
            bhopConnection = RunService.RenderStepped:Connect(function()
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    if LocalPlayer.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
                        LocalPlayer.Character.Humanoid:ChangeState("Jumping")
                    end
                end
            end)
        else
            if bhopConnection then bhopConnection:Disconnect() end
        end
    end,
})

local infJumpConnection = nil
movementTab:Toggle({
    Title = "Infinite Jump",
    Value = false,
    Callback = function(state)
        if state then
            infJumpConnection = UserInputService.JumpRequest:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
                end
            end)
        else
            if infJumpConnection then infJumpConnection:Disconnect() end
        end
    end,
})

local spinConnection = nil
movementTab:Toggle({
    Title = "Spinbot",
    Value = false,
    Callback = function(state)
        if state then
            spinConnection = RunService.RenderStepped:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(30), 0)
                end
            end)
        else
            if spinConnection then spinConnection:Disconnect() end
        end
    end,
})

local originalGravity = Workspace.Gravity
movementTab:Toggle({
    Title = "Low Gravity",
    Desc = "Moon jump effect",
    Value = false,
    Callback = function(state)
        Workspace.Gravity = state and 35 or originalGravity
    end,
})

local fakeLagLoop = nil
movementTab:Toggle({
    Title = "Fake Lag",
    Desc = "Desync / jitter movement",
    Value = false,
    Callback = function(state)
        if state then
            fakeLagLoop = task.spawn(function()
                while true do
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.Anchored = true
                        task.wait(0.15)
                        LocalPlayer.Character.HumanoidRootPart.Anchored = false
                    end
                    task.wait(0.2)
                end
            end)
        else
            if fakeLagLoop then task.cancel(fakeLagLoop) end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.Anchored = false
            end
        end
    end,
})

movementTab:Toggle({
    Title = "Ghost Mode",
    Desc = "Semi-invisible character",
    Value = false,
    Callback = function(state)
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = state and 0.7 or 0
                end
            end
        end
    end,
})

-- ==================== TELEPORTS ====================

teleportsTab:Button({
    Title = "TP to Murderer",
    Callback = function()
        local m = GetMurderer()
        if m and m.Character and m.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = m.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        end
    end,
})

teleportsTab:Button({
    Title = "TP to Sheriff",
    Callback = function()
        local s = GetSheriff()
        if s and s.Character and s.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = s.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        end
    end,
})

teleportsTab:Button({
    Title = "TP to Gun",
    Callback = function()
        local gunDrop = Workspace:FindFirstChild("GunDrop", true)
        if gunDrop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = gunDrop.CFrame
        end
    end,
})

teleportsTab:Button({
    Title = "TP to Lobby",
    Callback = function()
        local lobby = Workspace:FindFirstChild("Lobby") or Workspace:FindFirstChild("SpawnLocation", true)
        if lobby and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = lobby:GetPivot() + Vector3.new(0, 5, 0)
        end
    end,
})

teleportsTab:Button({
    Title = "TP Above Map",
    Desc = "Safe high position",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 80, 0)
        end
    end,
})

local clickTpConnection = nil
teleportsTab:Toggle({
    Title = "Click TP",
    Desc = "Ctrl + Click to teleport",
    Value = false,
    Callback = function(state)
        if state then
            clickTpConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    if Mouse and Mouse.Hit and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
                    end
                end
            end)
        else
            if clickTpConnection then clickTpConnection:Disconnect() end
        end
    end,
})

-- ==================== AUTOMATION ====================

automationTab:Button({
    Title = "FPS Booster",
    Desc = "Low graphics mode",
    Callback = function()
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            elseif v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") then
                v.Enabled = false
            end
        end
        Lighting.GlobalShadows = false
    end,
})

local muteLoop = nil
automationTab:Toggle({
    Title = "Mute Sounds",
    Desc = "Mute radios & effects",
    Value = false,
    Callback = function(state)
        if state then
            muteLoop = RunService.RenderStepped:Connect(function()
                for _, sound in ipairs(Workspace:GetDescendants()) do
                    if sound:IsA("Sound") and sound.Name ~= "Shoot" then
                        sound.Volume = 0
                    end
                end
            end)
        else
            if muteLoop then muteLoop:Disconnect() end
        end
    end,
})

local xrayEnabled = false
automationTab:Toggle({
    Title = "X-Ray Walls",
    Value = false,
    Callback = function(state)
        xrayEnabled = state
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part.Parent:FindFirstChild("Humanoid") then
                part.LocalTransparencyModifier = xrayEnabled and 0.5 or 0
            end
        end
    end,
})

local autoRejoinConn = nil
automationTab:Toggle({
    Title = "Auto Rejoin",
    Desc = "Rejoin on disconnect/error",
    Value = false,
    Callback = function(state)
        if state then
            autoRejoinConn = game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
                if child.Name == "ErrorPrompt" then
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                end
            end)
        else
            if autoRejoinConn then autoRejoinConn:Disconnect() end
        end
    end,
})

automationTab:Button({
    Title = "Fake Knife",
    Desc = "Client-side fake knife",
    Callback = function()
        if LocalPlayer.Backpack then
            local fakeKnife = Instance.new("Tool")
            fakeKnife.Name = "Fake Knife"
            local handle = Instance.new("Part")
            handle.Name = "Handle"
            handle.Size = Vector3.new(1, 3, 1)
            handle.Color = Color3.fromRGB(255, 0, 0)
            handle.Parent = fakeKnife
            fakeKnife.Parent = LocalPlayer.Backpack
        end
    end,
})

-- ==================== MISC ====================

local autoClickerLoop = nil
miscTab:Toggle({
    Title = "Auto Clicker",
    Value = false,
    Callback = function(state)
        if state then
            autoClickerLoop = task.spawn(function()
                while true do
                    if mouse1click then mouse1click() end
                    task.wait(0.02)
                end
            end)
        else
            if autoClickerLoop then task.cancel(autoClickerLoop) end
        end
    end,
})

local antiAfkConnection = nil
miscTab:Toggle({
    Title = "Anti-AFK",
    Value = false,
    Callback = function(state)
        if state then
            antiAfkConnection = LocalPlayer.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            end)
        else
            if antiAfkConnection then antiAfkConnection:Disconnect() end
        end
    end,
})

miscTab:Slider({
    Title = "FOV",
    Step = 1,
    Value = { Min = 70, Max = 120, Default = 70 },
    Callback = function(val)
        Workspace.CurrentCamera.FieldOfView = val
    end,
})

miscTab:Button({
    Title = "Copy Job ID",
    Callback = function()
        if setclipboard then
            setclipboard(tostring(game.JobId))
            WindUI:Notify({ Title = "Copied", Content = "JobId copied", Duration = 3 })
        end
    end,
})

miscTab:Button({
    Title = "Server Hop",
    Callback = function()
        local api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(api)) end)
        if success and result and result.data then
            for _, server in ipairs(result.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    break
                end
            end
        end
    end,
})

miscTab:Slider({
    Title = "UI Transparency",
    Step = 1,
    Value = { Min = 0, Max = 80, Default = 15 },
    Callback = function(val)
        WindUI.TransparencyValue = val / 100
        pcall(function()
            if Window.ToggleTransparency then
                Window:ToggleTransparency(val > 0)
            end
            if Window.SetBackgroundTransparency then
                Window:SetBackgroundTransparency(val / 100)
            end
        end)
    end,
})

miscTab:Button({
    Title = "Reset Position",
    Callback = function()
        pcall(function()
            if Window.SetToTheCenter then
                Window:SetToTheCenter()
            end
        end)
        WindUI:Notify({ Title = "Info", Content = "Window centered", Duration = 3 })
    end,
})

local spammerLoop = nil
miscTab:Toggle({
    Title = "Chat Spam",
    Desc = "Spam Vexide message",
    Value = false,
    Callback = function(state)
        if state then
            spammerLoop = task.spawn(function()
                while true do
                    local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                    if chatEvents and chatEvents:FindFirstChild("SayMessageRequest") then
                        chatEvents.SayMessageRequest:FireServer("Vexide-MM2 on top!", "All")
                    end
                    task.wait(3)
                end
            end)
        else
            if spammerLoop then task.cancel(spammerLoop) end
        end
    end,
})

miscTab:Slider({
    Title = "Max Zoom",
    Step = 0.1,
    Value = { Min = 12.8, Max = 250, Default = 12.8 },
    Callback = function(val)
        LocalPlayer.CameraMaxZoomDistance = val
    end,
})

WindUI:Notify({
    Title = "Vexide-MM2",
    Content = "Loaded successfully!",
    Icon = "check",
    Duration = 4,
})

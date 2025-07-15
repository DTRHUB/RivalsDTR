-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera

-- Structures de stockage
local toggleStates = {}          -- Ex: ["Aimbot"] = true
local sliderValues = {}          -- Ex: ["Aimbot Speed"] = 3
local dropdownValues = {}        -- Ex: ["Target"] = "Head"
local keybinds = {}              -- Ex: ["Aimbot Key"] = Enum.KeyCode.E

-- Variables globales optionnelles
local gui = nil                  -- Le ScreenGui principal (déclaré plus tard)
local activeTab = nil            -- Onglet actuellement affiché

-- Creation du ScreenGui

gui = Instance.new("ScreenGui")
gui.Name = "DTR_RIVALS_GUI"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Cadre Principal du menu

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 550, 0, 580)
frame.Position = UDim2.new(0.5, -275, 0.5, -290)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)


--Titre en Haut

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "💀 RIVALS - DTR [VIP]"
title.Font = Enum.Font.Code
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(200, 200, 200)
title.BackgroundTransparency = 1

-- Barre d'onglets 

local tabNames = { "🎯 Aim", "👁️ Visuals", "🔥 Rage", "🧍 Player" }
local tabBar = Instance.new("Frame", frame)
tabBar.Size = UDim2.new(1, -40, 0, 30)
tabBar.Position = UDim2.new(0, 20, 0, 40)
tabBar.BackgroundTransparency = 1

-- Creation Onglet + Panel 

local tabs = {}
for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton", tabBar)
    btn.Size = UDim2.new(0, 125, 0, 28)
    btn.Position = UDim2.new(0, (i - 1) * 135, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Code
    btn.TextSize = 18
    btn.Text = name
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local panel = Instance.new("ScrollingFrame", frame)
    panel.Size = UDim2.new(1, -40, 0, 470)
    panel.Position = UDim2.new(0, 20, 0, 80)
    panel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
    panel.CanvasSize = UDim2.new(0, 0, 0, 1000)
    panel.ScrollBarThickness = 4
    panel.Visible = false
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 4)

    tabs[name] = panel

    btn.MouseButton1Click:Connect(function()
        if activeTab then activeTab.Visible = false end
        panel.Visible = true
        activeTab = panel
    end)
end


-- Activer l’onglet AIM par défaut
tabs["🎯 Aim"].Visible = true
activeTab = tabs["🎯 Aim"]

-- Createur de toggle On/Off ou peux etre direct importation jsp a voir 

function createToggle(label)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 180, 0, 30)
    b.BackgroundColor3 = Color3.fromRGB(60,60,60)
    b.Font = Enum.Font.Code
    b.TextSize = 16
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = label .. ": OFF"
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,4)

    toggleStates[label] = false
    b.MouseButton1Click:Connect(function()
        toggleStates[label] = not toggleStates[label]
        b.Text = label .. ": " .. (toggleStates[label] and "ON" or "OFF")
    end)

    return b
end

--  Createur de slider 1 a 5
function createSlider(label)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0,180,0,50)
    container.BackgroundTransparency = 1

    local text = Instance.new("TextLabel", container)
    text.Size = UDim2.new(1,0,0,20)
    text.Font = Enum.Font.Code
    text.TextSize = 16
    text.TextColor3 = Color3.new(1,1,1)
    text.Text = label .. ": [3]"
    text.BackgroundTransparency = 1

    local track = Instance.new("Frame", container)
    track.Size = UDim2.new(1,0,0,6)
    track.Position = UDim2.new(0,0,0,25)
    track.BackgroundColor3 = Color3.fromRGB(80,80,80)
    Instance.new("UICorner", track).CornerRadius = UDim.new(0,3)

    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new(0.5, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(120,120,120)
    fill.BorderSizePixel = 0

    sliderValues[label] = 3
    local dragging = false

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = input.Position.X - track.AbsolutePosition.X
            local val = math.clamp(math.floor((rel / track.AbsoluteSize.X) * 5 + 1), 1, 5)
            sliderValues[label] = val
            text.Text = label .. ": [" .. val .. "]"
            fill.Size = UDim2.new((val - 1)/4, 0, 1, 0)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    fill.Parent = track
    track.Parent = container

    return container
end

-- Createur de dropdown cyclique 

function createDropdown(label, options)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 180, 0, 30)
    b.BackgroundColor3 = Color3.fromRGB(60,60,60)
    b.Font = Enum.Font.Code
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 16
    b.Text = label .. ": " .. options[1]
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,4)

    dropdownValues[label] = options[1]
    b.MouseButton1Click:Connect(function()
        local i = table.find(options, dropdownValues[label]) or 1
        dropdownValues[label] = options[(i % #options) + 1]
        b.Text = label .. ": " .. dropdownValues[label]
    end)

    return b
end


-- Createur de Keybinds (souris + clavier normalement faut faire en sorte que sa comprenne les deux au mieux)

function createKeybind(label)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 180, 0, 30)
    b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    b.Font = Enum.Font.Code
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 16

    if not keybinds[label] then keybinds[label] = Enum.KeyCode.E end
    b.Text = label .. ": " .. keybinds[label].Name
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)

    b.MouseButton1Click:Connect(function()
        b.Text = label .. ": [Press key or mouse]"
        local conn; conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                keybinds[label] = Enum.UserInputType.MouseButton1
                b.Text = label .. ": LeftClick"
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                keybinds[label] = Enum.UserInputType.MouseButton2
                b.Text = label .. ": RightClick"
            elseif input.KeyCode and input.KeyCode ~= Enum.KeyCode.Unknown then
                keybinds[label] = input.KeyCode
                b.Text = label .. ": " .. input.KeyCode.Name
            else
                b.Text = label .. ": [Invalid]"
            end
            conn:Disconnect()
        end)
    end)

    return b
end

-- Organisateur d'élement :


function populate(tab, elements)
    local y = 10
    for _, e in ipairs(elements) do
        e.Position = UDim2.new(0, 20, 0, y)
        e.Parent = tab
        y += e.Size.Y.Offset + 10
    end
end

-- Objectif : Construire une interface de facon dynamique (faut que j'apprend encore un peu a m'améliorer)

populate(tabs["🎯 Aim"], {
    createToggle("Aimbot"),
    createKeybind("Aimbot Key"),
    createSlider("Aimbot Speed"),
    createDropdown("Target", {"Head", "Torso", "Legs"})
})


-- Bloc concernant la page aim et qui va faire fonctionner normalement si je reussis le aim


RunService.RenderStepped:Connect(function()
    if not toggleStates["Aimbot"] then return end
    if not LocalPlayer.Character then return end

    local key = keybinds["Aimbot Key"]
    if not key then return end

    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- 🎮 Détection clavier ou souris
    local mouseHeld = false
    local keyboardHeld = false

    if typeof(key) == "EnumItem" then
        if key.EnumType == Enum.KeyCode then
            keyboardHeld = UserInputService:IsKeyDown(key)
        elseif key.EnumType == Enum.UserInputType then
            if key == Enum.UserInputType.MouseButton1 then
                mouseHeld = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
            elseif key == Enum.UserInputType.MouseButton2 then
                mouseHeld = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
            end
        end
    end

    if not (mouseHeld or keyboardHeld) then return end

    -- 🎯 Recherche de cible
    local targetPartName = dropdownValues["Target"] or "Head"
    local closest, minDistance = nil, math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local part = player.Character:FindFirstChild(targetPartName)
            local victimHRP = player.Character:FindFirstChild("HumanoidRootPart")
            if part and victimHRP then
                local dist = (camera.CFrame.Position - victimHRP.Position).Magnitude
                if dist < minDistance then
                    minDistance = dist
                    closest = part
                end
            end
        end
    end

    -- 📌 Lock de caméra
    if closest then
        local speed = (sliderValues["Aimbot Speed"] or 3) * 0.05
        local camPos = camera.CFrame.Position
        local targetPos = closest.Position
        local cf = CFrame.new(camPos, targetPos)
        camera.CFrame = camera.CFrame:Lerp(cf, speed)
    end
end)


--Interface Visuals Tabs

populate(tabs["👁️ Visuals"], {
    createToggle("Box ESP"),
    createToggle("Head ESP"),
    createToggle("Chams (Risky)"),
    createToggle("Name ESP"),
    createToggle("Distance"),
    createToggle("HealthBar ESP"),
    createToggle("Bone ESP (currently not working)"),
    createToggle("Tracer")
})


--BOX ESP

RunService.RenderStepped:Connect(function()
    for _, p in Players:GetPlayers() do
        if p == LocalPlayer or not p.Character then continue end
        local root = p.Character:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        if toggleStates["Box ESP"] then
            if not root:FindFirstChild("Z_Box") then
                local box = Instance.new("BoxHandleAdornment")
                box.Name = "Z_Box"
                box.Size = root.Size
                box.Adornee = root
                box.AlwaysOnTop = true
                box.ZIndex = 10
                box.Transparency = 0.2
                box.Color3 = Color3.new(1,1,1)
                box.Parent = root
            end
        else
            local b = root:FindFirstChild("Z_Box")
            if b then b:Destroy() end
        end
    end
end)

-- Head ESP


RunService.RenderStepped:Connect(function()
    for _, p in Players:GetPlayers() do
        if p == LocalPlayer or not p.Character then continue end
        local head = p.Character:FindFirstChild("Head")
        if not head then continue end

        if toggleStates["Head ESP"] then
            if not head:FindFirstChild("Z_HeadDot") then
                local gui = Instance.new("BillboardGui", head)
                gui.Name = "Z_HeadDot"
                gui.Adornee = head
                gui.Size = UDim2.new(0, 10, 0, 10)
                gui.AlwaysOnTop = true
                gui.MaxDistance = 99999

                local dot = Instance.new("Frame", gui)
                dot.Size = UDim2.new(1, 0, 1, 0)
                dot.BackgroundColor3 = Color3.new(1, 0, 0)
                dot.BackgroundTransparency = 0.2
                dot.BorderSizePixel = 0

                local corner = Instance.new("UICorner", dot)
                corner.CornerRadius = UDim.new(1, 0)
            end
        else
            local gui = head:FindFirstChild("Z_HeadDot")
            if gui then gui:Destroy() end
        end
    end
end)


-- Chams ESP


RunService.RenderStepped:Connect(function()
    for _, p in Players:GetPlayers() do
        if p == LocalPlayer or not p.Character then continue end

        if toggleStates["Chams (Risky)"] then
            if not p.Character:FindFirstChild("Z_Chams") then
                local chams = Instance.new("Highlight", p.Character)
                chams.Name = "Z_Chams"
                chams.FillColor = Color3.fromRGB(255, 0, 0)
                chams.FillTransparency = 0.5
                chams.OutlineTransparency = 1
                chams.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            end
        else
            local c = p.Character:FindFirstChild("Z_Chams")
            if c then c:Destroy() end
        end
    end
end)


-- Name ESP

RunService.RenderStepped:Connect(function()
    for _, p in Players:GetPlayers() do
        if p == LocalPlayer or not p.Character then continue end
        local head = p.Character:FindFirstChild("Head")
        if not head then continue end

        if toggleStates["Name ESP"] then
            if not head:FindFirstChild("Z_NameESP") then
                local gui = Instance.new("BillboardGui", head)
                gui.Name = "Z_NameESP"
                gui.Adornee = head
                gui.Size = UDim2.new(0, 100, 0, 20)
                gui.StudsOffset = Vector3.new(0, 1.6, 0)
                gui.AlwaysOnTop = true
                gui.LightInfluence = 0
                gui.MaxDistance = 99999

                local label = Instance.new("TextLabel", gui)
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.Code
                label.TextScaled = true
                label.Text = p.DisplayName
                label.TextColor3 = Color3.new(1,1,1)
                label.TextStrokeTransparency = 0.4
            end
        else
            local gui = head:FindFirstChild("Z_NameESP")
            if gui then gui:Destroy() end
        end
    end
end)


-- Distance ESP


RunService.RenderStepped:Connect(function()
    for _, p in Players:GetPlayers() do
        if p == LocalPlayer or not p.Character then continue end
        local head = p.Character:FindFirstChild("Head")
        if not head then continue end

        local dist = math.floor((camera.CFrame.Position - head.Position).Magnitude)

        if toggleStates["Distance"] then
            local gui = head:FindFirstChild("Z_DistanceESP")
            if not gui then
                gui = Instance.new("BillboardGui", head)
                gui.Name = "Z_DistanceESP"
                gui.Size = UDim2.new(0, 100, 0, 20)
                gui.StudsOffset = Vector3.new(0, 2.2, 0)
                gui.AlwaysOnTop = true
                gui.LightInfluence = 0
                gui.MaxDistance = 99999

                local label = Instance.new("TextLabel", gui)
                label.Name = "Label"
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.Code
                label.TextScaled = true
                label.TextColor3 = Color3.new(1, 1, 1)
                label.TextStrokeTransparency = 0.4
                label.Text = dist .. "m"
                label.Parent = gui
            else
                local label = gui:FindFirstChild("Label")
                if label then label.Text = dist .. "m" end
            end
            gui.Parent = head
        else
            local gui = head:FindFirstChild("Z_DistanceESP")
            if gui then gui:Destroy() end
        end
    end
end)

-- HealthBar 


RunService.RenderStepped:Connect(function()
    for _, p in Players:GetPlayers() do
        if p == LocalPlayer or not p.Character then continue end
        local head = p.Character:FindFirstChild("Head")
        local hp = p.Character:FindFirstChildOfClass("Humanoid")
        if not head or not hp then continue end

        local ratio = math.clamp(hp.Health / hp.MaxHealth, 0, 1)

        if toggleStates["HealthBar ESP"] then
            local gui = head:FindFirstChild("Z_HealthBarESP")
            if not gui then
                gui = Instance.new("BillboardGui", head)
                gui.Name = "Z_HealthBarESP"
                gui.Size = UDim2.new(0, 6, 0, 50)
                gui.StudsOffset = Vector3.new(-1.2, 1.2, 0)
                gui.AlwaysOnTop = true
                gui.LightInfluence = 0
                gui.MaxDistance = 99999

                local bar = Instance.new("Frame", gui)
                bar.Name = "Bar"
                bar.Size = UDim2.new(1, 0, ratio, 0)
                bar.Position = UDim2.new(0, 0, 1 - ratio, 0)
                bar.BorderSizePixel = 0
                bar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            else
                local bar = gui:FindFirstChild("Bar")
                if bar then
                    bar.Size = UDim2.new(1, 0, ratio, 0)
                    bar.Position = UDim2.new(0, 0, 1 - ratio, 0)

                    if ratio > 0.7 then
                        bar.BackgroundColor3 = Color3.fromRGB(0,255,0)
                    elseif ratio > 0.35 then
                        bar.BackgroundColor3 = Color3.fromRGB(255,255,0)
                    else
                        bar.BackgroundColor3 = Color3.fromRGB(255,0,0)
                    end
                end
            end
            gui.Parent = head
        else
            local gui = head:FindFirstChild("Z_HealthBarESP")
            if gui then gui:Destroy() end
        end
    end
end)


-- Bone ESP

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character then continue end
        local char = player.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        -- 🩻 Liste des membres R6 & R15
        local rigR6 = {
            "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"
     }
        local rigR15 = {
            "Head", "UpperTorso", "LowerTorso",
            "LeftUpperArm", "LeftLowerArm", "RightUpperArm", "RightLowerArm",
            "LeftUpperLeg", "LeftLowerLeg", "RightUpperLeg", "RightLowerLeg"
     }

        -- 🧬 Choix dynamique selon le rig
        local rigParts = char:FindFirstChild("Torso") and rigR6 or rigR15

        if toggleStates["Bone ESP"] then
            for _, limb in ipairs(rigParts) do
                local part = char:FindFirstChild(limb)
                if part and not part:FindFirstChild("Z_BoneBeam") then
                    local beam = Instance.new("Beam")
                    beam.Name = "Z_BoneBeam"
                    beam.Width0 = 0.1
                    beam.Width1 = 0.1
                    beam.Color = ColorSequence.new(Color3.new(1,1,1))
                    beam.FaceCamera = true
                    beam.LightInfluence = 0

                    local a0 = Instance.new("Attachment", part)
                    local a1 = hrp:FindFirstChildWhichIsA("Attachment") or Instance.new("Attachment", hrp)

                    beam.Attachment0 = a0
                    beam.Attachment1 = a1
                    beam.Parent = part
                end
            end
        else
            for _, limb in ipairs(rigParts) do
                local part = char:FindFirstChild(limb)
                if part then
                    local beam = part:FindFirstChild("Z_BoneBeam")
                    if beam then beam:Destroy() end
                    for _, att in ipairs(part:GetChildren()) do
                        if att:IsA("Attachment") then att:Destroy() end
                    end
                end
            end
        end
    end
end)


--Tracer 


RunService.RenderStepped:Connect(function()
    for _, p in Players:GetPlayers() do
        if p == LocalPlayer or not p.Character then continue end
        local root = p.Character:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHRP then continue end

        if toggleStates["Tracer"] and not root:FindFirstChild("Z_Tracer") then
            local beam = Instance.new("Beam")
            beam.Name = "Z_Tracer"
            beam.Width0 = 0.1
            beam.Width1 = 0.1
            beam.Color = ColorSequence.new(Color3.new(1,1,1))
            beam.FaceCamera = true
            beam.LightInfluence = 0

            local a0 = Instance.new("Attachment", root)
            local a1 = Instance.new("Attachment", myHRP)

            beam.Attachment0 = a0
            beam.Attachment1 = a1
            beam.Parent = root
        elseif not toggleStates["Tracer"] and root:FindFirstChild("Z_Tracer") then
            for _, obj in ipairs(root:GetChildren()) do
                if obj:IsA("Beam") or obj:IsA("Attachment") then obj:Destroy() end
            end
        end
    end
end)


-- TABS RAGE

populate(tabs["🔥 Rage"], {
    createToggle("SpinBot"),
    createToggle("Infinite Jump"),
    createToggle("Big Players")
})


--SPINBOT

local lastAngle = 0

RunService.RenderStepped:Connect(function()
    if not toggleStates["SpinBot"] then return end

    local char = LocalPlayer.Character
    if not char or not char.PrimaryPart then return end

    -- Position et orientation actuelles
    local currentPivot = char:GetPivot()

    --  Vitesse de rotation phénoménale
    local spinVelocity = 1000 -- Tu peux monter jusqu'à 5000 pour tornade extrême

    --  Incrémentation d'angle
    lastAngle += spinVelocity * RunService.RenderStepped:Wait()

    --  Application de la rotation via PivotTo
    local rotationCFrame = CFrame.Angles(0, math.rad(lastAngle), 0)
    char:PivotTo(CFrame.new(currentPivot.Position) * rotationCFrame)
end)




-- BIG PLAYER 

RunService.RenderStepped:Connect(function()
    for _, p in Players:GetPlayers() do
        if p == LocalPlayer or not p.Character then continue end

        if toggleStates["Big Players"] then
            for _, part in ipairs(p.Character:GetChildren()) do
                if part:IsA("BasePart") and not part:FindFirstChild("Z_BigTag") then
                    local originalSize = part.Size
                    local tag = Instance.new("BoolValue")
                    tag.Name = "Z_BigTag"
                    tag.Value = true
                    tag.Parent = part

                    part.Size = originalSize * 2
                    part.Massless = true
                    part.CanCollide = false
                end
            end
        else
            for _, part in ipairs(p.Character:GetChildren()) do
                if part:IsA("BasePart") and part:FindFirstChild("Z_BigTag") then
                    part.Size = part.Size / 2
                    part:FindFirstChild("Z_BigTag"):Destroy()
                end
            end
        end
    end
end)


--INFINITE JUMP 


UserInputService.JumpRequest:Connect(function()
    if toggleStates["Infinite Jump"] and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)


--TABS PLAYER


populate(tabs["🧍 Player"], {
    createToggle("Unlock 3rd Person"),
    createSlider("CFrame Speed")
})

--SLIDER SPEED

local keysHeld = {}
local keyMap = {
    [Enum.KeyCode.W] = Vector3.new(0, 0, -1),
    [Enum.KeyCode.S] = Vector3.new(0, 0, 1),
    [Enum.KeyCode.A] = Vector3.new(-1, 0, 0),
    [Enum.KeyCode.D] = Vector3.new(1, 0, 0)
}

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if keyMap[input.KeyCode] then
        keysHeld[input.KeyCode] = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    if keyMap[input.KeyCode] then
        keysHeld[input.KeyCode] = nil
    end
end)

RunService.RenderStepped:Connect(function()
    local speed = sliderValues["CFrame Speed"] or 0
    if speed <= 0 then return end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local moveVector = Vector3.zero
    for key, dir in pairs(keyMap) do
        if keysHeld[key] then
            moveVector += dir
        end
    end
    if moveVector.Magnitude == 0 then return end

    local direction = camera.CFrame:VectorToWorldSpace(moveVector).Unit
    direction = Vector3.new(direction.X, 0, direction.Z)

    root.CFrame += direction * (speed * 0.1)
end)


--UNLOCK 3RD PERSON

RunService.RenderStepped:Connect(function()
    if toggleStates["Unlock 3rd Person"] and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- 👁️ Calcul de la position caméra
        local distance = 8
        local height = 3
        local playerPos = hrp.Position
        local camPos = playerPos - hrp.CFrame.LookVector * distance + Vector3.new(0, height, 0)

        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = CFrame.new(camPos, playerPos)

        UserInputService.MouseIconEnabled = true
    else
        camera.CameraType = Enum.CameraType.Custom
    end
end)


local guiVisible = true -- Ton GUI est visible au démarrage

-- 🔁 Fonction pour activer / désactiver le menu et la souris
local function updateMenuState()
    gui.Enabled = guiVisible
    UserInputService.MouseIconEnabled = guiVisible
    UserInputService.MouseBehavior = guiVisible and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
end

-- ⌨️ Toggle menu via Insert ou RightShift
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightShift then
        guiVisible = not guiVisible
        updateMenuState()
    end
end)

-- 🔁 Appliquer l’état initial (démarrage / respawn)
updateMenuState()
LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    updateMenuState()
end)


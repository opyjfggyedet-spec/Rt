-- [[ น้องเก้าไม่แจก - Instant Steal & Teleport to SafeZone ]] --

local Success, ErrorMessage = pcall(function()
    local players = game:GetService("Players")
    local runService = game:GetService("RunService")
    local proximityPromptService = game:GetService("ProximityPromptService")
    
    local player = players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    -- ลบ GUI เก่าออกถ้ามีอยู่ก่อนหน้า
    local existingGui = playerGui:FindFirstChild("NongKaoMaiJaekHub")
    if existingGui then
        existingGui:Destroy()
    end

    -- 1. สร้าง ScreenGui หลัก
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NongKaoMaiJaekHub"
    ScreenGui.Parent = playerGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- 2. ปุ่มเปิด/ปิด เมนูลอย (ชื่อ "น้องเก้าไม่แจก" + ลากขยับได้)
    local FloatBtn = Instance.new("TextButton")
    FloatBtn.Name = "FloatBtn"
    FloatBtn.Parent = ScreenGui
    FloatBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    FloatBtn.BorderSizePixel = 2
    FloatBtn.BorderColor3 = Color3.fromRGB(0, 255, 127)
    FloatBtn.Position = UDim2.new(0, 30, 0.5, -40)
    FloatBtn.Size = UDim2.new(0, 130, 0, 45)
    FloatBtn.Font = Enum.Font.SourceSansBold
    FloatBtn.Text = "🇹🇭 น้องเก้าไม่แจก"
    FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    FloatBtn.TextSize = 14
    FloatBtn.Active = true
    FloatBtn.Draggable = true

    local UICornerFloat = Instance.new("UICorner")
    UICornerFloat.CornerRadius = UDim.new(0, 8)
    UICornerFloat.Parent = FloatBtn

    -- 3. หน้าต่าง UI หลัก (ลากขยับได้ - เพิ่มความสูงรองรับปุ่มใหม่)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -160, 0.5, -145)
    MainFrame.Size = UDim2.new(0, 320, 0, 310)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Visible = false

    local UICornerMain = Instance.new("UICorner")
    UICornerMain.CornerRadius = UDim.new(0, 8)
    UICornerMain.Parent = MainFrame

    -- แถบหัวข้อ UI (แสดงชื่อ น้องเก้าไม่แจก)
    local TopBar = Instance.new("Frame")
    TopBar.Parent = MainFrame
    TopBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 32)

    local UICornerTop = Instance.new("UICorner")
    UICornerTop.CornerRadius = UDim.new(0, 8)
    UICornerTop.Parent = TopBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = TopBar
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.Size = UDim2.new(0.8, 0, 1, 0)
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.Text = "น้องเก้าไม่แจก - กดทันที + วาร์ป"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 11
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- ปุ่มปิดหน้าต่าง (X)
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = TopBar
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.Position = UDim2.new(1, -28, 0.5, -10)
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Font = Enum.Font.SourceSansBold
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 12

    local UICornerClose = Instance.new("UICorner")
    UICornerClose.CornerRadius = UDim.new(0, 4)
    UICornerClose.Parent = CloseBtn

    CloseBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end)

    FloatBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)

    -- พื้นที่แสดงปุ่มตั้งค่า
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Parent = MainFrame
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Position = UDim2.new(0, 10, 0, 42)
    ContentFrame.Size = UDim2.new(1, -20, 1, -50)

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = ContentFrame
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 8)

    -- 4. ตัวแปรสถานะ
    local instantStealActive = false
    local autoTeleportOnSteal = false
    local safeZonePosition = nil
    local isTeleporting = false

    -- ปุ่มบันทึกจุดเขตปลอดภัย
    local SetSafeBtn = Instance.new("TextButton")
    SetSafeBtn.Parent = ContentFrame
    SetSafeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SetSafeBtn.Size = UDim2.new(1, 0, 0, 38)
    SetSafeBtn.Font = Enum.Font.SourceSansBold
    SetSafeBtn.Text = "📍 บันทึกจุดเขตปลอดภัย (ยืนจุดที่ต้องการ)"
    SetSafeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SetSafeBtn.TextSize = 13

    local UICornerS1 = Instance.new("UICorner")
    UICornerS1.CornerRadius = UDim.new(0, 6)
    UICornerS1.Parent = SetSafeBtn

    SetSafeBtn.MouseButton1Click:Connect(function()
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            safeZonePosition = hrp.CFrame + (hrp.CFrame.LookVector * 3)
            SetSafeBtn.Text = "✅ บันทึกจุดเขตปลอดภัยเรียบร้อย!"
            task.delay(1.5, function()
                SetSafeBtn.Text = "📍 บันทึกจุดเขตปลอดภัย (ยืนจุดที่ต้องการ)"
            end)
        end
    end)

    -- ปุ่มเปิด/ปิด ระบบกดขโมยทันที (Instant Steal)
    local ToggleInstantBtn = Instance.new("TextButton")
    ToggleInstantBtn.Parent = ContentFrame
    ToggleInstantBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    ToggleInstantBtn.Size = UDim2.new(1, 0, 0, 38)
    ToggleInstantBtn.Font = Enum.Font.SourceSansBold
    ToggleInstantBtn.Text = "⚡ กดขโมยไข่ทันที (ไม่ต้องรอ): ปิด"
    ToggleInstantBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleInstantBtn.TextSize = 13

    local UICornerS2 = Instance.new("UICorner")
    UICornerS2.CornerRadius = UDim.new(0, 6)
    UICornerS2.Parent = ToggleInstantBtn

    ToggleInstantBtn.MouseButton1Click:Connect(function()
        instantStealActive = not instantStealActive
        if instantStealActive then
            ToggleInstantBtn.Text = "⚡ กดขโมยไข่ทันที (ไม่ต้องรอ): เปิด"
            ToggleInstantBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        else
            ToggleInstantBtn.Text = "⚡ กดขโมยไข่ทันที (ไม่ต้องรอ): ปิด"
            ToggleInstantBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        end
    end)

    -- ปุ่มเปิด/ปิด ระบบวาร์ปกลับเมื่อขโมยไข่
    local ToggleTeleportBtn = Instance.new("TextButton")
    ToggleTeleportBtn.Parent = ContentFrame
    ToggleTeleportBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    ToggleTeleportBtn.Size = UDim2.new(1, 0, 0, 38)
    ToggleTeleportBtn.Font = Enum.Font.SourceSansBold
    ToggleTeleportBtn.Text = "🌀 วาร์ปกลับเขตปลอดภัยอัตโนมัติ: ปิด"
    ToggleTeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleTeleportBtn.TextSize = 13

    local UICornerS3 = Instance.new("UICorner")
    UICornerS3.CornerRadius = UDim.new(0, 6)
    UICornerS3.Parent = ToggleTeleportBtn

    ToggleTeleportBtn.MouseButton1Click:Connect(function()
        autoTeleportOnSteal = not autoTeleportOnSteal
        if autoTeleportOnSteal then
            ToggleTeleportBtn.Text = "🌀 วาร์ปกลับเขตปลอดภัยอัตโนมัติ: เปิด"
            ToggleTeleportBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        else
            ToggleTeleportBtn.Text = "🌀 วาร์ปกลับเขตปลอดภัยอัตโนมัติ: ปิด"
            ToggleTeleportBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        end
    end)

    -- คำแนะนำการใช้งาน
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Parent = ContentFrame
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Size = UDim2.new(1, 0, 0, 75)
    InfoLabel.Font = Enum.Font.SourceSans
    InfoLabel.Text = "💡 วิธีใช้ [น้องเก้าไม่แจก]:\n1. บันทึกจุดเขตปลอดภัย\n2. เปิด 'กดขโมยไข่ทันที' และ 'วาร์ปกลับเขตปลอดภัย'\n3. เดินไปใกล้ไข่แล้วกด ระบบจะกดและวาร์ปให้ทันที!"
    InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    InfoLabel.TextSize = 11
    InfoLabel.TextWrapped = true

    -- 5. ฟังก์ชันวาร์ปทันที
    local function InstantTeleport()
        if isTeleporting then return end
        isTeleporting = true

        task.spawn(function()
            local char = player.Character
            if not char then 
                isTeleporting = false
                return 
            end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            
            if hrp and humanoid and humanoid.Health > 0 then
                if not safeZonePosition then
                    safeZonePosition = hrp.CFrame + (hrp.CFrame.LookVector * 3)
                end

                local targetPos = safeZonePosition
                
                local holdStart = os.clock()
                while (os.clock() - holdStart) < 0.35 do
                    if not hrp.Parent then break end
                    hrp.CFrame = targetPos
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                    runService.Heartbeat:Wait()
                end
            end
            
            task.wait(0.05)
            isTeleporting = false
        end)
    end

    -- 6. ระบบบังคับลดเวลา ProximityPrompt ให้เป็น 0 (กดทันที) และสั่งวาร์ปเมื่อกด
    proximityPromptService.PromptTriggered:Connect(function(prompt, triggeringPlayer)
        if triggeringPlayer == player and autoTeleportOnSteal then
            local action = (prompt.ActionText or ""):lower()
            local object = (prompt.ObjectText or ""):lower()
            
            if action:find("steal") or object:find("steal") or action:find("ขโมย") or object:find("ขโมย") then
                InstantTeleport()
            end
        end
    end)

    -- ลูปเช็กปรับเวลา ProximityPrompt รอบตัวให้กดได้ทันที
    task.spawn(function()
        while true do
            if instantStealActive then
                pcall(function()
                    local char = player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    
                    if hrp then
                        for _, prompt in ipairs(workspace:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                                local parentPart = prompt.Parent
                                local isBasePart = parentPart and parentPart:IsA("BasePart")
                                
                                if isBasePart and (parentPart.Position - hrp.Position).Magnitude <= 30 then
                                    local action = (prompt.ActionText or ""):lower()
                                    local object = (prompt.ObjectText or ""):lower()
                                    
                                    local isSteal = action:find("steal") or object:find("steal") or action:find("ขโมย") or object:find("ขโมย")
                                    local isShop = action:find("shop") or object:find("shop") or action:find("buy") or object:find("buy") or action:find("ร้าน")

                                    if isSteal and not isShop then
                                        prompt.HoldDuration = 0 -- ทำให้กดปุ๊บติดปั๊บทันทีไม่ต้องรอ
                                    end
                                end
                            end
                        end
                    end
                end)
            end
            task.wait(0.2)
        end
    end)
end)

if not Success then
    warn("น้องเก้าไม่แจก Error: " .. tostring(ErrorMessage))
end

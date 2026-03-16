-- --- ADVANCED UI LIBRARY ---
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Library = {}

-- Utility to get a safe parent for the GUI (Executor friendly)
local function GetSafeParent()
    local success, parent = pcall(function() return CoreGui end)
    if not success or not parent then
        return Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    return parent
end

function Library:CreateWindow(windowName)
    local Window = {}
    
    -- Main GUI Setup
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KralAdvancedUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = GetSafeParent()
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 500, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame
    
    -- Top Bar (For Dragging)
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 35)
    TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TopBar.Parent = MainFrame
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 8)
    TopCorner.Parent = TopBar
    
    local Title = Instance.new("TextLabel")
    Title.Text = "  " .. windowName
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    -- Window Dragging Logic
    local dragging, dragInput, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Tab Container (Left Side)
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(0, 120, 1, -35)
    TabContainer.Position = UDim2.new(0, 0, 0, 35)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = MainFrame
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.Parent = TabContainer
    
    -- Elements Container (Right Side)
    local ElementsContainer = Instance.new("Frame")
    ElementsContainer.Size = UDim2.new(1, -130, 1, -45)
    ElementsContainer.Position = UDim2.new(0, 125, 0, 40)
    ElementsContainer.BackgroundTransparency = 1
    ElementsContainer.Parent = MainFrame

    local currentActiveTab = nil

    function Window:CreateTab(tabName)
        local Tab = {}
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, -10, 0, 30)
        TabButton.Position = UDim2.new(0, 5, 0, 0)
        TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.TextSize = 13
        TabButton.Text = tabName
        TabButton.Parent = TabContainer
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton
        
        -- Tab Page (Scrolling Frame for elements)
        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.ScrollBarThickness = 4
        TabPage.Visible = false
        TabPage.Parent = ElementsContainer
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.Parent = TabPage
        
        -- Tab Switching Logic
        TabButton.MouseButton1Click:Connect(function()
            if currentActiveTab then
                currentActiveTab.Visible = false
            end
            TabPage.Visible = true
            currentActiveTab = TabPage
            
            -- Simple click animation
            local tween = TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
            tween:Play()
            task.wait(0.2)
            TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
        end)
        
        -- If it's the first tab, make it visible by default
        if currentActiveTab == nil then
            TabPage.Visible = true
            currentActiveTab = TabPage
        end

        -- --- ADD TOGGLE ---
        function Tab:CreateToggle(toggleText, defaultState, callback)
            local state = defaultState
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, -10, 0, 35)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            ToggleFrame.Parent = TabPage
            
            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 6)
            ToggleCorner.Parent = ToggleFrame
            
            local Label = Instance.new("TextLabel")
            Label.Text = "  " .. toggleText
            Label.Size = UDim2.new(1, -50, 1, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleFrame
            
            local Checkmark = Instance.new("TextButton")
            Checkmark.Size = UDim2.new(0, 25, 0, 25)
            Checkmark.Position = UDim2.new(1, -30, 0.5, -12.5)
            Checkmark.BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 45)
            Checkmark.Text = ""
            Checkmark.Parent = ToggleFrame
            
            local CheckCorner = Instance.new("UICorner")
            CheckCorner.CornerRadius = UDim.new(0, 4)
            CheckCorner.Parent = Checkmark
            
            Checkmark.MouseButton1Click:Connect(function()
                state = not state
                local targetColor = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 45)
                TweenService:Create(Checkmark, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
                if callback then callback(state) end
            end)
        end

        -- --- ADD SLIDER ---
        function Tab:CreateSlider(sliderText, min, max, default, callback)
            local currentValue = default
            
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, -10, 0, 50)
            SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            SliderFrame.Parent = TabPage
            
            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 6)
            SliderCorner.Parent = SliderFrame
            
            local Label = Instance.new("TextLabel")
            Label.Text = "  " .. sliderText .. " : " .. tostring(currentValue)
            Label.Size = UDim2.new(1, 0, 0.5, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame
            
            local SliderBarBase = Instance.new("Frame")
            SliderBarBase.Size = UDim2.new(1, -20, 0, 10)
            SliderBarBase.Position = UDim2.new(0, 10, 0.65, 0)
            SliderBarBase.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            SliderBarBase.Parent = SliderFrame
            
            local BaseCorner = Instance.new("UICorner")
            BaseCorner.CornerRadius = UDim.new(1, 0)
            BaseCorner.Parent = SliderBarBase
            
            local SliderFill = Instance.new("Frame")
            local fillPercentage = (default - min) / (max - min)
            SliderFill.Size = UDim2.new(fillPercentage, 0, 1, 0)
            SliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            SliderFill.Parent = SliderBarBase
            
            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = SliderFill
            
            local DragButton = Instance.new("TextButton")
            DragButton.Size = UDim2.new(1, 0, 1, 0)
            DragButton.BackgroundTransparency = 1
            DragButton.Text = ""
            DragButton.Parent = SliderBarBase
            
            -- Slider Math & Logic
            local draggingSlider = false
            DragButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = true end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mouseX = UserInputService:GetMouseLocation().X
                    local relativeX = mouseX - SliderBarBase.AbsolutePosition.X
                    local percentage = math.clamp(relativeX / SliderBarBase.AbsoluteSize.X, 0, 1)
                    
                    currentValue = math.floor(min + ((max - min) * percentage))
                    Label.Text = "  " .. sliderText .. " : " .. tostring(currentValue)
                    
                    TweenService:Create(SliderFill, TweenInfo.new(0.05), {Size = UDim2.new(percentage, 0, 1, 0)}):Play()
                    
                    if callback then callback(currentValue) end
                end
            end)
        end

        return Tab
    end
    
    return Window
end

-- --- EXAMPLE USAGE (HOW TO USE IT IN YOUR SCRIPT) ---
-- local Window = Library:CreateWindow("Kral Premium UI")
-- local CombatTab = Window:CreateTab("Combat")
-- 
-- CombatTab:CreateToggle("Enable Aimbot", false, function(state)
--     print("Aimbot state: " .. tostring(state))
-- end)
-- 
-- CombatTab:CreateSlider("Aimbot Smoothness", 1, 10, 5, function(value)
--     print("Smoothness set to: " .. tostring(value))
-- end)
-- 
-- local VisualsTab = Window:CreateTab("Visuals")
-- VisualsTab:CreateToggle("Enable ESP", true, function(state)
--     print("ESP state: " .. tostring(state))
-- end)

return Library

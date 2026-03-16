local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local UILibrary = {}

local function GetSafeParent()
    local success, parent = pcall(function() return CoreGui end)
    if not success or not parent then
        return Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    return parent
end

function UILibrary:CreateWindow(windowTitle)
    local WindowInterface = {}
    
    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "SecureUI"
    MainGui.ResetOnSpawn = false
    
    local safeParent = GetSafeParent()
    MainGui.Parent = safeParent
    
    if syn and syn.protect_gui then
        pcall(function() syn.protect_gui(MainGui) end)
    end
    
    local BaseFrame = Instance.new("Frame")
    BaseFrame.Name = "BaseFrame"
    BaseFrame.Size = UDim2.new(0, 500, 0, 350)
    BaseFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    BaseFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    BaseFrame.BorderSizePixel = 0
    BaseFrame.Parent = MainGui
    
    local BaseCorner = Instance.new("UICorner")
    BaseCorner.CornerRadius = UDim.new(0, 8)
    BaseCorner.Parent = BaseFrame
    
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Header.Parent = BaseFrame
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 8)
    HeaderCorner.Parent = Header
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = "  " .. windowTitle
    TitleLabel.Size = UDim2.new(1, 0, 1, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Header

    local isDragging = false
    local dragInputObj
    local dragStartPos
    local startFramePos

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStartPos = input.Position
            startFramePos = BaseFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                end
            end)
        end
    end)

    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInputObj = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInputObj and isDragging then
            local delta = input.Position - dragStartPos
            BaseFrame.Position = UDim2.new(startFramePos.X.Scale, startFramePos.X.Offset + delta.X, startFramePos.Y.Scale, startFramePos.Y.Offset + delta.Y)
        end
    end)
    
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, 120, 1, -35)
    Sidebar.Position = UDim2.new(0, 0, 0, 35)
    Sidebar.BackgroundTransparency = 1
    Sidebar.ScrollBarThickness = 0
    Sidebar.Parent = BaseFrame
    
    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Padding = UDim.new(0, 5)
    SidebarLayout.Parent = Sidebar
    
    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -130, 1, -45)
    ContentArea.Position = UDim2.new(0, 125, 0, 40)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = BaseFrame

    local activeTabFrame = nil

    function WindowInterface:CreateTab(tabTitle)
        local TabInterface = {}
        
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, -10, 0, 30)
        TabBtn.Position = UDim2.new(0, 5, 0, 0)
        TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabBtn.Font = Enum.Font.GothamSemibold
        TabBtn.TextSize = 13
        TabBtn.Text = tabTitle
        TabBtn.Parent = Sidebar
        
        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 6)
        TabBtnCorner.Parent = TabBtn
        
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.ScrollBarThickness = 4
        TabContent.Visible = false
        TabContent.Parent = ContentArea
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Padding = UDim.new(0, 8)
        ContentLayout.Parent = TabContent
        
        TabBtn.MouseButton1Click:Connect(function()
            if activeTabFrame then
                activeTabFrame.Visible = false
            end
            TabContent.Visible = true
            activeTabFrame = TabContent
            
            local clickAnim = TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
            clickAnim:Play()
            task.wait(0.2)
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
        end)
        
        if activeTabFrame == nil then
            TabContent.Visible = true
            activeTabFrame = TabContent
        end

        function TabInterface:CreateToggle(toggleLabel, defaultVal, callbackFunc)
            local currentState = defaultVal
            
            local ToggleContainer = Instance.new("Frame")
            ToggleContainer.Size = UDim2.new(1, -10, 0, 35)
            ToggleContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            ToggleContainer.Parent = TabContent
            
            local ContainerCorner = Instance.new("UICorner")
            ContainerCorner.CornerRadius = UDim.new(0, 6)
            ContainerCorner.Parent = ToggleContainer
            
            local LabelText = Instance.new("TextLabel")
            LabelText.Text = "  " .. toggleLabel
            LabelText.Size = UDim2.new(1, -50, 1, 0)
            LabelText.BackgroundTransparency = 1
            LabelText.TextColor3 = Color3.fromRGB(255, 255, 255)
            LabelText.Font = Enum.Font.Gotham
            LabelText.TextSize = 13
            LabelText.TextXAlignment = Enum.TextXAlignment.Left
            LabelText.Parent = ToggleContainer
            
            local StatusIndicator = Instance.new("TextButton")
            StatusIndicator.Size = UDim2.new(0, 25, 0, 25)
            StatusIndicator.Position = UDim2.new(1, -30, 0.5, -12.5)
            StatusIndicator.BackgroundColor3 = currentState and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 45)
            StatusIndicator.Text = ""
            StatusIndicator.Parent = ToggleContainer
            
            local IndicatorCorner = Instance.new("UICorner")
            IndicatorCorner.CornerRadius = UDim.new(0, 4)
            IndicatorCorner.Parent = StatusIndicator
            
            StatusIndicator.MouseButton1Click:Connect(function()
                currentState = not currentState
                local targetBg = currentState and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(45, 45, 45)
                TweenService:Create(StatusIndicator, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
                if callbackFunc then callbackFunc(currentState) end
            end)
        end

        function TabInterface:CreateSlider(sliderLabel, minVal, maxVal, defaultVal, callbackFunc)
            local currentSliderVal = defaultVal
            
            local SliderContainer = Instance.new("Frame")
            SliderContainer.Size = UDim2.new(1, -10, 0, 50)
            SliderContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            SliderContainer.Parent = TabContent
            
            local ContainerCorner = Instance.new("UICorner")
            ContainerCorner.CornerRadius = UDim.new(0, 6)
            ContainerCorner.Parent = SliderContainer
            
            local LabelText = Instance.new("TextLabel")
            LabelText.Text = "  " .. sliderLabel .. " : " .. tostring(currentSliderVal)
            LabelText.Size = UDim2.new(1, 0, 0.5, 0)
            LabelText.BackgroundTransparency = 1
            LabelText.TextColor3 = Color3.fromRGB(255, 255, 255)
            LabelText.Font = Enum.Font.Gotham
            LabelText.TextSize = 13
            LabelText.TextXAlignment = Enum.TextXAlignment.Left
            LabelText.Parent = SliderContainer
            
            local TrackBg = Instance.new("Frame")
            TrackBg.Size = UDim2.new(1, -20, 0, 10)
            TrackBg.Position = UDim2.new(0, 10, 0.65, 0)
            TrackBg.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            TrackBg.Parent = SliderContainer
            
            local TrackBgCorner = Instance.new("UICorner")
            TrackBgCorner.CornerRadius = UDim.new(1, 0)
            TrackBgCorner.Parent = TrackBg
            
            local TrackFill = Instance.new("Frame")
            local initialFill = (defaultVal - minVal) / (maxVal - minVal)
            TrackFill.Size = UDim2.new(initialFill, 0, 1, 0)
            TrackFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            TrackFill.Parent = TrackBg
            
            local TrackFillCorner = Instance.new("UICorner")
            TrackFillCorner.CornerRadius = UDim.new(1, 0)
            TrackFillCorner.Parent = TrackFill
            
            local InteractBtn = Instance.new("TextButton")
            InteractBtn.Size = UDim2.new(1, 0, 1, 0)
            InteractBtn.BackgroundTransparency = 1
            InteractBtn.Text = ""
            InteractBtn.Parent = TrackBg
            
            local isInteracting = false
            InteractBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then isInteracting = true end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then isInteracting = false end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if isInteracting and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mousePosX = UserInputService:GetMouseLocation().X
                    local relativePosX = mousePosX - TrackBg.AbsolutePosition.X
                    local fillPercent = math.clamp(relativePosX / TrackBg.AbsoluteSize.X, 0, 1)
                    
                    currentSliderVal = math.floor(minVal + ((maxVal - minVal) * fillPercent))
                    LabelText.Text = "  " .. sliderLabel .. " : " .. tostring(currentSliderVal)
                    
                    TweenService:Create(TrackFill, TweenInfo.new(0.05), {Size = UDim2.new(fillPercent, 0, 1, 0)}):Play()
                    
                    if callbackFunc then callbackFunc(currentSliderVal) end
                end
            end)
        end

        return TabInterface
    end
    
    return WindowInterface
end

return UILibrary

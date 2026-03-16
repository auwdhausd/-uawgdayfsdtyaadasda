-- --- BASE UI LIBRARY ---
local UILibrary = {}
UILibrary.__index = UILibrary

-- --- SERVICES ---
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- --- CREATE MAIN WINDOW ---
function UILibrary.new(libraryName)
    local self = setmetatable({}, UILibrary)
    self.name = libraryName
    
    -- Create ScreenGui
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = libraryName
    self.screenGui.ResetOnSpawn = false
    -- NOTE: If using an executor, you might parent this to game:GetService("CoreGui")
    self.screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create Main Frame
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Name = "MainFrame"
    self.mainFrame.Size = UDim2.new(0, 450, 0, 350)
    self.mainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
    self.mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.Active = true
    self.mainFrame.Draggable = true -- Allows the user to drag the window
    self.mainFrame.Parent = self.screenGui
    
    -- UIListLayout for automatic vertical alignment of elements
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.Parent = self.mainFrame
    
    return self
end

-- --- WATERMARK ---
function UILibrary:CreateWatermark(watermarkText)
    local watermarkLabel = Instance.new("TextLabel")
    watermarkLabel.Name = "Watermark"
    watermarkLabel.Text = watermarkText .. " | FPS: 60"
    watermarkLabel.Size = UDim2.new(0, 200, 0, 25)
    watermarkLabel.Position = UDim2.new(0, 10, 0, 10)
    watermarkLabel.BackgroundTransparency = 1
    watermarkLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    watermarkLabel.TextXAlignment = Enum.TextXAlignment.Left
    watermarkLabel.Parent = self.screenGui
end

-- --- TOGGLE ---
function UILibrary:CreateToggle(toggleName, defaultState, callback)
    local toggleState = defaultState or false
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = toggleName
    toggleButton.Text = toggleName .. " : " .. tostring(toggleState)
    toggleButton.Size = UDim2.new(0.9, 0, 0, 35)
    toggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Parent = self.mainFrame
    
    toggleButton.MouseButton1Click:Connect(function()
        toggleState = not toggleState
        toggleButton.Text = toggleName .. " : " .. tostring(toggleState)
        
        -- Change color based on state
        if toggleState then
            toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        else
            toggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        end
        
        if callback then
            callback(toggleState)
        end
    end)
end

-- --- SLIDER ---
function UILibrary:CreateSlider(sliderName, minValue, maxValue, callback)
    local currentValue = minValue
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = sliderName
    sliderFrame.Size = UDim2.new(0.9, 0, 0, 45)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    sliderFrame.Parent = self.mainFrame
    
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Text = sliderName .. " : " .. tostring(currentValue)
    sliderLabel.Size = UDim2.new(1, 0, 0.5, 0)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sliderLabel.Parent = sliderFrame
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Text = ""
    sliderButton.Size = UDim2.new(1, 0, 0.5, 0)
    sliderButton.Position = UDim2.new(0, 0, 0.5, 0)
    sliderButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    sliderButton.Parent = sliderFrame
    
    sliderButton.MouseButton1Down:Connect(function()
        -- Math logic for slider dragging goes here using UserInputService
        print("[UI] Dragging Slider: " .. sliderName)
    end)
end

-- --- DROPDOWN ---
function UILibrary:CreateDropdown(dropdownName, optionsList, callback)
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Name = dropdownName
    dropdownButton.Text = dropdownName .. " (+)"
    dropdownButton.Size = UDim2.new(0.9, 0, 0, 35)
    dropdownButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    dropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdownButton.Parent = self.mainFrame
    
    dropdownButton.MouseButton1Click:Connect(function()
        -- Logic to expand frame and show options goes here
        print("[UI] Dropdown Opened: " .. dropdownName)
    end)
end

-- --- KEYBIND ---
function UILibrary:CreateKeybind(keybindName, defaultKey, callback)
    local currentKey = defaultKey
    local isListening = false
    
    local keybindButton = Instance.new("TextButton")
    keybindButton.Name = keybindName
    keybindButton.Text = keybindName .. " : " .. currentKey.Name
    keybindButton.Size = UDim2.new(0.9, 0, 0, 35)
    keybindButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    keybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    keybindButton.Parent = self.mainFrame
    
    keybindButton.MouseButton1Click:Connect(function()
        isListening = true
        keybindButton.Text = keybindName .. " : [Press Any Key]"
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if isListening and input.UserInputType == Enum.UserInputType.Keyboard then
            currentKey = input.KeyCode
            keybindButton.Text = keybindName .. " : " .. currentKey.Name
            isListening = false
            
            if callback then
                callback(currentKey)
            end
        end
    end)
end

return UILibrary

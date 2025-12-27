--[[
    O-X Panel - A draggable, responsive Roblox GUI for third-party software
    
    Features:
    - Red and Black color scheme
    - Fully draggable on PC and Mobile
    - Touch and Mouse input support
    - Responsive design for any screen size
    - Easy to customize and integrate
    
    Usage:
    local OXPanel = require(script:FindFirstChild("OXPanel"))
    local panel = OXPanel.new("MyPanel", {width = 300, height = 400})
]]

local OXPanel = {}
OXPanel.__index = OXPanel

-- Color Constants
local COLORS = {
    PRIMARY_RED = Color3.fromRGB(255, 0, 0),
    DARK_BLACK = Color3.fromRGB(20, 20, 20),
    LIGHT_BLACK = Color3.fromRGB(40, 40, 40),
    TEXT_WHITE = Color3.fromRGB(255, 255, 255),
    ACCENT_DARK_RED = Color3.fromRGB(200, 0, 0),
}

-- Default Configuration
local DEFAULT_CONFIG = {
    width = 350,
    height = 450,
    position = UDim2.new(0.5, -175, 0.5, -225),
    draggable = true,
    showCloseButton = true,
    showMinimizeButton = true,
    title = "O-X Panel",
}

--[[
    Creates a new O-X Panel instance
    @param title (string) - Panel title
    @param config (table) - Configuration options
    @return panel instance
]]
function OXPanel.new(title, config)
    local self = setmetatable({}, OXPanel)
    
    -- Merge config with defaults
    self.config = {}
    for key, value in pairs(DEFAULT_CONFIG) do
        self.config[key] = config and config[key] or value
    end
    
    self.config.title = title or self.config.title
    
    -- Initialize state
    self.isDragging = false
    self.dragStart = nil
    self.dragOffset = nil
    self.isMinimized = false
    self.buttons = {}
    self.tabs = {}
    
    -- Create GUI
    self:_createMainFrame()
    self:_createHeader()
    self:_createContent()
    self:_setupDragFunctionality()
    
    return self
end

--[[
    Creates the main frame (background)
]]
function OXPanel:_createMainFrame()
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Name = "OXPanel_Main"
    self.mainFrame.Size = UDim2.new(0, self.config.width, 0, self.config.height)
    self.mainFrame.Position = self.config.position
    self.mainFrame.BackgroundColor3 = COLORS.DARK_BLACK
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.ZIndex = 100
    
    -- Add border effect with a stroke
    local border = Instance.new("UIStroke")
    border.Color = COLORS.PRIMARY_RED
    border.Thickness = 2
    border.Parent = self.mainFrame
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self.mainFrame
    
    -- Add padding
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = self.mainFrame
end

--[[
    Creates the header section with title and buttons
]]
function OXPanel:_createHeader()
    self.header = Instance.new("Frame")
    self.header.Name = "Header"
    self.header.Size = UDim2.new(1, 0, 0, 50)
    self.header.BackgroundColor3 = COLORS.LIGHT_BLACK
    self.header.BorderSizePixel = 0
    self.header.Parent = self.mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 6)
    headerCorner.Parent = self.header
    
    -- Title Label
    self.titleLabel = Instance.new("TextLabel")
    self.titleLabel.Name = "Title"
    self.titleLabel.Size = UDim2.new(1, -100, 1, 0)
    self.titleLabel.Position = UDim2.new(0, 10, 0, 0)
    self.titleLabel.BackgroundTransparency = 1
    self.titleLabel.TextColor3 = COLORS.TEXT_WHITE
    self.titleLabel.TextSize = 18
    self.titleLabel.Font = Enum.Font.GothamBold
    self.titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.titleLabel.Text = self.config.title
    self.titleLabel.Parent = self.header
    
    -- Minimize Button
    if self.config.showMinimizeButton then
        self:_createHeaderButton("Minimize", 60, function()
            self:toggleMinimize()
        end)
    end
    
    -- Close Button
    if self.config.showCloseButton then
        self:_createHeaderButton("X", 30, function()
            self:destroy()
        end)
    end
end

--[[
    Helper function to create header buttons
]]
function OXPanel:_createHeaderButton(text, width, callback)
    local button = Instance.new("TextButton")
    button.Name = text .. "Button"
    button.Size = UDim2.new(0, width, 1, 0)
    button.Position = UDim2.new(1, -width, 0, 0)
    button.BackgroundColor3 = COLORS.PRIMARY_RED
    button.TextColor3 = COLORS.TEXT_WHITE
    button.TextSize = 16
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.BorderSizePixel = 0
    button.Parent = self.header
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    -- Button hover effect
    local UserInputService = game:GetService("UserInputService")
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = COLORS.ACCENT_DARK_RED
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = COLORS.PRIMARY_RED
    end)
    
    -- Button click
    button.MouseButton1Click:Connect(callback)
    
    -- Mobile touch support
    button.TouchTap:Connect(callback)
    
    table.insert(self.buttons, button)
end

--[[
    Creates the main content area
]]
function OXPanel:_createContent()
    self.contentFrame = Instance.new("Frame")
    self.contentFrame.Name = "Content"
    self.contentFrame.Size = UDim2.new(1, 0, 1, -60)
    self.contentFrame.Position = UDim2.new(0, 0, 0, 60)
    self.contentFrame.BackgroundColor3 = COLORS.DARK_BLACK
    self.contentFrame.BorderSizePixel = 0
    self.contentFrame.Parent = self.mainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = self.contentFrame
    
    -- Add scroll support
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = self.contentFrame
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.Parent = self.contentFrame
end

--[[
    Sets up drag functionality for both mouse and touch
]]
function OXPanel:_setupDragFunctionality()
    if not self.config.draggable then return end
    
    local UserInputService = game:GetService("UserInputService")
    local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
    
    -- Mouse drag support
    self.header.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.isDragging = true
            self.dragStart = input.Position
            self.dragOffset = self.mainFrame.AbsolutePosition - input.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input, gameProcessed)
        if not self.isDragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then
            return
        end
        
        local delta = input.Position - self.dragStart
        local newPos = self.mainFrame.AbsolutePosition + delta
        
        self.mainFrame.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
        self.dragStart = input.Position
    end)
    
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.isDragging = false
        end
    end)
    
    -- Touch drag support for mobile
    local touchInput = nil
    self.header.TouchBegan:Connect(function(touch, gameProcessed)
        if gameProcessed then return end
        
        self.isDragging = true
        touchInput = touch
        self.dragStart = touch.Position
    end)
    
    self.header.TouchMoved:Connect(function(touch, gameProcessed)
        if not self.isDragging or touchInput.UserInputType ~= touch.UserInputType then return end
        
        local delta = touch.Position - self.dragStart
        local newPos = self.mainFrame.AbsolutePosition + delta
        
        self.mainFrame.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
        self.dragStart = touch.Position
    end)
    
    self.header.TouchEnded:Connect(function(touch, gameProcessed)
        self.isDragging = false
        touchInput = nil
    end)
end

--[[
    Toggles minimize state
]]
function OXPanel:toggleMinimize()
    self.isMinimized = not self.isMinimized
    
    if self.isMinimized then
        self.contentFrame.Visible = false
        self.mainFrame.Size = UDim2.new(0, self.config.width, 0, 50)
    else
        self.contentFrame.Visible = true
        self.mainFrame.Size = UDim2.new(0, self.config.width, 0, self.config.height)
    end
end

--[[
    Adds a button to the content area
    @param text (string) - Button text
    @param callback (function) - Click callback
]]
function OXPanel:addButton(text, callback)
    local button = Instance.new("TextButton")
    button.Name = text .. "Btn"
    button.Size = UDim2.new(1, 0, 0, 40)
    button.BackgroundColor3 = COLORS.PRIMARY_RED
    button.TextColor3 = COLORS.TEXT_WHITE
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.Text = text
    button.BorderSizePixel = 0
    button.Parent = self.contentFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = COLORS.ACCENT_DARK_RED
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = COLORS.PRIMARY_RED
    end)
    
    -- Click handler
    button.MouseButton1Click:Connect(callback)
    button.TouchTap:Connect(callback)
    
    return button
end

--[[
    Adds a label to the content area
    @param text (string) - Label text
]]
function OXPanel:addLabel(text)
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 30)
    label.BackgroundColor3 = COLORS.LIGHT_BLACK
    label.TextColor3 = COLORS.TEXT_WHITE
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.BorderSizePixel = 0
    label.Parent = self.contentFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = label
    
    return label
end

--[[
    Sets the parent for the main frame (where it renders)
    @param parent (Instance) - Parent GUI object
]]
function OXPanel:setParent(parent)
    self.mainFrame.Parent = parent
end

--[[
    Destroys the panel and all its components
]]
function OXPanel:destroy()
    if self.mainFrame then
        self.mainFrame:Destroy()
    end
end

--[[
    Adds a text input box to the content area
    @param placeholder (string) - Placeholder text
    @param callback (function) - Text change callback
]]
function OXPanel:addTextBox(placeholder, callback)
    local inputBox = Instance.new("TextBox")
    inputBox.Name = "TextInput"
    inputBox.Size = UDim2.new(1, 0, 0, 35)
    inputBox.BackgroundColor3 = COLORS.LIGHT_BLACK
    inputBox.TextColor3 = COLORS.TEXT_WHITE
    inputBox.PlaceholderText = placeholder or "Enter text..."
    inputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    inputBox.TextSize = 12
    inputBox.Font = Enum.Font.Gotham
    inputBox.BorderSizePixel = 0
    inputBox.Parent = self.contentFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = inputBox
    
    if callback then
        inputBox.FocusLost:Connect(function(enterPressed)
            callback(inputBox.Text, enterPressed)
        end)
    end
    
    return inputBox
end

--[[
    Changes the panel title
    @param newTitle (string) - New title text
]]
function OXPanel:setTitle(newTitle)
    if self.titleLabel then
        self.titleLabel.Text = newTitle
        self.config.title = newTitle
    end
end

--[[
    Changes the panel size
    @param width (number) - New width
    @param height (number) - New height
]]
function OXPanel:setSize(width, height)
    self.config.width = width
    self.config.height = height
    
    if not self.isMinimized then
        self.mainFrame.Size = UDim2.new(0, width, 0, height)
    end
end

--[[
    Changes the panel position
    @param x (number) - X position
    @param y (number) - Y position
]]
function OXPanel:setPosition(x, y)
    self.mainFrame.Position = UDim2.new(0, x, 0, y)
end

--[[
    Toggles panel visibility
]]
function OXPanel:toggleVisibility()
    self.mainFrame.Visible = not self.mainFrame.Visible
    return self.mainFrame.Visible
end

--[[
    Sets panel visibility
    @param visible (boolean) - Visibility state
]]
function OXPanel:setVisible(visible)
    self.mainFrame.Visible = visible
end

--[[
    Gets current panel visibility
]]
function OXPanel:isVisible()
    return self.mainFrame.Visible
end

return OXPanel

local RunService = game:GetService("RunService")
 
local ESP = {}
 
ESP.ActiveObjects = {}
ESP.Connections = {}

function ESP:CheckObject(Object)
    if not ESP.ActiveObjects[Object] then
        ESP.ActiveObjects[Object] = {}
    end
end

function ESP:Box(Object, Settings)
    Settings = Settings or {}

    Settings.Color = Settings.Color or Color3.fromRGB(255, 255, 255)
    Settings.Thickness = Settings.Thickness or 2
    Settings.Filled = Settings.Filled or false

    if Object and not Object.PrimaryPart then
        return nil
    end
    ESP:CheckObject(Object)
 
    local BoxESP = {}
 
    BoxESP.DrawingObject = Drawing.new("Quad")
    BoxESP.DrawingObject.Color = Settings.Color or Color3.fromRGB(255, 255, 255)
    BoxESP.DrawingObject.Thickness = Settings.Thickness or 2
    BoxESP.DrawingObject.Filled = Settings.Filled or false
    BoxESP.Part = Settings.Part or Object.PrimaryPart
    BoxESP.Removed = false
 
    function BoxESP:Update()
        local BoundingCFrame, BoundingSize = Object:GetBoundingBox()
        BoundingSize /= 2
        
        Settings.FaceCamera = true
        if Settings.FaceCamera then
            BoundingCFrame = CFrame.new(BoundingCFrame.Position, workspace.Camera.CFrame.Position)
        end

        local PointAVector, PointAVisible = workspace.CurrentCamera:WorldToViewportPoint((BoundingCFrame * CFrame.new(BoundingSize.X, -BoundingSize.Y, 0)).Position) -- Top right
        local PointBVector, PointBVisible = workspace.CurrentCamera:WorldToViewportPoint((BoundingCFrame * CFrame.new(-BoundingSize.X, -BoundingSize.Y, 0)).Position) -- Top left
        local PointCVector, PointCVisible = workspace.CurrentCamera:WorldToViewportPoint((BoundingCFrame * CFrame.new(-BoundingSize.X, BoundingSize.Y, 0)).Position) -- Bottom left
        local PointDVector, PointDVisible = workspace.CurrentCamera:WorldToViewportPoint((BoundingCFrame * CFrame.new(BoundingSize.X, BoundingSize.Y, 0)).Position) -- Bottom right
        
        if PointAVisible or PointBVisible or PointCVisible or PointDVisible then
            BoxESP.DrawingObject.Visible = true

            BoxESP.DrawingObject.PointA = Vector2.new(PointAVector.X, PointAVector.Y, 0)
            BoxESP.DrawingObject.PointB = Vector2.new(PointBVector.X, PointBVector.Y, 0)
            BoxESP.DrawingObject.PointC = Vector2.new(PointCVector.X, PointCVector.Y, 0)
            BoxESP.DrawingObject.PointD = Vector2.new(PointDVector.X, PointDVector.Y, 0)
        else
            BoxESP.DrawingObject.Visible = false
        end
    end

    function BoxESP:ChangeSetting(Setting, Value)
        Settings[Setting] = Value
    end

    function BoxESP:Hide()
        BoxESP.DrawingObject.Visible = false
    end

    function BoxESP:Remove()
        BoxESP.DrawingObject:Remove()

        BoxESP.Removed = true
    end
 
    table.insert(ESP.ActiveObjects[Object], BoxESP)

    return BoxESP
end
 
function ESP:Name(Object, Text, Settings)
    Settings = Settings or {}

    Settings.Location = Settings.Location or "Top"

    if Object and not Object.PrimaryPart then
        return nil
    end
    ESP:CheckObject(Object)
 
    local NameESP = {}
 
    NameESP.DrawingObject = Drawing.new("Text")
    NameESP.DrawingObject.Font = 3
    NameESP.DrawingObject.Size = Settings.Size or 12
    NameESP.DrawingObject.Color = Settings.Color or Color3.fromRGB(255, 255, 255)
    NameESP.DrawingObject.Text = Text
    NameESP.DrawingObject.Center = true
    NameESP.DrawingObject.Outline = Settings.Outline or false
    NameESP.Part = Settings.Part or Object.PrimaryPart
    NameESP.Offset = Vector3.new(0, NameESP.Part.Size.Y, 0)
    NameESP.Removed = false
 
    function NameESP:UpdateText(NewText)
        NameESP.Text = NewText
    end
 
    function NameESP:Update()
        local BoundingCFrame, BoundingSize = Object:GetBoundingBox()
        local NewCFrame = CFrame.new(BoundingCFrame.Position, workspace.Camera.CFrame.Position)
        local Offset

        if Settings.Location == "Left" then
            NewCFrame += Vector3.new(-BoundingSize.X/2, -BoundingSize.Y, 0)
            Offset = Vector2.new()
        elseif Settings.Location == "Right" then
            NewCFrame += Vector3.new(BoundingSize.X/2, -BoundingSize.Y, 0)
            Offset = Vector2.new()
        elseif Settings.Location == "Bottom" then
            NewCFrame += Vector3.new(0, -BoundingSize.Y/2, 0)
            Offset = Vector2.new(0, NameESP.DrawingObject.TextBounds.Y/2)
        elseif Settings.Location == "Top" then
            NewCFrame += Vector3.new(0, BoundingSize.Y/2 + 0.5, 0)
            Offset = Vector2.new(0, -NameESP.DrawingObject.TextBounds.Y)
        end

        local Vector, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(NewCFrame.Position)

        NameESP.DrawingObject.Visible = OnScreen

        if OnScreen then
            local NewObjectPosition = Vector2.new(Vector.X, Vector.Y) + Offset
            NameESP.DrawingObject.Position = NewObjectPosition
        end
    end

    function NameESP:ChangeSetting(Setting, Value)
        Settings[Setting] = Value
    end

    function NameESP:Hide()
        NameESP.DrawingObject.Visible = false
    end

    function NameESP:Remove()
        NameESP.DrawingObject:Remove()

        NameESP.Removed = true
    end
 
    table.insert(ESP.ActiveObjects[Object], NameESP)
 
    return NameESP
end

function ESP:HealthBar(Object, Settings)
    Settings = Settings or {}

    Settings.Thickness = Settings.Thickness or 4
    Settings.Color = Settings.Color or Color3.fromRGB(0, 170, 0)
    Settings.Location = Settings.Location or "Left"

    if Object and not Object.PrimaryPart then
        return nil
    end
    ESP:CheckObject(Object)
 
    local HealthBarESP = {}

    HealthBarESP.DrawingObjectBackground = Drawing.new("Line")
    HealthBarESP.DrawingObject = Drawing.new("Line")
    HealthBarESP.DrawingObject.Thickness = Settings.Thickness or 4
    HealthBarESP.DrawingObject.Color = Settings.Color or Color3.fromRGB(170, 0, 0)
    HealthBarESP.DrawingObject.ZIndex = 2
    HealthBarESP.DrawingObjectBackground.Color = Color3.fromRGB(34, 34, 34)
    HealthBarESP.DrawingObjectBackground.Thickness = Settings.Thickness + 2 -- + 1 or 5
    HealthBarESP.DrawingObjectBackground.ZIndex = 1
    HealthBarESP.Part = Object.PrimaryPart
    HealthBarESP.Removed = false

    function HealthBarESP:Update()
        local BoundingCFrame, BoundingSize = Object:GetBoundingBox()
        BoundingSize /= 2
        BoundingCFrame = CFrame.new(BoundingCFrame.Position, workspace.Camera.CFrame.Position)
        local HealthCFrame = BoundingCFrame
        local HealthSize = BoundingSize

        local MaxSizeY
        local Health

        if Settings.KeepMiddle then
            if Settings.Location == "Left" or Settings.Location == "Right" then
                MaxSizeY = HealthSize.Y
                Health = (Object.Humanoid.Health / Object.Humanoid.MaxHealth) * MaxSizeY
                HealthSize -= Vector3.new(0, MaxSizeY + Health, 0)
            else
                MaxSizeY = HealthSize.X
                Health = (Object.Humanoid.Health / Object.Humanoid.MaxHealth) * MaxSizeY
                HealthSize -= Vector3.new(MaxSizeY + Health, 0, 0)
            end
        end

        local FinalBoundingPosition = {}
        local FinalHealthPosition = {}

        local Offset

        if Settings.Location == "Left" then
            Offset = Vector2.new(-5, 0)
            FinalBoundingPosition[1] = (BoundingCFrame * CFrame.new(BoundingSize.X, BoundingSize.Y, 0)).Position
            FinalBoundingPosition[2] = (BoundingCFrame * CFrame.new(BoundingSize.X, -BoundingSize.Y, 0)).Position

            FinalHealthPosition[1] = (BoundingCFrame * CFrame.new(HealthSize.X, -HealthSize.Y, 0)).Position
            FinalHealthPosition[2] = (BoundingCFrame * CFrame.new(HealthSize.X, HealthSize.Y, 0)).Position
        elseif Settings.Location == "Right" then
            Offset = Vector2.new(5, 0)
            FinalBoundingPosition[1] = (BoundingCFrame * CFrame.new(-BoundingSize.X, BoundingSize.Y, 0)).Position
            FinalBoundingPosition[2] = (BoundingCFrame * CFrame.new(-BoundingSize.X, -BoundingSize.Y, 0)).Position

            FinalHealthPosition[1] = (BoundingCFrame * CFrame.new(-HealthSize.X, -HealthSize.Y, 0)).Position
            FinalHealthPosition[2] = (BoundingCFrame * CFrame.new(-HealthSize.X, HealthSize.Y, 0)).Position
        elseif Settings.Location == "Bottom" then
            Offset = Vector2.new(0, 5)
            FinalBoundingPosition[1] = (BoundingCFrame * CFrame.new(BoundingSize.X, -BoundingSize.Y, 0)).Position
            FinalBoundingPosition[2] = (BoundingCFrame * CFrame.new(-BoundingSize.X, -BoundingSize.Y, 0)).Position
            
            FinalHealthPosition[1] = (BoundingCFrame * CFrame.new(HealthSize.X, -HealthSize.Y, 0)).Position
            FinalHealthPosition[2] = (BoundingCFrame * CFrame.new(-HealthSize.X, -HealthSize.Y, 0)).Position
        end

        local BottomVector, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(FinalBoundingPosition[1])
        local TopVector, OnScreen2 = workspace.CurrentCamera:WorldToViewportPoint(FinalBoundingPosition[2])

        local BottomVectorHealth, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(FinalHealthPosition[1])
        local TopVectorHealth, OnScreen2 = workspace.CurrentCamera:WorldToViewportPoint(FinalHealthPosition[2])

        HealthBarESP.DrawingObject.Visible = OnScreen
        HealthBarESP.DrawingObjectBackground.Visible = OnScreen
        if OnScreen or OnScreen2 then
            local DOBackgroundFrom = Vector2.new(BottomVector.X, BottomVector.Y) + Offset
            local DOBackgroundTo = Vector2.new(TopVector.X, TopVector.Y) + Offset
            local OBackgroundFrom = Vector2.new(BottomVectorHealth.X, BottomVectorHealth.Y) + Offset
            local OBackgroundTo = Vector2.new(TopVectorHealth.X, TopVectorHealth.Y) + Offset

            if not Settings.KeepMiddle then
                if Settings.Location == "Left" or Settings.Location == "Right" then
                    local Size = DOBackgroundFrom.Y - DOBackgroundTo.Y

                    local Health2 = (Object.Humanoid.Health / Object.Humanoid.MaxHealth) * Size
                    OBackgroundTo -= Vector2.new(0, Size - Health2)
                else
                    local Size = DOBackgroundFrom.X - DOBackgroundTo.X

                    local Health2 = (Object.Humanoid.Health / Object.Humanoid.MaxHealth) * Size
                    OBackgroundTo += Vector2.new(Size - Health2, 0)
                end
            end

            HealthBarESP.DrawingObjectBackground.From = DOBackgroundFrom
            HealthBarESP.DrawingObjectBackground.To = DOBackgroundTo

            HealthBarESP.DrawingObject.From = OBackgroundFrom
            HealthBarESP.DrawingObject.To = OBackgroundTo
        end
    end

    function HealthBarESP:ChangeSetting(Setting, Value)
        Settings[Setting] = Value
    end

    function HealthBarESP:Hide()
        HealthBarESP.DrawingObjectBackground.Visible = false
        HealthBarESP.DrawingObject.Visible = false
    end

    function HealthBarESP:Remove()
        HealthBarESP.DrawingObjectBackground:Remove()
        HealthBarESP.DrawingObject:Remove()

        HealthBarESP.Removed = true
    end

    table.insert(ESP.ActiveObjects[Object], HealthBarESP)

    return HealthBarESP
end

function ESP:Start()
    ESP.Connections.MainConnection = RunService.RenderStepped:Connect(function()
        for i,ObjectTable in pairs(ESP.ActiveObjects) do
            for i2,v in pairs(ObjectTable) do
                if i.Parent and i.PrimaryPart and v.Part and v.Removed == false then
                    v:Update()
                else
                    if v.Removed == false then
                        v:Remove()
                    end

                    ESP.ActiveObjects[i] = nil
                end
            end
        end
 
    end)
end
 
function ESP:Stop()
    ESP.Connections.MainConnection:Disconnect()

    for i,ObjectTable in pairs(ESP.ActiveObjects) do
        for i2,v in pairs(ObjectTable) do
            if v and v.Hide then
                v:Hide()
            end
        end
    end
end
 
return ESP

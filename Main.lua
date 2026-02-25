-- ========================================================================= --
-- [ CONFIGURAÇÃO DE IMAGENS (COLOQUE SEUS IDS AQUI) ]
-- ========================================================================= --
local IMAGES = {
	BotaoFlutuante = "rbxassetid://0", -- Ícone da engrenagem/logo flutuante
	FreeCam        = "rbxassetid://0", -- Ícone da Câmera
	Teleport       = "rbxassetid://0", -- Ícone do Pino de Localização
	Platform       = "rbxassetid://0", -- Ícone do Boneco Andando
	Noclip         = "rbxassetid://0", -- Ícone do Boneco com Setas (Noclip)
	Lighting       = "rbxassetid://0", -- Ícone do Sol (Brilho)
	Position       = "rbxassetid://0", -- Ícone do Mapa
	ResizeIcon     = "rbxassetid://7317540608" -- Ícone do triângulo padrão (pode manter)
}

-- [ CORES E TEMAS ]
local THEME = {
	BgColor = Color3.fromRGB(235, 235, 235),
	PanelBg = Color3.fromRGB(250, 250, 250),
	Purple  = Color3.fromRGB(111, 43, 226),
	Text    = Color3.fromRGB(80, 80, 80),
	Y = Color3.fromRGB(40, 200, 80),  -- Verde
	X = Color3.fromRGB(220, 50, 50),  -- Vermelho
	Z = Color3.fromRGB(50, 150, 255)  -- Azul
}

-- ========================================================================= --
-- [ SERVIÇOS E VARIÁVEIS INICIAIS ]
-- ========================================================================= --
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

local FILE_NAME = "StudioPro_v44.json"
local settings = { speed = 1.3, transparency = 0.0, inv = false, lightValue = 1 }

-- [ PERSISTÊNCIA ]
local function save() if writefile then pcall(function() writefile(FILE_NAME, HttpService:JSONEncode(settings)) end) end end
local function load() if isfile and isfile(FILE_NAME) then local s, data = pcall(function() return HttpService:JSONDecode(readfile(FILE_NAME)) end) if s then for k,v in pairs(data) do settings[k] = v end end end end
load()

-- Salva a iluminação original do jogo
local OriginalLighting = {
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	Brightness = Lighting.Brightness,
	GlobalShadows = Lighting.GlobalShadows,
	ExposureCompensation = Lighting.ExposureCompensation
}

-- ========================================================================= --
-- [ CRIAÇÃO DA UI AVANÇADA ]
-- ========================================================================= --
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StudioPro_v45"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local UI_ELEMENTS = {} -- Para controle de transparência (#ts)

local function applyCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = parent
	return corner
end

local function applyStroke(parent, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or THEME.Purple
	stroke.Thickness = thickness or 2
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

-- Botão Flutuante (Abre/Fecha)
local OpenBtn = Instance.new("ImageButton")
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0.5, -25, 0, 10)
OpenBtn.BackgroundColor3 = THEME.PanelBg
OpenBtn.Image = IMAGES.BotaoFlutuante
OpenBtn.Parent = screenGui
applyCorner(OpenBtn, 12)
applyStroke(OpenBtn, THEME.Purple, 2)
table.insert(UI_ELEMENTS, OpenBtn)

-- Frame Principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 260)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -130)
MainFrame.BackgroundColor3 = THEME.BgColor
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.Parent = screenGui
applyCorner(MainFrame, 16)
applyStroke(MainFrame, THEME.Purple, 3)
table.insert(UI_ELEMENTS, MainFrame)

-- Recipiente dos Botões do Topo
local TopButtonsFrame = Instance.new("Frame")
TopButtonsFrame.Size = UDim2.new(1, -20, 0, 50)
TopButtonsFrame.Position = UDim2.new(0, 10, 0, 10)
TopButtonsFrame.BackgroundTransparency = 1
TopButtonsFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = TopButtonsFrame

local buttons = {}
local function createTopButton(name, iconId)
	local btn = Instance.new("ImageButton")
	btn.Name = name
	btn.Size = UDim2.new(0, 50, 0, 50)
	btn.BackgroundColor3 = THEME.PanelBg
	btn.Image = iconId
	btn.Parent = TopButtonsFrame
	applyCorner(btn, 12)
	local stroke = applyStroke(btn, THEME.Purple, 2)
	stroke.Transparency = 1 -- Invisível até ser ativado
	
	btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(230,230,240)}):Play() end)
	btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.PanelBg}):Play() end)
	
	table.insert(UI_ELEMENTS, btn)
	buttons[name] = {Btn = btn, Stroke = stroke, Active = false}
	return btn
end

createTopButton("FreeCam", IMAGES.FreeCam)
createTopButton("Teleport", IMAGES.Teleport)
createTopButton("Platform", IMAGES.Platform)
createTopButton("Noclip", IMAGES.Noclip)

-- Seção Iluminação
local LightPanel = Instance.new("Frame")
LightPanel.Size = UDim2.new(1, -20, 0, 75)
LightPanel.Position = UDim2.new(0, 10, 0, 70)
LightPanel.BackgroundColor3 = THEME.PanelBg
LightPanel.Parent = MainFrame
applyCorner(LightPanel, 12)
applyStroke(LightPanel, THEME.Purple, 2)
table.insert(UI_ELEMENTS, LightPanel)

local LightIcon = Instance.new("ImageLabel")
LightIcon.Size = UDim2.new(0, 25, 0, 25)
LightIcon.Position = UDim2.new(0, 10, 0, 10)
LightIcon.BackgroundTransparency = 1
LightIcon.Image = IMAGES.Lighting
LightIcon.ImageColor3 = THEME.Purple
LightIcon.Parent = LightPanel

local LightTitle = Instance.new("TextLabel")
LightTitle.Size = UDim2.new(0, 100, 0, 25)
LightTitle.Position = UDim2.new(0, 40, 0, 10)
LightTitle.BackgroundTransparency = 1
LightTitle.Text = "lighting"
LightTitle.TextColor3 = THEME.Purple
LightTitle.Font = Enum.Font.GothamBold
LightTitle.TextSize = 20
LightTitle.TextXAlignment = Enum.TextXAlignment.Left
LightTitle.Parent = LightPanel
table.insert(UI_ELEMENTS, LightTitle)

local LightSliderBg = Instance.new("Frame")
LightSliderBg.Size = UDim2.new(1, -20, 0, 12)
LightSliderBg.Position = UDim2.new(0, 10, 0, 50)
LightSliderBg.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
LightSliderBg.Parent = LightPanel
applyCorner(LightSliderBg, 6)

local LightSliderFill = Instance.new("Frame")
LightSliderFill.Size = UDim2.new(settings.lightValue / 100, 0, 1, 0)
LightSliderFill.BackgroundColor3 = THEME.Purple
LightSliderFill.Parent = LightSliderBg
applyCorner(LightSliderFill, 6)

local LightTextMin = Instance.new("TextLabel")
LightTextMin.Size = UDim2.new(0, 100, 0, 15)
LightTextMin.Position = UDim2.new(0, 10, 0, 35)
LightTextMin.BackgroundTransparency = 1
LightTextMin.Text = "1%(default game)"
LightTextMin.TextColor3 = THEME.Text
LightTextMin.Font = Enum.Font.GothamSemibold
LightTextMin.TextSize = 12
LightTextMin.TextXAlignment = Enum.TextXAlignment.Left
LightTextMin.Parent = LightPanel
table.insert(UI_ELEMENTS, LightTextMin)

local LightTextMax = LightTextMin:Clone()
LightTextMax.Position = UDim2.new(1, -110, 0, 35)
LightTextMax.Text = "100%(full)"
LightTextMax.TextXAlignment = Enum.TextXAlignment.Right
LightTextMax.Parent = LightPanel

-- Seção Posição
local PosPanel = Instance.new("Frame")
PosPanel.Size = UDim2.new(1, -20, 0, 90)
PosPanel.Position = UDim2.new(0, 10, 0, 155)
PosPanel.BackgroundColor3 = THEME.PanelBg
PosPanel.Parent = MainFrame
applyCorner(PosPanel, 12)
applyStroke(PosPanel, THEME.Purple, 2)
table.insert(UI_ELEMENTS, PosPanel)

local PosIcon = LightIcon:Clone()
PosIcon.Image = IMAGES.Position
PosIcon.Parent = PosPanel

local PosTitle = LightTitle:Clone()
PosTitle.Text = "position"
PosTitle.Parent = PosPanel
table.insert(UI_ELEMENTS, PosTitle)

local function createAxisText(axis, color, yOffset)
	local txt = Instance.new("TextLabel")
	txt.Size = UDim2.new(1, -20, 0, 15)
	txt.Position = UDim2.new(0, 10, 0, yOffset)
	txt.BackgroundTransparency = 1
	txt.Text = axis .. ": 0.00"
	txt.TextColor3 = color
	txt.Font = Enum.Font.GothamBold
	txt.TextSize = 14
	txt.TextXAlignment = Enum.TextXAlignment.Left
	txt.Parent = PosPanel
	table.insert(UI_ELEMENTS, txt)
	return txt
end

local YTxt = createAxisText("Y", THEME.Y, 35)
local XTxt = createAxisText("X", THEME.X, 50)
local ZTxt = createAxisText("Z", THEME.Z, 65)

-- Botão de Redimensionamento (Triângulo)
local ResizeBtn = Instance.new("ImageButton")
ResizeBtn.Size = UDim2.new(0, 20, 0, 20)
ResizeBtn.Position = UDim2.new(1, -20, 1, -20)
ResizeBtn.BackgroundTransparency = 1
ResizeBtn.Image = IMAGES.ResizeIcon
ResizeBtn.ImageColor3 = THEME.Purple
ResizeBtn.Parent = MainFrame

-- [ SISTEMA NOCLIP (Setas Virtuais) ]
local yControls = Instance.new("Frame")
yControls.Size = UDim2.new(0, 50, 0, 100)
yControls.BackgroundTransparency = 1
yControls.Visible = false
yControls.Parent = screenGui

local function createArrow(txt, pos)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 45)
	b.Position = pos
	b.BackgroundColor3 = THEME.PanelBg
	b.Text = txt
	b.TextColor3 = THEME.Purple
	b.TextScaled = true
	b.Parent = yControls
	applyCorner(b, 8)
	applyStroke(b, THEME.Purple, 1)
	return b
end
local btnUp = createArrow("▲", UDim2.new(0,0,0,0))
local btnDown = createArrow("▼", UDim2.new(0,0,0,55))

-- ========================================================================= --
-- [ LÓGICA DE INTERAÇÃO DA UI ]
-- ========================================================================= --

-- Partículas UI
local function EmitUIParticles(parent)
	for i = 1, 5 do
		local particle = Instance.new("Frame")
		particle.Size = UDim2.new(0, 10, 0, 10)
		particle.Position = UDim2.new(0.5, -5, 0.5, -5)
		particle.BackgroundColor3 = THEME.Purple
		applyCorner(particle, 5)
		particle.Parent = parent
		
		local angle = math.rad(math.random(0, 360))
		local distance = math.random(15, 30)
		local endPos = UDim2.new(0.5, math.cos(angle)*distance - 5, 0.5, math.sin(angle)*distance - 5)
		
		local tw = TweenService:Create(particle, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = endPos,
			BackgroundTransparency = 1,
			Size = UDim2.new(0,0,0,0)
		})
		tw:Play()
		tw.Completed:Connect(function() particle:Destroy() end)
	end
end

-- Atualiza Transparência (#ts)
local function UpdateUITransparency()
	for _, element in pairs(UI_ELEMENTS) do
		if element:IsA("Frame") or element:IsA("ImageButton") then
			if element.Name == "MainFrame" then
				element.BackgroundTransparency = settings.transparency
			else
				element.BackgroundTransparency = (element.BackgroundTransparency == 1 and 1) or settings.transparency
			end
		elseif element:IsA("TextLabel") then
			element.TextTransparency = settings.transparency
		end
	end
end

-- Abre/Fecha Janela
OpenBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = not MainFrame.Visible
	EmitUIParticles(OpenBtn)
	if MainFrame.Visible then
		MainFrame.Size = UDim2.new(0, 0, 0, 0)
		TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 420, 0, 260)}):Play()
	end
end)

-- Sistema Arrastável
local function MakeDraggable(gui)
	local dragging, dragInput, dragStart, startPos
	gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position
		end
	end)
	gui.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	gui.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end
MakeDraggable(MainFrame)
MakeDraggable(OpenBtn)

-- Sistema Redimensionável
local resizing = false
local resizeStartPos, startSize
ResizeBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		resizing = true
		resizeStartPos = input.Position
		startSize = MainFrame.Size
	end
end)
UIS.InputChanged:Connect(function(input)
	if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - resizeStartPos
		local newWidth = math.clamp(startSize.X.Offset + delta.X, 300, 600)
		local newHeight = math.clamp(startSize.Y.Offset + delta.Y, 200, 500)
		MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
	end
end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		resizing = false
	end
end)

-- Sistema de Slider (Iluminação)
local draggingLight = false
local function UpdateLighting()
	settings.lightValue = math.clamp(settings.lightValue, 1, 100)
	LightSliderFill.Size = UDim2.new(settings.lightValue / 100, 0, 1, 0)
	
	if settings.lightValue <= 1 then
		Lighting.Ambient = OriginalLighting.Ambient
		Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
		Lighting.Brightness = OriginalLighting.Brightness
		Lighting.ExposureCompensation = OriginalLighting.ExposureCompensation
	else
		local perc = settings.lightValue / 100
		Lighting.Ambient = OriginalLighting.Ambient:Lerp(Color3.new(1, 1, 1), perc)
		Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient:Lerp(Color3.new(1, 1, 1), perc)
		Lighting.Brightness = OriginalLighting.Brightness + (5 * perc)
		Lighting.ExposureCompensation = OriginalLighting.ExposureCompensation + (2 * perc)
	end
	save()
end

local function ProcessLightInput(input)
	local relativeX = input.Position.X - LightSliderBg.AbsolutePosition.X
	local percentage = math.clamp(relativeX / LightSliderBg.AbsoluteSize.X, 0.01, 1)
	settings.lightValue = math.floor(percentage * 100)
	UpdateLighting()
end

LightSliderBg.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingLight = true
		ProcessLightInput(input)
	end
end)
UIS.InputChanged:Connect(function(input)
	if draggingLight and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		ProcessLightInput(input)
	end
end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingLight = false
	end
end)

local function ToggleButtonVisual(btnName, state)
	local obj = buttons[btnName]
	obj.Active = state
	TweenService:Create(obj.Stroke, TweenInfo.new(0.3), {Transparency = state and 0 or 1}):Play()
	if state then EmitUIParticles(obj.Btn) end
end

-- ========================================================================= --
-- [ OBJETOS DE APOIO & VARIÁVEIS DE ESTADO (MECÂNICA ORIGINAL) ]
-- ========================================================================= --
local platPart = Instance.new("Part")
platPart.Name = "StudioPro_Platform"
platPart.Size = Vector3.new(15, 1, 15)
platPart.Anchored = true
platPart.CanCollide = false
platPart.Transparency = 1
platPart.Material = Enum.Material.Glass
platPart.Parent = workspace

local platActive = false
local noclipActive = false
local enabled = false -- FreeCam
local camPos = Vector3.new(0,0,0)
local pitch, yaw, sens = 0, 0, 0.005
local frameCount = 0
local originalCollisions = {}
local yMove = 0
local platY_Noclip = 0

btnUp.MouseButton1Down:Connect(function() yMove = 0.65 end)
btnUp.MouseButton1Up:Connect(function() yMove = 0 end)
btnDown.MouseButton1Down:Connect(function() yMove = -0.65 end)
btnDown.MouseButton1Up:Connect(function() yMove = 0 end)

-- ========================================================================= --
-- [ FUNCIONAMENTO DOS BOTÕES PRINCIPAIS ]
-- ========================================================================= --

-- [1] FREECAM
buttons.FreeCam.Btn.MouseButton1Click:Connect(function()
	enabled = not enabled
	ToggleButtonVisual("FreeCam", enabled)
	camera.CameraType = enabled and Enum.CameraType.Scriptable or Enum.CameraType.Custom
	if enabled then
		camPos = camera.CFrame.Position
		pitch, yaw = math.asin(camera.CFrame.LookVector.Y), math.atan2(-camera.CFrame.LookVector.X, -camera.CFrame.LookVector.Z)
	end
	
	-- Congela o personagem ao ativar
	local char = player.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		char.HumanoidRootPart.Anchored = enabled
	end
end)

-- [2] TELEPORT
buttons.Teleport.Btn.MouseButton1Click:Connect(function()
	EmitUIParticles(buttons.Teleport.Btn)
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.CFrame = camera.CFrame
		if enabled then
			enabled = false
			ToggleButtonVisual("FreeCam", false)
			camera.CameraType = Enum.CameraType.Custom
			player.Character.HumanoidRootPart.Anchored = false
		end
	end
end)

-- [3] PLATAFORMA DINÂMICA
buttons.Platform.Btn.MouseButton1Click:Connect(function()
	platActive = not platActive
	ToggleButtonVisual("Platform", platActive)
	if not noclipActive then
		platPart.CanCollide = platActive
		platPart.Transparency = platActive and 0.8 or 1
	end
end)

-- [4] NOCLIP PLATAFORMA
local function restoreMap()
	for part, colState in pairs(originalCollisions) do if part and part.Parent then part.CanCollide = colState end end
	originalCollisions = {}
end

local function toggleNoclip()
	noclipActive = not noclipActive
	ToggleButtonVisual("Noclip", noclipActive)
	
	if noclipActive then
		platPart.CanCollide = true; platPart.Transparency = 0.8
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			platY_Noclip = player.Character.HumanoidRootPart.Position.Y - 4.5
		end
		for _, v in pairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") and v ~= platPart and not v:IsDescendantOf(player.Character) then
				originalCollisions[v] = v.CanCollide; v.CanCollide = false
			end
		end
		local tg = player.PlayerGui:FindFirstChild("TouchGui")
		local jumpBtn = tg and tg:FindFirstChild("JumpButton", true)
		if jumpBtn then 
			yControls.Position = UDim2.new(0, jumpBtn.AbsolutePosition.X + (jumpBtn.AbsoluteSize.X/4), 0, jumpBtn.AbsolutePosition.Y - 135) 
		else
			yControls.Position = UDim2.new(1, -100, 0.5, -50) -- Fallback para PC
		end
		yControls.Visible = true
	else
		restoreMap()
		yControls.Visible = false
		yMove = 0
		if not platActive then platPart.CanCollide = false; platPart.Transparency = 1 end
	end
end
buttons.Noclip.Btn.MouseButton1Click:Connect(toggleNoclip)

-- Reset por morte
player.CharacterAdded:Connect(function(char)
	if noclipActive then toggleNoclip() end
	char:WaitForChild("Humanoid").Died:Connect(function() if noclipActive then toggleNoclip() end end)
	
	-- Se renascer enquanto o freecam está ativo, reancorar
	if enabled then
		local hrp = char:WaitForChild("HumanoidRootPart", 3)
		if hrp then hrp.Anchored = true end
	end
end)

-- [ ANTI-VAZAMENTO ANALÓGICO DA CÂMERA ]
local function forceInv(obj)
	if not settings.inv then return end
	if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
		obj.ImageTransparency = 1
		if not obj:GetAttribute("Locked") then
			obj:GetPropertyChangedSignal("ImageTransparency"):Connect(function() if settings.inv then obj.ImageTransparency = 1 end end)
			obj:SetAttribute("Locked", true)
		end
	elseif obj:IsA("Frame") then
		obj.BackgroundTransparency = 1
		if not obj:GetAttribute("Locked") then
			obj:GetPropertyChangedSignal("BackgroundTransparency"):Connect(function() if settings.inv then obj.BackgroundTransparency = 1 end end)
			obj:SetAttribute("Locked", true)
		end
	end
end

-- ========================================================================= --
-- [ LOOP PRINCIPAL ]
-- ========================================================================= --
RunService.RenderStepped:Connect(function()
	if settings.inv then   
		frameCount = (frameCount + 1) % 10  
		if frameCount == 0 then   
			local tg = player.PlayerGui:FindFirstChild("TouchGui")  
			if tg then for _, v in pairs(tg:GetDescendants()) do forceInv(v) end end  
		end  
	end  

	local char = player.Character  
	local hrp = char and char:FindFirstChild("HumanoidRootPart")  
	local hum = char and char:FindFirstChildOfClass("Humanoid")  

	if hrp then
		-- Atualiza textos de Posição
		YTxt.Text = string.format("Y: %.2f", hrp.Position.Y)
		XTxt.Text = string.format("X: %.2f", hrp.Position.X)
		ZTxt.Text = string.format("Z: %.2f", hrp.Position.Z)

		if noclipActive then  
			-- LÓGICA NOCLIP: Segue X/Z, Y travado nas setas  
			if yMove ~= 0 then   
				platY_Noclip = platY_Noclip + yMove  
				hrp.CFrame = hrp.CFrame + Vector3.new(0, yMove, 0)  
			end  
			platPart.CFrame = CFrame.new(hrp.Position.X, platY_Noclip, hrp.Position.Z)  
		elseif platActive then  
			-- LÓGICA DINÂMICA: Segue em TODOS os eixos a 4.5 studs  
			platPart.CFrame = hrp.CFrame * CFrame.new(0, -4.5, 0)  
		else  
			platPart.CFrame = CFrame.new(0, -500, 0)  
		end  
    end
    if enabled then  
		local move = require(player.PlayerScripts:WaitForChild("PlayerModule")):GetControls():GetMoveVector()  
		local rot = CFrame.fromEulerAnglesYXZ(pitch, yaw, 0)  
		camPos = camPos + rot:VectorToWorldSpace(Vector3.new(move.X, 0, move.Z) * settings.speed)  
		camera.CFrame = CFrame.new(camPos) * rot  
		
		if hrp and hum then  
			hrp.AssemblyLinearVelocity = Vector3.zero  
			hrp.AssemblyAngularVelocity = Vector3.zero  
			if hum:GetState() ~= Enum.HumanoidStateType.Running then hum:ChangeState(Enum.HumanoidStateType.Running) end  
		end  
	end
end)

UIS.InputChanged:Connect(function(io, p)
	if enabled and io.UserInputType == Enum.UserInputType.Touch and not p then
		yaw = yaw + (io.Delta.X * -sens)
		pitch = math.clamp(pitch + (io.Delta.Y * -sens), math.rad(-89), math.rad(89))
	end
end)

-- Sistema de Comandos Chat
player.Chatted:Connect(function(msg)
	local a = msg:lower():split(" ")
	if a[1] == "#inv" then 
		settings.inv = true; save()
	elseif a[1] == "#uninv" then 
		settings.inv = false; save()
	elseif a[1] == "#ts" and a[2] then 
		settings.transparency = tonumber(a[2])
		UpdateUITransparency()
		save()
	end
end)

-- Inicializa estados da UI
UpdateLighting()
UpdateUITransparency()

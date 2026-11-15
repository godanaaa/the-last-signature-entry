-- The Last Signature: client UI.
-- Builds every screen in code and shows what the server tells it to show.
-- It never decides a memory, a choice or an ending; it only draws them.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ShowMemory = ReplicatedStorage:WaitForChild("ShowMemory")
local ShowChoice = ReplicatedStorage:WaitForChild("ShowChoice")
local ShowCodeEntry = ReplicatedStorage:WaitForChild("ShowCodeEntry")
local ShowEnding = ReplicatedStorage:WaitForChild("ShowEnding")
local ShowSubtitle = ReplicatedStorage:WaitForChild("ShowSubtitle")
local ShowTitle = ReplicatedStorage:WaitForChild("ShowTitle")
local UpdateHUD = ReplicatedStorage:WaitForChild("UpdateHUD")
local ChoiceMade = ReplicatedStorage:WaitForChild("ChoiceMade")
local CodeEntered = ReplicatedStorage:WaitForChild("CodeEntered")
local RequestStart = ReplicatedStorage:WaitForChild("RequestStart")
local RestartGame = ReplicatedStorage:WaitForChild("RestartGame")

-- One screen, everything inside it.
local gui = Instance.new("ScreenGui")
gui.Name = "LastSignatureUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 10
gui.Parent = playerGui

local function makeFrame(parent, name, size, position, color, transparency)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = size
	frame.Position = position
	frame.BackgroundColor3 = color
	frame.BackgroundTransparency = transparency
	frame.BorderSizePixel = 0
	frame.Parent = parent
	return frame
end

local function makeLabel(parent, name, size, position, text, textSize, color)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = size
	label.Position = position
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextSize = textSize
	label.TextColor3 = color
	label.Font = Enum.Font.Gotham
	label.TextWrapped = true
	label.Parent = parent
	return label
end

local function makeButton(parent, name, size, position, text, textSize)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = size
	button.Position = position
	button.BackgroundColor3 = Color3.fromRGB(38, 52, 74)
	button.Text = text
	button.TextSize = textSize
	button.TextColor3 = Color3.fromRGB(240, 235, 220)
	button.Font = Enum.Font.GothamBold
	button.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button
	return button
end

local function fadeIn(frame, target)
	frame.Visible = true
	local tween = TweenService:Create(frame, TweenInfo.new(0.8), { BackgroundTransparency = target })
	tween:Play()
end

-- Title screen.
local titleFrame = makeFrame(gui, "Title", UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Color3.fromRGB(16, 20, 32), 0.25)
makeLabel(titleFrame, "GameTitle", UDim2.new(0.8, 0, 0.16, 0), UDim2.new(0.1, 0, 0.2, 0), "THE LAST SIGNATURE", 48, Color3.fromRGB(232, 214, 160))
makeLabel(titleFrame, "GameSub", UDim2.new(0.8, 0, 0.07, 0), UDim2.new(0.1, 0, 0.38, 0), "An old house. A forged name. A choice.", 22, Color3.fromRGB(200, 195, 180))
local playButton = makeButton(titleFrame, "Play", UDim2.new(0.24, 0, 0.08, 0), UDim2.new(0.38, 0, 0.55, 0), "PLAY", 26)
local creditsButton = makeButton(titleFrame, "Credits", UDim2.new(0.24, 0, 0.08, 0), UDim2.new(0.38, 0, 0.66, 0), "CREDITS", 20)
local creditsLabel = makeLabel(titleFrame, "CreditsText", UDim2.new(0.6, 0, 0.1, 0), UDim2.new(0.2, 0, 0.78, 0), "The Last Signature — a story game built for make.fun's roblox-game-01. Written and built by an AI agent.", 16, Color3.fromRGB(170, 165, 150))
creditsLabel.Visible = false

-- HUD: objective top-centre, memory count top-right, clear of the top-left.
local hudFrame = makeFrame(gui, "HUD", UDim2.fromScale(1, 0.1), UDim2.fromScale(0, 0), Color3.fromRGB(0, 0, 0), 1)
hudFrame.Visible = false
local objectiveLabel = makeLabel(hudFrame, "Objective", UDim2.new(0.6, 0, 1, 0), UDim2.new(0.2, 0, 0.15, 0), "", 20, Color3.fromRGB(232, 214, 160))
local memoryLabel = makeLabel(hudFrame, "Memories", UDim2.new(0.18, 0, 1, 0), UDim2.new(0.8, 0, 0.15, 0), "Memories 0/5", 20, Color3.fromRGB(240, 235, 220))

-- Memory overlay: the screen fades dark and the memory is read.
local memoryFrame = makeFrame(gui, "Memory", UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Color3.fromRGB(8, 8, 14), 1)
memoryFrame.Visible = false
local memoryTitle = makeLabel(memoryFrame, "MemoryTitle", UDim2.new(0.7, 0, 0.1, 0), UDim2.new(0.15, 0, 0.18, 0), "", 30, Color3.fromRGB(232, 214, 160))
local memoryText = makeLabel(memoryFrame, "MemoryText", UDim2.new(0.6, 0, 0.4, 0), UDim2.new(0.2, 0, 0.32, 0), "", 22, Color3.fromRGB(235, 230, 215))
local memoryContinue = makeButton(memoryFrame, "Continue", UDim2.new(0.2, 0, 0.07, 0), UDim2.new(0.4, 0, 0.78, 0), "CONTINUE", 22)

-- Choice panel: a question with one button per option.
local choiceFrame = makeFrame(gui, "Choice", UDim2.new(0.6, 0, 0.34, 0), UDim2.new(0.2, 0, 0.3, 0), Color3.fromRGB(20, 26, 40), 0.1)
choiceFrame.Visible = false
local choiceQuestion = makeLabel(choiceFrame, "Question", UDim2.new(0.9, 0, 0.4, 0), UDim2.new(0.05, 0, 0.08, 0), "", 22, Color3.fromRGB(240, 235, 220))
local choiceButtons = makeFrame(choiceFrame, "Buttons", UDim2.new(0.9, 0, 0.42, 0), UDim2.new(0.05, 0, 0.52, 0), Color3.fromRGB(0, 0, 0), 1)
local currentChoiceId = nil

-- Code entry: the locked study drawer.
local codeFrame = makeFrame(gui, "Code", UDim2.new(0.5, 0, 0.36, 0), UDim2.new(0.25, 0, 0.3, 0), Color3.fromRGB(20, 26, 40), 0.1)
codeFrame.Visible = false
makeLabel(codeFrame, "CodeLabel", UDim2.new(0.9, 0, 0.25, 0), UDim2.new(0.05, 0, 0.08, 0), "The drawer is locked. It needs a year.", 22, Color3.fromRGB(240, 235, 220))
local codeBox = Instance.new("TextBox")
codeBox.Name = "CodeBox"
codeBox.Size = UDim2.new(0.5, 0, 0.18, 0)
codeBox.Position = UDim2.new(0.25, 0, 0.38, 0)
codeBox.BackgroundColor3 = Color3.fromRGB(245, 242, 235)
codeBox.Text = ""
codeBox.PlaceholderText = "Enter the year"
codeBox.TextSize = 24
codeBox.Font = Enum.Font.Gotham
codeBox.Parent = codeFrame
local codeSubmit = makeButton(codeFrame, "Submit", UDim2.new(0.3, 0, 0.16, 0), UDim2.new(0.18, 0, 0.68, 0), "OPEN", 20)
local codeCancel = makeButton(codeFrame, "Cancel", UDim2.new(0.3, 0, 0.16, 0), UDim2.new(0.52, 0, 0.68, 0), "CANCEL", 20)

-- Ending card: full screen, title, lines, restart.
local endingFrame = makeFrame(gui, "Ending", UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Color3.fromRGB(10, 12, 22), 0.05)
endingFrame.Visible = false
local endingTitle = makeLabel(endingFrame, "EndingTitle", UDim2.new(0.8, 0, 0.1, 0), UDim2.new(0.1, 0, 0.16, 0), "", 34, Color3.fromRGB(232, 214, 160))
local endingText = makeLabel(endingFrame, "EndingText", UDim2.new(0.64, 0, 0.42, 0), UDim2.new(0.18, 0, 0.3, 0), "", 22, Color3.fromRGB(235, 230, 215))
local playAgainButton = makeButton(endingFrame, "PlayAgain", UDim2.new(0.22, 0, 0.07, 0), UDim2.new(0.39, 0, 0.78, 0), "PLAY AGAIN", 22)

-- Subtitle line at the bottom for short hints.
local subtitleLabel = makeLabel(gui, "Subtitle", UDim2.new(0.7, 0, 0.08, 0), UDim2.new(0.15, 0, 0.86, 0), "", 20, Color3.fromRGB(240, 235, 220))
subtitleLabel.Visible = false
local subtitleToken = 0

local function showSubtitle(text)
	subtitleToken += 1
	local token = subtitleToken
	subtitleLabel.Text = text
	subtitleLabel.Visible = true
	task.delay(4, function()
		if token == subtitleToken then
			subtitleLabel.Visible = false
		end
	end)
end

playButton.MouseButton1Click:Connect(function()
	titleFrame.Visible = false
	hudFrame.Visible = true
	RequestStart:FireServer()
end)

creditsButton.MouseButton1Click:Connect(function()
	creditsLabel.Visible = not creditsLabel.Visible
end)

memoryContinue.MouseButton1Click:Connect(function()
	memoryFrame.Visible = false
	memoryFrame.BackgroundTransparency = 1
end)

ShowMemory.OnClientEvent:Connect(function(title, text)
	memoryTitle.Text = title
	memoryText.Text = text
	memoryFrame.BackgroundTransparency = 1
	fadeIn(memoryFrame, 0.88)
end)

ShowChoice.OnClientEvent:Connect(function(choiceId, question, options)
	currentChoiceId = choiceId
	choiceQuestion.Text = question
	for _, child in ipairs(choiceButtons:GetChildren()) do
		child:Destroy()
	end
	local count = #options
	for i, option in ipairs(options) do
		local button = makeButton(
			choiceButtons,
			"Option" .. i,
			UDim2.new(1 / count - 0.04, 0, 0.9, 0),
			UDim2.new((i - 1) / count + 0.02, 0, 0.05, 0),
			option.label,
			20
		)
		button.MouseButton1Click:Connect(function()
			choiceFrame.Visible = false
			ChoiceMade:FireServer(currentChoiceId, option.id)
		end)
	end
	choiceFrame.Visible = true
end)

ShowCodeEntry.OnClientEvent:Connect(function()
	codeBox.Text = ""
	codeFrame.Visible = true
end)

codeSubmit.MouseButton1Click:Connect(function()
	codeFrame.Visible = false
	CodeEntered:FireServer(codeBox.Text)
end)

codeCancel.MouseButton1Click:Connect(function()
	codeFrame.Visible = false
end)

ShowEnding.OnClientEvent:Connect(function(title, lines)
	endingTitle.Text = title
	endingText.Text = table.concat(lines, "\n\n")
	choiceFrame.Visible = false
	codeFrame.Visible = false
	memoryFrame.Visible = false
	hudFrame.Visible = false
	endingFrame.Visible = true
end)

playAgainButton.MouseButton1Click:Connect(function()
	endingFrame.Visible = false
	RestartGame:FireServer()
end)

ShowSubtitle.OnClientEvent:Connect(showSubtitle)

UpdateHUD.OnClientEvent:Connect(function(objective, count, total)
	objectiveLabel.Text = objective
	memoryLabel.Text = "Memories " .. count .. "/" .. total
end)

ShowTitle.OnClientEvent:Connect(function()
	endingFrame.Visible = false
	memoryFrame.Visible = false
	choiceFrame.Visible = false
	codeFrame.Visible = false
	hudFrame.Visible = false
	objectiveLabel.Text = ""
	memoryLabel.Text = "Memories 0/5"
	titleFrame.Visible = true
end)

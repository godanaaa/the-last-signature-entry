-- The Last Signature: server game logic.
-- Every rule lives here. The client only draws screens; it never decides
-- what a memory, a choice or an ending is. One state table per player keeps
-- the story: which memories were found, what was chosen, which doors opened.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

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

local SPAWN_POSITION = Vector3.new(0, 3, 8)

-- The house gets darker as the truth comes out. Applied at memory milestones.
local LIGHTING_STAGES = {
	{ at = 0, clockTime = 15, brightness = 2.5, ambient = Color3.fromRGB(128, 115, 102) },
	{ at = 2, clockTime = 19, brightness = 1.6, ambient = Color3.fromRGB(64, 56, 64) },
	{ at = 4, clockTime = 21, brightness = 1.1, ambient = Color3.fromRGB(30, 26, 36) },
}

local function applyLighting(memoryCount)
	local stage = LIGHTING_STAGES[1]
	for _, candidate in ipairs(LIGHTING_STAGES) do
		if memoryCount >= candidate.at then
			stage = candidate
		end
	end
	Lighting.ClockTime = stage.clockTime
	Lighting.Brightness = stage.brightness
	Lighting.Ambient = stage.ambient
end

local function findPart(name)
	for _, descendant in ipairs(Workspace:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant.Name == name then
			return descendant
		end
	end
	return nil
end

local function findPrompt(partName)
	local part = findPart(partName)
	if not part then
		return nil
	end
	for _, child in ipairs(part:GetChildren()) do
		if child:IsA("ProximityPrompt") then
			return child
		end
	end
	return nil
end

-- One state table per player.
local playerState = {}

local function newState()
	return {
		started = false,
		finished = false,
		memories = {},
		memoryCount = 0,
		hasKey = false,
		letterDone = false,
		phoneDone = false,
		willFound = false,
		objective = Config.OBJECTIVES.start,
	}
end

local function sendHUD(player)
	local state = playerState[player]
	if state then
		UpdateHUD:FireClient(player, state.objective, state.memoryCount, Config.MEMORY_TOTAL)
	end
end

local function setObjective(player, objective)
	local state = playerState[player]
	if state then
		state.objective = objective
		sendHUD(player)
	end
end

local function grantMemory(player, memoryId)
	local state = playerState[player]
	if not state or state.memories[memoryId] then
		return false
	end
	local memory = Config.MEMORIES[memoryId]
	if not memory then
		return false
	end
	state.memories[memoryId] = true
	state.memoryCount += 1
	applyLighting(state.memoryCount)
	ShowMemory:FireClient(player, memory.title, memory.text)
	sendHUD(player)
	return true
end

local function showHint(player, text)
	ShowSubtitle:FireClient(player, text)
end

local function openDoor(part)
	if part then
		part.Transparency = 1
		part.CanCollide = false
		part.CanTouch = false
		local prompt = nil
		for _, child in ipairs(part:GetChildren()) do
			if child:IsA("ProximityPrompt") then
				prompt = child
			end
		end
		if prompt then
			prompt.Enabled = false
		end
	end
end

local function closeDoor(part)
	if part then
		part.Transparency = 0
		part.CanCollide = true
		part.CanTouch = true
		for _, child in ipairs(part:GetChildren()) do
			if child:IsA("ProximityPrompt") then
				child.Enabled = true
			end
		end
	end
end

local function showEnding(player, endingId)
	local state = playerState[player]
	if not state or state.finished then
		return
	end
	state.finished = true
	setObjective(player, Config.OBJECTIVES.done)
	local ending = Config.ENDINGS[endingId]
	ShowEnding:FireClient(player, ending.title, ending.lines)
end

-- Connect one prompt to one handler. Nothing happens before the player
-- presses Play, so the title screen is never bypassed by walking around.
local function onPrompt(partName, handler)
	local prompt = findPrompt(partName)
	if not prompt then
		warn("The Last Signature: no prompt on " .. partName)
		return
	end
	prompt.Triggered:Connect(function(player)
		local state = playerState[player]
		if state and state.started and not state.finished then
			handler(player, state)
		end
	end)
end

onPrompt("Envelope", function(player)
	ShowMemory:FireClient(player, Config.NOTE_TITLE, Config.NOTE_TEXT)
end)

onPrompt("Photograph", function(player, state)
	if grantMemory(player, "photograph") then
		setObjective(player, Config.OBJECTIVES.photograph)
	end
end)

onPrompt("KeyDrawer", function(player, state)
	if state.hasKey then
		showHint(player, "The drawer is empty now.")
		return
	end
	if not state.memories.photograph then
		showHint(player, Config.HINTS.needPhotograph)
		return
	end
	state.hasKey = true
	findPrompt("KeyDrawer").Enabled = false
	showHint(player, Config.HINTS.gotKey)
	setObjective(player, Config.OBJECTIVES.key)
end)

onPrompt("Letter", function(player, state)
	if state.letterDone then
		showHint(player, "You have already decided about the letter.")
		return
	end
	ShowChoice:FireClient(player, "letter", Config.CHOICES.letter.question, Config.CHOICES.letter.options)
end)

onPrompt("Telephone", function(player, state)
	if state.phoneDone then
		showHint(player, "The telephone is silent now.")
		return
	end
	ShowChoice:FireClient(player, "telephone", Config.CHOICES.telephone.question, Config.CHOICES.telephone.options)
end)

onPrompt("Watch", function(player)
	grantMemory(player, "watch")
end)

onPrompt("Pen", function(player)
	grantMemory(player, "pen")
end)

onPrompt("LockedDrawer", function(player)
	ShowCodeEntry:FireClient(player)
end)

onPrompt("Will", function(player, state)
	if state.willFound then
		ShowMemory:FireClient(player, Config.WILL_TITLE, Config.WILL_TEXT)
		return
	end
	state.willFound = true
	ShowMemory:FireClient(player, Config.WILL_TITLE, Config.WILL_TEXT)
	openDoor(findPart("SecretDoor"))
	showHint(player, Config.HINTS.secretOpen)
	setObjective(player, Config.OBJECTIVES.secret)
end)

onPrompt("BlueDoor", function(player, state)
	if not state.hasKey then
		showHint(player, Config.HINTS.needKey)
		return
	end
	openDoor(findPart("BlueDoor"))
	showHint(player, Config.HINTS.doorOpen)
	setObjective(player, Config.OBJECTIVES.blueDoor)
end)

onPrompt("SecretDoor", function(player)
	local door = findPart("SecretDoor")
	if door and door.Transparency == 1 then
		showHint(player, "It is open now. Go on.")
	else
		showHint(player, Config.HINTS.needWill)
	end
end)

onPrompt("FinalPedestal", function(player, state)
	if state.memoryCount < Config.MEMORIES_FOR_TRUTH then
		showEnding(player, "unfinished")
		return
	end
	ShowChoice:FireClient(player, "final", Config.CHOICES.final.question, Config.CHOICES.final.options)
end)

-- Walking into a new room moves the objective on.
local function onRoomTrigger(triggerName, objective)
	local trigger = findPart(triggerName)
	if not trigger then
		return
	end
	local done = {}
	trigger.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player or done[player] then
			return
		end
		local state = playerState[player]
		if not state or not state.started or state.finished then
			return
		end
		done[player] = true
		setObjective(player, objective)
	end)
end

onRoomTrigger("HiddenRoomTrigger", Config.OBJECTIVES.will)
onRoomTrigger("SecretRoomTrigger", Config.OBJECTIVES.final)

-- Choices come back from the client with (choiceId, optionId).
ChoiceMade.OnServerEvent:Connect(function(player, choiceId, optionId)
	local state = playerState[player]
	if not state or not state.started or state.finished then
		return
	end
	if choiceId == "letter" and not state.letterDone then
		state.letterDone = true
		if optionId == "open" then
			grantMemory(player, "letter")
		else
			local fallout = Config.CHOICE_FALLOUT.letterLeave
			ShowMemory:FireClient(player, fallout.title, fallout.text)
		end
	elseif choiceId == "telephone" and not state.phoneDone then
		state.phoneDone = true
		if optionId == "answer" then
			grantMemory(player, "telephone")
		else
			local fallout = Config.CHOICE_FALLOUT.phoneIgnore
			ShowMemory:FireClient(player, fallout.title, fallout.text)
		end
	elseif choiceId == "final" then
		if optionId == "forgive" then
			showEnding(player, "acceptance")
		elseif optionId == "expose" then
			showEnding(player, "truth")
		elseif optionId == "protect" then
			showEnding(player, "signature")
		end
	end
end)

-- The study drawer opens with the year on the photograph: 1962.
CodeEntered.OnServerEvent:Connect(function(player, code)
	local state = playerState[player]
	if not state or not state.started or state.finished then
		return
	end
	if code == Config.DATE_CODE then
		local will = findPart("Will")
		if will then
			will.Transparency = 0
			will.CanCollide = true
			local prompt = findPrompt("Will")
			if prompt then
				prompt.Enabled = true
			end
		end
		showHint(player, "The drawer clicks open. Inside: a folded will.")
	else
		showHint(player, Config.HINTS.wrongCode)
	end
end)

local function resetWorld()
	closeDoor(findPart("BlueDoor"))
	closeDoor(findPart("SecretDoor"))
	local will = findPart("Will")
	if will then
		will.Transparency = 1
		will.CanCollide = false
		local prompt = findPrompt("Will")
		if prompt then
			prompt.Enabled = false
		end
	end
	local keyDrawerPrompt = findPrompt("KeyDrawer")
	if keyDrawerPrompt then
		keyDrawerPrompt.Enabled = true
	end
	applyLighting(0)
end

local function teleportToSpawn(player)
	local character = player.Character
	if not character then
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root then
		root.AssemblyLinearVelocity = Vector3.zero
		root.CFrame = CFrame.new(SPAWN_POSITION)
	end
end

RequestStart.OnServerEvent:Connect(function(player)
	local state = playerState[player]
	if not state then
		return
	end
	state.started = true
	state.objective = Config.OBJECTIVES.start
	teleportToSpawn(player)
	ShowMemory:FireClient(player, Config.NOTE_TITLE, Config.NOTE_TEXT)
	sendHUD(player)
end)

RestartGame.OnServerEvent:Connect(function(player)
	playerState[player] = newState()
	resetWorld()
	teleportToSpawn(player)
	ShowTitle:FireClient(player)
end)

local function initPlayer(player)
	playerState[player] = newState()
	player.CharacterAdded:Connect(function()
		task.wait(0.2)
		local state = playerState[player]
		if state and state.started then
			teleportToSpawn(player)
		end
	end)
end

Players.PlayerAdded:Connect(initPlayer)
for _, player in ipairs(Players:GetPlayers()) do
	initPlayer(player)
end
Players.PlayerRemoving:Connect(function(player)
	playerState[player] = nil
end)

applyLighting(0)

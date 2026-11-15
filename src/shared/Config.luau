-- The Last Signature: every line of story text lives here, so the server
-- and the client never duplicate a string. Tuning first, story second.

local Config = {}

-- The code that opens the locked study drawer. The photograph is dated 1962.
Config.DATE_CODE = "1962"

-- How many memories the player must hold to face the truth in the secret room.
Config.MEMORIES_FOR_TRUTH = 3

-- How many memories exist in total.
Config.MEMORY_TOTAL = 5

-- The envelope waiting by the front door. Shown when the player reads it.
Config.NOTE_TITLE = "The Envelope"
Config.NOTE_TEXT = "There is one thing I never told you.\n\nFind the room behind the blue door.\n\n— Elena"

-- Five memories. Each is found by interacting with one object in the house.
-- id is the part name the server looks for; counted memories raise the HUD.
Config.MEMORIES = {
	photograph = {
		title = "Memory 1 — The Photograph",
		text = "Summer, 1962. Two sisters on the porch of this house, arms linked, laughing at something the camera never caught.\n\nElena and Mara. One house. A promise neither of them kept.",
	},
	letter = {
		title = "Memory 2 — The Letter",
		text = "\"If you sign it, the house is yours. But you will carry it.\"\n\nMara's unsent letter, folded and refolded a hundred times. She never sent it. Elena read it anyway — the creases say she read it for years.",
	},
	watch = {
		title = "Memory 3 — The Broken Watch",
		text = "The watch stopped at the hour Mara left.\n\nElena stood at this window and watched her sister walk down the drive, suitcase in hand, and did not call her back.",
	},
	telephone = {
		title = "Memory 4 — The Last Call",
		text = "Elena picks up the phone. Mara's voice, older now, tired.\n\n\"I forgive you,\" Mara says. \"But I will not come home.\"\n\nThen silence. Elena held the receiver for a long time after.",
	},
	pen = {
		title = "Memory 5 — The Pen",
		text = "The pen Elena used to sign.\n\nHer hand shook over the will. One signature, and the house passed to her family instead of Mara's. She told herself it was for the best. She never believed it.",
	},
}

-- The will, found in the locked drawer. Reading it opens the secret room.
Config.WILL_TITLE = "The Will"
Config.WILL_TEXT = "The will, in Elena's hand. Mara's name has been crossed out — and written back in, in the same ink, many years later.\n\nUnderneath, a single line: \"I was wrong. Let the one who comes after me choose.\""

-- Short hint lines the server shows when the player tries something too early.
Config.HINTS = {
	needPhotograph = "The drawer is stuck. Something about that photograph on the wall... it feels like the key to this.",
	needKey = "Locked. The blue door needs a key.",
	needWill = "Another door, hidden behind the first. Something in this house must open it.",
	wrongCode = "Wrong code. The photograph is dated 1962 — the year it all began.",
	gotKey = "Inside the drawer: an old brass key. It feels warm, as if it has been waiting.",
	doorOpen = "The blue door swings open.",
	secretOpen = "The will's last line was an instruction. A hidden door slides open.",
}

-- The three choices. option ids are what the client sends back.
Config.CHOICES = {
	letter = {
		question = "The letter is addressed to Mara, but it was never sent. Do you open it?",
		options = {
			{ id = "open", label = "Open it" },
			{ id = "leave", label = "Leave it alone" },
		},
	},
	telephone = {
		question = "The telephone rings. Nobody has called this house in years.",
		options = {
			{ id = "answer", label = "Answer it" },
			{ id = "ignore", label = "Ignore it" },
		},
	},
	final = {
		question = "The truth is yours now. Elena left the choice to you. What do you do with her signature?",
		options = {
			{ id = "forgive", label = "Forgive" },
			{ id = "expose", label = "Expose" },
			{ id = "protect", label = "Protect" },
		},
	},
}

-- What the player sees when they leave the letter or ignore the phone.
Config.CHOICE_FALLOUT = {
	letterLeave = {
		title = "You leave the letter",
		text = "You set it back down, unopened. Some truths can wait — but they do not go away. The house feels a little colder.",
	},
	phoneIgnore = {
		title = "You let it ring",
		text = "The ringing stops. Whatever it was, it is gone now. You will never know whose voice it was.",
	},
}

-- The four endings. Each is shown full-screen with a Restart button.
Config.ENDINGS = {
	acceptance = {
		title = "Ending 1 — Acceptance",
		lines = {
			"You forgive Elena. She was afraid, and she was wrong, and she spent the rest of her life sorry.",
			"You place Mara's photograph beside Elena's on the mantel. Two sisters, home at last.",
			"The house is yours. This time, it is honestly yours.",
		},
	},
	truth = {
		title = "Ending 2 — The Truth",
		lines = {
			"You expose the forgery. The will is overturned, and the house passes to Mara's family, as it should have all along.",
			"It costs you the inheritance. It buys back the truth.",
			"Elena's secret is finally, at last, over.",
		},
	},
	signature = {
		title = "Ending 3 — The Signature",
		lines = {
			"You take up the pen and sign a new will, restoring Mara's name.",
			"You give up the house to protect her memory. Some signatures are worth more than what they sign away.",
			"The last signature in this house is finally an honest one.",
		},
	},
	unfinished = {
		title = "Ending 4 — The Unfinished Story",
		lines = {
			"You stand in the secret room, but you found too little to understand what you are looking at.",
			"The signature means nothing to you. The note means nothing. You leave, and the house keeps its secret.",
			"Some stories end because nobody stayed to finish them.",
		},
	},
}

-- The objective line shown at the top of the screen as the story advances.
Config.OBJECTIVES = {
	start = "Find the room behind the blue door.",
	photograph = "Something is hidden in the living room. Look closer.",
	key = "The old key opens the blue door.",
	blueDoor = "Enter the hidden room.",
	will = "The will is hidden in the study. The photograph holds the code.",
	secret = "Enter the secret room.",
	final = "Choose what the signature means.",
	done = "The story is yours now.",
}

return Config

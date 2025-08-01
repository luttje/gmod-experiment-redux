local PLUGIN = PLUGIN

local function filledcircle(x, y, radius, seg)
	local cir = {}

	table.insert(cir, {
		x = x,
		y = y,
		u = 0.5,
		v = 0.5
	})

	for i = 0, seg do
		local a = math.rad((i / seg) * -360)

		table.insert(cir, {
			x = x + math.sin(a) * radius,
			y = y + math.cos(a) * radius,
			u = math.sin(a) / 2 + 0.5,
			v = math.cos(a) / 2 + 0.5
		})
	end

	local a = math.rad(0)

	table.insert(cir, {
		x = x + math.sin(a) * radius,
		y = y + math.cos(a) * radius,
		u = math.sin(a) / 2 + 0.5,
		v = math.cos(a) / 2 + 0.5
	})

	surface.DrawPoly(cir)
end

local function slicedcircle(x, y, radius, seg, ang0, ang1)
	local cir = {}

	ang0 = ang0 + 90
	ang1 = ang1 + 90

	local arcseg = math.Round(360 / math.abs(ang1 - ang0) * seg)

	table.insert(cir, {
		x = x,
		y = y,
		u = 0.5,
		v = 0.5
	})

	for i = 0, arcseg do
		local a = math.rad((i / arcseg) * -math.abs(ang1 - ang0) + ang0)

		table.insert(cir, {
			x = x + math.sin(a) * radius,
			y = y + math.cos(a) * radius,
			u = math.sin(a) / 2 + 0.5,
			v = math.cos(a) / 2 + 0.5
		})
	end

	surface.DrawPoly(cir)
end

SWEP.GrenadeMenuAlpha = 0
SWEP.BlindFireMenuAlpha = 0

PLUGIN.CursorEnabled = false

local currentnade
local currentind
local lastmenu
function SWEP:DrawGrenadeHUD()
	if not PLUGIN.ConVars["nademenu"]:GetBool() then return end
	if not self:GetValue("CanQuickNade") then return end

	-- adapted from tfa vox radial menu
	local nades = self:GetAvailableGrenades(false)
	local scrw = ScrW()
	local scrh = ScrH()
	local r = PLUGIN.SS(128)
	local r2 = PLUGIN.SS(40)
	local sg = PLUGIN.SS(32)
	local ri = r * 0.667
	local arcdegrees = 360 / math.max(1, #nades)
	local d = 360
	local ft = FrameTime()

	local cursorx, cursory = input.GetCursorPos()
	local mouseangle = math.deg(math.atan2(cursorx - scrw / 2, cursory - scrh / 2))
	local mousedist = math.sqrt(math.pow(cursorx - scrw / 2, 2) + math.pow(cursory - scrh / 2, 2))
	mouseangle = math.NormalizeAngle(360 - (mouseangle - 90) + arcdegrees)
	if mouseangle < 0 then
		mouseangle = mouseangle + 360
	end

	if self:GetOwner():KeyDown(self.GrenadeMenuKey) and not self:GetPrimedGrenade() and self.BlindFireMenuAlpha == 0 and self:GetHolsterTime() == 0 then
		self.GrenadeMenuAlpha = math.Approach(self.GrenadeMenuAlpha, 1, 15 * ft)
		if not lastmenu then
			gui.EnableScreenClicker(true)
			PLUGIN.CursorEnabled = true
			lastmenu = true
		end

		if mousedist > r2 then
			local i = math.floor(mouseangle / arcdegrees) + 1
			currentnade = nades[i]
			currentind = i
		else
			currentnade = self:GetGrenade()
			currentind = nil
		end
		self.GrenadeMenuHighlighted = currentind
	else
		self.GrenadeMenuAlpha = math.Approach(self.GrenadeMenuAlpha, 0, -10 * ft)
		if lastmenu then
			if not self:GetCustomize() then
				gui.EnableScreenClicker(false)
				PLUGIN.CursorEnabled = false
			end
			if currentnade then
				if currentnade.Index ~= self:GetGrenade().Index then
					self:GetOwner():EmitSound("tacrp/weapons/grenade/roll-" .. math.random(1, 3) .. ".wav")
				end
				net.Start("tacrp_togglenade")
				net.WriteUInt(currentnade.Index, 4)
				net.WriteBool(false)
				net.SendToServer()
				self.Secondary.Ammo = currentnade.Ammo or "none"
			end
			lastmenu = false
		end
	end

	if self.GrenadeMenuAlpha <= 0 then
		return
	end

	local a = self.GrenadeMenuAlpha
	local col = Color(255, 255, 255, 255 * a)

	surface.DrawCircle(scrw / 2, scrh / 2, r, 255, 255, 255, a * 255)

	surface.SetDrawColor(0, 0, 0, a * 200)
	draw.NoTexture()
	filledcircle(scrw / 2, scrh / 2, r, 32)

	if #nades == 0 then
		local nadetext = "NO GRENADES AVAILABLE"
		surface.SetFont("TacRP_HD44780A00_5x8_8")
		local nadetextw = surface.GetTextSize(nadetext)
		surface.SetTextPos(scrw / 2 - nadetextw * 0.5, scrh / 2 + PLUGIN.SS(6))
		surface.DrawText(nadetext)
		return
	end

	surface.SetDrawColor(150, 150, 150, a * 100)
	draw.NoTexture()
	if currentind then
		local i = currentind
		local d0 = 0 - arcdegrees * (i - 2)
		slicedcircle(scrw / 2, scrh / 2, r, 32, d0, d0 + arcdegrees)
	else
		filledcircle(scrw / 2, scrh / 2, r2, 32)
	end

	surface.SetDrawColor(0, 0, 0, a * 255)
	surface.DrawCircle(scrw / 2, scrh / 2, r2, 255, 255, 255, a * 255)

	for i = 1, #nades do
		local rad = math.rad(d + arcdegrees * 0.5)

		surface.SetDrawColor(255, 255, 255, a * 255)
		surface.DrawLine(
			scrw / 2 + math.cos(math.rad(d)) * r2,
			scrh / 2 - math.sin(math.rad(d)) * r2,
			scrw / 2 + math.cos(math.rad(d)) * r,
			scrh / 2 - math.sin(math.rad(d)) * r)

		local nadex, nadey = scrw / 2 + math.cos(rad) * ri, scrh / 2 - math.sin(rad) * ri
		local nade = nades[i]

		local qty = nil --"INF"

		if nade.Singleton then
			qty = self:GetOwner():HasWeapon(nade.GrenadeWep) and 1 or 0
		elseif not PLUGIN.IsGrenadeInfiniteAmmo(nade.Index) then
			qty = self:GetOwner():GetAmmoCount(nade.Ammo)
		end

		if not qty or qty > 0 then
			surface.SetDrawColor(255, 255, 255, a * 255)
			surface.SetTextColor(255, 255, 255, a * 255)
		else
			surface.SetDrawColor(175, 175, 175, a * 255)
			surface.SetTextColor(175, 175, 175, a * 255)
		end

		if nade.Icon then
			surface.SetMaterial(nade.Icon)
			surface.DrawTexturedRect(nadex - sg * 0.5, nadey - sg * 0.5 - PLUGIN.SS(8), sg, sg)
		end
		local nadetext = nade.PrintName .. (qty and ("x" .. qty) or "")
		surface.SetFont("TacRP_HD44780A00_5x8_8")
		local nadetextw = surface.GetTextSize(nadetext)
		surface.SetTextPos(nadex - nadetextw * 0.5, nadey + PLUGIN.SS(6))
		surface.DrawText(nadetext)

		d = d - arcdegrees
	end

	local nade = currentnade
	if nade.Icon then
		surface.SetMaterial(nade.Icon)
		surface.SetDrawColor(255, 255, 255, a * 255)
		surface.DrawTexturedRect(scrw / 2 - sg * 0.5, scrh / 2 - sg * 0.5 - PLUGIN.SS(8), sg, sg)
	end

	local nadetext = nade.PrintName
	surface.SetFont("TacRP_HD44780A00_5x8_8")
	local nadetextw = surface.GetTextSize(nadetext)
	surface.SetTextPos(scrw / 2 - nadetextw * 0.5, scrh / 2 + PLUGIN.SS(6))
	surface.SetTextColor(255, 255, 255, a * 255)
	surface.DrawText(nadetext)

	if not PLUGIN.IsGrenadeInfiniteAmmo(nade.Index) then
		local qty
		if nade.Singleton then
			qty = self:GetOwner():HasWeapon(nade.GrenadeWep) and "x1" or "x0"
		else
			qty = "x" .. tostring(self:GetOwner():GetAmmoCount(nade.Ammo))
		end
		surface.SetFont("TacRP_HD44780A00_5x8_8")
		local qtyw = surface.GetTextSize(qty)
		surface.SetTextPos(scrw / 2 - qtyw * 0.5, scrh / 2 + PLUGIN.SS(16))
		surface.SetTextColor(255, 255, 255, a * 255)
		surface.DrawText(qty)
	end

	-- description box is blocked in customize
	if self:GetCustomize() then return end

	local w, h = PLUGIN.SS(96), PLUGIN.SS(128)
	local tx, ty = scrw / 2 + r + PLUGIN.SS(16), scrh / 2

	-- full name

	surface.SetDrawColor(0, 0, 0, 200 * a)
	PLUGIN.DrawCorneredBox(tx, ty - h * 0.5 - PLUGIN.SS(28), w, PLUGIN.SS(24), col)
	surface.SetTextColor(255, 255, 255, a * 255)

	local name = nade.FullName or nade.PrintName
	surface.SetFont("TacRP_Myriad_Pro_16")
	local name_w, name_h = surface.GetTextSize(name)
	if name_w > w then
		surface.SetFont("TacRP_Myriad_Pro_14")
		name_w, name_h = surface.GetTextSize(name)
	end
	surface.SetTextPos(tx + w / 2 - name_w / 2, ty - h * 0.5 - PLUGIN.SS(28) + PLUGIN.SS(12) - name_h / 2)
	surface.DrawText(name)


	-- Description

	surface.SetDrawColor(0, 0, 0, 200 * a)
	PLUGIN.DrawCorneredBox(tx, ty - h * 0.5, w, h, col)

	surface.SetFont("TacRP_Myriad_Pro_8")
	surface.SetTextPos(tx + PLUGIN.SS(4), ty - h / 2 + PLUGIN.SS(2))
	surface.DrawText("FUSE:")

	surface.SetFont("TacRP_Myriad_Pro_8")
	surface.SetTextPos(tx + PLUGIN.SS(4), ty - h / 2 + PLUGIN.SS(10))
	surface.DrawText(nade.DetType or "")

	surface.SetFont("TacRP_Myriad_Pro_8")
	surface.SetTextPos(tx + PLUGIN.SS(4), ty - h / 2 + PLUGIN.SS(22))
	surface.DrawText("DESCRIPTION:")

	surface.SetFont("TacRP_Myriad_Pro_8")

	if nade.Description then
		nade.DescriptionMultiLine = PLUGIN.MultiLineText(nade.Description or "", w - PLUGIN.SS(7), "TacRP_Myriad_Pro_8")
	end

	surface.SetTextColor(255, 255, 255, a * 255)
	for i, text in ipairs(nade.DescriptionMultiLine) do
		surface.SetTextPos(tx + PLUGIN.SS(4), ty - h / 2 + PLUGIN.SS(30) + (i - 1) * PLUGIN.SS(8))
		surface.DrawText(text)
	end

	surface.SetFont("TacRP_Myriad_Pro_8")
	surface.SetDrawColor(0, 0, 0, 200 * a)

	-- Only use the old bind hints if current hint is disabled
	if PLUGIN.ConVars["hints"]:GetBool() then
		self.LastHintLife = CurTime()
		return
	end

	if PLUGIN.ConVars["nademenu_click"]:GetBool() then
		local binded = input.LookupBinding("grenade1")

		PLUGIN.DrawCorneredBox(tx, ty + h * 0.5 + PLUGIN.SS(2), w, PLUGIN.SS(binded and 36 or 28), col)

		surface.SetTextPos(tx + PLUGIN.SS(4), ty + h / 2 + PLUGIN.SS(4))
		surface.DrawText("[LMB] - Throw Overhand")
		surface.SetTextPos(tx + PLUGIN.SS(4), ty + h / 2 + PLUGIN.SS(12))
		surface.DrawText("[RMB] - Throw Underhand")
		if binded then
			surface.SetTextPos(tx + PLUGIN.SS(4), ty + h / 2 + PLUGIN.SS(20))
			surface.DrawText("Hold/Tap [" .. PLUGIN.GetBind("grenade1") .. "] - Over/Under")
		end
		if PLUGIN.AreTheGrenadeAnimsReadyYet then
			surface.SetTextPos(tx + PLUGIN.SS(4), ty + h / 2 + PLUGIN.SS(28))
			surface.DrawText("[MMB] - Pull Out Grenade")
		end
	else
		PLUGIN.DrawCorneredBox(tx, ty + h * 0.5 + PLUGIN.SS(2), w, PLUGIN.SS(28), col)

		surface.SetTextPos(tx + PLUGIN.SS(4), ty + h / 2 + PLUGIN.SS(4))
		surface.DrawText("Hold [" .. PLUGIN.GetBind("grenade1") .. "] - Throw Overhand")
		surface.SetTextPos(tx + PLUGIN.SS(4), ty + h / 2 + PLUGIN.SS(12))
		surface.DrawText("Tap [" .. PLUGIN.GetBind("grenade1") .. "] - Throw Underhand")

		if PLUGIN.AreTheGrenadeAnimsReadyYet then
			surface.SetTextPos(tx + PLUGIN.SS(4), ty + h / 2 + PLUGIN.SS(20))
			surface.DrawText("[MMB] - Pull Out Grenade")
		end
	end
end

local mat_none = Material("tacrp/blindfire/none.png", "smooth")
local mat_wall = Material("tacrp/blindfire/wall.png", "smooth")
local bf_slices = {
	{ PLUGIN.BLINDFIRE_RIGHT, mat_wall,                                          270 },
	{ PLUGIN.BLINDFIRE_KYS,   Material("tacrp/blindfire/suicide.png", "smooth"), 0 },
	{ PLUGIN.BLINDFIRE_LEFT,  mat_wall,                                          90 },
	{ PLUGIN.BLINDFIRE_UP,    mat_wall,                                          0 },
}
local bf_slices2 = {
	{ PLUGIN.BLINDFIRE_RIGHT, mat_wall, 270 },
	{ PLUGIN.BLINDFIRE_LEFT,  mat_wall, 90 },
	{ PLUGIN.BLINDFIRE_UP,    mat_wall, 0 },
}
local bf_slices3 = {
	{ PLUGIN.BLINDFIRE_RIGHT, mat_wall, 270 },
	{ PLUGIN.BLINDFIRE_NONE,  mat_none, 0 },
	{ PLUGIN.BLINDFIRE_LEFT,  mat_wall, 90 },
	{ PLUGIN.BLINDFIRE_UP,    mat_wall, 0 },
}
local lastmenu_bf
local bf_suicidelock
local bf_funnyline
local bf_lines = {
	"Go ahead, see if I care.",
	"Why not just killbind?",
	"But you have so much to live for!",
	"Just like Hemingway.",
	"... NOW!",
	"DO IT!",
	"Now THIS is realism.",
	"See you in the next life!",
	"Time to commit a little insurance fraud.",
	"Don't give them the satisfaction.",
	"Why not jump off a building instead?",
	"Ripperoni in pepperoni.",
	"F",
	"L + ratio + you're a minge + touch grass",
	"You serve NO PURPOSE!",
	"type unbindall in console",
	"Citizens aren't supposed to have guns.",
	"I have decided that I want to die.",
	"What's the point?",
	"eh",
	"not worth",
	"Just like Hitler.",
	"Kill your own worst enemy.",
	"You've come to the right place.",
	"Don't forget to like and subscribe",
	"noooooooooooooo",
	"tfa base sucks lololololol",
	"The HUD is mandatory.",
	"No Bitches?",
	"now you have truly become garry's mod",
	"type 'tacrp_rock_funny 1' in console",
	"is only gaem, y u haev to be mad?",
	"And so it ends.",
	"Suicide is badass!",
	"Stop staring at me and get to it!",
	"you like kissing boys don't you",
	"A most tactical decision.",
	"Bye have a great time!",
	"Try doing this with the Dual MTX!",
	"Try doing this with the RPG-7!",
	"sad",
	"commit sudoku",
	"kermit suicide",
	"You can disable this button in the options.",
	"Goodbye, cruel world!",
	"Adios!",
	"Sayonara, [------]!",
	"Nice boat!",
	"I find it quite Inconceievable!",
	"Delete system32.dll",
	"Press ALT+F4 for admin gun",
	"AKA: Canadian Medkit",
	"The coward's way out",
	"No man lives forever.",
	"Goodbye, cruel world.",
	"Doing this will result in an admin sit",
	"Do it, before you turn.",
	"Your HUD Buddy will miss you.",
	"1-800-273-8255: Suicide and Crisis Support",
	"Guaranteed dead or your money back!",
	"Free health restore",
	"For best results, make a scene in public",
	"What are you, chicken?",
	"Don't pussy out NOW",
	"-1 Kill",
	"You COULD type 'kill' in console",
	"You know, back before all this started, me and my buddy Keith would grab a couple of .25s, piss tiny little guns, and take turns down by the river shootin' each other in the forehead with 'em. Hurt like a motherfucker, but we figured if we kept going, we could work our way up to bigger rounds, and eventually, ain't nothin' gon' be able to hurt us no more. Then we moved up to .22 and... well, let's just say I didn't go first.",
	"How many headshots can YOU survive?",
	"Shoot yourself in the head CHALLENGE",
	"The only remedy to admin abuse",
	"Try doing this with the Riot Shield!",
	"Too bad you can't overcook nades",
	"It's incredible you can survive this",
	"Physics-based suicide",
	"Sheep go to Heaven; goats go to Hell.",
	"Nobody will be impressed.",
	"You have a REALLY tough skull",
	"Think about the clean-up",
	"Canadian Healthcare Edition",
	"A permanent solution to a temporary problem.",
	"At least take some cops with you",
	"Don't let them take you alive!",
	"Teleport to spawn!",
	"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
	"THE VOICES TOLD ME TO DO IT",
	"Equestria awaits.",
	"Truck-Kun sends you to Heaven. Gun-San sends you to Hell.",
	"40,000 men and women everyday",
	"And it's all YOUR fault!",
	"YOU made me do this!",
	"AAA quality game design",
	"Stream it on TikTok!",
	"This button is banned in Russia",
	"Was it ethical to add this? No. But it was funny.",
	"Wrote amazing eulogy, couldn't wait for funeral",
	"It's gonna be a closed casket for you I think",
	"A shitpost in addon form",
	"More fun than working on ARC9",
	"A final rebellion against an indifferent world.",
	"Probably part of an infinite money exploit",
	"You're not a real gamer until you've done this",
	"We call this one the Detroit Cellphone",
	"Do a backflip!",
	"Do it for the Vine",
	"Show it to your mother",
	"To kill for yourself is murder. To kill yourself is hilarious.",
	"This is all your fault.",
	"Life begins at the other side of despair.",
	"You are still a good person.",
	"Reports of my survival have been greatly exaggerated.",
	"Home? We can't go home.",
	"No matter what happens next, don't be too hard on yourself.",
	"There is no escape.",
	"Is this really what you want, Walker? So be it.",
	"We call this one the Devil's Haircut",
	"Open your mind",
	"Edgy jokes for dumbass teens",
	"The fun will be endless",
	"The living will envy the dead",
	"There is only darkness.",
	"There is nothing on the other side.",
	"Is this how you get your kicks?",
	"ngl this is how I feel when I log on to a server and see m9k",
	"Administer straight to forehead",
	"No tactical advantages whatsoever.",
	"The best is yet to come",
	"I know what you did, Mikey.",
	"AMONG US AMONG US AMONG US AMONG US",
	"What would your waifu think?",
	"You won't get to see her, you know.",
	"ez",
	"Ehh... it's ez",
	"So ez it's hard to believe",
	"As shrimple as that",
	"Well, I won't try and stop you",
	"Send it to your favorite Youtubers",
	"SHED YOUR BODY FREE YOUR SOUL",
	"Suicide is illegal because you're damaging government property.",
	"ESCAPE THE SIMULATION",
	"Classic schizoposting",
	"See you in Hell",
	"The person you are most likely to kill is yourself.",
	"There will be no encore.",
	"Can't you pick a less messy method?",
	"Just like Jeffrey Epstein... *snort*",
	"The enemy. Shoot the enemy.",
	"Let's see you do this on M9K",
	"You won't do it, you pussy.",
	"Ka-POW!",
	"Bam-kerchow!",
	"Zoop!",
	"Zycie jest bez sensu i wszyscy zginemy",
	"We really shouldn't be encouraging this.",
	"You'll never see all the quotes",
	"When the going gets tough, the tough get going",
	"Acute cerebral lead poisoning",
	"Those bullets are laced with estrogen, you know",
	"google en passant",
	"And then he sacrificed... THE PLAYERRRRRRRRRRR",
	"You should grow and change as a person",
	"dont leave me </3",
	"Nyoooom~",
	"yeah take that fat L",
	"not very ez now is it",
	"You'll never live to see the day TF2 gets updated.",
	"go commit die",
	"oof",
	"早死早超生",
	"-800 social credit 干得好",
	"So long, and thanks for all the tactical realism!",
	"THE END IS NEVER THE END IS NEVER THE END IS NEVER THE END IS NEVER THE END IS NEVER THE END IS NEVER THE END IS NEVER THE END IS NEVER THE END IS NEVER THE END IS NEVER",
	"Dying a virgin?",
	"Error: Quip not found.",
	"Do it, I dare you.",
	"If you're reading this, they trapped me at the quip factory and they're forcing me to write these. Please send help.",
	"I'm not locked in here with you. You're locked in here with me.",
	"Only one bullet left. Not for the enemy.",
	"Preferable to surrender.",
	"Such a beautiful death.",
	"See you later. Wait, actually...",
	"You're not going to like what happens next.",
	"Remember that you are loved.",
	"Whoever retreats, I'll shoot. If someone gets injured, there will be no rescue. I'll just finish him off.",
	"I'm not going to die. I'm going to find out if I'm really alive.",
	"Have a nice life.",
	"One less murderer.",
	"There is no evidence showing that Russian Roulette was ever actually played in Russia.",
	"Don't you have anything better to do?",
	"Pre-order a video game, so you'll live to see it release.",
	"Sorry, I just don't feel like it today.",
	"No, please. Don't.",
	"Blind fire backwards",
	"At least you can't miss",
	"And for my final magic trick...",
	"Take your own life, so they won't take it from you.",
	"Never point a gun at anything you aren't willing to destroy.",
	"Lower the gunnot No, higher... there, that's the cerebellum.",
	"It'll hurt, but only for a moment.",
	"Goodness, imagine if you survive.",
	"Such a waste of life.",
	"None of it meant anything to me.",
	"Escape the Matrix.",
	"Death shall be a great adventure.",
	"Give me liberty, or give me death.",
	"I never wanted to grow old anyway.",
	"All debts must be repaid.",
	"Eros and Thanatos.",
	"Adults only.",
	"You must be 18 or above to click this button.",
	"Hey, what's up guys? It's your boy, back again for another EPIC Garry's Mod video.",
	"That's just crazy, man. For real.",
	"This is the only way to free your soul.",
	"Hey, come on, we can talk about this.",
	"One day you're alive, the next...",
	"But... why?",
	"Lived as he died; a virgin.",
	"A very stupid decision.",
	"I'm not going to tell you what to do, but...",
	"You should do it.",
	"You're not going to do it, are you?",
	"Are you really just going to sit here and read all these quotes?",
	"Et tu, Brutus?",
	"We didn't like you anyway.",
	"You're not going to get away with this.",
	"You'll just respawn anyway.",
	"How do you know you're the same person you were yesterday?",
	"Scratch the itch at the back of your head.",
	"You're not going to get a second chance.",
	"Think of how much they'll miss you.",
	"They'll be sorry. They'll be REAL sorry.",
	"The train leaves the station every evening, 21:00.",
	"Put your finger on the eject button, see how alive it makes you feel.",
	"It's okay to kill yourself.",
	"I'm gonna blow my brains out. Gonna close this one final case and then *blam* -- I'm outta here.",
	"Looks like the circus left town, but the clowns are still here.",
	"Establish your authority.",
	"Everybody calm downnot This is only a demonstration!",
	"What in the name of fuck are you doing?",
	"I want to see where this is going.",
	"Be careful -- it's loaded.",
	"It tastes like iron and hell.",
	"These are my thoughts. This is my head.",
	"You will NEVER forget what happens in five seconds!",
	"Inside the small mechanism, you can hear a spring tensing up.",
	"There's this itch in the middle of your skull, where you've never reached. Never scratched...",
	"He's not gonna off himself, c'mon!",
	"Go ahead. Three, two...",
	"We can't have any fun if you kill yourself.",
	"I... don't know why she left you. You can still turn this around, come on.",
	"When the FISH is FUNNY",
	"A dog walked into a tavern and said, \"I can't see a thing. I'll open this one.\"",
	"This is how the revolution starts.",
	"Oh what fun it is to die on a one horse open sleigh",
	"But... I love you!",
	"Even now, the evil seed of what you have done germinates within you.",
	"How cliche.",
	"Oh, you can do better than THAT."
}

local function canhighlight(self, slice)
	if not self:GetValue("CanBlindFire") and self:GetValue("CanSuicide") then
		return not slice or
			slice[1] == PLUGIN.BLINDFIRE_NONE or slice[1] == PLUGIN.BLINDFIRE_KYS
	end
	return true
end

function SWEP:DrawBlindFireHUD()
	if not PLUGIN.ConVars["blindfiremenu"]:GetBool() then return end
	local nocenter = PLUGIN.ConVars["blindfiremenu_nocenter"]:GetBool()
	local nosuicide = nocenter or PLUGIN.ConVars["idunwannadie"]:GetBool()

	-- adapted from tfa vox radial menu
	local ft = FrameTime()
	local scrw = ScrW()
	local scrh = ScrH()
	local r = PLUGIN.SS(72)
	local r2 = PLUGIN.SS(24)
	local sg = PLUGIN.SS(32)
	local ri = r * 0.667
	local s = 45

	local slices = bf_slices
	if nocenter then
		slices = bf_slices3
	elseif nosuicide then
		slices = bf_slices2
		s = 90
	end
	if currentind and currentind > #slices then currentind = 0 end

	local arcdegrees = 360 / #slices
	local d = 360 - s

	local cursorx, cursory = input.GetCursorPos()
	local mouseangle = math.deg(math.atan2(cursorx - scrw / 2, cursory - scrh / 2))
	local mousedist = math.sqrt(math.pow(cursorx - scrw / 2, 2) + math.pow(cursory - scrh / 2, 2))
	if #slices == 3 then
		mouseangle = math.NormalizeAngle(360 - mouseangle + arcdegrees) -- ???
	else
		mouseangle = math.NormalizeAngle(360 - (mouseangle - s) + arcdegrees)
	end
	if mouseangle < 0 then
		mouseangle = mouseangle + 360
	end

	if (self:GetOwner():KeyDown(IN_ZOOM) or self:GetOwner().TacRPBlindFireDown) and self:CheckBlindFire(true) and self.GrenadeMenuAlpha == 0 then
		self.BlindFireMenuAlpha = math.Approach(self.BlindFireMenuAlpha, 1, 15 * ft)
		if not lastmenu_bf then
			gui.EnableScreenClicker(true)
			PLUGIN.CursorEnabled = true
			lastmenu_bf = true
			if self:GetBlindFireMode() == PLUGIN.BLINDFIRE_KYS then
				bf_suicidelock = 0
			else
				bf_suicidelock = 1
				bf_funnyline = nil
			end
		end

		if mousedist > r2 then
			local i = math.floor(mouseangle / arcdegrees) + 1
			currentind = i
		else
			currentind = 0
		end
	else
		self.BlindFireMenuAlpha = math.Approach(self.BlindFireMenuAlpha, 0, -10 * ft)
		if lastmenu_bf then
			if not self:GetCustomize() then
				gui.EnableScreenClicker(false)
				PLUGIN.CursorEnabled = false
			end
			if (not nocenter or currentind > 0) and (nosuicide or bf_suicidelock == 0 or currentind ~= 2) then
				net.Start("tacrp_toggleblindfire")
				net.WriteUInt(currentind > 0 and slices[currentind][1] or PLUGIN.BLINDFIRE_NONE, PLUGIN.BlindFireNetBits)
				net.SendToServer()
			end

			lastmenu_bf = false
		end
	end

	if self.BlindFireMenuAlpha <= 0 then
		return
	end

	local a = self.BlindFireMenuAlpha
	local col = Color(255, 255, 255, 255 * a)

	surface.DrawCircle(scrw / 2, scrh / 2, r, 255, 255, 255, a * 255)

	surface.SetDrawColor(0, 0, 0, a * 200)
	draw.NoTexture()
	filledcircle(scrw / 2, scrh / 2, r, 32)

	if currentind and canhighlight(self, slices[currentind]) then
		surface.SetDrawColor(150, 150, 150, a * 100)
		draw.NoTexture()
		if currentind > 0 then
			if not nosuicide and currentind == 2 and bf_suicidelock > 0 then
				surface.SetDrawColor(150, 50, 50, a * 100)
			end
			local d0 = -s - arcdegrees * (currentind - 2)
			slicedcircle(scrw / 2, scrh / 2, r, 32, d0, d0 + arcdegrees)
		else
			filledcircle(scrw / 2, scrh / 2, r2, 32)
		end
	end

	surface.SetDrawColor(0, 0, 0, a * 255)
	surface.DrawCircle(scrw / 2, scrh / 2, r2, 255, 255, 255, a * 255)

	for i = 1, #slices do
		local rad = math.rad(d + arcdegrees * 0.5)

		surface.SetDrawColor(255, 255, 255, a * 255)
		surface.DrawLine(
			scrw / 2 + math.cos(math.rad(d)) * r2,
			scrh / 2 - math.sin(math.rad(d)) * r2,
			scrw / 2 + math.cos(math.rad(d)) * r,
			scrh / 2 - math.sin(math.rad(d)) * r)

		local nadex, nadey = scrw / 2 + math.cos(rad) * ri, scrh / 2 - math.sin(rad) * ri

		if not canhighlight(self, slices[i]) or (not nosuicide and i == 2 and bf_suicidelock > 0) then
			surface.SetDrawColor(150, 150, 150, a * 200)
		end

		surface.SetMaterial(slices[i][2])
		surface.DrawTexturedRectRotated(nadex, nadey, sg, sg, slices[i][3])

		d = d - arcdegrees
	end

	if not nocenter then
		surface.SetDrawColor(255, 255, 255, a * 255)
		surface.SetMaterial(mat_none)
		surface.DrawTexturedRectRotated(scrw / 2, scrh / 2, PLUGIN.SS(28), PLUGIN.SS(28), 0)
	end

	if not nosuicide and currentind == 2 then
		local w, h = PLUGIN.SS(132), PLUGIN.SS(24)
		local tx, ty = scrw / 2, scrh / 2 + r + PLUGIN.SS(4)

		surface.SetDrawColor(0, 0, 0, 200 * a)
		PLUGIN.DrawCorneredBox(tx - w / 2, ty, w, h, col)
		surface.SetTextColor(255, 255, 255, a * 255)

		surface.SetFont("TacRP_Myriad_Pro_12")
		surface.SetTextColor(255, 255, 255, 255 * a)
		local t1 = "Shoot Yourself"
		local t1_w = surface.GetTextSize(t1)
		surface.SetTextPos(tx - t1_w / 2, ty + PLUGIN.SS(2))
		surface.DrawText(t1)

		surface.SetFont("TacRP_Myriad_Pro_6")
		local t2 = bf_funnyline or ""
		if bf_suicidelock > 0 then
			surface.SetFont("TacRP_Myriad_Pro_8")
			t2 = "[" .. PLUGIN.GetBind("attack") .. "] - Unlock"
		elseif not bf_funnyline then
			bf_funnyline = bf_lines[math.random(1, #bf_lines)]
		end
		local t2_w, t2_h = surface.GetTextSize(t2)
		surface.SetTextPos(tx - t2_w / 2, ty + PLUGIN.SS(18) - t2_h / 2)
		surface.DrawText(t2)
	end
end

hook.Add("VGUIMousePressed", "tacrp_grenademenu", function(pnl, mousecode)
	local wpn = LocalPlayer():GetActiveWeapon()
	if not (LocalPlayer():Alive() and IsValid(wpn) and wpn.ArcticTacRP and not wpn:StillWaiting(nil, true)) then return end
	if wpn.GrenadeMenuAlpha == 1 then
		if not PLUGIN.ConVars["nademenu_click"]:GetBool() or not currentnade then return end
		if mousecode == MOUSE_MIDDLE and PLUGIN.AreTheGrenadeAnimsReadyYet then
			local nadewep = currentnade.GrenadeWep
			if not nadewep or not wpn:CheckGrenade(currentnade.Index, true) then return end
			wpn.GrenadeMenuAlpha = 0
			gui.EnableScreenClicker(false)
			PLUGIN.CursorEnabled = false
			if LocalPlayer():HasWeapon(nadewep) then
				input.SelectWeapon(LocalPlayer():GetWeapon(nadewep))
			else
				net.Start("tacrp_givenadewep")
				net.WriteUInt(currentnade.Index, PLUGIN.QuickNades_Bits)
				net.SendToServer()
				wpn.GrenadeWaitSelect =
					nadewep -- cannot try to switch immediately as the nade wep does not exist on client yet
			end
		elseif mousecode == MOUSE_RIGHT or mousecode == MOUSE_LEFT then
			wpn.GrenadeThrowOverride = mousecode == MOUSE_RIGHT
			net.Start("tacrp_togglenade")
			net.WriteUInt(currentnade.Index, PLUGIN.QuickNades_Bits)
			net.WriteBool(true)
			net.WriteBool(wpn.GrenadeThrowOverride)
			net.SendToServer()
			wpn.Secondary.Ammo = currentnade.Ammo or "none"
		end
	elseif wpn.BlindFireMenuAlpha == 1 then
		if mousecode == MOUSE_LEFT and currentind == 2 then
			bf_suicidelock = bf_suicidelock - 1
		end
	end
end)

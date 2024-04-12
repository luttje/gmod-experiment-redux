local ITEM = ITEM

ITEM.name = "Arriane's Diary"
ITEM.model = Model("models/props_lab/binderblue.mdl")
ITEM.description = "A diary with a worn cover."
ITEM.chanceToScavenge = 2

function ITEM:GetText()
	return [[
		<b>Arrianne's Diary</b>
		Since my previous diary was destroyed, I've decided to start a new one. I don't know what's going on in this place, but I need to keep track of it. I need to keep track of everything that's happening (as long as I can).

		<b>Monday, 5th of June, 2045:</b>
		I've been working on a new type of material generator for the company the past weeks. They won't tell me what they'll use it for, but it's supposed to convert raw materials into energy...

		<b>Tuesday, 6th of June, 2045:</b>
		Breakfast, lunch, and dinner. That's all I do now. I work on the generator all day, every day.
		I can't shake the feeling that the company is hiding something from us. I've been working here for years, but I've never felt like I was doing the right thing. I'm afraid of what my colleagues are doing, there's experiments going on that I don't understand.

		<b>Wednesday, 7th of June, 2045:</b>
		I saw them construct a giant city out of nowhere. I don't know how they did it, but I know it's not right. I'm afraid of what they're doing, and I'm afraid of what I'm doing. I can't keep working here, I need to leave.

		<b>Thursday, 8th of June, 2045:</b>
		I saw a cat today. It was nice to see something normal for once.

		<b>Wednesday, 12th of July, 2045:</b>
		I've neglected my diary for a while. I saw them bring in a bunch of test subjects into the facility. They wouldn't tell us what they were for, but I know it's not good. I need to leave, but I don't know where to go.
		I'm afraid they'll bring them into that giant city. I don't know what they're planning, but I know it's not good.

		<b>Friday, 14th of July, 2045:</b>
		This is not okay, that city was filled with gun shots and screams. I can't stay here, I need to leave. I need to leave now.

		<b>Saturday, 15th of July, 2045:</b>
		I don't know where I'm going, but I can't stay here. I need to leave. I need to leave now.
	]]
end

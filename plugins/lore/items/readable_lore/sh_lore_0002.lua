local ITEM = ITEM

ITEM.name = "Construction Assignment"
ITEM.model = Model("models/props_c17/paper01.mdl")
ITEM.description = "A piece of paper with a list of construction assignments."
ITEM.chanceToScavenge = Schema.RARITY_SUPER_RARE

function ITEM:GetText()
	return [[
		<b>Construction Assignment - Fase 5</b>
		<ul>
			<li>Finalize branding of the shops. Make sure the signs are visible from the street.</li>
			<li>FOTO: This shop should contain furniture and decorations.</li>
			<li>Bakery: Displays will be trucked in on Monday.</li>
			<li>The bar: The bar should be finished by the end of the week.</li>
			<li>The apartments: The apartments should be finished by the end of the month.</li>
			<li>The hospital: The hospital should be finished by the end of the month.</li>
			<li><span class="censored w-16"></span><span class="censored w-4"></span><span class="censored w-24"></span><span class="censored w-5"></span><span class="censored w-8"></span></li>
			<li><span class="censored w-24"></span><span class="censored w-5"></span><span class="censored w-24"></span><span class="censored w-5"></span><span class="censored w-8"></span><span class="censored w-32"></span><span class="censored w-16"></span></li>
			<li><span class="censored w-24"></span><span class="censored w-5"></span><span class="censored w-8"></span><span class="censored w-32"></span><span class="censored w-4"></span><span class="censored w-24"></span></li>
			<li><span class="censored w-11"></span><span class="censored w-8"></span><span class="censored w-12"></span><span class="censored w-4"></span><span class="censored w-24"></span><span class="censored w-5"></span><span class="censored w-8"></span><span class="censored w-32"></span></li>
			<li><span class="censored w-4"></span><span class="censored w-9"></span><span class="censored w-5"></span><span class="censored w-8"></span></li>
		</ul>
	]]
end

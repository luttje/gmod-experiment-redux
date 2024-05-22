local DESCRIPTION_AGE_INDICATOR = {
	"Ageless",
	"Elderly",
	"Middle-aged",
	"Young",
	"Youthful",
}

local DESCRIPTION_BODY_TYPE_HEIGHT = {
	"%s of average height",
	"%s of medium height",
	"%s of short stature",
	"%s of tall stature",
	"and average height %s",
	"and short %s",
	"and tall %s",
	"extremely short %s",
	"extremely tall %s",
	"%s of diminutive height",
	"%s of towering height",
	"%s with a compact frame",
	"%s with a lanky build",
	"%s with a stocky build",
	"%s with a wiry build",
	"%s with a petite frame",
	"%s with a hulking frame",
	"%s of a slight stature",
	"%s of a robust build",
	"%s of a slender build",
	"%s of a muscular build",
	"%s of a gaunt frame",
	"%s of a hefty build",
	"%s of an imposing stature",
	"%s with a delicate build",
	"%s with a powerful build",
	"%s with a lithe build",
	"%s of a modest height",
	"%s of a colossal build",
	"and diminutive %s",
	"and towering %s",
	"of rather short stature %s",
	"of rather tall stature %s",
	"%s with an average build",
	"%s with a thin frame",
	"%s with a thickset build",
	"%s of a medium frame",
}

-- with...
local DESCRIPTION_BODY_TYPE_FRAME = {
	"a sleek body",
	"a tiny frame",
	"an athletic build",
	"a bulky frame",
	"a delicate frame",
	"a fit body",
	"a fragile frame",
	"a frail frame",
	"a gangly frame",
	"a lanky frame",
	"a petite frame",
	"a robust, strong body",
	"a scrawny frame",
	"a skinny frame",
	"a slender frame",
	"a slim frame",
	"a small frame",
	"a solid muscular frame",
	"a solid strong frame",
	"a solid, strong build",
	"a thin frame",
	"a toned physique",
	"dense muscles",
	"large muscles",
	"lean muscles",
}

-- They've got...
local DESCRIPTION_FACIAL_FEATURES = {
	"a broad face with a broken nose and a permanent scowl",
	"a broad face with a smirk",
	"a broad forehead and a fierce look",
	"a broad forehead with a stern frown",
	"a broad nose with a sneer",
	"a broad, flat face with a grimace",
	"a furrowed brow and a suspicious look",
	"a gaunt face with hollow cheeks",
	"a gaunt face with piercing eyes",
	"a gaunt with hollow cheeks and sunken eyes",
	"a gaunt, haunted face",
	"a grim expression with a prominent brow ridge",
	"a grim face with dark, hollow eyes",
	"a hardened face with a cold, calculating stare",
	"a hardened face with a cruel smile",
	"a heavy brow and a grimace",
	"a heavy brow with a fierce look",
	"a heavy-set face with a bushy mustache",
	"a heavy-set features with a cold stare",
	"a heavy-set jaw with a cynical smirk",
	"a narrow chin with a distrustful gaze",
	"a narrow, angular face with a stern expression",
	"a pale complexion with dark circles under the eyes",
	"a round face with freckles and a warm smile",
	"a rugged face with a cold stare",
	"a rugged face with a grim look",
	"a sallow complexion with a haunted demeanor",
	"a scarred face with a cruel smirk",
	"a scarred face with a missing ear",
	"a scarred skin with a grim look",
	"an angular face with a somber look",
	"an angular jaw with a scar running down one side",
	"an intense gaze with a furrowed brow",
	"broad cheeks with a stern expression",
	"chiseled cheekbones and a distant look",
	"chiseled face with a haunted gaze",
	"chiseled features with a stern demeanor",
	"chiseled jawline with a haunted expression",
	"deep-set eyes and a perpetual sneer",
	"deep-set eyes with a cold expression",
	"deep-set eyes with a haunted expression",
	"delicate features with a pained expression",
	"delicate features with a thin mouth",
	"delicate features with a wary look",
	"gaunt cheeks with a piercing gaze",
	"harsh features with a disinterested gaze",
	"heavy features with a stern glare",
	"heavy jowls and a menacing glare",
	"hollow cheeks with a distant gaze",
	"hollow eyes and a gaunt expression",
	"narrow eyes with a suspicious gaze",
	"narrow face with a calculating expression",
	"narrow face with a hollow stare",
	"narrow face with a hooked nose",
	"pale skin with a ghostly appearance",
	"piercing eyes with a determined look",
	"pockmarked skin and a crooked smile",
	"prominent cheekbones with a sad smile",
	"prominent forehead and a scowl",
	"prominent jaw with a grim smile",
	"rough features with a hardened gaze",
	"rough features with a weary look",
	"rough skin with a battle-hardened look",
	"rough skin with a determined look",
	"round cheeks with a deceptively gentle look",
	"sharp features with a cold smile",
}

local DESCRIPTION_TRAITS = {
	"On their temples, they have cybernetic implants",
	"They have a scar running across one eye",
	"Visible in the dark, they have bioluminescent tattoos",
	"Their arm is metallic with intricate designs",
	"They have heterochromia, with one blue eye and one green eye",
	"One of their ears is missing, replaced by a cybernetic implant",
	"Intricate scalp tattoos cover their bald head",
	"Half of their face is covered in burn scars",
	"They have a tattoo of a snake on their neck",
	"They have a tattoo of a skull on their neck",
	"They have a tattoo of a spider on their neck",
	"They have a tattoo of a scorpion on their neck",
	"Their fingers are replaced with cybernetic digits",
	"They have a robotic leg that whirs when they walk",
	"Their eyes are completely black, reflecting no light",
	"They have metal plates grafted to their skull",
	"Their voice is modulated by a vocal implant",
	"A web of glowing lines covers their arms",
	"They have a breathing apparatus integrated into their chest",
	"Their teeth are metallic, reflecting light eerily",
	"They wear a cloak made of dark, synthetic fibers",
	"Their skin is pale with a slight bluish tint",
	"They have a mechanical spider crawling on their shoulder",
	"One of their eyes is replaced with a red, glowing cybernetic eye",
	"Their hands are covered in burn scars",
	"They have a tattoo of a dragon coiling around their arm",
	"Their movements are unnaturally smooth, suggesting augmentation",
	"They have a set of mechanical wings folded on their back",
	"Their voice has a strange echo to it",
	"Their hair is silver and shimmers in the light",
	"They have a set of sharp, metallic claws instead of nails",
	"Their body is covered in small, hexagonal scales",
	"They have a digital display embedded in their forearm",
	"Their neck has a visible seam, suggesting replacement",
	"They have a tattoo of a phoenix on their chest",
	"Their left arm is a sleek, black cybernetic prosthetic",
	"Their eyes have a digital readout visible in the iris",
	"They have a small drone hovering around their head",
	"Their skin has a slight sheen, like polished stone",
	"They have a jagged scar running from their jaw to their collarbone",
	"Their voice is a low, gravelly growl",
	"They wear a mask that hides half of their face",
	"Their body is covered in cryptic, glowing symbols",
}

local DESCRIPTION_BEHAVIOR = {
	"They're constantly scanning surroundings with a cautious gaze",
	"Their hand is never far from their weapon",
	"They're tapping on a datapad while muttering calculations",
	"They stand with a confident, defiant stance",
	"They're fidgeting nervously and glancing over their shoulder",
	"They're moving with silent, predatory grace",
	"They speak in a calm, authoritative voice",
	"They're constantly adjusting their goggles",
	"Their eyes flicker with a mixture of fear and determination",
	"They're pacing back and forth, deep in thought",
	"Their fingers drum rhythmically on any available surface",
	"They're whispering into a hidden comm device",
	"They always stay close to the shadows",
	"Their posture is rigid, as if ready to spring into action",
	"They're analyzing everyone with a cold, calculating stare",
	"Their lips curl into a cynical smile",
	"They're constantly checking the time",
	"They emit a low, unsettling hum while working",
	"They're scratching at an old scar absentmindedly",
	"They're polishing a well-worn piece of equipment",
	"They're murmuring fragments of an old song",
	"Their eyes dart from face to face, never resting",
	"They're hunched over, concealing something in their hands",
	"They walk with a slight limp, barely noticeable",
	"They're muttering in an unknown language",
	"They chuckle darkly at inappropriate moments",
	"Their voice carries an edge of bitterness",
	"They're scanning the horizon with a far-off look",
	"They're adjusting the straps of their gear",
	"They constantly clean under their fingernails with a small knife",
	"They're repeatedly clenching and unclenching their fists",
	"They laugh nervously at the slightest provocation",
	"They're twisting a ring on their finger compulsively",
	"They sigh deeply, as if carrying a heavy burden",
	"They're meticulously organizing their belongings",
	"They're frequently adjusting their armor",
	"They rub their temples as if trying to ward off a headache",
	"They're chewing on the end of a pen or stylus",
}

return DESCRIPTION_AGE_INDICATOR,
    DESCRIPTION_BODY_TYPE_HEIGHT,
    DESCRIPTION_BODY_TYPE_FRAME,
    DESCRIPTION_FACIAL_FEATURES,
    DESCRIPTION_TRAITS,
	DESCRIPTION_BEHAVIOR

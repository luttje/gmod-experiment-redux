ATT.PrintName = "Holographic (1.5x)"

ATT.AdminOnly = false
ATT.InvAtt = ""
ATT.Free = false
ATT.Ignore = true

ATT.Icon = Material("")
ATT.Description = "Muzzle device that reduces audible report and spread."
ATT.Pros = {""}
ATT.Cons = {""}

ATT.Model = ""
ATT.WorldModel = "" // optional
ATT.Scale = 1
ATT.ModelOffset = Vector(0, 0, 0)

ATT.Category = "" // can be "string" or {"list", "of", "strings"}

ATT.ActivateElements = {""}

ATT.SortOrder = 0

// Sight stuff
// Allows a custom sight to be defined based on offset from the element's origin

ATT.SightPos = Vector(0, 0, 0)
ATT.SightAng = Angle(0, 0, 0)

// Stat modifications are completely automatically handled now.

// You can do Mult_ before a stat, e.g.:
// Mult_RPM
// Mult_Recoil
// Mult_ScopedSpreadPenalty
// In order to multiply the value.

// You can do Add_ in a similar way, which will add a value.

// There is also Override_, which works similarly.
// Override_Priority_ will do what you would expect.

ATT.Override_Scope = true
ATT.Override_ScopeOverlay = false
ATT.Override_ScopeFOV = 90 / 1.5
ATT.Override_ScopeLevels = 1
ATT.Override_ScopeHideWeapon = false

ATT.Mult_QuickScopeTime = 0.75
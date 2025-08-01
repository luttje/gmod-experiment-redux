SWEP.StatCache = {}
SWEP.HookCache = {}
SWEP.StatScoreCache = {} -- used by cust menu
SWEP.MiscCache = {}

SWEP.ExcludeFromRawStats = {
    ["FullName"] = true,
    ["PrintName"] = true,
    ["Description"] = true,
}

SWEP.IntegerStats = {
    ["ClipSize"] = true,
    ["Num"] = true,
}

SWEP.AllowNegativeStats = {
    ["RecoilKick"] = true,
}

function SWEP:InvalidateCache()
    self.StatCache = {}
    self.HookCache = {}
    self.StatScoreCache = {}
    self.MiscCache = {}
    self.RecoilPatternCache = {}

    self.AutoSightPos = nil
    self.AutoSightAng = nil
end

function SWEP:RunHook(val, data)
    if !self.HookCache[val] then
        self.HookCache[val] = {}

        if self:GetTable()[val] then
            table.insert(self.HookCache[val], self:GetTable()[val])
        end

        for slot, slottbl in pairs(self.Attachments) do
            if !slottbl.Installed then continue end

            local atttbl = TacRP.GetAttTable(slottbl.Installed)

            if atttbl[val] then
                table.insert(self.HookCache[val], atttbl[val])
            end
        end
    end

    for _, chook in pairs(self.HookCache[val]) do
        local d = chook(self, data)
        if d != nil then
            data = d
        end
    end

    data = hook.Run("TacRP_" .. val, self, data) or data

    return data
end

function SWEP:GetBaseValue(val)
    local stat = self:GetTable()[val]

    local b = TacRP.GetBalanceMode()
    if b > 0 and self.BalanceStats != nil then
        if TacRP.BalanceDefaults[b] and TacRP.BalanceDefaults[b][val] != nil then
            stat = TacRP.BalanceDefaults[b][val]
        end
        for j = b, 1, -1 do
            if self.BalanceStats[b] and self.BalanceStats[b][val] != nil then
                stat = self.BalanceStats[b][val]
                break
            end
        end
    end

    if isnumber(stat) then
        if self.IntegerStats[val] then
            stat = math.ceil(stat)
        end
        if !self.AllowNegativeStats[val] then
            stat = math.max(stat, 0)
        end
    end

    return stat
end

function SWEP:GetValue(val, static, invert)

    local cachei = invert and 2 or 1

    if static == nil then
        static = self.StaticStats
    end

    local stat = nil

    -- Generate a cache if it doesn't exist already
    if !self.StatCache[val] or !self.StatCache[val][cachei] then

        self.StatCache[val] = self.StatCache[val] or {}

        stat = self:GetBaseValue(val)

        local modifiers = {
            ["stat"] = nil, -- return this unless hook is set
            ["hook"] = nil, -- if set, always call hook and use the following values
            ["func"] = {}, -- modifying functions
            ["set"] = stat, -- override and no prefix
            ["prio"] = 0, -- override priority
            ["add"] = 0,
            ["mul"] = 1,
        }

        -- local priority = 0

        if !self.ExcludeFromRawStats[val] then
            for slot, slottbl in pairs(self.Attachments) do
                if !slottbl.Installed then continue end

                local atttbl = TacRP.GetAttTable(slottbl.Installed)

                local att_priority = atttbl["Priority_" .. val] or 1

                if atttbl[val] != nil and att_priority > modifiers.prio then
                    -- stat = atttbl[val]
                    -- priority = att_priority
                    modifiers.set = atttbl[val]
                    modifiers.prio = att_priority
                end
            end
        end

        for slot, slottbl in pairs(self.Attachments) do
            if !slottbl.Installed then continue end

            local atttbl = TacRP.GetAttTable(slottbl.Installed)

            local att_priority = atttbl["Override_Priority_" .. val] or 1

            if atttbl["Override_" .. val] != nil and att_priority > modifiers.prio then
                -- stat = atttbl["Override_" .. val]
                -- priority = att_priority
                modifiers.set = atttbl["Override_" .. val]
                modifiers.prio = att_priority
            end

            if atttbl["Add_" .. val] then -- isnumber(stat) and
                -- stat = stat + atttbl["Add_" .. val] * (invert and -1 or 1)
                modifiers.add = modifiers.add + atttbl["Add_" .. val] * (invert and -1 or 1)
            end

            if atttbl["Mult_" .. val] then -- isnumber(stat) and
                if invert then
                    -- stat = stat / atttbl["Mult_" .. val]
                    modifiers.mul = modifiers.mul / atttbl["Mult_" .. val]
                else
                    -- stat = stat * atttbl["Mult_" .. val]
                    modifiers.mul = modifiers.mul * atttbl["Mult_" .. val]
                end
            end

            if atttbl["Func_" .. val] then
                table.insert(modifiers.func, atttbl["Func_" .. val])
            end
        end

        -- Check for stat hooks. If any exist, we must call it whenever we try to get the stat.
        -- Cache this check so we don't unnecessarily call hook.Run a million times when nobody wants to hook us.
        if table.Count(hook.GetTable()["TacRP_Stat_" .. val] or {}) > 0 then
            modifiers.hook = true
        end

        -- Calculate the final value
        if isnumber(modifiers.set) then
            modifiers.stat = (modifiers.set + modifiers.add) * modifiers.mul
            if self.IntegerStats[val] then
                modifiers.stat = math.ceil(modifiers.stat)
            end
            if !self.AllowNegativeStats[val] then
                modifiers.stat = math.max(modifiers.stat, 0)
            end
        else
            modifiers.stat = modifiers.set
        end

        -- Cache our final value, presence of hooks, and summed modifiers
        self.StatCache[val][cachei] = modifiers
    end

    local cache = self.StatCache[val][cachei]
    if !static and (cache.hook or #cache.func > 0) then
        -- Run the hook
        -- Hooks are expected to modify "set", "prio", "add" and "mul", so we can do all calculations in the right order.
        local modifiers = {set = nil, prio = 0, add = 0, mul = 1}

        if #cache.func > 0 then
            for _, f in ipairs(cache.func) do
                f(self, modifiers)
            end
        end
        if cache.hook then
            hook.Run("TacRP_Stat_" .. val, self, modifiers)
            if !istable(modifiers) then modifiers = {set = nil, prio = 0, add = 0, mul = 1} end -- some hook isn't cooperating!
        end

        if modifiers.prio > cache.prio then
            stat = modifiers.set
        else
            stat = cache.set
        end

        if isnumber(stat) then
            if invert then
                stat = (stat - modifiers.add - cache.add) / modifiers.mul / cache.mul
            else
                stat = (stat + modifiers.add + cache.add) * modifiers.mul * cache.mul
            end

            if self.IntegerStats[val] then
                stat = math.ceil(stat)
            end
            if !self.AllowNegativeStats[val] then
                stat = math.max(stat, 0)
            end
        end
    else
        stat = cache.stat
    end

    return stat
end
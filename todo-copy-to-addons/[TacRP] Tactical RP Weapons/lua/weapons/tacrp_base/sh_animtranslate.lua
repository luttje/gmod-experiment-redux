function SWEP:TranslateSequence(seq)
    seq = self:RunHook("Hook_TranslateSequence", seq)

    seq = self.AnimationTranslationTable[seq] or seq

    if istable(seq) then
        seq["BaseClass"] = nil
        seq = seq[math.Round(util.SharedRandom("TacRP_animtr", 1, #seq))]
    end

    return seq
end

function SWEP:HasSequence(seq)
    seq = self:TranslateSequence(seq)
    local vm = self:GetVM()
    seq = vm:LookupSequence(seq)

    return seq != -1
end
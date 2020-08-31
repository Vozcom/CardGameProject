return function(Modules, ClientModules, Services)

	local module = {}
    local private = {}
    
    private.XP_Gap = 100 -- level * gap

    module.FunctionsOnJoin = {}
    function module.BindToJoin(f)
        table.insert(module.FunctionsOnJoin, f)
    end

    function module.GetMaxXP(levelReceived)
        local lvl = ((levelReceived > 1) and levelReceived) or 1
        return (lvl * private.XP_Gap)
    end

    function module.GetPetMaxXP(petClassId, levelReceived)

        local lvl = ((levelReceived > 1) and levelReceived) or 1
        local gap = 100 -- change later depending on pet class (make folder for each pet class)
        return (lvl * gap)
    end

    return module, private
end
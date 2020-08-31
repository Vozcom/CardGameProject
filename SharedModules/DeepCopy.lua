return function(SharedModules, Services, isServer)

	local module = {}
    function module.Copy(orig)
        local orig_type = type(orig)
        local copy
        if orig_type == 'table' then
            copy = {}
            for orig_key, orig_value in next, orig, nil do
                copy[module.Copy(orig_key)] = module.Copy(orig_value)
            end
            setmetatable(copy, module.Copy(getmetatable(orig)))
        else -- number, string, boolean, etc
            copy = orig
        end
        return copy
    end
    
    function module.Merge(template, updated)
        for i, v in pairs(template) do
            if updated[i] then
                template[i] = updated[i]
            end
        end
        return template
    end

	return module
end

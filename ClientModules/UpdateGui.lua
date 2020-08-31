return function(Modules, ServerModules, Services)
	local module = {}
	local private = {}

    local PlayerData = {}
	local Bindings = {}

    local GameGui
    function module.Init()
        GameGui = Modules.GuiLibrary.GetGameGui()
    end

    function module.Start()
        private.Bind('Clicks', private.UpdateClicks)
    end

    function private.UpdateClicks(value)
        print('Display clicks! (Client)')
    end

    function module.UpdateStats_event(stats)

        assert(type(stats) == "table", "Data sent from server must be a table to be updated")
		for key, value in pairs(stats) do
			PlayerData[key] = value
		end
		for key, value in pairs(stats) do
			if Bindings[key] then
				for _, f in pairs(Bindings[key]) do
					f(value)
				end
			end
		end
    end
    function module.GetData()
        return PlayerData
    end
    function private.Bind(key, func)
		if (not Bindings[key]) then
			Bindings[key] = {}
		end
		table.insert(Bindings[key], func)
	end

    return module, private
end
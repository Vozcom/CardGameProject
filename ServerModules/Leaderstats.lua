return function(Modules, ClientModules, Services)

	local module = {}
    local private = {}
   
    local PlayerLeaderstats = {}
    local Stats = {}

    function module.Init()
        private.AddStat('Clicks', 'Clicks', 'StringValue', private.OutValue)
    end
    function module.Start()
        Modules.ServerWorld.BindToJoin(private.Set)
    end

    function private.AddStat(name, bindData, dataType, func)
		Stats[name] = {Name = name, BindData = bindData, DataType = dataType, Function = func}
    end
    
    function private.Set(player)

        local leaderstats = Instance.new("IntValue")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
        PlayerLeaderstats[player] = leaderstats
		
        for tag, data in pairs(Stats) do
            
			local stat = Instance.new(data.DataType)
			stat.Name = data.Name
			stat.Parent = leaderstats
        end
		private.UpdateStats(player)
    end

    function private.UpdateStats(player)
        
        if PlayerLeaderstats[player] then
            
            local playerData = Modules.PlayerData.GetData(player)
            for tag, data in pairs(Stats) do
                PlayerLeaderstats[player]:FindFirstChild(tag).Value = data.Function(playerData[data.BindData])
			end
		end
	end

    function private.OutValue(value)
		return tostring(value)
	end
    return module, private
end
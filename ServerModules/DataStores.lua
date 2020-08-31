local PlayerDatas = {}
return function(Modules, ClientModules, Services)
	local module = {}
	local private = {}

    local DataStoreService = Services.DataStoreService
    local defaultUpdate = {'Clicks', 'Tokens', 'Level', 'Gamepasses'}

    function module.OnPlayerReady(player)

        private.SetupPlayer(player)
        game:BindToClose(private.ShutServer)
        spawn(private.AutoSave)

        for _, func in pairs(Modules.ServerWorld.FunctionsOnJoin) do
            func(player)
        end
    end
    function module.OnPlayerLeaving(player)
        module.SaveData_Check(player)
    end

    private.STUDIO_LOADS = false
    private.STUDIO_SAVES = false
	private.MAX_TRIES = 4
	private.RETRY_TIME = 5

    local LoadedDataStores = {PlayerData = DataStoreService:GetDataStore("PlayerData_test2")}
    function private.LoadData(index, userId)

        local tries = 0
        local success, data
        repeat
            success, data = pcall(function()
                if Services.RunService:IsStudio() and private.STUDIO_LOADS then
                    return LoadedDataStores[index]:GetAsync(userId)
                elseif (not Services.RunService:IsStudio()) then
                    return LoadedDataStores[index]:GetAsync(userId)
                end
            end)
            if (not success) then
                tries = (tries + 1)
                wait(private.RETRY_TIME ^ tries)
            end
        until success or tries >= private.MAX_TRIES
        return data
    end

    function private.SaveData(index, userId, data, raw)
		local tries = 0
		local success
		repeat
			success = pcall(function()
				if Services.RunService:IsStudio() and private.STUDIO_SAVES then
					LoadedDataStores[index]:SetAsync(userId, data)
				elseif (not Services.RunService:IsStudio()) then
					LoadedDataStores[index]:SetAsync(userId, data)
				end
			end)
			if (not success) then
				tries = (tries + 1)
				wait(private.RETRY_TIME ^ tries)
			end
		until success or tries >= private.MAX_TRIES or raw
    end
    
    -- DATA STUFFS
    function private.SetupPlayer(player)
        PlayerDatas[player] = Modules.PlayerData:New(player, private.LoadData(player))
        module.UpdateStats(player, defaultUpdate)
    end

    function module.GetServerDatas()
        return PlayerDatas
    end
    function module.UpdateStats(player, indexTable)
        local packedData = Modules.PlayerData.GetData(player):PackNeededData(indexTable)
        ClientModules.UpdateGui.UpdateStats(player, packedData)
	end
    function module.SaveData_Check(player)
        local data = Modules.PlayerData.GetData(player)
        if data then
			private.SaveData("PlayerData", player.UserId, data:GetSaveData())
		end
    end
    function private.AutoSave()
		wait(40)
		for _, player in pairs(game.Players:GetChildren()) do
			module.SaveData_Check(player)
			wait(5)
		end
    end
    ----------

    function private.ShutServer()
		if Services.RunService:IsStudio() then
			return
		end
		wait(10)
		print("farewell my friend, its been a fun ride..")
	end

    return module, private
end
return function(Modules, ClientModules, Services)
	local module = {}
    local private = {}

    function module.Start()
        Modules.ServerWorld.BindToJoin(private.GetGamepassesJoin)
    end

    local FunctionBindings = {}
    function private.BindId(id, initFunc)
        FunctionBindings[tostring(id)] = initFunc
    end

    private.BindId(123456789, function()
        -- actions for the specific product/gamepass
    end)

    function private.GetGamepassesJoin(player)
        local playerData = Modules.PlayerData.GetData(player)
        for _, gamePassInfo in pairs(Services.ServerStorage.ServerData.Gamepasses:GetChildren()) do
            
            if not playerData:OwnsGamePass(gamePassInfo.Name) then
                if Services.MarketplaceService:UserOwnsGamePassAsync(player.UserId, tonumber(gamePassInfo.Name)) then
                    
                    playerData:AddGamePass(gamePassInfo.Name)
                    if FunctionBindings[tostring(gamePassInfo.Name)] then
                        FunctionBindings[tostring(gamePassInfo.Name)](player)
					end
				end
			else
				if FunctionBindings[tostring(gamePassInfo.Name)] then
					FunctionBindings[tostring(gamePassInfo.Name)](player)
				end
			end
		end
    end
    Services.MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, purchaseSuccess)
        
        local gamePass = Services.ServerStorage.ServerData.Gamepasses:FindFirstChild(tostring(gamePassId))
        if (purchaseSuccess and gamePass) then
            
			Modules.PlayerData.GetData(player):AddGamePass(gamePassId)
			if FunctionBindings[tostring(gamePassId)] then
				FunctionBindings[tostring(gamePassId)](player)
			end
		end
    end)
    
    function Services.MarketplaceService.ProcessReceipt(receiptInfo)

		local player = Services.Players:GetPlayerByUserId(receiptInfo.PlayerId)
        if player and Services.ServerStorage.ServerData.DevProducts:FindFirstChild(tostring(receiptInfo.ProductId)) then
            
			local playerData = Modules.PlayerData.GetData(player)
            if playerData then
				playerData:AddRobuxSpent(receiptInfo.CurrencySpent)
        
                local ID = tostring(receiptInfo.ProductId)
                if FunctionBindings[ID] then
                    FunctionBindings[ID](player)
                end
                spawn(function() Modules.ServerWorld.SaveData(player) end)
			end
		end
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

    return module, private
end
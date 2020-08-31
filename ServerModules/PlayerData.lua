return function(Modules, ClientModules, Services)
	local module = {}
    module.__index = module

    local private = {}   
    local PlayerDataTemplate = {

        Level = 0,
        XP = 0,

        Clicks = 0,
        Tokens = 0,

        PetsInventory = {},
        Gamepasses = {},
        RobuxSpent = 0,
    }

    function module:AddRobuxSpent(amount)
		self.RobuxSpent = self.RobuxSpent + amount
	end
	function module:OwnsGamePass(id)
		return self.Gamepasses[tostring(id)]
	end
	function module:AddGamePass(id)
		if not self:OwnsGamePass(id) then
			self.Gamepasses[tostring(id)] = true
		end
    end

    function module:AddClick()
        local value = 1
        self.Clicks = (self.Clicks + value)
    end

    function module:AddLevel()
        self.Level = (self.Level or 0) + 1
    end

    function module:AddXP(value)

        local playerLevel = self.Level
        local maxXP = Modules.ServerWorld.GetMaxXP(playerLevel)

        local XPgiving = value
        local diff = maxXP - (self.XP + XPgiving)
        if (diff < 0) then
            XPgiving = value - (diff * -1)
        end

        self.XP = (self.XP + XPgiving)
        if (self.XP >= maxXP) then -- NEW LEVEL!
            self:AddLevel()
            self.XP = 0
        end
        local spare = (value - XPgiving)
        if (spare > 0) then
            self.XP = (self.XP + spare)
        end
    end

    function module:AddPet(petClassId)

        local stringId = tostring(petClassId)
        local inv = self.PetsInventory

        local playerOwnsIDPet = inv[stringId]
        inv[stringId] = {
            Pets = (playerOwnsIDPet and playerOwnsIDPet.Pets) or {}
        }

        local generateId = function()
            local range, randomID = math.random(1000, 9999)
            while wait() do

                randomID = tostring(range)
                if (not inv[stringId].Pets[randomID]) then
                    break
                end
            end
            return randomID
        end

        -- TO DO: define max XP per pets for each level
        local particularId = generateId()
        inv[stringId].Pets[particularId] = {
            Level = 0,
            XP = 0
        }
    end

    function module:RemoveParticularPet(petClassId, particularId)

        local stringId = tostring(petClassId)
        local inv = self.PetsInventory

        if (not inv[stringId]) then -- pet class does not exist
            return warn('Player does not own the pet class!')
        end

        local petClassInfos = inv[stringId]
        local particularPetInfos = petClassInfos.Pets[tostring(particularId)]

        if (not particularPetInfos) then -- particular pet does not exist
            return warn('Pet does not exist in player inventory!')
        end
        particularPetInfos = nil
    end

    function module:AddPetXP(petClassId, particularId, value)

        local stringId = tostring(petClassId)
        local inv = self.PetsInventory

        if (not inv[stringId]) then -- pet class does not exist
            return warn('Player does not own the pet class!')
        end

        local petClassInfos = inv[stringId]
        local particularPetInfos = petClassInfos.Pets[tostring(particularId)]

        if (not particularPetInfos) then -- particular pet does not exist
            return warn('Pet does not exist in player inventory!')
        end

        local currentPetLevel = particularPetInfos.Level
        local maxXP = Modules.ServerWorld.GetPetMaxXP(stringId, currentPetLevel)
        local XPgiving = value

        local diff = maxXP - (particularPetInfos.XP + XPgiving)
        if (diff < 0) then
            XPgiving = value - (diff * -1)
        end

        particularPetInfos.XP = (particularPetInfos.XP + XPgiving)
        if (particularPetInfos.XP >= maxXP) then -- NEW LEVEL!
            particularPetInfos.Level = (particularPetInfos.Level or 0) + 1
            particularPetInfos.XP = 0
        end
        local spare = (value - XPgiving)
        if (spare > 0) then
            particularPetInfos.XP = (particularPetInfos.XP + spare)
        end
    end

    function module:New(player, encodedData)

        local data = {}
        if encodedData and typeof(encodedData) == "string" then
			data = Services.HttpService:JSONDecode(encodedData)
        end
        local tempdata = Modules.DeepCopy.Copy(PlayerDataTemplate)
		data = Modules.DeepCopy.Merge(tempdata, data)
		data.Player = player

		setmetatable(data, self)
		return data
    end

    function module.GetData(player, specialCase)

        local data = Modules.DataStores.GetServerDatas()[player]
        if (not data) then warn("Player Data doesn't exist", specialCase) end
		return data
    end

    function module:PackNeededData(indexesWanted)

		local neededData = {}
        for _, index in pairs(indexesWanted) do
            
			if self[index] then
				neededData[index] = self[index]
			else
				error("Tried to pack an unexisting index")
			end
		end
		return neededData
	end

    function module:GetSaveData()
        return Services.HttpService:JSONEncode(self)
    end

    return module, private
end
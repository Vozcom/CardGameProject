return function(Modules, ServerModules, Services)
	local module = {}
	local private = {}

    function module.GetGameGui()
        return game.Players.LocalPlayer.PlayerGui:WaitForChild('GameGui')
    end

    return module, private
end
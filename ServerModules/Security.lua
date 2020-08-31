return function(Modules, ClientModules, Services)

	local module = {}
    local private = {}

    local max_warnings = 3
    private.PlayerWarnings = {}

    function module.WarnPlayer(player)

        private.PlayerWarnings[player.UserId] = (private.PlayerWarnings[player.UserId] or 0) + 1
        warn(("Warned %q: (%s/%s)"):format(player.Name, private.PlayerWarnings[player.UserId], max_warnings))

        if (private.PlayerWarnings[player.UserId] >= max_warnings) then
            player:Kick()
            print(("%q got kicked out due to too man warnings."):format(player.Name))
        end
    end

    return module, private
end
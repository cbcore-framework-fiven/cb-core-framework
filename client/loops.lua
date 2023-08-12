CreateThread(function()
    while true do
        local sleep = 0
        if LocalPlayer.state.isLoggedIn then
            sleep = (1000 * 60) * CBCore.Config.UpdateInterval
            TriggerServerEvent('CBCore:UpdatePlayer')
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        if LocalPlayer.state.isLoggedIn then
            if (CBCore.PlayerData.metadata['hunger'] <= 0 or CBCore.PlayerData.metadata['thirst'] <= 0) and not (CBCore.PlayerData.metadata['isdead'] or CBCore.PlayerData.metadata["inlaststand"]) then
                local ped = PlayerPedId()
                local currentHealth = GetEntityHealth(ped)
                local decreaseThreshold = math.random(5, 10)
                SetEntityHealth(ped, currentHealth - decreaseThreshold)
            end
        end
        Wait(CBCore.Config.StatusInterval)
    end
end)
-- Event Handler

AddEventHandler('chatMessage', function(_, _, message)
    if string.sub(message, 1, 1) == '/' then
        CancelEvent()
        return
    end
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    if not QBCore.Players[src] then return end
    local Player = QBCore.Players[src]
    TriggerEvent('cb-log:server:CreateLog', 'joinleave', 'Dropped', 'red', '**' .. GetPlayerName(src) .. '** (' .. Player.PlayerData.license .. ') left..' ..'\n **Reason:** ' .. reason)
    Player.Functions.Save()
    CBCore.Player_Buckets[Player.PlayerData.license] = nil
    CBCore.Players[src] = nil
end)

-- Player Connecting

local function onPlayerConnecting(name, _, deferrals)
    local src = source
    local license
    local identifiers = GetPlayerIdentifiers(src)
    deferrals.defer()

    -- Mandatory wait
    Wait(0)

    if CBCore.Config.Server.Closed then
        if not IsPlayerAceAllowed(src, 'cbadmin.join') then
            deferrals.done(CBCore.Config.Server.ClosedReason)
        end
    end

    for _, v in pairs(identifiers) do
        if string.find(v, 'license') then
            license = v
            break
        end
    end

    if GetConvarInt("sv_fxdkMode", false) then
        license = 'license:AAAAAAAAAAAAAAAA' -- Dummy License
    end

    if not license then
        deferrals.done(Lang:t('error.no_valid_license'))
    elseif CBCore.Config.Server.CheckDuplicateLicense and CBCore.Functions.IsLicenseInUse(license) then
        deferrals.done(Lang:t('error.duplicate_license'))
    end

    local databaseTime = os.clock()
    local databasePromise = promise.new()

    -- conduct database-dependant checks
    CreateThread(function()
        deferrals.update(string.format(Lang:t('info.checking_ban'), name))
        local databaseSuccess, databaseError = pcall(function()
            local isBanned, Reason = QBCore.Functions.IsPlayerBanned(src)
            if isBanned then
                deferrals.done(Reason)
            end
        end)

        if CBCore.Config.Server.Whitelist then
            deferrals.update(string.format(Lang:t('info.checking_whitelisted'), name))
            databaseSuccess, databaseError = pcall(function()
                if not CBCore.Functions.IsWhitelisted(src) then
                    deferrals.done(Lang:t('error.not_whitelisted'))
                end
            end)
        end

        if not databaseSuccess then
            databasePromise:reject(databaseError)
        end
        databasePromise:resolve()
    end)

    -- wait for database to finish
    databasePromise:next(function()
        deferrals.update(string.format(Lang:t('info.join_server'), name))
        deferrals.done()
    end, function (databaseError)
        deferrals.done(Lang:t('error.connecting_database_error'))
        print('^1' .. databaseError)
    end)

    -- if conducting checks for too long then raise error
    while databasePromise.state == 0 do
        if os.clock() - databaseTime > 30 then
            deferrals.done(Lang:t('error.connecting_database_timeout'))
            error(Lang:t('error.connecting_database_timeout'))
            break
        end
        Wait(1000)
    end

    -- Add any additional defferals you may need!
end

AddEventHandler('playerConnecting', onPlayerConnecting)

-- Open & Close Server (prevents players from joining)

RegisterNetEvent('CBCore:Server:CloseServer', function(reason)
    local src = source
    if CBCore.Functions.HasPermission(src, 'admin') then
        reason = reason or 'No reason specified'
        CBCore.Config.Server.Closed = true
        CBCore.Config.Server.ClosedReason = reason
        for k in pairs(QBCore.Players) do
            if not CBCore.Functions.HasPermission(k, CBCore.Config.Server.WhitelistPermission) then
                CBCore.Functions.Kick(k, reason, nil, nil)
            end
        end
    else
        CBCore.Functions.Kick(src, Lang:t("error.no_permission"), nil, nil)
    end
end)

RegisterNetEvent('CBCore:Server:OpenServer', function()
    local src = source
    if CBCore.Functions.HasPermission(src, 'admin') then
        CBCore.Config.Server.Closed = false
    else
        CBCore.Functions.Kick(src, Lang:t("error.no_permission"), nil, nil)
    end
end)

-- Callback Events --

-- Client Callback
RegisterNetEvent('CBCore:Server:TriggerClientCallback', function(name, ...)
    if CBCore.ClientCallbacks[name] then
        CBCore.ClientCallbacks[name](...)
        CBCore.ClientCallbacks[name] = nil
    end
end)

-- Server Callback
RegisterNetEvent('CBCore:Server:TriggerCallback', function(name, ...)
    local src = source
    CBCore.Functions.TriggerCallback(name, src, function(...)
        TriggerClientEvent('CBCore:Client:TriggerCallback', src, name, ...)
    end, ...)
end)

-- Player

RegisterNetEvent('CBCore:UpdatePlayer', function()
    local src = source
    local Player = CBCore.Functions.GetPlayer(src)
    if not Player then return end
    local newHunger = Player.PlayerData.metadata['hunger'] - CBCore.Config.Player.HungerRate
    local newThirst = Player.PlayerData.metadata['thirst'] - CBCore.Config.Player.ThirstRate
    if newHunger <= 0 then
        newHunger = 0
    end
    if newThirst <= 0 then
        newThirst = 0
    end
    Player.Functions.SetMetaData('thirst', newThirst)
    Player.Functions.SetMetaData('hunger', newHunger)
    TriggerClientEvent('hud:client:UpdateNeeds', src, newHunger, newThirst)
    Player.Functions.Save()
end)

RegisterNetEvent('CBCore:ToggleDuty', function()
    local src = source
    local Player = CBCore.Functions.GetPlayer(src)
    if not Player then return end
    if Player.PlayerData.job.onduty then
        Player.Functions.SetJobDuty(false)
        TriggerClientEvent('CBCore:Notify', src, Lang:t('info.off_duty'))
    else
        Player.Functions.SetJobDuty(true)
        TriggerClientEvent('CBCore:Notify', src, Lang:t('info.on_duty'))
    end
        
    TriggerEvent('CBCore:Server:SetDuty', src, Player.PlayerData.job.onduty)
    TriggerClientEvent('CBCore:Client:SetDuty', src, Player.PlayerData.job.onduty)
end)

-- BaseEvents

-- Vehicles
RegisterServerEvent('baseevents:enteringVehicle', function(veh,seat,modelName)
    local src = source
    local data = {
        vehicle = veh,
        seat = seat,
        name = modelName,
        event = 'Entering'
    }
    TriggerClientEvent('CBCore:Client:VehicleInfo', src, data)
end)

RegisterServerEvent('baseevents:enteredVehicle', function(veh,seat,modelName)
    local src = source
    local data = {
        vehicle = veh,
        seat = seat,
        name = modelName,
        event = 'Entered'
    }
    TriggerClientEvent('CBCore:Client:VehicleInfo', src, data)
end)

RegisterServerEvent('baseevents:enteringAborted', function()
    local src = source
    TriggerClientEvent('CBCore:Client:AbortVehicleEntering', src)
end)

RegisterServerEvent('baseevents:leftVehicle', function(veh,seat,modelName)
    local src = source
    local data = {
        vehicle = veh,
        seat = seat,
        name = modelName,
        event = 'Left'
    }
    TriggerClientEvent('CBCore:Client:VehicleInfo', src, data)
end)

-- Items

-- This event is exploitable and should not be used. It has been deprecated, and will be removed soon.
RegisterNetEvent('CBCore:Server:UseItem', function(item)
    print(string.format("%s triggered CBCore:Server:UseItem by ID %s with the following data. This event is deprecated due to exploitation, and will be removed soon. Check cb-inventory for the right use on this event.", GetInvokingResource(), source))
    CBCore.Debug(item)
end)

-- This event is exploitable and should not be used. It has been deprecated, and will be removed soon. function(itemName, amount, slot)
RegisterNetEvent('CBCore:Server:RemoveItem', function(itemName, amount)
    local src = source
    print(string.format("%s triggered CBCore:Server:RemoveItem by ID %s for %s %s. This event is deprecated due to exploitation, and will be removed soon. Adjust your events accordingly to do this server side with player functions.", GetInvokingResource(), src, amount, itemName))
end)

-- This event is exploitable and should not be used. It has been deprecated, and will be removed soon. function(itemName, amount, slot, info)
RegisterNetEvent('CBCore:Server:AddItem', function(itemName, amount)
    local src = source
    print(string.format("%s triggered CBCore:Server:AddItem by ID %s for %s %s. This event is deprecated due to exploitation, and will be removed soon. Adjust your events accordingly to do this server side with player functions.", GetInvokingResource(), src, amount, itemName))
end)

-- Non-Chat Command Calling (ex: qb-adminmenu)

RegisterNetEvent('CBCore:CallCommand', function(command, args)
    local src = source
    if not CBCore.Commands.List[command] then return end
    local Player = CBCore.Functions.GetPlayer(src)
    if not Player then return end
    local hasPerm = CBCore.Functions.HasPermission(src, "command."..CBCore.Commands.List[command].name)
    if hasPerm then
        if CBCore.Commands.List[command].argsrequired and #CBCore.Commands.List[command].arguments ~= 0 and not args[#CBCore.Commands.List[command].arguments] then
            TriggerClientEvent('CBCore:Notify', src, Lang:t('error.missing_args2'), 'error')
        else
            CBCore.Commands.List[command].callback(src, args)
        end
    else
        TriggerClientEvent('CBCore:Notify', src, Lang:t('error.no_access'), 'error')
    end
end)

-- Use this for player vehicle spawning
-- Vehicle server-side spawning callback (netId)
-- use the netid on the client with the NetworkGetEntityFromNetworkId native
-- convert it to a vehicle via the NetToVeh native
CBCore.Functions.CreateCallback('CBCore:Server:SpawnVehicle', function(source, cb, model, coords, warp)
    local veh = CBCore.Functions.SpawnVehicle(source, model, coords, warp)
    cb(NetworkGetNetworkIdFromEntity(veh))
end)

-- Use this for long distance vehicle spawning
-- vehicle server-side spawning callback (netId)
-- use the netid on the client with the NetworkGetEntityFromNetworkId native
-- convert it to a vehicle via the NetToVeh native
CBCore.Functions.CreateCallback('CBCore:Server:CreateVehicle', function(source, cb, model, coords, warp)
    local veh = CBCore.Functions.CreateAutomobile(source, model, coords, warp)
    cb(NetworkGetNetworkIdFromEntity(veh))
end)

--CBCore.Functions.CreateCallback('CBCore:HasItem', function(source, cb, items, amount)
-- 
--end)
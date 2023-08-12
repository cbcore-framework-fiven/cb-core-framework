-- Add or change (a) method(s) in the QBCore.Functions table
local function SetMethod(methodName, handler)
    if type(methodName) ~= "string" then
        return false, "invalid_method_name"
    end

    CBCore.Functions[methodName] = handler

    TriggerEvent('CBCore:Server:UpdateObject')

    return true, "success"
end

CBCore.Functions.SetMethod = SetMethod
exports("SetMethod", SetMethod)

-- Add or change (a) field(s) in the CBCore table
local function SetField(fieldName, data)
    if type(fieldName) ~= "string" then
        return false, "invalid_field_name"
    end

    CBCore[fieldName] = data

    TriggerEvent('CBCore:Server:UpdateObject')

    return true, "success"
end

CBCore.Functions.SetField = SetField
exports("SetField", SetField)

-- Single add job function which should only be used if you planning on adding a single job
local function AddJob(jobName, job)
    if type(jobName) ~= "string" then
        return false, "invalid_job_name"
    end

    if CBCore.Shared.Jobs[jobName] then
        return false, "job_exists"
    end

    CBCore.Shared.Jobs[jobName] = job

    TriggerClientEvent('CBCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, job)
    TriggerEvent('CBCore:Server:UpdateObject')
    return true, "success"
end

CBCore.Functions.AddJob = AddJob
exports('AddJob', AddJob)

-- Multiple Add Jobs
local function AddJobs(jobs)
    local shouldContinue = true
    local message = "success"
    local errorItem = nil

    for key, value in pairs(jobs) do
        if type(key) ~= "string" then
            message = 'invalid_job_name'
            shouldContinue = false
            errorItem = jobs[key]
            break
        end

        if CBCore.Shared.Jobs[key] then
            message = 'job_exists'
            shouldContinue = false
            errorItem = jobs[key]
            break
        end

        CBCore.Shared.Jobs[key] = value
    end

    if not shouldContinue then return false, message, errorItem end
    TriggerClientEvent('CBCore:Client:OnSharedUpdateMultiple', -1, 'Jobs', jobs)
    TriggerEvent('CBCore:Server:UpdateObject')
    return true, message, nil
end

CBCore.Functions.AddJobs = AddJobs
exports('AddJobs', AddJobs)

-- Single Remove Job
local function RemoveJob(jobName)
    if type(jobName) ~= "string" then
        return false, "invalid_job_name"
    end

    if not CBCore.Shared.Jobs[jobName] then
        return false, "job_not_exists"
    end

    CBCore.Shared.Jobs[jobName] = nil

    TriggerClientEvent('CBCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, nil)
    TriggerEvent('CBCore:Server:UpdateObject')
    return true, "success"
end

CBCore.Functions.RemoveJob = RemoveJob
exports('RemoveJob', RemoveJob)

-- Single Update Job
local function UpdateJob(jobName, job)
    if type(jobName) ~= "string" then
        return false, "invalid_job_name"
    end

    if not CBCore.Shared.Jobs[jobName] then
        return false, "job_not_exists"
    end

    CBCore.Shared.Jobs[jobName] = job

    TriggerClientEvent('CBCore:Client:OnSharedUpdate', -1, 'Jobs', jobName, job)
    TriggerEvent('CBCore:Server:UpdateObject')
    return true, "success"
end

CBCore.Functions.UpdateJob = UpdateJob
exports('UpdateJob', UpdateJob)

-- Single add item
local function AddItem(itemName, item)
    if type(itemName) ~= "string" then
        return false, "invalid_item_name"
    end

    if CBCore.Shared.Items[itemName] then
        return false, "item_exists"
    end

    CBCore.Shared.Items[itemName] = item

    TriggerClientEvent('CBCore:Client:OnSharedUpdate', -1, 'Items', itemName, item)
    TriggerEvent('CBCore:Server:UpdateObject')
    return true, "success"
end

CBCore.Functions.AddItem = AddItem
exports('AddItem', AddItem)

-- Single update item
local function UpdateItem(itemName, item)
    if type(itemName) ~= "string" then
        return false, "invalid_item_name"
    end
    if not QBCore.Shared.Items[itemName] then
        return false, "item_not_exists"
    end
    CBCore.Shared.Items[itemName] = item
    TriggerClientEvent('CBCore:Client:OnSharedUpdate', -1, 'Items', itemName, item)
    TriggerEvent('CBCore:Server:UpdateObject')
    return true, "success"
end

CBCore.Functions.UpdateItem = UpdateItem
exports('UpdateItem', UpdateItem)

-- Multiple Add Items
local function AddItems(items)
    local shouldContinue = true
    local message = "success"
    local errorItem = nil

    for key, value in pairs(items) do
        if type(key) ~= "string" then
            message = "invalid_item_name"
            shouldContinue = false
            errorItem = items[key]
            break
        end

        if CBCore.Shared.Items[key] then
            message = "item_exists"
            shouldContinue = false
            errorItem = items[key]
            break
        end

        CBCore.Shared.Items[key] = value
    end

    if not shouldContinue then return false, message, errorItem end
    TriggerClientEvent('CBCore:Client:OnSharedUpdateMultiple', -1, 'Items', items)
    TriggerEvent('CBCore:Server:UpdateObject')
    return true, message, nil
end

CBCore.Functions.AddItems = AddItems
exports('AddItems', AddItems)

-- Single Remove Item
local function RemoveItem(itemName)
    if type(itemName) ~= "string" then
        return false, "invalid_item_name"
    end

    if not CBCore.Shared.Items[itemName] then
        return false, "item_not_exists"
    end

    CBCore.Shared.Items[itemName] = nil

    TriggerClientEvent('CBCore:Client:OnSharedUpdate', -1, 'Items', itemName, nil)
    TriggerEvent('CBCore:Server:UpdateObject')
    return true, "success"
end

CBCore.Functions.RemoveItem = RemoveItem
exports('RemoveItem', RemoveItem)

-- Single Add Gang
local function AddGang(gangName, gang)
    if type(gangName) ~= "string" then
        return false, "invalid_gang_name"
    end

    if CBCore.Shared.Gangs[gangName] then
        return false, "gang_exists"
    end

    CBCore.Shared.Gangs[gangName] = gang

    TriggerClientEvent('CBCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, gang)
    TriggerEvent('CBCore:Server:UpdateObject')
    return true, "success"
end

CBCore.Functions.AddGang = AddGang
exports('AddGang', AddGang)

-- Multiple Add Gangs
local function AddGangs(gangs)
    local shouldContinue = true
    local message = "success"
    local errorItem = nil

    for key, value in pairs(gangs) do
        if type(key) ~= "string" then
            message = "invalid_gang_name"
            shouldContinue = false
            errorItem = gangs[key]
            break
        end

        if QBCore.Shared.Gangs[key] then
            message = "gang_exists"
            shouldContinue = false
            errorItem = gangs[key]
            break
        end

        CBCore.Shared.Gangs[key] = value
    end

    if not shouldContinue then return false, message, errorItem end
    TriggerClientEvent('CBCore:Client:OnSharedUpdateMultiple', -1, 'Gangs', gangs)
    TriggerEvent('CBCore:Server:UpdateObject')
    return true, message, nil
end

CBCore.Functions.AddGangs = AddGangs
exports('AddGangs', AddGangs)

-- Single Remove Gang
local function RemoveGang(gangName)
    if type(gangName) ~= "string" then
        return false, "invalid_gang_name"
    end

    if not CBCore.Shared.Gangs[gangName] then
        return false, "gang_not_exists"
    end

    CBCore.Shared.Gangs[gangName] = nil

    TriggerClientEvent('CBCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, nil)
    TriggerEvent('CBCore:Server:UpdateObject')
    return true, "success"
end

CBCore.Functions.RemoveGang = RemoveGang
exports('RemoveGang', RemoveGang)

-- Single Update Gang
local function UpdateGang(gangName, gang)
    if type(gangName) ~= "string" then
        return false, "invalid_gang_name"
    end

    if not CBCore.Shared.Gangs[gangName] then
        return false, "gang_not_exists"
    end

    CBCore.Shared.Gangs[gangName] = gang

    TriggerClientEvent('CBCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, gang)
    TriggerEvent('CBCore:Server:UpdateObject')
    return true, "success"
end

CBCore.Functions.UpdateGang = UpdateGang
exports('UpdateGang', UpdateGang)

local function GetCoreVersion(InvokingResource)
    local resourceVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')
    if InvokingResource and InvokingResource ~= '' then
        print(("%s called qbcore version check: %s"):format(InvokingResource or 'Unknown Resource', resourceVersion))
    end
    return resourceVersion
end

CBCore.Functions.GetCoreVersion = GetCoreVersion
exports('GetCoreVersion', GetCoreVersion)

local function ExploitBan(playerId, origin)
    local name = GetPlayerName(playerId)
    MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        name,
        CBCore.Functions.GetIdentifier(playerId, 'license'),
        CBCore.Functions.GetIdentifier(playerId, 'discord'),
        CBCore.Functions.GetIdentifier(playerId, 'ip'),
        origin,
        2147483647,
        'Anti Cheat'
    })
    DropPlayer(playerId, Lang:t('info.exploit_banned', {discord = QBCore.Config.Server.Discord}))
    TriggerEvent("cb-log:server:CreateLog", "anticheat", "Anti-Cheat", "red", name .. " has been banned for exploiting " .. origin, true)
end

exports('ExploitBan', ExploitBan)
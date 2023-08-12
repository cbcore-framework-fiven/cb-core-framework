CBCore = {}
CBCore.PlayerData = {}
CBCore.Config = QBConfig
CBCore.Shared = QBShared
CBCore.ClientCallbacks = {}
CBCore.ServerCallbacks = {}

exports('GetCoreObject', function()
    return CBCore
end)

-- To use this export in a script instead of manifest method
-- Just put this line of code below at the very top of the script
-- local CBCore = exports['cb-core']:GetCoreObject()
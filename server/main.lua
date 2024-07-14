-------------------------------------------------
-- 
-- COMMANDS
-- 
-------------------------------------------------
lib.addCommand(IR8.Config.Commands.ManageBlips, {
    help = IR8.Config.Commands.ManageBlipsDescription,
    params = {},
    restricted = IR8.Config.Commands.Permissions
}, function(source, args, raw)
    TriggerClientEvent(IR8.Config.ClientCallbackPrefix .. "ShowNUI", source)
end)

-------------------------------------------------
-- 
-- CALL BACKS
-- 
-------------------------------------------------

-- One off loading of blips for players just connecting
lib.callback.register(IR8.Config.ServerCallbackPrefix .. "LoadBlips", function ()
    return IR8.Utilities.GetBlips()
end)

-- For creating a blip
lib.callback.register(IR8.Config.ServerCallbackPrefix .. "Create", function (source, data)
    local res = IR8.Utilities.CreateBlip(data)

    if res.success then 
        res.blips = IR8.Utilities.GetBlips()
        TriggerClientEvent(IR8.Config.ClientCallbackPrefix .. "SetBlips", -1, res.blips)

        -- Send discord webhook

        IR8.Utilities.DebugPrint("Sending discord notification for created blip.")
        IR8.Utilities.SendDiscordEmbed({
            title = "Blip Created",
            message = "A blip was created for " .. data.title .. " with position of " .. data.position
        })
    end

    return res
end)

-- For saving a blip
lib.callback.register(IR8.Config.ServerCallbackPrefix .. "Update", function (source, data)
    local res = IR8.Utilities.UpdateBlip(data)

    if res.success then 
        res.blips = IR8.Utilities.GetBlips()
        TriggerClientEvent(IR8.Config.ClientCallbackPrefix .. "SetBlips", -1, res.blips)

        -- Send discord webhook

        IR8.Utilities.DebugPrint("Sending discord notification for updated blip.")
        IR8.Utilities.SendDiscordEmbed({
            title = "Blip Updated",
            message = "Blip data was updated for " .. data.title .. "."
        })
    end

    return res
end)

-- For deleting a blip
lib.callback.register(IR8.Config.ServerCallbackPrefix .. "Delete", function (source, data)
    local blipData = IR8.Utilities.GetBlip(data.id)
    local res = IR8.Utilities.DeleteBlip(data)

    if res.success then 
        res.blips = IR8.Utilities.GetBlips()
        TriggerClientEvent(IR8.Config.ClientCallbackPrefix .. "SetBlips", -1, res.blips)

        -- Send discord webhook
        if blipData then

            IR8.Utilities.DebugPrint("Sending discord notification for deleted blip.")
            IR8.Utilities.SendDiscordEmbed({
                title = "Blip Created",
                message = "Blip " .. blipData.title .. " was deleted."
            })
        end
    end

    return res
end)
-------------------------------------------------
-- 
-- DISCORD WEBHOOK CONFIGURATION
-- Thanks to complex from Project Sloth for the 
-- suggestion to move this config to here.
-- 
-------------------------------------------------

-- Send discord notifications when tickets are created / updated
Discord = {

    -- Only sends webhooks if this is true
    WebhookEnabled = true,

    -- The webhook url to send the request to
    WebhookUrl = 'url',

    -- The author name of the webhook
    AuthorName = 'IR8 Blips Manager'
}

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
        SendDiscordEmbed({
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
        SendDiscordEmbed({
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
            SendDiscordEmbed({
                title = "Blip Created",
                message = "Blip " .. blipData.title .. " was deleted."
            })
        end
    end

    return res
end)

-----------------------------------------------------------
-- 
--                    DISCORD WEBHOOK
-- 
-----------------------------------------------------------

function SendDiscordEmbed (options)

    if not Discord.WebhookEnabled then return end
    if Discord.WebhookUrl == "url" then return end

    if type(options) ~= "table" then
        return false
    end

    if not options.title then
        return false
    end

    if not options.message then
        return false
    end

    local embed = {
        {
            ["title"] = "**".. options.title .."**",
            ["description"] = options.message,
        }
    }

    if options.color then
        embed[1].color = options.color
    end

    if options.footer then
        embed[1].footer = {
            ["text"] = options.footer
        }
    end
    
    PerformHttpRequest(Discord.WebhookUrl, function(err, text, headers) 
        print(err)
    end, 'POST', json.encode({username = Discord.AuthorName, embeds = embed}), { ['Content-Type'] = 'application/json' })
end
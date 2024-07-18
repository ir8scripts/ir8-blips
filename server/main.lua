-------------------------------------------------
-- 
-- LOGGIN CONFIGURATION
-- Thanks to complex from Project Sloth for the 
-- suggestion to move this config to here.
-- 
-- Thanks to simsonas86 for fivemerr support
--
-------------------------------------------------

-- Send discord notifications when tickets are created / updated
Logging = {

    -- Only sends webhooks if this isn't empty
    LoggingService = 'discord', -- 'discord' | 'fivemerr' (discord is not recommended as it is not a logging service, fivemerr is a free alternative)

    -- Discord webhook url or Fivemerr API token
    LoggingTarget = 'url',

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
-- CATEGORY CALL BACKS
-- 
-------------------------------------------------

-- List of categories
lib.callback.register(IR8.Config.ServerCallbackPrefix .. "Categories", function ()
    return IR8.Database.GetCategories()
end)

-- For creating a blip category
lib.callback.register(IR8.Config.ServerCallbackPrefix .. "Category_Create", function (source, data)
    local res = IR8.Database.CreateCategory(data)

    if res.success then 
        res.categories = IR8.Database.GetCategories()

        -- Send discord webhook

        IR8.Utilities.DebugPrint("Sending discord notification for created blip category.")
        SendLog({
            title = "Blip Category Created",
            message = "A blip category was created for " .. data.title,
            source = source
        })
    end

    return res
end)

-- For saving a blip category
lib.callback.register(IR8.Config.ServerCallbackPrefix .. "Category_Enabled", function (source, data)
    local categoryData = IR8.Database.GetCategory(data.id)
    local res = IR8.Database.UpdateCategoryEnabled(data.id, data.enabled)

    if res.success then 
        local allBlips = IR8.Database.GetBlips()
        TriggerClientEvent(IR8.Config.ClientCallbackPrefix .. "SetBlips", -1, allBlips)

        res.categories = IR8.Database.GetCategories()
        res.message = categoryData.title .. " was " .. (data.enabled == 1 and 'enabled' or 'disabled')

        IR8.Utilities.DebugPrint("Sending discord notification for status of blip category.")
        SendLog({
            title = "Blip Category Status",
            message = "Blip Category: " .. categoryData.title .. " was " .. (data.enabled == 1 and 'enabled' or 'disabled'),
            source = source
        })
    end

    return res
end)

-- For saving a blip category
lib.callback.register(IR8.Config.ServerCallbackPrefix .. "Category_Update", function (source, data)
    local categoryData = IR8.Database.GetCategory(data.id)
    local res = IR8.Database.UpdateCategory(data)

    if res.success then 
        res.categories = IR8.Database.GetCategories()

        IR8.Utilities.DebugPrint("Sending discord notification for status of blip category update.")
        SendLog({
            title = "Blip Category Status",
            message = "Blip Category: " .. categoryData.title .. " was updated",
            source = source
        })
    end

    return res
end)

-- For deleting a blip category
lib.callback.register(IR8.Config.ServerCallbackPrefix .. "Category_Delete", function (source, data)
    local categoryData = IR8.Database.GetCategory(data.id)
    local res = IR8.Database.DeleteCategory(data)

    if res.success then 
        res.categories = IR8.Database.GetCategories()

        IR8.Utilities.DebugPrint("Sending discord notification for status of blip category deletion.")
        SendLog({
            title = "Blip Category Deletion",
            message = "Blip Category: " .. categoryData.title .. " was deleted",
            source = source
        })

        if (data.deleteBlips) then
            local allBlips = IR8.Database.GetBlips()
            TriggerClientEvent(IR8.Config.ClientCallbackPrefix .. "SetBlips", -1, allBlips)
        end
    end

    return res
end)

-- One off loading of blips for players just connecting
lib.callback.register(IR8.Config.ServerCallbackPrefix .. "Category_Blips", function (source, data)
    local res = IR8.Database.GetBlips(data.categoryId)

    if res then
        return {
            success = true,
            blips = res
        }
    else
        return { success = false, error = "Failed to load blips for category" }
    end
end)

-------------------------------------------------
-- 
-- BLIP CALL BACKS
-- 
-------------------------------------------------

-- One off loading of blips for players just connecting
lib.callback.register(IR8.Config.ServerCallbackPrefix .. "LoadBlips", function ()
    return IR8.Database.GetBlips()
end)

-- For creating a blip
lib.callback.register(IR8.Config.ServerCallbackPrefix .. "Create", function (source, data)
    local res = IR8.Database.CreateBlip(data)

    if res.success then 
        res.blips = IR8.Database.GetBlips(data.selectedCategoryId and data.selectedCategoryId or false)

        local allBlips = IR8.Database.GetBlips()
        TriggerClientEvent(IR8.Config.ClientCallbackPrefix .. "SetBlips", -1, allBlips)

        -- Send discord webhook

        IR8.Utilities.DebugPrint("Sending discord notification for created blip.")
        SendLog({
            title = "Blip Created",
            message = "A blip was created for " .. data.title .. " with position of " .. data.position,
            source = source
        })
    end

    return res
end)

-- For saving a blip
lib.callback.register(IR8.Config.ServerCallbackPrefix .. "Update", function (source, data)
    local res = IR8.Database.UpdateBlip(data)

    if res.success then 
        res.blips = IR8.Database.GetBlips(data.selectedCategoryId and data.selectedCategoryId or false)

        local allBlips = IR8.Database.GetBlips()
        TriggerClientEvent(IR8.Config.ClientCallbackPrefix .. "SetBlips", -1, allBlips)

        -- Send discord webhook

        IR8.Utilities.DebugPrint("Sending discord notification for updated blip.")
        SendLog({
            title = "Blip Updated",
            message = "Blip data was updated for " .. data.title .. ".",
            source = source
        })
    end

    return res
end)

-- For deleting a blip
lib.callback.register(IR8.Config.ServerCallbackPrefix .. "Delete", function (source, data)
    local blipData = IR8.Database.GetBlip(data.id)
    local res = IR8.Database.DeleteBlip(data)

    if res.success then 
        res.blips = IR8.Database.GetBlips(data.selectedCategoryId and data.selectedCategoryId or false)

        local allBlips = IR8.Database.GetBlips()
        TriggerClientEvent(IR8.Config.ClientCallbackPrefix .. "SetBlips", -1, allBlips)

        -- Send discord webhook
        if blipData then

            IR8.Utilities.DebugPrint("Sending discord notification for deleted blip.")
            SendLog({
                title = "Blip Deleted",
                message = "Blip " .. blipData.title .. " was deleted.",
                source = source
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

    if Logging.LoggingTarget == "url" then
        lib.print.error('Attempted to create a log with discord, but webhook url is not defined!')
        return
    end

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

    PerformHttpRequest(Logging.LoggingTarget, function(err, text, headers)
        print(err)
    end, 'POST', json.encode({username = Logging.AuthorName, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

function SentFivemerrLog(options)

    if Logging.LoggingTarget == "url" then
        lib.print.error('Attempted to create a log with fivemerr, but API token is not defined!')
        return
    end

    local data = {
        ["level"] = "info",
        ["message"] = options.title,
        ["resource"] = tostring(GetCurrentResourceName()),
        ["metadata"] = {
            ["server-id"] = tostring(options.source),
            ["message"] = options.message
        }
    }

    PerformHttpRequest('https://api.fivemerr.com/v1/logs', function(err, text, headers)
        print(err)
    end, 'POST', json.encode(data), { ['Content-Type'] = 'application/json', ['Authorization'] = tostring(Logging.LoggingTarget) })
end

function SendLog(options)
    if Logging.LoggingService == 'discord' then
        SendDiscordEmbed(options)
    elseif Logging.LoggingService == 'fivemerr' then
        SentFivemerrLog(options)
    else
        return
    end
end

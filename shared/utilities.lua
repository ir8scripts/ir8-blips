-- Attaches to the IR8 table 
-- Example call : IR8.Utilities.DebugPrint('foo-bar')
IR8.Utilities = {

    ---------------------------------------------------------
    -- 
    -- DEBUGGING
    --
    ---------------------------------------------------------

    DebugPrint = function(...)
        if not IR8.Config.Debugging then
            return
        end

        local args<const> = {...}

        local appendStr = ''
        for _, v in ipairs(args) do
            appendStr = appendStr .. ' ' .. tostring(v)
        end

        print(appendStr)
    end,

    -----------------------------------------------------------
    -- 
    --                    DISCORD WEBHOOK
    -- 
    -----------------------------------------------------------

    SendDiscordEmbed = function (options)

        if not IR8.Config.Discord.WebhookEnabled then return end

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
      
        PerformHttpRequest(IR8.Config.Discord.WebhookUrl, function(err, text, headers) 
            print(err)
        end, 'POST', json.encode({username = IR8.Config.Discord.AuthorName, embeds = embed}), { ['Content-Type'] = 'application/json' })
    end,

    ---------------------------------------------------------
    -- 
    -- NOTIFICATIONS
    --
    ---------------------------------------------------------
    
    -- Server side notification
    NotifyFromServer = function (source, id, title, message, type)
        TriggerClientEvent('ox_lib:notify', source, {
            id = id,
            title = title,
            description = message,
            type = type
        })
    end,

    -- Client side notification
    Notify = function (id, title, message, type)
        lib.notify({
            id = id,
            title = title,
            description = message,
            type = type
        })
    end,

    GetPositionFromString = function (position)
        position = position:gsub("%s+", "")
        position = string.gsub(position, "%s+", "")

        if not position then
            return {
                valid = false,
                error = "Position expects 3 parameters. Example: 1,2,3 (X,Y,Z)"
            }
        end

        local params = {}

        for pos in string.gmatch(position, '([^,]+)') do
            table.insert(params, pos)
        end

        if #params ~= 3 then
            return {
                valid = false,
                error = "Position expects 3 parameters. Example: 1,2,3 (X,Y,Z)"
            }
        end

        return {
            valid = true,
            x = params[1],
            y = params[2],
            z = params[3]
        }
    end,

    ---------------------------------------------------------
    -- 
    -- Blip Database Functions
    --
    ---------------------------------------------------------

    -- Get blips
    GetBlips = function()
        local blips = MySQL.query.await('SELECT * FROM `' .. IR8.Config.BlipsTable .. '` ORDER BY id ASC')
        return blips
    end,

    -- Get blip
    GetBlip = function(id)
        local blip = MySQL.single.await('SELECT * FROM `' .. IR8.Config.BlipsTable .. '` WHERE id = ?', {
            id
        })
        return blip
    end,

    -- Creates a blip
    CreateBlip = function (data)

        local position = IR8.Utilities.GetPositionFromString(data.position)

        if not position.valid then
            return { success = false, error = position.error }
        end

        local query = 'INSERT INTO `' .. IR8.Config.BlipsTable .. '`(title, blip_id, scale, color, display, short_range, positionX, positionY, positionZ, job) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
        local res = MySQL.insert.await(query, {
            data.title,
            data.blip_id,
            data.scale,
            data.color,
            data.display,
            data.short_range,
            position.x,
            position.y,
            position.z,
            data.job and data.job or ""
        })

        return { success = res and true or false }
    end,

    -- Updates a blip
    UpdateBlip = function (data)
        local position = IR8.Utilities.GetPositionFromString(data.position)

        if not position.valid then
            return { success = false, error = position.error }
        end

        local query = 'UPDATE `' .. IR8.Config.BlipsTable .. '` SET title = ?, blip_id = ?, scale = ?, color = ?, display = ?, short_range = ?, positionX = ?, positionY = ?, positionZ = ?, job = ? WHERE id = ?'
        
        local res = MySQL.query.await(query, {
            data.title,
            data.blip_id,
            data.scale,
            data.color,
            data.display,
            data.short_range,
            position.x,
            position.y,
            position.z,
            data.job and data.job or "",
            data.id
        })

        return { success = res and true or false }
    end,

    -- Deletes a blip
    DeleteBlip = function (data)
        local query = 'DELETE FROM `' .. IR8.Config.BlipsTable .. '` WHERE id = ?'
        
        local res = MySQL.query.await(query, {
            data.id
        })

        return { success = res and true or false }
    end,
}

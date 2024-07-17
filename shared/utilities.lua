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

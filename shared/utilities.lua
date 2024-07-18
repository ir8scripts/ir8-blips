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
    end
}

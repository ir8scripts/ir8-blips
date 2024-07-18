-- Attaches to the IR8 table 
IR8.Database = {

    ---------------------------------------------------------
    -- 
    -- Category Database Functions
    --
    ---------------------------------------------------------

    -- Get categories
    GetCategories = function()
        local categories = MySQL.query.await('SELECT * FROM `' .. IR8.Config.CategoriesTable .. '` ORDER BY title ASC')
        return categories
    end,

    -- Get category
    GetCategory = function(id)
        local category = MySQL.single.await('SELECT * FROM `' .. IR8.Config.CategoriesTable .. '` WHERE id = ?', {
            id
        })

        if category then
            category.blips = IR8.Database.GetBlips(category.id)
        end

        return category
    end,

    -- Creates a blip category
    CreateCategory = function (data)

        local query = 'INSERT INTO `' .. IR8.Config.CategoriesTable .. '`(title) VALUES(?)'
        local res = MySQL.insert.await(query, {
            data.title
        })

        return { success = res and true or false }
    end,

    -- Updates a blip category enabled status
    UpdateCategoryEnabled = function (id, enabled)
        local query = 'UPDATE `' .. IR8.Config.CategoriesTable .. '` SET enabled = ? WHERE id = ?'
        
        local res = MySQL.query.await(query, {
            enabled,
            id
        })

        return { success = res and true or false }
    end,

    -- Updates a blip category
    UpdateCategory = function (data)
        local query = 'UPDATE `' .. IR8.Config.CategoriesTable .. '` SET title = ? WHERE id = ?'
        
        local res = MySQL.query.await(query, {
            data.title,
            data.id
        })

        return { success = res and true or false }
    end,

    -- Deletes a blip category
    DeleteCategory = function (data)
        local query = 'DELETE FROM `' .. IR8.Config.CategoriesTable .. '` WHERE id = ?'
        
        local res = MySQL.query.await(query, {
            data.id
        })

        if data.deleteBlips then
            MySQL.query.await('DELETE FROM `' .. IR8.Config.BlipsTable .. '` WHERE category_id = ?', {
                data.id
            })
        else
            MySQL.query.await('UPDATE `' .. IR8.Config.BlipsTable .. '` SET category_id = NULL WHERE category_id = ?', {
                data.id
            })
        end

        return { success = res and true or false }
    end,

    ---------------------------------------------------------
    -- 
    -- Blip Database Functions
    --
    --------------------------------------------------------

    -- Get blips
    GetBlips = function(categoryId)
        local categories = IR8.Database.GetCategories()
        local blips = MySQL.query.await('SELECT * FROM `' .. IR8.Config.BlipsTable .. '` ORDER BY id ASC')

        if type(categoryId) == "number" then
            blips = MySQL.query.await('SELECT * FROM `' .. IR8.Config.BlipsTable .. '` WHERE category_id = ? ORDER BY id ASC', {
                categoryId
            })
        end

        -- Assign category data
        if type(blips) == "table" then
            for bk, blip in pairs(blips) do
                if blip.category_id then
                    for _, cat in pairs(categories) do
                        if cat.id == blip.category_id then
                            blips[bk].category = cat
                        end
                    end
                else
                    blips[bk].category = nil
                end
            end
        end

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

        local query = 'INSERT INTO `' .. IR8.Config.BlipsTable .. '`(title, blip_id, scale, color, display, short_range, positionX, positionY, positionZ, job, category_id) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
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
            data.job and data.job or "",
            data.category_id and data.category_id or nil
        })

        return { success = res and true or false }
    end,

    -- Updates a blip
    UpdateBlip = function (data)
        local position = IR8.Utilities.GetPositionFromString(data.position)

        if not position.valid then
            return { success = false, error = position.error }
        end

        local query = 'UPDATE `' .. IR8.Config.BlipsTable .. '` SET title = ?, blip_id = ?, scale = ?, color = ?, display = ?, short_range = ?, positionX = ?, positionY = ?, positionZ = ?, job = ?, category_id = ? WHERE id = ?'
        
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
            data.category_id and data.category_id or nil,
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

-- Create a default table for the IR8 object
IR8 = {}

------------------------------------------------------------
-- Blip Configuration
------------------------------------------------------------
IR8.Config = {

    -- Enables development printing
    Debugging = false,

    -- Server framework
    Framework = "qbcore", -- "esx" | "qbcore"

    -- Event related vars
    ServerCallbackPrefix = "ir8-blips:Server", -- Change this if you rename the resource folder
    ClientCallbackPrefix = "ir8-blips:Client", -- Change this if you rename the resource folder

    -- Table where blip categories are stored 
    CategoriesTable = "ir8_blips_category",

    -- Table where blips are stored
    BlipsTable = "ir8_blips",

    -- Command information
    Commands = {

        -- Command to manage blips
        ManageBlips = "blips",
        ManageBlipsDescription = "Manage map blips",

        -- Permissions for commands
        Permissions = {
            'group.admin'
        }
    },

    -- Customize NUI Theme
    Theme = {

        -- Title of the window
        Title = "Blip Manager",

        Colors = {

            -- Background of the modal window
            Background = "rgba(19, 22, 24, 0.9)",

            -- Text color
            Text = "#ffffff"
        }
    }
}
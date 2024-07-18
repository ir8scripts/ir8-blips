# Blips

This script is a real time blip manager for your server. Add / Update / and Delete blips on your map and when you're done, it will update for all players online in real time. With it's easy installation, you'll be managing your map blips in no time.

I know there are others out there, but I created this to be a bit more user friendly and easy to use.

If you need any support, feel free to reach out to us via our Discord: https://discord.gg/7NATz2Yw5a

### New in Version 1.0.4

- Moved Webhook Configuration to server-side
- Updated config to include theme variables and title for the modal window
- Removed duplicate colors in blip colors dropdown

### New in Version 1.0.2

- Restrict Blips by Job
- Webhook Configuration for logs of Creation / Updating / and Deletion.
- Blip Preview, switched from a number input to a select box
- Color configuration switched from a number input to a select box.

### Dependencies

- Supports both ESX and QBCore
- oxmysql
- ox_lib

### Database

Run the `__install/database.sql` file in your server's database.

### Drop the Resource

Download the main branch and drop the package into your resources folder and remember to `ensure ir8-blips` after `ox_lib` and `oxmysql`

### Configuration

The real configuration variables you need to set are for the following:

`Framework` and `Commands.Permissions`

### Webhook Configuration

You can set your webhook configuration from server/main.lua at the top of the file.

### Renaming the Resource

If you rename the resource folder, make sure you set the following configuration variables to match the folder name:

```
-- Event related vars
ServerCallbackPrefix = "ir8-blips:Server", -- Change this if you rename the resource folder
ClientCallbackPrefix = "ir8-blips:Client", -- Change this if you rename the resource folder
```
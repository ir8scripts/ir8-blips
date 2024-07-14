# Blips

This script acts as a real time blip manager for your server. Add / Update / and Delete blips on your map and when you're done, it will update for all players online in real time. With it's easy installation, you'll be managing your map blips in no time.

If you need any support, feel free to reach out to us via our Discord: https://discord.gg/wzEYNCN7pH

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

Drop the package into your resources folder and remember to `ensure ir8-blips` after `ox_lib` and `oxmysql`

### Configuration

The real configuration variables you need to set are for the following:

`Framework` and `Commands.Permissions`

### Renaming the Resource

If you rename the resource folder, make sure you set the following configuration variables to match the folder name:

```
-- Event related vars
ServerCallbackPrefix = "ir8-blips:Server", -- Change this if you rename the resource folder
ClientCallbackPrefix = "ir8-blips:Client", -- Change this if you rename the resource folder
```
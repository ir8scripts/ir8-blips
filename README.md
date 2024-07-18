# Blips

This script is a real time blip manager for your server. Add / Update / and Delete blips on your map and when you're done, it will update for all players online in real time. With it's easy installation, you'll be managing your map blips in no time.

I know there are others out there, but I created this to be a bit more user friendly and easy to use.

If you need any support, feel free to reach out to us via our Discord: https://discord.gg/7NATz2Yw5a

### New in Version 1.0.6
- UI reworked to support categories
- Ability to enable/disable categories and all blips under it with one click
- Ability to set a category for a blip from options management
- Thanks to simsonas86 for fivemerr logging support

### New in Version 1.0.5
- Better handling for framework init with NUI

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

### Upgrading from pre-v1.0.6

If you are upgrading from v1.0.5 or before, you must also run the following SQL:

```
/*
    The following SQL was added as of v1.0.6
    If you are upgrading from v1.0.5 or before, you must run the following.
*/

ALTER TABLE ir8_blips ADD category_id INT NULL;

CREATE TABLE IF NOT EXISTS ir8_blips_category
(
    id      int auto_increment primary key,
    title   varchar(255)     null,
    enabled int(2) default 1 null
);
```

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
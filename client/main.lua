-------------------------------------------------
-- 
-- STATE
-- 
-------------------------------------------------
Blips = {}
BlipsLoaded = false
PlayerData = {}
PlayerLoadedEvent = false
Framework = nil

-------------------------------------------------
-- 
-- PLAYER LOADED EVENT SETUP
-- 
-------------------------------------------------
if IR8.Config.Framework == "esx" then
  PlayerLoadedEvent = "esx:playerLoaded"
elseif IR8.Config.Framework == "qbcore" then
  PlayerLoadedEvent = "QBCore:Client:OnPlayerLoaded"
end

if PlayerLoadedEvent then
  IR8.Utilities.DebugPrint("[Framework.PlayerLoadedEvent] set to " .. PlayerLoadedEvent)
end

-------------------------------------------------
-- 
-- FRAMEWORK
-- 
-------------------------------------------------
Citizen.CreateThread(function()

  -- Check for ESX
  if IR8.Config.Framework == "esx" then

      Framework = exports["es_extended"]:getSharedObject()
      PlayerData = Framework.GetPlayerData()

      while PlayerData.job == nil do
          PlayerData = Framework.GetPlayerData()
          Citizen.Wait(100)
      end

      IR8.Utilities.DebugPrint("Framework [ESX] found. Setting PlayerData")

  -- Check for QBCore
  elseif IR8.Config.Framework == "qbcore" then

      Framework = exports['qb-core']:GetCoreObject()
      PlayerData = Framework.Functions.GetPlayerData()

      while PlayerData.job == nil do
          PlayerData = Framework.Functions.GetPlayerData()
          Citizen.Wait(100)
      end

      IR8.Utilities.DebugPrint("Framework [QBCore] found. Setting PlayerData")
      
  else
      print("Framework not found.")
  end
end)

-------------------------------------------------
-- 
-- LOAD BLIPS
-- 
-------------------------------------------------
function loadBlips ()
  Blips = lib.callback.await(IR8.Config.ServerCallbackPrefix .. 'LoadBlips', false)
  IR8.Utilities.DebugPrint("Loaded blips table:")
  IR8.Utilities.DebugPrint(json.encode(Blips))
  BlipsLoaded = true
end

-------------------------------------------------
-- 
-- DRAW BLIPS
-- 
-------------------------------------------------
function drawBlips ()
  -- If blips are not loaded
  if not BlipsLoaded then return end

  for k, blip in pairs(Blips) do

    -- Continue by default
    local continue = true

    -- Job check if one is needed
    if blip.job ~= "" and blip.job ~= nil then
      if blip.job and PlayerData.job.name ~= blip.job then continue = false end
    end

    if blip.category then
      if blip.category.enabled == 0 then
        continue = false
      end
    end

    if continue then
      Blips[k].blip = AddBlipForCoord(blip.positionX, blip.positionY, blip.positionZ)
      SetBlipSprite(Blips[k].blip, blip.blip_id)
      SetBlipDisplay(Blips[k].blip, blip.display)
      SetBlipScale(Blips[k].blip, blip.scale)
      SetBlipColour(Blips[k].blip, blip.color)
      SetBlipAsShortRange(Blips[k].blip, blip.short_range == '1' and true or false)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentSubstringPlayerName(blip.title)
      EndTextCommandSetBlipName(Blips[k].blip)
    end
  end
end

-------------------------------------------------
-- 
-- REMOVE BLIPS
-- 
-------------------------------------------------
function removeBlips ()

  for k, blip in pairs(Blips) do
    if Blips[k].blip then
      RemoveBlip(Blips[k].blip)
    end
  end

  Blips = {}
  BlipsLoaded = false
end

-------------------------------------------------
-- 
-- THREADING
-- 
-------------------------------------------------
Citizen.CreateThread(function()
  if not BlipsLoaded then
    loadBlips()
  end

  while not BlipsLoaded do
    Wait(1000)
  end

  drawBlips()

  -- If framework not found, attempt to init here
  if not PlayerLoadedEvent then
    SendNUIMessage({ 
      action = "init", 
      debug = IR8.Config.Debugging,
      theme = IR8.Config.Theme
    })
  end
end)

-------------------------------------------------
-- 
-- EVENTS
-- 
-------------------------------------------------

-- PlayerLoaded event handler based on framework
if PlayerLoadedEvent then
  RegisterNetEvent(PlayerLoadedEvent)
  AddEventHandler (PlayerLoadedEvent, function()
    SendNUIMessage({ 
      action = "init", 
      debug = IR8.Config.Debugging,
      theme = IR8.Config.Theme
    })
  end)
end

-- Show blips
RegisterNetEvent(IR8.Config.ClientCallbackPrefix .. "SetBlips")
AddEventHandler (IR8.Config.ClientCallbackPrefix .. "SetBlips", function(blips)
    removeBlips()
    Blips = blips
    BlipsLoaded = true
    drawBlips()
end)

-- Show the NUI
RegisterNetEvent(IR8.Config.ClientCallbackPrefix .. "ShowNUI")
AddEventHandler (IR8.Config.ClientCallbackPrefix .. "ShowNUI", function()
  local categories = lib.callback.await(IR8.Config.ServerCallbackPrefix .. 'Categories', false)
  SendNUIMessage({ action = "show", categories = categories, theme = IR8.Config.Theme })
  SetNuiFocus(true, true)
end)

-------------------------------------------------
-- 
-- JOB UPDATE EVENTS
-- 
-------------------------------------------------

if IR8.Config.Framework == "esx" then

  -- When job is updated for ESX
  RegisterNetEvent('esx:setJob')
  AddEventHandler('esx:setJob', function(job)
      PlayerData.job = job
      removeBlips()
      loadBlips()
      drawBlips()
  end)

-- Check for QBCore
elseif IR8.Config.Framework == "qbcore" then

  -- When job is updated for QBCore
  RegisterNetEvent('QBCore:Client:OnJobUpdate')
  AddEventHandler('QBCore:Client:OnJobUpdate', function(job)
      PlayerData.job = job
      removeBlips()
      loadBlips()
      drawBlips()
  end)
  
end

-------------------------------------------------
-- 
-- NUI EVENTS
-- 
-------------------------------------------------

-- Hide NUI
RegisterNUICallback('hide', function(_, cb)
  SendNUIMessage({ action = "hide"  })
  SetNuiFocus(false, false)
  cb({})
end)

-------------------------------------------------
-- 
-- CATEGORY NUI EVENTS
-- 
-------------------------------------------------

-- Blip creation
RegisterNUICallback('category_create', function(data, cb)
  local res = lib.callback.await(IR8.Config.ServerCallbackPrefix .. 'Category_Create', false, data)

  if res.success then
    SendNUIMessage({ action = "category_update", categories = res.categories })
  end

  cb(res)
end)

-- Blip update
RegisterNUICallback('category_update', function(data, cb)
  local res = lib.callback.await(IR8.Config.ServerCallbackPrefix .. 'Category_Update', false, data)

  if res.success then
    SendNUIMessage({ action = "category_update", categories = res.categories })
  end

  cb(res)
end)

-- Blip update
RegisterNUICallback('category_enabled', function(data, cb)
  local res = lib.callback.await(IR8.Config.ServerCallbackPrefix .. 'Category_Enabled', false, data)

  cb(res)
end)

-- Blip delete
RegisterNUICallback('category_delete', function(data, cb)
  local res = lib.callback.await(IR8.Config.ServerCallbackPrefix .. 'Category_Delete', false, data)

  if res.success then
    SendNUIMessage({ action = "category_update", categories = res.categories })
  end

  cb(res)
end)

-- Blips for category
RegisterNUICallback('category_blips', function(data, cb)
  local res = lib.callback.await(IR8.Config.ServerCallbackPrefix .. 'Category_Blips', false, data)
  cb(res)
end)

-------------------------------------------------
-- 
-- BLIP NUI EVENTS
-- 
-------------------------------------------------

-- Blip creation
RegisterNUICallback('create', function(data, cb)
  local res = lib.callback.await(IR8.Config.ServerCallbackPrefix .. 'Create', false, data)

  if res.success then
    SendNUIMessage({ action = "update", blips = res.blips })
  end

  cb(res)
end)

-- Blip update
RegisterNUICallback('update', function(data, cb)
  local res = lib.callback.await(IR8.Config.ServerCallbackPrefix .. 'Update', false, data)

  if res.success then
    SendNUIMessage({ action = "update", blips = res.blips })
  end

  cb(res)
end)

-- Blip delete
RegisterNUICallback('delete', function(data, cb)
  local res = lib.callback.await(IR8.Config.ServerCallbackPrefix .. 'Delete', false, data)

  if res.success then
    SendNUIMessage({ action = "update", blips = res.blips })
  end

  cb(res)
end)

-------------------------------------------------
-- 
-- MISC NUI EVENTS
-- 
-------------------------------------------------

-- Position request
RegisterNUICallback('position', function(_, cb)
  local playerCoords = GetEntityCoords(PlayerPedId())
  local position = playerCoords.x .. ", " .. playerCoords.y .. ", " .. playerCoords.z
  cb({ position = position })
end)

-- Teleport request
RegisterNUICallback('teleport', function(data, cb)
  SetEntityCoords(PlayerPedId(), data.x, data.y, data.z)
  cb({ })
end)

-------------------------------------------------
-- 
-- ON RESOURCE START
-- 
-------------------------------------------------
AddEventHandler('onResourceStart', function(resource)
  if resource == GetCurrentResourceName() then
    SendNUIMessage({ 
      action = "init", 
      debug = IR8.Config.Debugging,
      theme = IR8.Config.Theme
    })
  end
end)

-------------------------------------------------
-- 
-- CLEANUP ON RESOURCE STOP
-- 
-------------------------------------------------
AddEventHandler('onResourceStop', function(resource)
  if resource == GetCurrentResourceName() then
    if BlipsLoaded then
      IR8.Utilities.DebugPrint('Removing blips due to script stop.')
      removeBlips()
    end
  end
end)
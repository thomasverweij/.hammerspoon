-- load config
require("conf.config")
local config = hs.settings.get("config")

-- global hyper key
local hyper = {"ctrl", "alt", "cmd"}

-- keybindings config
require("lib.keyBindings")

-- displaylink
require("lib.displaylink")

-- Window manager
local windowManager = require("lib.windowManager")
hs.window.animationDuration = 0
windowManager.ultrawideMonitor = config.wm_ultrawide
windowManager:bindHotkeys({
  up = {hyper, "up"},
  right = {hyper, "right"},
  left = {hyper, "left"},
  fullscreen = {hyper, "f"},
  middle = {hyper, "g"},
  fullscreenAll = {hyper,"r"}
})

-- snapdrag. disabled because of lack of multi monitor support
-- require("lib.snapdrag")

-- hassMenu config 
local hassMenu = require("lib.hassMenu")
hassMenu.host = config.hass_host 
hassMenu.authToken = config.hass_token
hassMenu.getScenes()

-- inputSwitch config
-- inputSwitch = require("lib.inputSwitch")
-- inputSwitch.devices = config.inputswitch_devices
-- inputSwitch.watcher:start()
-- hs.hotkey.bind(hyper, 'f12', inputSwitch.switch)

-- Menu
local menuTable = function() 
  return {
    {title = "Window management", disabled = true},
    {title = "All fullscreen", shortcut = "f", fn = function() windowManager:_fullscreenAll() end},
    {title = "All middle screen", shortcut = "m", fn = function() windowManager:_middleAll() end},
    {title = "-"},
    {title = "Home", disabled = true },
    {title = "Toggle lights", checked = hassMenu.lightState, shortcut = "o", fn = function() hassMenu.toggleLights() end},
    {title = "Scenes", menu = hassMenu.scenes},
    {title = "-"},
    {title = "System", disabled = true },
    -- {title = "Sleep", shortcut = "s", fn = function() hs.caffeinate.systemSleep() end},
    {title = "Screenshot", shortcut = "s", fn = function() hs.application.launchOrFocus('screenshot') end},
    {title = "Lock", shortcut = "l", fn = function() hs.caffeinate.startScreensaver() end},
    {title = "Settings", shortcut = "p", fn = function() hs.application.launchOrFocus('System Settings') end},
  }
end

local menuItem = hs.menubar.new(false)
menuItem:setTitle('hs')
menuItem:setMenu(menuTable)

-- configure doublepress command key

local cmdDoublePress = require("lib.cmdDoublePress")
cmdDoublePress.timeFrame = .3
cmdDoublePress.action = function()
  hassMenu.getLightState()
  menuItem:setMenu(menuTable)
  menuItem:popupMenu(hs.mouse.absolutePosition(), true)
end

-- load secrets
require("secrets").load(".secrets.json")

-- global hyper key
local hyper = {"ctrl", "alt", "cmd"}

-- Window manager config
hs.loadSpoon("MiroWindowsManager")
hs.window.animationDuration = 0
spoon.MiroWindowsManager:bindHotkeys({
  up = {hyper, "up"},
  right = {hyper, "right"},
  down = {hyper, "down"},
  left = {hyper, "left"},
  fullscreen = {hyper, "f"},
  middle = {hyper, "g"},
  fullscreenAll = {hyper,"r"},
  middleAll = {hyper,"t"}
})

-- remotehid config
hs.loadSpoon("RemoteHID")
spoon.RemoteHID.port = "7638"           --server port (default: 7638)
spoon.RemoteHID.interface = nil         --interface (default: nil)

-- hassMenu config 
hassMenu = require("hassMenu")
hassMenu.host = "10.200.210.5:8123"
hassMenu.authToken = hs.settings.get("secrets").hass_token


-- inputSwitch config
inputSwitch = require("inputSwitch")

-- Menu
menuTable = {
  {title = "Window management", disabled = true},
  {title = "All fullscreen", shortcut = "f", fn = function() spoon.MiroWindowsManager:_fullscreenAll() end},
  {title = "All middle screen", shortcut = "m", fn = function() spoon.MiroWindowsManager:_middleAll() end},
  {title = "-"},
  {title = "RemoteHID", disabled = true},
  {title = "Start", shortcut = "r", fn = function() spoon.RemoteHID:start() end},
  {title = "-"},
  {title = "Home", disabled = true },
  {title = "Toggle lights", shortcut = "o", fn = function() hassMenu.toggleLights() end},
  {title = "Scenes", menu = hassMenu.getMenuItems()},
  {title = "-"},
  {title = "System", disabled = true },
  {title = "Toggle input", shortcut = "t", fn = function() inputSwitch:switch() end},
  {title = "Lock", shortcut = "l", fn = function() hs.caffeinate.startScreensaver() end},
  {title = "Sleep", shortcut = "s", fn = function() hs.caffeinate.systemSleep() end},
  {title = "Preferences", shortcut = "p", fn = function() hs.application.launchOrFocus('System Preferences') end}
}

menuItem = hs.menubar.new(false)
menuItem:setTitle('hs')
menuItem:setMenu(menuTable)

cmdDoublePress = require("cmdDoublePress")
cmdDoublePress.timeFrame = .3
cmdDoublePress.action = function()
  menuItem:popupMenu(hs.mouse.absolutePosition(), true)
end

-- enable cli
require("hs.ipc")

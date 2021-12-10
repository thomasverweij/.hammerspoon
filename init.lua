-- secrets

require("secrets").load(".secrets.json")

-- global hyper key

local hyper = {"ctrl", "alt", "cmd"}

-- bluetooth of when sleeping

-- require "bluetoothSleep"

-- Window manager

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

-- remotehid

hs.loadSpoon("RemoteHID")
spoon.RemoteHID.port = "7638"           --server port (default: 7638)
spoon.RemoteHID.interface = nil         --interface (default: nil)

-- spoon.RemoteHID:bindHotKeys({           --bind hotkeys (available commands: start, stop):
--     start={hyper, "s"},
--     stop={hyper, "a"}
-- })


-- Menu 
hass_token = hs.settings.get("secrets").hass_token

menuTable = {
  -- {title = "Applications", disabled = true},
  -- {title = "Terminal", shortcut = "t", fn = function() hs.application.launchOrFocus('iTerm') end},
  -- {title = "Visual Studio Code", shortcut = "c", fn = function() hs.application.launchOrFocus('Visual Studio Code') end},
  -- {title = "Browser", shortcut = "b", fn = function() hs.application.launchOrFocus('Safari') end},
  -- {title = "-"},
  {title = "Window management", disabled = true},
  {title = "All fullscreen", shortcut = "f", fn = function() spoon.MiroWindowsManager:_fullscreenAll() end},
  {title = "All middle screen", shortcut = "m", fn = function() spoon.MiroWindowsManager:_middleAll() end},
  {title = "-"},
  {title = "RemoteHID", disabled = true},
  {title = "Start", shortcut = "r", fn = function() spoon.RemoteHID:start() end},
  {title = "-"},
  {title = "Home", disabled = true },
  {title = "Toggle lights", shortcut = "o", fn = function() 
      hs.http.asyncPost("http://10.200.210.4:8123/api/services/switch/toggle", "{\"entity_id\": \"switch.niet_bed\"}",  {Authorization=hass_token}, function() end)
    end
  },
  {title = "-"},
  {title = "System", disabled = true },
  {title = "Lock", shortcut = "l", fn = function() hs.caffeinate.startScreensaver() end}, -- Make sure system is configured to lock immediatly after starting screensaver
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


require("hs.ipc")

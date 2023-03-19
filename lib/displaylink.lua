module = {}
module.state = false

function displaylinkOn()
    hs.application.open("DisplayLink Manager")
end

function displaylinkOff()
    hs.application.find("displaylinkuseragent", false):kill()
end

function fluxOff()
    hs.application.find("flux", false):kill()
end


function fluxOn()
    hs.application.open("Flux")
end

function nightlightOn()
    local t = hs.task.new("/opt/homebrew/bin/nightlight", result_callback, {"on"})
    t:start()
end

function nightlightOff()
    local t = hs.task.new("/opt/homebrew/bin/nightlight", result_callback, {"off"})
    t:start()
end

function dockConnected()
    displaylinkOn()
    nightlightOff()
    fluxOn()
    module.state = true
end

function dockDisconnected()
    displaylinkOff()
    nightlightOn()
    fluxOff()
    module.state = false
end

function result_callback(rc, stdout, stderr)
    if rc ~= 0 then
        print(string.format("Error: rc=%d stderr=%s stdout=%s", rc, stderr, stdout))
    end
end

function watcherFunction(event)
    if event.productName == "Logi Dock" then
        if event.eventType == "removed" then
            dockDisconnected()
        end
        if event.eventType == "added" then
            dockConnected()
        end
    end
end

module.switchState = function()
    if module.state then
        dockDisconnected()
    else
        dockConnected()
    end
end

function startUp()
    local flux = hs.application.find('flux')
    local dl = hs.application.find('displaylinkuseragent')
    local dock = hs.fnutils.find(hs.usb.attachedDevices(), function(x) return x.productName == "Logi Dock" end)
    if (not (flux and dl)) and dock then
        dockConnected()
    end
end


watcher = hs.usb.watcher.new(watcherFunction)
watcher:start()
startUp()

return module
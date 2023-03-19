module = {}
module.state = true

function displaylinkOn()
    hs.application.open("DisplayLink Manager")
end

function displaylinkOff()
    hs.application.find("Displaylink", false):kill()
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
        print('disconnect')
        dockDisconnected()
    else
        print('connect')
        dockConnected()
    end
end

watcher = hs.usb.watcher.new(watcherFunction)
watcher:start()

return module
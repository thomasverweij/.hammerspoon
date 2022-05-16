require "string"

module = {}
module.devices = {"c0:a5:3e:05:7f:93", "a8:91:3d:e5:a4:bb"}
module.usbwatcher_productid = 2082

function log_error(exitCode, stdOut, stdErr)
    if exitCode ~= 0 then
        print(string.format("Error: rc=%d stderr=%s stdout=%s", exitCode, stdOut, stdErr))
    end
end

function connect_device(mac)
    local t = hs.task.new("/usr/local/bin/blueutil", log_error, {"--connect", mac})
    t:start()
end

function pair_device(mac)
    local t = hs.task.new("/usr/local/bin/blueutil", function(exitCode, stdOut, stdErr)
        log_error(exitCode, stdOut, stdErr)
        connect_device(mac)
    end, {"--pair", mac})
    t:start()
end

function switch_device_off(mac)
    local t = hs.task.new("/usr/local/bin/blueutil", log_error, {"--unpair", mac})
    t:start()
end

function switch_device_on(mac)
    local t = hs.task.new("/usr/local/bin/blueutil", function(exitCode, stdOut, stdErr)
        log_error(exitCode, stdOut, stdErr)
        pair_device(mac)
    end, {"--unpair", mac})
    t:start()
end

function switch_device(mac)
    local t = hs.task.new("/usr/local/bin/blueutil", function(exitCode, stdOut, stdErr)

        log_error(exitCode, stdOut, stdErr)

        if stdOut == "1\n" then
            switch_device_off(mac)
        else
            switch_device_on(mac)
        end
    end, {"--is-connected", mac})
    t:start()
end

module.connect = function(mac)
    switch_device_on(mac)
end

module.disconnect = function(mac)
    switch_device_off(mac)
end

module.switch = function()
    hs.fnutils.each(module.devices, function(d)
        print("switching " .. d)
        switch_device(d)
    end)
end

function usb_callback(e)
    if e.eventType == "added" and e.productID == module.usbwatcher_productid then
        hs.fnutils.each(module.devices, function(d)
            print("connecting " .. d)
            module.connect(d)
        end)
    elseif e.eventType == "removed" and e.productID == module.usbwatcher_productid then
        hs.fnutils.each(module.devices, function(d)
            print("disconnecting " .. d)
            module.disconnect(d)
        end)
    end
  end
   
module.watcher = hs.usb.watcher.new(usb_callback)

return module
require "string"

module = {}
keyboard = "c0:a5:3e:05:7f:93"
trackpad = "a8:91:3d:e5:a4:bb"

function log_error(exitCode, stdOut, stdErr)
    if exitCode ~= 0 then
        print(string.format("Error: rc=%d stderr=%s stdout=%s", exitCode, stdOut, stdErr))
    end
end

function connect_device(mac)
    local t = hs.task.new("/usr/local/bin/blueutil", log_error, {"--connect", mac})
    t:start()
end

function switch_device_on(mac)
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

function switch_device(mac)
    local t = hs.task.new("/usr/local/bin/blueutil", function(exitCode, stdOut, stdErr)

        log_error(exitCode, stdOut, stdErr)

        if stdOut == "1\n" then
            print("device is connected: unpair")
            switch_device_off(mac)
        else
            print("device is not connected: pair and connect")
            switch_device_on(mac)
        end
    end, {"--is-connected", mac})
    t:start()
end

module.switch = function()
    print("switching keyboard")
    switch_device(keyboard)
    print("switching trackpad")
    switch_device(trackpad)
end

return module
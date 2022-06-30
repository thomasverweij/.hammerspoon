require "string"

device = "04-5d-4b-82-81-17"

function bluetooth(state)
    local t = hs.task.new("/usr/local/bin/blueutil", result_callback, {"--power", state})
    t:start()
end

function connect(id)
    local t = hs.task.new("/usr/local/bin/blueutil", result_callback, {"--connect", id})
    t:start()
end

function result_callback(rc, stdout, stderr)
    if rc ~= 0 then
        print(string.format("Error: rc=%d stderr=%s stdout=%s", rc, stderr, stdout))
    end
end

function wake_callback(rc, stdout, stderr)
    if rc == 0 then
        connect(device)
    else
        print(string.format("Error: rc=%d stderr=%s stdout=%s", rc, stderr, stdout))
    end
end

function watcher_callback(event)
    if event == hs.caffeinate.watcher.systemWillSleep then
        bluetooth("off")
    elseif event == hs.caffeinate.watcher.screensDidWake then
        bluetooth("on")
        hs.task.new("/bin/sleep", wake_callback, {"1"}):start()
    end
end

watcher = hs.caffeinate.watcher.new(watcher_callback)
watcher:start()

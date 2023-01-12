local hotkey = {'ctrl','alt','cmd'}

function bind_key(mod, key, func)
    hs.hotkey.bind(mod, key, nil, func, func, func):enable()
end

function system_key(key)
    hs.eventtap.event.newSystemKeyEvent(key, true):post()
    hs.timer.usleep(10)
    hs.eventtap.event.newSystemKeyEvent(key, false):post()
end

function volume_up()
    system_key('SOUND_UP')
end

function volume_down()
    system_key('SOUND_DOWN')
end

function mute()
    system_key('MUTE')
end

function brightness_up()
    system_key('BRIGHTNESS_UP')
end

function brightness_down()
    system_key('BRIGHTNESS_DOWN')
end

function keyboard_up()
    system_key('ILLUMINATION_UP')
end

function keyboard_down()
    system_key('ILLUMINATION_DOWN')
end


bind_key(hotkey, '=', volume_up)
bind_key(hotkey, '-', volume_down)
bind_key(hotkey, '2', brightness_up)
bind_key(hotkey, '1', brightness_down)
bind_key(hotkey, '0', mute)
bind_key(hotkey, '4', keyboard_up)
bind_key(hotkey, '3', keyboard_down)

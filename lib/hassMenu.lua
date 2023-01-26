local timer = require("hs.timer")

local module   = {}

module.authToken = ""
module.host = ""
module.scenes = nil
module.lightState = false

module.turnOnScene = function(sceneId)
    hs.http.asyncPost("http://" .. module.host .. "/api/services/scene/turn_on", "{\"entity_id\": \"" .. sceneId .. "\"}",  {Authorization=module.authToken}, function() 
        module.lightState = true
    end)
end

module.toggleLights = function()
    hs.http.asyncPost("http://" .. module.host .. "/api/services/switch/toggle", "{\"entity_id\": \"switch.niet_bed\"}",  {Authorization=module.authToken}, function() 
        module.lightState = not module.lightState
    end)
end

module.getMenuItems = function()
    scenes = module.getScenes()
    if not scenes then
        return nil
    end
    
end    

module.getScenes = function() 
    hs.http.asyncGet("http://" .. module.host .. "/api/states", {Authorization=module.authToken}, function(status, body, headers) 
        if status == 200 then
            local scenes = hs.fnutils.filter(
                hs.json.decode(body), 
                function(x) 
                    return string.find(x.entity_id, "scene.") == 1
                end
            )
            local scenes_names = hs.fnutils.map(scenes, function(x) return x.entity_id end)
            module.scenes = hs.fnutils.map(scenes_names, function(x) return {title = x, fn = function() module.turnOnScene(x) end} end)
        else
            return nil
        end
    end)
end

module.getLightState = function()

    hs.http.asyncGet("http://" .. module.host .. "/api/states/switch.nightlight", {Authorization=module.authToken}, function(status, body, headers) 
        if status == 200 then
            local state = hs.json.decode(body).state
            if state == "on" then
                module.lightState = true
            else
                module.lightState = false
            end
        end
    end)

    return module.lightState
end

-- local pollTimer = timer.new(5, module.getLightState)
-- pollTimer:start()

return module
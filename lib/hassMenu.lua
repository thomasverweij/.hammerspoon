local module   = {}

module.authToken = ""
module.host = ""
module.getScenes = function()
    local status, body, headers = hs.http.get("http://" .. module.host .. "/api/states", {Authorization=module.authToken})
    print(status)

    if status == 200 then
        local scenes = hs.fnutils.filter(
            hs.json.decode(body), 
            function(x) 
                return string.find(x.entity_id, "scene.") == 1
            end
        )
        local scenes_names = hs.fnutils.map(scenes, function(x) return x.entity_id end)
        return scenes_names
    else
        return nil
    end
end

module.turnOnScene = function(sceneId)
    hs.http.asyncPost("http://" .. module.host .. "/api/services/scene/turn_on", "{\"entity_id\": \"" .. sceneId .. "\"}",  {Authorization=module.authToken}, function() end)
end

module.toggleLights = function()
    hs.http.asyncPost("http://" .. module.host .. "/api/services/switch/toggle", "{\"entity_id\": \"switch.niet_bed\"}",  {Authorization=module.authToken}, function() end)
end

module.getMenuItems = function()
    scenes = module.getScenes()
    if not scenes then
        return nil
    end
    return hs.fnutils.map(scenes, function(x) return {title = x, fn = function() module.turnOnScene(x) end} end)
end    

return module
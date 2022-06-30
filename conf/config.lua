module = {}

module.load = function(filename)
  if hs.fs.attributes(filename) then
    hs.settings.set("config", hs.json.read(filename))
  else
    print("Secrets not found: " .. filename)
  end
end

module.load('conf/.config.lua')
return module
module = {}

module.load = function(filename)
  if hs.fs.attributes(filename) then
    hs.settings.set("secrets", hs.json.read(filename))
  else
    print("Secrets not found: " .. filename)
  end
end

return module
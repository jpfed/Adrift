require 'lunity'

stuff = { 'Explosion', 'Geom', 'Poly' }

-- TODO: how to require every test_ file?
for k,v in ipairs(stuff) do
  print("Running " .. v)
  require("test_" .. v)
  lunity.__runAllTests("TEST_" .. string.upcase(), { useANSI = true })
end


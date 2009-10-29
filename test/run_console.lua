require 'lunity'
require 'string'

-- TODO: how to require every test_ file?
stuff = { 'Explosion', 'Geom', 'Poly', 'PriorityQueue', 'QuadTree', 'Triangle' }

for k,v in ipairs(stuff) do
  print("Running " .. v)
  require("test_" .. v)
  -- TODO: only do ANSI if NOT windows... also, have an HTML env option...
  lunity.__runAllTests(lunity["TEST_" .. v:upper()], { useANSI = true })
end


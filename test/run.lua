require 'lunity'
require 'string'

function run(v)
  require(v)
  local opts
  
  if os.getenv("TEST_FORMAT") == "HTML" then
    opts = { useHTML = true }
  elseif os.getenv("OS") == "win" then
    opts = { useANSI = false }
  else
    opts = { useANSI = true }
  end

  lunity.__runAllTests(lunity[v:upper()], opts)
end

if arg[1] then
  for i = 1,10 do
    if arg[i] then
      run(arg[i])
    end
  end
else
  -- TODO: how to require every test_ file automatically?
  stuff = { 'test_Explosion', 'test_Geom', 'test_Poly', 'test_PriorityQueue', 'test_QuadTree', 'test_Triangle' }

  for k,v in ipairs(stuff) do
    run(v)
  end
end

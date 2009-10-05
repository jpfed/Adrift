require 'lunity'
require 'love_test'
love.filesystem.require("util/geom.lua")
module( 'TEST_GEOM', lunity )

function test_IntersectParallel()
  local p1 = {x=0, y=0}
  local p2 = {x=10, y=0}
  local p3 = {x=0, y=10}
  local p4 = {x=10, y=10}

  assertFalse( geom.intersect(p1,p2,p3,p4) )
end

function test_IntersectSharingEndpoint()
  local p1 = {x=0, y=0}
  local p2 = {x=10, y=10}
  local p3 = {x=0, y=10}
  local p4 = {x=10, y=10}

  assertFalse( geom.intersect(p1,p2,p3,p4) )
end


function test_Intersect()
  local p1 = {x=0, y=0}
  local p2 = {x=10, y=10}
  local p3 = {x=0, y=10}
  local p4 = {x=10, y=0}

  assertTrue( geom.intersect(p1,p2,p3,p4) )
end

runTests { useANSI = true }

require 'lunity'
require 'love_test'
love.filesystem.require("util/triangle.lua")
module( 'TEST_TRIANGLE', lunity )

function test_MakesTriangles()
  local t = Triangle:create(0,0,3,0,3,4)
  assertTableEquals( t, {0,0,3,0,3,4} )
end

function test_TrianglesNotOverlapping()
  local t1 = Triangle:create(0,0,3,0,3,4)
  local t2 = Triangle:create(100,0,13,0,13,4)
end

runTests { useANSI = false }

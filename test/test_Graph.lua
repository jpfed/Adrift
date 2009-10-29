require 'lunity'
require 'love_test'
love.filesystem.require("util/Graph.lua")
module( 'TEST_GRAPH', lunity )

function test_Create()
  local g = Graph:create()
  assert(g ~= nil)
end

function test_AddNode()
  local g = Graph:create()
  local n1 = g:addNode()
  assert(n1 ~= nil)
end

function test_AddArc()
  local g = Graph:create()
  local n1 = g:addNode()
  local n2 = g:addNode()
  local a = g:addArc(n1,n2)
  assert(a ~= nil)
end

function test_ShortestPath1()
  local g = Graph:create()
  local root = g:addNode()
  local deadend = g:addNode()
  local long1 = g:addNode()
  local long2 = g:addNode()
  local long3 = g:addNode()
  local short1 = g:addNode()
  local short2 = g:addNode()
  local deadend2 = g:addNode()
  local goal = g:addNode()
  
  g:addArc(root, deadend)
  
  g:addArc(root, long1)
  g:addArc(long1, long2)
  g:addArc(long2, long3)
  g:addArc(long3, goal)
  g:addArc(long2, deadend2)
  
  g:addArc(root, short1)
  g:addArc(short1, short2)
  g:addArc(short2, goal)
  g:addArc(short1, deadend2)
  
  local path = g:shortestPath(root,goal)
  assert(path ~= nil)
  assert(path[1] == root)
  assert(path[2] == short1)
  assert(path[3] == short2)
  assert(path[4] == goal)
  assert(#path == 4)
end


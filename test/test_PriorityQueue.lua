require 'lunity'
require 'love_test'
love.filesystem.require("util/PriorityQueue.lua")
module( 'TEST_PRIORITY_QUEUE', lunity )

function test_Create()
  local pq = PriorityQueue:create()
end

function test_Insert()
  local pq = PriorityQueue:create()
  local currentBest = 2
  for count = 1,1000 do
    local p = math.random()
    currentBest = math.min(currentBest, p)
    pq:insert({priority = p})
  end
  assert(pq:checkTop().priority == currentBest)
end

function test_RemoveTop()
  local pq = PriorityQueue:create()
  pq:insert({priority = 5})
  pq:insert({priority = 3})
  pq:insert({priority = 7})
  pq:insert({priority = 2})
  pq:insert({priority = 8})
  pq:insert({priority = 1})
  pq:insert({priority = 9})
  pq:insert({priority = 6})
  assert(pq:removeTop().priority == 1)
  assert(pq:removeTop().priority == 2)
  assert(pq:removeTop().priority == 3)
  assert(pq:removeTop().priority == 5)
  assert(pq:removeTop().priority == 6)
  assert(pq:removeTop().priority == 7)
  assert(pq:removeTop().priority == 8)
  assert(pq:removeTop().priority == 9)
end

runTests { useANSI = true }

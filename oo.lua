mixin = function(destination, source)
  for k,v in pairs(source) do
    destination[k] = v
  end
end

AisInstanceOfB = function(object, class)
  if object == nil then return false end
  if object == class or object.class == class then return true end
  return AisInstanceOfB(object.super,class)
end

printall = function(object, name)
  print(name .. ": " .. tostring(object))
  for k,v in pairs(object) do
    print(name .. ": " .. tostring(k) .. ": " .. tostring(v))
  end
end
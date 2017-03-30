if _G.EONZ_VECTOR_LOADED then
  error("lunar vector loaded twice")
else
  _G.EONZ_VECTOR_LOADED = true
end

local vector = {type='vector'} ; vector.__index = vector
local vector_metatable = {} ; setmetatable(vector, vector_metatable)

function vector.new (x, y) -- specific constructor
  local self = setmetatable({}, vector)
  
  assert(x and type(x) == 'number', 'missing x coordinate')
  assert(y and type(y) == 'number', 'missing y coordinate')
  
  self.x = x
  self.y = y
  
  return self
end

function vector.zero() -- zero constructor
  return vector.new(0, 0)
end

function vector.polar(theta, radius)
  return vector.new(math.cos(theta) * radius, math.sin(theta) * radius)
end

function vector.clone(other) -- clones another vector
  
  -- Note that this can also be called as vector_instance:clone() to clone
  -- the vector you call it on.
  
  return vector.new(other.x, other.y)
  
end

function vector_metatable.__call (table, ...) -- psuedo-overloaded constructor
  
  -- This constructor is slower than the others, so it is not
  -- suggested for use in frequently called code. 
  
  -- It can dispatch to vector.zero, vector.new, and can also
  -- derive a vector from an array, or from a table that has
  -- x and y members. This includes other vectors, making this
  -- a copy constructor.
  
  
  local args = {...}
  
  if #args == 0 then
    return vector.zero()
  elseif #args == 1 then
    if type(args[1] == "table") then
      if args[1].x and args[1].y then
        return vector.new(args[1].x, args[1].y)
      else
        return vector.new(unpack(args[1]))
      end
    else
      error('expected single argument to be an array-like table')
    end
  elseif #args == 2 then
    return vector.new(args[1], args[2])
  else
    error('expected zero, one, or two arguments')
  end
end

function vector:__tostring () -- Returns a string representation of the vector formatted as: {x, y}
  return '{' .. self.x .. ', ' .. self.y .. '}'
end

function vector.isVector (thing) -- Tests if the argument is a first-class vector. 
  return getmetatable(thing) == vector
end

function vector.areVectors (...) -- Tests if each of the arguments are first-class vectors.
  local args = {...}
  
  for i = 1, #args do
    if not vector.isVector(args[i]) then
      return false
    end
  end
  
  return true
end

local function assert_vectors(...) -- Asserts that each of the arguments are first-class vectors.
  assert(vector.areVectors(...), "expected vectors")
end

function vector.__eq (a, b) -- Tests for equality between two vector-like tables.
  return a.x == b.x and a.y == b.y
end

function vector.__add (a, b) -- Adds two vector-like tables.
  assert_vectors(a, b)
  return vector.new(a.x + b.x, a.y + b.y)
end

function vector.__sub (a, b) -- Subtracts one vector-like table from another.
  assert_vectors(a, b)
  return vector.new(a.x - b.x, a.y - b.y)
end

function vector.__mul (a, b) -- Multiplies a vector by a vector-like table or scalar.

  -- Vector to vector multiplication is done component-wise.
  --
  -- Note that the left hand side must always be a vector.
  
  if type(b) == 'table' then
    return vector.new(a.x * b.x, a.y * b.y)
  elseif type(b) == 'number' then
    return vector.new(a.x * b, a.y * b)
  else
    error("expected number or vector-like table on right side of vector multiplication")
  end
  
end

function vector.__div (a, b) -- Divides a vector by a vector-like table or scalar.

  -- Vector to vector division is done component-wise.
  --
  -- Note that the left hand side must always be a vector.
  
  if type(b) == 'table' then
    return vector.new(a.x / b.x, a.y / b.y)
  elseif type(b) == 'number' then
    return vector.new(a.x / b, a.y / b)
  else
    error("expected number or vector-like table on right side of vector division")
  end
  
end

function vector.__unm (v) -- Negates the vector.
  -- This function will technically also work on vector-like tables, but it will
  -- need to be called explicitly as vector.__unm(table), which is a bit clumsy.
  
  -- Unless you need the performance, I'd suggest -vector(table) for readability.
  
  return vector.new(-v.x, -v.y)
end

function vector:scale(scalar) -- Returns a new vector equal to this vector multiplied by a scalar.
  
  -- This is a legacy function, but is marginally faster than the multiplication 
  -- metamethod as it does not need to disambiguate between vectors and scalars.
  
  return vector.new(self.x * scalar, self.y * scalar)
end

function vector:dot(other) -- Returns the dot product of two vector-like tables.
  return self.x * other.x + self.y * other.y
end

function vector:length2 () -- Returns the square of the length of a vector-like table.
  return self.x * self.x + self.y * self.y
end

function vector:length () -- Returns the length of a vector-like table.
  return math.sqrt(self:length2())
end

function vector:normal () -- Returns a new vector equal to the normalized value of the current vector.
  local len = self:length()
  
  if len == 0 then
    return vector.zero()
  else 
    return vector.new(self.x / len, self.y / len)
  end
end

function vector:orthogonal () -- Returns a new vector equal to the current vector rotated 90 degrees.
  return vector.new(-self.y, self.x)
end

function vector:floor () -- Returns a vector whose components equal the 'floor' of the components of the current vector.
  return vector.new(math.floor(self.x), math.floor(self.y))
end

function vector:ceil ()  -- Returns a vector whose components equal the 'ceil' of the components of the current vector.
  return vector.new(math.ceil(self.x), math.ceil(self.y))
end

function vector:angle () -- Gets the angle in radians of this vector.
  return math.atan2(self.y, self.x)
end


function vector:rotated(theta)
  local cs = math.cos(theta)
  local sn = math.sin(theta)
  local nx = self.x * cs - self.y * sn
  local ny = self.x * sn + self.y * cs
  return vector(nx, ny)
end


local FULL_CIRCLE = math.pi * 2
  
function vector.normalizeAngle(theta, min)
  min = min or 0
  
  while theta >= min + FULL_CIRCLE do theta = theta - FULL_CIRCLE end
  while theta < min do theta = theta + FULL_CIRCLE end
  return theta
end

return vector
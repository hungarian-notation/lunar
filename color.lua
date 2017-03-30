local Color = {}

local FULL_ROTATION = math.pi * 2

function Color.hsvToRgb(H_or_table, S, V)
  local H
  
  if type(H_or_table) == 'table' then
    H = H_or_table[1]
    S = H_or_table[2]
    V = H_or_table[3]
  else
    H = H_or_table
  end
  
  H = vector.normalizeAngle(H)
  
	local C = V * S
  local hFact = H / (FULL_ROTATION / 6.0)
  local X = C * (1 - math.abs((H / (FULL_ROTATION / 6.0)) % 2 - 1))
  local m = V - C
  
  local r, g, b
  
  if hFact <= 1.0 then
    r, g, b = C, X, 0
  elseif hFact <= 2.0 then
    r, g, b = X, C, 0
  elseif hFact <= 3.0 then
    r, g, b = 0, C, X
  elseif hFact <= 4.0 then
    r, g, b = 0, X, C
  elseif hFact <= 5.0 then
    r, g, b = X, 0, C
  elseif hFact <= 6.0 then
    r, g, b = C, 0, X
  else error("H out of bounds: " .. hFact) end
  
  r, g, b = (r + m) * 0xFF, (g + m) * 0xFF, (b + m) * 0xFF
  
  if type(H_or_table) == 'table' then
    return {r, g, b}
  else
    return r, g, b
  end
end

function Color.rgbToHsv(r, g, b)
	
end

return Color
local function EXPORT_GLOBAL(key, value)
  _G[key] = value
  lunar.log('exported "' .. key .. '" to the global table')
end

local function EXPORT_OPT_GLOBAL(opt, def, value) 
  if opt then
    local key = type(opt) == 'string' and opt or def
    EXPORT_GLOBAL(key, value)
  end
end

-- # Optional Exports
-- To export these optional packages into the global namespace, set
-- their opts key to a truthy value when calling this function. If
-- you set the value to a string, that string is the name the package
-- will be exported as. If you set the value to `true`, they will be
-- exported under their default name.
  
--[[
  
|opts.debug_messages|:
  Enables debug messages. When this option is true, the `log` function in the
  lunar namespace prints its args via `print`. When this option is not true, `log`
  is an empty function.
  
|opts.global_vector|: 
  True to export the vector module as 'vector' to the global namespace.
  You may also provide a string with this name to choose a specific
  name for the global vector table.
  
|opts.global_namespace|:
  True to export a handle for the root namespace to the global environment.
  The default name for this table is **'lib'**, though you may specify a different
  name by passing it as the value of this option.
  
|opts.use_snake_case|:
  Setting this option to true switches the event module into snake-case mode.
  Event handlers are recognized via the prefix `on_` and take the form `on_event`,
  rather than the typical `onEvent`.
  
  This option has no effect on the api of this library, which is still in
  mostly camel case.

--]]
  
return function(opts) 
  local root_namespace = require 'lunar.namespace'
  
  if opts.debug_messages then
    root_namespace.lunar:setVariable("DEBUG", true)
    root_namespace.lunar:setVariable("log", function (...) print (...) end)
  else
    root_namespace.lunar:setVariable("log", function () end)
  end
    
  EXPORT_GLOBAL("lunar", root_namespace.lunar)
  
  EXPORT_OPT_GLOBAL(opts.global_vector, "vector", root_namespace.lunar.vector)
  EXPORT_OPT_GLOBAL(opts.global_namespace, "lib", root_namespace)
  
  if opts.use_snake_case then
    _G['LUNAR_USE_SNAKE_CASE'] = true
  end
end
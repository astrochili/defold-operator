--[[
  operator.lua
  github.com/astrochili/defold-operator

  Copyright (c) 2022 Roman Silin
  MIT license. See LICENSE for details.
--]]

local operator = { }

-- Helpers

function operator.lerp(t, a, b)
  return a + (b - a) * t
end

function operator.angle_between(v1, v2)
  local a = vmath.dot(v1, v2)
  local b = vmath.length(v1)
  local c = vmath.length(v2)
  local rad = math.acos(a / (b * c))
  return math.deg(rad)
end

function operator.project_on_plane(plane_normal, v)
  local distance = vmath.dot(plane_normal, v)
  return v - plane_normal * distance
end

-- Easing

operator.EASING_INOUT_SINE = function(x)
  return -(math.cos(math.pi * x) - 1) / 2
end

operator.EASING_INOUT_CUBIC = function(x)
  if x < 0.5 then
    return 4 * x * x * x
  else
    return 1 - math.pow(-2 * x + 2, 3) / 2
  end
end

operator.EASING_INOUT_QUINT = function(x)
  if x < 0.5 then
    return 16 * x * x * x * x * x
  else
    return 1 - math.pow(-2 * x + 2, 5) / 2
  end
end

operator.EASING_INOUT_CIRC = function(x)
  if x < 0.5 then
    return (1 - math.sqrt(1 - math.pow(2 * x, 2))) / 2
  else
    return (math.sqrt(1 - math.pow(-2 * x + 2, 2)) + 1) / 2;
  end
end

operator.EASING_INOUT_QUAD = function(x)
  if x < 0.5 then
    return 2 * x * x
  else
    return 1 - math.pow(-2 * x + 2, 2) / 2
  end
end

operator.EASING_INOUT_QUART = function(x)
  if x < 0.5 then
    return 8 * x * x * x * x
  else
    return 1 - math.pow(-2 * x + 2, 4) / 2
  end
end

operator.EASING_INOUT_EXPO = function(x)
  if x == 0 then
    return 0
  elseif x == 1 then
    return 1
  elseif x < 0.5 then
    return math.pow(2, 20 * x - 10) / 2
  else
    return (2 - math.pow(2, -20 * x + 10)) / 2
  end
end

-- Public Properties

operator.camera_collisions_groups = { hash 'default' }
operator.flight_bezier_samples_count = 32
operator.flight_look_easing = operator.EASING_INOUT_QUAD
operator.flight_zoom_easing = operator.EASING_INOUT_QUAD

-- Private Properties

local private = {
  active_operator = nil,
  checkpoints = { },
  operators = { },
  is_debug = false  
}

-- Public Functions

function operator.get_active_operator()
  return private.active_operator
end

function operator.set_debug(is_debug)
  private.is_debug = is_debug

  for url, _ in pairs(private.operators) do
    msg.post(url, hash 'debug', { is_debug = is_debug })
  end

  for url, _ in pairs(private.checkpoints) do
    msg.post(url, hash 'debug', { is_debug = is_debug })
  end
end

function operator.is_debug()
  return private.is_debug
end

-- Internal Functions

function operator.did_init_operator(url)
  msg.post(url, hash 'debug', { is_debug = private.is_debug })
  private.operators[url] = true
end

function operator.did_final_operator(url)
  private.operators[url] = nil
end

function operator.did_init_checkpoint(url)
  msg.post(url, hash 'debug', { is_debug = private.is_debug })
  private.checkpoints[url] = true
end

function operator.did_final_checkpoint(url)
  private.checkpoints[url] = nil
end

function operator.did_activate_operator(url)
  if private.active_operator then
    msg.post(private.active_operator, hash 'deactivate')
  end

  private.active_operator = url
end

function operator.did_deactivate_operator(url)
  if private.active_operator == url then
    private.active_operator = nil
  end
end

return operator
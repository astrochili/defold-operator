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

function operator.quat_from_euler(euler)
  local quat_x = vmath.quat_rotation_x(math.rad(euler.x))
  local quat_y = vmath.quat_rotation_y(math.rad(euler.y))
  local quat_z = vmath.quat_rotation_z(math.rad(euler.z))
  return quat_z * quat_y * quat_x
end

function operator.euler_from_quat(quat)
  local x, y, z, w = quat.x, quat.y, quat.z, quat.w

	local polus = 2 * (y * z - w * x)
  local yaw, pitch, roll

	if polus < 0.999 then
		if polus > -0.999 then
      yaw = -math.asin(polus)
      pitch = math.atan2(2 * (x * z + w * y), 1 - 2 * (x * x + y * y))
      roll = math.atan2(2 * (x * y + w * z), 1 - 2 * (x * x + z * z))
		else
      yaw = math.pi / 2
      pitch = math.atan2(2 * (x * y - w * z), 1 - 2 * (y * y + z * z))
      roll = 0
		end
	else
    yaw = -math.pi / 2
    pitch = math.atan2(-2 * (x * y - w * z), 1 - 2 * (y * y + z * z))
    roll = 0
	end

  yaw = math.deg(yaw)
  pitch = math.deg(pitch)
  roll = math.deg(roll)

  local euler = vmath.vector3(yaw, pitch, roll)
  return euler
end

function operator.normalized_target_angle(original, target)
  local planned_rotation = target - original
  local nearest_angle = target

  if planned_rotation > 180 then
    nearest_angle = target - 360
  elseif planned_rotation < -180 then
    nearest_angle = target + 360
  end

  return nearest_angle
end

function operator.normalized_target_euler(original, target)
  local nearest_look = vmath.vector3(target)
  nearest_look.x = operator.normalized_target_angle(original.x, target.x)
  nearest_look.y = operator.normalized_target_angle(original.y, target.y)
  nearest_look.z = operator.normalized_target_angle(original.z, target.z)
  return nearest_look
end

function operator.clamp_angle(angle, min, max)
  local angle = angle

  if angle < -360 then
    angle = angle + 360
  elseif angle > 360 then
    angle = angle - 360
  end

  angle = math.min(math.max(angle, min), max)
  return angle
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
    msg.post(url, hash 'debug', { is_enabled = is_debug })
  end

  for url, _ in pairs(private.checkpoints) do
    msg.post(url, hash 'debug', { is_enabled = is_debug })
  end
end

function operator.is_debug()
  return private.is_debug
end

-- Internal Functions

function operator.did_init_operator(url)
  msg.post(url, hash 'debug', { is_enabled = private.is_debug })
  private.operators[url] = true
end

function operator.did_final_operator(url)
  private.operators[url] = nil
end

function operator.did_init_checkpoint(url)
  msg.post(url, hash 'debug', { is_enabled = private.is_debug })
  private.checkpoints[url] = true
end

function operator.did_final_checkpoint(url)
  private.checkpoints[url] = nil
end

function operator.did_activate_operator(url)
  if private.active_operator and private.active_operator ~= url then
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
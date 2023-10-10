--[[
  bezier.lua
  github.com/astrochili/defold-operator

  Copyright (c) 2022 Roman Silin
  MIT license. See LICENSE for details.
--]]

local bezier = { }

-- Local

local function int_length(a)
  return a
end

local function int_lerp(t, a, b)
  return a + (b - a) * t
end

local function linear_bezier(time, lerp, p1, p2)
	local result = p1 == p2 and p1 or lerp(time, p1, p2)
	return result
end

local function quad_bezier(time, lerp, p1, p2, p3)
	local a = linear_bezier(time, lerp, p1, p2)
	local b = linear_bezier(time, lerp, p2, p3)
	local result = linear_bezier(time, lerp, a, b)
	return result
end

local function cubic_bezier(time, lerp, p1, p2, p3, p4)
  local a = quad_bezier(time, lerp, p1, p2, p3)
  local b = quad_bezier(time, lerp, p2, p3, p4)
	local result = linear_bezier(time, lerp, a, b)
	return result
end

local bezier_funcs = {
  [2] = linear_bezier,
  [3] = quad_bezier,
  [4] = cubic_bezier
}

-- Public

function bezier.new(points, samples_count, length_func, lerp_func)
  assert(#points >= 2 and #points <= 4, 'Only 2-4 bezier points are supported.')

	local self = setmetatable({ }, { __index = bezier })
  local is_integer = type(points[1]) == 'integer'

  self.length_func = length_func or (is_integer and int_length or vmath.length)
  self.lerp_func = lerp_func or (is_integer and int_lerp or vmath.lerp)
  self.bezier_func = bezier_funcs[#points]
  self.samples = { }

  self.origin = points[1]
  self.points = { }
  for index, point in ipairs(points) do
    self.points[index] = point - self.origin
  end

  local samples_count = samples_count or 1
  samples_count = (#points > 2 and samples_count > 1) and samples_count or 1

  local previous_position = points[1]
  local passed_length = 0

  for index = 1, samples_count do
    local current_time = index / samples_count
    local current_position = self.bezier_func(current_time, self.lerp_func, unpack(points))
    local sample_length = self.length_func(current_position - previous_position)

    passed_length = passed_length + sample_length
    table.insert(self.samples, passed_length)
    previous_position = current_position
  end

	return self
end

function bezier.position(self, time)
  return self.origin + self.bezier_func(time, self.lerp_func, unpack(self.points))
end

function bezier.uniform_position(self, time)
  local time = math.max(0, math.min(time, 1))
  local length = self.samples[#self.samples]
  local desired_length = length * time

  for index, sample in ipairs(self.samples) do
    if sample >= desired_length then
      local previous_sample = self.samples[index - 1] or 0
      local previous_time = (index - 1) / #self.samples

      local current_time = index / #self.samples

      local sample_distance = sample - previous_sample
      local desired_distance = desired_length - previous_sample
      local sample_progress = desired_distance / sample_distance

      local uniform_time = int_lerp(sample_progress, previous_time, current_time)
      local position = bezier.position(self, uniform_time)

      return position
    end
  end

  return nil
end

return bezier
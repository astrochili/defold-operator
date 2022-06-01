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

local function quad_bezier(time, lerp, p1, p2, p3)
	local a = lerp(time, p1, p2)
	local b = lerp(time, p2, p3)
	local result = lerp(time, a, b)
	return result
end

local function cubic_bezier(time, lerp, p1, p2, p3, p4)
  local a = quad_bezier(time, lerp, p1, p2, p3)
  local b = quad_bezier(time, lerp, p2, p3, p4)
	local result = lerp(time, a, b)
	return result
end

-- Public

function bezier.new(points, samples_count, length_func, lerp_func)
  assert(#points >= 3 and #points <= 4, 'Only 3 or 4 bezier points supported.')
  assert(points[1] ~= points[#points], 'No distance between the start and end points.')

	local self = setmetatable({ }, { __index = bezier })
  local is_integer = type(points[1]) == 'integer'

  self.length_func = length_func or (is_integer and int_length or vmath.length)
  self.lerp_func = lerp_func or (is_integer and int_lerp or vmath.lerp)
  self.bezier_func = #points == 4 and cubic_bezier or quad_bezier

  self.points = points
  self.samples = { }

  local samples_count = (samples_count and samples_count >= 1) and samples_count or 1
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
  return self.bezier_func(time, self.lerp_func, unpack(self.points))
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
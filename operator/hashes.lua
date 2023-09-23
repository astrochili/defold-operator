--[[
  hashes.lua
  github.com/astrochili/defold-operator

  Copyright (c) 2023 Roman Silin
  MIT license. See LICENSE for details.
--]]

local hashes = {
  acquire_camera_focus = hash 'acquire_camera_focus',
  acquire_input_focus = hash 'acquire_input_focus',
  activate = hash 'activate',
  camera = hash 'camera',
  checkpoint = hash 'checkpoint',
  deactivate = hash 'deactivate',
  debug = hash 'debug',
  default = hash 'default',
  draw_line = hash 'draw_line',
  euler = hash 'euler',
  far_z = hash 'far_z',
  follow_point = hash 'follow_point',
  follow_sequence = hash 'follow_sequence',
  fov = hash 'fov',
  ground_normal = hash 'ground_normal',
  internal_control = hash 'internal_control',
  manual_control = hash 'manual_control',
  motion_finished = hash 'motion_finished',
  motion_interrupted = hash 'motion_interrupted',
  motion_point = hash 'motion_point',
  mouse_wheel_down = hash 'mouse_wheel_down',
  mouse_wheel_up = hash 'mouse_wheel_up',
  near_z = hash 'near_z',
  object_post_movement = hash 'object_post_movement',
  operator_attached = hash 'operator_attached',
  operator_detached = hash 'operator_detached',
  post_update = hash 'post_update',
  release_camera_focus = hash 'release_camera_focus',
  release_input_focus = hash 'release_input_focus',
  unfollow = hash 'unfollow',
  use_camera_projection = hash 'use_camera_projection'
}

return hashes
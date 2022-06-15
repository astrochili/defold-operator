# Defold Camera Operator

![](https://user-images.githubusercontent.com/4752473/173253156-043d31ac-fe48-43bb-b91a-1272feec80c2.jpg)

## Overview

This is a tweakable camera movement controller suitable for 3D games on the [Defold](https://defold.com). It can help you smoothly control your character’s camera or make cinematic motion paths using checkpoints.

Showing your player the level by flying around and finish the flight by smooth attachment to the character — sounds like a classic use case.

This extension is not about rendering so you can use any render script that you want.

[Play HTML5 demo](https://astronachos.com/defold/operator).

[Discuss on the forum](https://forum.defold.com/t/operator-camera-movement-controller-for-3d-games/71094/3).

## Features

- Camera rotation and zooming by mouse controls.
- External manual control by messages.
- Following an object with avoiding obstacles.
- Smart alignment to the ground slope.
- Smooth movement along checkpoints using a bezier path.
- Switching between multiple cameras.

## Install

Add links to the zip-archives of the latest versions of [defold-operator](https://github.com/astrochili/defold-operator/releases) and [defold-pointer-lock](https://github.com/indiesoftby/defold-pointer-lock) to your Defold project as [dependencies](http://www.defold.com/manuals/libraries/).

## Quick Start

Add `operator.collection` to your scene and configure its script properties in the editor.

**Character Following**

1. Post the [`follow_point`](#follow_point) message to follow the game object.
2. Use mouse controls or post [`manual_control`](#manual_control) messages.

**Cinematic Flight**

1. Add `checkpoint.go` instances to your scene and configure their script properties in the editor.
2. Post the [`follow_sequence`](#follow_sequence) message with an array of checkpoints to follow the sequence.

## Operator Properties

### is_active

Activates the operator during initialization.

### internal_control

Enables internal control with a mouse input during initialization.

### camera_fov

Vertical field of view in degrees. The value passed to the camera component during initialization.

### camera_near_z

Near z position to render. The value passed to the camera component during initialization.

### camera_far_z

Far z position to render. The value passed to the camera component during initialization.

### look_horizontal

Enables horizontal camera rotation.

### look_vertical

Enables vertical camera rotation.

### inverted_horizontal

Inverts horizontal camera rotation.

### inverted_vertical

Inverts vertical camera rotation.

### minimum

A vector representing lower bounds of the rotation and zoom distance limits.

- `x` - minimum vertical rotation in degrees.
- `y` - minimum horizontal rotation in degrees.
- `z` - minimum zoom distance in units.

### maximum

A vector representing upper bounds of the rotation and zoom distance limits.

- `x` - maximum vertical rotation in degrees.
- `y` - maximum horizontal rotation in degrees.
- `z` - maximum zoom distance in units.

### sensitivity

Input sensitivity for the camera rotation. The value is an angle in degrees to rotate by 1 input value.

- `0.0` - no reaction.
- `0.7` - degrees = 70% of input.

### smoothness

How much time in seconds needed to turn the current look to the desired look after input.

- `0` - look immediately and sharp.
- `0.1` - look smoothly.
- `1.2` - look like a sloth.

The first-person look usually uses sharper rotation than the third-person look.

### zoom

An initial distance between the camera and the operator anchor point.

- `0` - use for the first-person look to rotate the camera inside the object.
- `n` - use for the third-person look to rotate the camera around the object.

### zoom_step

The camera distance change in units per a zoom input value.

### zoom_smoothness

How much time in seconds needed to change the current zoom to the desired zoom after input.

- `0` - zoom immediately and sharp.
- `0.3` - zoom smoothly (recommended).
- `1.2` - zoom like a sloth.

### collision_check

Checks a path from the camera to the operator anchor for the collisions and move it closer if necessary.

### collision_distance

Minimum distance between the camera and the collision surface if `collision_check` is turned on.

### ground_align_factor

How much align the camera to the ground normal.

- `0` - no alignment.
- `0.5` - half alignment (recommended).
- `1.0` - full alignment (not recommended).

### ground_align_smoothness

How much time in seconds needed to change the current ground alignment to the desired ground alignment after the ground normal update.

- `0` - align immediately and sharp (not recommended).
- `0.5` - align smoothly.
- `2.3` - align like a sloth.

Don't use low values to avoid sharp shakes due to the ground geometry.

## Activation Messages

### activate

Activates the operator. Acquires input and camera focuses, posts `use_camera_projection` to the render. Automatically deactivates a previous operator.

```lua
msg.post(operator_url, hash 'activate')
```

### deactivate

Deactivates the operator. Releases input and camera focuses.

```lua
msg.post(operator_url, hash 'deactivate')
```

## Follow Messages

The operator can follow the object or follow checkpoints to make kind of cinematic camera movement.

Local space coordinates and rotations are respected so you can switch between two moving objects without problems.

### Checkpoint

There is two ways to create checkpoint:

- Place `checkpoint.go` instance to your scene and configure its script properties.
- Manually create table with parameters in the code.

A point table have additional parameters `position` and `look`, which are the equivalents of `checkpoint.go` position, rotation.

- `object` (optional, default is `nil`) - move the operrator in the local object coordinates. Use this to attach it to something moving, like a character.
- `position` (optional, default is `vmath.vector()`) - the operator anchor position.
- `look` (optional, default is the previous point `look`) - the camera rotation.
- `zoom` (optional, default is the previous point `zoom`) - the camera zoom distance.
- `speed` (optional, default is the previous point `speed`) - the speed at which the operator should move at this point. Measured in units per second.
- `inout` (optional, default is `false`) - use in-out easing on speed changing along tha path to this point. The speed between points changes linearly so in-out is useful when moving from `0` to `0` speed.
- `bezier` (optional, default is `true`) - use bezier smoothness at this point.

```lua
local point = {
    -- global space
    object = nil

    -- global position
    position = vmath.vector3(14, 2, 7)

    -- look down to the left.
    look = vmath.vector3(-45, 90, 0)

    -- 3 units from the camera to the anchor
    zoom = 3

    -- 5 units/sec speed at this point
    speed = 5

    -- speed linear changing to this point
    inout = false

    -- use bezier smooth at this point
    bezier = true
}
```

### follow_sequence

Follow the sequence of points.

```lua
local sequence = {
    -- manually created point
    checkpoint_1,

    -- checkpoint instance url
    msg.url('/checkpoint_2'),

    -- follow the object
    object_point
}

msg.post(operator_url, hash 'follow_sequence', sequence)
```

Sender will become `motion_observer` during the motion to receivce [motion messages](#motion_point).

### follow_point

This is equilent to the `follow_sequence` message with one `point`.

If you want just to attach the camera to the character — that's your case.

```lua
-- Create a point
local point = {
    object = character_url,
    position = vmath.vector3(0, 1.5, 0)
}

-- Follow the point
msg.post(operator_url, hash 'follow_point', point)
```

### unfollow

Stop following any sequence or object.

```lua
msg.post(operator_url, hash 'unfollow')
```

## Ground Alignment Messages

### ground_normal

Update the ground normal to proper camera alignment. This is usually done with raycasting down from the followed object.

```lua
-- raycast from the object to the ground
local ground = physics.raycast(position, position + vmath.vector3(0, -1, 0), { hash 'default' })

-- nil will be interpreted as vmath.vector3(0, 1, 0).
local normal = ground and ground.normal or nil

msg.post(operator_url, hash 'ground_normal', { normal = normal })
```

## Control Messages

### internal_control

Enables or disables internal control with a mouse input.

```lua
msg.post(operator_url, hash 'internal_control', { is_inabled = true })
```

### manual_control

Manually control the look and zoom by input values. This can be useful on devices without a mouse or if you prefer to control everything by yourself.

```lua
local input = {
    horizontal = dx,
    vertical = dy,
    zoom = dz
}

msg.post(operator_url, hash 'manual_control', input)
```

You can reference to default internal control values:
-  Mouse moving actions send `action.dx` and `action.dy` values.
-  Mouse wheel actions send `dz` as `-1` or `1` values.

## Outgoing Messages

### operator_attached

- `operator` - the `url` of the operator.

Sends to the followed object when the operator attached.

### operator_detached

- `operator` - the `url` of the operator.

Sends to the followed object when the operator detached.

### motion_point

- `object` - the `url` of the object if exists.
- `checkpoint`- the `url` of the checkpoint if exists.

Sends to `motion_observer` when the operator has reached the checkpoint.

### motion_finished

- `object` - the `url` of the object if exists.
- `checkpoint`- the `url` of the checkpoint if exists.

Sends to `motion_observer` when the current operator motion has finished.

### motion_interrupted

Sends to `motion_observer` when the current operator motion has interrupted by any other commands.

## Operator Module

The operator module gives you access to additional shared preferences. Add the following requirement to use it.

```lua
local operator = require 'operator.operator'
```

### operator.get_active_operator()

Returns the current active operator `url`.

```lua
local active_operator_url = operator.get_active_operator()
```

### operator.set_debug(is_debug)

Enables camera and checkpoint meshes, active bezier drawing.

```lua
operator.set_debug(true)
```

### operator.is_debug()

Returns current debug mode state as `bool`.

```lua
local is_debug = operator.is_debug()
```

### operator.camera_collisions_groups

Collision groups that are tested by raycast from the operator anchor to the camera to avoid obstacles.

```lua
operator.camera_collisions_groups = { hash 'default' }
```

### operator.flight_bezier_samples_count

Count of bezier segments. Used by uniform position calculation. `16` is usually enough, but `32` is more beautiful.

```lua
operator.flight_bezier_samples_count = 32
```

### operator.flight_look_easing

Easing function to update the camera rotation between motion points.

```lua
-- set a ready to use easing function
operator.flight_look_easing = operator.EASING_INOUT_QUAD

-- or use your own
local easing_linear = function(x) return x end
operator.flight_look_easing = easing_linear
```

### operator.flight_zoom_easing

Easing function to update the camera zoom distance between motion points.

```lua
-- set a ready to use easing function
operator.flight_zoom_easing = operator.EASING_INOUT_QUAD
-- or use your own
local easing_linear = function(x) return x end
operator.flight_zoom_easing = easing_linear
```

### Included Easing Functions

- `operator.EASING_INOUT_SINE`
- `operator.EASING_INOUT_CUBIC`
- `operator.EASING_INOUT_QUINT`
- `operator.EASING_INOUT_CIRC`
- `operator.EASING_INOUT_QUAD`
- `operator.EASING_INOUT_EXPO`

## Bezier Module

The `bezier.lua` module is used to move the camera, but you can also use it for your own purposes. It supports vector and integer points.

Add the following requirement to use it.

```lua
local bezier = require 'operator.bezier'
```

### bezier.new(points, samples_count, length_func, lerp_func)

- `points` - an array of vector or integer points. 3 points for quadratic bezier or 4 points for cubic bezier.
- `samples_count` (optional, default is `32`) - count of bezier segments for uniform position calculation.
- `length_func` (optional, default function supports vectors and integers) - length function to override.
- `lerp_func` (optional, default function supports vectors and integers) - lerp function to override.

Returns a bezier instance with pre-calculated data.

```lua
-- quadratic bezier with default count of samples
local points = { p1, p2, p3 }
local bezier_path = bezier.new(points)

-- cubic bezier with 16 samples
local points = { p1, p2, p3, p4 }
local bezier_path = bezier.new(points, 16)
```

### bezier:position(time)

- `time` - a float value from 0 to 1 representing progress.

Returns a classic position along the bezier.

### bezier:uniform_position(time)

- `time` - a float value from 0 to 1 representing progress.

Returns an uniform position along the bezier. The accuracy depends of `samples_count`.

## Dependences

- [defold-pointer-lock](https://github.com/indiesoftby/defold-pointer-lock) by Artsiom Trubchyk ([@aglitchman](https://github.com/aglitchman)).

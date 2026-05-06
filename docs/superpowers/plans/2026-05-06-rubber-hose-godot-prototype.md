# Rubber Hose Godot Prototype Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Godot 4 side-scrolling Rubber Hose prototype with a playable `CharacterBody2D`, four surface types, procedural cartoon deformation, debug UI, and a test playground.

**Architecture:** Gameplay and visual presentation are separated. `PlayerController` owns movement and collision, `SurfaceDetector` resolves floor material profiles, and `ToonAnimator` converts gameplay data into squash/stretch, lean, limb swing, and facial feedback without changing the collision shape.

**Tech Stack:** Godot 4, GDScript, `CharacterBody2D`, `Resource`, `RayCast2D`, `AnimationPlayer`, `CanvasLayer`, `.tscn` scenes, `.tres` resources.

---

## File Structure

- Create: `project.godot` — Godot project settings, input actions, main scene.
- Create: `scenes/Main.tscn` — root scene containing the playground, player, camera, and debug overlay.
- Create: `scenes/Player.tscn` — player scene with stable collision and separate `VisualRoot`.
- Create: `scenes/SurfaceBlock.tscn` — reusable colored platform block that exports a `SurfaceProfile`.
- Create: `scripts/player/player_controller.gd` — movement, state classification, jump, bounce, and exposed gameplay data.
- Create: `scripts/player/surface_detector.gd` — resolves active surface from collisions/areas.
- Create: `scripts/player/toon_animator.gd` — procedural squash/stretch, lean, limbs, eyes, and recovery.
- Create: `scripts/surfaces/surface_profile.gd` — typed data resource for movement and visual parameters.
- Create: `scripts/surfaces/surface_block.gd` — applies surface profile metadata and color to a block.
- Create: `scripts/debug/debug_overlay.gd` — displays state, surface, velocity, grounded, and impact data.
- Create: `resources/surfaces/normal.tres` — normal ground profile.
- Create: `resources/surfaces/ice.tres` — ice profile.
- Create: `resources/surfaces/elastic.tres` — elastic ground profile.
- Create: `resources/surfaces/slime.tres` — slime/mud profile.

## Verification Commands

Run these after tasks that create or modify Godot files:

```bash
godot --headless --path . --quit
```

Expected: exit code 0. If the machine does not have `godot` on `PATH`, open the project in Godot 4 and confirm the editor imports the project without script or scene errors.

Run this after each task to inspect changed files:

```bash
git status --short
```

Expected: only files from the current task and earlier accepted tasks are listed.

Commit checkpoints in this plan are review points only. Do not run `git commit` unless the user explicitly asks for commits.

---

### Task 1: Create Godot Project Skeleton

**Files:**
- Create: `project.godot`
- Create: `scenes/Main.tscn`
- Create: `scripts/debug/debug_overlay.gd`

- [ ] **Step 1: Create directory structure**

Run:

```bash
mkdir -p scenes scripts/player scripts/surfaces scripts/debug resources/surfaces
```

Expected: directories exist under the repository root.

- [ ] **Step 2: Create `project.godot`**

Write:

```ini
; Engine configuration file.
; Use Godot 4.x to open this project.

config_version=5

[application]
config/name="Rubber Hose Animation Prototype"
run/main_scene="res://scenes/Main.tscn"
config/features=PackedStringArray("4.3", "GL Compatibility")

[display]
window/size/viewport_width=1280
window/size/viewport_height=720
window/stretch/mode="canvas_items"

[input]
move_left={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":65,"physical_keycode":0,"key_label":0,"unicode":0,"echo":false,"script":null), Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":4194319,"physical_keycode":0,"key_label":0,"unicode":0,"echo":false,"script":null)]
}
move_right={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":68,"physical_keycode":0,"key_label":0,"unicode":0,"echo":false,"script":null), Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":4194321,"physical_keycode":0,"key_label":0,"unicode":0,"echo":false,"script":null)]
}
jump={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":32,"physical_keycode":0,"key_label":0,"unicode":0,"echo":false,"script":null)]
}
```

- [ ] **Step 3: Create `scripts/debug/debug_overlay.gd`**

Write:

```gdscript
extends CanvasLayer

@export var player_path: NodePath

@onready var label: Label = $PanelContainer/MarginContainer/Label

var player: Node = null


func _ready() -> void:
	if player_path != NodePath():
		player = get_node_or_null(player_path)


func _process(_delta: float) -> void:
	if player == null:
		label.text = "Player: not assigned"
		return

	var surface_name := "none"
	if player.active_surface != null:
		surface_name = player.active_surface.display_name

	label.text = "State: %s\nSurface: %s\nVelocity: %.1f, %.1f\nGrounded: %s\nImpact: %.1f" % [
		player.movement_state,
		surface_name,
		player.velocity.x,
		player.velocity.y,
		str(player.is_on_floor()),
		player.last_impact_strength,
	]
```

- [ ] **Step 4: Create `scenes/Main.tscn` with placeholder nodes**

Write:

```ini
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/debug/debug_overlay.gd" id="1_debug"]

[node name="Main" type="Node2D"]

[node name="World" type="Node2D" parent="."]

[node name="PlayerSpawn" type="Marker2D" parent="World"]
position = Vector2(120, 420)

[node name="Camera2D" type="Camera2D" parent="World"]
position = Vector2(640, 360)
enabled = true
zoom = Vector2(1, 1)

[node name="DebugOverlay" type="CanvasLayer" parent="."]
script = ExtResource("1_debug")

[node name="PanelContainer" type="PanelContainer" parent="DebugOverlay"]
offset_left = 16.0
offset_top = 16.0
offset_right = 336.0
offset_bottom = 152.0

[node name="MarginContainer" type="MarginContainer" parent="DebugOverlay/PanelContainer"]
theme_override_constants/margin_left = 12
theme_override_constants/margin_top = 12
theme_override_constants/margin_right = 12
theme_override_constants/margin_bottom = 12

[node name="Label" type="Label" parent="DebugOverlay/PanelContainer/MarginContainer"]
text = "Prototype booting"
```

- [ ] **Step 5: Verify project loads**

Run:

```bash
godot --headless --path . --quit
```

Expected: exit code 0. The debug overlay may report no assigned player because the player is created in a later task.

- [ ] **Step 6: Review checkpoint**

Run:

```bash
git status --short
```

Expected: `project.godot`, `scenes/Main.tscn`, and `scripts/debug/debug_overlay.gd` are listed as new files. Do not commit unless explicitly requested by the user.

---

### Task 2: Add Surface Profiles and Surface Blocks

**Files:**
- Create: `scripts/surfaces/surface_profile.gd`
- Create: `scripts/surfaces/surface_block.gd`
- Create: `scenes/SurfaceBlock.tscn`
- Create: `resources/surfaces/normal.tres`
- Create: `resources/surfaces/ice.tres`
- Create: `resources/surfaces/elastic.tres`
- Create: `resources/surfaces/slime.tres`
- Modify: `scenes/Main.tscn`

- [ ] **Step 1: Create `scripts/surfaces/surface_profile.gd`**

Write:

```gdscript
class_name SurfaceProfile
extends Resource

@export var id: StringName = &"normal"
@export var display_name: String = "Normal"
@export var color: Color = Color(0.35, 0.32, 0.28, 1.0)
@export var acceleration_multiplier: float = 1.0
@export var friction_multiplier: float = 1.0
@export var max_speed_multiplier: float = 1.0
@export var jump_multiplier: float = 1.0
@export var bounce_multiplier: float = 0.0
@export var stickiness: float = 0.0
@export var visual_squash_multiplier: float = 1.0
@export var visual_stretch_multiplier: float = 1.0
@export var visual_drag_multiplier: float = 1.0
@export var skid_threshold_multiplier: float = 1.0


func smoothed_to(target: SurfaceProfile, weight: float) -> SurfaceProfile:
	var result := SurfaceProfile.new()
	result.id = target.id
	result.display_name = target.display_name
	result.color = color.lerp(target.color, weight)
	result.acceleration_multiplier = lerpf(acceleration_multiplier, target.acceleration_multiplier, weight)
	result.friction_multiplier = lerpf(friction_multiplier, target.friction_multiplier, weight)
	result.max_speed_multiplier = lerpf(max_speed_multiplier, target.max_speed_multiplier, weight)
	result.jump_multiplier = lerpf(jump_multiplier, target.jump_multiplier, weight)
	result.bounce_multiplier = lerpf(bounce_multiplier, target.bounce_multiplier, weight)
	result.stickiness = lerpf(stickiness, target.stickiness, weight)
	result.visual_squash_multiplier = lerpf(visual_squash_multiplier, target.visual_squash_multiplier, weight)
	result.visual_stretch_multiplier = lerpf(visual_stretch_multiplier, target.visual_stretch_multiplier, weight)
	result.visual_drag_multiplier = lerpf(visual_drag_multiplier, target.visual_drag_multiplier, weight)
	result.skid_threshold_multiplier = lerpf(skid_threshold_multiplier, target.skid_threshold_multiplier, weight)
	return result
```

- [ ] **Step 2: Create surface resources**

Write `resources/surfaces/normal.tres`:

```ini
[gd_resource type="Resource" script_class="SurfaceProfile" load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/surfaces/surface_profile.gd" id="1_profile"]

[resource]
script = ExtResource("1_profile")
id = &"normal"
display_name = "Normal"
color = Color(0.36, 0.31, 0.25, 1)
acceleration_multiplier = 1.0
friction_multiplier = 1.0
max_speed_multiplier = 1.0
jump_multiplier = 1.0
bounce_multiplier = 0.0
stickiness = 0.0
visual_squash_multiplier = 1.0
visual_stretch_multiplier = 1.0
visual_drag_multiplier = 1.0
skid_threshold_multiplier = 1.0
```

Write `resources/surfaces/ice.tres`:

```ini
[gd_resource type="Resource" script_class="SurfaceProfile" load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/surfaces/surface_profile.gd" id="1_profile"]

[resource]
script = ExtResource("1_profile")
id = &"ice"
display_name = "Ice"
color = Color(0.45, 0.85, 1, 1)
acceleration_multiplier = 0.55
friction_multiplier = 0.08
max_speed_multiplier = 1.18
jump_multiplier = 1.0
bounce_multiplier = 0.0
stickiness = 0.0
visual_squash_multiplier = 0.9
visual_stretch_multiplier = 1.05
visual_drag_multiplier = 1.35
skid_threshold_multiplier = 0.45
```

Write `resources/surfaces/elastic.tres`:

```ini
[gd_resource type="Resource" script_class="SurfaceProfile" load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/surfaces/surface_profile.gd" id="1_profile"]

[resource]
script = ExtResource("1_profile")
id = &"elastic"
display_name = "Elastic"
color = Color(1, 0.42, 0.74, 1)
acceleration_multiplier = 0.95
friction_multiplier = 0.9
max_speed_multiplier = 1.0
jump_multiplier = 1.1
bounce_multiplier = 0.72
stickiness = 0.0
visual_squash_multiplier = 1.8
visual_stretch_multiplier = 1.75
visual_drag_multiplier = 1.0
skid_threshold_multiplier = 1.0
```

Write `resources/surfaces/slime.tres`:

```ini
[gd_resource type="Resource" script_class="SurfaceProfile" load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/surfaces/surface_profile.gd" id="1_profile"]

[resource]
script = ExtResource("1_profile")
id = &"slime"
display_name = "Slime"
color = Color(0.18, 0.85, 0.28, 1)
acceleration_multiplier = 0.45
friction_multiplier = 1.7
max_speed_multiplier = 0.55
jump_multiplier = 0.68
bounce_multiplier = 0.0
stickiness = 0.75
visual_squash_multiplier = 1.25
visual_stretch_multiplier = 1.35
visual_drag_multiplier = 1.9
skid_threshold_multiplier = 1.35
```

- [ ] **Step 3: Create `scripts/surfaces/surface_block.gd`**

Write:

```gdscript
extends StaticBody2D

@export var profile: SurfaceProfile
@export var size: Vector2 = Vector2(320, 64):
	set(value):
		size = value
		_apply_size_and_color()

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var color_rect: ColorRect = $ColorRect


func _ready() -> void:
	add_to_group("surface")
	set_meta("surface_profile", profile)
	_apply_size_and_color()


func _apply_size_and_color() -> void:
	if collision_shape == null or color_rect == null:
		return
	var rectangle := RectangleShape2D.new()
	rectangle.size = size
	collision_shape.shape = rectangle
	collision_shape.position = Vector2.ZERO
	color_rect.size = size
	color_rect.position = -size * 0.5
	if profile != null:
		color_rect.color = profile.color
```

- [ ] **Step 4: Create `scenes/SurfaceBlock.tscn`**

Write:

```ini
[gd_scene load_steps=3 format=3]

[ext_resource type="Script" path="res://scripts/surfaces/surface_block.gd" id="1_block"]

[sub_resource type="RectangleShape2D" id="RectangleShape2D_block"]
size = Vector2(320, 64)

[node name="SurfaceBlock" type="StaticBody2D"]
script = ExtResource("1_block")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("RectangleShape2D_block")

[node name="ColorRect" type="ColorRect" parent="."]
offset_left = -160.0
offset_top = -32.0
offset_right = 160.0
offset_bottom = 32.0
color = Color(0.36, 0.31, 0.25, 1)
```

- [ ] **Step 5: Modify `scenes/Main.tscn` to instance four surface blocks**

Replace the file with:

```ini
[gd_scene load_steps=8 format=3]

[ext_resource type="Script" path="res://scripts/debug/debug_overlay.gd" id="1_debug"]
[ext_resource type="PackedScene" path="res://scenes/SurfaceBlock.tscn" id="2_block"]
[ext_resource type="Resource" path="res://resources/surfaces/normal.tres" id="3_normal"]
[ext_resource type="Resource" path="res://resources/surfaces/ice.tres" id="4_ice"]
[ext_resource type="Resource" path="res://resources/surfaces/elastic.tres" id="5_elastic"]
[ext_resource type="Resource" path="res://resources/surfaces/slime.tres" id="6_slime"]

[node name="Main" type="Node2D"]

[node name="World" type="Node2D" parent="."]

[node name="PlayerSpawn" type="Marker2D" parent="World"]
position = Vector2(120, 420)

[node name="NormalGround" parent="World" instance=ExtResource("2_block")]
position = Vector2(240, 620)
profile = ExtResource("3_normal")
size = Vector2(480, 64)

[node name="IceGround" parent="World" instance=ExtResource("2_block")]
position = Vector2(720, 620)
profile = ExtResource("4_ice")
size = Vector2(480, 64)

[node name="ElasticGround" parent="World" instance=ExtResource("2_block")]
position = Vector2(1200, 620)
profile = ExtResource("5_elastic")
size = Vector2(480, 64)

[node name="SlimeGround" parent="World" instance=ExtResource("2_block")]
position = Vector2(1680, 620)
profile = ExtResource("6_slime")
size = Vector2(480, 64)

[node name="Wall" parent="World" instance=ExtResource("2_block")]
position = Vector2(2000, 476)
profile = ExtResource("3_normal")
size = Vector2(64, 352)

[node name="Camera2D" type="Camera2D" parent="World"]
position = Vector2(640, 360)
enabled = true
zoom = Vector2(1, 1)

[node name="DebugOverlay" type="CanvasLayer" parent="."]
script = ExtResource("1_debug")

[node name="PanelContainer" type="PanelContainer" parent="DebugOverlay"]
offset_left = 16.0
offset_top = 16.0
offset_right = 336.0
offset_bottom = 152.0

[node name="MarginContainer" type="MarginContainer" parent="DebugOverlay/PanelContainer"]
theme_override_constants/margin_left = 12
theme_override_constants/margin_top = 12
theme_override_constants/margin_right = 12
theme_override_constants/margin_bottom = 12

[node name="Label" type="Label" parent="DebugOverlay/PanelContainer/MarginContainer"]
text = "Prototype booting"
```

- [ ] **Step 6: Verify surfaces import**

Run:

```bash
godot --headless --path . --quit
```

Expected: exit code 0 with no resource load errors.

- [ ] **Step 7: Review checkpoint**

Run:

```bash
git status --short
```

Expected: surface scripts, surface resources, `SurfaceBlock.tscn`, and modified `Main.tscn` are listed. Do not commit unless explicitly requested by the user.

---

### Task 3: Implement Player Controller and Surface Detection

**Files:**
- Create: `scripts/player/surface_detector.gd`
- Create: `scripts/player/player_controller.gd`
- Create: `scenes/Player.tscn`
- Modify: `scenes/Main.tscn`

- [ ] **Step 1: Create `scripts/player/surface_detector.gd`**

Write:

```gdscript
extends RayCast2D

@export var fallback_surface: SurfaceProfile


func get_surface_profile() -> SurfaceProfile:
	force_raycast_update()
	if not is_colliding():
		return fallback_surface

	var collider := get_collider()
	if collider != null and collider.has_meta("surface_profile"):
		var value: Variant = collider.get_meta("surface_profile")
		if value is SurfaceProfile:
			return value

	return fallback_surface
```

- [ ] **Step 2: Create `scripts/player/player_controller.gd`**

Write:

```gdscript
class_name PlayerController
extends CharacterBody2D

signal state_changed(new_state: StringName)
signal surface_changed(new_surface: SurfaceProfile)
signal impact(strength: float)

const STATE_IDLE: StringName = &"idle"
const STATE_RUN: StringName = &"run"
const STATE_JUMP: StringName = &"jump"
const STATE_FALL: StringName = &"fall"
const STATE_LAND: StringName = &"land"
const STATE_SKID: StringName = &"skid"
const STATE_BOUNCE: StringName = &"bounce"
const STATE_STUCK: StringName = &"stuck"

@export var base_acceleration: float = 2200.0
@export var base_friction: float = 2600.0
@export var base_max_speed: float = 360.0
@export var jump_velocity: float = -560.0
@export var gravity: float = 1600.0
@export var max_fall_speed: float = 1100.0
@export var surface_blend_speed: float = 12.0
@export var landing_state_time: float = 0.12
@export var bounce_state_time: float = 0.18
@export var skid_min_speed: float = 150.0

@export var default_surface: SurfaceProfile

@onready var surface_detector: Node = $SurfaceSensor

var movement_state: StringName = STATE_IDLE
var active_surface: SurfaceProfile
var target_surface: SurfaceProfile
var last_impact_strength: float = 0.0

var _state_timer: float = 0.0
var _was_on_floor: bool = false
var _previous_velocity_y: float = 0.0


func _ready() -> void:
	active_surface = default_surface
	target_surface = default_surface
	if surface_detector.has_method("get_surface_profile"):
		surface_detector.set("fallback_surface", default_surface)


func _physics_process(delta: float) -> void:
	_update_surface(delta)
	_apply_horizontal_movement(delta)
	_apply_vertical_movement(delta)
	_previous_velocity_y = velocity.y
	move_and_slide()
	_handle_floor_contact()
	_update_state(delta)


func _update_surface(delta: float) -> void:
	if is_on_floor() and surface_detector.has_method("get_surface_profile"):
		var detected: SurfaceProfile = surface_detector.get_surface_profile()
		if detected != null:
			target_surface = detected

	if target_surface == null:
		target_surface = default_surface
	if active_surface == null:
		active_surface = target_surface
		return

	var weight := clampf(delta * surface_blend_speed, 0.0, 1.0)
	if active_surface.id != target_surface.id:
		surface_changed.emit(target_surface)
	active_surface = active_surface.smoothed_to(target_surface, weight)


func _apply_horizontal_movement(delta: float) -> void:
	var input_axis := Input.get_axis("move_left", "move_right")
	var max_speed := base_max_speed * active_surface.max_speed_multiplier
	var acceleration := base_acceleration * active_surface.acceleration_multiplier
	var friction := base_friction * active_surface.friction_multiplier

	if not is_zero_approx(input_axis):
		velocity.x = move_toward(velocity.x, input_axis * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	if active_surface.stickiness > 0.0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0.0, active_surface.stickiness * 900.0 * delta)


func _apply_vertical_movement(delta: float) -> void:
	if not is_on_floor():
		velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity * active_surface.jump_multiplier
		_set_state(STATE_JUMP, 0.0)


func _handle_floor_contact() -> void:
	var grounded := is_on_floor()
	if grounded and not _was_on_floor:
		last_impact_strength = maxf(0.0, _previous_velocity_y)
		impact.emit(last_impact_strength)
		if active_surface.bounce_multiplier > 0.0 and last_impact_strength > 120.0:
			velocity.y = -last_impact_strength * active_surface.bounce_multiplier
			_set_state(STATE_BOUNCE, bounce_state_time)
		else:
			_set_state(STATE_LAND, landing_state_time)
	_was_on_floor = grounded


func _update_state(delta: float) -> void:
	if _state_timer > 0.0:
		_state_timer = maxf(0.0, _state_timer - delta)
		return

	if not is_on_floor():
		_set_state(STATE_JUMP if velocity.y < 0.0 else STATE_FALL, 0.0)
		return

	var input_axis := Input.get_axis("move_left", "move_right")
	var reversing := not is_zero_approx(input_axis) and signf(input_axis) != signf(velocity.x)
	var skid_threshold := skid_min_speed * active_surface.skid_threshold_multiplier

	if active_surface.stickiness > 0.35 and absf(velocity.x) > 20.0:
		_set_state(STATE_STUCK, 0.0)
	elif reversing and absf(velocity.x) > skid_threshold:
		_set_state(STATE_SKID, 0.0)
	elif absf(velocity.x) > 20.0:
		_set_state(STATE_RUN, 0.0)
	else:
		_set_state(STATE_IDLE, 0.0)


func _set_state(new_state: StringName, lock_time: float) -> void:
	if movement_state != new_state:
		movement_state = new_state
		state_changed.emit(new_state)
	_state_timer = maxf(_state_timer, lock_time)
```

- [ ] **Step 3: Create `scenes/Player.tscn`**

Write:

```ini
[gd_scene load_steps=7 format=3]

[ext_resource type="Script" path="res://scripts/player/player_controller.gd" id="1_controller"]
[ext_resource type="Script" path="res://scripts/player/surface_detector.gd" id="2_detector"]
[ext_resource type="Resource" path="res://resources/surfaces/normal.tres" id="3_normal"]

[sub_resource type="CapsuleShape2D" id="CapsuleShape2D_player"]
radius = 24.0
height = 88.0

[sub_resource type="CircleShape2D" id="CircleShape2D_head"]
radius = 22.0

[sub_resource type="CircleShape2D" id="CircleShape2D_eye"]
radius = 3.0

[node name="Player" type="CharacterBody2D"]
script = ExtResource("1_controller")
default_surface = ExtResource("3_normal")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
position = Vector2(0, -44)
shape = SubResource("CapsuleShape2D_player")

[node name="SurfaceSensor" type="RayCast2D" parent="."]
script = ExtResource("2_detector")
target_position = Vector2(0, 12)
enabled = true
fallback_surface = ExtResource("3_normal")

[node name="CameraTarget" type="Marker2D" parent="."]
position = Vector2(0, -80)

[node name="AnimationPlayer" type="AnimationPlayer" parent="."]

[node name="AnimationTree" type="AnimationTree" parent="."]

[node name="VisualRoot" type="Node2D" parent="."]
position = Vector2(0, -52)

[node name="Body" type="Polygon2D" parent="VisualRoot"]
color = Color(0.06, 0.05, 0.045, 1)
polygon = PackedVector2Array(-24, -42, 24, -42, 32, 8, 18, 44, -18, 44, -32, 8)

[node name="Head" type="Polygon2D" parent="VisualRoot"]
position = Vector2(0, -70)
color = Color(0.06, 0.05, 0.045, 1)
polygon = PackedVector2Array(-26, -20, 26, -20, 32, 8, 18, 28, -18, 28, -32, 8)

[node name="LeftArm" type="Line2D" parent="VisualRoot"]
width = 8.0
default_color = Color(0.06, 0.05, 0.045, 1)
points = PackedVector2Array(-22, -28, -48, -2, -36, 28)

[node name="RightArm" type="Line2D" parent="VisualRoot"]
width = 8.0
default_color = Color(0.06, 0.05, 0.045, 1)
points = PackedVector2Array(22, -28, 48, -2, 36, 28)

[node name="LeftLeg" type="Line2D" parent="VisualRoot"]
width = 9.0
default_color = Color(0.06, 0.05, 0.045, 1)
points = PackedVector2Array(-14, 34, -30, 62, -24, 88)

[node name="RightLeg" type="Line2D" parent="VisualRoot"]
width = 9.0
default_color = Color(0.06, 0.05, 0.045, 1)
points = PackedVector2Array(14, 34, 30, 62, 24, 88)

[node name="LeftFoot" type="Polygon2D" parent="VisualRoot"]
position = Vector2(-26, 88)
color = Color(0.06, 0.05, 0.045, 1)
polygon = PackedVector2Array(-20, -5, 18, -5, 24, 3, -18, 7)

[node name="RightFoot" type="Polygon2D" parent="VisualRoot"]
position = Vector2(26, 88)
color = Color(0.06, 0.05, 0.045, 1)
polygon = PackedVector2Array(-18, -5, 20, -5, 18, 7, -24, 3)

[node name="Eyes" type="Node2D" parent="VisualRoot/Head"]

[node name="LeftEye" type="Polygon2D" parent="VisualRoot/Head/Eyes"]
position = Vector2(-10, 0)
color = Color(1, 1, 1, 1)
polygon = PackedVector2Array(-5, -6, 5, -6, 6, 5, -5, 6)

[node name="RightEye" type="Polygon2D" parent="VisualRoot/Head/Eyes"]
position = Vector2(10, 0)
color = Color(1, 1, 1, 1)
polygon = PackedVector2Array(-5, -6, 5, -6, 6, 5, -5, 6)
```

- [ ] **Step 4: Modify `scenes/Main.tscn` to instance player and connect debug overlay**

Add this ext_resource near existing ext_resources:

```ini
[ext_resource type="PackedScene" path="res://scenes/Player.tscn" id="7_player"]
```

Update the scene header to account for the added resource:

```ini
[gd_scene load_steps=9 format=3]
```

Add this node under `World` after `PlayerSpawn`:

```ini
[node name="Player" parent="World" instance=ExtResource("7_player")]
position = Vector2(120, 520)
```

Set this property on the `DebugOverlay` node:

```ini
player_path = NodePath("../World/Player")
```

- [ ] **Step 5: Verify player scene imports**

Run:

```bash
godot --headless --path . --quit
```

Expected: exit code 0 with no GDScript parse errors.

- [ ] **Step 6: Manual play check**

Open the project in Godot 4 and run `scenes/Main.tscn`.

Expected:
- A black cartoon placeholder character appears above the first platform.
- `A/D` or arrow keys move the character.
- `Space` jumps.
- Debug overlay shows state, surface, velocity, grounded flag, and impact value.

- [ ] **Step 7: Review checkpoint**

Run:

```bash
git status --short
```

Expected: player scripts, `Player.tscn`, and modified `Main.tscn` are listed. Do not commit unless explicitly requested by the user.

---

### Task 4: Add Procedural Rubber Hose Visual Feedback

**Files:**
- Create: `scripts/player/toon_animator.gd`
- Modify: `scenes/Player.tscn`

- [ ] **Step 1: Create `scripts/player/toon_animator.gd`**

Write:

```gdscript
extends Node2D

@export var player_path: NodePath = NodePath("..")
@export var squash_recovery_speed: float = 10.0
@export var lean_strength: float = 0.08
@export var run_cycle_speed: float = 0.045
@export var limb_swing_amount: float = 22.0

@onready var player: PlayerController = get_node(player_path)
@onready var body: Polygon2D = $Body
@onready var head: Polygon2D = $Head
@onready var left_arm: Line2D = $LeftArm
@onready var right_arm: Line2D = $RightArm
@onready var left_leg: Line2D = $LeftLeg
@onready var right_leg: Line2D = $RightLeg
@onready var left_foot: Polygon2D = $LeftFoot
@onready var right_foot: Polygon2D = $RightFoot
@onready var eyes: Node2D = $Head/Eyes

var _squash := Vector2.ONE
var _target_squash := Vector2.ONE
var _cycle := 0.0
var _last_velocity_x := 0.0


func _ready() -> void:
	player.impact.connect(_on_player_impact)


func _process(delta: float) -> void:
	_cycle += absf(player.velocity.x) * run_cycle_speed * delta
	_update_target_squash()
	_squash = _squash.lerp(_target_squash, clampf(delta * squash_recovery_speed, 0.0, 1.0))
	scale = _squash
	rotation = _calculate_lean()
	_update_limb_swing()
	_update_face()
	_last_velocity_x = player.velocity.x


func _update_target_squash() -> void:
	_target_squash = Vector2.ONE
	if player.active_surface == null:
		return

	match player.movement_state:
		PlayerController.STATE_JUMP:
			_target_squash = Vector2(0.88, 1.14 * player.active_surface.visual_stretch_multiplier)
		PlayerController.STATE_FALL:
			_target_squash = Vector2(0.94, 1.06)
		PlayerController.STATE_SKID:
			_target_squash = Vector2(1.12, 0.92)
		PlayerController.STATE_BOUNCE:
			_target_squash = Vector2(0.78, 1.34 * player.active_surface.visual_stretch_multiplier)
		PlayerController.STATE_STUCK:
			_target_squash = Vector2(1.08, 0.94)


func _calculate_lean() -> float:
	var acceleration := player.velocity.x - _last_velocity_x
	var lean := clampf(-acceleration * lean_strength, -0.22, 0.22)
	if player.movement_state == PlayerController.STATE_SKID:
		lean += -signf(player.velocity.x) * 0.18
	return lean


func _update_limb_swing() -> void:
	var swing := sin(_cycle) * limb_swing_amount
	var drag_multiplier := 1.0
	if player.active_surface != null:
		drag_multiplier = player.active_surface.visual_drag_multiplier

	if player.movement_state == PlayerController.STATE_STUCK:
		swing *= 0.45
		left_foot.position.y = 92.0 + absf(sin(_cycle)) * 8.0
		right_foot.position.y = 92.0 + absf(cos(_cycle)) * 8.0
	else:
		left_foot.position.y = 88.0
		right_foot.position.y = 88.0

	left_arm.rotation_degrees = swing * 0.55 * drag_multiplier
	right_arm.rotation_degrees = -swing * 0.55 * drag_multiplier
	left_leg.rotation_degrees = -swing * 0.4
	right_leg.rotation_degrees = swing * 0.4
	left_foot.rotation_degrees = -swing * 0.12
	right_foot.rotation_degrees = swing * 0.12


func _update_face() -> void:
	match player.movement_state:
		PlayerController.STATE_SKID:
			eyes.scale = Vector2(1.25, 0.85)
			eyes.position.x = -signf(player.velocity.x) * 4.0
		PlayerController.STATE_BOUNCE:
			eyes.scale = Vector2(0.8, 1.3)
			eyes.position.x = 0.0
		PlayerController.STATE_STUCK:
			eyes.scale = Vector2(0.75, 0.75)
			eyes.position.x = 0.0
		_:
			eyes.scale = eyes.scale.lerp(Vector2.ONE, 0.2)
			eyes.position = eyes.position.lerp(Vector2.ZERO, 0.2)


func _on_player_impact(strength: float) -> void:
	if player.active_surface == null:
		return
	var normalized := clampf(strength / 900.0, 0.0, 1.0)
	var squash_x := 1.0 + normalized * 0.45 * player.active_surface.visual_squash_multiplier
	var squash_y := 1.0 - normalized * 0.32 * player.active_surface.visual_squash_multiplier
	_squash = Vector2(squash_x, maxf(0.55, squash_y))
```

- [ ] **Step 2: Attach animator script to `VisualRoot` in `scenes/Player.tscn`**

Add an ext_resource:

```ini
[ext_resource type="Script" path="res://scripts/player/toon_animator.gd" id="4_toon"]
```

Update the scene header to account for the added script resource:

```ini
[gd_scene load_steps=8 format=3]
```

Update the `VisualRoot` node:

```ini
[node name="VisualRoot" type="Node2D" parent="."]
position = Vector2(0, -52)
script = ExtResource("4_toon")
```

- [ ] **Step 3: Verify animator imports**

Run:

```bash
godot --headless --path . --quit
```

Expected: exit code 0 with no parse errors.

- [ ] **Step 4: Manual visual check**

Open `scenes/Main.tscn` in Godot 4 and play.

Expected:
- Landing compresses the character visually.
- Jumping stretches the character upward.
- Running swings limbs.
- Ice skids lean the character backward.
- Slime makes feet drag lower.
- Collision shape stays fixed while `VisualRoot` deforms.

- [ ] **Step 5: Review checkpoint**

Run:

```bash
git status --short
```

Expected: `scripts/player/toon_animator.gd` and modified `scenes/Player.tscn` are listed. Do not commit unless explicitly requested by the user.

---

### Task 5: Tune Playground Camera and Surface Readability

**Files:**
- Modify: `scenes/Main.tscn`
- Modify: `scenes/Player.tscn`
- Modify: `scripts/debug/debug_overlay.gd`

- [ ] **Step 1: Move camera into the player scene**

In `scenes/Main.tscn`, remove the old `Camera2D` node under `World`:

```ini
[node name="Camera2D" type="Camera2D" parent="World"]
```

In `scenes/Player.tscn`, add this node under the root `Player` node:

```ini
[node name="Camera2D" type="Camera2D" parent="."]
position = Vector2(180, -140)
enabled = true
zoom = Vector2(0.9, 0.9)
position_smoothing_enabled = true
position_smoothing_speed = 6.0
```

- [ ] **Step 2: Add surface labels to `scenes/Main.tscn`**

Add these labels under `World`:

```ini
[node name="NormalLabel" type="Label" parent="World"]
position = Vector2(80, 540)
text = "NORMAL"

[node name="IceLabel" type="Label" parent="World"]
position = Vector2(580, 540)
text = "ICE: slide + skid"

[node name="ElasticLabel" type="Label" parent="World"]
position = Vector2(1040, 540)
text = "ELASTIC: bounce"

[node name="SlimeLabel" type="Label" parent="World"]
position = Vector2(1520, 540)
text = "SLIME: drag + stuck"
```

- [ ] **Step 3: Improve debug overlay with controls hint**

Replace `scripts/debug/debug_overlay.gd` with:

```gdscript
extends CanvasLayer

@export var player_path: NodePath

@onready var label: Label = $PanelContainer/MarginContainer/Label

var player: Node = null


func _ready() -> void:
	if player_path != NodePath():
		player = get_node_or_null(player_path)


func _process(_delta: float) -> void:
	if player == null:
		label.text = "Player: not assigned\nControls: A/D or arrows, Space"
		return

	var surface_name := "none"
	if player.active_surface != null:
		surface_name = player.active_surface.display_name

	label.text = "Controls: A/D or arrows, Space\nState: %s\nSurface: %s\nVelocity: %.1f, %.1f\nGrounded: %s\nImpact: %.1f" % [
		player.movement_state,
		surface_name,
		player.velocity.x,
		player.velocity.y,
		str(player.is_on_floor()),
		player.last_impact_strength,
	]
```

- [ ] **Step 4: Verify scene imports**

Run:

```bash
godot --headless --path . --quit
```

Expected: exit code 0.

- [ ] **Step 5: Manual readability check**

Play `scenes/Main.tscn`.

Expected:
- Camera follows the player across all four zones.
- Surface labels are visible before or while entering each zone.
- Debug overlay includes controls and live movement data.

- [ ] **Step 6: Review checkpoint**

Run:

```bash
git status --short
```

Expected: modified `scenes/Main.tscn` and `scripts/debug/debug_overlay.gd` are listed. Do not commit unless explicitly requested by the user.

---

### Task 6: Final Prototype Verification and Tuning Pass

**Files:**
- Modify: `scripts/player/player_controller.gd`
- Modify: `scripts/player/toon_animator.gd`
- Modify: `resources/surfaces/normal.tres`
- Modify: `resources/surfaces/ice.tres`
- Modify: `resources/surfaces/elastic.tres`
- Modify: `resources/surfaces/slime.tres`

- [ ] **Step 1: Run headless import verification**

Run:

```bash
godot --headless --path . --quit
```

Expected: exit code 0.

- [ ] **Step 2: Manual normal-ground check**

Play `scenes/Main.tscn` and stay on the normal zone.

Expected:
- Player accelerates quickly and stops predictably.
- Jump reaches a readable height.
- Landing causes visible squash and recovers within about 0.2 seconds.
- Debug surface reads `Normal`.

- [ ] **Step 3: Manual ice check**

Move into the ice zone, release input, then reverse direction.

Expected:
- Player slides after input is released.
- Reversing at speed enters `skid`.
- Body leans backward and eyes change shape.
- Debug surface reads `Ice`.

- [ ] **Step 4: Manual elastic check**

Jump or fall onto the elastic zone.

Expected:
- Player rebounds upward after landing.
- Larger fall produces larger bounce within controllable bounds.
- Debug state enters `bounce`.
- VisualRoot stretches tall after the bounce.

- [ ] **Step 5: Manual slime check**

Move through the slime zone and jump inside it.

Expected:
- Horizontal movement is slower.
- Jump is weaker than normal ground.
- Debug state can enter `stuck` while moving.
- Feet drag downward during movement.
- Debug surface reads `Slime`.

- [ ] **Step 6: Tune values if any manual check fails**

Use these exact starting corrections:

```text
If normal movement feels too slow: increase Player.base_acceleration by 200 and Player.base_max_speed by 20.
If normal stopping feels too floaty: increase Player.base_friction by 300.
If ice does not slide: reduce ice.friction_multiplier by 0.02, minimum 0.03.
If ice is uncontrollable: increase ice.acceleration_multiplier by 0.05, maximum 0.75.
If elastic bounce is weak: increase elastic.bounce_multiplier by 0.08, maximum 0.9.
If elastic bounce is too high: reduce elastic.bounce_multiplier by 0.08, minimum 0.45.
If slime is barely different: reduce slime.max_speed_multiplier by 0.05 and increase slime.stickiness by 0.05.
If slime is frustrating: increase slime.max_speed_multiplier by 0.05 and reduce slime.stickiness by 0.05.
```

After each change, rerun the relevant manual check.

- [ ] **Step 7: Verify collision stability**

Play for two minutes and cross all surfaces repeatedly.

Expected:
- Player does not fall through platforms.
- Player does not stick permanently to walls.
- VisualRoot deformation does not move `CollisionShape2D`.
- State display does not flicker every frame between two labels.

- [ ] **Step 8: Final headless verification**

Run:

```bash
godot --headless --path . --quit
```

Expected: exit code 0.

- [ ] **Step 9: Final review checkpoint**

Run:

```bash
git status --short
```

Expected: all prototype files are listed as new or modified. Do not commit unless explicitly requested by the user.

---

## Spec Coverage Review

- Godot 4 side-scrolling prototype: Task 1 creates the project and main scene.
- `CharacterBody2D` gameplay controller: Task 3 creates `PlayerController`.
- Surface profiles for normal, ice, elastic, and slime/mud: Task 2 creates `SurfaceProfile` resources.
- Surface-driven movement differences: Task 3 applies profile values to movement and bounce.
- Procedural Rubber Hose visual layer: Task 4 creates `ToonAnimator`.
- Stable collision separate from visual deformation: Task 3 keeps `CollisionShape2D` on the root, Task 4 only deforms `VisualRoot`.
- Debug overlay: Task 1 creates it, Task 5 improves it.
- Test playground with four zones: Task 2 builds the zones, Task 5 improves readability.
- Tuning and validation: Task 6 defines manual checks and exact correction rules.

## Handoff Notes

- Implement tasks in order. Later tasks depend on scenes and scripts created earlier.
- Use Godot 4.x. Godot 3.x will not match the `CharacterBody2D` and resource behavior used here.
- Do not suppress GDScript errors. Fix parse/import errors directly.
- Do not let visual deformation alter `CollisionShape2D`; all squash/stretch belongs under `VisualRoot`.
- Do not run `git commit` unless the user explicitly asks for commits.

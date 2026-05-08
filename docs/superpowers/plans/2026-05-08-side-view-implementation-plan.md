# Side-View Character Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add side-view rendering for directional character actions (run/jump/fall/skid/stuck) while keeping front-view for non-directional states (idle/land/bounce).

**Architecture:** Data-driven view switching in ToonAnimator — two sets of base geometry data (front/side), instant view switch based on movement state, vertical limb swing for side-view animation, polygon mirroring for left-facing direction. Decorative nodes grouped into FrontDeco/SideDeco visibility containers.

**Tech Stack:** Godot 4, GDScript, Polygon2D, Line2D procedural animation

---

## File Structure

| File | Role | Change Type |
|------|------|-------------|
| `scripts/player/toon_animator.gd` | View system + side-view animation | **Major modify** |
| `scenes/Player.tscn` | FrontDeco/SideDeco containers, side-view geometry | **Major modify** |
| `tests/task6_miner_visual_checks.gd` | Add FrontDeco/SideDeco assertions | **Minor modify** |
| `scripts/player/player_controller.gd` | No changes | — |
| `tests/task4_toon_animator_checks.gd` | No changes needed (skid triggers side-view, still produces non-zero offsets) | — |

---

## Problem Statement

The current character is **100% front-view** — all body parts (arms, legs, eyes, feet) are arranged symmetrically around X=0. This looks wrong for a side-scrolling game when the character is performing directional actions like walking, jumping, running, and skidding. These actions should show the character in **profile (side-view)**.

### View Selection Rule

| State | View | Rationale |
|-------|------|-----------|
| `idle` | Front | Non-directional resting pose |
| `run` | **Side** | Directional movement — profile view correct |
| `jump` | **Side** | Moving upward with horizontal velocity — profile view |
| `fall` | **Side** | Descending with horizontal velocity — profile view |
| `land` | Front | Brief transitional (0.12s lock) — vertical event, front reads well |
| `skid` | **Side** | Strong directional lean — profile view essential |
| `bounce` | Front | Brief transitional (0.18s lock) — vertical rebound, front is fine |
| `stuck` | **Side** | Directional resistance — character struggling against motion direction |

### Transition Style: Instant Switch (no blending)

Rubber-hose animation style is inherently snappy (think Cuphead, Fleischer cartoons). Instant view changes are stylistically correct and simple to implement.

---

### Task 1: Add View Enum and Dual Base Data to ToonAnimator

**Files:**
- Modify: `scripts/player/toon_animator.gd:1-31`

This task adds the view enum, dual base data variables, and deco container references. No visual change yet — just scaffolding.

- [ ] **Step 1: Add View enum and new variables after existing variables (line 30)**

Replace the variable block (lines 9-30) with:

```gdscript
enum View { FRONT, SIDE }

var player: CharacterBody2D = null
var body: Polygon2D = null
var head: Polygon2D = null
var left_arm: Line2D = null
var right_arm: Line2D = null
var left_leg: Line2D = null
var right_leg: Line2D = null
var left_foot: Polygon2D = null
var right_foot: Polygon2D = null
var eyes: Node2D = null
var front_deco: Node2D = null
var side_deco: Node2D = null
var left_eye: Polygon2D = null
var right_eye: Polygon2D = null

var current_view: View = View.FRONT
var _last_mirror_direction: float = 1.0

# Front-view base data (populated from scene defaults)
var _front_base_body_position := Vector2.ZERO
var _front_base_head_position := Vector2.ZERO
var _front_base_left_arm_points := PackedVector2Array()
var _front_base_right_arm_points := PackedVector2Array()
var _front_base_left_leg_points := PackedVector2Array()
var _front_base_right_leg_points := PackedVector2Array()
var _front_base_left_foot_position := Vector2.ZERO
var _front_base_right_foot_position := Vector2.ZERO
var _front_base_eyes_position := Vector2.ZERO
var _front_base_left_arm_position := Vector2.ZERO
var _front_base_right_arm_position := Vector2.ZERO
var _front_base_left_leg_position := Vector2.ZERO
var _front_base_right_leg_position := Vector2.ZERO
var _front_base_body_polygon := PackedVector2Array()
var _front_base_head_polygon := PackedVector2Array()
var _front_base_left_foot_polygon := PackedVector2Array()
var _front_base_right_foot_polygon := PackedVector2Array()
var _front_base_left_eye_position := Vector2.ZERO
var _front_base_right_eye_position := Vector2.ZERO
var _front_base_left_eye_polygon := PackedVector2Array()
var _front_base_right_eye_polygon := PackedVector2Array()

# Front-view head decoration positions
var _front_base_helmet_position := Vector2.ZERO
var _front_base_helmet_brim_position := Vector2.ZERO
var _front_base_head_lamp_position := Vector2.ZERO
var _front_base_lamp_glow_position := Vector2.ZERO
var _front_base_mouth_position := Vector2.ZERO
var _front_base_cheek_position := Vector2.ZERO
var _front_base_hair_tuft_position := Vector2.ZERO
var _front_base_ear_left_position := Vector2.ZERO

# Side-view base data (hardcoded, facing right)
var _side_base_body_position := Vector2(2, 0)
var _side_base_head_position := Vector2(4, -39)
var _side_base_left_arm_points := PackedVector2Array()
var _side_base_right_arm_points := PackedVector2Array()
var _side_base_left_leg_points := PackedVector2Array()
var _side_base_right_leg_points := PackedVector2Array()
var _side_base_left_foot_position := Vector2(-2, 64)
var _side_base_right_foot_position := Vector2(4, 64)
var _side_base_eyes_position := Vector2(3, -1)
var _side_base_body_polygon := PackedVector2Array(-8, -22, 12, -22, 14, 24, -10, 24)
var _side_base_head_polygon := PackedVector2Array(-15, -17, 10, -19, 18, -5, 12, 20, -5, 22, -18, 5)
var _side_base_left_foot_polygon := PackedVector2Array(-10, -6, 8, -8, 14, 2, 6, 10, -14, 8)
var _side_base_right_foot_polygon := PackedVector2Array(-8, -8, 14, -6, 18, 4, 4, 10, -12, 2)
var _side_base_left_eye_position := Vector2(-3, 0)
var _side_base_right_eye_position := Vector2(5, 0)
var _side_base_left_eye_polygon := PackedVector2Array(-4, -9, 5, -9, 6, 8, -5, 8)
var _side_base_right_eye_polygon := PackedVector2Array(-5, -9, 4, -9, 5, 8, -6, 8)

# Side-view head decoration positions (facing right)
var _side_base_helmet_position := Vector2(3, -17)
var _side_base_helmet_brim_position := Vector2(4, -10)
var _side_base_head_lamp_position := Vector2(12, -27)
var _side_base_lamp_glow_position := Vector2(22, -29)
var _side_base_mouth_position := Vector2(5, 13)
var _side_base_cheek_position := Vector2(12, 8)
var _side_base_hair_tuft_position := Vector2(10, -15)
var _side_base_ear_left_position := Vector2(-16, 5)

# Active base data (points to either front or side set)
var _base_body_position := Vector2.ZERO
var _base_head_position := Vector2.ZERO
var _base_left_arm_points := PackedVector2Array()
var _base_right_arm_points := PackedVector2Array()
var _base_left_leg_points := PackedVector2Array()
var _base_right_leg_points := PackedVector2Array()
var _base_left_foot_position := Vector2.ZERO
var _base_right_foot_position := Vector2.ZERO
var _base_eyes_position := Vector2.ZERO

var _run_cycle := 0.0
var _impact_squash := 0.0
```

- [ ] **Step 2: Rewrite `_store_base_visuals()` with dual data storage**

Replace the entire `_store_base_visuals()` function (lines 84-102) with:

```gdscript
func _store_base_visuals() -> void:
	# --- Front-view base data (from scene) ---
	if body != null:
		_front_base_body_position = body.position
		_front_base_body_polygon = body.polygon
	if head != null:
		_front_base_head_position = head.position
		_front_base_head_polygon = head.polygon
	if left_arm != null:
		_front_base_left_arm_points = left_arm.points
		_front_base_left_arm_position = left_arm.position
	if right_arm != null:
		_front_base_right_arm_points = right_arm.points
		_front_base_right_arm_position = right_arm.position
	if left_leg != null:
		_front_base_left_leg_points = left_leg.points
		_front_base_left_leg_position = left_leg.position
	if right_leg != null:
		_front_base_right_leg_points = right_leg.points
		_front_base_right_leg_position = right_leg.position
	if left_foot != null:
		_front_base_left_foot_position = left_foot.position
		_front_base_left_foot_polygon = left_foot.polygon
	if right_foot != null:
		_front_base_right_foot_position = right_foot.position
		_front_base_right_foot_polygon = right_foot.polygon
	if eyes != null:
		_front_base_eyes_position = eyes.position
	if left_eye != null:
		_front_base_left_eye_position = left_eye.position
		_front_base_left_eye_polygon = left_eye.polygon
	if right_eye != null:
		_front_base_right_eye_position = right_eye.position
		_front_base_right_eye_polygon = right_eye.polygon

	# --- Front-view head decoration positions (from scene) ---
	if head != null:
		var helmet := head.get_node_or_null("Helmet") as Polygon2D
		if helmet != null:
			_front_base_helmet_position = helmet.position
		var brim := head.get_node_or_null("HelmetBrim") as Polygon2D
		if brim != null:
			_front_base_helmet_brim_position = brim.position
		var lamp := head.get_node_or_null("HeadLamp") as Polygon2D
		if lamp != null:
			_front_base_head_lamp_position = lamp.position
		var glow := head.get_node_or_null("LampGlow") as Polygon2D
		if glow != null:
			_front_base_lamp_glow_position = glow.position
		var mouth := head.get_node_or_null("Mouth") as Polygon2D
		if mouth != null:
			_front_base_mouth_position = mouth.position
		var cheek := head.get_node_or_null("Cheek") as Polygon2D
		if cheek != null:
			_front_base_cheek_position = cheek.position
		var tuft := head.get_node_or_null("HairTuft") as Polygon2D
		if tuft != null:
			_front_base_hair_tuft_position = tuft.position
		var ear := head.get_node_or_null("EarLeft") as Polygon2D
		if ear != null:
			_front_base_ear_left_position = ear.position

	# --- Side-view base data (hardcoded, facing right) ---
	# Back arm (LeftArm node) — hangs behind body
	_side_base_left_arm_points = PackedVector2Array(
		Vector2(0, 0), Vector2(-2, 20), Vector2(-4, 42)
	)
	# Front arm (RightArm node) — reaches in front
	_side_base_right_arm_points = PackedVector2Array(
		Vector2(0, 0), Vector2(6, 20), Vector2(4, 42)
	)
	# Back leg (LeftLeg node) — trails behind
	_side_base_left_leg_points = PackedVector2Array(
		Vector2(0, 0), Vector2(-3, 22), Vector2(-5, 42)
	)
	# Front leg (RightLeg node) — steps forward
	_side_base_right_leg_points = PackedVector2Array(
		Vector2(0, 0), Vector2(3, 22), Vector2(5, 42)
	)

	# --- Initialize active base data to front-view ---
	_base_body_position = _front_base_body_position
	_base_head_position = _front_base_head_position
	_base_left_arm_points = _front_base_left_arm_points
	_base_right_arm_points = _front_base_right_arm_points
	_base_left_leg_points = _front_base_left_leg_points
	_base_right_leg_points = _front_base_right_leg_points
	_base_left_foot_position = _front_base_left_foot_position
	_base_right_foot_position = _front_base_right_foot_position
	_base_eyes_position = _front_base_eyes_position
```

- [ ] **Step 3: Add node references for deco containers and eyes in `_ready()`**

After the line `eyes = get_node_or_null("Head/Eyes") as Node2D` (line 48), add:

```gdscript
	left_eye = get_node_or_null("Head/Eyes/LeftEye") as Polygon2D
	right_eye = get_node_or_null("Head/Eyes/RightEye") as Polygon2D
	front_deco = get_node_or_null("FrontDeco") as Node2D
	side_deco = get_node_or_null("SideDeco") as Node2D
```

- [ ] **Step 4: Commit**

```bash
git add scripts/player/toon_animator.gd
git commit -m "feat: add View enum, dual base data, and deco container refs to ToonAnimator"
```

---

### Task 2: Add View Selection, Switching, and Mirroring Logic

**Files:**
- Modify: `scripts/player/toon_animator.gd`

- [ ] **Step 1: Add `_update_view()`, `_apply_view()`, `_mirror_side_view()`, and `_mirror_polygon()` methods**

Add these four methods before `_player_state()` (before line 251):

```gdscript
func _update_view(state: StringName) -> void:
	var target_view: View = View.FRONT
	match state:
		&"run", &"jump", &"fall", &"skid", &"stuck":
			target_view = View.SIDE
	if current_view != target_view:
		current_view = target_view
		_apply_view()


func _apply_view() -> void:
	var is_side := current_view == View.SIDE

	# Swap active base data
	if is_side:
		_base_body_position = _side_base_body_position
		_base_head_position = _side_base_head_position
		_base_left_arm_points = _side_base_left_arm_points
		_base_right_arm_points = _side_base_right_arm_points
		_base_left_leg_points = _side_base_left_leg_points
		_base_right_leg_points = _side_base_right_leg_points
		_base_left_foot_position = _side_base_left_foot_position
		_base_right_foot_position = _side_base_right_foot_position
		_base_eyes_position = _side_base_eyes_position
	else:
		_base_body_position = _front_base_body_position
		_base_head_position = _front_base_head_position
		_base_left_arm_points = _front_base_left_arm_points
		_base_right_arm_points = _front_base_right_arm_points
		_base_left_leg_points = _front_base_left_leg_points
		_base_right_leg_points = _front_base_right_leg_points
		_base_left_foot_position = _front_base_left_foot_position
		_base_right_foot_position = _front_base_right_foot_position
		_base_eyes_position = _front_base_eyes_position

	# Swap polygon shapes for body, head, feet
	if body != null:
		body.polygon = _side_base_body_polygon if is_side else _front_base_body_polygon
	if head != null:
		head.polygon = _side_base_head_polygon if is_side else _front_base_head_polygon
	if left_foot != null:
		left_foot.polygon = _side_base_left_foot_polygon if is_side else _front_base_left_foot_polygon
	if right_foot != null:
		right_foot.polygon = _side_base_right_foot_polygon if is_side else _front_base_right_foot_polygon

	# Swap eye positions and shapes
	if left_eye != null:
		left_eye.position = _side_base_left_eye_position if is_side else _front_base_left_eye_position
		left_eye.polygon = _side_base_left_eye_polygon if is_side else _front_base_left_eye_polygon
		left_eye.visible = not is_side  # Hide back eye in side-view
	if right_eye != null:
		right_eye.position = _side_base_right_eye_position if is_side else _front_base_right_eye_position
		right_eye.polygon = _side_base_right_eye_polygon if is_side else _front_base_right_eye_polygon

	# Swap limb positions (fore/aft overlap in side-view vs left/right spread in front-view)
	if left_arm != null:
		left_arm.position = Vector2(2, -16) if is_side else _front_base_left_arm_position
	if right_arm != null:
		right_arm.position = Vector2(4, -16) if is_side else _front_base_right_arm_position
	if left_leg != null:
		left_leg.position = Vector2(-1, 20) if is_side else _front_base_left_leg_position
	if right_leg != null:
		right_leg.position = Vector2(3, 20) if is_side else _front_base_right_leg_position

	# Swap head decoration positions
	if head != null:
		var helmet := head.get_node_or_null("Helmet") as Polygon2D
		if helmet != null:
			helmet.position = _side_base_helmet_position if is_side else _front_base_helmet_position
		var brim := head.get_node_or_null("HelmetBrim") as Polygon2D
		if brim != null:
			brim.position = _side_base_helmet_brim_position if is_side else _front_base_helmet_brim_position
		var lamp := head.get_node_or_null("HeadLamp") as Polygon2D
		if lamp != null:
			lamp.position = _side_base_head_lamp_position if is_side else _front_base_head_lamp_position
		var glow := head.get_node_or_null("LampGlow") as Polygon2D
		if glow != null:
			glow.position = _side_base_lamp_glow_position if is_side else _front_base_lamp_glow_position
		var mouth := head.get_node_or_null("Mouth") as Polygon2D
		if mouth != null:
			mouth.position = _side_base_mouth_position if is_side else _front_base_mouth_position
		var cheek := head.get_node_or_null("Cheek") as Polygon2D
		if cheek != null:
			cheek.position = _side_base_cheek_position if is_side else _front_base_cheek_position
			cheek.visible = not is_side  # Cheek hidden in side-view
		var tuft := head.get_node_or_null("HairTuft") as Polygon2D
		if tuft != null:
			tuft.position = _side_base_hair_tuft_position if is_side else _front_base_hair_tuft_position
		var ear := head.get_node_or_null("EarLeft") as Polygon2D
		if ear != null:
			ear.position = _side_base_ear_left_position if is_side else _front_base_ear_left_position

	# Toggle deco containers
	if front_deco != null:
		front_deco.visible = not is_side
	if side_deco != null:
		side_deco.visible = is_side

	# Apply direction mirroring for side-view
	if is_side and player != null:
		var direction := _facing_direction(player.velocity.x)
		_last_mirror_direction = direction
		_mirror_side_view(direction)


func _mirror_side_view(direction: float) -> void:
	if direction >= 0.0:
		# Facing right — use default side-view data as-is
		if body != null:
			body.polygon = _side_base_body_polygon
		if head != null:
			head.polygon = _side_base_head_polygon
		if left_foot != null:
			left_foot.polygon = _side_base_left_foot_polygon
			left_foot.position = _side_base_left_foot_position
		if right_foot != null:
			right_foot.polygon = _side_base_right_foot_polygon
			right_foot.position = _side_base_right_foot_position
		if left_eye != null:
			left_eye.polygon = _side_base_left_eye_polygon
			left_eye.position = _side_base_left_eye_position
		if right_eye != null:
			right_eye.polygon = _side_base_right_eye_polygon
			right_eye.position = _side_base_right_eye_position
		if left_arm != null:
			left_arm.position = Vector2(2, -16)
		if right_arm != null:
			right_arm.position = Vector2(4, -16)
		if left_leg != null:
			left_leg.position = Vector2(-1, 20)
		if right_leg != null:
			right_leg.position = Vector2(3, 20)
		if head != null:
			var helmet := head.get_node_or_null("Helmet") as Polygon2D
			if helmet != null:
				helmet.position = _side_base_helmet_position
			var brim := head.get_node_or_null("HelmetBrim") as Polygon2D
			if brim != null:
				brim.position = _side_base_helmet_brim_position
			var lamp := head.get_node_or_null("HeadLamp") as Polygon2D
			if lamp != null:
				lamp.position = _side_base_head_lamp_position
			var glow := head.get_node_or_null("LampGlow") as Polygon2D
			if glow != null:
				glow.position = _side_base_lamp_glow_position
			var mouth := head.get_node_or_null("Mouth") as Polygon2D
			if mouth != null:
				mouth.position = _side_base_mouth_position
			var cheek := head.get_node_or_null("Cheek") as Polygon2D
			if cheek != null:
				cheek.position = _side_base_cheek_position
			var tuft := head.get_node_or_null("HairTuft") as Polygon2D
			if tuft != null:
				tuft.position = _side_base_hair_tuft_position
			var ear := head.get_node_or_null("EarLeft") as Polygon2D
			if ear != null:
				ear.position = _side_base_ear_left_position
	else:
		# Facing left — mirror X coordinates
		if body != null:
			body.polygon = _mirror_polygon(_side_base_body_polygon)
		if head != null:
			head.polygon = _mirror_polygon(_side_base_head_polygon)
		if left_foot != null:
			left_foot.polygon = _mirror_polygon(_side_base_left_foot_polygon)
			left_foot.position = Vector2(-_side_base_left_foot_position.x, _side_base_left_foot_position.y)
		if right_foot != null:
			right_foot.polygon = _mirror_polygon(_side_base_right_foot_polygon)
			right_foot.position = Vector2(-_side_base_right_foot_position.x, _side_base_right_foot_position.y)
		if left_eye != null:
			left_eye.polygon = _mirror_polygon(_side_base_left_eye_polygon)
			left_eye.position = Vector2(-_side_base_left_eye_position.x, _side_base_left_eye_position.y)
		if right_eye != null:
			right_eye.polygon = _mirror_polygon(_side_base_right_eye_polygon)
			right_eye.position = Vector2(-_side_base_right_eye_position.x, _side_base_right_eye_position.y)
		if left_arm != null:
			left_arm.position = Vector2(-2, -16)
		if right_arm != null:
			right_arm.position = Vector2(-4, -16)
		if left_leg != null:
			left_leg.position = Vector2(1, 20)
		if right_leg != null:
			right_leg.position = Vector2(-3, 20)
		if head != null:
			var helmet := head.get_node_or_null("Helmet") as Polygon2D
			if helmet != null:
				helmet.position = Vector2(-_side_base_helmet_position.x, _side_base_helmet_position.y)
			var brim := head.get_node_or_null("HelmetBrim") as Polygon2D
			if brim != null:
				brim.position = Vector2(-_side_base_helmet_brim_position.x, _side_base_helmet_brim_position.y)
			var lamp := head.get_node_or_null("HeadLamp") as Polygon2D
			if lamp != null:
				lamp.position = Vector2(-_side_base_head_lamp_position.x, _side_base_head_lamp_position.y)
			var glow := head.get_node_or_null("LampGlow") as Polygon2D
			if glow != null:
				glow.position = Vector2(-_side_base_lamp_glow_position.x, _side_base_lamp_glow_position.y)
			var mouth := head.get_node_or_null("Mouth") as Polygon2D
			if mouth != null:
				mouth.position = Vector2(-_side_base_mouth_position.x, _side_base_mouth_position.y)
			var cheek := head.get_node_or_null("Cheek") as Polygon2D
			if cheek != null:
				cheek.position = Vector2(-_side_base_cheek_position.x, _side_base_cheek_position.y)
			var tuft := head.get_node_or_null("HairTuft") as Polygon2D
			if tuft != null:
				tuft.position = Vector2(-_side_base_hair_tuft_position.x, _side_base_hair_tuft_position.y)
			var ear := head.get_node_or_null("EarLeft") as Polygon2D
			if ear != null:
				ear.position = Vector2(-_side_base_ear_left_position.x, _side_base_ear_left_position.y)

	# Mirror side-view decorative nodes
	if side_deco != null:
		side_deco.scale.x = direction if direction != 0.0 else 1.0


func _mirror_polygon(points: PackedVector2Array) -> PackedVector2Array:
	var mirrored := PackedVector2Array()
	for point in points:
		mirrored.append(Vector2(-point.x, point.y))
	return mirrored
```

- [ ] **Step 2: Wire `_update_view()` into `_process()`**

In `_process()`, add the view update call right after `var state := _player_state()` (line 63):

```gdscript
	var state := _player_state()
	_update_view(state)
	var direction := _facing_direction(horizontal_speed)
```

- [ ] **Step 3: Add direction-change mirroring at end of `_process()`**

At the end of `_process()`, after `_apply_eye_expression(state, direction, speed_ratio)` (line 81), add:

```gdscript
	# Update side-view direction mirror when direction changes
	if current_view == View.SIDE:
		if not is_equal_approx(direction, _last_mirror_direction):
			_last_mirror_direction = direction
			_mirror_side_view(direction)
```

- [ ] **Step 4: Commit**

```bash
git add scripts/player/toon_animator.gd
git commit -m "feat: add view selection, switching, polygon mirroring, and direction flipping"
```

---

### Task 3: Add Side-View Animation Branches

**Files:**
- Modify: `scripts/player/toon_animator.gd`

- [ ] **Step 1: Add `_set_limb_points_vertical()` helper after `_set_limb_points()` (after line 202)**

```gdscript
func _set_limb_points_vertical(limb: Line2D, base_points: PackedVector2Array, y_offset: float, bend_weight: float) -> void:
	if limb == null or base_points.size() == 0:
		return
	var updated := PackedVector2Array()
	for index in base_points.size():
		var point := base_points[index]
		if index == 1:
			point.y += y_offset * bend_weight
		elif index > 1:
			point.y += y_offset
		updated.append(point)
	limb.points = updated
```

- [ ] **Step 2: Branch `_apply_limb_swing()` for side-view (replace lines 172-188)**

```gdscript
func _apply_limb_swing(state: StringName, direction: float, speed_ratio: float, surface_drag: float) -> void:
	var swing := sin(_run_cycle) * limb_swing_amount * speed_ratio
	var counter_swing := sin(_run_cycle + PI) * limb_swing_amount * speed_ratio
	var drag_bias := 0.0
	if state == &"skid" or state == &"stuck":
		drag_bias = -direction * limb_swing_amount * 0.65 * surface_drag
	if state == &"stuck":
		swing *= 0.35
		counter_swing *= 0.35
	elif state == &"jump" or state == &"fall" or state == &"bounce":
		swing *= 0.35
		counter_swing *= 0.35

	if current_view == View.SIDE:
		# Side-view: limbs swing fore/aft (Y-axis)
		_set_limb_points_vertical(left_arm, _base_left_arm_points, counter_swing + drag_bias, 0.55)
		_set_limb_points_vertical(right_arm, _base_right_arm_points, swing + drag_bias, 0.55)
		_set_limb_points_vertical(left_leg, _base_left_leg_points, swing + drag_bias, 0.75)
		_set_limb_points_vertical(right_leg, _base_right_leg_points, counter_swing + drag_bias, 0.75)
	else:
		# Front-view: limbs swing laterally (X-axis)
		_set_limb_points(left_arm, _base_left_arm_points, counter_swing + drag_bias, 0.55)
		_set_limb_points(right_arm, _base_right_arm_points, swing + drag_bias, 0.55)
		_set_limb_points(left_leg, _base_left_leg_points, swing + drag_bias, 0.75)
		_set_limb_points(right_leg, _base_right_leg_points, counter_swing + drag_bias, 0.75)
```

- [ ] **Step 3: Branch `_apply_foot_drag()` for side-view (replace lines 205-226)**

```gdscript
func _apply_foot_drag(state: StringName, direction: float, speed_ratio: float, surface_drag: float) -> void:
	var swing := sin(_run_cycle) * limb_swing_amount * 0.55 * speed_ratio
	var drag := -direction * limb_swing_amount * 0.8 * surface_drag

	if current_view == View.SIDE:
		# Side-view: feet drag fore/aft
		var front_offset := Vector2(0.0, -swing)
		var back_offset := Vector2(0.0, swing)

		match state:
			&"skid":
				front_offset += Vector2(drag * 0.6, 3.0 * surface_drag)
				back_offset += Vector2(drag * 0.6, 3.0 * surface_drag)
			&"stuck":
				front_offset = Vector2(drag * 0.8, 6.0 * surface_drag)
				back_offset = Vector2(drag * 1.0, 7.0 * surface_drag)
			&"jump", &"bounce":
				front_offset = Vector2(-direction * 2.0, -4.0)
				back_offset = Vector2(-direction * 2.0, -4.0)
			&"fall":
				front_offset = Vector2(-direction * 1.5, -2.0)
				back_offset = Vector2(-direction * 1.5, -2.0)

		left_foot.position = _base_left_foot_position + back_offset
		right_foot.position = _base_right_foot_position + front_offset
	else:
		# Front-view: feet drag laterally (original behavior)
		var left_offset := Vector2(-swing, 0.0)
		var right_offset := Vector2(swing, 0.0)

		match state:
			&"skid":
				left_offset += Vector2(drag * 1.2, 3.0 * surface_drag)
				right_offset += Vector2(drag * 1.2, 3.0 * surface_drag)
			&"stuck":
				left_offset = Vector2(drag * 1.6, 6.0 * surface_drag)
				right_offset = Vector2(drag * 1.2, 7.0 * surface_drag)
			&"jump", &"bounce":
				left_offset = Vector2(-direction * 3.0, -4.0)
				right_offset = Vector2(-direction * 3.0, -4.0)
			&"fall":
				left_offset = Vector2(-direction * 2.0, -2.0)
				right_offset = Vector2(-direction * 2.0, -2.0)

		left_foot.position = _base_left_foot_position + left_offset
		right_foot.position = _base_right_foot_position + right_offset
```

- [ ] **Step 4: Branch `_apply_eye_expression()` for side-view (replace lines 229-248)**

```gdscript
func _apply_eye_expression(state: StringName, direction: float, speed_ratio: float) -> void:
	eyes.position = _base_eyes_position
	eyes.scale = Vector2.ONE
	eyes.rotation = 0.0

	if current_view == View.SIDE:
		# Side-view: only right eye visible (front eye)
		if left_eye != null:
			left_eye.visible = false
		if right_eye != null:
			right_eye.visible = true
		match state:
			&"skid":
				eyes.position = _base_eyes_position + Vector2(-direction * 2.0, 1.5)
				eyes.scale = Vector2(1.25, 0.58)
				eyes.rotation = direction * 0.08
			&"stuck":
				eyes.position = _base_eyes_position + Vector2(-direction * 1.0, 2.0)
				eyes.scale = Vector2(0.82, 0.72)
			&"jump", &"bounce":
				eyes.position = _base_eyes_position + Vector2(-direction * 1.0, -1.0)
				eyes.scale = Vector2(0.85, 1.18)
			&"fall":
				eyes.position = _base_eyes_position + Vector2(-direction * speed_ratio * 1.5, 0.5)
				eyes.scale = Vector2(1.08, 0.9)
			&"run":
				eyes.position = _base_eyes_position + Vector2(-direction * speed_ratio * 1.5, 0.0)
	else:
		# Front-view: both eyes visible
		if left_eye != null:
			left_eye.visible = true
		if right_eye != null:
			right_eye.visible = true
		match state:
			&"skid":
				eyes.position = _base_eyes_position + Vector2(direction * 3.0, 1.5)
				eyes.scale = Vector2(1.25, 0.58)
				eyes.rotation = -direction * 0.08
			&"stuck":
				eyes.position = _base_eyes_position + Vector2(direction * 1.5, 2.0)
				eyes.scale = Vector2(0.82, 0.72)
			&"jump", &"bounce":
				eyes.position = _base_eyes_position + Vector2(direction * 1.5, -1.0)
				eyes.scale = Vector2(0.85, 1.18)
			&"fall":
				eyes.position = _base_eyes_position + Vector2(direction * speed_ratio * 2.0, 0.5)
				eyes.scale = Vector2(1.08, 0.9)
			&"run":
				eyes.position = _base_eyes_position + Vector2(direction * speed_ratio * 2.0, 0.0)
```

- [ ] **Step 5: Branch `_apply_body_offsets()` for side-view (replace lines 160-169)**

```gdscript
func _apply_body_offsets(state: StringName) -> void:
	body.position = _base_body_position
	head.position = _base_head_position
	match state:
		&"jump", &"bounce":
			head.position = _base_head_position + Vector2(0.0, -3.0)
			if current_view == View.SIDE:
				head.position += Vector2(2.0, 0.0)  # Head juts forward on jump
		&"fall":
			head.position = _base_head_position + Vector2(0.0, -1.5)
		&"land", &"skid", &"stuck":
			head.position = _base_head_position + Vector2(0.0, 2.5)
			if current_view == View.SIDE:
				head.position += Vector2(-1.0, 0.0)  # Head pulls back on impact
```

- [ ] **Step 6: Commit**

```bash
git add scripts/player/toon_animator.gd
git commit -m "feat: add side-view animation branches for limb swing, foot drag, eyes, and body"
```

---

### Task 4: Restructure Player.tscn — Add FrontDeco/SideDeco Containers

**Files:**
- Modify: `scenes/Player.tscn`

- [ ] **Step 1: Add FrontDeco container and reparent front-view decorative nodes**

In Player.tscn, after the VisualRoot node definition (line 43), add the FrontDeco container node. Then change `parent="VisualRoot"` to `parent="VisualRoot/FrontDeco"` for these nodes: LeftArmCoil, RightArmCoil, LeftLegCoil, RightLegCoil, OverallsBib, LeftStrap, RightStrap, LeftButton, RightButton, LeftGlove, RightGlove.

Add this line after the VisualRoot node entry:

```
[node name="FrontDeco" type="Node2D" parent="VisualRoot"]
```

Then for each of the 11 decorative nodes listed above, change their parent from `"VisualRoot"` to `"VisualRoot/FrontDeco"`.

- [ ] **Step 2: Add SideDeco container with side-view decorative nodes**

After all the FrontDeco children, add:

```
[node name="SideDeco" type="Node2D" parent="VisualRoot"]
visible = false

[node name="SideArmCoil" type="Line2D" parent="VisualRoot/SideDeco"]
position = Vector2(4, -16)
points = PackedVector2Array(0, 0, 3, 7, -1, 14, 5, 21, 1, 28, 4, 36, 2, 45)
width = 5.0
default_color = Color(0.76, 0.76, 0.72, 1)
begin_cap_mode = 2
end_cap_mode = 2

[node name="SideLegCoil" type="Line2D" parent="VisualRoot/SideDeco"]
position = Vector2(3, 20)
points = PackedVector2Array(0, 0, 2, 7, -1, 14, 3, 22, 0, 30, 2, 39)
width = 5.0
default_color = Color(0.72, 0.72, 0.68, 1)
begin_cap_mode = 2
end_cap_mode = 2

[node name="SideGlove" type="Polygon2D" parent="VisualRoot/SideDeco"]
position = Vector2(36, 31)
color = Color(0.86, 0.86, 0.8, 1)
polygon = PackedVector2Array(-8, -8, 10, -9, 14, 2, 8, 12, -10, 10, -14, 0)

[node name="SideBib" type="Polygon2D" parent="VisualRoot/SideDeco"]
position = Vector2(2, -7)
color = Color(0.34, 0.34, 0.34, 1)
polygon = PackedVector2Array(-6, -14, 8, -14, 10, 14, -8, 14)

[node name="SideStrap" type="Line2D" parent="VisualRoot/SideDeco"]
points = PackedVector2Array(5, -24, -3, 9)
width = 4.0
default_color = Color(0.66, 0.66, 0.62, 1)

[node name="SideButton" type="Polygon2D" parent="VisualRoot/SideDeco"]
position = Vector2(3, 7)
color = Color(0.9, 0.9, 0.82, 1)
polygon = PackedVector2Array(-3, -3, 3, -3, 4, 3, -4, 3)
```

- [ ] **Step 3: Commit**

```bash
git add scenes/Player.tscn
git commit -m "feat: add FrontDeco/SideDeco containers with side-view decorative nodes"
```

---

### Task 5: Update Tests for New Structure

**Files:**
- Modify: `tests/task6_miner_visual_checks.gd`

- [ ] **Step 1: Update decorative node paths and add new assertions**

Replace the content of `tests/task6_miner_visual_checks.gd` with:

```gdscript
extends SceneTree

var failures: Array[String] = []


func _initialize() -> void:
	var player_scene := load("res://scenes/Player.tscn")
	_assert(player_scene is PackedScene, "Player.tscn should load")
	if player_scene is PackedScene:
		var player: Node = player_scene.instantiate()

		# Core animation nodes — must stay at VisualRoot level
		_assert(player.get_node_or_null("VisualRoot/Body") is Polygon2D, "Body should remain Polygon2D")
		_assert(player.get_node_or_null("VisualRoot/Head") is Polygon2D, "Head should remain Polygon2D")
		_assert(player.get_node_or_null("VisualRoot/LeftArm") is Line2D, "LeftArm core animation node should stay Line2D")
		_assert(player.get_node_or_null("VisualRoot/RightArm") is Line2D, "RightArm core animation node should stay Line2D")
		_assert(player.get_node_or_null("VisualRoot/LeftLeg") is Line2D, "LeftLeg core animation node should stay Line2D")
		_assert(player.get_node_or_null("VisualRoot/RightLeg") is Line2D, "RightLeg core animation node should stay Line2D")
		_assert(player.get_node_or_null("VisualRoot/LeftFoot") is Polygon2D, "LeftFoot boot anchor should stay Polygon2D")
		_assert(player.get_node_or_null("VisualRoot/RightFoot") is Polygon2D, "RightFoot boot anchor should stay Polygon2D")
		_assert(player.get_node_or_null("VisualRoot/Head/Eyes/LeftEye") is Polygon2D, "Left eye should remain under Head/Eyes")
		_assert(player.get_node_or_null("VisualRoot/Head/Mouth") is Polygon2D, "Mouth should exist")

		# Head decorations
		_assert(player.get_node_or_null("VisualRoot/Head/Helmet") is Polygon2D, "Helmet should exist")
		_assert(player.get_node_or_null("VisualRoot/Head/HelmetBrim") is Polygon2D, "Helmet brim should exist")
		_assert(player.get_node_or_null("VisualRoot/Head/HeadLamp") is Polygon2D, "Head lamp should exist")
		_assert(player.get_node_or_null("VisualRoot/Head/LampGlow") is Polygon2D, "Lamp glow should exist")

		# View containers
		_assert(player.get_node_or_null("VisualRoot/FrontDeco") is Node2D, "FrontDeco container should exist")
		_assert(player.get_node_or_null("VisualRoot/SideDeco") is Node2D, "SideDeco container should exist")

		# Front-view decorative nodes (now under FrontDeco)
		_assert(player.get_node_or_null("VisualRoot/FrontDeco/LeftArmCoil") is Line2D, "Left arm coil should exist in FrontDeco")
		_assert(player.get_node_or_null("VisualRoot/FrontDeco/RightArmCoil") is Line2D, "Right arm coil should exist in FrontDeco")
		_assert(player.get_node_or_null("VisualRoot/FrontDeco/LeftLegCoil") is Line2D, "Left leg coil should exist in FrontDeco")
		_assert(player.get_node_or_null("VisualRoot/FrontDeco/RightLegCoil") is Line2D, "Right leg coil should exist in FrontDeco")
		_assert(player.get_node_or_null("VisualRoot/FrontDeco/LeftGlove") is Polygon2D, "Left glove should exist in FrontDeco")
		_assert(player.get_node_or_null("VisualRoot/FrontDeco/RightGlove") is Polygon2D, "Right glove should exist in FrontDeco")
		_assert(player.get_node_or_null("VisualRoot/FrontDeco/OverallsBib") is Polygon2D, "Overalls bib should exist in FrontDeco")
		_assert(player.get_node_or_null("VisualRoot/FrontDeco/LeftStrap") is Line2D, "Left overalls strap should exist in FrontDeco")
		_assert(player.get_node_or_null("VisualRoot/FrontDeco/RightStrap") is Line2D, "Right overalls strap should exist in FrontDeco")
		_assert(player.get_node_or_null("VisualRoot/FrontDeco/LeftButton") is Polygon2D, "Left button should exist in FrontDeco")
		_assert(player.get_node_or_null("VisualRoot/FrontDeco/RightButton") is Polygon2D, "Right button should exist in FrontDeco")

		# Side-view decorative nodes
		_assert(player.get_node_or_null("VisualRoot/SideDeco/SideArmCoil") is Line2D, "Side arm coil should exist in SideDeco")
		_assert(player.get_node_or_null("VisualRoot/SideDeco/SideLegCoil") is Line2D, "Side leg coil should exist in SideDeco")
		_assert(player.get_node_or_null("VisualRoot/SideDeco/SideGlove") is Polygon2D, "Side glove should exist in SideDeco")
		_assert(player.get_node_or_null("VisualRoot/SideDeco/SideBib") is Polygon2D, "Side bib should exist in SideDeco")
		_assert(player.get_node_or_null("VisualRoot/SideDeco/SideStrap") is Line2D, "Side strap should exist in SideDeco")
		_assert(player.get_node_or_null("VisualRoot/SideDeco/SideButton") is Polygon2D, "Side button should exist in SideDeco")

		player.free()

	_finish()


func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	if failures.is_empty():
		print("Vintage miner visual checks passed")
		quit(0)
		return
	for failure in failures:
		printerr(failure)
	quit(1)
```

- [ ] **Step 2: Commit**

```bash
git add tests/task6_miner_visual_checks.gd
git commit -m "test: update miner visual checks for FrontDeco/SideDeco structure"
```

---

### Task 6: Run All Tests and Fix Issues

**Files:**
- Possibly modify: `scripts/player/toon_animator.gd`, `scenes/Player.tscn`, `tests/*.gd`

- [ ] **Step 1: Run all existing tests**

```bash
cd /Users/q/panel/test/test_ai/rubber-hose-animation
/Applications/Godot.app/Contents/MacOS/Godot --headless --script tests/task3_player_checks.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --script tests/task4_toon_animator_checks.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --script tests/task5_readability_checks.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --script tests/task6_miner_visual_checks.gd
```

- [ ] **Step 2: Fix any failing tests**

If tests fail, check:
- Node path changes (core nodes must stay at `VisualRoot/*`)
- Type mismatches (all node types must be preserved)
- task3 also checks `VisualRoot/LeftArm is Line2D` and `VisualRoot/Head/Eyes/LeftEye` — these paths must not change

- [ ] **Step 3: Verify in-editor visual output**

Open the project in Godot editor, run the Main scene, and verify:
- Character shows front-view in idle
- Character switches to side-view when running
- Character switches to side-view when jumping/falling
- Side-view flips correctly when moving left vs right
- Character returns to front-view on landing (brief) and idle
- Decorative nodes (coils, gloves, overalls) toggle correctly

- [ ] **Step 4: Commit any fixes**

```bash
git add -A
git commit -m "fix: resolve test failures after side-view implementation"
```

---

### Task 7: Visual Polish — Iterate on Side-View Geometry

**Files:**
- Modify: `scripts/player/toon_animator.gd` (side-view polygon data)
- Modify: `scenes/Player.tscn` (side-view decoration shapes)

The hardcoded polygon coordinates are approximations — they need visual tuning.

- [ ] **Step 1: Run the project and assess side-view appearance**

Look at the side-view character while running/jumping. Note which parts look off:
- Body shape too wide/narrow?
- Head profile looks wrong?
- Arms positioned incorrectly relative to body?
- Feet too small/large or wrong shape?
- Eye position off?
- Helmet/lamp positioning wrong?

- [ ] **Step 2: Adjust side-view polygon coordinates in `_store_base_visuals()`**

Key coordinates to tune:
- `_side_base_body_polygon` — body profile shape
- `_side_base_head_polygon` — head profile shape
- `_side_base_left_arm_points` / `_side_base_right_arm_points` — arm positions/angles
- `_side_base_left_leg_points` / `_side_base_right_leg_points` — leg positions/angles
- `_side_base_left_foot_polygon` / `_side_base_right_foot_polygon` — foot profile shapes
- `_side_base_left_eye_polygon` / `_side_base_right_eye_polygon` — eye size for side-view
- All `_side_base_*_position` values — spatial layout

- [ ] **Step 3: Adjust side-view decoration nodes in Player.tscn**

Edit the `SideDeco/*` node positions/polygons to align with tuned core geometry.

- [ ] **Step 4: Repeat Steps 1-3 until satisfied**

- [ ] **Step 5: Final commit**

```bash
git add -A
git commit -m "polish: tune side-view geometry and decoration alignment"
```

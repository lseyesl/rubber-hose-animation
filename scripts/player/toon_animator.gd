extends Node2D

enum View { FRONT, SIDE }

@export var player_path: NodePath = NodePath("..")
@export var squash_recovery_speed: float = 11.0
@export var lean_strength: float = 0.14
@export var run_cycle_speed: float = 11.5
@export var limb_swing_amount: float = 9.0

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
var _side_base_body_polygon := [Vector2(-8, -22), Vector2(12, -22), Vector2(14, 24), Vector2(-10, 24)]
var _side_base_head_polygon := [Vector2(-15, -17), Vector2(10, -19), Vector2(18, -5), Vector2(12, 20), Vector2(-5, 22), Vector2(-18, 5)]
var _side_base_left_foot_polygon := [Vector2(-10, -6), Vector2(8, -8), Vector2(14, 2), Vector2(6, 10), Vector2(-14, 8)]
var _side_base_right_foot_polygon := [Vector2(-8, -8), Vector2(14, -6), Vector2(18, 4), Vector2(4, 10), Vector2(-12, 2)]
var _side_base_left_eye_position := Vector2(-3, 0)
var _side_base_right_eye_position := Vector2(5, 0)
var _side_base_left_eye_polygon := [Vector2(-4, -9), Vector2(5, -9), Vector2(6, 8), Vector2(-5, 8)]
var _side_base_right_eye_polygon := [Vector2(-5, -9), Vector2(4, -9), Vector2(5, 8), Vector2(-6, 8)]

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


func _ready() -> void:
	var player_node := get_node_or_null(player_path)
	if player_node is CharacterBody2D:
		player = player_node
	else:
		push_warning("ToonAnimator expected a CharacterBody2D at player_path %s" % [player_path])

	body = get_node_or_null("Body") as Polygon2D
	head = get_node_or_null("Head") as Polygon2D
	left_arm = get_node_or_null("LeftArm") as Line2D
	right_arm = get_node_or_null("RightArm") as Line2D
	left_leg = get_node_or_null("LeftLeg") as Line2D
	right_leg = get_node_or_null("RightLeg") as Line2D
	left_foot = get_node_or_null("LeftFoot") as Polygon2D
	right_foot = get_node_or_null("RightFoot") as Polygon2D
	eyes = get_node_or_null("Head/Eyes") as Node2D
	left_eye = get_node_or_null("Head/Eyes/LeftEye") as Polygon2D
	right_eye = get_node_or_null("Head/Eyes/RightEye") as Polygon2D
	front_deco = get_node_or_null("FrontDeco") as Node2D
	side_deco = get_node_or_null("SideDeco") as Node2D

	_store_base_visuals()
	_connect_player_impact()


func _process(delta: float) -> void:
	if player == null or not _has_required_visuals():
		return

	var horizontal_speed := player.velocity.x
	var speed_ratio := clampf(absf(horizontal_speed) / 360.0, 0.0, 1.6)
	_run_cycle += delta * run_cycle_speed * maxf(speed_ratio, 0.18)
	_impact_squash = move_toward(_impact_squash, 0.0, delta * squash_recovery_speed)

	var state := _player_state()
	_update_view(state)
	var direction := _facing_direction(horizontal_speed)
	var surface_squash := _surface_float(&"visual_squash_multiplier", 1.0)
	var surface_stretch := _surface_float(&"visual_stretch_multiplier", 1.0)
	var surface_drag := _surface_float(&"visual_drag_multiplier", 1.0)
	var target_scale := _target_scale_for_state(state, speed_ratio, surface_squash, surface_stretch)
	target_scale.x += _impact_squash * 0.26 * surface_squash
	target_scale.y -= _impact_squash * 0.2 * surface_squash
	target_scale.x = maxf(target_scale.x, 0.65)
	target_scale.y = maxf(target_scale.y, 0.65)

	var blend := clampf(delta * squash_recovery_speed, 0.0, 1.0)
	scale = scale.lerp(target_scale, blend)
	rotation = lerpf(rotation, _target_lean_for_state(state, direction, speed_ratio), blend)

	_apply_body_offsets(state)
	_apply_limb_swing(state, direction, speed_ratio, surface_drag)
	_apply_foot_drag(state, direction, speed_ratio, surface_drag)
	_apply_eye_expression(state, direction, speed_ratio)

	# Update side-view direction mirror when direction changes
	if current_view == View.SIDE:
		if not is_equal_approx(direction, _last_mirror_direction):
			_last_mirror_direction = direction
			_mirror_side_view(direction)


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
	_side_base_left_arm_points = [
		Vector2(0, 0), Vector2(-2, 20), Vector2(-4, 42)
	]
	# Front arm (RightArm node) — reaches in front
	_side_base_right_arm_points = [
		Vector2(0, 0), Vector2(6, 20), Vector2(4, 42)
	]
	# Back leg (LeftLeg node) — trails behind
	_side_base_left_leg_points = [
		Vector2(0, 0), Vector2(-3, 22), Vector2(-5, 42)
	]
	# Front leg (RightLeg node) — steps forward
	_side_base_right_leg_points = [
		Vector2(0, 0), Vector2(3, 22), Vector2(5, 42)
	]

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


func _connect_player_impact() -> void:
	if player == null or not player.has_signal("impact"):
		return
	var impact_callback := Callable(self, "_on_player_impact")
	if not player.is_connected("impact", impact_callback):
		player.connect("impact", impact_callback)


func _has_required_visuals() -> bool:
	return body != null \
	and head != null \
	and left_arm != null \
	and right_arm != null \
	and left_leg != null \
	and right_leg != null \
	and left_foot != null \
	and right_foot != null \
	and eyes != null


func _target_scale_for_state(state: StringName, speed_ratio: float, surface_squash: float, surface_stretch: float) -> Vector2:
	match state:
		&"jump":
			return Vector2(0.86, 1.18 + 0.08 * surface_stretch)
		&"fall":
			return Vector2(0.94, 1.08 + 0.04 * surface_stretch)
		&"land":
			return Vector2(1.18 + 0.1 * surface_squash, 0.78)
		&"skid":
			return Vector2(1.28 + 0.08 * surface_squash, 0.74)
		&"bounce":
			return Vector2(0.78, 1.3 + 0.16 * surface_stretch)
		&"stuck":
			return Vector2(1.16 + 0.08 * surface_squash, 0.76)
		&"run":
			var cycle_squash := sin(_run_cycle * 2.0) * 0.025 * speed_ratio
			return Vector2(1.0 + cycle_squash, 1.0 - cycle_squash)
		_:
			return Vector2.ONE


func _target_lean_for_state(state: StringName, direction: float, speed_ratio: float) -> float:
	match state:
		&"skid":
			return -direction * lean_strength * 1.8
		&"stuck":
			return direction * lean_strength * 0.65
		&"jump", &"fall", &"bounce":
			return direction * lean_strength * 0.5 * speed_ratio
		&"run":
			return direction * lean_strength * speed_ratio
		_:
			return 0.0


func _apply_body_offsets(state: StringName) -> void:
	body.position = _base_body_position
	head.position = _base_head_position
	match state:
		&"jump", &"bounce":
			head.position = _base_head_position + Vector2(0.0, -3.0)
			if current_view == View.SIDE:
				head.position += Vector2(2.0, 0.0)
		&"fall":
			head.position = _base_head_position + Vector2(0.0, -1.5)
		&"land", &"skid", &"stuck":
			head.position = _base_head_position + Vector2(0.0, 2.5)
			if current_view == View.SIDE:
				head.position += Vector2(-1.0, 0.0)


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


func _set_limb_points(limb: Line2D, base_points: PackedVector2Array, x_offset: float, bend_weight: float) -> void:
	if limb == null or base_points.size() == 0:
		return
	var updated := PackedVector2Array()
	for index in base_points.size():
		var point := base_points[index]
		if index == 1:
			point.x += x_offset * bend_weight
		elif index > 1:
			point.x += x_offset
		updated.append(point)
	limb.points = updated


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
		# Front-view: feet drag laterally
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


func _update_view(state: StringName) -> void:
	var target_view: View = View.FRONT
	match state:
		&"run", &"jump", &"fall", &"skid", &"stuck":
			target_view = View.SIDE
		&"land", &"bounce":
			# Land/bounce are brief transitional states — keep side-view if
			# the character has horizontal velocity or directional input,
			# otherwise fall back to front-view.
			if player != null and absf(player.velocity.x) > 5.0:
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
		left_eye.visible = not is_side
	if right_eye != null:
		right_eye.position = _side_base_right_eye_position if is_side else _front_base_right_eye_position
		right_eye.polygon = _side_base_right_eye_polygon if is_side else _front_base_right_eye_polygon

	# Swap limb positions
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
			cheek.visible = not is_side
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


func _player_state() -> StringName:
	if player == null:
		return &"idle"
	var value = player.get("movement_state")
	if value is StringName:
		return value
	if value is String:
		return StringName(value)
	return &"idle"


func _surface_float(property_name: StringName, fallback: float) -> float:
	if player == null:
		return fallback
	var surface = player.get("active_surface")
	if not surface is Resource:
		return fallback
	var value = surface.get(property_name)
	if value is float or value is int:
		return float(value)
	return fallback


func _facing_direction(horizontal_speed: float) -> float:
	if absf(horizontal_speed) > 1.0:
		return signf(horizontal_speed)
	return 1.0


func _on_player_impact(strength: float) -> void:
	_impact_squash = clampf(strength / 700.0, 0.0, 1.0)

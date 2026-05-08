extends Node2D

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


func _store_base_visuals() -> void:
	if body != null:
		_base_body_position = body.position
	if head != null:
		_base_head_position = head.position
	if left_arm != null:
		_base_left_arm_points = left_arm.points
	if right_arm != null:
		_base_right_arm_points = right_arm.points
	if left_leg != null:
		_base_left_leg_points = left_leg.points
	if right_leg != null:
		_base_right_leg_points = right_leg.points
	if left_foot != null:
		_base_left_foot_position = left_foot.position
	if right_foot != null:
		_base_right_foot_position = right_foot.position
	if eyes != null:
		_base_eyes_position = eyes.position


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
		&"fall":
			head.position = _base_head_position + Vector2(0.0, -1.5)
		&"land", &"skid", &"stuck":
			head.position = _base_head_position + Vector2(0.0, 2.5)


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


func _apply_foot_drag(state: StringName, direction: float, speed_ratio: float, surface_drag: float) -> void:
	var swing := sin(_run_cycle) * limb_swing_amount * 0.55 * speed_ratio
	var drag := -direction * limb_swing_amount * 0.8 * surface_drag
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

extends Node2D

enum View { FRONT, SIDE }

@export var player_path: NodePath = NodePath("..")
@export var squash_recovery_speed: float = 11.0
@export var lean_strength: float = 0.14
@export var run_cycle_speed: float = 11.5
@export var limb_swing_amount: float = 9.0

var player: CharacterBody2D = null
var body: Node2D = null
var head: Node2D = null
var left_arm: Node2D = null
var right_arm: Node2D = null
var left_hand: Node2D = null
var right_hand: Node2D = null
var left_leg: Node2D = null
var right_leg: Node2D = null
var left_foot: Node2D = null
var right_foot: Node2D = null
var eyes: Node2D = null
var left_eye: Node2D = null
var right_eye: Node2D = null
var eyebrows: Node2D = null
var mouth: Node2D = null
var front_deco: Node2D = null
var side_deco: Node2D = null

var current_view: View = View.FRONT
var _last_mirror_direction: float = 1.0
var _run_cycle := 0.0
var _impact_squash := 0.0

var _front_base_body_position := Vector2.ZERO
var _front_base_head_position := Vector2.ZERO
var _front_base_left_arm_position := Vector2.ZERO
var _front_base_right_arm_position := Vector2.ZERO
var _front_base_left_hand_position := Vector2.ZERO
var _front_base_right_hand_position := Vector2.ZERO
var _front_base_left_leg_position := Vector2.ZERO
var _front_base_right_leg_position := Vector2.ZERO
var _front_base_left_foot_position := Vector2.ZERO
var _front_base_right_foot_position := Vector2.ZERO
var _front_base_eyes_position := Vector2.ZERO
var _front_base_eyebrows_position := Vector2.ZERO
var _front_base_mouth_position := Vector2.ZERO

var _side_base_body_position := Vector2(2, 0)
var _side_base_head_position := Vector2(4, -39)
var _side_base_left_arm_position := Vector2(2, -16)
var _side_base_right_arm_position := Vector2(4, -16)
var _side_base_left_hand_position := Vector2(6, 18)
var _side_base_right_hand_position := Vector2(14, 18)
var _side_base_left_leg_position := Vector2(-1, 20)
var _side_base_right_leg_position := Vector2(3, 20)
var _side_base_left_foot_position := Vector2(-2, 64)
var _side_base_right_foot_position := Vector2(4, 64)
var _side_base_eyes_position := Vector2(3, -1)
var _side_base_eyebrows_position := Vector2(3, -11)
var _side_base_mouth_position := Vector2(5, 13)

var _base_body_position := Vector2.ZERO
var _base_head_position := Vector2.ZERO
var _base_left_arm_position := Vector2.ZERO
var _base_right_arm_position := Vector2.ZERO
var _base_left_hand_position := Vector2.ZERO
var _base_right_hand_position := Vector2.ZERO
var _base_left_leg_position := Vector2.ZERO
var _base_right_leg_position := Vector2.ZERO
var _base_left_foot_position := Vector2.ZERO
var _base_right_foot_position := Vector2.ZERO
var _base_eyes_position := Vector2.ZERO
var _base_eyebrows_position := Vector2.ZERO
var _base_mouth_position := Vector2.ZERO


func _ready() -> void:
	var player_node := get_node_or_null(player_path)
	if player_node is CharacterBody2D:
		player = player_node
	else:
		push_warning("ToonAnimator expected a CharacterBody2D at player_path %s" % [player_path])

	body = get_node_or_null("Body") as Node2D
	head = get_node_or_null("Head") as Node2D
	left_arm = get_node_or_null("LeftArm") as Node2D
	right_arm = get_node_or_null("RightArm") as Node2D
	left_hand = get_node_or_null("LeftHand") as Node2D
	right_hand = get_node_or_null("RightHand") as Node2D
	left_leg = get_node_or_null("LeftLeg") as Node2D
	right_leg = get_node_or_null("RightLeg") as Node2D
	left_foot = get_node_or_null("LeftFoot") as Node2D
	right_foot = get_node_or_null("RightFoot") as Node2D
	eyes = get_node_or_null("Head/Eyes") as Node2D
	left_eye = get_node_or_null("Head/Eyes/LeftEye") as Node2D
	right_eye = get_node_or_null("Head/Eyes/RightEye") as Node2D
	eyebrows = get_node_or_null("Head/Eyebrows") as Node2D
	mouth = get_node_or_null("Head/Mouth") as Node2D
	front_deco = get_node_or_null("FrontDeco") as Node2D
	side_deco = get_node_or_null("SideDeco") as Node2D

	_store_base_visuals()
	_apply_view()
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

	if current_view == View.SIDE and not is_equal_approx(direction, _last_mirror_direction):
		_last_mirror_direction = direction
		_mirror_side_view(direction)


func _store_base_visuals() -> void:
	_front_base_body_position = body.position if body != null else Vector2.ZERO
	_front_base_head_position = head.position if head != null else Vector2.ZERO
	_front_base_left_arm_position = left_arm.position if left_arm != null else Vector2.ZERO
	_front_base_right_arm_position = right_arm.position if right_arm != null else Vector2.ZERO
	_front_base_left_hand_position = left_hand.position if left_hand != null else Vector2.ZERO
	_front_base_right_hand_position = right_hand.position if right_hand != null else Vector2.ZERO
	_front_base_left_leg_position = left_leg.position if left_leg != null else Vector2.ZERO
	_front_base_right_leg_position = right_leg.position if right_leg != null else Vector2.ZERO
	_front_base_left_foot_position = left_foot.position if left_foot != null else Vector2.ZERO
	_front_base_right_foot_position = right_foot.position if right_foot != null else Vector2.ZERO
	_front_base_eyes_position = eyes.position if eyes != null else Vector2.ZERO
	_front_base_eyebrows_position = eyebrows.position if eyebrows != null else Vector2.ZERO
	_front_base_mouth_position = mouth.position if mouth != null else Vector2.ZERO


func _connect_player_impact() -> void:
	if player != null and player.has_signal("impact") and not player.impact.is_connected(_on_player_impact):
		player.impact.connect(_on_player_impact)


func _has_required_visuals() -> bool:
	return body != null and head != null and left_arm != null and right_arm != null and left_leg != null and right_leg != null and left_foot != null and right_foot != null and eyes != null


func _player_state() -> StringName:
	var raw_state = player.get("movement_state") if player != null else &"idle"
	if raw_state is StringName:
		return raw_state
	if raw_state is String:
		return StringName(raw_state)
	return &"idle"


func _surface_float(property: StringName, fallback: float) -> float:
	if player == null:
		return fallback
	var surface = player.get("active_surface")
	if surface == null:
		return fallback
	var value = surface.get(property)
	return float(value) if value != null else fallback


func _target_scale_for_state(state: StringName, speed_ratio: float, surface_squash: float, surface_stretch: float) -> Vector2:
	match state:
		&"run":
			return Vector2(1.0 + speed_ratio * 0.06, 1.0 - speed_ratio * 0.04)
		&"jump":
			return Vector2(0.9, 1.12 * surface_stretch)
		&"fall":
			return Vector2(1.04, 0.96)
		&"land":
			return Vector2(1.16 * surface_squash, 0.82)
		&"skid":
			return Vector2(1.14 * surface_squash, 0.88)
		&"bounce":
			return Vector2(0.86, 1.2 * surface_stretch)
		&"stuck":
			return Vector2(1.1 * surface_squash, 0.88)
	return Vector2.ONE


func _target_lean_for_state(state: StringName, direction: float, speed_ratio: float) -> float:
	match state:
		&"run":
			return direction * speed_ratio * lean_strength
		&"skid":
			return -direction * (0.24 + speed_ratio * 0.08)
		&"jump", &"fall", &"bounce":
			return direction * speed_ratio * 0.08
		&"stuck":
			return -direction * 0.18
	return 0.0


func _apply_body_offsets(state: StringName) -> void:
	body.position = _base_body_position
	head.position = _base_head_position
	mouth.position = _base_mouth_position if mouth != null else Vector2.ZERO
	match state:
		&"jump", &"bounce":
			head.position += Vector2(0, -3)
			body.position += Vector2(0, 2)
		&"land", &"stuck":
			head.position += Vector2(0, 2)
			body.position += Vector2(0, 3)


func _apply_limb_swing(state: StringName, direction: float, speed_ratio: float, surface_drag: float) -> void:
	var swing := sin(_run_cycle) * limb_swing_amount * speed_ratio
	var drag_bias := 0.0
	match state:
		&"skid":
			drag_bias = -direction * limb_swing_amount * 0.65 * surface_drag
		&"stuck":
			drag_bias = -direction * limb_swing_amount * surface_drag
		&"jump", &"fall", &"bounce":
			swing *= 0.35

	left_arm.position = _base_left_arm_position
	right_arm.position = _base_right_arm_position
	left_leg.position = _base_left_leg_position
	right_leg.position = _base_right_leg_position
	if left_hand != null:
		left_hand.position = _base_left_hand_position
	if right_hand != null:
		right_hand.position = _base_right_hand_position

	left_arm.rotation = deg_to_rad(-swing + drag_bias)
	right_arm.rotation = deg_to_rad(swing + drag_bias)
	left_leg.rotation = deg_to_rad(swing * 0.55)
	right_leg.rotation = deg_to_rad(-swing * 0.55)
	var mirror_x := _last_mirror_direction if current_view == View.SIDE else 1.0
	var arm_stretch := 1.0 + absf(swing) * 0.008
	var leg_stretch := 1.0 + absf(swing) * 0.006
	left_arm.scale = Vector2(mirror_x, arm_stretch)
	right_arm.scale = Vector2(mirror_x, arm_stretch)
	left_leg.scale = Vector2(mirror_x, leg_stretch)
	right_leg.scale = Vector2(mirror_x, leg_stretch)

	if current_view == View.SIDE:
		var arm_length := 34.0
		var left_arm_angle := left_arm.rotation
		var right_arm_angle := right_arm.rotation
		if left_hand != null:
			left_hand.position = _base_left_arm_position + Vector2(
				sin(left_arm_angle) * arm_length,
				cos(left_arm_angle) * arm_length
			)
			left_hand.scale.x = mirror_x
		if right_hand != null:
			right_hand.position = _base_right_arm_position + Vector2(
				sin(right_arm_angle) * arm_length,
				cos(right_arm_angle) * arm_length
			)
			right_hand.scale.x = mirror_x
		if side_deco != null:
			side_deco.position.y = swing * 0.18


func _apply_foot_drag(state: StringName, direction: float, speed_ratio: float, surface_drag: float) -> void:
	var swing := sin(_run_cycle) * 4.0 * speed_ratio
	var drag := -direction * limb_swing_amount * 0.9 * surface_drag
	var left_offset := Vector2(-swing, 0.0)
	var right_offset := Vector2(swing, 0.0)
	if current_view == View.SIDE:
		left_offset = Vector2(0.0, swing)
		right_offset = Vector2(0.0, -swing)
	match state:
		&"skid":
			left_offset += Vector2(drag, 4.0)
			right_offset += Vector2(drag, 4.0)
		&"stuck":
			left_offset = Vector2(drag * 1.2, 7.0)
			right_offset = Vector2(drag, 7.0)
		&"jump", &"bounce":
			left_offset = Vector2(-direction * 2.0, -4.0)
			right_offset = Vector2(-direction * 2.0, -4.0)
		&"fall":
			left_offset = Vector2(-direction * 1.5, -2.0)
			right_offset = Vector2(-direction * 1.5, -2.0)
	left_foot.position = _base_left_foot_position + left_offset
	right_foot.position = _base_right_foot_position + right_offset


func _apply_eye_expression(state: StringName, direction: float, speed_ratio: float) -> void:
	eyes.position = _base_eyes_position
	eyes.scale = Vector2.ONE
	eyes.rotation = 0.0
	if eyebrows != null:
		eyebrows.position = _base_eyebrows_position
	mouth.position = _base_mouth_position if mouth != null else Vector2.ZERO

	if current_view == View.SIDE:
		if left_eye != null:
			left_eye.visible = false
		if right_eye != null:
			right_eye.visible = true
		if eyebrows != null:
			eyebrows.scale.x = direction
	else:
		if left_eye != null:
			left_eye.visible = true
		if right_eye != null:
			right_eye.visible = true

	match state:
		&"skid":
			eyes.position += Vector2(direction * (3.0 if current_view == View.FRONT else -2.0), 1.5)
			eyes.scale = Vector2(1.2, 0.65)
			if mouth != null:
				mouth.rotation = -direction * 0.08
		&"stuck":
			eyes.position += Vector2(direction, 2.0)
			eyes.scale = Vector2(0.85, 0.75)
		&"jump", &"bounce":
			eyes.position += Vector2(direction, -1.0)
			eyes.scale = Vector2(0.9, 1.15)
		&"fall":
			eyes.position += Vector2(direction * speed_ratio * 1.5, 0.5)
		&"run":
			eyes.position += Vector2(direction * speed_ratio * 1.4, 0.0)


func _update_view(state: StringName) -> void:
	var target_view: View = View.FRONT
	match state:
		&"run":
			target_view = View.SIDE
		&"jump", &"fall":
			target_view = current_view
		&"skid", &"stuck":
			target_view = View.SIDE
		&"land", &"bounce":
			if player != null and absf(player.velocity.x) > 5.0:
				target_view = View.SIDE
	if current_view != target_view:
		current_view = target_view
		_apply_view()


func _apply_view() -> void:
	var is_side := current_view == View.SIDE
	_base_body_position = _side_base_body_position if is_side else _front_base_body_position
	_base_head_position = _side_base_head_position if is_side else _front_base_head_position
	_base_left_arm_position = _side_base_left_arm_position if is_side else _front_base_left_arm_position
	_base_right_arm_position = _side_base_right_arm_position if is_side else _front_base_right_arm_position
	_base_left_hand_position = _side_base_left_hand_position if is_side else _front_base_left_hand_position
	_base_right_hand_position = _side_base_right_hand_position if is_side else _front_base_right_hand_position
	_base_left_leg_position = _side_base_left_leg_position if is_side else _front_base_left_leg_position
	_base_right_leg_position = _side_base_right_leg_position if is_side else _front_base_right_leg_position
	_base_left_foot_position = _side_base_left_foot_position if is_side else _front_base_left_foot_position
	_base_right_foot_position = _side_base_right_foot_position if is_side else _front_base_right_foot_position
	_base_eyes_position = _side_base_eyes_position if is_side else _front_base_eyes_position
	_base_eyebrows_position = _side_base_eyebrows_position if is_side else _front_base_eyebrows_position
	_base_mouth_position = _side_base_mouth_position if is_side else _front_base_mouth_position

	_set_view_sprites(body, is_side)
	_set_view_sprites(head, is_side)
	_set_view_sprites(left_arm, is_side)
	_set_view_sprites(right_arm, is_side)
	_set_view_sprites(left_leg, is_side)
	_set_view_sprites(right_leg, is_side)
	_set_view_sprites(left_foot, is_side)
	_set_view_sprites(right_foot, is_side)
	if front_deco != null:
		front_deco.visible = not is_side
	if side_deco != null:
		side_deco.visible = is_side
	_mirror_side_view(_facing_direction(player.velocity.x) if player != null else 1.0)


func _set_view_sprites(part: Node2D, is_side: bool) -> void:
	if part == null:
		return
	var front_sprite := part.get_node_or_null("FrontSprite") as CanvasItem
	var side_sprite := part.get_node_or_null("SideSprite") as CanvasItem
	if front_sprite != null:
		front_sprite.visible = not is_side
	if side_sprite != null:
		side_sprite.visible = is_side


func _mirror_side_view(direction: float) -> void:
	var mirror := direction if direction != 0.0 else 1.0
	if current_view == View.SIDE:
		for part in [body, head, left_arm, right_arm, left_hand, right_hand, left_leg, right_leg, left_foot, right_foot]:
			if part != null:
				part.scale.x = mirror
		if side_deco != null:
			side_deco.scale.x = mirror
	else:
		for part in [body, head, left_arm, right_arm, left_hand, right_hand, left_leg, right_leg, left_foot, right_foot]:
			if part != null:
				part.scale.x = 1.0
		if side_deco != null:
			side_deco.scale.x = 1.0


func _facing_direction(horizontal_speed: float) -> float:
	if absf(horizontal_speed) > 5.0:
		return signf(horizontal_speed)
	return _last_mirror_direction


func _on_player_impact(strength: float) -> void:
	_impact_squash = clampf(strength / 420.0, 0.0, 1.0)

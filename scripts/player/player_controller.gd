class_name PlayerController
extends CharacterBody2D

signal state_changed(new_state: StringName)
signal surface_changed(new_surface: Resource)
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
@export var default_surface: Resource

@onready var surface_detector: Node = $SurfaceSensor

var movement_state: StringName = STATE_IDLE
var active_surface: Resource
var target_surface: Resource
var last_impact_strength: float = 0.0

var _state_lock_timer: float = 0.0
var _target_surface_id: StringName = &""
var _previous_floor_contact: bool = false


func _ready() -> void:
	active_surface = default_surface
	target_surface = default_surface
	_target_surface_id = _surface_id(target_surface)


func _physics_process(delta: float) -> void:
	_state_lock_timer = maxf(_state_lock_timer - delta, 0.0)
	_update_surface(delta)

	var input_axis := Input.get_axis("move_left", "move_right")
	_apply_horizontal_movement(input_axis, delta)
	_apply_vertical_movement(delta)

	var previous_y_velocity := velocity.y
	_previous_floor_contact = is_on_floor()
	move_and_slide()
	_handle_floor_contact(previous_y_velocity)
	_update_state(input_axis)


func _update_surface(delta: float) -> void:
	var detected_surface := _detect_surface()
	if detected_surface == null:
		detected_surface = default_surface
	if detected_surface == null:
		return

	var detected_id := _surface_id(detected_surface)
	if detected_id != _target_surface_id:
		_target_surface_id = detected_id
		target_surface = detected_surface
		surface_changed.emit(target_surface)
	else:
		target_surface = detected_surface

	if active_surface == null:
		active_surface = target_surface
		return

	var blend_weight := clampf(delta * surface_blend_speed, 0.0, 1.0)
	if active_surface.has_method("smoothed_to"):
		active_surface = active_surface.call("smoothed_to", target_surface, blend_weight)
	else:
		active_surface = target_surface


func _detect_surface() -> Resource:
	if surface_detector != null and surface_detector.has_method("get_surface_profile"):
		var detected = surface_detector.call("get_surface_profile")
		if detected is Resource:
			return detected
	return default_surface


func _apply_horizontal_movement(input_axis: float, delta: float) -> void:
	var acceleration := base_acceleration * _surface_float("acceleration_multiplier", 1.0)
	var friction := base_friction * _surface_float("friction_multiplier", 1.0)
	var maximum_speed := base_max_speed * _surface_float("max_speed_multiplier", 1.0)
	var stickiness := _surface_float("stickiness", 0.0)

	if not is_zero_approx(input_axis):
		var target_speed := input_axis * maximum_speed
		var acceleration_delta := acceleration * (1.0 - clampf(stickiness * 0.45, 0.0, 0.8)) * delta
		velocity.x = move_toward(velocity.x, target_speed, acceleration_delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)


func _apply_vertical_movement(delta: float) -> void:
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity * _surface_float("jump_multiplier", 1.0)
	elif not is_on_floor():
		velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
	elif velocity.y > 0.0:
		velocity.y = 0.0


func _handle_floor_contact(previous_y_velocity: float) -> void:
	var on_floor := is_on_floor()
	if on_floor and not _previous_floor_contact:
		last_impact_strength = maxf(previous_y_velocity, 0.0)
		if last_impact_strength > 0.0:
			impact.emit(last_impact_strength)

		var bounce_multiplier := _surface_float("bounce_multiplier", 0.0)
		if bounce_multiplier > 0.0 and last_impact_strength > absf(jump_velocity) * 0.35:
			velocity.y = -last_impact_strength * bounce_multiplier
			_lock_state(STATE_BOUNCE, bounce_state_time)
		else:
			_lock_state(STATE_LAND, landing_state_time)
	elif not on_floor and _previous_floor_contact:
		last_impact_strength = 0.0


func _update_state(input_axis: float) -> void:
	if _state_lock_timer > 0.0:
		return

	var next_state := movement_state
	if not is_on_floor():
		if velocity.y < 0.0:
			next_state = STATE_JUMP
		else:
			next_state = STATE_FALL
	else:
		var stickiness := _surface_float("stickiness", 0.0)
		var skid_threshold := skid_min_speed * _surface_float("skid_threshold_multiplier", 1.0)
		if stickiness >= 0.7 and not is_zero_approx(input_axis) and absf(velocity.x) < skid_min_speed * 0.25:
			next_state = STATE_STUCK
		elif not is_zero_approx(input_axis) and absf(velocity.x) >= skid_threshold and signf(input_axis) != signf(velocity.x):
			next_state = STATE_SKID
		elif absf(velocity.x) > 5.0:
			next_state = STATE_RUN
		else:
			next_state = STATE_IDLE

	_set_state(next_state)


func _lock_state(new_state: StringName, duration: float) -> void:
	_state_lock_timer = duration
	_set_state(new_state)


func _set_state(new_state: StringName) -> void:
	if movement_state == new_state:
		return
	movement_state = new_state
	state_changed.emit(movement_state)


func _surface_float(property_name: StringName, fallback: float) -> float:
	if active_surface == null:
		return fallback
	var value = active_surface.get(property_name)
	if value is float or value is int:
		return float(value)
	return fallback


func _surface_id(surface: Resource) -> StringName:
	if surface == null:
		return &""
	var value = surface.get("id")
	if value is StringName:
		return value
	if value is String:
		return StringName(value)
	return &""

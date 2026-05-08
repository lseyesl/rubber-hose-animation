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


func smoothed_to(target: Resource, weight: float) -> Resource:
	var result: Resource = get_script().new()
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

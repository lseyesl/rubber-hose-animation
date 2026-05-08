extends StaticBody2D

@export var profile: Resource
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
		color_rect.color = profile.get("color")

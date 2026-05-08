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

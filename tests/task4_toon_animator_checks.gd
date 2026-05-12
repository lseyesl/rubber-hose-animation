extends SceneTree

var failures: Array[String] = []


func _initialize() -> void:
	_run_checks()
	if not failures.is_empty():
		for failure in failures:
			printerr(failure)
		quit(1)
		return

	_process_instantiated_player()


func _run_checks() -> void:
	var player_scene := load("res://scenes/Player.tscn")
	_assert(player_scene is PackedScene, "Player.tscn should load")
	if not player_scene is PackedScene:
		return

	var player_instance: Node = player_scene.instantiate()
	var visual_root := player_instance.get_node_or_null("VisualRoot")
	_assert(visual_root is Node2D, "VisualRoot should be Node2D")
	if visual_root is Node2D:
		var visual_script: Script = visual_root.get_script()
		_assert(visual_script != null, "VisualRoot should have a script")
		if visual_script != null:
			_assert(visual_script.resource_path == "res://scripts/player/toon_animator.gd", "VisualRoot should use toon_animator.gd")

	_assert(player_instance.get_node_or_null("VisualRoot/Body") is Node2D, "Body should be an image rig handle")
	_assert(player_instance.get_node_or_null("VisualRoot/Head") is Node2D, "Head should be an image rig handle")
	_assert(player_instance.get_node_or_null("VisualRoot/LeftArm") is Node2D, "LeftArm should be an image rig handle")
	_assert(player_instance.get_node_or_null("VisualRoot/RightArm") is Node2D, "RightArm should be an image rig handle")
	_assert(player_instance.get_node_or_null("VisualRoot/LeftLeg") is Node2D, "LeftLeg should be an image rig handle")
	_assert(player_instance.get_node_or_null("VisualRoot/RightLeg") is Node2D, "RightLeg should be an image rig handle")
	_assert(player_instance.get_node_or_null("VisualRoot/LeftFoot") is Node2D, "LeftFoot should be an image rig handle")
	_assert(player_instance.get_node_or_null("VisualRoot/RightFoot") is Node2D, "RightFoot should be an image rig handle")
	_assert(player_instance.get_node_or_null("VisualRoot/Head/Eyes") is Node2D, "Head/Eyes should be Node2D")
	_assert(player_instance.get_node_or_null("VisualRoot/Body/TorsoSprite") is Sprite2D, "Body should render with TorsoSprite")
	_assert(player_instance.get_node_or_null("VisualRoot/Head/HeadSprite") is Sprite2D, "Head should render with HeadSprite")
	_assert(player_instance.get_node_or_null("VisualRoot/LeftArm/ArmSprite") is Sprite2D, "LeftArm should render with ArmSprite")
	_assert(player_instance.get_node_or_null("VisualRoot/RightArm/ArmSprite") is Sprite2D, "RightArm should render with ArmSprite")
	_assert(player_instance.get_node_or_null("VisualRoot/LeftLeg/LegSprite") is Sprite2D, "LeftLeg should render with LegSprite")
	_assert(player_instance.get_node_or_null("VisualRoot/RightLeg/LegSprite") is Sprite2D, "RightLeg should render with LegSprite")
	_assert(player_instance.get_node_or_null("VisualRoot/LeftFoot/BootSprite") is Sprite2D, "LeftFoot should render with BootSprite")
	_assert(player_instance.get_node_or_null("VisualRoot/RightFoot/BootSprite") is Sprite2D, "RightFoot should render with BootSprite")

	player_instance.free()


func _process_instantiated_player() -> void:
	var player_scene := load("res://scenes/Player.tscn")
	if not player_scene is PackedScene:
		quit(1)
		return

	var player_instance: Node = player_scene.instantiate()
	var visual_root := player_instance.get_node_or_null("VisualRoot")
	var left_foot := player_instance.get_node_or_null("VisualRoot/LeftFoot")
	var right_foot := player_instance.get_node_or_null("VisualRoot/RightFoot")
	var base_left_foot_position := Vector2.ZERO
	var base_right_foot_position := Vector2.ZERO
	if left_foot is Node2D:
		base_left_foot_position = left_foot.position
	if right_foot is Node2D:
		base_right_foot_position = right_foot.position

	root.add_child(player_instance)
	await process_frame
	await process_frame
	player_instance.set("movement_state", &"skid")
	player_instance.set("velocity", Vector2(280.0, 0.0))
	if visual_root is Node2D:
		visual_root.call("_process", 0.1)

	if visual_root is Node2D:
		_assert(not visual_root.scale.is_equal_approx(Vector2.ONE), "VisualRoot should squash/stretch during skid")
		_assert(not is_zero_approx(visual_root.rotation), "VisualRoot should lean during skid")
	if left_foot is Node2D:
		_assert(not left_foot.position.is_equal_approx(base_left_foot_position), "LeftFoot should drag from its stored base position")
	if right_foot is Node2D:
		_assert(not right_foot.position.is_equal_approx(base_right_foot_position), "RightFoot should drag from its stored base position")

	player_instance.queue_free()
	await process_frame

	if failures.is_empty():
		print("Task 4 toon animator checks passed")
		quit(0)
		return

	for failure in failures:
		printerr(failure)
	quit(1)


func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

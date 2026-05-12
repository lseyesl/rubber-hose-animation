extends SceneTree

var failures: Array[String] = []


func _initialize() -> void:
	var player_scene := load("res://scenes/Player.tscn")
	_assert(player_scene is PackedScene, "Player.tscn should load")
	if not player_scene is PackedScene:
		_finish()
		return

	var player: Node = player_scene.instantiate()

	# Core visual handles stay stable, but they now render via image sprites.
	_assert(player.get_node_or_null("VisualRoot/Body") is Node2D, "Body image-rig handle should exist")
	_assert(player.get_node_or_null("VisualRoot/Body/TorsoSprite") is Sprite2D, "TorsoSprite should render the body")
	_assert(player.get_node_or_null("VisualRoot/Head") is Node2D, "Head image-rig handle should exist")
	_assert(player.get_node_or_null("VisualRoot/Head/HeadSprite") is Sprite2D, "HeadSprite should render the head")
	_assert(player.get_node_or_null("VisualRoot/Head/Eyes/LeftEye/LeftEyeSprite") is Sprite2D, "Left eye should be image-based")
	_assert(player.get_node_or_null("VisualRoot/Head/Eyes/RightEye/RightEyeSprite") is Sprite2D, "Right eye should be image-based")
	_assert(player.get_node_or_null("VisualRoot/Head/Eyebrows/LeftBrowSprite") is Sprite2D, "Left brow should be image-based")
	_assert(player.get_node_or_null("VisualRoot/Head/Eyebrows/RightBrowSprite") is Sprite2D, "Right brow should be image-based")
	_assert(player.get_node_or_null("VisualRoot/Head/Mouth/MouthSprite") is Sprite2D, "Mouth should be image-based")
	_assert(player.get_node_or_null("VisualRoot/LeftArm/ArmSprite") is Sprite2D, "Left arm should be image-based")
	_assert(player.get_node_or_null("VisualRoot/RightArm/ArmSprite") is Sprite2D, "Right arm should be image-based")
	_assert(player.get_node_or_null("VisualRoot/LeftHand/HandSprite") is Sprite2D, "Left hand should be image-based")
	_assert(player.get_node_or_null("VisualRoot/RightHand/HandSprite") is Sprite2D, "Right hand should be image-based")
	_assert(player.get_node_or_null("VisualRoot/LeftLeg/LegSprite") is Sprite2D, "Left leg should be image-based")
	_assert(player.get_node_or_null("VisualRoot/RightLeg/LegSprite") is Sprite2D, "Right leg should be image-based")
	_assert(player.get_node_or_null("VisualRoot/LeftFoot/BootSprite") is Sprite2D, "Left boot should be image-based")
	_assert(player.get_node_or_null("VisualRoot/RightFoot/BootSprite") is Sprite2D, "Right boot should be image-based")

	# The local decal and UI history layers may remain, but not as body-part renderers.
	_assert(player.get_node_or_null("VisualRoot/Head/LocalDecals") is Node2D, "Head local decals should remain optional overlays")
	_assert(player.get_node_or_null("VisualRoot/FrontDeco") is Node2D, "FrontDeco container should remain")
	_assert(player.get_node_or_null("VisualRoot/SideDeco") is Node2D, "SideDeco container should remain")

	await _run_image_rig_behavior_checks(player)

	player.free()
	_finish()


func _run_image_rig_behavior_checks(player: Node) -> void:
	root.add_child(player)
	await process_frame
	await process_frame

	player.set("movement_state", &"run")
	player.set("velocity", Vector2(280.0, 0.0))
	var visual_root: Node2D = player.get_node_or_null("VisualRoot")
	if visual_root == null:
		return

	var right_arm: Node2D = player.get_node_or_null("VisualRoot/RightArm")
	var right_foot: Node2D = player.get_node_or_null("VisualRoot/RightFoot")
	var base_arm_rotation := right_arm.rotation if right_arm != null else 0.0
	var base_foot_position := right_foot.position if right_foot != null else Vector2.ZERO

	visual_root.call("_process", 0.1)
	_assert(player.get_node_or_null("VisualRoot/SideDeco").visible, "SideDeco should show in side view")
	_assert((player.get_node_or_null("VisualRoot/Body/SideSprite") as CanvasItem).visible, "Body side sprite should show in side view")
	_assert(not (player.get_node_or_null("VisualRoot/Body/FrontSprite") as CanvasItem).visible, "Body front sprite should hide in side view")
	_assert(right_arm != null and not is_equal_approx(right_arm.rotation, base_arm_rotation), "RightArm image handle should swing during run")
	_assert(right_foot != null and not right_foot.position.is_equal_approx(base_foot_position), "RightFoot image handle should drag during run")

	player.set("velocity", Vector2(-280.0, 0.0))
	visual_root.call("_process", 0.1)
	_assert((player.get_node_or_null("VisualRoot/Body") as Node2D).scale.x == -1.0, "Body image handle should mirror left in side view")
	_assert((player.get_node_or_null("VisualRoot/Head") as Node2D).scale.x == -1.0, "Head image handle should mirror left in side view")
	_assert((player.get_node_or_null("VisualRoot/SideDeco") as Node2D).scale.x == -1.0, "SideDeco should mirror left in side view")


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

extends SceneTree

var failures: Array[String] = []


func _initialize() -> void:
	_run_checks()
	if failures.is_empty():
		print("Task 3 player checks passed")
		quit(0)
		return

	for failure in failures:
		printerr(failure)
	quit(1)


func _run_checks() -> void:
	var normal_surface := load("res://resources/surfaces/normal.tres")
	_assert(normal_surface is Resource, "normal surface resource should load")

	var detector_script := load("res://scripts/player/surface_detector.gd")
	_assert(detector_script is Script, "surface detector script should load")
	if detector_script is Script:
		var detector := RayCast2D.new()
		detector.set_script(detector_script)
		detector.set("fallback_surface", normal_surface)
		root.add_child(detector)
		_assert(detector.get_surface_profile() == normal_surface, "surface detector should return fallback surface when not colliding")
		detector.queue_free()

	var controller_script := load("res://scripts/player/player_controller.gd")
	_assert(controller_script is Script, "player controller script should load")
	if controller_script is Script:
		var player := CharacterBody2D.new()
		player.set_script(controller_script)
		_assert(player.has_signal("state_changed"), "player should expose state_changed signal")
		_assert(player.has_signal("surface_changed"), "player should expose surface_changed signal")
		_assert(player.has_signal("impact"), "player should expose impact signal")
		_assert(player.get("movement_state") == &"idle", "player default movement_state should be idle")
		player.free()

	var player_scene := load("res://scenes/Player.tscn")
	_assert(player_scene is PackedScene, "Player.tscn should load")
	if player_scene is PackedScene:
		var player_instance: Node = player_scene.instantiate()
		_assert(player_instance is CharacterBody2D, "Player root should be CharacterBody2D")
		_assert(player_instance.has_node("SurfaceSensor"), "Player should include SurfaceSensor")
		_assert(player_instance.get_node_or_null("VisualRoot/LeftArm") is Node2D, "Player LeftArm should be an image rig handle")
		_assert(player_instance.get_node_or_null("VisualRoot/RightArm") is Node2D, "Player RightArm should be an image rig handle")
		_assert(player_instance.get_node_or_null("VisualRoot/LeftLeg") is Node2D, "Player LeftLeg should be an image rig handle")
		_assert(player_instance.get_node_or_null("VisualRoot/RightLeg") is Node2D, "Player RightLeg should be an image rig handle")
		_assert(player_instance.has_node("VisualRoot/Head/Eyes/LeftEye/LeftEyeSprite"), "Player should include image-based left eye visual under Head/Eyes")
		_assert(player_instance.has_node("VisualRoot/RightFoot"), "Player should include right foot visual")
		player_instance.free()

	var main_scene := load("res://scenes/Main.tscn")
	_assert(main_scene is PackedScene, "Main.tscn should load")
	if main_scene is PackedScene:
		var main_instance: Node = main_scene.instantiate()
		_assert(main_instance.has_node("World/Player"), "Main should instance Player under World")
		var overlay: Node = main_instance.get_node_or_null("DebugOverlay")
		_assert(overlay != null and overlay.get("player_path") == NodePath("../World/Player"), "DebugOverlay should target World/Player")
		main_instance.free()


func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

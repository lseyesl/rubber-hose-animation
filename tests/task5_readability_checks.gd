extends SceneTree

const CONTROLS_HINT := "Controls: A/D or arrows, Space"

var failures: Array[String] = []


func _initialize() -> void:
	_run_static_checks()
	if not failures.is_empty():
		_finish()
		return

	_run_frame_checks()


func _run_static_checks() -> void:
	var main_scene := load("res://scenes/Main.tscn")
	_assert(main_scene is PackedScene, "Main.tscn should load")
	if not main_scene is PackedScene:
		return

	var main_instance: Node = main_scene.instantiate()
	var world := main_instance.get_node_or_null("World")
	_assert(world is Node2D, "Main should include World Node2D")
	if world is Node2D:
		_assert(world.get_node_or_null("Camera2D") == null, "World should not include a direct Camera2D")
		_assert_label(world, "NormalLabel", "NORMAL", Vector2(80, 540))
		_assert_label(world, "IceLabel", "ICE: slide + skid", Vector2(580, 540))
		_assert_label(world, "ElasticLabel", "ELASTIC: bounce", Vector2(1040, 540))
		_assert_label(world, "SlimeLabel", "SLIME: drag + stuck", Vector2(1520, 540))

	var camera := main_instance.get_node_or_null("World/Player/Camera2D")
	_assert(camera is Camera2D, "World/Player/Camera2D should exist")
	if camera is Camera2D:
		_assert(camera.position.is_equal_approx(Vector2(180, -140)), "Player camera should use the Task 5 follow offset")
		_assert(camera.enabled, "Player camera should be enabled")
		_assert(camera.zoom.is_equal_approx(Vector2(0.9, 0.9)), "Player camera should use the Task 5 zoom")
		_assert(camera.position_smoothing_enabled, "Player camera smoothing should be enabled")
		_assert(is_equal_approx(camera.position_smoothing_speed, 6.0), "Player camera smoothing speed should be 6.0")

	main_instance.free()


func _run_frame_checks() -> void:
	var main_scene := load("res://scenes/Main.tscn")
	if not main_scene is PackedScene:
		_finish()
		return

	var main_instance: Node = main_scene.instantiate()
	root.add_child(main_instance)
	await process_frame

	var debug_overlay := main_instance.get_node_or_null("DebugOverlay")
	_assert(debug_overlay is CanvasLayer, "Debug overlay should be a CanvasLayer")
	if debug_overlay is CanvasLayer:
		debug_overlay.call("_process", 0.0)

	var debug_label := main_instance.get_node_or_null("DebugOverlay/PanelContainer/MarginContainer/Label")
	_assert(debug_label is Label, "Debug overlay should include a Label")
	if debug_label is Label:
		_assert(debug_label.text.contains(CONTROLS_HINT), "Debug overlay should include controls hint after processing")
		_assert(debug_label.text.begins_with(CONTROLS_HINT + "\nState: "), "Debug overlay player text should start with controls hint")

	var overlay_script := load("res://scripts/debug/debug_overlay.gd")
	_assert(overlay_script is Script, "Debug overlay script should load")
	if overlay_script is Script:
		var overlay := CanvasLayer.new()
		overlay.set_script(overlay_script)
		var panel := PanelContainer.new()
		panel.name = "PanelContainer"
		overlay.add_child(panel)
		var margin := MarginContainer.new()
		margin.name = "MarginContainer"
		panel.add_child(margin)
		var no_player_label := Label.new()
		no_player_label.name = "Label"
		margin.add_child(no_player_label)
		root.add_child(overlay)
		overlay.call("_process", 0.0)
		_assert(no_player_label.text == "Player: not assigned\n" + CONTROLS_HINT, "Debug overlay no-player text should include exact controls hint")
		overlay.queue_free()

	main_instance.queue_free()
	await process_frame
	_finish()


func _assert_label(parent: Node, label_name: String, expected_text: String, expected_position: Vector2) -> void:
	var label := parent.get_node_or_null(label_name)
	_assert(label is Label, "%s should be a Label" % label_name)
	if label is Label:
		_assert(label.text == expected_text, "%s should read '%s'" % [label_name, expected_text])
		_assert(label.position.is_equal_approx(expected_position), "%s should use Task 5 readability position" % label_name)


func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	if failures.is_empty():
		print("Task 5 readability checks passed")
		quit(0)
		return

	for failure in failures:
		printerr(failure)
	quit(1)

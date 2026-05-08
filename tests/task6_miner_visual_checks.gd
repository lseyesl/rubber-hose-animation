extends SceneTree

var failures: Array[String] = []


func _initialize() -> void:
	var player_scene := load("res://scenes/Player.tscn")
	_assert(player_scene is PackedScene, "Player.tscn should load")
	if player_scene is PackedScene:
		var player: Node = player_scene.instantiate()
		_assert(player.get_node_or_null("VisualRoot/Body") is Polygon2D, "Body should remain Polygon2D")
		_assert(player.get_node_or_null("VisualRoot/Head") is Polygon2D, "Head should remain Polygon2D")
		_assert(player.get_node_or_null("VisualRoot/Head/Helmet") is Polygon2D, "Helmet should exist")
		_assert(player.get_node_or_null("VisualRoot/Head/HelmetBrim") is Polygon2D, "Helmet brim should exist")
		_assert(player.get_node_or_null("VisualRoot/Head/HeadLamp") is Polygon2D, "Head lamp should exist")
		_assert(player.get_node_or_null("VisualRoot/Head/LampGlow") is Polygon2D, "Lamp glow should exist")
		_assert(player.get_node_or_null("VisualRoot/OverallsBib") is Polygon2D, "Overalls bib should exist")
		_assert(player.get_node_or_null("VisualRoot/LeftStrap") is Line2D, "Left overalls strap should exist")
		_assert(player.get_node_or_null("VisualRoot/RightStrap") is Line2D, "Right overalls strap should exist")
		_assert(player.get_node_or_null("VisualRoot/LeftButton") is Polygon2D, "Left button should exist")
		_assert(player.get_node_or_null("VisualRoot/RightButton") is Polygon2D, "Right button should exist")
		_assert(player.get_node_or_null("VisualRoot/LeftArm") is Line2D, "LeftArm core animation node should stay Line2D")
		_assert(player.get_node_or_null("VisualRoot/RightArm") is Line2D, "RightArm core animation node should stay Line2D")
		_assert(player.get_node_or_null("VisualRoot/LeftLeg") is Line2D, "LeftLeg core animation node should stay Line2D")
		_assert(player.get_node_or_null("VisualRoot/RightLeg") is Line2D, "RightLeg core animation node should stay Line2D")
		_assert(player.get_node_or_null("VisualRoot/LeftArmCoil") is Line2D, "Left arm coil should exist")
		_assert(player.get_node_or_null("VisualRoot/RightArmCoil") is Line2D, "Right arm coil should exist")
		_assert(player.get_node_or_null("VisualRoot/LeftLegCoil") is Line2D, "Left leg coil should exist")
		_assert(player.get_node_or_null("VisualRoot/RightLegCoil") is Line2D, "Right leg coil should exist")
		_assert(player.get_node_or_null("VisualRoot/LeftGlove") is Polygon2D, "Left glove should exist")
		_assert(player.get_node_or_null("VisualRoot/RightGlove") is Polygon2D, "Right glove should exist")
		_assert(player.get_node_or_null("VisualRoot/LeftFoot") is Polygon2D, "LeftFoot boot anchor should stay Polygon2D")
		_assert(player.get_node_or_null("VisualRoot/RightFoot") is Polygon2D, "RightFoot boot anchor should stay Polygon2D")
		_assert(player.get_node_or_null("VisualRoot/Head/Eyes/LeftEye") is Polygon2D, "Left eye should remain under Head/Eyes")
		_assert(player.get_node_or_null("VisualRoot/Head/Mouth") is Polygon2D, "Mouth should exist")
		player.free()

	_finish()


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

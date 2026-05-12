extends SceneTree

var failures: Array[String] = []


func _initialize() -> void:
	_check_player_local_decals()
	_check_item_sheet_scene()
	_finish()


func _check_player_local_decals() -> void:
	var player_scene := load("res://scenes/Player.tscn")
	_assert(player_scene is PackedScene, "Player.tscn should load")
	if not player_scene is PackedScene:
		return

	var player: Node = player_scene.instantiate()

	_assert(player.get_node_or_null("VisualRoot/Head/LocalDecals") is Node2D, "Head local decal container should exist")
	_assert(player.get_node_or_null("VisualRoot/Head/LocalDecals/HeadlampGlassDecal") is Polygon2D, "Headlamp glass decal should exist")
	_assert(player.get_node_or_null("VisualRoot/Head/LocalDecals/HelmetScratchDecal") is Line2D, "Helmet scratch decal should exist")
	_assert(player.get_node_or_null("VisualRoot/Head/LocalDecals/SmileExpressionDecal") is Line2D, "Smile expression decal should exist")

	_assert(player.get_node_or_null("VisualRoot/FrontDeco/LocalDecals") is Node2D, "FrontDeco local decal container should exist")
	_assert(player.get_node_or_null("VisualRoot/FrontDeco/LocalDecals/LeftGlovePalmDecal") is Line2D, "Left glove palm decal should exist")
	_assert(player.get_node_or_null("VisualRoot/FrontDeco/LocalDecals/RightGlovePalmDecal") is Line2D, "Right glove palm decal should exist")
	_assert(player.get_node_or_null("VisualRoot/FrontDeco/LocalDecals/OverallPatchDecal") is Polygon2D, "Overall patch decal should exist")

	_assert(player.get_node_or_null("VisualRoot/SideDeco/LocalDecals") is Node2D, "SideDeco local decal container should exist")
	_assert(player.get_node_or_null("VisualRoot/SideDeco/LocalDecals/SideGlovePalmDecal") is Line2D, "Side glove palm decal should exist")
	_assert(player.get_node_or_null("VisualRoot/SideDeco/LocalDecals/SideOverallPatchDecal") is Polygon2D, "Side overall patch decal should exist")

	_assert(player.get_node_or_null("VisualRoot/LeftFoot/LocalDecals/LeftBootTreadDecal") is Line2D, "Left boot tread decal should exist")
	_assert(player.get_node_or_null("VisualRoot/RightFoot/LocalDecals/RightBootTreadDecal") is Line2D, "Right boot tread decal should exist")

	# Core procedural anchors must remain anchors, not sprites.
	_assert(player.get_node_or_null("VisualRoot/Body") is Polygon2D, "Body should remain a procedural Polygon2D anchor")
	_assert(player.get_node_or_null("VisualRoot/Head") is Polygon2D, "Head should remain a procedural Polygon2D anchor")
	_assert(player.get_node_or_null("VisualRoot/LeftArm") is Line2D, "LeftArm should remain a procedural Line2D anchor")
	_assert(player.get_node_or_null("VisualRoot/RightArm") is Line2D, "RightArm should remain a procedural Line2D anchor")

	player.free()


func _check_item_sheet_scene() -> void:
	var sheet_scene := load("res://scenes/ui/PlayerItemSheet.tscn")
	_assert(sheet_scene is PackedScene, "PlayerItemSheet.tscn should load")
	if not sheet_scene is PackedScene:
		return

	var sheet: Node = sheet_scene.instantiate()
	_assert(sheet.get_node_or_null("Portrait") is Sprite2D, "Player portrait sprite should exist")
	_assert(sheet.get_node_or_null("HelmetIcon") is Sprite2D, "Helmet icon sprite should exist")
	_assert(sheet.get_node_or_null("GloveIcon") is Sprite2D, "Glove icon sprite should exist")
	_assert(sheet.get_node_or_null("BootIcon") is Sprite2D, "Boot icon sprite should exist")
	_assert(sheet.get_node_or_null("PickaxeIcon") is Sprite2D, "Pickaxe icon sprite should exist")
	_assert(sheet.get_node_or_null("LanternIcon") is Sprite2D, "Lantern icon sprite should exist")
	_assert(sheet.get_node_or_null("MineCartIcon") is Sprite2D, "Mine cart icon sprite should exist")

	for node_name in ["Portrait", "HelmetIcon", "GloveIcon", "BootIcon", "PickaxeIcon", "LanternIcon", "MineCartIcon"]:
		var icon := sheet.get_node_or_null(node_name) as Sprite2D
		if icon != null:
			_assert(icon.texture != null, "%s should use the player profile texture" % node_name)
			_assert(icon.region_enabled, "%s should use a sheet region" % node_name)

	sheet.free()


func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	if failures.is_empty():
		print("Player local decal and item sheet checks passed")
		quit(0)
		return
	for failure in failures:
		printerr(failure)
	quit(1)

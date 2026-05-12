extends SceneTree

var failures: Array[String] = []


func _initialize() -> void:
	_check_player_profile_real_transparency()
	_check_player_local_decals()
	_check_item_sheet_scene()
	_finish()


func _check_player_profile_real_transparency() -> void:
	var profile_image := _load_texture_image("res://docs/assets/player_profile.png")
	_assert(profile_image != null, "player_profile.png should load as an image")
	if profile_image == null:
		return

	var transparent_samples := [
		Vector2i(0, 0),
		Vector2i(profile_image.get_width() - 1, 0),
		Vector2i(0, profile_image.get_height() - 1),
		Vector2i(profile_image.get_width() - 1, profile_image.get_height() - 1),
		Vector2i(32, 32),
	]
	for sample: Vector2i in transparent_samples:
		var pixel := profile_image.get_pixelv(sample)
		_assert(pixel.a < 0.01, "player_profile.png background pixel %s should be truly transparent, got alpha %.3f" % [sample, pixel.a])


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

	# Core body parts should now be image rig handles, not procedural shapes.
	_assert(player.get_node_or_null("VisualRoot/Body") is Node2D, "Body should be an image rig handle")
	_assert(player.get_node_or_null("VisualRoot/Head") is Node2D, "Head should be an image rig handle")
	_assert(player.get_node_or_null("VisualRoot/LeftArm") is Node2D, "LeftArm should be an image rig handle")
	_assert(player.get_node_or_null("VisualRoot/RightArm") is Node2D, "RightArm should be an image rig handle")
	_assert(player.get_node_or_null("VisualRoot/LeftLeg") is Node2D, "LeftLeg should be an image rig handle")
	_assert(player.get_node_or_null("VisualRoot/RightLeg") is Node2D, "RightLeg should be an image rig handle")
	_assert(player.get_node_or_null("VisualRoot/LeftFoot") is Node2D, "LeftFoot should be an image rig handle")
	_assert(player.get_node_or_null("VisualRoot/RightFoot") is Node2D, "RightFoot should be an image rig handle")
	_assert(player.get_node_or_null("VisualRoot/Body/TorsoSprite") is Sprite2D, "Torso should be image-based")
	_assert(player.get_node_or_null("VisualRoot/Head/HeadSprite") is Sprite2D, "Head should be image-based")
	_assert(player.get_node_or_null("VisualRoot/Head/Eyes/LeftEye/LeftEyeSprite") is Sprite2D, "Left eye should be image-based")
	_assert(player.get_node_or_null("VisualRoot/Head/Eyes/RightEye/RightEyeSprite") is Sprite2D, "Right eye should be image-based")
	_assert(player.get_node_or_null("VisualRoot/Head/Eyebrows/LeftBrowSprite") is Sprite2D, "Left eyebrow should be image-based")
	_assert(player.get_node_or_null("VisualRoot/Head/Eyebrows/RightBrowSprite") is Sprite2D, "Right eyebrow should be image-based")
	_assert(player.get_node_or_null("VisualRoot/Head/Mouth/MouthSprite") is Sprite2D, "Mouth should be image-based")
	_assert(player.get_node_or_null("VisualRoot/Head/Eyes/LeftEyeSprite") == null, "Left eye should not have an uncontrolled duplicate sprite")
	_assert(player.get_node_or_null("VisualRoot/Head/Eyes/RightEyeSprite") == null, "Right eye should not have an uncontrolled duplicate sprite")
	_assert(player.get_node_or_null("VisualRoot/Head/MouthSprite") == null, "Mouth should not have an uncontrolled duplicate sprite")
	_assert(player.get_node_or_null("VisualRoot/LeftArm/ArmSprite") is Sprite2D, "Left arm should be image-based")
	_assert(player.get_node_or_null("VisualRoot/RightArm/ArmSprite") is Sprite2D, "Right arm should be image-based")
	_assert(player.get_node_or_null("VisualRoot/LeftHand/HandSprite") is Sprite2D, "Left hand should be image-based")
	_assert(player.get_node_or_null("VisualRoot/RightHand/HandSprite") is Sprite2D, "Right hand should be image-based")
	_assert(player.get_node_or_null("VisualRoot/LeftLeg/LegSprite") is Sprite2D, "Left leg should be image-based")
	_assert(player.get_node_or_null("VisualRoot/RightLeg/LegSprite") is Sprite2D, "Right leg should be image-based")
	_assert(player.get_node_or_null("VisualRoot/LeftFoot/BootSprite") is Sprite2D, "Left boot should be image-based")
	_assert(player.get_node_or_null("VisualRoot/RightFoot/BootSprite") is Sprite2D, "Right boot should be image-based")

	_assert_part_texture(player, "VisualRoot/Body/TorsoSprite", "res://resources/player/parts/torso_front.png")
	_assert_part_texture(player, "VisualRoot/Body/FrontSprite", "res://resources/player/parts/torso_front.png")
	_assert_part_texture(player, "VisualRoot/Body/SideSprite", "res://resources/player/parts/torso_side.png")
	_assert_part_texture(player, "VisualRoot/Head/HeadSprite", "res://resources/player/parts/head_front.png")
	_assert_part_texture(player, "VisualRoot/Head/FrontSprite", "res://resources/player/parts/head_front.png")
	_assert_part_texture(player, "VisualRoot/Head/SideSprite", "res://resources/player/parts/head_side.png")
	_assert_part_texture(player, "VisualRoot/Head/Eyes/LeftEye/LeftEyeSprite", "res://resources/player/parts/eye_left.png", false)
	_assert_part_texture(player, "VisualRoot/Head/Eyes/RightEye/RightEyeSprite", "res://resources/player/parts/eye_right.png", false)
	_assert_part_texture(player, "VisualRoot/Head/Eyebrows/LeftBrowSprite", "res://resources/player/parts/brow_left.png", false)
	_assert_part_texture(player, "VisualRoot/Head/Eyebrows/RightBrowSprite", "res://resources/player/parts/brow_right.png", false)
	_assert_part_texture(player, "VisualRoot/Head/Mouth/MouthSprite", "res://resources/player/parts/mouth.png", false)
	_assert_part_texture(player, "VisualRoot/LeftArm/ArmSprite", "res://resources/player/parts/arm_front.png")
	_assert_part_texture(player, "VisualRoot/RightArm/ArmSprite", "res://resources/player/parts/arm_front.png")
	_assert_part_texture(player, "VisualRoot/LeftHand/HandSprite", "res://resources/player/parts/hand_front.png")
	_assert_part_texture(player, "VisualRoot/RightHand/HandSprite", "res://resources/player/parts/hand_front.png")
	_assert_part_texture(player, "VisualRoot/LeftLeg/LegSprite", "res://resources/player/parts/leg_front.png")
	_assert_part_texture(player, "VisualRoot/RightLeg/LegSprite", "res://resources/player/parts/leg_front.png")
	_assert_part_texture(player, "VisualRoot/LeftFoot/BootSprite", "res://resources/player/parts/boot_front.png")
	_assert_part_texture(player, "VisualRoot/RightFoot/BootSprite", "res://resources/player/parts/boot_front.png")

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


func _assert_tight_region(root_node: Node, path: String, max_size: Vector2) -> void:
	var sprite := root_node.get_node_or_null(path) as Sprite2D
	if sprite == null:
		return
	_assert(sprite.region_enabled, "%s should use a cropped atlas region" % path)
	_assert(sprite.region_rect.size.x <= max_size.x and sprite.region_rect.size.y <= max_size.y, "%s region should be tightly cropped, got %s max %s" % [path, sprite.region_rect.size, max_size])


func _assert_part_texture(root_node: Node, path: String, expected_path: String, should_have_transparent_background := true) -> void:
	var sprite := root_node.get_node_or_null(path) as Sprite2D
	if sprite == null:
		return
	_assert(not sprite.region_enabled, "%s should use a standalone sliced texture, not Sprite2D.region_rect" % path)
	_assert(sprite.texture != null, "%s should have a standalone part texture" % path)
	if sprite.texture != null:
		_assert(sprite.texture.resource_path == expected_path, "%s should use %s, got %s" % [path, expected_path, sprite.texture.resource_path])
		if should_have_transparent_background:
			_assert_part_image_has_transparency(expected_path)


func _assert_part_image_has_transparency(part_path: String) -> void:
	var part_image := _load_texture_image(part_path)
	_assert(part_image != null, "%s should load as a sliced image" % part_path)
	if part_image == null:
		return

	var has_transparent_pixel := false
	for y in part_image.get_height():
		for x in part_image.get_width():
			if part_image.get_pixel(x, y).a < 0.01:
				has_transparent_pixel = true
				break
		if has_transparent_pixel:
			break
	_assert(has_transparent_pixel, "%s should preserve real transparent background pixels after slicing" % part_path)


func _load_texture_image(path: String) -> Image:
	var texture := load(path) as Texture2D
	if texture == null:
		return null
	return texture.get_image()


func _finish() -> void:
	if failures.is_empty():
		print("Player local decal and item sheet checks passed")
		quit(0)
		return
	for failure in failures:
		printerr(failure)
	quit(1)

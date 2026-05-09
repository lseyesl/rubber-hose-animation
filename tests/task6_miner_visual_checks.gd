extends SceneTree

var failures: Array[String] = []


func _initialize() -> void:
	var player_scene := load("res://scenes/Player.tscn")
	_assert(player_scene is PackedScene, "Player.tscn should load")
	if not player_scene is PackedScene:
		_finish()
		return

	var player: Node = player_scene.instantiate()

	# Core animation nodes — must stay at VisualRoot level
	_assert(player.get_node_or_null("VisualRoot/Body") is Polygon2D, "Body should remain Polygon2D")
	_assert(player.get_node_or_null("VisualRoot/Head") is Polygon2D, "Head should remain Polygon2D")
	_assert(player.get_node_or_null("VisualRoot/LeftArm") is Line2D, "LeftArm core animation node should stay Line2D")
	_assert(player.get_node_or_null("VisualRoot/RightArm") is Line2D, "RightArm core animation node should stay Line2D")
	_assert(player.get_node_or_null("VisualRoot/LeftLeg") is Line2D, "LeftLeg core animation node should stay Line2D")
	_assert(player.get_node_or_null("VisualRoot/RightLeg") is Line2D, "RightLeg core animation node should stay Line2D")
	_assert(player.get_node_or_null("VisualRoot/LeftFoot") is Polygon2D, "LeftFoot boot anchor should stay Polygon2D")
	_assert(player.get_node_or_null("VisualRoot/RightFoot") is Polygon2D, "RightFoot boot anchor should stay Polygon2D")
	_assert(player.get_node_or_null("VisualRoot/Head/Eyes/LeftEye") is Polygon2D, "Left eye should remain under Head/Eyes")
	_assert(player.get_node_or_null("VisualRoot/Head/Mouth") is Polygon2D, "Mouth should exist")

	# Head decorations
	_assert(player.get_node_or_null("VisualRoot/Head/Helmet") is Polygon2D, "Helmet should exist")
	_assert(player.get_node_or_null("VisualRoot/Head/HelmetBrim") is Polygon2D, "Helmet brim should exist")
	_assert(player.get_node_or_null("VisualRoot/Head/HeadLamp") is Polygon2D, "Head lamp should exist")
	_assert(player.get_node_or_null("VisualRoot/Head/LampGlow") is Polygon2D, "Lamp glow should exist")
	_assert(player.get_node_or_null("VisualRoot/Head/HelmetBand") is Line2D, "Helmet band should exist")
	_assert(player.get_node_or_null("VisualRoot/Head/LampRim") is Line2D, "Lamp rim should exist")
	_assert(player.get_node_or_null("VisualRoot/Head/LampBeam") is Line2D, "Lamp beam should exist")
	_assert(player.get_node_or_null("VisualRoot/Head/HelmetGrooveLeft") is Line2D, "Helmet left groove texture should exist")
	_assert(player.get_node_or_null("VisualRoot/Head/HelmetGrooveRight") is Line2D, "Helmet right groove texture should exist")
	_assert(player.get_node_or_null("VisualRoot/Head/LampShine") is Polygon2D, "Lamp shine decal should exist")
	_assert(player.get_node_or_null("VisualRoot/Head/Nose") is Polygon2D, "Round cartoon nose should exist")
	_assert(player.get_node_or_null("VisualRoot/Head/Tooth") is Polygon2D, "Smile tooth highlight should exist")
	_assert(player.get_node_or_null("VisualRoot/FilmGrain") is Node2D, "Player-local film grain container should exist")
	_assert(player.get_node_or_null("VisualRoot/FilmGrain/GrainA") is Polygon2D, "Film grain speckle A should exist")
	_assert(player.get_node_or_null("VisualRoot/FilmGrain/GrainB") is Polygon2D, "Film grain speckle B should exist")
	_assert(player.get_node_or_null("VisualRoot/FilmGrain/VerticalScratch") is Line2D, "Player-local film scratch should exist")

	# View containers
	_assert(player.get_node_or_null("VisualRoot/FrontDeco") is Node2D, "FrontDeco container should exist")
	_assert(player.get_node_or_null("VisualRoot/SideDeco") is Node2D, "SideDeco container should exist")

	# Front-view decorative nodes (now under FrontDeco)
	_assert(player.get_node_or_null("VisualRoot/FrontDeco/LeftArmCoil") is Line2D, "Left arm coil should exist in FrontDeco")
	_assert(player.get_node_or_null("VisualRoot/FrontDeco/RightArmCoil") is Line2D, "Right arm coil should exist in FrontDeco")
	_assert(player.get_node_or_null("VisualRoot/FrontDeco/LeftLegCoil") is Line2D, "Left leg coil should exist in FrontDeco")
	_assert(player.get_node_or_null("VisualRoot/FrontDeco/RightLegCoil") is Line2D, "Right leg coil should exist in FrontDeco")
	_assert(player.get_node_or_null("VisualRoot/FrontDeco/LeftGlove") is Polygon2D, "Left glove should exist in FrontDeco")
	_assert(player.get_node_or_null("VisualRoot/FrontDeco/RightGlove") is Polygon2D, "Right glove should exist in FrontDeco")
	_assert(player.get_node_or_null("VisualRoot/FrontDeco/LeftGloveThumb") is Polygon2D, "Left glove thumb should exist in FrontDeco")
	_assert(player.get_node_or_null("VisualRoot/FrontDeco/RightGloveThumb") is Polygon2D, "Right glove thumb should exist in FrontDeco")
	_assert(player.get_node_or_null("VisualRoot/FrontDeco/LeftGloveFingers") is Line2D, "Left glove finger marks should exist in FrontDeco")
	_assert(player.get_node_or_null("VisualRoot/FrontDeco/RightGloveFingers") is Line2D, "Right glove finger marks should exist in FrontDeco")
	_assert(player.get_node_or_null("VisualRoot/FrontDeco/LeftArmCoilShadow") is Line2D, "Left arm coil shadow should exist in FrontDeco")
	_assert(player.get_node_or_null("VisualRoot/FrontDeco/RightArmCoilShadow") is Line2D, "Right arm coil shadow should exist in FrontDeco")
	_assert(player.get_node_or_null("VisualRoot/FrontDeco/LeftArmCoilHighlight") is Line2D, "Left front coil highlight should exist")
	_assert(player.get_node_or_null("VisualRoot/FrontDeco/RightArmCoilHighlight") is Line2D, "Right front coil highlight should exist")
	_assert(player.get_node_or_null("VisualRoot/FrontDeco/LeftGloveCreases") is Line2D, "Left glove crease texture should exist")
	_assert(player.get_node_or_null("VisualRoot/FrontDeco/RightGloveCreases") is Line2D, "Right glove crease texture should exist")
	_assert(player.get_node_or_null("VisualRoot/FrontDeco/OverallsBib") is Polygon2D, "Overalls bib should exist in FrontDeco")
	_assert(player.get_node_or_null("VisualRoot/FrontDeco/OverallsWear") is Line2D, "Front overalls fabric wear should exist")
	_assert(player.get_node_or_null("VisualRoot/FrontDeco/LeftStrap") is Line2D, "Left overalls strap should exist in FrontDeco")
	_assert(player.get_node_or_null("VisualRoot/FrontDeco/RightStrap") is Line2D, "Right overalls strap should exist in FrontDeco")
	_assert(player.get_node_or_null("VisualRoot/FrontDeco/LeftButton") is Polygon2D, "Left button should exist in FrontDeco")
	_assert(player.get_node_or_null("VisualRoot/FrontDeco/RightButton") is Polygon2D, "Right button should exist in FrontDeco")

	# Side-view decorative nodes
	_assert(player.get_node_or_null("VisualRoot/SideDeco/SideArmCoil") is Line2D, "Side arm coil should exist in SideDeco")
	_assert(player.get_node_or_null("VisualRoot/SideDeco/SideCoilHighlight") is Line2D, "Side coil highlight should exist")
	_assert(player.get_node_or_null("VisualRoot/SideDeco/SideLegCoil") is Line2D, "Side leg coil should exist in SideDeco")
	_assert(player.get_node_or_null("VisualRoot/SideDeco/SideGlove") is Polygon2D, "Side glove should exist in SideDeco")
	_assert(player.get_node_or_null("VisualRoot/SideDeco/SideGloveThumb") is Polygon2D, "Side glove thumb should exist in SideDeco")
	_assert(player.get_node_or_null("VisualRoot/SideDeco/SideGloveFingers") is Line2D, "Side glove finger marks should exist in SideDeco")
	_assert(player.get_node_or_null("VisualRoot/SideDeco/SideBib") is Polygon2D, "Side bib should exist in SideDeco")
	_assert(player.get_node_or_null("VisualRoot/SideDeco/SideOverallsWear") is Line2D, "Side overalls fabric wear should exist")
	_assert(player.get_node_or_null("VisualRoot/SideDeco/SideStrap") is Line2D, "Side strap should exist in SideDeco")
	_assert(player.get_node_or_null("VisualRoot/SideDeco/SideButton") is Polygon2D, "Side button should exist in SideDeco")
	_assert(player.get_node_or_null("VisualRoot/LeftFoot/LeftBootSole") is Polygon2D, "Left boot sole should exist")
	_assert(player.get_node_or_null("VisualRoot/RightFoot/RightBootSole") is Polygon2D, "Right boot sole should exist")
	_assert(player.get_node_or_null("VisualRoot/LeftFoot/LeftBootCleats") is Line2D, "Left boot cleats should exist")
	_assert(player.get_node_or_null("VisualRoot/RightFoot/RightBootCleats") is Line2D, "Right boot cleats should exist")
	_assert(player.get_node_or_null("VisualRoot/LeftFoot/LeftBootHighlight") is Line2D, "Left boot highlight decal should exist")
	_assert(player.get_node_or_null("VisualRoot/RightFoot/RightBootHighlight") is Line2D, "Right boot highlight decal should exist")

	# --- Dynamic side-view behavior checks ---
	await _run_side_view_checks(player)

	player.free()
	_finish()


func _run_side_view_checks(player: Node) -> void:
	root.add_child(player)
	await process_frame
	await process_frame

	player.set("movement_state", &"run")
	player.set("velocity", Vector2(280.0, 0.0))
	var visual_root: Node2D = player.get_node_or_null("VisualRoot")
	if visual_root == null:
		return

	visual_root.call("_process", 0.1)

	_assert(player.get_node_or_null("VisualRoot/SideDeco").visible, "SideDeco should show in side view")
	_assert((player.get_node_or_null("VisualRoot/Head/HelmetBand") as Node2D).position == Vector2(4, -17), "Helmet band should move to side-view position")
	_assert((player.get_node_or_null("VisualRoot/Head/LampRim") as Node2D).position == Vector2(12, -27), "Lamp rim should move to side-view position")
	_assert((player.get_node_or_null("VisualRoot/Head/Nose") as Node2D).position == Vector2(15, 7), "Nose should move to side-view profile position")
	_assert((player.get_node_or_null("VisualRoot/Head/Tooth") as Node2D).position == Vector2(7, 14), "Tooth should move to side-view smile position")
	_assert((player.get_node_or_null("VisualRoot/Head/LampBeam") as Node2D).position == Vector2(25, -29), "Lamp beam should move forward in side view")
	_assert((player.get_node_or_null("VisualRoot/Head/LampShine") as Node2D).position == Vector2(13, -27), "Lamp shine should move to side-view lamp position")
	_assert((player.get_node_or_null("VisualRoot/Head/HelmetGrooveLeft") as Node2D).position == Vector2(3, -17), "Helmet left groove should move to side-view helmet position")
	_assert((player.get_node_or_null("VisualRoot/Head/HelmetGrooveRight") as Node2D).position == Vector2(3, -17), "Helmet right groove should move to side-view helmet position")
	_assert((player.get_node_or_null("VisualRoot/LeftFoot/LeftBootSole") as Node2D).position == Vector2(-2, 8), "Back boot sole should use side-view position")
	_assert((player.get_node_or_null("VisualRoot/LeftFoot/LeftBootCleats") as Node2D).position == Vector2(-3, 10), "Back boot cleats should use side-view position")
	_assert((player.get_node_or_null("VisualRoot/LeftFoot/LeftBootHighlight") as Node2D).position == Vector2(-3, -1), "Back boot highlight should use side-view position")
	_assert((player.get_node_or_null("VisualRoot/RightFoot/RightBootSole") as Node2D).position == Vector2(2, 8), "Front boot sole should use side-view position")
	_assert((player.get_node_or_null("VisualRoot/RightFoot/RightBootCleats") as Node2D).position == Vector2(3, 10), "Front boot cleats should use side-view position")
	_assert((player.get_node_or_null("VisualRoot/RightFoot/RightBootHighlight") as Node2D).position == Vector2(3, -1), "Front boot highlight should use side-view position")

	# Side-view arm decorations should swing with arms
	var side_arm_coil: Line2D = player.get_node_or_null("VisualRoot/SideDeco/SideArmCoil")
	var side_coil_highlight: Line2D = player.get_node_or_null("VisualRoot/SideDeco/SideCoilHighlight")
	var side_glove: Polygon2D = player.get_node_or_null("VisualRoot/SideDeco/SideGlove")
	var side_glove_thumb: Polygon2D = player.get_node_or_null("VisualRoot/SideDeco/SideGloveThumb")
	var side_glove_fingers: Line2D = player.get_node_or_null("VisualRoot/SideDeco/SideGloveFingers")
	var right_arm: Line2D = player.get_node_or_null("VisualRoot/RightArm")
	var base_arm_tip_y: float = right_arm.points[2].y if right_arm != null and right_arm.points.size() > 2 else 0.0
	var base_coil_y: float = side_arm_coil.position.y if side_arm_coil != null else 0.0
	var base_coil_highlight_y: float = side_coil_highlight.position.y if side_coil_highlight != null else 0.0
	var base_glove_y: float = side_glove.position.y if side_glove != null else 0.0
	var base_thumb_y: float = side_glove_thumb.position.y if side_glove_thumb != null else 0.0
	var base_fingers_y: float = side_glove_fingers.position.y if side_glove_fingers != null else 0.0

	# Run another frame to accumulate different swing phase
	visual_root.call("_process", 0.05)
	var next_arm_tip_y: float = right_arm.points[2].y if right_arm != null and right_arm.points.size() > 2 else 0.0
	var next_coil_y: float = side_arm_coil.position.y if side_arm_coil != null else 0.0
	var next_coil_highlight_y: float = side_coil_highlight.position.y if side_coil_highlight != null else 0.0
	var next_glove_y: float = side_glove.position.y if side_glove != null else 0.0
	var next_thumb_y: float = side_glove_thumb.position.y if side_glove_thumb != null else 0.0
	var next_fingers_y: float = side_glove_fingers.position.y if side_glove_fingers != null else 0.0
	# Arm itself must swing
	_assert(not is_equal_approx(next_arm_tip_y, base_arm_tip_y), "RightArm should swing during side-view run")
	# Decorations must follow arm swing — use same magnitude tolerance as arm swing itself
	var arm_swing_magnitude := absf(base_arm_tip_y - next_arm_tip_y)
	_assert(absf(base_coil_y - next_coil_y) > arm_swing_magnitude * 0.3, "SideArmCoil should swing with arm in side-view run")
	_assert(absf(base_coil_highlight_y - next_coil_highlight_y) > arm_swing_magnitude * 0.3, "SideCoilHighlight should swing with arm in side-view run")
	_assert(absf(base_glove_y - next_glove_y) > arm_swing_magnitude * 0.3, "SideGlove should swing with arm in side-view run")
	_assert(absf(base_thumb_y - next_thumb_y) > arm_swing_magnitude * 0.3, "SideGloveThumb should swing with arm in side-view run")
	_assert(absf(base_fingers_y - next_fingers_y) > arm_swing_magnitude * 0.3, "SideGloveFingers should swing with arm in side-view run")

	# Left-facing mirror checks
	player.set("velocity", Vector2(-280.0, 0.0))
	visual_root.call("_process", 0.1)
	_assert((player.get_node_or_null("VisualRoot/Head/HelmetBand") as Node2D).position == Vector2(-4, -17), "Helmet band should mirror for left-facing side view")
	_assert((player.get_node_or_null("VisualRoot/Head/HelmetBand") as Node2D).scale.x == -1.0, "Helmet band shape should mirror for left-facing side view")
	_assert((player.get_node_or_null("VisualRoot/Head/LampRim") as Node2D).position == Vector2(-12, -27), "Lamp rim should mirror for left-facing side view")
	_assert((player.get_node_or_null("VisualRoot/Head/LampRim") as Node2D).scale.x == -1.0, "Lamp rim shape should mirror for left-facing side view")
	_assert((player.get_node_or_null("VisualRoot/Head/Nose") as Node2D).position == Vector2(-15, 7), "Nose should mirror for left-facing side view")
	_assert((player.get_node_or_null("VisualRoot/Head/Nose") as Node2D).scale.x == -1.0, "Nose shape should mirror for left-facing side view")
	_assert((player.get_node_or_null("VisualRoot/Head/Tooth") as Node2D).position == Vector2(-7, 14), "Tooth should mirror for left-facing side view")
	_assert((player.get_node_or_null("VisualRoot/Head/Tooth") as Node2D).scale.x == -1.0, "Tooth shape should mirror for left-facing side view")
	_assert((player.get_node_or_null("VisualRoot/Head/LampBeam") as Node2D).position == Vector2(-25, -29), "Lamp beam should mirror for left-facing side view")
	_assert((player.get_node_or_null("VisualRoot/Head/LampBeam") as Node2D).scale.x == -1.0, "Lamp beam should mirror its shape for left-facing side view")
	_assert((player.get_node_or_null("VisualRoot/Head/LampShine") as Node2D).position == Vector2(-13, -27), "Lamp shine should mirror for left-facing side view")
	_assert((player.get_node_or_null("VisualRoot/Head/LampShine") as Node2D).scale.x == -1.0, "Lamp shine should mirror its shape for left-facing side view")
	_assert((player.get_node_or_null("VisualRoot/Head/HelmetGrooveLeft") as Node2D).position == Vector2(-3, -17), "Helmet left groove should mirror for left-facing side view")
	_assert((player.get_node_or_null("VisualRoot/Head/HelmetGrooveLeft") as Node2D).scale.x == -1.0, "Helmet left groove should mirror its shape for left-facing side view")
	_assert((player.get_node_or_null("VisualRoot/Head/HelmetGrooveRight") as Node2D).position == Vector2(-3, -17), "Helmet right groove should mirror for left-facing side view")
	_assert((player.get_node_or_null("VisualRoot/Head/HelmetGrooveRight") as Node2D).scale.x == -1.0, "Helmet right groove should mirror its shape for left-facing side view")
	_assert((player.get_node_or_null("VisualRoot/LeftFoot/LeftBootSole") as Node2D).position == Vector2(2, 8), "Back boot sole should mirror for left-facing side view")
	_assert((player.get_node_or_null("VisualRoot/LeftFoot/LeftBootSole") as Node2D).scale.x == -1.0, "Back boot sole shape should mirror for left-facing side view")
	_assert((player.get_node_or_null("VisualRoot/LeftFoot/LeftBootCleats") as Node2D).position == Vector2(3, 10), "Back boot cleats should mirror for left-facing side view")
	_assert((player.get_node_or_null("VisualRoot/LeftFoot/LeftBootCleats") as Node2D).scale.x == -1.0, "Back boot cleats shape should mirror for left-facing side view")
	_assert((player.get_node_or_null("VisualRoot/LeftFoot/LeftBootHighlight") as Node2D).position == Vector2(3, -1), "Back boot highlight should mirror for left-facing side view")
	_assert((player.get_node_or_null("VisualRoot/LeftFoot/LeftBootHighlight") as Node2D).scale.x == -1.0, "Back boot highlight should mirror for left-facing side view")
	_assert((player.get_node_or_null("VisualRoot/RightFoot/RightBootSole") as Node2D).position == Vector2(-2, 8), "Front boot sole should mirror for left-facing side view")
	_assert((player.get_node_or_null("VisualRoot/RightFoot/RightBootSole") as Node2D).scale.x == -1.0, "Front boot sole shape should mirror for left-facing side view")
	_assert((player.get_node_or_null("VisualRoot/RightFoot/RightBootCleats") as Node2D).position == Vector2(-3, 10), "Front boot cleats should mirror for left-facing side view")
	_assert((player.get_node_or_null("VisualRoot/RightFoot/RightBootCleats") as Node2D).scale.x == -1.0, "Front boot cleats should mirror for left-facing side view")
	_assert((player.get_node_or_null("VisualRoot/RightFoot/RightBootHighlight") as Node2D).position == Vector2(-3, -1), "Front boot highlight should mirror for left-facing side view")
	_assert((player.get_node_or_null("VisualRoot/RightFoot/RightBootHighlight") as Node2D).scale.x == -1.0, "Front boot highlight should mirror for left-facing side view")


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

# Vintage Miner Character Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the current placeholder player as a grayscale vintage miner with helmet lamp, overalls, spring limbs, gloves, and large boots while preserving gameplay and procedural animation.

**Architecture:** Keep the existing `Player.tscn` root, collision, controller, `VisualRoot`, and core animator node names. Add decorative visual nodes around the existing anchors, extend `ToonAnimator` only where needed to keep decorative coils aligned, and validate the visual contract with a headless Godot test.

**Tech Stack:** Godot 4, GDScript, `CharacterBody2D`, `Polygon2D`, `Line2D`, `.tscn` scenes, headless Godot verification scripts.

---

## File Structure

- Modify: `scenes/Player.tscn` — replace placeholder orange character with grayscale vintage miner primitives.
- Modify: `scripts/player/toon_animator.gd` — optionally animate decorative spring coils if static decorative nodes drift visually.
- Create: `tests/task6_miner_visual_checks.gd` — verify miner-specific visual nodes and existing animation contract.
- Modify: `tests/task4_toon_animator_checks.gd` — update expectations if new hierarchy adds decorative nodes but keep existing core checks.

## Task 1: Add Miner Visual Contract Test

**Files:**
- Create: `tests/task6_miner_visual_checks.gd`

- [ ] **Step 1: Write failing visual contract test**

Create `tests/task6_miner_visual_checks.gd`:

```gdscript
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
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
rm -rf .godot && /usr/local/bin/godot --headless --path . --script res://tests/task6_miner_visual_checks.gd
```

Expected: FAIL with missing miner nodes such as `Helmet should exist`.

## Task 2: Rebuild Player Visuals as Vintage Miner

**Files:**
- Modify: `scenes/Player.tscn`

- [ ] **Step 1: Replace `VisualRoot` contents with miner primitives**

In `scenes/Player.tscn`, keep root/controller/collision/camera/sensor nodes unchanged. Replace the children under `VisualRoot` with this structure and values:

```ini
[node name="VisualRoot" type="Node2D" parent="."]
position = Vector2(0, -52)
script = ExtResource("4_toon")

[node name="LeftArmCoil" type="Line2D" parent="VisualRoot"]
position = Vector2(-20, -15)
points = PackedVector2Array(0, 0, -8, 7, 1, 14, -10, 21, -2, 28, -12, 36, -8, 45)
width = 5.0
default_color = Color(0.76, 0.76, 0.72, 1)
begin_cap_mode = 2
end_cap_mode = 2

[node name="RightArmCoil" type="Line2D" parent="VisualRoot"]
position = Vector2(20, -17)
points = PackedVector2Array(0, 0, 9, 7, -1, 14, 11, 21, 2, 28, 13, 36, 9, 45)
width = 5.0
default_color = Color(0.76, 0.76, 0.72, 1)
begin_cap_mode = 2
end_cap_mode = 2

[node name="LeftLegCoil" type="Line2D" parent="VisualRoot"]
position = Vector2(-11, 20)
points = PackedVector2Array(0, 0, -7, 7, 2, 14, -8, 22, 0, 30, -6, 39)
width = 5.0
default_color = Color(0.72, 0.72, 0.68, 1)
begin_cap_mode = 2
end_cap_mode = 2

[node name="RightLegCoil" type="Line2D" parent="VisualRoot"]
position = Vector2(11, 20)
points = PackedVector2Array(0, 0, 7, 7, -2, 14, 8, 22, 0, 30, 6, 39)
width = 5.0
default_color = Color(0.72, 0.72, 0.68, 1)
begin_cap_mode = 2
end_cap_mode = 2

[node name="LeftArm" type="Line2D" parent="VisualRoot"]
position = Vector2(-18, -16)
points = PackedVector2Array(0, 0, -16, 20, -12, 42)
width = 3.0
default_color = Color(0.08, 0.08, 0.08, 1)
begin_cap_mode = 2
end_cap_mode = 2

[node name="RightArm" type="Line2D" parent="VisualRoot"]
position = Vector2(18, -16)
points = PackedVector2Array(0, 0, 16, 20, 12, 42)
width = 3.0
default_color = Color(0.08, 0.08, 0.08, 1)
begin_cap_mode = 2
end_cap_mode = 2

[node name="LeftLeg" type="Line2D" parent="VisualRoot"]
position = Vector2(-10, 20)
points = PackedVector2Array(0, 0, -5, 22, -3, 42)
width = 3.0
default_color = Color(0.08, 0.08, 0.08, 1)
begin_cap_mode = 2
end_cap_mode = 2

[node name="RightLeg" type="Line2D" parent="VisualRoot"]
position = Vector2(10, 20)
points = PackedVector2Array(0, 0, 5, 22, 3, 42)
width = 3.0
default_color = Color(0.08, 0.08, 0.08, 1)
begin_cap_mode = 2
end_cap_mode = 2

[node name="Body" type="Polygon2D" parent="VisualRoot"]
color = Color(0.16, 0.16, 0.16, 1)
polygon = PackedVector2Array(-20, -22, 20, -22, 24, 24, -24, 24)

[node name="OverallsBib" type="Polygon2D" parent="VisualRoot"]
position = Vector2(0, -7)
color = Color(0.34, 0.34, 0.34, 1)
polygon = PackedVector2Array(-12, -14, 12, -14, 14, 14, -14, 14)

[node name="LeftStrap" type="Line2D" parent="VisualRoot"]
points = PackedVector2Array(-17, -24, -7, 9)
width = 4.0
default_color = Color(0.66, 0.66, 0.62, 1)

[node name="RightStrap" type="Line2D" parent="VisualRoot"]
points = PackedVector2Array(17, -24, 7, 9)
width = 4.0
default_color = Color(0.66, 0.66, 0.62, 1)

[node name="LeftButton" type="Polygon2D" parent="VisualRoot"]
position = Vector2(-10, 7)
color = Color(0.9, 0.9, 0.82, 1)
polygon = PackedVector2Array(-3, -3, 3, -3, 4, 3, -4, 3)

[node name="RightButton" type="Polygon2D" parent="VisualRoot"]
position = Vector2(10, 7)
color = Color(0.9, 0.9, 0.82, 1)
polygon = PackedVector2Array(-3, -3, 3, -3, 4, 3, -4, 3)

[node name="LeftGlove" type="Polygon2D" parent="VisualRoot"]
position = Vector2(-32, 31)
color = Color(0.86, 0.86, 0.8, 1)
polygon = PackedVector2Array(-15, -8, 7, -9, 16, 0, 12, 12, -8, 13, -18, 4)

[node name="RightGlove" type="Polygon2D" parent="VisualRoot"]
position = Vector2(32, 31)
color = Color(0.86, 0.86, 0.8, 1)
polygon = PackedVector2Array(-7, -9, 15, -8, 18, 4, 8, 13, -12, 12, -16, 0)

[node name="LeftFoot" type="Polygon2D" parent="VisualRoot"]
position = Vector2(-15, 64)
color = Color(0.05, 0.05, 0.05, 1)
polygon = PackedVector2Array(-17, -6, 10, -8, 18, 2, 10, 10, -20, 8)

[node name="RightFoot" type="Polygon2D" parent="VisualRoot"]
position = Vector2(15, 64)
color = Color(0.05, 0.05, 0.05, 1)
polygon = PackedVector2Array(-10, -8, 17, -6, 20, 8, -10, 10, -18, 2)

[node name="Head" type="Polygon2D" parent="VisualRoot"]
position = Vector2(0, -39)
color = Color(0.78, 0.78, 0.72, 1)
polygon = PackedVector2Array(-23, -17, 22, -17, 25, 8, 14, 24, -14, 24, -25, 8)

[node name="EarLeft" type="Polygon2D" parent="VisualRoot/Head"]
position = Vector2(-24, 5)
color = Color(0.7, 0.7, 0.65, 1)
polygon = PackedVector2Array(-7, -8, 4, -8, 6, 6, -5, 9)

[node name="HairTuft" type="Polygon2D" parent="VisualRoot/Head"]
position = Vector2(6, -15)
color = Color(0.04, 0.04, 0.04, 1)
polygon = PackedVector2Array(-9, 0, -2, -8, 2, 0, 9, -7, 7, 5)

[node name="Helmet" type="Polygon2D" parent="VisualRoot/Head"]
position = Vector2(0, -17)
color = Color(0.28, 0.28, 0.28, 1)
polygon = PackedVector2Array(-24, 2, -15, -15, 13, -17, 25, 0, 15, 7, -17, 7)

[node name="HelmetBrim" type="Polygon2D" parent="VisualRoot/Head"]
position = Vector2(0, -10)
color = Color(0.08, 0.08, 0.08, 1)
polygon = PackedVector2Array(-28, -2, 19, -5, 27, 0, 12, 6, -28, 5)

[node name="HeadLamp" type="Polygon2D" parent="VisualRoot/Head"]
position = Vector2(6, -27)
color = Color(0.9, 0.9, 0.78, 1)
polygon = PackedVector2Array(-7, -6, 7, -6, 9, 6, -8, 7)

[node name="LampGlow" type="Polygon2D" parent="VisualRoot/Head"]
position = Vector2(17, -29)
color = Color(1, 1, 0.85, 0.45)
polygon = PackedVector2Array(0, -2, 15, -8, 15, -4, 0, 3)

[node name="Eyes" type="Node2D" parent="VisualRoot/Head"]
position = Vector2(1, -1)

[node name="LeftEye" type="Polygon2D" parent="VisualRoot/Head/Eyes"]
position = Vector2(-8, 0)
color = Color(0.03, 0.03, 0.03, 1)
polygon = PackedVector2Array(-3, -8, 4, -8, 5, 7, -4, 7)

[node name="RightEye" type="Polygon2D" parent="VisualRoot/Head/Eyes"]
position = Vector2(9, 0)
color = Color(0.03, 0.03, 0.03, 1)
polygon = PackedVector2Array(-4, -8, 3, -8, 4, 7, -5, 7)

[node name="Mouth" type="Polygon2D" parent="VisualRoot/Head"]
position = Vector2(1, 13)
color = Color(0.04, 0.04, 0.04, 1)
polygon = PackedVector2Array(-10, -4, 10, -4, 7, 7, -5, 9)

[node name="Cheek" type="Polygon2D" parent="VisualRoot/Head"]
position = Vector2(15, 8)
color = Color(0.9, 0.9, 0.82, 1)
polygon = PackedVector2Array(-5, -4, 6, -5, 7, 4, -4, 6)
```

- [ ] **Step 2: Run miner visual test**

Run:

```bash
rm -rf .godot && /usr/local/bin/godot --headless --path . --script res://tests/task6_miner_visual_checks.gd
```

Expected: PASS with `Vintage miner visual checks passed`.

## Task 3: Verify Existing Animation Contract

**Files:**
- Modify: `tests/task4_toon_animator_checks.gd` only if needed

- [ ] **Step 1: Run existing animation test**

Run:

```bash
rm -rf .godot && /usr/local/bin/godot --headless --path . --script res://tests/task4_toon_animator_checks.gd
```

Expected: PASS. If it fails because of intentional node movement, update only path/position expectations while preserving checks that `VisualRoot` squashes, leans, and foot anchors move during skid.

- [ ] **Step 2: Verify player/readability tests still pass**

Run:

```bash
rm -rf .godot && /usr/local/bin/godot --headless --path . --script res://tests/task3_player_checks.gd
rm -rf .godot && /usr/local/bin/godot --headless --path . --script res://tests/task5_readability_checks.gd
```

Expected: both pass.

## Task 4: Final Import and Scene Verification

**Files:**
- No planned source changes unless verification exposes a concrete failure.

- [ ] **Step 1: Run full headless verification**

Run:

```bash
rm -rf .godot && /usr/local/bin/godot --headless --path . --script res://tests/task3_player_checks.gd
rm -rf .godot && /usr/local/bin/godot --headless --path . --script res://tests/task4_toon_animator_checks.gd
rm -rf .godot && /usr/local/bin/godot --headless --path . --script res://tests/task5_readability_checks.gd
rm -rf .godot && /usr/local/bin/godot --headless --path . --script res://tests/task6_miner_visual_checks.gd
rm -rf .godot && /usr/local/bin/godot --headless --path . --quit
/usr/local/bin/godot --headless --path . --scene res://scenes/Main.tscn --quit
```

Expected: all commands exit 0.

- [ ] **Step 2: Inspect git status**

Run:

```bash
GIT_MASTER=1 git status --short
```

Expected: only intentional files from this redesign are changed or new; `.godot/` and `.DS_Store` must not appear.

---

## Spec Coverage Review

- Black-and-white vintage miner style: Task 2 changes palette and adds miner-specific face/body/gear nodes.
- Helmet and lamp: Task 2 adds `Helmet`, `HelmetBrim`, `HeadLamp`, and `LampGlow`.
- Overalls: Task 2 adds bib, straps, and buttons.
- Spring limbs: Task 2 keeps animated limb anchors and adds coil line nodes.
- Gloves and boots: Task 2 adds glove nodes and restyles feet as oversized boots.
- Animation compatibility: Task 3 reruns existing animation/player/readability checks.
- No gameplay changes: Task 4 verifies import/scene behavior without touching controller scripts.

## Handoff Notes

- Do not alter movement physics, surface profiles, or level layout.
- Keep core node names stable because `ToonAnimator` depends on them.
- If decorative coils look static during play, prefer a small `ToonAnimator` extension that mirrors limb point offsets instead of changing controller logic.
- Do not commit unless the user explicitly asks.

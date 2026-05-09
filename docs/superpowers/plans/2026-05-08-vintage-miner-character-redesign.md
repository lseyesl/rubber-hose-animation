# Hybrid Vintage Miner Player Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor the Godot player visual layer into a reference-matched black-and-white rubber-hose miner using animated primitives plus local decorative texture/decal accents.

**Architecture:** Keep `Player.tscn` root, collision, controller, `VisualRoot`, and the core node names consumed by `ToonAnimator`. Add local visual-only decal nodes under `VisualRoot`, `Head`, `FrontDeco`, `SideDeco`, and boot anchors; extend `ToonAnimator` only to cache, switch, mirror, and animate those decals with the existing front/side view system. Gameplay scripts remain unchanged.

**Tech Stack:** Godot 4.6, GDScript, `.tscn`, `Polygon2D`, `Line2D`, headless Godot scene tests.

---

## File Structure

- Modify: `tests/task6_miner_visual_checks.gd` — add failing contract checks for hybrid decorative texture/decal layer.
- Modify: `scenes/Player.tscn` — add decal/detail nodes: film speckles, helmet grooves, lamp shine, fabric wear, coil highlights, glove creases, and boot highlights.
- Modify: `scripts/player/toon_animator.gd` — keep those visual-only decals aligned during front/side switching and side-view mirroring.
- Existing verification: `tests/task3_player_checks.gd`, `tests/task4_toon_animator_checks.gd`, `tests/task5_readability_checks.gd`, and `tests/task6_miner_visual_checks.gd` must pass headlessly.

## Task 1: Hybrid Visual Contract Test

**Files:**
- Modify: `tests/task6_miner_visual_checks.gd`

- [ ] **Step 1: Add failing assertions for texture/decal layer**

Add assertions that require these nodes:

```gdscript
_assert(player.get_node_or_null("VisualRoot/FilmGrain") is Node2D, "Player-local film grain container should exist")
_assert(player.get_node_or_null("VisualRoot/FilmGrain/GrainA") is Polygon2D, "Film grain speckle A should exist")
_assert(player.get_node_or_null("VisualRoot/Head/HelmetGrooveLeft") is Line2D, "Helmet left groove texture should exist")
_assert(player.get_node_or_null("VisualRoot/Head/HelmetGrooveRight") is Line2D, "Helmet right groove texture should exist")
_assert(player.get_node_or_null("VisualRoot/Head/LampShine") is Polygon2D, "Lamp shine decal should exist")
_assert(player.get_node_or_null("VisualRoot/FrontDeco/OverallsWear") is Line2D, "Front overalls fabric wear should exist")
_assert(player.get_node_or_null("VisualRoot/FrontDeco/LeftArmCoilHighlight") is Line2D, "Left front coil highlight should exist")
_assert(player.get_node_or_null("VisualRoot/FrontDeco/RightArmCoilHighlight") is Line2D, "Right front coil highlight should exist")
_assert(player.get_node_or_null("VisualRoot/FrontDeco/LeftGloveCreases") is Line2D, "Left glove crease texture should exist")
_assert(player.get_node_or_null("VisualRoot/FrontDeco/RightGloveCreases") is Line2D, "Right glove crease texture should exist")
_assert(player.get_node_or_null("VisualRoot/SideDeco/SideCoilHighlight") is Line2D, "Side coil highlight should exist")
_assert(player.get_node_or_null("VisualRoot/SideDeco/SideOverallsWear") is Line2D, "Side overalls fabric wear should exist")
_assert(player.get_node_or_null("VisualRoot/LeftFoot/LeftBootHighlight") is Line2D, "Left boot highlight decal should exist")
_assert(player.get_node_or_null("VisualRoot/RightFoot/RightBootHighlight") is Line2D, "Right boot highlight decal should exist")
```

Add side-view dynamic checks that `LampShine`, helmet grooves, and boot highlights move to side-view positions and mirror left/right.

- [ ] **Step 2: Run the test and verify RED**

Run:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/task6_miner_visual_checks.gd
```

Expected: FAIL with missing decal nodes such as `Player-local film grain container should exist`.

## Task 2: Add Hybrid Decorative Nodes

**Files:**
- Modify: `scenes/Player.tscn`

- [ ] **Step 1: Add player-local film and texture/decal nodes**

Add `FilmGrain` under `VisualRoot`; add helmet groove, lamp shine, fabric wear, coil highlight, glove crease, side highlight, and boot highlight nodes using `Polygon2D`/`Line2D`. Keep them visual-only and small so they enhance the reference style without replacing animated primitives.

- [ ] **Step 2: Run Task 6 and verify GREEN or identify animator gaps**

Run the same Task 6 command. Expected after scene-only work: static node checks pass; dynamic side-view checks may fail until Task 3 if decal positions are not switched/mirrored.

## Task 3: Animate and Mirror Decal Layer

**Files:**
- Modify: `scripts/player/toon_animator.gd`

- [ ] **Step 1: Cache front and side base positions for new decals**

Add variables for helmet grooves, lamp shine, boot highlights, and side coil highlight positions. Store front defaults in `_store_base_visuals()`.

- [ ] **Step 2: Update front/side switching and mirroring**

Extend `_apply_view()`, `_mirror_side_view()`, `_apply_boot_detail_view()`, and `_apply_side_deco_swing()` so decal nodes follow the same view, foot, and swing transforms as their parent primitives.

- [ ] **Step 3: Run Task 6 and verify GREEN**

Run:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/task6_miner_visual_checks.gd
```

Expected: PASS.

## Task 4: Full Verification

**Files:**
- No production modifications unless verification exposes a concrete bug.

- [ ] **Step 1: Run existing headless checks**

Run:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/task3_player_checks.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/task4_toon_animator_checks.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/task5_readability_checks.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/task6_miner_visual_checks.gd
```

Expected: all PASS.

- [ ] **Step 2: Run Godot import check**

Run:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --quit
```

Expected: exit code 0.

## Self-Review

- Spec coverage: hybrid primitives plus local texture/decal accents are covered by Tasks 1-3; gameplay preservation and verification are covered by Task 4.
- Placeholder scan: no TBD/TODO placeholders remain.
- Type consistency: all required visual nodes use Godot node types already present in the project (`Node2D`, `Polygon2D`, `Line2D`).

## Execution Note

No commits are included in this plan because the user has not explicitly requested a git commit.

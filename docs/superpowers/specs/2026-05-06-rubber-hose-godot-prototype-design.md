# Rubber Hose Godot Prototype Design

Date: 2026-05-06

## Goal

Build an experimental Godot 4 prototype for a 2D side-scrolling Rubber Hose style character. The first version prioritizes playable feel: the character should run, jump, skid, bounce, and feel different on distinct surface materials while showing exaggerated cartoon feedback.

This is a near-product-prototype, not a polished final game. The goal is to prove the control feel, material reactions, and Rubber Hose visual direction with an extensible architecture.

## Chosen Direction

Use a gameplay-first architecture with a procedural cartoon presentation layer.

- `CharacterBody2D` handles movement, collision, jump logic, and material response.
- A separate visual layer applies squash/stretch, leaning, limb swing, facial feedback, and impact exaggeration.
- Surface behavior is data-driven through surface profiles.
- The first visual rig uses simple layered cartoon placeholder shapes and line limbs.
- The structure leaves room to replace the visual layer with `Skeleton2D`, `Bone2D`, and IK later without rewriting controller logic.

## Non-Goals for the First Version

- Full production art assets.
- Final authored animation set.
- Complex ragdoll-driven movement.
- Physics deformation that changes the player collision shape.
- A complete game loop with menus, progression, scoring, or enemies.

## Core Architecture

The player is split into stable gameplay logic and exaggerated visual feedback.

### Gameplay Layer

The gameplay layer is responsible for deterministic platform movement:

- Horizontal acceleration, deceleration, and max speed.
- Jumping and falling.
- Ground, wall, and ceiling collision handling.
- Surface detection under the character.
- State classification such as idle, run, jump, fall, land, skid, bounce, and stuck.

The gameplay layer should not depend on detailed art or bone setup. It exposes readable signals or properties such as velocity, grounded state, active surface, impact strength, and current movement state.

### Visual Layer

The visual layer listens to gameplay data and turns it into cartoon feedback:

- Squash on landing.
- Stretch on takeoff and bounce.
- Lean based on acceleration, deceleration, and skid direction.
- Limb swing based on speed and state.
- Foot dragging on sticky surfaces.
- Eye or face reactions during skid, bounce, or stuck states.

The visual layer can exaggerate heavily, but it must not modify the collision shape. This keeps the character playable even when the art bends, stretches, or compresses.

## Player Scene Structure

Recommended initial scene: `Player.tscn`.

```text
Player (CharacterBody2D)
├── CollisionShape2D
├── SurfaceSensor
├── CameraTarget
├── AnimationPlayer
├── AnimationTree
└── VisualRoot
    ├── Body
    ├── Head
    ├── Eyes
    ├── LeftArm
    ├── RightArm
    ├── LeftLeg
    ├── RightLeg
    ├── LeftFoot
    └── RightFoot
```

`VisualRoot` starts with simple cartoon placeholder pieces: capsule or oval body, round head, line-based arms and legs, flat feet, and expressive eyes. These pieces are easy to scale, rotate, and offset procedurally.

The later upgrade path is to replace the contents of `VisualRoot` with a `Skeleton2D` hierarchy, weighted `Polygon2D` pieces, and IK or procedural bone overrides. The controller and surface systems should not need large changes for that upgrade.

## Movement and Animation States

The first version uses these states:

- `idle`: grounded with little or no input.
- `run`: grounded with stable movement.
- `jump`: upward movement after jump input or bounce.
- `fall`: airborne and descending.
- `land`: short impact state after touching ground.
- `skid`: high horizontal speed with opposite input or low-friction surface behavior.
- `bounce`: rebound from elastic ground.
- `stuck`: slowed movement on sticky mud or slime.

`AnimationTree` and `AnimationPlayer` can handle baseline state transitions and simple loops. Procedural animation is layered on top so squash/stretch and material-specific exaggeration can react continuously to velocity and impact values.

State transitions need hysteresis or short minimum durations to avoid flickering between adjacent states such as idle/run or run/skid.

## Surface System

Each surface type is represented by a data profile. A profile controls both movement parameters and visual feedback strength.

Suggested `SurfaceProfile` fields:

- `id`
- `display_name`
- `acceleration_multiplier`
- `friction_multiplier`
- `max_speed_multiplier`
- `jump_multiplier`
- `bounce_multiplier`
- `stickiness`
- `visual_squash_multiplier`
- `visual_stretch_multiplier`
- `visual_drag_multiplier`
- `skid_threshold_multiplier`

The player reads the active profile from the floor beneath it. Detection can use tile custom data, collider groups, or metadata. The implementation should hide that detail behind a small surface lookup API so the player controller does not care whether the level uses tiles or separate collision bodies.

Surface parameter changes should be smoothed over a short time window. This prevents harsh feel changes when crossing from ice to normal ground or from normal ground into mud.

## First Version Surface Types

### Normal Ground

Normal ground is the baseline movement profile:

- Standard acceleration and friction.
- Standard jump height.
- Standard run animation.
- Landing squash and takeoff stretch at moderate intensity.

### Ice

Ice emphasizes low friction and loss of control:

- Lower friction.
- Slower turn-around response.
- Longer braking distance.
- `skid` animation when reversing or trying to stop.
- Visual body lean opposite the movement direction.
- Fast foot slipping and worried eye expression.

### Elastic Ground

Elastic ground emphasizes impact and rebound:

- Landing velocity converts into upward bounce.
- Manual jump can stack with bounce within tuned limits.
- Strong landing squash followed by tall stretch.
- `bounce` state for the rebound moment.

The bounce is implemented in player movement logic, not left entirely to `PhysicsMaterial`, because `CharacterBody2D` is script-controlled and should stay predictable.

### Slime or Mud

Slime and mud emphasize drag and effort:

- Lower acceleration.
- Lower max speed.
- Reduced jump power.
- Higher visual drag.
- `stuck` animation or heavy run variant.
- Feet appear to pull out of the surface during steps.

## Test Playground

The first playable scene should be a horizontal playground with clear surface zones:

1. Normal ground for baseline control.
2. Ice strip for sliding and skidding.
3. Elastic ground for bouncing.
4. Slime or mud strip for drag and stuck movement.
5. A few ramps, ledges, and vertical walls to test collision stability.

The playground should include debug labels or an overlay showing:

- Current movement state.
- Current surface profile.
- Current velocity.
- Whether the player is grounded.
- Recent impact or bounce strength.

## Tuning Interface

The prototype should include a simple tuning entry point. This can start as exported script variables and a debug overlay, then grow into an in-game panel.

Important tunables:

- Base acceleration.
- Base friction.
- Max run speed.
- Jump velocity.
- Gravity.
- Landing squash strength.
- Stretch recovery speed.
- Ice friction multiplier.
- Elastic bounce multiplier.
- Mud stickiness and speed reduction.

Tuning should be fast because the prototype's success depends on feel rather than raw feature count.

## Validation Criteria

The first version is successful when:

- The player can run, jump, land, and collide reliably.
- Normal ground feels stable and responsive.
- Ice clearly causes sliding and skidding.
- Elastic ground clearly bounces the character.
- Slime or mud clearly slows and drags the character.
- Rubber Hose feedback is visible during run, jump, fall, land, skid, bounce, and stuck states.
- Visual deformation never changes or breaks the collision shape.
- Surface transitions are smooth enough that control does not feel broken.
- Debug information makes it easy to understand current state and tune behavior.

## Risks and Mitigations

### Risk: Visual exaggeration breaks gameplay readability

Mitigation: Keep the collision shape stable and use `VisualRoot` for all deformation.

### Risk: Animation state flickers

Mitigation: Use thresholds, hysteresis, and minimum state durations.

### Risk: Surface logic becomes hardcoded

Mitigation: Use `SurfaceProfile` resources and a surface lookup boundary.

### Risk: Rubber Hose upgrade requires rewriting player logic

Mitigation: Keep the controller independent from `VisualRoot` internals.

### Risk: Near-product scope becomes too large

Mitigation: Treat art as expressive placeholder art. Prioritize feel, clear feedback, and extensible structure over final polish.

## Implementation Readiness

This design is ready to become an implementation plan. The recommended next step is to create a Godot 4 project skeleton, then implement in this order:

1. Project structure and test playground.
2. `CharacterBody2D` player controller.
3. Surface profile data and detection.
4. Procedural cartoon visual layer.
5. Animation states and debug overlay.
6. Tuning pass and verification scene.

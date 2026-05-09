# Vintage Miner Character Redesign

Date: 2026-05-08

## Goal

Redesign the current Godot placeholder player into a black-and-white vintage miner character inspired by the provided reference image. The new character should read as a 1930s rubber-hose cartoon miner with a helmet lamp, expressive face, spring-like limbs, white gloves, overalls, and oversized boots.

## Chosen Direction

Use a hybrid character system: keep the existing procedural character anchors for animation, then layer reference-matched decorative texture pieces and grayscale detail shapes on top. The gameplay controller remains unchanged.

- Keep `Player.tscn` root, collision shape, `VisualRoot`, and `ToonAnimator` integration.
- Preserve existing core node names used by `ToonAnimator`: `Body`, `Head`, `LeftArm`, `RightArm`, `LeftLeg`, `RightLeg`, `LeftFoot`, `RightFoot`, and `Head/Eyes`.
- Add decorative child nodes and lightweight texture overlays around those anchors to create the miner look.
- Use a grayscale palette with thick dark shapes, bright highlights, and film-grain texture accents to evoke a silent-film cartoon style.

## Visual Design

The character should be rebuilt from animated Godot 2D primitives plus small decorative texture overlays. The primitives carry the silhouette and animation; the overlays add the reference image's old-film grime, miner-helmet detail, clothing wear, and hand-drawn shading.

### Head and Face

- `Head` becomes a light-gray rounded cartoon face.
- Add a miner helmet made from polygon pieces: helmet cap, brim, head lamp, and small lamp glow. Add texture accents for helmet grooves, lamp shine, and speckled film wear.
- Add facial details: large oval eyes, smiling open mouth, cheek/nose shapes, ears, and a small hair tuft.
- Keep the eyes under `VisualRoot/Head/Eyes` so the existing animator can squash and shift them.

### Body

- `Body` becomes dark-gray overalls and torso.
- Add an overalls bib, left/right straps, and two bright buttons, with texture accents for fabric wear and vintage ink shading.
- Keep the torso compact so squash/stretch remains readable.

### Limbs

- Keep `LeftArm`, `RightArm`, `LeftLeg`, and `RightLeg` as `Line2D` nodes so `ToonAnimator` can continue bending them.
- Restyle these core limb nodes as dark spring guide lines.
- Add decorative coil/spring line nodes near each limb to suggest the reference image's metal spring arms and legs.
- Add highlight/shadow overlay strokes on the coils so the springs read as shiny metal instead of simple zig-zag lines.
- The decorative coils should be children of `VisualRoot` and remain visually aligned with the animated limb anchors.

### Hands and Feet

- Replace simple feet with oversized black miner boots using polygon shapes and tread/highlight texture details.
- Add light-gray/white glove shapes for hands, with mitten-like cartoon fingers and hand-drawn crease accents.
- Keep `LeftFoot` and `RightFoot` as the animated foot anchors so existing foot drag still works.

## Animation Compatibility

The redesign must not break existing gameplay or procedural animation.

- `ToonAnimator` may be extended to cache and animate decorative coil nodes if needed.
- Collision remains unchanged on the `Player` root.
- All squash/stretch and limb animation remain visual-only under `VisualRoot`.
- Existing tests for player structure, toon animation, and readability should continue to pass after being updated for any intentional new visual nodes.

## Non-Goals

- No full imported sprite sheet that replaces the animated character.
- No final production illustration pass; texture overlays stay lightweight and editable.
- No full-screen film grain or post-processing pass unless it is local to the player visual layer.
- No changes to movement physics, surface profiles, or level layout.
- No full skeletal rig or IK conversion in this pass.

## Validation Criteria

The redesign is successful when:

- The player reads clearly as a black-and-white vintage miner closely matching the provided reference: joyful round face, miner helmet lamp, overalls, spring limbs, white gloves, and oversized boots.
- Helmet, head lamp, overalls, spring limbs, white gloves, and large boots are visible in `Player.tscn`.
- Existing movement, surface response, squash/stretch, skid, bounce, and stuck visual feedback still work.
- Godot headless import passes.
- Existing verification scripts pass, with any character-structure checks updated to include the miner-specific nodes.

## Implementation Readiness

This is a focused hybrid visual redesign. The implementation should modify `scenes/Player.tscn`, add or update local player texture/decal assets under `docs/assets` or a Godot asset folder if needed, likely update `scripts/player/toon_animator.gd` for decorative coil syncing, and update/add tests for the miner visual contract. Gameplay scripts should remain unchanged unless a test exposes a concrete integration issue.

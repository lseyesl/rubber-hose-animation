# Player Image-Part Rig Redesign

Date: 2026-05-12

## Goal

把 player 的可见身体从程序化 `Polygon2D` / `Line2D` 形状改为图片部件 rig，使游戏内角色更接近 `docs/assets/player_concept.png` 和 `docs/assets/player_profile.png`。程序逻辑只负责移动、缩放、旋转、镜像和状态切换，不再负责生成身体外形。

## User Feedback Driving This Change

局部 decal 方案仍保留了程序化主体，导致 player 和概念图差距过大。新的要求是：手、胳膊、头、眼睛、眉毛、嘴、躯干、腿等主体部件都应该使用图片实现，而不是程序化绘制。

## Decision: D — Image-Part Rig

采用 **D：image-part rig** 作为新的主方案，替代之前 B/C 的局部增强路线。

- B（局部 decal + UI sheet）保留为历史阶段，不作为最终视觉方向。
- C（动作关键帧 decal）暂不追加；如果 D 完成后仍需夸张状态表现，再作为图片部件状态切换扩展。
- 不做完整逐帧 player sprite sheet；改做“可动画图片部件”。

## Architecture

### Gameplay Layer: Keep

继续保留：

- `Player` root as `CharacterBody2D`
- `CollisionShape2D`
- `SurfaceSensor`
- `Camera2D`
- `scripts/player/player_controller.gd`
- surface profiles and movement physics

### Visual Layer: Replace Generated Shapes with Image Parts

`VisualRoot` 继续作为视觉根节点并继续使用 `scripts/player/toon_animator.gd`，但可见部件改为图片节点或图片 rig 容器。

Required image-based parts:

| Concept Part | Required Node | Type Direction | Notes |
|--------------|---------------|----------------|-------|
| 头 | `VisualRoot/Head` | `Node2D` container with `HeadSprite` | 容器承接 squash/position，图片承接外观 |
| 眼睛 | `VisualRoot/Head/Eyes/LeftEyeSprite`, `RightEyeSprite` | `Sprite2D` | 眼睛来自图片区域 |
| 眉毛 | `VisualRoot/Head/Eyebrows/LeftBrowSprite`, `RightBrowSprite` | `Sprite2D` | 新增表情层 |
| 嘴 | `VisualRoot/Head/MouthSprite` | `Sprite2D` | 替代 polygon mouth |
| 躯干 | `VisualRoot/Body` | `Node2D` container with `TorsoSprite` | 保持 Body 动画锚点名称 |
| 胳膊 | `VisualRoot/LeftArm`, `RightArm` | `Node2D` container with arm sprites | 程序控制容器位置/旋转/缩放 |
| 手 | `VisualRoot/LeftHand`, `RightHand` or children under arm containers | `Sprite2D` | 手套必须是图片 |
| 腿 | `VisualRoot/LeftLeg`, `RightLeg` | `Node2D` container with leg sprites | 弹簧腿来自图片 |
| 脚/靴子 | `VisualRoot/LeftFoot`, `RightFoot` | `Node2D` container with boot sprites | 保留 foot drag 行为 |

The legacy node names (`Body`, `Head`, `LeftArm`, `RightArm`, `LeftLeg`, `RightLeg`, `LeftFoot`, `RightFoot`, `Head/Eyes`) should remain as animation anchors, but their visible children become `Sprite2D` regions.

## Asset Strategy

First implementation may use `docs/assets/player_profile.png` as a temporary atlas with `Sprite2D.region_enabled = true` for all parts. This lets us switch the rig architecture before final hand-cut assets exist.

Later, replace temporary regions with a curated atlas such as:

- `assets/player/player_parts_atlas.png`
- `assets/player/player_parts_atlas.png.import`

Recommended atlas contents:

- front head, side head
- left/right eyes
- left/right eyebrows
- mouth variants
- torso/overalls
- upper/lower spring arm or single spring-arm segments
- glove/hand sprites
- spring leg sprites
- boot sprites
- helmet/headlamp variants

## ToonAnimator Changes

`ToonAnimator` should stop assuming visible parts are `Polygon2D` / `Line2D`.

Minimum changes:

- Treat `Body`, `Head`, arms, legs, and feet as `Node2D` anchors.
- Store and animate `position`, `scale`, and `rotation` on anchors.
- Do not mutate `polygon` or `points` for image parts.
- Replace limb point bending with container transforms: rotation, scale, and child sprite stretch/skew where possible.
- Preserve:
  - squash/stretch on `VisualRoot`
  - lean
  - limb swing
  - foot drag
  - eye expression via eye sprite container offsets/scales
  - front/side switching
  - left/right mirroring
  - surface visual multipliers

## Testing Strategy

Tests must change from “core anchors are Polygon2D/Line2D” to “core anchors are image rig anchors with Sprite2D children”.

Required assertions:

- `VisualRoot/Body` is `Node2D` and has `TorsoSprite` as `Sprite2D`.
- `VisualRoot/Head` is `Node2D` and has `HeadSprite`, `MouthSprite`, `Eyes`, `Eyebrows`.
- Eyes and eyebrows are `Sprite2D` image parts.
- Arms, hands, legs, and boots are image-based nodes.
- No visible core body part remains a standalone `Polygon2D` or `Line2D` shape.
- `ToonAnimator` still processes run/skid/side-view without errors.
- Existing gameplay/controller tests still pass.

## Non-Goals

- No full frame-by-frame player sprite sheet in this pass.
- No movement physics change.
- No collision shape change.
- No inventory/equipment gameplay.
- No final production art slicing requirement before the architecture works; temporary atlas regions are acceptable for first implementation.

## Success Criteria

- Main player silhouette is visibly driven by images, not generated primitives.
- The player can still run/skid/jump/fall with existing `ToonAnimator` responses.
- The rig can later receive cleaner cut images without changing gameplay scripts.
- Tests enforce image-based body parts so the implementation cannot regress to procedural shapes.

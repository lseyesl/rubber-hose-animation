# Player Display Replan

Date: 2026-05-12

## Goal

重新规划 player 显示方案，使 `docs/assets/player_concept.png` 与 `docs/assets/player_profile.png` 中的 rubber-hose 矿工形象成为项目内统一的角色显示规范，而不是仅作为单张参考图。

## Source References

- `docs/assets/player_concept.png`：情绪、动作感、复古矿工氛围、弹簧肢体与头灯识别。
- `docs/assets/player_profile.png`：正/侧/背比例、装备细节、道具 icon 造型、角色 turn-around 一致性。

## Current Project Fit

当前项目已经采用适合该角色的 hybrid procedural 显示架构：

- `scenes/Player.tscn` 保持 `CharacterBody2D`、碰撞、surface sensor、camera 等玩法节点稳定。
- `VisualRoot` 承担所有可变形视觉层。
- `scripts/player/toon_animator.gd` 已支持 front/side view、镜像、squash/stretch、lean、limb swing、eye expression、surface visual multiplier 与落地冲击反馈。
- `FrontDeco` / `SideDeco` 已经将装饰层和动画锚点拆开。

因此新方案不应改为完整 sprite sheet 替换，而应把两张参考图转化为一套分层、三视图、可动画的显示规范。

## Considered Approaches

### Option A: Full Sprite Sheet Replacement

把 player 改成完整导入 sprite sheet，按动作播放帧动画。

- 优点：最接近绘制稿；美术控制强。
- 缺点：会削弱当前 procedural squash/stretch、surface response、弹簧肢体动态和 side mirroring；实现成本高；不符合已有 spec 的方向。
- 结论：不推荐。

### Option B: Keep Current Player, Only Adjust Colors/Details

只在现有 `Player.tscn` 上补颜色、头灯、背带裤、手套、靴子细节。

- 优点：改动小，风险低。
- 缺点：无法充分利用 `player_profile.png` 的正/侧/背规范，也无法建立道具显示体系；后续 UI/icon/装备显示仍会分裂。
- 结论：可作为最小修补，但不是理想重规划。

### Option C: Layered Three-View Display System（推荐）

延续当前 procedural anchors，把 `player_profile.png` 拆成显示规范：正面展示、侧面运动、背面预留、道具 icon 字典。场景内角色继续由 Godot primitives/deco overlays 构成，UI 与文档使用同一套比例和道具规则。

- 优点：保留现有动画系统；能统一角色、三视图和道具；易测试；未来可逐步替换为 texture decal 而不破坏玩法。
- 缺点：需要整理节点职责和显示规则，短期文档/测试工作更多。
- 结论：推荐采用。

## Recommended Display Scheme

### 1. Visual Identity

Player 的核心识别必须固定为：

- 大头、小躯干、夸张白手套、厚重棕色矿工靴。
- 金属弹簧手臂和腿，必须在小尺寸下仍能读出来。
- 棕色矿工头盔 + 正面圆形头灯，头灯是最高优先级身份标识。
- 深蓝背带裤 + 奶油色上衣 + 黄色纽扣。
- 表情保持 cheerful rubber-hose：大眼、圆鼻、张嘴笑。

显示优先级：轮廓 > 头灯 > 弹簧四肢 > 手套/靴子 > 背带裤细节 > 纹理噪点。

### 2. Scene Player Views

Use `VisualRoot` as the display root and preserve current gameplay separation.

| View | Usage | Required Readability |
|------|-------|----------------------|
| Front | idle, land, bounce, status showcase | 头灯正中、双眼、双手套、双靴、背带裤纽扣 |
| Side | run, jump with horizontal velocity, fall with horizontal velocity, skid, stuck | 突出的头灯、鼻子、单眼轮廓、单侧手套、靴底、弹簧肢体方向感 |
| Back | 不立即用于 gameplay；作为未来攀爬/背向动作与文档规范 | 交叉背带、后袋、头盔背面、头发轮廓、弹簧肢体 |

Back view should be documented and optionally represented by a hidden/future `BackDeco` group, but implementation can defer it until a gameplay state needs it.

### 3. Node Layering Rules

Keep the current anchor/deco split:

- Animation anchors: `Body`, `Head`, `LeftArm`, `RightArm`, `LeftLeg`, `RightLeg`, `LeftFoot`, `RightFoot`, `Head/Eyes`.
- Front detail group: `FrontDeco` for front coils, gloves, straps, buttons, boot details.
- Side detail group: `SideDeco` for side coil, side glove, side boot/overall details.
- Future optional group: `BackDeco` only when a real back-view gameplay/display use exists.

Decorative pieces may move with cached base positions in `ToonAnimator`, but collision and movement must remain unchanged.

### 4. Item and Equipment Display

The item row in `player_profile.png` should become the player visual dictionary, not a new gameplay inventory feature yet.

| Item | Display Role | In-Game Use |
|------|--------------|-------------|
| Helmet | Head identity reference | Player head visual and possible UI portrait icon |
| Glove | Hand shape reference | Hand pose/deco standard |
| Boot | Foot silhouette reference | Foot/landing/skid readability standard |
| Pickaxe | Tool icon reference | Future prop/equipment icon |
| Lantern | Light-source icon reference | Future UI prop or cave-light pickup icon |
| Mine cart | Environmental prop reference | Future level prop; not part of player body |

All item icons should keep thick outlines, simple warm palette, and exaggerated silhouette so they remain readable at small UI sizes.

### 5. Color and Style Direction

The concept image is monochrome vintage, while the profile sheet uses warm color. The project should use a hybrid palette:

- Gameplay sprite: warm profile-sheet colors for readability（brown helmet/boots, blue overalls, cream shirt, white gloves, gray springs）.
- Optional overlay: local film grain/scratch accents remain subtle and should not obscure silhouette.
- UI/documentation renders: can show the fuller color palette and cleaner icon shapes.

Avoid making the gameplay character too grayscale; the colored profile sheet gives better small-screen readability.

### 6. Animation Rules

`ToonAnimator` remains the animation authority.

- Keep instant view switching for rubber-hose snappiness.
- Preserve surface-driven squash/stretch/drag multipliers.
- Keep side mirroring for left/right movement.
- Make spring limbs the most animated feature: swing, stretch, skid drag, and bounce should visibly affect coils.
- Headlamp should subtly lead direction in side view and remain centered in front view.

### 7. Validation Criteria

The replan is successful when:

- A viewer can identify the character as the same miner from both reference images at gameplay size.
- Front and side views match `player_profile.png` proportions.
- Current procedural animation behavior remains intact.
- Player display docs distinguish body anchors, decorative layers, direction views, and item/icon references.
- No movement, collision, surface profile, or controller behavior changes are required.

## Implementation Boundary

This document is a display scheme replan. A later implementation plan should focus on:

1. Auditing `Player.tscn` against the visual identity checklist.
2. Updating colors/details to align with `player_profile.png`.
3. Adding tests for required visual nodes and view containers.
4. Optionally adding a UI/icon style guide for the profile-sheet item row.

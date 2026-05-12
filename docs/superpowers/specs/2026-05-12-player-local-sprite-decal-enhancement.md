# Player Local Sprite/Decal Enhancement Design

Date: 2026-05-12

## Goal

在不替换现有 `VisualRoot + ToonAnimator` 程序动画主体的前提下，用局部 sprite/decal 和 UI/item sprite sheet 提升 player 的完成度。第一阶段先做方案 B；如果效果不够，再追加方案 C。

## Decision

采用分阶段路线：

1. **先做 B：局部 decal + UI sprite sheet。**
2. **保留 C：动作关键帧 decal。** 当 B 的静态增强无法满足动作表现时，再追加 C。

完整 player sprite sheet 仍不是本阶段目标；主角色动作继续由 `scripts/player/toon_animator.gd` 驱动。

## Shared Constraints

- 保留 `scenes/Player.tscn` 的 `CharacterBody2D`、碰撞体、`SurfaceSensor`、`VisualRoot` 与核心动画节点。
- 保留 `ToonAnimator` 的 squash/stretch、surface visual multipliers、front/side switching、side mirroring、limb swing 与 impact squash。
- 不用 sprite sheet 替换 `Body`、`Head`、`LeftArm`、`RightArm`、`LeftLeg`、`RightLeg`、`LeftFoot`、`RightFoot`、`Head/Eyes`。
- 新增 sprite/decal 只增强视觉完成度，不改变移动、碰撞、surface profile 或 player controller。
- 视觉基准来自：
  - `docs/assets/player_concept.png`
  - `docs/assets/player_profile.png`

## 方案 B：局部 decal + UI sprite sheet（第一阶段）

### Purpose

让场景内 player 更接近参考图完成度，同时补齐 UI/道具显示的一致视觉来源。B 方案解决“看起来还不够完成稿”和“道具/头像没有统一资产”的问题，但不增加动作状态复杂度。

### Asset Groups

#### 1. Local Player Decals

这些 decal 挂在现有程序节点或 deco container 下，随节点移动、缩放、镜像。

| Decal | Suggested Parent | Role |
|-------|------------------|------|
| Headlamp glass/highlight | `VisualRoot/Head` | 强化头灯作为最高优先级身份标识 |
| Helmet scratches/seams | `VisualRoot/Head` | 增加矿工帽完成度，不影响头部变形 |
| Face expression patch variants | `VisualRoot/Head` or `VisualRoot/Head/Eyes` | 让笑脸、眼睛更接近 concept 图 |
| Glove palm/finger crease decals | `VisualRoot/FrontDeco`, `VisualRoot/SideDeco` | 强化白手套 cartoon 质感 |
| Boot sole/tread decals | `VisualRoot/LeftFoot`, `VisualRoot/RightFoot` | 强化厚靴和落地可读性 |
| Overall fabric wear/patch | `VisualRoot/FrontDeco`, `VisualRoot/SideDeco` | 增加蓝色背带裤细节 |
| Local film grain/scratch | `VisualRoot/FilmGrain` | 保留 vintage 氛围，但不遮挡轮廓 |

#### 2. UI/Item Sprite Sheet

UI/item sheet 不参与 player 主体动作，只服务头像、图标和未来装备/道具显示。

建议包含：

- player portrait：正面头像，突出头灯、笑脸、矿工帽。
- helmet icon：来自 `player_profile.png` 的头盔/头灯轮廓。
- glove icon：白手套，粗描边。
- boot icon：厚底棕色矿工靴。
- pickaxe icon：木柄 + 灰色镐头。
- lantern icon：暖黄色玻璃灯。
- mine cart icon：木车 + 矿石。

### B Display Rules

- 场景 player 小尺寸优先保持轮廓清楚，decal 不应比主体线条更抢眼。
- decal 应该跟随现有节点，而不是建立新的动作系统。
- UI/item sheet 可以比场景 player 更精细，因为它不参与实时 deformation。
- 每个 icon 使用同一套粗描边、暖色矿洞调色和简化高识别造型。

### B Success Criteria

- player 在 gameplay 尺寸下更接近 `player_profile.png` 的完成稿风格。
- 头灯、手套、靴子、背带裤的材质细节明显提升。
- UI/item 图标与 player 身份统一。
- `ToonAnimator` 的现有运动反馈不被削弱。
- 不需要为 run/jump/skid 新增动作状态贴片。

## 方案 C：动作关键帧 decal（后续追加）

### Purpose

当 B 的静态局部增强不够表现 rubber-hose 夸张动作时，追加少量状态贴片，让 run、jump、skid、stuck 等动作更有动画感。C 不替换主体动画，只在关键状态显示更夸张的局部表情或效果 decal。

### Trigger to Add C

满足以下任一情况，再追加 C：

- B 完成后，run/jump/skid 的动作仍显得像“静态角色在移动”。
- 弹簧肢体的实时 swing 足够，但脸部/头灯/手套缺少状态反馈。
- 需要更明确地区分 skid、stuck、bounce 等手感状态。
- UI/icon 已统一，但 gameplay 角色缺少 reference concept 图里的夸张情绪。

### C Asset Groups

| State | Decal Type | Suggested Parent | Purpose |
|-------|------------|------------------|---------|
| run | cheek/smile smear, side eye patch | `VisualRoot/Head` | 增加速度感和快乐奔跑感 |
| jump | wide-eye/highlight patch, lifted mouth | `VisualRoot/Head/Eyes`, `VisualRoot/Head` | 强化上升瞬间的兴奋表情 |
| fall | stretched mouth/eye patch | `VisualRoot/Head` | 强化下落紧张感 |
| skid | squint eye, grit teeth, boot dust/spark decal | `VisualRoot/Head`, feet nodes | 强化摩擦和方向阻力 |
| stuck | strained face, compressed glove/coil accent | `VisualRoot/Head`, deco groups | 强化被 slime 等表面拖住的反馈 |
| bounce/land | star/headlamp flash, impact dust | `VisualRoot/Head`, feet nodes | 强化 rubber-hose 弹跳反馈 |

### C Runtime Rules

- C decals 由 `ToonAnimator` 根据 `movement_state`、velocity 和 surface response 控制 visible/hidden。
- C decals 不改变核心节点 polygon/line 数据，只作为状态 overlay。
- 同一时刻只显示必要的少量 state decal，避免视觉噪音。
- C 必须保留 B 的 local decal 和 UI/item sheet，不回退 B。

### C Success Criteria

- run、jump、skid、stuck、bounce/land 至少有 3 个状态能通过局部贴片读出不同情绪或受力。
- 状态贴片增强动作表现，但不遮挡头灯、手套、靴子和弹簧肢体轮廓。
- `ToonAnimator` 仍是唯一动画状态入口。

## Recommended Implementation Order

1. **B1 — Asset style guide:** 定义 decal 和 UI/item sheet 的尺寸、描边、色板、命名规则。
2. **B2 — Local decal placement:** 在 `Player.tscn` 中为头灯、手套、靴子、背带裤、film grain 增加贴片挂点或 Sprite2D 节点。
3. **B3 — UI/item sheet:** 建立 portrait 和 item icon 的 sprite sheet 规范与切片资源。
4. **B4 — Tests/checks:** 更新视觉结构测试，确认核心动画节点仍存在，decal 节点不会替代 anchors。
5. **Review B in game:** 如果动作仍不够有表现力，再进入 C。
6. **C1 — State decal registry:** 在 `ToonAnimator` 增加状态贴片引用和可见性控制。
7. **C2 — State-specific overlays:** 为 run/jump/skid/stuck/bounce 添加少量表情或效果 decal。
8. **C3 — State tests:** 验证状态切换时对应 decal 可见性正确。

## Non-Goals

- 不制作完整 player 动作 sprite sheet。
- 不替换 `ToonAnimator`。
- 不新增 inventory/equipment gameplay。
- 不改变 collision、movement physics、surface profiles。
- 不把 UI/item sheet 强行用于 gameplay 角色主体。

## Validation Plan

方案 B 完成后检查：

- `Player.tscn` 仍有核心 procedural nodes：`Body`、`Head`、四肢、双脚、`Head/Eyes`。
- 新 decal 节点只作为 children/overlay 存在。
- UI/item sheet 覆盖 portrait、helmet、glove、boot、pickaxe、lantern、mine cart。
- gameplay 下 player 比当前更接近 `player_profile.png`，同时运动反馈不变。

方案 C 追加后检查：

- `ToonAnimator` 根据 movement state 控制 state decal。
- 状态贴片增强 run/jump/skid/stuck/bounce，不影响主轮廓。
- B 的资产和节点结构继续保留。

# Player 显示方案研究发现

## 图片资源
- `docs/assets/player_concept.png`：概念图。
- `docs/assets/player_profile.png`：正侧背视图与道具参考。

## `player_concept.png` 视觉发现
- 角色是复古 rubber-hose 矿工，整体为 1930s 卡通动画风格。
- 轮廓重点：大圆头、短小躯干、巨大手套、巨大靴子、细长弹簧四肢。
- 身份识别：矿工头盔、头灯、背带裤、矿洞、矿车、灯笼、标语等。
- 运动暗示：弹簧手脚适合表现弹跳、伸缩、攀爬、挥手、落地缓冲。
- 显示要求：远距离也要保留大头、头灯、手套、靴子、弹簧肢体这些核心轮廓。

## `player_profile.png` 视觉发现
- 正、侧、背视图比例一致：大头、小身体、弹簧四肢、超大手套与工作靴。
- 服装基准：棕色矿工帽 + 圆形头灯、奶油色上衣、深蓝背带裤、黄色纽扣、白手套、棕色厚底靴。
- 背面必须体现：交叉背带、后袋、帽子结构、头发轮廓、弹簧四肢。
- 侧面必须体现：突出的头灯、鼻子、单眼轮廓、张嘴笑容、靴底形状。
- 道具包括：头盔、手套、靴子、镐、灯笼、矿车；需保持同样粗描边、暖色矿洞调色与简洁高识别造型。

## 初步设计方向
- 角色显示应从“普通角色 sprite”升级为“可分层的角色展示系统”：身体核心、弹簧四肢、装备道具、方向视图、表情/头灯效果分开定义。
- 场景内小尺寸显示优先级：轮廓 > 头灯 > 弹簧肢体 > 手套/靴子 > 服装细节。
- UI/文档展示可使用更完整的三视图与道具陈列。

## 项目现状发现
- 当前 `scenes/Player.tscn` 是 `CharacterBody2D` 根节点，玩法稳定层包含 `CollisionShape2D`、`SurfaceSensor`、`Camera2D`、`AnimationPlayer`、`AnimationTree`。
- `VisualRoot` 位于 `Player` 下，挂载 `scripts/player/toon_animator.gd`，所有角色形变都在 visual 层发生。
- `Player.tscn` 已有 `FrontDeco` 与 `SideDeco`：前者用于正面手套、弹簧、背带裤等装饰；后者用于侧面弹簧、手套、侧视装饰。
- `toon_animator.gd` 已定义 `enum View { FRONT, SIDE }`，并缓存 front/side 两套基础几何与头部装饰位置。
- `toon_animator.gd` 根据 `player.velocity`、`movement_state`、surface visual multipliers、impact signal 做 squash/stretch、lean、limb swing、eye expression、front/side switching 和 mirror。
- 既有 spec `2026-05-08-vintage-miner-character-redesign.md` 明确选择 hybrid character system：保留 procedural anchors，增加轻量装饰 overlay；不要用完整导入 sprite sheet 替换角色。
- 既有 side-view plan 明确方向视图规则：idle/land/bounce 可正面，run/jump/fall/skid/stuck 应偏侧视或方向视。

## 对新方案的影响
- 新方案应延续当前架构，而不是推翻为全 sprite-sheet。
- `player_profile.png` 中的正/侧/背三视图可以转化为显示规范：正面 idle/展示、侧面移动、背面用于文档/未来攀爬或背向动作。
- `player_profile.png` 的道具行目前没有对应 inventory 系统，应先作为视觉字典和 UI icon 规范，而不是立即扩展玩法系统。

## 局部 sprite/decal 增强方向
- 适合使用 sprite/decal 的部位：表情贴片、头灯玻璃/高光、头盔划痕、手套掌纹/指缝、靴底纹、背带裤补丁/布料磨损、局部 film grain。
- 不适合使用 sprite/decal 替换的部位：`Body`、`Head`、`LeftArm`、`RightArm`、`LeftLeg`、`RightLeg`、`LeftFoot`、`RightFoot` 等核心动画锚点。
- UI 层适合更完整的 sprite 图：player portrait、道具 icon、装备图标、状态栏头像；这些不影响 gameplay animation。
- 局部增强的成功标准：角色更接近参考图完成度，但 `ToonAnimator` 的 squash/stretch、side mirroring、surface visual response 仍然保留。

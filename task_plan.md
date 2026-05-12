# Player 显示方案重规划任务计划

## 目标
基于 `docs/assets/player_concept.png`（概念图）与 `docs/assets/player_profile.png`（正侧背视图 + 道具），重新规划 player 的显示方案，使后续实现能统一角色比例、方向视图、道具展示、动画可读性与游戏内 UI/场景呈现。

## 当前阶段
- 阶段 1：恢复/创建规划上下文 — complete
- 阶段 2：理解图片与项目现状 — complete
- 阶段 3：澄清方案偏好与呈现范围 — complete（按完整 player 显示体系覆盖：场景角色、方向视图、道具展示、UI 缩略显示）
- 阶段 4：提出 2-3 套显示方案 — complete
- 阶段 5：整理并写入正式设计文档 — complete
- 阶段 6：按“局部 sprite/decal 增强”重新收束方案 — complete
- 阶段 7：将 B/C 阶段方案写入文档 — complete

## 约束与决策
- 先做方案规划，不直接修改 player 实现。
- 以图片中的 rubber-hose 矿工为视觉基准。
- 需要保留：大头、小躯干、弹簧四肢、白手套、厚靴、矿工头盔头灯、蓝色背带裤、暖色矿工道具。
- 后续方案必须兼顾游戏内小尺寸可读性。
- 保持现有 hybrid procedural 方案：`Player.tscn` 的 `VisualRoot`、`FrontDeco`、`SideDeco` 与 `ToonAnimator` 继续承担显示逻辑。
- 不改 `player_controller.gd`、碰撞体、surface movement 逻辑；player 显示方案只影响视觉层。

## 待确认
- 用户是否认可推荐方向：分层三视图 hybrid player 显示系统。
- 用户追加方向：不做完整 sprite sheet，改为局部 sprite/decal 增强；需要确认局部增强范围。

## 局部增强初稿
- 主体仍由 `VisualRoot`、`ToonAnimator`、`Body/Head/Limbs/Feet` 程序节点驱动。
- sprite/decal 只用于：表情、头灯/头盔细节、手套掌纹、靴子纹理、背带裤布料磨损、UI portrait、道具 icon。
- 不使用 sprite sheet 替换完整 player 动作。

## 输出文件
- `docs/superpowers/specs/2026-05-12-player-display-replan.md`
- `docs/superpowers/specs/2026-05-12-player-local-sprite-decal-enhancement.md`

## 遇到的错误
| 错误 | 尝试次数 | 解决方案 |
|------|---------|----------|
| 无 | 0 | 无 |

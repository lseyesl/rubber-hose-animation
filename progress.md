# Player 显示方案重规划进度

## 2026-05-12
- 创建规划文件：`task_plan.md`、`findings.md`、`progress.md`。
- 确认目标图片存在于 `docs/assets/`：
  - `player_concept.png`
  - `player_profile.png`
- 使用图片分析提取 player 的核心视觉语言：rubber-hose 矿工、弹簧四肢、矿工装备、夸张手套/靴子、三视图与道具一致性。
- 已启动项目内探索任务，寻找现有 player 展示/动画/文档入口。
- 收到探索结果：主要入口为 `scenes/Player.tscn`、`scripts/player/toon_animator.gd`；既有方案已是 hybrid procedural + deco overlay。
- 核对 `Player.tscn`、`toon_animator.gd`、既有 miner redesign spec 与 side-view plan，确认新方案应作为现有体系的“显示规范升级”，不是重建角色系统。
- 写入 player 显示重规划文档：`docs/superpowers/specs/2026-05-12-player-display-replan.md`。
- 用户要求基于“局部增强”方案继续规划。
- 已将局部增强边界记录为：主角色 procedural 不替换，sprite/decal 只用于视觉贴片、UI portrait 与道具 icon。
- 用户确认先做 B：局部 decal + UI sprite sheet；如果效果不够再切到 C：动作关键帧 decal。
- 已写入 B/C 设计文档：`docs/superpowers/specs/2026-05-12-player-local-sprite-decal-enhancement.md`。
- 已提交前置规划/资源改动：
  - `85bbac2 Update player reference assets`
  - `85c1434 Add player display planning docs`
  - `18b5582 Add player planning progress records`
- 已按 TDD 实施 B 方案：先新增失败测试 `tests/task7_player_decal_sheet_checks.gd`，确认缺少 decal 和 UI sheet；再补 `Player.tscn` local decals 与 `scenes/ui/PlayerItemSheet.tscn`。
- 验证通过：`task3_player_checks.gd`、`task4_toon_animator_checks.gd`、`task5_readability_checks.gd`、`task6_miner_visual_checks.gd`、`task7_player_decal_sheet_checks.gd`、`godot --headless --quit`。
- 用户反馈 B 方案仍不满足：程序化主体会导致 player 与概念图差距过大；手、胳膊、头、眼睛、眉毛、嘴、躯干、腿等都应使用图片实现。
- 已新增 D 方案设计文档：`docs/superpowers/specs/2026-05-12-player-image-part-rig-redesign.md`。
- 已实施 D image-part rig：`Player.tscn` 的 Body/Head/Arms/Hands/Legs/Feet 改为 `Node2D` handles + `Sprite2D` image parts；`toon_animator.gd` 改为 transform-handle animator。
- 已验证：GDScript LSP 对 `toon_animator.gd`、`task6_miner_visual_checks.gd`、`task7_player_decal_sheet_checks.gd` 无诊断；Godot task3-task7 与 headless quit 全部通过。

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

# Heads Off Party (Head, Your Majesty)

**GitHub**: https://github.com/yanlinyi101/head-your-majesty

单场景高密度物理派对小品 — 四个没头角色在革命后的巴黎广场抢各种脑袋，戴上"国王头"坚持最久者获胜。

- 引擎: Godot 4.6.2
- 语言: GDScript
- 当前阶段: Phase 1 graybox 原型（1 玩家 vs 1 BOT）

## Phase 1 验证

```powershell
# 跑 headless 测试
godot --headless --path "." -s res://tests/test_runner.gd

# 启动交互
godot --path "."
```

详见：
- 项目背景: [docs/project-brief.md](docs/project-brief.md)
- 详细规格: [docs/project-spec.md](docs/project-spec.md)
- Phase 1 实现计划: [docs/superpowers/plans/2026-05-16-heads-off-party-phase1.md](docs/superpowers/plans/2026-05-16-heads-off-party-phase1.md)
- 手动冒烟清单: [docs/phase1-playtest-checklist.md](docs/phase1-playtest-checklist.md)

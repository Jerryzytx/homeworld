# Homeworld · 家机小世界

一个以 AI 为主要玩家的持久化生活模拟小世界。

## Current Status

- Batch 3A — SEALED
- Batch 3B — SEALED
- Batch 3C — SEALED
- Batch 3D Rest / Sleep — SEALED
- Batch 3C.1 Achievement Hotfix — IN REVIEW
- Cloudflare deployment — HOLD

## Production Baseline

当前公开基线：

- `homeworld-batch3c-worker.txt`
- `homeworld-init.sql`

真实生产环境运行于 Cloudflare Worker + D1。

## Important Rules

- 世界离线时暂停，不跟现实时间流逝
- 游戏日边界为 05:00
- `sleep` = 睡到下一个尚未到达的 05:00
- `home_gpt` 由 `work_gpt` 与 `chat_gpt` 共用
- `mouse` 为只读观察者
- `/watch` 必须保持严格只读
- 所有真实 mutation 使用 revision claim + request idempotency

## Known Issues

### #001 Achievement unlock paths

以下成就已在数据库中定义，但当前 Batch 3C baseline 缺少解锁路径：

- `first_ss`
- `first_trophy`
- `codex_6`
- `codex_12`

正在 Batch 3C.1 中修复。

## Collaboration

- ChatGPT：架构、Frozen Spec、Review、Integration、Testing
- DeepSeek：Implementation、Independent Review
- Jerry：Product / World Design / Deployment

## Security

本仓库禁止提交：

- `ACCESS_TOKEN`
- API keys
- Cookies
- passwords
- `.env` secrets
- 真实 D1 数据库导出

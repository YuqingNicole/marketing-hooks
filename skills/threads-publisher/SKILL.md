---
name: threads-publisher
description: Publish posts and threads to Threads (Meta) via the official Threads API. Use when Nicole wants to post content to Threads, write a single post, create a multi-post thread, or ask for help with Threads content strategy and writing tips. Triggers on phrases like "发 Threads"、"post to Threads"、"发帖"、"写一条 thread"、"thread 内容"、"Threads 文案".
---

# Threads Publisher

## Config Location

Token and credentials: `~/.openclaw/threads/config.json`

```json
{
  "app_id": "992270066570020",
  "user_id": "26308861195437268",
  "access_token": "...",
  "expires_at": "2026-06-02"
}
```

Token expires every 60 days. To refresh:
```bash
curl -s "https://graph.threads.net/refresh_access_token?grant_type=th_refresh_token&access_token=TOKEN"
```

---

## Publish Script

`~/.openclaw/workspace/scripts/threads_publish.sh`

```bash
# 单条
bash ~/.openclaw/workspace/scripts/threads_publish.sh "内容"

# Thread（多条串联）
bash ~/.openclaw/workspace/scripts/threads_publish.sh "第1条" "第2条" "第3条"
```

---

## Workflow

1. **Write** — draft content based on Nicole's topic
2. **Preview** — show Nicole the full draft before publishing
3. **Confirm** — only publish after Nicole says "发吧" / "post it" / "ok"
4. **Publish** — run the script, share the post link

Never publish without explicit confirmation.

---

## Content Tips

See `references/threads-tips.md` for Threads writing best practices and content strategy.

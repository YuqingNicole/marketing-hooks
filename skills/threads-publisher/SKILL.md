---
name: threads-publisher
description: Publish posts and threads to Threads (Meta), analyze post performance, track account insights, and research competitor/inspiration accounts. Use when Nicole wants to post content to Threads, write a single post, create a multi-post thread, review post analytics, check follower growth, or research what's performing well on Threads. Triggers on phrases like "发 Threads"、"post to Threads"、"发帖"、"写一条 thread"、"thread 内容"、"Threads 文案"、"看数据"、"帖子表现"、"粉丝增长"、"对标账号".
---

# Threads Publisher

## Config

Token and credentials: `~/.openclaw/threads/config.json`

```json
{
  "app_id": "992270066570020",
  "user_id": "26308861195437268",
  "access_token": "...",
  "expires_at": "2026-06-02",
  "scopes": "threads_basic,threads_content_publish,threads_manage_insights"
}
```

Token expires every 60 days. Refresh before expiry:
```bash
TOKEN=$(python3 -c "import json; print(json.load(open('$HOME/.openclaw/threads/config.json'))['access_token'])")
curl -s "https://graph.threads.net/refresh_access_token?grant_type=th_refresh_token&access_token=$TOKEN"
```

---

## 1. Publishing Posts

Script: `~/.openclaw/workspace/scripts/threads_publish.sh`

```bash
# 单条
bash ~/.openclaw/workspace/scripts/threads_publish.sh "内容"

# Thread（多条串联，按顺序回复）
bash ~/.openclaw/workspace/scripts/threads_publish.sh "第1条" "第2条" "第3条"
```

**Workflow（必须遵守）：**
1. 写草稿给 Nicole 预览
2. Nicole 说"发吧"才执行发布
3. 发布后返回帖子链接

For image posts, need a public image URL. Options: GitHub raw URL, Imgur, or any CDN.

---

## 2. Post Analytics

Read insights for any post:

```python
import urllib.request, json

TOKEN = json.load(open('/home/node/.openclaw/threads/config.json'))['access_token']

def get_post_insights(post_id):
    url = f"https://graph.threads.net/v1.0/{post_id}/insights?metric=views,likes,replies,reposts,quotes&access_token={TOKEN}"
    with urllib.request.urlopen(url) as r:
        data = json.loads(r.read())['data']
    return {x['name']: x['values'][0]['value'] for x in data}
```

---

## 3. Account Insights

Track overall account performance (views, likes, replies, reposts, quotes, followers):

```bash
TOKEN=$(python3 -c "import json; print(json.load(open('$HOME/.openclaw/threads/config.json'))['access_token'])")
USER_ID="26308861195437268"

# 最近7天
curl -s "https://graph.threads.net/v1.0/$USER_ID/threads_insights\
?metric=views,likes,replies,reposts,quotes,followers_count\
&period=day\
&since=$(date -d '7 days ago' +%s)\
&until=$(date +%s)\
&access_token=$TOKEN"
```

Available periods: `day`, `week`, `month`

---

## 4. Read Any Public Account

Scrape public Threads profiles via Jina Reader (no auth needed):

```bash
curl -s "https://r.jina.ai/https://www.threads.net/@USERNAME" | head -200
```

Useful for: competitor analysis, trend spotting, content inspiration.

---

## 5. Delete a Post

```bash
TOKEN=$(python3 -c "import json; print(json.load(open('$HOME/.openclaw/threads/config.json'))['access_token'])")
curl -s -X DELETE "https://graph.threads.net/v1.0/POST_ID?access_token=$TOKEN"
```

---

## Content Tips

See `references/threads-tips.md` for writing best practices, content formats, and Nicole's proven content strategy based on actual post performance data.

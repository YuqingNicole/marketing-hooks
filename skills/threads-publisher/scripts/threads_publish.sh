#!/bin/bash
# Threads 发帖脚本
# 用法:
#   单条: ./threads_publish.sh "你的内容"
#   Thread: ./threads_publish.sh "第一条" "第二条" "第三条"

CONFIG="$HOME/.openclaw/threads/config.json"
TOKEN=$(python3 -c "import json; d=json.load(open('$CONFIG')); print(d['access_token'])")
USER_ID=$(python3 -c "import json; d=json.load(open('$CONFIG')); print(d['user_id'])")

if [ -z "$TOKEN" ] || [ -z "$USER_ID" ]; then
  echo "❌ 找不到 token，请检查 ~/.openclaw/threads/config.json"
  exit 1
fi

if [ $# -eq 0 ]; then
  echo "用法: $0 \"内容1\" [\"内容2\"] [\"内容3\"] ..."
  exit 1
fi

posts=("$@")
count=${#posts[@]}

echo "📋 准备发布 $count 条内容："
echo "---"
for i in "${!posts[@]}"; do
  echo "[$((i+1))/$count] ${posts[$i]}"
  echo "---"
done

# 创建单条帖子
create_post() {
  local text="$1"
  local reply_to="$2"

  if [ -n "$reply_to" ]; then
    curl -s -X POST "https://graph.threads.net/v1.0/$USER_ID/threads" \
      -d "text=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$text'''))")" \
      -d "media_type=TEXT" \
      -d "reply_to_id=$reply_to" \
      -d "access_token=$TOKEN"
  else
    curl -s -X POST "https://graph.threads.net/v1.0/$USER_ID/threads" \
      --data-urlencode "text=$text" \
      -d "media_type=TEXT" \
      -d "access_token=$TOKEN"
  fi
}

# 发布帖子
publish_post() {
  local creation_id="$1"
  curl -s -X POST "https://graph.threads.net/v1.0/$USER_ID/threads_publish" \
    -d "creation_id=$creation_id" \
    -d "access_token=$TOKEN"
}

echo "🚀 开始发布..."
echo ""

first_post_id=""
prev_post_id=""

for i in "${!posts[@]}"; do
  text="${posts[$i]}"
  num=$((i+1))

  echo -n "[$num/$count] 创建帖子..."

  if [ $i -eq 0 ]; then
    result=$(create_post "$text" "")
  else
    result=$(create_post "$text" "$prev_post_id")
  fi

  creation_id=$(echo "$result" | python3 -c "import sys,json; print(json.load(sys.stdin).get('id',''))")

  if [ -z "$creation_id" ]; then
    echo "❌ 失败"
    echo "错误: $result"
    exit 1
  fi

  echo -n " 发布..."
  pub_result=$(publish_post "$creation_id")
  post_id=$(echo "$pub_result" | python3 -c "import sys,json; print(json.load(sys.stdin).get('id',''))")

  if [ -z "$post_id" ]; then
    echo "❌ 发布失败"
    echo "错误: $pub_result"
    exit 1
  fi

  echo "✅ 成功 (ID: $post_id)"

  if [ $i -eq 0 ]; then
    first_post_id="$post_id"
  fi
  prev_post_id="$post_id"

  # Thread 条之间稍等一下
  if [ $i -lt $((count-1)) ]; then
    sleep 1
  fi
done

echo ""
echo "🎉 发布完成！"
if [ $count -gt 1 ]; then
  echo "🔗 Thread 首条链接: https://www.threads.net/post/$first_post_id"
else
  echo "🔗 链接: https://www.threads.net/post/$first_post_id"
fi

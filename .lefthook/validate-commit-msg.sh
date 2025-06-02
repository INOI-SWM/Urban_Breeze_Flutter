#!/bin/bash

commit_msg=$(cat "$1")

types="feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert|design"
jira_pattern="\[INOI-[0-9]+\]"

clean_message() {
  echo "$1" | sed '/^#/d' | sed '/^\s*$/d'
}

commit_msg=$(clean_message "$commit_msg")

if [[ ! "$commit_msg" =~ ^($types):\  ]]; then
  echo "❌ 커밋 메시지는 다음 형식을 따라야 합니다: 'type: 설명' (예: feat: 메시지 내용)"
  echo "   사용 가능한 타입: $types"
  exit 1
fi

if [[ "$commit_msg" =~ ^($types):\ $jira_pattern\  ]]; then
  if [[ ! "$commit_msg" =~ ^($types):\ $jira_pattern\ .+ ]]; then
    echo "❌ 지라 코드 '[INOI-123]' 뒤에 메시지 요약이 필요합니다."
    exit 1
  fi
else
  if [[ ! "$commit_msg" =~ ^($types):\ .+ ]]; then
    echo "❌ 커밋 메시지에 메시지 요약이 포함되어야 합니다."
    exit 1
  fi
fi

echo "✅ 커밋 메시지 검사 통과"
exit 0

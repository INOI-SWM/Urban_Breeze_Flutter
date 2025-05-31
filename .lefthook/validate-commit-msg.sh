#!/bin/bash
commit_msg=$(cat "$1")

remove_comments_and_empty_lines() {
    echo "$1" | sed '/^#/d' | sed '/^\s*$/d'
}

commit_msg=$(remove_comments_and_empty_lines "$commit_msg")

if [[ ! "$commit_msg" =~ ^(feat|fix|chore|docs|refactor|test|style): ]]; then
  echo "❌ 커밋 메시지의 타입이 올바르지 않습니다. (feat:, fix:, chore: 등)"
  exit 1
fi

if [[ "$commit_msg" =~ ^(feat|fix|chore|docs|refactor|test|style):\ \[INOI-[0-9]+\]\  ]]; then
  jira_code_present=true
else
  jira_code_present=false
fi

if $jira_code_present; then
  if [[ ! "$commit_msg" =~ ^(feat|fix|chore|docs|refactor|test|style):\ \[INOI-[0-9]+\]\ .+ ]]; then
    echo "❌ 지라 코드 '[INOI-123]' 뒤에 메시지 요약이 필요합니다."
    exit 1
  fi
else
  if [[ ! "$commit_msg" =~ ^(feat|fix|chore|docs|refactor|test|style):\ .+ ]]; then
    echo "❌ 커밋 메시지에 메시지 요약이 포함되어야 합니다."
    exit 1
  fi
fi

echo "✅ 커밋 메시지 검사 통과"
exit 0

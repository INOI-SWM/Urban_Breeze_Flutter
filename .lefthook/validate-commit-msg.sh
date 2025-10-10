#!/bin/bash



commit_msg=$(cat "$1")

# Release Please 권장 타입
types="feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert"

clean_message() {
  echo "$1" | sed '/^#/d' | sed '/^\s*$/d'
}

commit_msg=$(clean_message "$commit_msg")

# Jira 티켓 포함 (선택)
if [[ "$commit_msg" =~ ^($types)!?:\ \[.*\]\ .+ ]]; then
  if [[ ! "$commit_msg" =~ ^($types)!?:\ \[INOI-[0-9]+\]\ .+ ]]; then
    echo "❌ 지라 코드는 '[INOI-숫자]' 형식이어야 합니다."
    exit 1
  fi
# 일반 Conventional Commits (권장)
elif [[ "$commit_msg" =~ ^($types)!?:\ .+ ]]; then
  # Breaking change 체크
  if [[ "$commit_msg" =~ ^($types)!:\ .+ ]] || [[ "$commit_msg" =~ BREAKING\ CHANGE ]]; then
    echo "⚠️  Breaking Change 감지! Major 버전이 증가합니다."
  fi
  
  # 버전 증가 안내
  if [[ "$commit_msg" =~ ^feat:\ .+ ]]; then
    echo "📌 feat 커밋: Minor 버전이 증가합니다. (예: 1.0.0 → 1.1.0)"
  elif [[ "$commit_msg" =~ ^fix:\ .+ ]]; then
    echo "📌 fix 커밋: Patch 버전이 증가합니다. (예: 1.0.0 → 1.0.1)"
  fi
  
  echo "✅ 커밋 메시지 검사 통과"
else
  echo "❌ 커밋 메시지는 Conventional Commits 형식을 따라야 합니다."
  echo ""
  echo "형식: <type>: <설명>"
  echo ""
  echo "주요 타입:"
  echo "  feat:     새 기능 (Minor 버전↑)"
  echo "  fix:      버그 수정 (Patch 버전↑)"
  echo "  refactor: 리팩토링"
  echo "  perf:     성능 개선"
  echo "  docs:     문서"
  echo ""
  echo "예시:"
  echo "  feat: Garmin 연동 추가"
  echo "  fix: Provider 매칭 오류 수정"
  echo "  feat!: Breaking change"
  echo ""
  echo "자세한 내용: RELEASE_GUIDE.md"
  exit 1
fi

exit 0

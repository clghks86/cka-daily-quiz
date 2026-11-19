#!/usr/bin/env bash
# cka-daily-quiz 배포: 저장소 확인/생성 → push → GitHub Pages 활성화 → 접속 확인
# 사용법:  bash deploy.sh
set -uo pipefail

OWNER="clghks86"
REPO="cka-daily-quiz"
FULL="$OWNER/$REPO"
SITE="https://$OWNER.github.io/$REPO"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

say() { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
ok()  { printf '\033[1;32m  ✓\033[0m %s\n' "$*"; }
bad() { printf '\033[1;31m  ✗\033[0m %s\n' "$*"; }

cd "$DIR" || exit 1

# 0) 로그인 계정 확인
LOGIN="$(gh api user --jq .login 2>/dev/null)"
if [ "$LOGIN" != "$OWNER" ]; then
  bad "gh 로그인 계정이 '$LOGIN' 입니다. '$OWNER' 로 연결되어 있어야 합니다."
  exit 1
fi
ok "GitHub 로그인: $LOGIN"

# 1) 저장소 확인 / 생성
if gh repo view "$FULL" >/dev/null 2>&1; then
  ok "저장소가 이미 있습니다: https://github.com/$FULL"
else
  say "저장소 생성 시도: $FULL (public)"
  if out="$(gh api -X POST user/repos -f name="$REPO" \
        -f description="CKA daily study notes & interactive quiz (GitHub Pages)" \
        -F private=false -F has_issues=false -F has_wiki=false 2>&1)"; then
    ok "저장소 생성 완료"
  else
    bad "저장소를 만들 수 없습니다."
    echo "$out"
    cat <<'EOS'

  GitHub App 에 저장소 생성(Administration) 권한이 없는 상태입니다.
  다음 중 하나를 하면 이 스크립트를 그대로 다시 실행할 수 있습니다.

   A) github.com/new 에서 저장소 이름 'cka-daily-quiz', 공개(Public),
      README 추가 없이 생성 → bash deploy.sh 재실행   (가장 빠름)
   B) 앱의 GitHub 연결 설정에서 App 권한에 저장소 생성 허용
EOS
    exit 1
  fi

  # 생성 직후 API 반영 대기
  for i in $(seq 1 10); do
    gh repo view "$FULL" >/dev/null 2>&1 && break
    sleep 2
  done
fi

# 2) 커밋 & push
say "커밋 정리"
git rev-parse --git-dir >/dev/null 2>&1 || git init -q
git config user.name  "$(git config user.name  || echo "$OWNER")"
git config user.email "$(git config user.email || echo "$OWNER@users.noreply.github.com")"
git add -A
if ! git diff --cached --quiet; then
  git commit -q -m "CKA Daily Study — Day 01 (2026-11-19) etcd backup/restore & kubeadm upgrade"
  ok "새 커밋 생성"
else
  ok "변경 없음 (이미 커밋됨)"
fi
git branch -M main

REMOTE_URL="https://github.com/$FULL.git"
if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$REMOTE_URL"
else
  git remote add origin "$REMOTE_URL"
fi

say "push → origin/main"
if git push -u origin main 2>&1 | tail -3; then
  ok "push 완료"
else
  bad "push 실패. App 이 이 저장소에 접근할 수 있는지 확인하세요 (저장소 선택이 'Only select repositories' 라면 추가 필요)."
  exit 1
fi

# 3) GitHub Pages 활성화 (이미 켜져 있으면 그대로)
say "GitHub Pages 설정"
if gh api "repos/$FULL/pages" >/dev/null 2>&1; then
  ok "Pages 이미 활성화됨"
  gh api "repos/$FULL/pages" --jq '"  branch=\(.source.branch) path=\(.source.path) status=\(.status // "-")"'
else
  if gh api -X POST "repos/$FULL/pages" \
       -f "source[branch]=main" -f "source[path]=/" >/dev/null 2>&1; then
    ok "Pages 활성화 요청 완료 (main / root)"
  else
    bad "Pages 활성화 실패 — 저장소 Settings → Pages 에서 Source: Deploy from a branch, main / (root) 선택"
  fi
fi

# 4) 접속 확인 (최대 60초)
say "접속 확인 (최대 60초)"
for path in "/" "/2026-11-19.html"; do
  code=""
  for i in $(seq 1 20); do
    code="$(curl -s -o /dev/null -w '%{http_code}' -L --max-time 10 "$SITE$path")"
    [ "$code" = "200" ] && break
    sleep 3
  done
  if [ "$code" = "200" ]; then ok "HTTP 200  $SITE$path"
  else bad "HTTP $code  $SITE$path"; fi
done

echo
say "저장소: https://github.com/$FULL"
say "사이트 : $SITE"

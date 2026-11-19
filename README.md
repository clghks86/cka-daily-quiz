# CKA Daily Study & Interactive Quiz

매일 아침 10분, CKA(Certified Kubernetes Administrator) 5문항 인터랙티브 퀴즈.
회차마다 **단일 HTML 파일**로 완결되어 오프라인에서도 열립니다.

- 사이트: https://clghks86.github.io/cka-daily-quiz/
- 대시보드: `index.html`
- 회차 페이지: `YYYY-MM-DD.html`

## 구성

| 파일 | 설명 |
| --- | --- |
| `index.html` | 모바일 대시보드 — 최신 회차 바로가기 카드 + 회차별 링크 목록 |
| `2026-11-19.html` | Day 01 · Cluster Architecture — etcd 백업·복구 & kubeadm 클러스터 업그레이드 |
| `deploy.sh` | 저장소 생성 → push → GitHub Pages 활성화 → 접속 확인 |

## 회차 페이지에 들어가는 것

1. **이론 요약** — 접기/펼치기(`<details>`). 핵심 개념 + 시험에 나오는 명령어 정리, 코드 블록은 가로 스크롤.
2. **인터랙티브 퀴즈 (5문항)** — 한 번에 한 문항씩 카드로 표시, 보기를 고르면 즉시 정답·해설 확인, `다음 문제 →` 로 진행.
3. **결과 화면** — 총점(예: 80점 · 4/5), 정답/오답 수, 문제별 정오표, 오답 풀이 상세, `오답만 다시 풀기` / `전체 다시 풀기`.

순수 Vanilla HTML/CSS/JS. 외부 CDN·폰트·라이브러리 없음.

## 새 회차 추가하기

1. `2026-11-19.html` 을 복사해 날짜 파일명으로 저장
2. `<title>`, 상단 배지, 히어로 문구, `QS` 배열(문항·보기·정답·해설) 교체
3. `index.html` 의 회차 목록에 항목 추가 (`.row.active` → 이전 회차는 `.row.done` 처리)
4. `git add -A && git commit -m "Day 02" && git push`

퀴즈 데이터 구조:

```js
{
  n: 1,                        // 문항 번호
  tag: "etcd 백업",             // 주제 태그
  q: "질문 텍스트",
  code: "",                    // (선택) 질문 위에 보여 줄 코드 블록
  opts: [ { t: "보기 A" }, { t: "보기 B" }, { t: "보기 C" }, { t: "보기 D" } ],
  answer: 0,                   // 정답 인덱스 (0부터)
  why: "해설 텍스트",
  whyCode: ""                  // (선택) 해설 뒤 명령 흐름 코드 블록
}
```

## GitHub Pages

- 저장소 `clghks86/cka-daily-quiz` — **Public** (무료 Pages 조건)
- Source: `main` 브랜치 `/` (root), Jekyll 빌드 없이 정적 파일 그대로 서빙
- 배포 반영까지 보통 10~60초

## 로컬에서 보기

```bash
python3 -m http.server 8000   # http://localhost:8000
```

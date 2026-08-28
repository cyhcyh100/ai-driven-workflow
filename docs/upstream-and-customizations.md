# Upstream과 커스텀 범위

## 기준점

이 저장소의 최초 공개 commit은 2026-08-10에 작성됐습니다. 그 시점 이전의
`obra/superpowers` main 중 마지막 commit인
[`44c9b2d`](https://github.com/obra/superpowers/tree/44c9b2d6e889982ac18c27d05a19fefe335194e1)를
비교 기준으로 고정합니다.

이 문서의 목적은 번역, 운영 정책 변경, 그대로 가져온 코드를 구분하는 것입니다.
upstream 전체를 제가 작성한 것처럼 보이게 하지 않고, 실제로 판단하고 바꾼 부분을
검토할 수 있게 남깁니다.

## 그대로 가져온 파일

다음 파일은 기준 commit과 동일합니다.

- `skills/brainstorming/scripts/frame-template.html`
- `skills/brainstorming/scripts/helper.js`
- `skills/brainstorming/scripts/server.cjs`
- `skills/brainstorming/scripts/start-server.sh`
- `skills/brainstorming/scripts/stop-server.sh`

이 파일들은 visual companion이 동작하는 데 필요해서 함께 배포하며, 원 저작권과
MIT 라이선스는 루트 `LICENSE`에 보존합니다.

## 번역하거나 운영 정책을 바꾼 파일

다음 영역은 upstream 구조를 출발점으로 삼아 한국어로 옮기거나 개인 운영 규칙을
반영했습니다.

- `skills/brainstorming/`
- `skills/writing-plans/`
- `skills/subagent-driven-development/`

주요 변경은 다음과 같습니다.

1. 설계 승인과 spec 검토를 명시적인 사람의 gate로 유지
2. worktree를 기본값에서 제외하고 현재 workspace의 별도 branch 사용
3. 승인된 plan 실행 중 task 사이의 확인 질문 제거
4. 모델을 task 난이도가 아니라 실행/판단 역할로 배정
5. task brief, 구현 보고, diff package를 파일로 전달
6. progress ledger와 임시 산출물을 plan별 workspace에 격리
7. task reviewer가 spec 준수와 코드 품질을 한 번에 판정

## 이 저장소에서 별도로 추가한 문서와 스킬

- `skills/handoff/SKILL.md`
- `docs/ai-code-review-pipeline.md`
- `docs/how-i-work.md`
- 저장소의 README, 검증 스크립트와 테스트

`docs/ai-code-review-pipeline.md`는 사내 구현을 복제한 것이 아니라, 공개 가능한
설계 판단만 다시 정리한 문서입니다.

## 업데이트 원칙

upstream을 갱신할 때는 다음 순서를 따릅니다.

1. 기준 commit을 이 문서와 `THIRD_PARTY_NOTICES.md`에 기록
2. 그대로 가져온 파일은 `cmp` 또는 checksum으로 동일성 확인
3. 커스텀 파일은 upstream diff를 읽고 운영 정책과 충돌하는 변경만 수동 반영
4. `scripts/verify.sh` 실행
5. 동작이나 정책이 바뀌었다면 README의 변경 표도 갱신

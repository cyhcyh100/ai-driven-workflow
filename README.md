# 저는 AI를 이렇게 사용합니다

Claude Code 세션 9개월치(2025-11 ~ 2026-08, 프롬프트 10,302건)를 분석해 정리한
작업 방식과, 그 방식을 실행하기 위해 만든 스킬 모음입니다.

한 줄로 요약하면 **실행은 위임하고 주장은 검증한다. 검증에서 배운 것은 규칙으로
남긴다.** 입니다. 전체 분석은
[저는 AI를 이렇게 사용합니다](docs/how-i-work.md)에 있습니다.

## 핵심 원칙 열 가지

10,302개의 프롬프트에서 반복적으로 나타난 패턴입니다.

| # | 원칙 | 한 줄 설명 |
| --- | --- | --- |
| 01 | 추측하지 않고 확인한다 | "가능성 있음"으로 결론 내지 않는다. 코드, 콘솔, DB에서 증거를 가져온다. |
| 02 | 구현 전에 계획, 계획 전에 조사 | 원인과 비용을 먼저 확인해야 "안 한다"는 결정도 가능하다. |
| 03 | 근본 원인만 수정한다 | lint disable, 임시 패치, 우회는 수정으로 치지 않는다. |
| 04 | 테스트 통과를 완료로 보지 않는다 | 실제 환경에서 실제 API를 호출해 확인한 것까지가 완료다. |
| 05 | 구현자와 리뷰어를 분리한다 | 구현자의 보고는 검증되지 않은 주장이다. 컨텍스트를 비운 에이전트가 검증한다. |
| 06 | 복잡성을 늘리지 않는다 | 최소 수정으로 해결하고, 주석에는 코드로 알 수 없는 이유만 남긴다. |
| 07 | 위임에는 사후 보고를 붙인다 | "알아서 진행해" 뒤에 "임의 결정 중 리스크 있던 것을 근거와 함께 보고해"를 붙인다. |
| 08 | 조용한 실패를 막는다 | 판단이 애매하면 fail-closed로 멈추고, 멈춘 이유를 보고하게 한다. |
| 09 | 실패를 규칙으로 남긴다 | 한 번 겪은 문제는 `CLAUDE.md`, memory, 스킬에 적어 재발을 막는다. |
| 10 | 글도 코드처럼 관리한다 | 독자에 맞춰 상세도를 조절하고, 과장하지 않고, 모르면 모른다고 쓴다. |

원칙마다 출처가 된 프롬프트 발췌는 [원칙의 근거](docs/how-i-work.md#원칙의-근거)에
있습니다.

## 표준 워크플로우

세션 하나가 티켓 생성부터 머지, 실환경 검증까지를 다룹니다. 세션당 사람 발화는
평균 7.7턴입니다.

```text
현황 파악
  → /jira                        티켓 생성
  → /writing-plans               계획을 파일로
  → /subagent-driven-development task별 구현자·리뷰어 분리 실행
  → /jira finish                 커밋 + PR
  → /molin-review-loop           AI 리뷰 봇이 approve할 때까지 반영·재리뷰
  → 머지
  → 실환경 검증                   실제 API 호출, 실제 결과 수신 확인
```

사람이 개입하는 지점은 요구사항 결정, 설계와 plan 승인, 최종 리뷰입니다. 승인된
plan을 실행하는 동안에는 task마다 확인을 요청하지 않고, 막힘이나 plan 모순이
발견됐을 때만 다시 판단을 요청합니다.

- **계획은 파일로 받는다.** 122개 세션에서 plan mode 승인은 0회입니다. 계획을
  `docs/superpowers/plans/*.md`로 쓰게 하고 에디터에서 직접 리뷰합니다.
- **병렬 세션은 저장소 복제로 만든다.** worktree 대신 저장소를 복제해 세션 5개를
  동시에 돌리고, 세션 간 인계는 `HANDOFF.md`로 합니다.
- **컨텍스트는 초기화하고 지식은 파일로 남긴다.** `/clear` 613회, `/compact`
  16회. 남길 지식은 `CLAUDE.md`, spec, plan, memory 파일로 옮깁니다.

## 숫자로 보는 9개월

| 지표 | 값 | 의미 |
| --- | ---: | --- |
| 입력한 프롬프트 | 10,302 | 2025-11-04 ~ 2026-08-07, 중복 제외 |
| plan / 계획 언급 | 1,464 | 구현 전에 계획을 요구한 횟수 |
| "확인해" | 675 | 검증을 요구한 횟수 |
| 세션당 사람 발화 | 7.7턴 | 지시 한 번으로 진행되는 자율 실행 구간이 길다 |
| 서브에이전트 호출 | 421 | 구현·수정 180회, 리뷰 143회 |
| plan mode 승인 | 0 | 계획을 파일로 받아 리뷰하기 때문에 쓰지 않는다 |
| 프로젝트별 memory 파일 | 105 | 실패에서 나온 규칙을 저장하는 곳 |
| 커스텀 스킬 | 15 | superpowers 포크 7 + 자작 8, git으로 버전 관리 |

진화 과정과 하네스 구성, 사례는 [docs/how-i-work.md](docs/how-i-work.md)에
정리했습니다.

## 이 저장소의 스킬

위 워크플로우를 실행하기 위해 쓰는 스킬 중 공개 가능한 것의 스냅샷입니다. 새로운
에이전트 프레임워크를 주장하지 않습니다. Jesse Vincent(obra)의
[superpowers](https://github.com/obra/superpowers)를 실제 작업에 적용하면서 바꾼
규칙과, 사내 AI 코드리뷰 플랫폼을 운영하며 내린 설계 판단을 공개 가능한 범위에서
정리했습니다. 기준으로 삼은 upstream은
[`44c9b2d`](https://github.com/obra/superpowers/tree/44c9b2d6e889982ac18c27d05a19fefe335194e1)입니다.

- [brainstorming](skills/brainstorming/SKILL.md): 구현 전에 요구사항과 설계를
  검증합니다. 시각적 비교가 필요한 경우에만 로컬 브라우저 companion을 사용합니다.
- [writing-plans](skills/writing-plans/SKILL.md): 확정된 spec을 독립적으로 실행
  가능한 task와 테스트 단계로 변환합니다.
- [subagent-driven-development](skills/subagent-driven-development/SKILL.md): task별
  implementer와 reviewer를 분리하고 파일 기반으로 컨텍스트를 전달합니다.
- [handoff](skills/handoff/SKILL.md): 성공한 경로뿐 아니라 실패한 접근과 다음
  행동까지 `HANDOFF.md`에 남깁니다.
- [AI 코드리뷰 파이프라인 설계](docs/ai-code-review-pipeline.md): 사내 플랫폼에서
  리뷰어 분리, 오탐 판정, 재리뷰 중복 억제를 설계한 이유를 정리합니다.

### upstream 대비 바꾼 운영 규칙

| 영역 | 이 저장소의 선택 | 이유 |
| --- | --- | --- |
| 작업 공간 | worktree 대신 현재 workspace의 별도 브랜치 사용 | 작은 개인 프로젝트에서 생기는 전환 비용을 줄이기 위해 |
| 실행 흐름 | task 사이의 확인 질문 제거 | 승인된 plan은 중간 대기 없이 끝까지 실행하기 위해 |
| 모델 배정 | 난이도 추정 대신 실행/판단 역할로 tier 고정 | task별 난이도 예측의 편차를 없애고 비용을 통제하기 위해 |
| 컨텍스트 전달 | task brief, 구현 보고, diff package를 파일로 전달 | 긴 dispatch와 대화 compaction으로 인한 정보 손실을 줄이기 위해 |
| 진행 복구 | plan별 progress ledger 기록 | 세션이 끊겨도 완료 task를 중복 실행하지 않기 위해 |
| 리뷰 | task마다 spec 준수와 코드 품질을 함께 판정 | 과소 구현과 과잉 구현을 코드 품질 문제와 동시에 잡기 위해 |

구체적인 upstream 대비 파일 구분은
[upstream-and-customizations.md](docs/upstream-and-customizations.md)에 적었습니다.

### 설치와 전제

Claude Code는 개인 스킬을 `~/.claude/skills/<name>/SKILL.md`, 프로젝트 스킬을
`.claude/skills/<name>/SKILL.md`에서 읽습니다.

```bash
git clone https://github.com/cyhcyh100/ai-driven-workflow.git
cd ai-driven-workflow
mkdir -p ~/.claude/skills
cp -R skills/brainstorming skills/writing-plans \
  skills/subagent-driven-development skills/handoff ~/.claude/skills/
```

필요한 실행 환경은 Git, Bash, Node.js 18 이상입니다. 전체 개발 흐름에는 이
저장소에 포함하지 않은 upstream 스킬도 필요합니다.

- `test-driven-development`
- `requesting-code-review`
- `finishing-a-development-branch`
- `executing-plans`를 대안 실행기로 사용할 경우 해당 스킬

누락된 의존성은 같은 기준 commit의
[superpowers skills](https://github.com/obra/superpowers/tree/44c9b2d6e889982ac18c27d05a19fefe335194e1/skills)에서
확인할 수 있습니다.

### 검증

```bash
scripts/verify.sh
```

검증 스크립트는 Bash와 Node.js 문법, plan별 SDD workspace와 ledger 격리, task
brief와 review package 생성, brainstorming server의 WebSocket helper, Markdown
내부 링크를 확인합니다.

## 공개 범위와 한계

- 사내 AI 코드리뷰 플랫폼의 프롬프트와 구현은 회사 자산이라 공개하지 않습니다.
  문서에는 재사용 가능한 설계 판단만 담았습니다.
- 회사 데이터로 측정한 오탐률이나 비용 수치는 공개하지 않았습니다. 세션 분석의
  숫자는 제 프롬프트 기록에서 나온 것이고, 회사 프로젝트명은 일반화했습니다.
- 모델 이름과 사용 가능 tier는 실행 환경에 종속됩니다. 모델 정책의 핵심은 특정
  제품명이 아니라 실행 역할과 판단 역할을 분리하는 데 있습니다.

## 라이선스와 출처

upstream에서 가져온 부분과 수정한 부분 모두 루트 [LICENSE](LICENSE)의 MIT
라이선스를 따릅니다. 원본 저작권과 파일별 출처는
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)에 기록했습니다.

# AI와 일하는 방식

Claude Code를 설계, 구현, 리뷰, 인계가 이어지는 개발 프로세스로 운영하기 위해
사용하는 스킬 모음입니다.

이 저장소는 Jesse Vincent(obra)의
[superpowers](https://github.com/obra/superpowers)를 실제 작업에 적용하면서 바꾼
규칙과 직접 만든 스킬을 공개 가능한 범위에서 정리한 것입니다. 비교 기준은
[`44c9b2d`](https://github.com/obra/superpowers/tree/44c9b2d6e889982ac18c27d05a19fefe335194e1)입니다.

## 작업 흐름

```text
요구사항 확인
  → brainstorming: 질문과 대안 비교, 설계 승인
  → writing-plans: 파일·인터페이스·테스트 단위로 계획 작성
  → subagent-driven-development: task별 구현과 독립 리뷰
  → 최종 브랜치 리뷰
  → handoff: 다음 세션에 결정 사항과 실패한 접근 전달
```

사람은 요구사항과 설계, 구현 계획, 최종 변경을 승인합니다. 승인된 계획을 실행할
때는 task마다 확인을 요청하지 않습니다. 대신 계획과 실제 코드가 충돌하거나
되돌리기 어려운 결정이 필요한 경우에는 실행을 멈추고 판단을 요청합니다.

이 흐름을 정한 배경과 실제 운영 사례는
[AI 코딩 에이전트 운영 방식](docs/how-i-work.md)에 정리했습니다.

## 운영 규칙

| 영역 | 선택 | 이유 |
| --- | --- | --- |
| 작업 공간 | worktree 대신 현재 workspace의 별도 브랜치 사용 | 작은 개인 프로젝트에서 생기는 전환 비용을 줄이기 위해 |
| 실행 흐름 | task 사이의 확인 질문 제거 | 승인된 계획은 중간 대기 없이 실행하기 위해 |
| 모델 배정 | 난이도 추정 대신 실행·판단 역할로 tier 고정 | task별 난이도 예측의 편차를 줄이고 비용을 통제하기 위해 |
| 컨텍스트 전달 | task brief, 구현 보고, diff package를 파일로 전달 | 긴 작업과 대화 압축 과정에서 생기는 정보 손실을 줄이기 위해 |
| 진행 복구 | 계획별 progress ledger 기록 | 세션이 끊겨도 완료한 task를 다시 실행하지 않기 위해 |
| 리뷰 | task마다 spec 준수와 코드 품질을 함께 판정 | 과소·과잉 구현과 코드 품질 문제를 한 번에 확인하기 위해 |

upstream 파일과 직접 수정한 파일의 구분은
[Upstream과 커스텀 범위](docs/upstream-and-customizations.md)에서 확인할 수 있습니다.

## 포함된 스킬과 문서

- [brainstorming](skills/brainstorming/SKILL.md): 구현 전에 요구사항과 설계를
  검토합니다. 시각적 비교가 필요할 때만 로컬 브라우저 companion을 사용합니다.
- [writing-plans](skills/writing-plans/SKILL.md): 확정된 spec을 독립적으로 실행할
  수 있는 task와 테스트 단계로 변환합니다.
- [subagent-driven-development](skills/subagent-driven-development/SKILL.md):
  task별 implementer와 reviewer를 분리하고 파일로 컨텍스트를 전달합니다.
- [handoff](skills/handoff/SKILL.md): 결정 사항, 실패한 접근, 다음 행동을
  `HANDOFF.md`에 남깁니다.
- [AI 코드리뷰 파이프라인 설계](docs/ai-code-review-pipeline.md): 사내 플랫폼에서
  리뷰어 분리, 오탐 판정, 재리뷰 중복 억제를 선택한 이유를 설명합니다.
- [AI 코딩 에이전트 운영 방식](docs/how-i-work.md): 9개월간의 세션 기록을 바탕으로
  현재 작업 흐름과 그 배경을 설명합니다.

## 설치

이 저장소는 완결된 Claude Code plugin이 아니라 개인 환경에서 사용하는 스킬의
스냅샷입니다. Claude Code는 개인 스킬을 `~/.claude/skills/<name>/SKILL.md`,
프로젝트 스킬을 `.claude/skills/<name>/SKILL.md`에서 읽습니다.

```bash
git clone https://github.com/cyhcyh100/ai-driven-workflow.git
cd ai-driven-workflow
mkdir -p ~/.claude/skills
cp -R skills/brainstorming skills/writing-plans \
  skills/subagent-driven-development skills/handoff ~/.claude/skills/
```

Git, Bash, Node.js 18 이상이 필요합니다. 전체 개발 흐름에는 이 저장소에 포함하지
않은 다음 upstream 스킬도 필요합니다.

- `test-driven-development`
- `requesting-code-review`
- `finishing-a-development-branch`
- `executing-plans`를 대안 실행기로 사용할 경우 해당 스킬

누락된 의존성은 같은 기준 commit의
[superpowers skills](https://github.com/obra/superpowers/tree/44c9b2d6e889982ac18c27d05a19fefe335194e1/skills)에서
확인할 수 있습니다.

## 검증

```bash
scripts/verify.sh
```

검증 스크립트는 다음 항목을 확인합니다.

- Bash와 Node.js 문법
- 계획별 SDD workspace와 ledger 격리
- task brief와 review package 생성
- brainstorming server의 WebSocket helper
- Markdown 내부 링크

## 공개 범위와 한계

- 사내 AI 코드리뷰 플랫폼의 프롬프트와 구현은 포함하지 않았습니다. 문서에는
  공개 가능한 설계 판단만 담았습니다.
- 회사 데이터로 측정한 오탐률, 비용, 처리량은 공개하지 않았습니다. 이 저장소의
  문서는 성능 benchmark가 아닙니다.
- 세션 분석에 사용한 원본 기록은 공개하지 않았습니다. 문서에 제시한 수치는 작업
  규모와 사용 패턴을 설명하기 위한 것이며, 방식의 효과를 입증하는 지표가 아닙니다.
- 모델 이름과 사용 가능한 tier는 실행 환경에 따라 달라집니다. 여기서 설명하는
  모델 정책은 특정 제품보다 실행 역할과 판단 역할의 분리에 초점을 둡니다.

## 라이선스와 출처

upstream에서 가져온 부분과 수정한 부분 모두 루트 [LICENSE](LICENSE)의 MIT
라이선스를 따릅니다. 원본 저작권과 파일별 출처는
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)에 기록했습니다.

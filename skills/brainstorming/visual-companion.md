# 비주얼 컴패니언 가이드

목업, 다이어그램, 옵션을 보여주기 위한 브라우저 기반 비주얼 브레인스토밍 컴패니언.

## 언제 쓰는가

세션 단위가 아니라 질문 단위로 판단한다. 기준: **읽는 것보다 보는 것이 이해에 더 나은가?**

**브라우저 사용** — 내용 자체가 시각적일 때:

- **UI 목업** — 와이어프레임, 레이아웃, 내비게이션 구조, 컴포넌트 디자인
- **아키텍처 다이어그램** — 시스템 컴포넌트, 데이터 흐름, 관계 맵
- **시각적 나란히 비교** — 두 레이아웃, 두 컬러 스킴, 두 디자인 방향 비교
- **디자인 다듬기** — 룩앤필, 간격, 시각적 위계에 관한 질문일 때
- **공간적 관계** — 다이어그램으로 그린 상태 머신, 플로우차트, 엔티티 관계

**터미널 사용** — 내용이 텍스트나 표일 때:

- **요구사항·범위 질문** — "X가 무슨 뜻인가요?", "어떤 기능이 범위에 들어가나요?"
- **개념적 A/B/C 선택** — 말로 설명된 접근 방식 중 고르기
- **트레이드오프 목록** — 장단점, 비교 표
- **기술적 결정** — API 설계, 데이터 모델링, 아키텍처 접근 방식 선택
- **명확화 질문** — 답이 시각적 선호가 아니라 말인 모든 것

UI 주제에 *관한* 질문이라고 자동으로 시각적 질문이 되는 건 아니다. "어떤 종류의 위저드를 원하세요?"는 개념적 — 터미널을 쓴다. "이 위저드 레이아웃들 중 어느 게 맞는 느낌인가요?"는 시각적 — 브라우저를 쓴다.

## 동작 방식

서버가 디렉토리를 감시하며 가장 최근 HTML 파일을 브라우저에 서빙한다. `screen_dir`에 HTML 콘텐츠를 쓰면 사용자가 브라우저에서 보고 클릭으로 옵션을 선택할 수 있다. 선택은 `state_dir/events`에 기록되고, 다음 턴에 읽으면 된다.

**콘텐츠 fragment vs 전체 문서:** HTML 파일이 `<!DOCTYPE`이나 `<html`로 시작하면 서버는 그대로 서빙한다 (helper 스크립트만 주입). 그렇지 않으면 서버가 자동으로 프레임 템플릿으로 감싼다 — 헤더, CSS 테마, 연결 상태, 모든 인터랙티브 인프라를 추가한다. **기본적으로 콘텐츠 fragment를 작성한다.** 페이지를 완전히 제어해야 할 때만 전체 문서를 작성한다.

## 세션 시작

```bash
# Start AFTER the user approves the companion. --open auto-opens their browser on
# the first screen; --project-dir persists mockups and enables same-port restart.
scripts/start-server.sh --project-dir /path/to/project --open

# Returns: {"type":"server-started","port":52341,
#           "url":"http://localhost:52341/?key=ab12…",
#           "screen_dir":"/path/to/project/.superpowers/brainstorm/12345-1706000000/content",
#           "state_dir":"/path/to/project/.superpowers/brainstorm/12345-1706000000/state"}
```

응답에서 `screen_dir`과 `state_dir`을 저장해 둔다. `--open`을 쓰면 첫 화면을 push할 때 브라우저가 스스로 열린다 — 사용자에게 브라우저를 열어달라고 요청할 필요는 없지만, 폴백으로 URL은 공유해 둔다 (headless/원격 환경에서는 자동으로 열리지 않는다).

**URL에는 세션 키(`?key=…`)가 포함되어 있다.** 서버는 키가 없는 요청을 모두 거부하므로, 항상 `url` 필드의 **완전한** URL을 사용자에게 전달한다 — 쿼리 스트링을 떼거나 `http://host:port`만 건네지 않는다. 이 키가 HTTP와 WebSocket 접근을 막아주기 때문에, 엉뚱한 브라우저 탭이나 같은 네트워크의 다른 머신이 화면을 읽거나 이벤트를 주입할 수 없다. 첫 로드 이후에는 브라우저가 쿠키로 키를 기억하므로 새로고침과 `/files/*` 에셋은 키를 반복하지 않아도 동작한다.

**연결 정보 찾기:** 서버는 시작 시 JSON을 `$STATE_DIR/server-info`에 기록한다. 서버를 백그라운드로 띄워서 stdout을 잡지 못했다면 이 파일을 읽어 URL과 포트를 얻는다. `--project-dir`을 썼다면 `<project>/.superpowers/brainstorm/`에서 세션 디렉토리를 확인한다.

**참고:** 프로젝트 루트를 `--project-dir`로 넘겨야 목업이 `.superpowers/brainstorm/`에 유지되고 서버 재시작 후에도 살아남는다. 없으면 파일이 `/tmp`로 가서 정리 대상이 된다. `.superpowers/`가 `.gitignore`에 없다면 추가하라고 사용자에게 알려준다.

**플랫폼별 서버 실행:**

**Claude Code:**
```bash
# Default mode works — the script backgrounds the server itself.
scripts/start-server.sh --project-dir /path/to/project --open
```

Windows에서는 스크립트가 자동 감지해 포그라운드 모드로 전환된다 (툴 콜이 블로킹됨). Bash 툴 콜에 `run_in_background: true`를 사용해 서버가 대화 턴을 넘어 살아있게 하고, 다음 턴에 `$STATE_DIR/server-info`를 읽어 URL과 포트를 얻는다.

**Codex:**
```bash
# Codex reaps background processes. The script auto-detects CODEX_CI and
# switches to foreground mode. Run it normally — no extra flags needed.
scripts/start-server.sh --project-dir /path/to/project --open
```

**Copilot CLI:**
```bash
# Use --foreground and start the server via the bash tool with mode: "async"
# so the process survives across turns. Capture the returned shellId for
# read_bash / stop_bash if you need to interact with it later.
scripts/start-server.sh --project-dir /path/to/project --open --foreground
```

**기타 환경:** 서버는 대화 턴을 넘어 백그라운드에서 계속 실행되어야 한다. 환경이 detach된 프로세스를 정리해 버린다면, `--foreground`를 쓰고 플랫폼의 백그라운드 실행 메커니즘으로 커맨드를 실행한다.

브라우저에서 URL에 접근할 수 없다면 (원격/컨테이너 환경에서 흔함), loopback이 아닌 호스트로 바인딩한다:

```bash
scripts/start-server.sh \
  --project-dir /path/to/project \
  --host 0.0.0.0 \
  --url-host localhost
```

반환 JSON의 URL에 어떤 호스트명을 넣을지는 `--url-host`로 제어한다.

## 루프

1. **서버가 살아있는지 확인**한 뒤, `screen_dir`의 새 파일에 **HTML을 작성**한다:
   - **필수: URL을 언급하거나 화면을 push하기 전에 서버가 살아있는지 확인한다.** `$STATE_DIR/server-info`가 존재하고 `$STATE_DIR/server-stopped`가 없는지 확인한다. 서버가 내려갔다면 **같은 `--project-dir`**로 `start-server.sh`를 다시 실행해 재시작한다 — 같은 포트를 재사용하므로 사용자가 열어둔 탭이 알아서 재연결되고 (서버가 내려간 동안 "paused" 오버레이 표시), 새 URL을 보낼 필요가 없다. 서버는 4시간 유휴 후 자동 종료된다 (`--idle-timeout-minutes`로 조정 가능).
   - 의미 있는 파일명을 쓴다: `platform.html`, `visual-style.html`, `layout.html`
   - **파일명은 절대 재사용하지 않는다** — 화면마다 새 파일
   - 파일 생성 도구를 사용한다 — **cat/heredoc은 절대 쓰지 않는다** (터미널에 노이즈를 쏟아냄)
   - 서버는 가장 최근 파일을 자동으로 서빙한다

2. **사용자에게 무엇을 보게 될지 알려주고 턴을 끝낸다:**
   - URL을 다시 알려준다 (첫 단계만이 아니라 매 단계)
   - 화면에 뭐가 있는지 짧게 요약한다 (예: "홈페이지 레이아웃 옵션 3개를 띄웠습니다")
   - 터미널로 답해달라고 요청한다: "한번 보시고 의견 주세요. 원하시면 클릭해서 옵션을 선택하셔도 됩니다."

3. **다음 턴에** — 사용자가 터미널로 응답한 후:
   - `$STATE_DIR/events`가 있으면 읽는다 — 사용자의 브라우저 인터랙션(클릭, 선택)이 JSON lines로 담겨 있다
   - 사용자의 터미널 텍스트와 합쳐 전체 그림을 파악한다
   - 터미널 메시지가 주된 피드백이고, `state_dir/events`는 구조화된 인터랙션 데이터를 제공한다

4. **반복하거나 진행한다** — 피드백이 현재 화면을 바꾸면 새 파일을 쓴다 (예: `layout-v2.html`). 현재 단계가 검증된 뒤에만 다음 질문으로 넘어간다.

5. **터미널로 돌아갈 때는 화면을 비운다** — 다음 단계에 브라우저가 필요 없으면 (예: 명확화 질문, 트레이드오프 논의), 대기 화면을 push해 낡은 콘텐츠를 치운다:

   ```html
   <!-- filename: waiting.html (or waiting-2.html, etc.) -->
   <div style="display:flex;align-items:center;justify-content:center;min-height:60vh">
     <p class="subtitle">Continuing in terminal...</p>
   </div>
   ```

   대화가 이미 다음으로 넘어갔는데 사용자가 이미 결론난 선택지를 계속 보고 있는 상황을 막아준다. 다음 시각적 질문이 나오면 평소처럼 새 콘텐츠 파일을 push한다.

6. 끝날 때까지 반복한다.

## 콘텐츠 fragment 작성

페이지 안에 들어갈 콘텐츠만 작성한다. 서버가 자동으로 프레임 템플릿(헤더, 테마 CSS, 연결 상태, 모든 인터랙티브 인프라)으로 감싼다.

**최소 예시:**

```html
<h2>Which layout works better?</h2>
<p class="subtitle">Consider readability and visual hierarchy</p>

<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>Single Column</h3>
      <p>Clean, focused reading experience</p>
    </div>
  </div>
  <div class="option" data-choice="b" onclick="toggleSelect(this)">
    <div class="letter">B</div>
    <div class="content">
      <h3>Two Column</h3>
      <p>Sidebar navigation with main content</p>
    </div>
  </div>
</div>
```

이게 전부다. `<html>`도, CSS도, `<script>` 태그도 필요 없다. 전부 서버가 제공한다.

## 사용 가능한 CSS 클래스

프레임 템플릿이 콘텐츠에 쓸 수 있는 CSS 클래스를 제공한다:

### Options (A/B/C 선택)

```html
<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>Title</h3>
      <p>Description</p>
    </div>
  </div>
</div>
```

**다중 선택:** 컨테이너에 `data-multiselect`를 추가하면 여러 옵션을 선택할 수 있다. 클릭할 때마다 해당 항목의 선택 스타일이 토글된다.

```html
<div class="options" data-multiselect>
  <!-- same option markup — users can select/deselect multiple -->
</div>
```

### Cards (시각 디자인)

```html
<div class="cards">
  <div class="card" data-choice="design1" onclick="toggleSelect(this)">
    <div class="card-image"><!-- mockup content --></div>
    <div class="card-body">
      <h3>Name</h3>
      <p>Description</p>
    </div>
  </div>
</div>
```

### 목업 컨테이너

```html
<div class="mockup">
  <div class="mockup-header">Preview: Dashboard Layout</div>
  <div class="mockup-body"><!-- your mockup HTML --></div>
</div>
```

### 분할 뷰 (나란히 비교)

```html
<div class="split">
  <div class="mockup"><!-- left --></div>
  <div class="mockup"><!-- right --></div>
</div>
```

### 장단점

```html
<div class="pros-cons">
  <div class="pros"><h4>Pros</h4><ul><li>Benefit</li></ul></div>
  <div class="cons"><h4>Cons</h4><ul><li>Drawback</li></ul></div>
</div>
```

### 목 엘리먼트 (와이어프레임 빌딩 블록)

```html
<div class="mock-nav">Logo | Home | About | Contact</div>
<div style="display: flex;">
  <div class="mock-sidebar">Navigation</div>
  <div class="mock-content">Main content area</div>
</div>
<button class="mock-button">Action Button</button>
<input class="mock-input" placeholder="Input field">
<div class="placeholder">Placeholder area</div>
```

### 타이포그래피와 섹션

- `h2` — 페이지 제목
- `h3` — 섹션 헤딩
- `.subtitle` — 제목 아래 보조 텍스트
- `.section` — 하단 마진이 있는 콘텐츠 블록
- `.label` — 작은 대문자 라벨 텍스트

## 브라우저 이벤트 형식

사용자가 브라우저에서 옵션을 클릭하면 인터랙션이 `$STATE_DIR/events`에 기록된다 (한 줄에 JSON 객체 하나). 새 화면을 push하면 파일은 자동으로 비워진다.

```jsonl
{"type":"click","choice":"a","text":"Option A - Simple Layout","timestamp":1706000101}
{"type":"click","choice":"c","text":"Option C - Complex Grid","timestamp":1706000108}
{"type":"click","choice":"b","text":"Option B - Hybrid","timestamp":1706000115}
```

전체 이벤트 스트림은 사용자의 탐색 경로를 보여준다 — 결정하기 전에 여러 옵션을 클릭해 볼 수 있다. 마지막 `choice` 이벤트가 보통 최종 선택이지만, 클릭 패턴에서 망설임이나 선호가 드러나면 물어볼 가치가 있다.

`$STATE_DIR/events`가 없으면 사용자가 브라우저와 상호작용하지 않은 것이다 — 터미널 텍스트만 사용한다.

## 디자인 팁

- **질문에 맞는 완성도로** — 레이아웃 질문에는 와이어프레임, 완성도 질문에는 다듬은 화면
- **페이지마다 질문을 설명한다** — "Pick one"이 아니라 "어떤 레이아웃이 더 전문적으로 느껴지나요?"
- **진행하기 전에 반복한다** — 피드백이 현재 화면을 바꾸면 새 버전을 쓴다
- **화면당 옵션은 최대 2~4개**
- **실제 콘텐츠가 중요할 땐 실제 콘텐츠를** — 사진 포트폴리오라면 실제 이미지(Unsplash)를 쓴다. 플레이스홀더 콘텐츠는 디자인 문제를 가린다.
- **목업은 단순하게** — 픽셀 퍼펙트 디자인이 아니라 레이아웃과 구조에 집중한다

## 파일 네이밍

- 의미 있는 이름을 쓴다: `platform.html`, `visual-style.html`, `layout.html`
- 파일명은 절대 재사용하지 않는다 — 화면마다 새 파일이어야 한다
- 반복 버전에는 `layout-v2.html`, `layout-v3.html`처럼 버전 접미사를 붙인다
- 서버는 수정 시각 기준 가장 최근 파일을 서빙한다

## 정리

```bash
scripts/stop-server.sh $SESSION_DIR
```

세션에 `--project-dir`을 썼다면 목업 파일은 나중에 참고할 수 있도록 `.superpowers/brainstorm/`에 남는다. `/tmp` 세션만 stop 시 삭제된다.

## 참고 자료

- 프레임 템플릿 (CSS 레퍼런스): `scripts/frame-template.html`
- Helper 스크립트 (클라이언트 사이드): `scripts/helper.js`

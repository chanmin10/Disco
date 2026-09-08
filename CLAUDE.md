# DISCO

AI 기반 언어 학습 어시스턴트. 사용자가 아무 텍스트나 번역 요청하면, 그중 실제 "단어/표현"만 자동으로 판별해서 개인 단어장에 저장해준다. 핵심 차별점은 **전역 단축키로 뜨는 팝업창** (Spotlight/Raycast 패턴) — 어떤 앱을 쓰다가도 즉시 번역 요청 가능.

전체 기획 배경은 `design/PRD.md` 참고. 요약:
- **F-01** 메인 창 = 주제(테마)별 채팅방 + 사이드바 단어장 (언어가 아니라 "프로그래밍/일상/비즈니스" 같은 주제 단위로 방이 나뉘고, 번역 언어는 방마다 하나로 고정)
- **F-02** 번역한 단어/표현은 자동으로 백그라운드에서 DB에 저장 (수동 추가 없음)
- **F-03** 전역 단축키 → 팝업창 즉시 오픈, 번역 후 지정한 테마로 자동 저장
- **F-04** 듀얼 엔진: **General = Gemini API** (문장 통번역, LLM), **Quick = Google Translation API** (빠른 단어 번역). 사용자에게는 벤더명 노출 안 하고 General/Quick 라벨만 보임
- **F-05** (P1, MVP 범위 밖) 플래시카드/PDF 복습 — 현재는 오른쪽 사이드바의 플립 카드 칩이 가벼운 대체 역할

## 디자인 스펙 — 반드시 참고

- `design/DISCO_design_spec.md` — 색상 토큰, 타이포그래피, 레이아웃 수치, 컴포넌트 재사용 규칙이 정리된 리빙 도큐먼트. UI 관련 작업 전에 먼저 읽을 것.
- `design/DISCO 디자인 스펙/*.dc.html` — 실제 동작하는 Claude Design 프로토타입 (`Main Window`, `Login Window`, `Popup Window`, `Settings Window`, `SegmentedControl`). **세부 수치·인터랙션은 이 프로토타입이 스펙 문서보다 우선**. 새 UI를 만들거나 기존 UI를 스펙과 맞출 때 여기서 정확한 마크업/스타일 값을 그대로 가져다 쓴다.

> ⚠️ `DISCO_design_spec.md`는 기술 스택을 Flutter로 적어놨지만 **실제 구현은 Electron + React + TypeScript**다 (아래 참고). 디자인 수치·톤·레이아웃 원칙만 따르고, 기술 스택 언급은 무시할 것.

## 저장소 구조

```
Disco/
├── frontend/   # Electron 앱 (실제 구현 스택)
├── backend/    # FastAPI 서버
└── design/     # PRD, 디자인 스펙, .dc.html 프로토타입
```

---

## Frontend — Electron + React + TypeScript

`npm run dev` (개발), `npm run typecheck`, `npm run lint`, `npm run build:mac` 등. `electron-vite` 기반.

### 창(Window) 4개, 각각 독립 렌더러 엔트리

| 창 | 생성 위치 | 렌더러 진입점 | 비고 |
|---|---|---|---|
| Login | `main/windows/loginWindow.ts` | `renderer/src/login-window/` | 로그아웃 상태의 유일한 진입점. 로그인 중에는 Settings 안에서 로그인하는 경로 자체가 없음 |
| Main | `main/windows/mainWindow.ts` | `renderer/src/main-window/` | 채팅+사이드바. macOS에서 빨간 버튼 close는 `hide()`로 가로챔 (아래 "close vs quit" 참고) |
| Popup | `main/windows/popupWindow.ts` | `renderer/src/popup-window/` | 전역 단축키로 토글. `show:false, frame:false, transparent:true`로 미리 만들어두고 show/hide만 함 |
| Settings | `main/windows/settingsWindow.ts` | `renderer/src/settings-window/` | 로그인 후에만 메뉴(⌘,)로 접근 가능 |

창 레퍼런스는 전부 `main/windows/windowRegistry.ts`에서 중앙 관리 (`windowRegistry.main/popup/settings/login`).

### 로그인 게이팅 (중요 — 여러 세션에서 반복 확인된 동작)

- 앱은 `app.whenReady()`에서 **항상 Login 창부터** 띄운다 (`main/index.ts`). Main/Popup은 로그인 성공 전엔 존재하지 않음.
- `main/authLifecycle.ts`의 `handleLoginSuccess()`가 유일하게 `createMainWindow()` + `createPopupWindow()` + `registerGlobalShortcut()`를 실행하는 곳. 로그아웃(`handleLogout()`)은 이걸 전부 되돌림 (팝업 destroy, 단축키 해제, 메인창 destroy).
- 즉 **로그인 전에는 전역 단축키도, 팝업도 존재하지 않는다.** 앱이 아예 안 켜져 있으면 당연히 아무것도 안 뜬다 (트레이/자동실행 없음, 순수 프로세스 기반).
- Settings 창 안에 로그인 폼 같은 건 없다 — 로그아웃하면 Login 창으로 강제 이동.

### macOS의 "close vs quit" 패턴 (버그 있었음, 수정됨)

- `mainWindow.ts`의 `close` 핸들러는 macOS에서 기본적으로 `event.preventDefault() + hide()` — 빨간 버튼으로 닫아도 로그아웃되지 않고 백그라운드에 남아서 Dock 클릭(`activate`)으로 복귀 가능하게 하는 의도적 패턴.
- 문제: 이 핸들러가 Cmd+Q / Quit 메뉴로 인한 진짜 종료의 `close` 이벤트까지 무조건 가로채서, **완전 종료가 실제로는 취소되고 프로세스가 백그라운드에 계속 살아있는** 버그가 있었음. 그 상태에서도 전역 단축키/팝업이 살아있어서 "앱을 껐는데 팝업이 뜨는" 현상 발생.
- 수정: `windowRegistry.isQuitting` 플래그 추가 → `index.ts`의 `app.on('before-quit', ...)`에서 true로 세팅 → `mainWindow.ts`의 close 핸들러는 `!windowRegistry.isQuitting`일 때만 hide 가로채기를 함. 진짜 quit는 정상적으로 진행되어 `shortcuts.ts`의 `will-quit`에서 `globalShortcut.unregisterAll()`까지 도달함.
- **다른 창(Login/Popup/Settings)에는 이런 close 가로채기가 없음** — mainWindow.ts만 특수 케이스.

### IPC 계약 (`preload/index.ts` ↔ `main/ipcHandlers.ts`)

`window.api`로 노출: `getAppVersion`, `getShortcut`/`setShortcut`, `hidePopup`/`resizePopup`, `notifyLoginSuccess`/`notifyLogout`, `onPopupShow`(구독), `onDeepLink`(구독, `disco://` 프로토콜 — `main/deepLink.ts`가 처리, 콜드 스타트 시 `pendingUrl` 버퍼링 후 `flushPendingDeepLink()`로 flush).

단축키 값은 `main/store.ts` (`electron-store`)에 영속화, 기본값 `Shift+Alt+Space`.

### 렌더러 공유 코드 (`renderer/src/shared/`)

- `apiClient.ts` — axios 인스턴스. 요청 인터셉터가 Supabase 세션에서 access_token을 매번 읽어 `Authorization: Bearer` 헤더 부착. 응답 인터셉터가 401을 감지하면 자동 로그아웃 + 모든 창을 Login으로 되돌림 (중복 트리거 방지용 `handlingUnauthorized` 플래그).
- `translateFlow.ts` — **Main/Popup 둘 다 여기 하나만 거쳐서 번역 요청** (`runTranslate`). General이면 `/translate/ai` 한 번, Quick이면 `/translate/quick` → `/translate/classify` 두 번 호출. 엔진 분기 로직을 여기 한 곳에만 두는 게 원칙 — 각 창에서 중복 구현하지 말 것.
- `markdown.css` — `react-markdown`으로 렌더링하는 `.markdown-content` 클래스 스타일. Main(`MessageBubble.tsx`)과 Popup(`ResultArea.tsx`) 둘 다 여기서 가져다 씀 (원래 Main 전용 `chat.css`였다가 Popup 마크다운 렌더링 깨짐 이슈로 공유 위치로 이동함).
- `hooks/useThemes.ts`, `hooks/useVocab.ts`, `hooks/useAuthSession.ts` — 각각 테마 목록/단어장/Supabase 세션 상태.
- `tokens.css` — 디자인 토큰 CSS 변수 (`--accent`, `--text-primary`, `--surface-*` 등). **다크모드 변형 없음** — 단일 팔레트.

### Main ↔ Popup 동작 일치 원칙

Main과 Popup은 별도의 로컬 `isTranslating` state를 각자 갖고 있음 (공유 상태/훅 없음). **하지만 사용자 경험은 반드시 동일해야 한다** — 이번 세션에서 두 번 확인된 패턴:
- API 응답 대기 중 추가 입력을 막을 때는 **필드 자체를 disabled로 막지 말고**, 전송 액션(Enter/전송 버튼)만 guard할 것. 즉 타이핑은 항상 가능하고, "전송 시도"만 `if (disabled) return`으로 막는다. (`ChatInput.tsx`의 `send()`, `PopupTextarea.tsx`의 `onKeyDown` Enter 분기가 레퍼런스)
- 마크다운 렌더링, placeholder 동작, 로딩 중 입력 처리 등 Main에 있는 패턴은 Popup에도 대칭적으로 있어야 한다. 둘 중 하나만 고치고 끝내지 말 것.

---

## Backend — FastAPI (`backend/`)

- `main.py` — 엔드포인트 전부 여기 (라우터 분리 안 되어 있음, 단일 파일). `public_router`(헬스체크만) / `private_router`(나머지 전부, `Depends(get_current_user)`로 인증 게이트).
- 인증: `auth.py` — Supabase Auth JWT를 `HTTPBearer`로 받아서 `supabase.auth.get_user(token)` (동기 SDK라 `asyncio.to_thread`로 감쌈). 실패 시 401.
- 레이트 리밋: `auth.py`의 `check_and_increment()` — 유저별/일별 `ApiUsage` 테이블에 카운트. `AI_LIMIT = 20/day`, `QUICK_LIMIT = 100/day`. 초과 시 429 + 한국어 에러 메시지.
- DB: PostgreSQL, SQLAlchemy 2.0 async (`asyncpg`), Alembic 마이그레이션 (`alembic/versions/`). 모델은 `models.py` (`Theme`, `Session`, `VocabEntry`, `Profile`, `ApiUsage`). **`Session` 모델은 현재 어떤 엔드포인트에서도 안 쓰임** — 향후 대화 기록용으로 스키마만 존재하는 상태로 보임.
- 엔드포인트:
  - `POST /translate/quick` — Google Translation API 두 번 호출(원문 언어 감지 → 필요시 반대 방향 재번역)해서 `text_native`/`text_target` 산출. **DB에 저장 안 함**, 저장은 아래 classify가 담당.
  - `POST /translate/classify` — Gemini에 "이게 저장할 만한 단어/표현인가?" 판단시키는 프롬프트(`prompts.py`의 `VOCAB_CLASSIFIER_PROMPT`) 호출 → `is_vocab`이면 `VocabEntry` insert (중복이면 skip).
  - `POST /translate/ai` — Gemini로 문장 통번역 + 단어 판별을 한 번에 (`GEMINI_TRANSLATE_PROMPT`). 응답이 ` ``` ` 코드블록으로 감싸진 JSON을 포함하는 포맷이라 문자열 split으로 파싱 — 이 파싱이 Gemini 응답 포맷에 강하게 의존하므로 프롬프트를 건드릴 땐 이 파싱 로직도 같이 확인할 것.
  - `POST/GET/DELETE /themes`, `GET/DELETE /vocab` — 표준 CRUD.
- Gemini/Google Translate 키는 `os.environ["GEMINI_API_KEY"]`/`os.environ["GOOGLE_TRANSLATE_API_KEY"]`로 직접 읽음 (`.env`, `load_dotenv()`). 프로덕션은 Fly.io (`fly.toml`, `disco-backend.fly.dev`), Dockerfile로 `uvicorn main:app --port 8080` 실행.
- 프론트 `apiClient.ts`는 dev면 `http://localhost:8000`, 빌드면 `https://disco-backend.fly.dev`로 baseURL 분기.

### 필요한 환경변수

- **backend/.env**: `DATABASE_URL`, `GEMINI_API_KEY`, `GOOGLE_TRANSLATE_API_KEY`, `SUPABASE_URL`, `SUPABASE_SERVICE_KEY`, `RESEND_API`
- **frontend/.env**: `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`, `GH_TOKEN` (electron-builder 자동업데이트 배포용)

---

## 작업할 때 참고할 것

- UI를 만들거나 고칠 땐 항상 `design/` 프로토타입/스펙과 먼저 대조한다 — 색상·수치·인터랙션을 임의로 정하지 말 것.
- Main과 Popup은 짝이다. 한쪽 동작(로딩 처리, 마크다운, 에러 처리 등)을 고치면 다른 쪽도 대칭인지 확인한다.
- 엔진 분기(General/Quick)는 `translateFlow.ts` 한 곳에만 있어야 한다.
- Electron 창 라이프사이클(특히 macOS의 close/hide/quit 구분)은 미묘하다 — 창을 새로 추가하거나 close 동작을 바꿀 땐 `windowRegistry.isQuitting` 패턴을 참고해서 "사용자가 창을 닫은 것"과 "앱이 실제로 종료되는 것"을 구분할 것.

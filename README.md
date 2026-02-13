# jaeho-claude-only

Jaeho의 Claude Code 고도화 환경 - 자동 오케스트레이션 & 자율 실행 모드

## 🎯 개요

OpenCode에서 Claude Code로 마이그레이션한 통합 환경입니다. **하나의 에이전트만 호출하면 알아서 필요한 에이전트/스킬을 자동으로 판단하고 사용**하는 지능형 시스템입니다.

## ✨ 주요 특징

- 🤖 **자동 오케스트레이션**: @coordinator가 작업 복잡도/비용을 분석하여 최적 전략 선택
- ⚡ **자율 실행 모드**: 승인 요청 없이 작업 완료까지 자동 진행
- 💰 **비용 최적화**: 단순 작업 직접 처리, 검색은 Haiku, 전략만 Opus
- 🎯 **지능적 라우팅**: 키워드 기반 자동 에이전트 위임
- 🔄 **자동 재시도**: 에러 발생 시 자동 수정 및 재시도 (최대 3회)

## 📦 포함 내용

### 커스텀 에이전트 (8개)

| 에이전트 | 모델 | 용도 |
|---------|------|------|
| **coordinator** | Sonnet | 🆕 **범용 진입점** - 모든 요청의 자동 라우팅 |
| **oracle** | Opus | 아키텍처 상담 & 디버깅 |
| **prometheus** | Opus | 전략적 계획 수립 |
| **momus** | Sonnet | 계획/코드 품질 리뷰 |
| **code-reviewer** | Sonnet | 코드 리뷰 전문가 |
| **debugger** | Sonnet | 버그 추적 & 수정 |
| **librarian** | Haiku | 문서 검색 & 레퍼런스 |
| **multimodal-looker** | Sonnet | 이미지/PDF 분석 |

### 다이어그램 스킬 (5개)

- `/mermaid-render` - Mermaid → SVG/PNG 변환
- `/arch-diagram` - 시스템 아키텍처
- `/sequence-diagram` - 시퀀스/플로우
- `/class-diagram` - UML 클래스
- `/er-diagram` - DB 스키마

### 워크플로우 스킬 (6개) 🆕

- `/tdd-cycle` - TDD 사이클 (Red → Green → Refactor)
- `/brainstorm-session` - 체계적 아이디어 발산
- `/write-plan` - 구조화된 계획 문서 작성
- `/systematic-debug` - 단계별 디버깅 프로세스
- `/code-review-checklist` - 체크리스트 기반 리뷰
- `/refactor-guide` - 안전한 리팩토링 가이드

### MCP 서버 (6개)

- **github** - GitHub 통합
- **playwright** - 브라우저 자동화
- **filesystem** - 파일 시스템 접근
- **sequential-thinking** - 단계별 추론
- **memory** - 지식 그래프
- **notion-epic-tracker** - Notion 작업 관리 (Python)

## 🚀 빠른 시작

### 필수 요구사항

- **Claude Code CLI** - [code.claude.com](https://code.claude.com)
- **Node.js** >= 18.0.0
- **Python** >= 3.10
- **Git** (선택)

### 설치 방법

```bash
# 1. 리포지토리 클론
git clone https://github.com/jaeholee-creator/jaeho-claude-only.git
cd jaeho-claude-only

# 2. 환경변수 설정
cp .env.example .env
# .env 파일을 열어서 토큰 입력

# 3. 설치 스크립트 실행
./setup.sh

# 4. Claude Code 시작
claude  # 모드 선택 화면이 나타납니다
```

### 🎛️ 모드 선택 기능

`claude` 명령어 실행 시 5가지 실행 모드 중 선택할 수 있습니다:

```bash
$ claude
🤖 Claude Code 모드 선택

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Default: 모든 작업마다 확인 요청
✏️  Accept Edits: 파일 편집 자동, 명령어만 확인 (추천)
📝 Plan: 읽기 전용 분석 (수정 불가)
🔒 Don't Ask: 사전 승인 목록만 사용
⚠️  Bypass: 모든 권한 무시 (격리 환경만!)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

모드를 선택하세요 (숫자 입력):
1) Default (기본 - 모든 작업 확인)
2) Accept Edits (편집 자동 승인) ⭐
3) Plan Mode (읽기 전용 계획)
4) Don't Ask (사전 승인만)
5) Bypass Permissions ⚠️ (격리 환경)
6) 취소
```

**추천 모드:**
- **Accept Edits (2번)** - 파일 편집은 자동 승인, Bash 명령어만 확인 요청 (가장 효율적)

**인자가 있으면 모드 선택 없이 바로 실행:**
```bash
claude "사용자 인증 구현해줘"  # 바로 실행 (모드 선택 생략)
```

### .env 설정

`.env` 파일에 다음 토큰을 입력하세요:

```bash
# GitHub Personal Access Token (필수)
GITHUB_PERSONAL_ACCESS_TOKEN=ghp_YOUR_TOKEN_HERE

# Notion Integration Token (선택 - Notion 사용 시)
NOTION_TOKEN=ntn_YOUR_TOKEN_HERE
```

**GitHub Token 생성 방법:**
1. GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token (classic)
3. repo, read:org 권한 선택
4. 토큰 복사하여 .env에 입력

## 📖 사용 가이드

### 🆕 자동 오케스트레이션 (권장)

**모든 요청에 `@coordinator`를 사용하세요!**

```bash
# 단순 작업 - 직접 처리
@coordinator 이 함수에 에러 처리 추가해줘
→ Sonnet으로 즉시 처리 (빠르고 저렴)

# 문서 검색 - Haiku 위임
@coordinator React Query 사용법 알려줘
→ @librarian 위임 (80% 비용 절감)

# 아키텍처 - Opus 위임
@coordinator 이 시스템 아키텍처 분석해줘
→ @oracle 위임 (전문성 필요)

# 복잡한 작업 - 다중 에이전트
@coordinator 사용자 인증 시스템을 설계하고 구현해줘
→ 자동 오케스트레이션:
  1. @prometheus (계획)
  2. @oracle (설계)
  3. 직접 구현
  4. @code-reviewer (리뷰)
```

### 에이전트 직접 호출 (고급)

특정 에이전트를 직접 호출할 수도 있습니다:

```bash
# 아키텍처 분석
@oracle 이 시스템의 아키텍처를 분석해줘

# 코드 리뷰
@code-reviewer 이 PR을 리뷰해줘

# 버그 디버깅
@debugger TypeError 원인을 찾아줘

# 문서 검색
@librarian React Query 사용법 알려줘

# 프로젝트 계획
@prometheus 사용자 인증 구현 계획을 세워줘
```

**하지만 대부분의 경우 @coordinator 사용을 권장합니다.**

### 다이어그램 생성

```bash
# 아키텍처 다이어그램
/arch-diagram

# 시퀀스 다이어그램
/sequence-diagram

# ER 다이어그램
/er-diagram
```

### 🆕 워크플로우 스킬

```bash
# TDD 사이클로 기능 구현
/tdd-cycle "사용자 로그인"

# 브레인스토밍 세션
/brainstorm-session "API 성능 개선 방안"

# 구조화된 계획 문서 작성
/write-plan "사용자 인증 JWT 전환"

# 체계적 디버깅
/systematic-debug "메모리 누수 문제"

# 체크리스트 기반 코드 리뷰
/code-review-checklist "src/auth/"

# 안전한 리팩토링
/refactor-guide "UserService 클래스"
```

### Notion 작업 관리

```bash
# Epic 목록 조회
list_epics

# 특정 Epic의 Task 조회
list_tasks("프로젝트명")

# Task 생성
create_task("프로젝트명", "Task 이름", "Feature", "HIGH")

# Task 완료
complete_task("프로젝트명", "Task 이름")
```

## 📁 디렉토리 구조

```
jaeho-claude-only/
├── README.md                      # 이 파일
├── setup.sh                       # 설치 스크립트
├── .env.example                   # 환경변수 템플릿
├── .gitignore                     # Git 제외 파일
├── config/
│   ├── CLAUDE.md                  # 전역 설정 (오케스트레이션 가이드 포함)
│   ├── settings.json              # Claude Code 설정 (자동 승인 모드)
│   ├── mcp.json                   # MCP 서버 정의
│   ├── agents/                    # 커스텀 에이전트 8개
│   │   ├── coordinator.md         # 🆕 범용 진입점
│   │   ├── oracle.md
│   │   ├── prometheus.md
│   │   ├── momus.md
│   │   ├── librarian.md
│   │   ├── multimodal-looker.md
│   │   ├── code-reviewer.md
│   │   └── debugger.md
│   └── skills/                    # 커스텀 스킬 12개
│       ├── mermaid-render/SKILL.md
│       ├── arch-diagram/SKILL.md
│       ├── sequence-diagram/SKILL.md
│       ├── class-diagram/SKILL.md
│       ├── er-diagram/SKILL.md
│       ├── tdd-cycle/SKILL.md                  # 🆕
│       ├── brainstorm-session/SKILL.md         # 🆕
│       ├── write-plan/SKILL.md                 # 🆕
│       ├── systematic-debug/SKILL.md           # 🆕
│       ├── code-review-checklist/SKILL.md      # 🆕
│       ├── refactor-guide/SKILL.md             # 🆕
│       └── delegation-guide/SKILL.md           # 🆕 (내부용)
└── mcp-servers/
    └── notion-epic-tracker/       # Python MCP 서버
        ├── server.py
        └── requirements.txt
```

## 🔧 문제 해결

### MCP 서버가 연결 안 됨

```bash
# Python 가상환경 확인
ls ~/.config/claude-mcp/notion-epic-tracker/.venv/

# 없으면 재설치
cd ~/.config/claude-mcp/notion-epic-tracker
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
```

### 에이전트가 안 보임

```bash
# 에이전트 파일 확인
ls ~/.claude/agents/

# 없으면 다시 복사
cp -r config/agents/* ~/.claude/agents/
```

### Mermaid 다이어그램 생성 실패

```bash
# Mermaid CLI 설치
npm install -g @mermaid-js/mermaid-cli

# 버전 확인
mmdc --version
```

## 🔄 업데이트

리포지토리가 업데이트되면:

```bash
cd jaeho-claude-only
git pull
./setup.sh
```

## 📝 커스터마이징

### 에이전트 수정

`config/agents/` 디렉토리의 `.md` 파일을 수정한 후 `./setup.sh` 재실행

### 스킬 추가

`config/skills/` 디렉토리에 새 스킬 폴더와 `SKILL.md` 파일 생성 후 `./setup.sh` 재실행

### MCP 서버 추가

`config/mcp.json`에 서버 정의 추가 후 `./setup.sh` 재실행

## 🤝 기여

이슈나 개선사항은 GitHub Issues로 제출해주세요.

## 📜 라이선스

MIT License

## 🌟 주요 개선사항 (v2.0)

### 자동 오케스트레이션
- **Coordinator 메타 에이전트**: 모든 요청의 범용 진입점
- **지능적 라우팅**: 복잡도/비용/컨텍스트 효율성 분석
- **자동 위임**: 키워드 기반 에이전트 자동 선택
- **비용 최적화**: 단순 작업 직접 처리, 검색은 Haiku, 전략만 Opus

### 자율 실행 모드
- **승인 요청 없음**: 파일 생성/수정/명령어 실행 자동 진행
- **자동 재시도**: 실패 시 자동 수정 및 재시도 (최대 3회)
- **에러 자동 복구**: 에러 원인 분석 후 수정
- **중단 없는 작업**: 작업 완료까지 자동 진행

### 워크플로우 스킬 (6개 신규)
- TDD 사이클, 브레인스토밍, 계획 작성, 체계적 디버깅, 코드 리뷰, 리팩토링

### 컨텍스트 최적화
- Tool Search 활성화 (46.9% 토큰 감소)
- MCP 제한 준수 (6/10 사용)
- 한국어 응답 지원

---

**만든 사람**: Jaeho Lee
**최종 업데이트**: 2026-02-08
**버전**: 2.0.0 (자동 오케스트레이션 & 자율 실행)

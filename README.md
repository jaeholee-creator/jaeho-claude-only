# jaeho-claude-only

Jaeho의 Claude Code 통합 환경 - 에이전트, 스킬, MCP 서버를 한 번에 설치

## 🎯 개요

OpenCode에서 Claude Code로 마이그레이션한 통합 환경입니다. 다른 PC에서도 원클릭으로 동일한 환경을 구축할 수 있습니다.

## 📦 포함 내용

### 커스텀 에이전트 (7개)

| 에이전트 | 모델 | 용도 |
|---------|------|------|
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
claude
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

### 에이전트 호출

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

### 다이어그램 생성

```bash
# 아키텍처 다이어그램
/arch-diagram

# 시퀀스 다이어그램
/sequence-diagram

# ER 다이어그램
/er-diagram
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
│   ├── CLAUDE.md                  # 전역 설정
│   ├── settings.json              # Claude Code 설정
│   ├── mcp.json                   # MCP 서버 정의
│   ├── agents/                    # 커스텀 에이전트 7개
│   │   ├── oracle.md
│   │   ├── prometheus.md
│   │   ├── momus.md
│   │   ├── librarian.md
│   │   ├── multimodal-looker.md
│   │   ├── code-reviewer.md
│   │   └── debugger.md
│   └── skills/                    # 커스텀 스킬 5개
│       ├── mermaid-render/SKILL.md
│       ├── arch-diagram/SKILL.md
│       ├── sequence-diagram/SKILL.md
│       ├── class-diagram/SKILL.md
│       └── er-diagram/SKILL.md
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

---

**만든 사람**: Jaeho Lee
**최종 업데이트**: 2026-02-07

---
name: notion-report-designer
description: Notion AI 트렌드 리포트 레이아웃 설계 및 개선 전문 스킬. notion_publisher.py를 분석하고 가독성·정보밀도 개선안을 설계·구현한다.
user-invocable: true
tools: [Read, Edit, Write, Grep, Glob]
---

# Notion Report Designer 스킬

AI 트렌드 리포트의 Notion 레이아웃을 **정보 밀도↑ + 가독성↑** 두 목표를 동시에 달성하도록 설계·구현하는 전문 스킬입니다.

## 설계 원칙

### 1. 빠른 스캔 (5초 룰)
- 페이지 열자마자 5초 내에 "오늘 뭐가 중요한지" 파악 가능
- Quick Action callout이 페이지 최상단에 배치
- 점수 시각화로 중요도를 한눈에 파악

### 2. 정보 계층 구조
```
레벨 1: Quick Action (즉시 확인 필요) ← 가장 눈에 띄게
레벨 2: 시간대별 트렌드 (24h > 7d > 30d)
레벨 3: AI Tool 릴리즈 전용 섹션
레벨 4: 카테고리별 전체 목록 (Toggle - 접혀 있음)
```

### 3. AI Tool 특화 표시
- 모든 아이템에서 AI 도구명 자동 감지 → 태그로 표시
- GitHub Releases 아이템은 별도 전용 섹션
- 내 환경(Claude Code, Cursor, LangChain) 연관 여부 강조

### 4. 긴급도 체계
- 🔴 즉시확인: score ≥ 70 + github_releases 또는 anthropic 관련
- 🟡 이번주: score 50-69 또는 7일 이내
- 🟢 참고: score < 50 또는 30일 이내

## 개선된 아이템 카드 포맷

```
[heading_3]   N. 제목 (링크)
[paragraph]   ●●●●○ 85점 · 🔴 즉시확인 · 🐙 깃허브 릴리즈 (AI 도구)
[bulleted]    [LangGraph] [에이전트 프레임워크]    ← AI 도구 태그 (있을 때만)
[callout]     요약 텍스트 1-2줄                   ← summary 있을 때만
```

## 새 페이지 구조

```
🤖 헤더 Callout (수집 통계)
⚡ Quick Action Callout (즉시확인 상위 3개) ← 신규
───────────────────────────────────────
🔥 오늘의 핫 트렌드 (24h)
  [개선 카드 × 5]
🛠️ AI Tool 릴리즈 (신규 전용 섹션)          ← 신규
  [Toggle: 에이전트 프레임워크]
  [Toggle: AI 코딩 도구]
  [Toggle: MCP 생태계]
───────────────────────────────────────
📈 이번 주 주목할 트렌드 (7d)
  [개선 카드 × 5]
💎 이번 달 놓치면 안 되는 이슈 (30d)
  [개선 카드 × 5]
───────────────────────────────────────
📂 카테고리별 (5개 Toggle - 접혀 있음)
📊 수집 현황 표
ℹ️ 푸터
```

## 사용법

```
/notion-report-designer
→ notion_publisher.py 현재 구조 분석 후 개선안 제안 및 구현
```

## AI Tool 감지 키워드 목록

```python
AI_TOOL_TAGS = {
    "Claude Code": ["claude code", "claude-code"],
    "Cursor": ["cursor", "cursor ai", "cursor ide"],
    "Copilot": ["copilot", "github copilot"],
    "Windsurf": ["windsurf", "codeium"],
    "Devin": ["devin", "cognition ai"],
    "LangChain": ["langchain", "langchain-core"],
    "LangGraph": ["langgraph", "langgraph-sdk"],
    "CrewAI": ["crewai", "crew ai"],
    "AutoGen": ["autogen", "microsoft autogen"],
    "OpenAI SDK": ["openai-agents", "openai agents sdk"],
    "PydanticAI": ["pydantic-ai", "pydanticai"],
    "MCP": ["mcp", "model context protocol"],
    "OpenHands": ["openhands", "open hands"],
    "n8n": ["n8n"],
    "Replit": ["replit"],
    "Lovable": ["lovable"],
    "Bolt": ["bolt.new", "bolt new"],
}
```

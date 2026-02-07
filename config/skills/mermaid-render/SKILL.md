---
name: mermaid-render
description: Mermaid 다이어그램 코드를 SVG/PNG 이미지로 렌더링
user-invocable: true
allowed-tools: Write, Bash
argument-hint: "[output-filename]"
---

# Mermaid Diagram Renderer

Mermaid 코드를 시각적 다이어그램(SVG/PNG)으로 자동 변환합니다.

## 사전 조건

Mermaid CLI 설치 필요:
```bash
npm install -g @mermaid-js/mermaid-cli
```

## 사용 방법

1. **Mermaid 코드 생성**: 다이어그램 문법으로 작성
2. **임시 파일 저장**: `/tmp/diagram-{timestamp}.mmd`에 저장
3. **렌더링**: `mmdc` 명령으로 SVG/PNG 생성
4. **결과 반환**: 생성된 파일 경로 제공

## 출력 형식

| 형식 | 명령어 | 용도 |
|------|--------|------|
| SVG | `-o file.svg` | 웹, 확대 가능 (권장) |
| PNG | `-o file.png` | 래스터 이미지 |
| PDF | `-o file.pdf` | 문서 첨부 |

## 렌더링 옵션

```bash
# 기본 렌더링
mmdc -i input.mmd -o output.svg

# 다크 테마
mmdc -i input.mmd -o output.svg -t dark

# 투명 배경
mmdc -i input.mmd -o output.svg -b transparent

# 고해상도 PNG
mmdc -i input.mmd -o output.png -s 2
```

## 사용 가능한 테마

- `default` - 기본 테마
- `dark` - 다크 모드
- `forest` - 녹색 톤
- `neutral` - 그레이스케일

## 예시 워크플로우

**사용자 요청**: "사용자 인증 플로우차트 만들어줘"

**처리 단계**:
1. Mermaid 코드 생성
2. `/tmp/diagram-auth-{timestamp}.mmd` 저장
3. `mmdc -i /tmp/diagram-auth-{timestamp}.mmd -o /tmp/diagram-auth.svg` 실행
4. 결과: "다이어그램이 `/tmp/diagram-auth.svg`에 생성되었습니다"

## 에러 처리

렌더링 실패 시:
1. Mermaid 문법 확인 (mermaid.live에서 검증)
2. Chrome 설치 확인: `npx puppeteer browsers install chrome`
3. 출력 디렉토리 권한 확인

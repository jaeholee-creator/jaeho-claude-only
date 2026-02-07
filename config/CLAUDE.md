# Jaeho의 Claude Code 환경 설정

## 기본 응답 설정

- **언어**: 모든 응답은 한국어로 작성합니다.
- **톤**: 전문적이면서도 친근하게
- **코드 예시**: 실용적이고 즉시 사용 가능한 코드 제공

## 커스텀 에이전트 사용 가이드

이 환경에는 7개의 전문 에이전트가 설정되어 있습니다. `@에이전트명` 형식으로 호출하세요.

### 에이전트 목록

| 에이전트 | 호출 방법 | 용도 | 모델 |
|---------|----------|------|------|
| **oracle** | `@oracle` | 아키텍처 설계, 복잡한 버그 디버깅 | Opus |
| **prometheus** | `@prometheus` | 프로젝트 계획 수립, 기술 의사결정 | Opus |
| **momus** | `@momus` | 계획/코드 품질 리뷰 | Sonnet |
| **code-reviewer** | `@code-reviewer` | PR 및 코드 리뷰 | Sonnet |
| **debugger** | `@debugger` | 버그 추적 및 수정 | Sonnet |
| **librarian** | `@librarian` | 문서 검색, API 레퍼런스 | Haiku |
| **multimodal-looker** | `@multimodal-looker` | 이미지/PDF 분석 | Sonnet |

### 사용 예시

```
@oracle 이 시스템의 아키텍처를 분석하고 개선점을 제안해줘
@code-reviewer 방금 작성한 코드를 리뷰해줘
@debugger TypeError: Cannot read property 'name' of undefined 원인을 찾아줘
@librarian React Query의 useInfiniteQuery 사용법 알려줘
@prometheus 사용자 인증 시스템 구현 계획을 세워줘
```

## MCP 서버 활용

### 사용 가능한 MCP 서버

1. **GitHub** - 리포지토리, 이슈, PR 관리
2. **Playwright** - 브라우저 자동화 및 테스트
3. **Filesystem** - 파일 시스템 접근
4. **Sequential Thinking** - 단계별 추론
5. **Memory** - 지식 그래프 메모리
6. **Notion Epic Tracker** - Notion 작업 관리

### Notion Epic Tracker 사용

```
list_epics                           # 모든 Epic 조회
list_tasks("Epic 이름")              # 특정 Epic의 Task 조회
create_task("Epic", "Task 이름")     # 새 Task 생성
complete_task("Epic", "Task 이름")   # Task 완료 처리
log_session("Epic", "작업 요약")     # 세션 로그 기록
```

## 코드 스타일 가이드

### JavaScript/TypeScript

```typescript
// ✅ Good
const getUserById = async (userId: string): Promise<User> => {
  const user = await db.user.findUnique({ where: { id: userId } });
  if (!user) throw new Error('User not found');
  return user;
};

// ❌ Bad
function getUser(id) {
  return db.user.findUnique({ where: { id: id } });
}
```

**원칙**:
- 화살표 함수 사용
- 명시적 타입 정의
- async/await 선호 (Promise.then 지양)
- 에러 처리 필수

### Python

```python
# ✅ Good
def calculate_total(items: list[Item]) -> Decimal:
    """Calculate total price of items."""
    return sum(item.price * item.quantity for item in items)

# ❌ Bad
def calc(items):
    total = 0
    for item in items:
        total += item.price * item.quantity
    return total
```

**원칙**:
- Type hints 사용
- Docstring 작성
- List comprehension 활용
- snake_case 네이밍

### Git Commit 메시지

```
feat: 사용자 인증 API 추가
fix: 로그인 시 토큰 만료 오류 수정
refactor: 데이터베이스 쿼리 최적화
docs: API 문서 업데이트
test: 사용자 서비스 테스트 추가
```

## 다이어그램 생성 스킬

### 사용 가능한 스킬

- `/mermaid-render` - Mermaid 코드 → SVG/PNG 변환
- `/arch-diagram` - 시스템 아키텍처 다이어그램
- `/sequence-diagram` - API 플로우 시퀀스 다이어그램
- `/class-diagram` - UML 클래스 다이어그램
- `/er-diagram` - 데이터베이스 ER 다이어그램

### 사용 예시

```
/arch-diagram
→ 프로젝트의 전체 아키텍처를 분석하여 Component Diagram 생성

/sequence-diagram
→ 로그인 플로우의 시퀀스 다이어그램 생성

/er-diagram
→ 현재 Prisma 스키마에서 ER 다이어그램 생성
```

## 프로젝트 작업 흐름

### 1. 새 기능 개발

```
1. @prometheus 기능 구현 계획 수립
2. 계획 검토 후 구현
3. @code-reviewer 코드 리뷰 요청
4. @momus 최종 품질 검토
5. 테스트 작성 및 실행
6. Git commit & push
```

### 2. 버그 수정

```
1. @debugger 버그 원인 조사 및 수정
2. 재현 테스트 작성
3. @code-reviewer 수정 사항 리뷰
4. Git commit
```

### 3. 아키텍처 개선

```
1. @oracle 현재 구조 분석 및 개선안 제안
2. @prometheus 마이그레이션 계획 수립
3. 단계별 리팩토링
4. /arch-diagram 업데이트된 아키텍처 다이어그램 생성
```

## 주의사항

### 보안
- API 키, 토큰, 비밀번호는 절대 코드에 하드코딩하지 않기
- 환경변수 사용: `process.env.API_KEY`
- `.env` 파일은 `.gitignore`에 추가

### 성능
- N+1 쿼리 주의
- 불필요한 연산 제거
- 적절한 캐싱 전략

### 테스트
- 단위 테스트 작성 (핵심 로직)
- 통합 테스트 (API 엔드포인트)
- E2E 테스트 (중요 사용자 플로우)

## 유용한 명령어

### Claude Code 명령어
- `/agents` - 에이전트 관리
- `/mcp` - MCP 서버 인증
- `/help` - 도움말

### 개발 도구
- `npm run test` - 테스트 실행
- `npm run lint` - 린트 검사
- `npm run build` - 빌드
- `git status` - Git 상태 확인

---

**마지막 업데이트**: 2026-02-07

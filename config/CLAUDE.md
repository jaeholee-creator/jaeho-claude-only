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

## 🤖 자동 오케스트레이션 시스템

### Coordinator 에이전트 - 범용 진입점

**모든 요청에 `@coordinator`를 사용하세요!**

Coordinator는 작업의 복잡도와 효율성을 분석하여:
- **단순 작업**: 직접 처리 (빠르고 저렴)
- **전문성 필요**: 적절한 에이전트 위임
- **복잡한 작업**: 다중 에이전트 오케스트레이션

```
@coordinator 이 함수에 에러 처리 추가해줘
→ 단순 작업으로 직접 처리 (Sonnet)

@coordinator React Query 사용법 알려줘
→ @librarian 위임 (Haiku, 비용 절감)

@coordinator 이 시스템 아키텍처 분석해줘
→ @oracle 위임 (Opus, 전문성 필요)

@coordinator 사용자 인증 시스템을 설계하고 구현해줘
→ 다중 에이전트 오케스트레이션
  1. @prometheus (계획)
  2. @oracle (설계)
  3. 직접 구현
  4. @code-reviewer (리뷰)
```

### 지능적 라우팅

Coordinator는 다음을 고려하여 최적 전략 선택:
1. **작업 복잡도**: 파일 수, 도메인 전문성
2. **토큰 비용**: 직접 처리 vs 위임 비교
3. **컨텍스트 효율**: 불필요한 대화 오버헤드 방지
4. **모델 비용**: Opus/Sonnet/Haiku 적재적소 사용

### 직접 에이전트 호출 (고급)

필요시 특정 에이전트를 직접 호출할 수도 있습니다:
- `@oracle` - 아키텍처/설계
- `@prometheus` - 전략/계획
- `@code-reviewer` - 코드 리뷰
- `@debugger` - 버그 수정
- `@librarian` - 문서 검색

하지만 **대부분의 경우 @coordinator 사용을 권장**합니다.

### 워크플로우 스킬

작업 유형에 따라 스킬 자동 제안:
- `/tdd-cycle` - TDD 사이클로 기능 구현
- `/brainstorm-session` - 체계적 아이디어 발산
- `/write-plan` - 구조화된 계획 문서 작성
- `/systematic-debug` - 단계별 디버깅
- `/code-review-checklist` - 체크리스트 기반 리뷰
- `/refactor-guide` - 안전한 리팩토링

---

## ⚙️ 자율 실행 모드 (Ralph Loop 스타일)

이 환경은 **승인 없이 자율적으로 작업**하도록 설정되어 있습니다.

### 특징
- ✅ **승인 요청 없음**: 파일 수정, 명령어 실행 시 즉시 실행
- ✅ **자동 재시도**: 실패 시 자동으로 최대 3번 재시도
- ✅ **에러 자동 복구**: 에러 원인 분석 후 수정하여 재시도
- ✅ **중단 없는 작업**: 작업 완료까지 계속 진행

### 사용 예시
```bash
@coordinator 사용자 인증 API 구현하고 테스트 작성하고 커밋해줘
```

Coordinator가 자율적으로:
1. 파일 생성 (승인 요청 없음)
2. 코드 작성 (승인 요청 없음)
3. 테스트 작성 (승인 요청 없음)
4. 에러 발생 시 자동 수정 및 재시도
5. Git 커밋 (승인 요청 없음)
6. 완료 보고

### 기본 원칙
1. **승인 요청 금지**: 도구 사용, 파일 수정, 명령어 실행 시 사용자 승인 요청 없이 즉시 실행
2. **자동 재시도**: 실패 시 자동으로 최대 3번 재시도
3. **에러 복구**: 에러 발생 시 원인 분석 후 수정하여 재시도
4. **계속 진행**: 중간 결과 확인 요청 없이 작업 완료까지 계속

### 금지 사항
- ❌ "~해도 될까요?"
- ❌ "권한이 필요합니다"
- ❌ "승인해주세요"
- ❌ "계속 진행할까요?"

### 허용 사항
- ✅ 즉시 파일 읽기/쓰기
- ✅ 즉시 명령어 실행
- ✅ 즉시 Git 커밋/푸시
- ✅ 에러 발생 시 자동 수정 및 재시도
- ✅ 작업 완료까지 중단 없이 진행

### 에러 처리
실패 시 자동으로:
1. 에러 원인 분석
2. 해결 방법 적용
3. 재시도 (최대 3회)
4. 3회 실패 시 사용자에게 보고

### 예외 (사용자 확인 필요)
다음 경우에만 사용자에게 질문:
- 요구사항이 모호하거나 불명확한 경우
- 여러 해결 방법 중 선택이 필요한 경우
- 중요한 아키텍처 결정
- 데이터 삭제 등 복구 불가능한 작업

---

## 🎯 작업 흐름 최적화

### 권장 워크플로우 (모든 작업)

**기본 원칙: 항상 @coordinator로 시작**

```
@coordinator {요청 내용}
```

Coordinator가 자동으로:
1. 복잡도 분석
2. 토큰 비용 계산
3. 최적 전략 선택
   - 단순 → 직접 처리
   - 전문성 필요 → 에이전트 위임
   - 복잡 → 다중 에이전트

### 대안 (고급 사용자)

특정 에이전트를 이미 알고 있다면 직접 호출 가능:
- `@oracle` - 아키텍처 질문
- `@librarian` - 문서 검색만
- `@code-reviewer` - 리뷰만

하지만 대부분의 경우 coordinator가 더 효율적입니다.

---

## 💡 베스트 프랙티스

1. **항상 @coordinator로 시작**: 모든 요청은 @coordinator를 통해 → 자동으로 최적 전략 선택
2. **명확한 요청**: 작업 목표를 구체적으로 명시
3. **컨텍스트 제공**: 관련 파일, 요구사항 첨부
4. **단계별 진행**: 큰 작업은 여러 단계로 분할
5. **피드백 루프**: 중간 결과 확인 후 다음 단계

**왜 항상 @coordinator를 사용해야 하나요?**
- 작업 복잡도에 따라 자동으로 직접 처리 또는 위임 결정
- 토큰 비용 최적화 (불필요한 위임 방지)
- 가장 적합한 모델/에이전트 자동 선택
- 사용자는 복잡도를 판단할 필요 없음

---

**마지막 업데이트**: 2026-02-08

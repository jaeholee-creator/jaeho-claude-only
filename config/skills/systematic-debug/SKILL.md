---
name: systematic-debug
description: 단계별 디버깅 프로세스 - 재현, 가설, 검증, 수정, 확인
user-invocable: true
allowed-tools: Read, Edit, Bash, Grep, Glob
argument-hint: "[error-description]"
---

# 체계적 디버깅 프로세스

버그를 효율적으로 찾고 수정하는 6단계 워크플로우입니다.

## 6단계 디버깅 프로세스

### 1️⃣ 에러 재현 (Reproduce)

**목표**: 버그를 일관되게 재현

**수집할 정보**:
- 에러 메시지 (전체 스택 트레이스)
- 재현 단계
- 환경 정보 (OS, 브라우저, 버전 등)
- 입력 데이터
- 예상 동작 vs 실제 동작

**최소 재현 케이스 작성**:
```javascript
// Minimal reproducible example
test('bug: user creation fails with special characters', () => {
  const user = { name: "O'Brien", email: "test@example.com" };
  expect(() => createUser(user)).not.toThrow(); // Currently fails
});
```

**체크리스트**:
- [ ] 버그가 100% 재현되는가?
- [ ] 최소 단계로 줄였는가?
- [ ] 환경 정보를 기록했는가?

---

### 2️⃣ 가설 수립 (Hypothesize)

**목표**: 가능한 원인 3-5개 나열

**가설 템플릿**:
```markdown
## 가설 목록

### 가설 1: SQL Injection 방지 로직 문제
- **가능성**: 높음 (70%)
- **근거**: 에러가 특수문자 입력 시만 발생
- **검증 방법**: DB 쿼리 로그 확인

### 가설 2: 입력 검증 정규식 오류
- **가능성**: 중간 (40%)
- **근거**: 이름 필드에 정규식 검증 있음
- **검증 방법**: 정규식 단위 테스트

### 가설 3: 인코딩 문제
- **가능성**: 낮음 (20%)
- **근거**: UTF-8 환경이지만 검증 필요
- **검증 방법**: 문자 인코딩 체크
```

**우선순위 결정**:
1. 가능성이 높은 가설부터
2. 검증하기 쉬운 가설부터
3. 영향이 큰 가설부터

---

### 3️⃣ 가설 검증 (Verify)

**목표**: 각 가설을 체계적으로 테스트

**검증 기법**:

#### A. 로그 추가
```javascript
console.log('[DEBUG] Input:', JSON.stringify(user));
console.log('[DEBUG] Query:', query);
console.log('[DEBUG] Result:', result);
```

#### B. 디버거 사용
```javascript
// Chrome DevTools, VS Code debugger
debugger;  // Break point
```

#### C. 이진 탐색
- 코드 절반씩 주석 처리하며 문제 범위 좁히기

#### D. 격리 테스트
```javascript
// 의심 함수만 따로 테스트
test('sanitizeInput with special chars', () => {
  const result = sanitizeInput("O'Brien");
  expect(result).toBe("O''Brien");  // SQL escape
});
```

**체크리스트**:
- [ ] 각 가설을 독립적으로 테스트했는가?
- [ ] 충분한 로그를 남겼는가?
- [ ] 중간 결과를 확인했는가?

---

### 4️⃣ 근본 원인 식별 (Identify Root Cause)

**목표**: 표면적 증상이 아닌 실제 원인 찾기

**5 Whys 기법**:
```markdown
1. 왜 사용자 생성이 실패하는가?
   → SQL 에러 발생

2. 왜 SQL 에러가 발생하는가?
   → 쿼리에 작은따옴표가 그대로 들어감

3. 왜 작은따옴표가 이스케이프되지 않았는가?
   → sanitize 함수가 호출되지 않음

4. 왜 sanitize 함수가 호출되지 않았는가?
   → ORM 사용 시에는 자동 이스케이프 기대했으나, raw query 사용

5. 왜 raw query를 사용했는가?
   → 성능 최적화를 위해 복잡한 쿼리를 raw로 작성
```

**근본 원인**: ORM 대신 raw query 사용 시 수동 이스케이프 누락

**관련 코드 분석**:
```javascript
// 문제 코드
const query = `INSERT INTO users (name, email) VALUES ('${user.name}', '${user.email}')`;
// ❌ 위험: SQL Injection + 특수문자 처리 안 됨

// 올바른 방법
const query = 'INSERT INTO users (name, email) VALUES (?, ?)';
db.execute(query, [user.name, user.email]);
// ✅ Parameterized query 사용
```

---

### 5️⃣ 수정 구현 (Fix)

**목표**: 최소 변경으로 버그 수정

**수정 원칙**:
1. **최소 변경**: 버그 수정에 필요한 최소한의 코드만 변경
2. **엣지 케이스 고려**: 유사한 문제가 다른 곳에도 있는지 확인
3. **테스트 추가**: 동일한 버그가 재발하지 않도록

**수정 예시**:
```javascript
// 수정 전
function createUser(user) {
  const query = `INSERT INTO users (name, email) VALUES ('${user.name}', '${user.email}')`;
  return db.execute(query);
}

// 수정 후
function createUser(user) {
  const query = 'INSERT INTO users (name, email) VALUES (?, ?)';
  return db.execute(query, [user.name, user.email]);
}
```

**회귀 테스트 추가**:
```javascript
describe('User creation', () => {
  test('should handle names with apostrophes', () => {
    const user = { name: "O'Brien", email: "test@example.com" };
    expect(() => createUser(user)).not.toThrow();
  });

  test('should handle names with quotes', () => {
    const user = { name: 'John "Doe"', email: "test@example.com" };
    expect(() => createUser(user)).not.toThrow();
  });

  test('should handle SQL injection attempts', () => {
    const user = { name: "'; DROP TABLE users--", email: "test@example.com" };
    expect(() => createUser(user)).not.toThrow();
  });
});
```

---

### 6️⃣ 확인 및 방지 (Verify & Prevent)

**목표**: 수정 검증 및 재발 방지

**검증 체크리스트**:
- [ ] 원래 버그가 수정되었는가?
- [ ] 새로운 버그가 생기지 않았는가?
- [ ] 모든 기존 테스트가 통과하는가?
- [ ] 엣지 케이스가 처리되는가?

**재발 방지**:

#### A. 코드 검색
```bash
# 유사한 패턴 찾기
grep -r "INSERT INTO.*VALUES.*\${" .
grep -r "raw query" .
```

#### B. Linting 규칙 추가
```javascript
// eslintrc.js
rules: {
  'no-template-curly-in-string': 'error',  // SQL 템플릿 리터럴 금지
}
```

#### C. 문서화
```markdown
## 배운 점

### 문제
Raw SQL query에서 특수문자 처리 누락으로 SQL 에러 발생

### 해결
Parameterized query 사용

### 재발 방지
1. 모든 raw query를 parameterized로 변경
2. ESLint 규칙 추가
3. 코드 리뷰 체크리스트에 추가

### 관련 이슈
- Issue #123
- PR #456
```

---

## 디버깅 도구

### JavaScript/Node.js
```javascript
// 1. console 활용
console.log('[DEBUG]', variable);
console.table(array);
console.trace();  // Call stack

// 2. debugger 사용
debugger;  // VS Code, Chrome DevTools

// 3. 조건부 디버깅
if (user.id === 123) {
  debugger;
}
```

### Python
```python
# 1. print 디버깅
print(f"[DEBUG] {variable=}")

# 2. pdb 사용
import pdb; pdb.set_trace()

# 3. logging
import logging
logging.debug(f"User: {user}")
```

### 브라우저
- Chrome DevTools
- React DevTools
- Redux DevTools
- Network 탭
- Performance 탭

---

## 디버깅 베스트 프랙티스

### ✅ 효과적인 디버깅

1. **침착함 유지**: 당황하지 말고 체계적으로 접근
2. **가정 없애기**: "이게 문제일 리 없어" 금지
3. **작은 변경**: 한 번에 하나씩 수정
4. **Git 활용**: 각 시도마다 커밋, 언제든 되돌리기
5. **휴식**: 막히면 잠시 쉬기 (rubber duck debugging)

### ❌ 피해야 할 실수

1. **무작위 변경**: 이것저것 바꿔보기
2. **로그 무시**: 에러 메시지를 제대로 안 읽기
3. **중복 수정**: 같은 버그를 여러 곳에서 임시방편으로 해결
4. **테스트 생략**: 수정 후 테스트 안 하기
5. **문서화 안 함**: 배운 것을 기록하지 않기

---

## 디버깅 체크리스트

```markdown
## 디버깅 체크리스트

### 재현 (Reproduce)
- [ ] 에러 메시지 전체 복사
- [ ] 재현 단계 문서화
- [ ] 최소 재현 케이스 작성
- [ ] 환경 정보 기록

### 가설 (Hypothesize)
- [ ] 가능한 원인 3-5개 나열
- [ ] 각 가설의 가능성 평가
- [ ] 우선순위 결정

### 검증 (Verify)
- [ ] 로그 추가
- [ ] 디버거 사용
- [ ] 격리 테스트 작성
- [ ] 각 가설 독립적으로 테스트

### 근본 원인 (Root Cause)
- [ ] 5 Whys 적용
- [ ] 관련 코드 분석
- [ ] 의존성 확인

### 수정 (Fix)
- [ ] 최소 변경으로 수정
- [ ] 엣지 케이스 고려
- [ ] 회귀 테스트 추가

### 확인 (Verify)
- [ ] 원래 버그 수정 확인
- [ ] 새 버그 없음 확인
- [ ] 모든 테스트 통과
- [ ] 유사 패턴 검색
- [ ] 재발 방지 조치
- [ ] 문서화
```

---

## 요약

효과적인 디버깅은:
- ✅ 체계적인 6단계 프로세스
- ✅ 재현 → 가설 → 검증 → 원인 → 수정 → 확인
- ✅ 근본 원인 해결 (임시방편 아님)
- ✅ 재발 방지 조치

**핵심**: 무작위가 아닌 과학적 접근!

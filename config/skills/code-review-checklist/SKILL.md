---
name: code-review-checklist
description: 체크리스트 기반 코드 리뷰 - 기능, 설계, 테스트, 보안, 성능
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
argument-hint: "[file-or-directory]"
---

# 코드 리뷰 체크리스트

체계적이고 일관성 있는 코드 리뷰를 위한 체크리스트입니다.

## 6가지 리뷰 관점

### 1️⃣ 기능 (Functionality)

**목표**: 코드가 의도대로 동작하는가?

#### 체크리스트
- [ ] **요구사항 충족**: PR이 요구사항을 모두 만족하는가?
- [ ] **정상 케이스**: 일반적인 사용 시나리오가 동작하는가?
- [ ] **엣지 케이스**: 경계 조건, 빈 값, null, undefined 처리
- [ ] **에러 처리**: 예외 상황을 적절히 처리하는가?
- [ ] **사용자 경험**: 사용자 관점에서 직관적인가?

#### 예시
```javascript
// ❌ Bad: 엣지 케이스 미처리
function divide(a, b) {
  return a / b;  // b가 0이면?
}

// ✅ Good: 엣지 케이스 처리
function divide(a, b) {
  if (b === 0) {
    throw new Error('Division by zero');
  }
  return a / b;
}
```

---

### 2️⃣ 설계 (Design)

**목표**: 코드 구조가 합리적인가?

#### 체크리스트
- [ ] **단일 책임 원칙** (SRP): 각 함수/클래스가 하나의 일만 하는가?
- [ ] **DRY**: 중복 코드가 없는가?
- [ ] **적절한 추상화**: 과도하지도, 부족하지도 않은가?
- [ ] **확장 가능성**: 미래 변경에 열려 있는가?
- [ ] **명확한 인터페이스**: API가 직관적인가?

#### 예시
```javascript
// ❌ Bad: 하나의 함수가 너무 많은 일
function processUser(user) {
  validateUser(user);
  saveToDatabase(user);
  sendEmail(user);
  logActivity(user);
  updateCache(user);
}

// ✅ Good: 단일 책임 분리
function processUser(user) {
  validateUser(user);
  saveUser(user);
  notifyUser(user);
}

function saveUser(user) {
  saveToDatabase(user);
  updateCache(user);
}

function notifyUser(user) {
  sendEmail(user);
  logActivity(user);
}
```

#### SOLID 원칙 체크
- **S**: Single Responsibility
- **O**: Open/Closed
- **L**: Liskov Substitution
- **I**: Interface Segregation
- **D**: Dependency Inversion

---

### 3️⃣ 테스트 (Tests)

**목표**: 충분한 테스트가 있는가?

#### 체크리스트
- [ ] **단위 테스트**: 핵심 로직에 테스트가 있는가?
- [ ] **커버리지**: 주요 경로가 테스트되는가? (최소 80%)
- [ ] **테스트 가독성**: 테스트 이름이 명확한가?
- [ ] **실패 시나리오**: 에러 케이스도 테스트하는가?
- [ ] **독립성**: 테스트 간 의존성이 없는가?

#### 예시
```javascript
// ✅ Good: 명확한 테스트
describe('calculateDiscount', () => {
  it('should apply 10% discount for regular users', () => {
    expect(calculateDiscount(100, 'regular')).toBe(90);
  });

  it('should apply 20% discount for premium users', () => {
    expect(calculateDiscount(100, 'premium')).toBe(80);
  });

  it('should throw error for invalid user type', () => {
    expect(() => calculateDiscount(100, 'invalid')).toThrow();
  });

  it('should handle zero amount', () => {
    expect(calculateDiscount(0, 'regular')).toBe(0);
  });
});
```

---

### 4️⃣ 보안 (Security)

**목표**: 보안 취약점이 없는가?

#### 체크리스트
- [ ] **입력 검증**: 모든 사용자 입력을 검증하는가?
- [ ] **SQL Injection**: Parameterized query 사용하는가?
- [ ] **XSS**: 사용자 입력을 이스케이프하는가?
- [ ] **인증/인가**: 권한 체크가 있는가?
- [ ] **민감 정보**: 비밀번호, API 키를 노출하지 않는가?
- [ ] **HTTPS**: 중요 데이터 전송 시 암호화하는가?

#### OWASP Top 10 체크
```markdown
1. [ ] Injection (SQL, NoSQL, Command)
2. [ ] Broken Authentication
3. [ ] Sensitive Data Exposure
4. [ ] XML External Entities (XXE)
5. [ ] Broken Access Control
6. [ ] Security Misconfiguration
7. [ ] Cross-Site Scripting (XSS)
8. [ ] Insecure Deserialization
9. [ ] Using Components with Known Vulnerabilities
10. [ ] Insufficient Logging & Monitoring
```

#### 예시
```javascript
// ❌ Bad: SQL Injection 취약
const query = `SELECT * FROM users WHERE id = ${userId}`;

// ✅ Good: Parameterized query
const query = 'SELECT * FROM users WHERE id = ?';
db.execute(query, [userId]);

// ❌ Bad: XSS 취약
element.innerHTML = userInput;

// ✅ Good: 이스케이프
element.textContent = userInput;
// 또는
element.innerHTML = escapeHtml(userInput);
```

---

### 5️⃣ 성능 (Performance)

**목표**: 성능이 적절한가?

#### 체크리스트
- [ ] **알고리즘 효율성**: 시간 복잡도가 적절한가? (O(n²) → O(n))
- [ ] **메모리 사용**: 메모리 누수가 없는가?
- [ ] **N+1 쿼리**: 반복문 안에 DB 쿼리가 없는가?
- [ ] **캐싱**: 반복 계산을 캐싱하는가?
- [ ] **지연 로딩**: 필요한 시점에만 로드하는가?

#### 예시
```javascript
// ❌ Bad: N+1 쿼리 문제
for (const user of users) {
  const posts = await db.getPosts(user.id);  // N번 쿼리
  user.posts = posts;
}

// ✅ Good: 한 번에 조회
const userIds = users.map(u => u.id);
const allPosts = await db.getPostsByUserIds(userIds);  // 1번 쿼리
users.forEach(user => {
  user.posts = allPosts.filter(p => p.userId === user.id);
});

// ❌ Bad: 비효율적 검색
const found = array.find(item => item.id === searchId);  // O(n)

// ✅ Good: 해시맵 사용
const map = new Map(array.map(item => [item.id, item]));
const found = map.get(searchId);  // O(1)
```

#### 성능 프로파일링
```javascript
// 시간 측정
console.time('operation');
// ... 코드 ...
console.timeEnd('operation');

// 메모리 측정
const used = process.memoryUsage();
console.log(`Memory: ${used.heapUsed / 1024 / 1024} MB`);
```

---

### 6️⃣ 가독성 (Readability)

**목표**: 다른 개발자가 쉽게 이해할 수 있는가?

#### 체크리스트
- [ ] **명확한 네이밍**: 변수/함수 이름이 의도를 표현하는가?
- [ ] **적절한 주석**: 복잡한 로직에 설명이 있는가?
- [ ] **일관된 스타일**: 프로젝트 컨벤션을 따르는가?
- [ ] **매직 넘버 없음**: 상수를 명명된 변수로 사용하는가?
- [ ] **함수 크기**: 함수가 너무 길지 않은가? (50줄 이하 권장)

#### 예시
```javascript
// ❌ Bad: 의미 없는 이름, 매직 넘버
function calc(x) {
  if (x > 18) {
    return x * 0.8;
  }
  return x;
}

// ✅ Good: 명확한 이름, 상수 사용
const ADULT_AGE = 18;
const ADULT_DISCOUNT_RATE = 0.8;

function calculateTicketPrice(age) {
  if (age >= ADULT_AGE) {
    return age * ADULT_DISCOUNT_RATE;
  }
  return age;
}

// ❌ Bad: 주석 없는 복잡한 정규식
const re = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$/;

// ✅ Good: 설명이 있는 정규식
// 비밀번호 검증: 최소 8자, 대문자/소문자/숫자 각 1개 이상
const PASSWORD_REGEX = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$/;
```

#### 네이밍 컨벤션
```javascript
// 변수/함수: camelCase
const userName = "John";
function getUserName() {}

// 상수: UPPER_SNAKE_CASE
const MAX_RETRY_COUNT = 3;

// 클래스: PascalCase
class UserService {}

// Boolean: is/has/should 접두사
const isValid = true;
const hasPermission = false;
const shouldRender = true;
```

---

## 리뷰 프로세스

### 코드 작성자 (Author)

**PR 생성 전 셀프 체크**:
```markdown
- [ ] 모든 테스트가 통과하는가?
- [ ] Linter 경고가 없는가?
- [ ] 커밋 메시지가 명확한가?
- [ ] 불필요한 코드(주석, console.log)를 제거했는가?
- [ ] PR 설명이 충분한가?
```

**PR 템플릿**:
```markdown
## 변경 사항
- [...]

## 왜 이 변경이 필요한가?
- [...]

## 어떻게 테스트했는가?
- [ ] 단위 테스트
- [ ] 수동 테스트
- [ ] 브라우저 테스트

## 스크린샷 (UI 변경 시)
[...]

## 체크리스트
- [ ] 테스트 추가
- [ ] 문서 업데이트
- [ ] Breaking change 없음
```

---

### 리뷰어 (Reviewer)

**리뷰 순서**:
1. **개요 파악**: PR 설명 읽기
2. **테스트 먼저**: 테스트 코드부터 리뷰
3. **핵심 로직**: 중요한 변경 사항 집중
4. **디테일**: 세부사항 확인
5. **전체 흐름**: 변경사항이 전체에 미치는 영향

**리뷰 코멘트 스타일**:
```markdown
# 😊 긍정적 피드백
👍 좋은 추상화입니다!
✨ 이 리팩토링으로 가독성이 훨씬 좋아졌네요.

# 🤔 제안
💡 이렇게 하면 어떨까요? [대안 제시]
❓ 이 부분이 필요한 이유가 궁금합니다.

# 🚨 반드시 수정 필요
⚠️ 이 부분은 SQL Injection 취약점이 있습니다.
🐛 null 체크가 누락되어 에러가 발생할 수 있습니다.

# 📝 작은 개선
✏️ 타이포: "recieve" → "receive"
🎨 일관성: 다른 곳에서는 camelCase를 사용하는데 여기는 snake_case네요.
```

**승인 기준**:
- ✅ **LGTM (Looks Good To Me)**: 문제없음, 머지 가능
- 🤔 **Approve with comments**: 사소한 개선사항 있지만 머지 가능
- ❌ **Request changes**: 반드시 수정 필요

---

## 전체 리뷰 체크리스트

```markdown
# 코드 리뷰 체크리스트

## 1. 기능 (Functionality)
- [ ] 요구사항 충족
- [ ] 정상 케이스 동작
- [ ] 엣지 케이스 처리
- [ ] 에러 처리 적절
- [ ] 사용자 경험 고려

## 2. 설계 (Design)
- [ ] 단일 책임 원칙
- [ ] DRY (중복 제거)
- [ ] 적절한 추상화
- [ ] 확장 가능성
- [ ] 명확한 인터페이스

## 3. 테스트 (Tests)
- [ ] 단위 테스트 존재
- [ ] 테스트 커버리지 충분 (80%+)
- [ ] 테스트 가독성
- [ ] 실패 시나리오 테스트
- [ ] 테스트 독립성

## 4. 보안 (Security)
- [ ] 입력 검증
- [ ] SQL Injection 방지
- [ ] XSS 방지
- [ ] 인증/인가 체크
- [ ] 민감 정보 보호

## 5. 성능 (Performance)
- [ ] 알고리즘 효율성
- [ ] 메모리 사용 적절
- [ ] N+1 쿼리 없음
- [ ] 적절한 캐싱
- [ ] 지연 로딩

## 6. 가독성 (Readability)
- [ ] 명확한 네이밍
- [ ] 적절한 주석
- [ ] 일관된 스타일
- [ ] 매직 넘버 없음
- [ ] 함수 크기 적절

## 기타
- [ ] Breaking change 없음
- [ ] 문서 업데이트
- [ ] 마이그레이션 필요 시 스크립트 포함
```

---

## 베스트 프랙티스

### ✅ 좋은 코드 리뷰

1. **빠른 리뷰**: 24시간 이내 (블로커 제거)
2. **건설적 피드백**: "이게 왜 나쁜가" → "이렇게 하면 더 좋아요"
3. **긍정적 톤**: 비난이 아닌 학습 기회
4. **명확한 우선순위**: 필수 수정 vs 제안 구분
5. **칭찬도 함께**: 좋은 코드에는 👍

### ❌ 피해야 할 실수

1. **nitpicking**: 사소한 것에 집착
2. **과도한 리뷰**: PR이 너무 크면 별도 분리 요청
3. **모호한 피드백**: "이상해요" → 구체적으로 설명
4. **권위적 태도**: "내 방식이 옳아"
5. **늦은 리뷰**: 며칠씩 방치

---

## 도구

- **GitHub**: Pull Request, Code Review
- **GitLab**: Merge Request
- **Gerrit**: 엄격한 리뷰 프로세스
- **Linter**: ESLint, Pylint, RuboCop
- **Formatter**: Prettier, Black
- **정적 분석**: SonarQube, CodeClimate

---

## 요약

효과적인 코드 리뷰는:
- ✅ 6가지 관점으로 체계적 검토
- ✅ 기능, 설계, 테스트, 보안, 성능, 가독성
- ✅ 건설적이고 긍정적인 피드백
- ✅ 빠른 응답 (24시간 이내)

**핵심**: 코드 품질 향상 + 지식 공유 + 팀워크!

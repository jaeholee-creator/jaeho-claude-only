---
name: tdd-cycle
description: 테스트 주도 개발 워크플로우 - Red(실패 테스트) → Green(통과) → Refactor
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
argument-hint: "[feature-name]"
---

# TDD 사이클 워크플로우

테스트 주도 개발(Test-Driven Development)을 체계적으로 진행하는 스킬입니다.

## TDD 3단계 사이클

### 🔴 1단계: Red - 실패하는 테스트 작성

**목표**: 구현하려는 기능의 명세를 테스트로 정의

**절차**:
1. 새 기능의 예상 동작을 명확히 정의
2. 해당 동작을 검증하는 테스트 작성
3. 테스트 실행 → **반드시 실패해야 함** (아직 구현 안 했으므로)
4. 실패 메시지 확인 (올바른 이유로 실패하는지 검증)

**예시 (JavaScript)**:
```javascript
// user.test.js
describe('User', () => {
  test('should create user with valid email', () => {
    const user = new User({
      name: 'John Doe',
      email: 'john@example.com'
    });

    expect(user.name).toBe('John Doe');
    expect(user.email).toBe('john@example.com');
    expect(user.isValid()).toBe(true);
  });

  test('should reject invalid email', () => {
    expect(() => {
      new User({ name: 'John', email: 'invalid-email' });
    }).toThrow('Invalid email format');
  });
});
```

**체크리스트**:
- [ ] 테스트가 실제로 실패하는가?
- [ ] 실패 이유가 명확한가?
- [ ] 테스트 이름이 의도를 잘 설명하는가?
- [ ] 하나의 동작만 테스트하는가?

---

### 🟢 2단계: Green - 테스트 통과하는 최소 코드

**목표**: 테스트를 통과시키는 가장 간단한 구현

**절차**:
1. 테스트를 통과시킬 최소한의 코드만 작성
2. 과도한 추상화, 최적화 하지 않기 (나중에 리팩토링에서!)
3. 테스트 실행 → **통과 확인**
4. 모든 기존 테스트도 여전히 통과하는지 확인

**예시 (JavaScript)**:
```javascript
// user.js
class User {
  constructor({ name, email }) {
    this.name = name;

    // 이메일 검증 (최소 구현)
    if (!email.includes('@')) {
      throw new Error('Invalid email format');
    }
    this.email = email;
  }

  isValid() {
    return this.name && this.email;
  }
}

module.exports = User;
```

**원칙**:
- ✅ KISS (Keep It Simple, Stupid)
- ✅ YAGNI (You Aren't Gonna Need It)
- ❌ 과도한 일반화 금지
- ❌ 미래를 위한 코드 금지

**체크리스트**:
- [ ] 테스트가 통과하는가?
- [ ] 코드가 최소한인가? (더 줄일 수 있나?)
- [ ] 모든 기존 테스트도 통과하는가?

---

### 🔵 3단계: Refactor - 코드 개선

**목표**: 테스트를 유지하면서 코드 품질 향상

**절차**:
1. 중복 코드 제거 (DRY 원칙)
2. 가독성 향상 (명확한 변수명, 함수 분리)
3. 디자인 패턴 적용 (필요한 경우)
4. 각 리팩토링 후 테스트 재실행 → **여전히 통과 확인**

**리팩토링 기법**:
- **Extract Method**: 긴 함수를 작은 함수로 분리
- **Rename Variable**: 의미 있는 이름으로 변경
- **Remove Duplication**: 공통 로직 추출
- **Simplify Conditionals**: 복잡한 조건문 단순화

**예시 (JavaScript - 리팩토링 후)**:
```javascript
// user.js (개선 버전)
class User {
  constructor({ name, email }) {
    this.name = name;
    this.email = this._validateEmail(email);
  }

  _validateEmail(email) {
    // 정규식으로 더 정확한 검증
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (!emailRegex.test(email)) {
      throw new Error('Invalid email format');
    }

    return email;
  }

  isValid() {
    return Boolean(this.name && this.email);
  }
}

module.exports = User;
```

**체크리스트**:
- [ ] 중복 코드가 제거되었는가?
- [ ] 코드 가독성이 향상되었는가?
- [ ] 테스트가 여전히 통과하는가?
- [ ] 성급한 최적화를 하지 않았는가?

---

## TDD 사이클 반복

```
Red → Green → Refactor → Red → Green → Refactor → ...
```

각 사이클은 작게 유지하세요 (5-10분).

## 추가 테스트 케이스

기본 기능이 완성되면 다음 테스트 추가:

### 엣지 케이스
```javascript
test('should handle empty name', () => {
  expect(() => {
    new User({ name: '', email: 'test@example.com' });
  }).toThrow();
});

test('should trim whitespace from email', () => {
  const user = new User({
    name: 'John',
    email: '  test@example.com  '
  });
  expect(user.email).toBe('test@example.com');
});
```

### 경계 조건
```javascript
test('should handle very long names', () => {
  const longName = 'a'.repeat(1000);
  const user = new User({
    name: longName,
    email: 'test@example.com'
  });
  expect(user.name.length).toBe(1000);
});
```

---

## TDD 베스트 프랙티스

### ✅ 좋은 습관

1. **작은 단위로 진행**: 한 번에 하나의 기능만
2. **빠른 피드백**: 테스트는 1초 이내에 실행
3. **명확한 테스트 이름**: `should_do_something_when_condition`
4. **독립적인 테스트**: 테스트 간 의존성 제거
5. **Given-When-Then 패턴**:
   ```javascript
   test('should calculate discount', () => {
     // Given: 초기 상태
     const price = 100;
     const discountRate = 0.1;

     // When: 동작 수행
     const result = calculateDiscount(price, discountRate);

     // Then: 결과 검증
     expect(result).toBe(90);
   });
   ```

### ❌ 피해야 할 실수

1. **Red 단계 건너뛰기**: 테스트 실패를 확인하지 않으면 테스트가 제대로 작동하는지 알 수 없음
2. **너무 큰 테스트**: 한 테스트에 여러 기능 검증
3. **구현 의존적 테스트**: 내부 구현을 테스트하면 리팩토링이 어려움
4. **느린 테스트**: DB, 네트워크 호출은 모킹

---

## 도구별 TDD 예시

### Python + pytest
```python
# test_calculator.py
import pytest
from calculator import Calculator

def test_add():
    calc = Calculator()
    assert calc.add(2, 3) == 5

def test_divide_by_zero():
    calc = Calculator()
    with pytest.raises(ZeroDivisionError):
        calc.divide(10, 0)
```

### TypeScript + Jest
```typescript
// calculator.test.ts
import { Calculator } from './calculator';

describe('Calculator', () => {
  let calc: Calculator;

  beforeEach(() => {
    calc = new Calculator();
  });

  it('should add two numbers', () => {
    expect(calc.add(2, 3)).toBe(5);
  });

  it('should throw on division by zero', () => {
    expect(() => calc.divide(10, 0)).toThrow();
  });
});
```

### Go
```go
// calculator_test.go
package calculator

import "testing"

func TestAdd(t *testing.T) {
    calc := NewCalculator()
    result := calc.Add(2, 3)

    if result != 5 {
        t.Errorf("Expected 5, got %d", result)
    }
}
```

---

## 요약

TDD는 다음을 보장합니다:
- ✅ **높은 테스트 커버리지**: 모든 코드가 테스트됨
- ✅ **더 나은 설계**: 테스트 가능한 코드는 좋은 설계
- ✅ **빠른 피드백**: 즉시 문제 발견
- ✅ **안전한 리팩토링**: 테스트가 안전망 역할
- ✅ **문서화**: 테스트가 사용 예시

**핵심 원칙**: Red → Green → Refactor를 짧은 사이클로 반복!

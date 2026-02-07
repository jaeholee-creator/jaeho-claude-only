---
name: refactor-guide
description: 안전한 리팩토링 가이드 - Extract, Rename, Move, Simplify
user-invocable: true
allowed-tools: Read, Edit, Grep, Glob, Bash
argument-hint: "[code-section]"
---

# 안전한 리팩토링 가이드

테스트를 유지하면서 코드 품질을 개선하는 리팩토링 카탈로그입니다.

## 리팩토링 기본 원칙

### 🎯 언제 리팩토링하는가?

**리팩토링 신호**:
- 중복 코드 (DRY 원칙 위반)
- 긴 함수 (50줄 이상)
- 큰 클래스 (500줄 이상)
- 긴 파라미터 리스트 (3개 이상)
- 복잡한 조건문 (중첩 3단계 이상)
- 주석이 필요한 복잡한 코드

**3의 법칙 (Rule of Three)**:
1. 첫 번째: 그냥 작성
2. 두 번째: 중복이지만 참기
3. 세 번째: 리팩토링!

---

## 안전한 리팩토링 절차

### 1️⃣ 테스트 먼저 작성/실행
```bash
# 리팩토링 전 모든 테스트가 통과하는지 확인
npm test
```

### 2️⃣ 작은 단위로 변경
한 번에 하나의 리팩토링만 수행

### 3️⃣ 각 변경 후 테스트
```bash
# 각 리팩토링 후 즉시 테스트
npm test
```

### 4️⃣ 커밋 자주 하기
```bash
# 각 리팩토링마다 커밋 (쉬운 롤백)
git add .
git commit -m "refactor: extract calculateTotal method"
```

### 5️⃣ 리뷰 받기
큰 리팩토링은 PR로 리뷰 요청

---

## 리팩토링 카탈로그

### 1️⃣ Extract Method (메서드 추출)

**언제**: 긴 함수, 중복 코드, 설명이 필요한 로직

**전**:
```javascript
function printOwing(invoice) {
  let outstanding = 0;

  console.log("***********************");
  console.log("**** Customer Owes ****");
  console.log("***********************");

  // Calculate outstanding
  for (const order of invoice.orders) {
    outstanding += order.amount;
  }

  // Print details
  console.log(`name: ${invoice.customer}`);
  console.log(`amount: ${outstanding}`);
}
```

**후**:
```javascript
function printOwing(invoice) {
  printBanner();
  const outstanding = calculateOutstanding(invoice);
  printDetails(invoice, outstanding);
}

function printBanner() {
  console.log("***********************");
  console.log("**** Customer Owes ****");
  console.log("***********************");
}

function calculateOutstanding(invoice) {
  return invoice.orders.reduce((sum, order) => sum + order.amount, 0);
}

function printDetails(invoice, outstanding) {
  console.log(`name: ${invoice.customer}`);
  console.log(`amount: ${outstanding}`);
}
```

**장점**:
- 가독성 향상
- 재사용 가능
- 테스트 용이

---

### 2️⃣ Rename (이름 변경)

**언제**: 의미 없는 이름, 오해의 소지가 있는 이름

**전**:
```javascript
function calc(d) {
  return d * 0.1;
}

const x = calc(100);
```

**후**:
```javascript
function calculateDiscount(price) {
  const DISCOUNT_RATE = 0.1;
  return price * DISCOUNT_RATE;
}

const discountedPrice = calculateDiscount(100);
```

**네이밍 가이드**:
```javascript
// Boolean
const isValid = true;
const hasPermission = false;
const shouldRender = true;

// 함수: 동사로 시작
function getUserById() {}
function saveUser() {}
function validateEmail() {}

// 배열: 복수형
const users = [];
const items = [];

// 상수: 대문자 스네이크 케이스
const MAX_RETRY_COUNT = 3;
const API_BASE_URL = "https://api.example.com";
```

---

### 3️⃣ Extract Variable (변수 추출)

**언제**: 복잡한 표현식

**전**:
```javascript
if (
  order.quantity > 10 &&
  order.price > 100 &&
  order.customer.isVIP
) {
  applyDiscount(order);
}
```

**후**:
```javascript
const isLargeOrder = order.quantity > 10;
const isHighValueOrder = order.price > 100;
const isVIPCustomer = order.customer.isVIP;

if (isLargeOrder && isHighValueOrder && isVIPCustomer) {
  applyDiscount(order);
}
```

---

### 4️⃣ Inline (인라인)

**언제**: 불필요한 간접 참조

**전**:
```javascript
function getRating(driver) {
  return moreThanFiveLateDeliveries(driver) ? 2 : 1;
}

function moreThanFiveLateDeliveries(driver) {
  return driver.numberOfLateDeliveries > 5;
}
```

**후**:
```javascript
function getRating(driver) {
  return driver.numberOfLateDeliveries > 5 ? 2 : 1;
}
```

---

### 5️⃣ Replace Magic Number (매직 넘버 제거)

**전**:
```javascript
function calculateDiscount(price) {
  if (price > 100) {
    return price * 0.9;
  }
  return price;
}
```

**후**:
```javascript
const PREMIUM_THRESHOLD = 100;
const DISCOUNT_RATE = 0.1;

function calculateDiscount(price) {
  if (price > PREMIUM_THRESHOLD) {
    return price * (1 - DISCOUNT_RATE);
  }
  return price;
}
```

---

### 6️⃣ Simplify Conditional (조건문 단순화)

#### A. 조기 반환 (Guard Clauses)

**전**:
```javascript
function getPayAmount(employee) {
  let result;
  if (employee.isSeparated) {
    result = { amount: 0, reason: "SEP" };
  } else {
    if (employee.isRetired) {
      result = { amount: 0, reason: "RET" };
    } else {
      result = { amount: employee.salary, reason: "NORMAL" };
    }
  }
  return result;
}
```

**후**:
```javascript
function getPayAmount(employee) {
  if (employee.isSeparated) {
    return { amount: 0, reason: "SEP" };
  }

  if (employee.isRetired) {
    return { amount: 0, reason: "RET" };
  }

  return { amount: employee.salary, reason: "NORMAL" };
}
```

#### B. 조건문을 다형성으로 (Polymorphism)

**전**:
```javascript
function getSpeed(bird) {
  switch (bird.type) {
    case "European":
      return getEuropeanSpeed(bird);
    case "African":
      return getAfricanSpeed(bird);
    case "Norwegian":
      return getNorwegianSpeed(bird);
    default:
      throw new Error("Unknown bird");
  }
}
```

**후**:
```javascript
class EuropeanBird {
  getSpeed() {
    // European bird logic
  }
}

class AfricanBird {
  getSpeed() {
    // African bird logic
  }
}

class NorwegianBird {
  getSpeed() {
    // Norwegian bird logic
  }
}

// 사용
const speed = bird.getSpeed();
```

---

### 7️⃣ Remove Duplication (중복 제거)

**전**:
```javascript
function createUser(name, email) {
  const user = {
    name,
    email,
    createdAt: new Date(),
    updatedAt: new Date(),
    id: generateId()
  };
  return user;
}

function createAdmin(name, email) {
  const admin = {
    name,
    email,
    createdAt: new Date(),
    updatedAt: new Date(),
    id: generateId(),
    role: "admin"
  };
  return admin;
}
```

**후**:
```javascript
function createBaseUser(name, email, additionalFields = {}) {
  return {
    name,
    email,
    createdAt: new Date(),
    updatedAt: new Date(),
    id: generateId(),
    ...additionalFields
  };
}

function createUser(name, email) {
  return createBaseUser(name, email);
}

function createAdmin(name, email) {
  return createBaseUser(name, email, { role: "admin" });
}
```

---

### 8️⃣ Replace Nested Conditional (중첩 조건 제거)

**전**:
```javascript
function getPrice(item) {
  if (item) {
    if (item.stock > 0) {
      if (item.discount) {
        return item.price * (1 - item.discount);
      } else {
        return item.price;
      }
    } else {
      return null;
    }
  } else {
    return null;
  }
}
```

**후**:
```javascript
function getPrice(item) {
  if (!item || item.stock === 0) {
    return null;
  }

  const basePrice = item.price;
  return item.discount
    ? basePrice * (1 - item.discount)
    : basePrice;
}
```

---

### 9️⃣ Extract Class (클래스 추출)

**언제**: 클래스가 너무 많은 책임을 가질 때

**전**:
```javascript
class Person {
  constructor(name, officeAreaCode, officeNumber) {
    this.name = name;
    this.officeAreaCode = officeAreaCode;
    this.officeNumber = officeNumber;
  }

  get telephoneNumber() {
    return `(${this.officeAreaCode}) ${this.officeNumber}`;
  }
}
```

**후**:
```javascript
class TelephoneNumber {
  constructor(areaCode, number) {
    this.areaCode = areaCode;
    this.number = number;
  }

  toString() {
    return `(${this.areaCode}) ${this.number}`;
  }
}

class Person {
  constructor(name, areaCode, number) {
    this.name = name;
    this.telephoneNumber = new TelephoneNumber(areaCode, number);
  }

  get telephoneNumber() {
    return this.telephoneNumber.toString();
  }
}
```

---

### 🔟 Replace Temp with Query (임시 변수를 쿼리로)

**전**:
```javascript
function getPrice(quantity, itemPrice) {
  const basePrice = quantity * itemPrice;
  const discount = basePrice > 1000 ? 0.05 : 0;
  return basePrice * (1 - discount);
}
```

**후**:
```javascript
function getPrice(quantity, itemPrice) {
  return getBasePrice(quantity, itemPrice) * (1 - getDiscount(quantity, itemPrice));
}

function getBasePrice(quantity, itemPrice) {
  return quantity * itemPrice;
}

function getDiscount(quantity, itemPrice) {
  const basePrice = getBasePrice(quantity, itemPrice);
  return basePrice > 1000 ? 0.05 : 0;
}
```

---

## 리팩토링 패턴

### 🔄 Replace Loop with Pipeline

**전**:
```javascript
const names = [];
for (const person of people) {
  if (person.age >= 18) {
    names.push(person.name);
  }
}
```

**후**:
```javascript
const names = people
  .filter(person => person.age >= 18)
  .map(person => person.name);
```

---

### 🔄 Consolidate Conditional (조건 통합)

**전**:
```javascript
function disabilityAmount(employee) {
  if (employee.seniority < 2) return 0;
  if (employee.monthsDisabled > 12) return 0;
  if (employee.isPartTime) return 0;
  // compute the disability amount
}
```

**후**:
```javascript
function disabilityAmount(employee) {
  if (isNotEligibleForDisability(employee)) {
    return 0;
  }
  // compute the disability amount
}

function isNotEligibleForDisability(employee) {
  return (
    employee.seniority < 2 ||
    employee.monthsDisabled > 12 ||
    employee.isPartTime
  );
}
```

---

## 리팩토링 체크리스트

```markdown
## 리팩토링 전

- [ ] 모든 테스트가 통과하는가?
- [ ] 버전 관리 시스템에 커밋했는가?
- [ ] 리팩토링 목표가 명확한가?

## 리팩토링 중

- [ ] 한 번에 하나씩 변경하는가?
- [ ] 각 변경 후 테스트하는가?
- [ ] 자주 커밋하는가?
- [ ] 막히면 롤백 준비되어 있는가?

## 리팩토링 후

- [ ] 모든 테스트가 통과하는가?
- [ ] 코드 가독성이 개선되었는가?
- [ ] 중복이 제거되었는가?
- [ ] 성능이 유지/개선되었는가?
- [ ] 문서를 업데이트했는가?
```

---

## 베스트 프랙티스

### ✅ 안전한 리팩토링

1. **테스트 먼저**: 리팩토링 전 테스트 작성/실행
2. **작은 단계**: 한 번에 하나씩
3. **자주 테스트**: 각 변경 후 즉시
4. **자주 커밋**: 롤백 가능하도록
5. **리뷰 요청**: 큰 리팩토링은 PR

### ❌ 위험한 리팩토링

1. **테스트 없이**: 회귀 버그 발생 가능
2. **큰 변경**: 문제 발생 시 원인 찾기 어려움
3. **기능 추가와 동시**: 리팩토링과 기능 추가는 분리
4. **성급한 최적화**: 필요하지 않은 추상화
5. **리뷰 없이**: 혼자 판단은 위험

---

## 리팩토링 도구

### IDE 기능
```
- Extract Method: Ctrl+Alt+M (VS Code)
- Rename: F2
- Extract Variable: Ctrl+Alt+V
- Inline: Ctrl+Alt+N
```

### 자동화 도구
- **JavaScript**: ESLint, Prettier
- **Python**: Black, isort, pylint
- **Java**: IntelliJ IDEA refactoring tools
- **TypeScript**: TSLint, Prettier

---

## 요약

안전한 리팩토링은:
- ✅ 테스트 유지하며 진행
- ✅ 작은 단위로 변경
- ✅ 각 변경 후 즉시 테스트
- ✅ 자주 커밋 (쉬운 롤백)
- ✅ 카탈로그 패턴 활용

**핵심**: 동작은 그대로, 구조만 개선!

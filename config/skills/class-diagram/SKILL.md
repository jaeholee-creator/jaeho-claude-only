---
name: class-diagram
description: 객체지향 설계를 위한 UML 클래스 다이어그램 생성
user-invocable: true
allowed-tools: Read, Grep, Glob, Write, Bash
argument-hint: "[module-name]"
---

# Class Diagram Generator

객체지향 구조와 관계를 시각화하는 UML 클래스 다이어그램을 생성합니다.

## 기본 문법

```mermaid
classDiagram
    class User {
        +String id
        +String email
        +String name
        -String passwordHash
        +login()
        +logout()
        +updateProfile()
    }
```

## 접근 제한자

| 기호 | 접근성 |
|------|--------|
| `+` | Public |
| `-` | Private |
| `#` | Protected |
| `~` | Package/Internal |

## 관계 타입

### Association (연관)

```mermaid
classDiagram
    class User {
        +String id
        +String email
    }

    class Post {
        +String id
        +String title
        +String content
    }

    User "1" --> "0..*" Post : creates
```

### Inheritance (상속)

```mermaid
classDiagram
    class Animal {
        <<abstract>>
        +String name
        +makeSound()*
    }

    class Dog {
        +String breed
        +makeSound()
        +fetch()
    }

    class Cat {
        +Boolean indoor
        +makeSound()
    }

    Animal <|-- Dog
    Animal <|-- Cat
```

### Interface Implementation

```mermaid
classDiagram
    class Serializable {
        <<interface>>
        +serialize() String
        +deserialize(data)
    }

    class User {
        +String id
        +serialize() String
        +deserialize(data)
    }

    Serializable <|.. User
```

### Composition & Aggregation

```mermaid
classDiagram
    class Order {
        +String id
        +Date createdAt
    }

    class OrderItem {
        +String productId
        +int quantity
    }

    class Customer {
        +String id
        +String name
    }

    Order *-- OrderItem : contains
    Order o-- Customer : belongs to
```

## 다중도 (Cardinality)

| 표기 | 의미 |
|------|------|
| `"1"` | 정확히 1개 |
| `"0..1"` | 0개 또는 1개 |
| `"0..*"` | 0개 이상 |
| `"1..*"` | 1개 이상 |
| `"n"` | N개 |

## 완전한 예제

```mermaid
classDiagram
    class User {
        +UUID id
        +String email
        +String name
        -String passwordHash
        +Date createdAt
        +login(email, password) Boolean
        +logout() void
        +updateProfile(data) User
    }

    class Post {
        +UUID id
        +String title
        +String content
        +UUID authorId
        +Date publishedAt
        +publish() void
        +unpublish() void
    }

    class Comment {
        +UUID id
        +String text
        +UUID postId
        +UUID authorId
        +Date createdAt
    }

    class Tag {
        +UUID id
        +String name
        +String slug
    }

    User "1" --> "0..*" Post : writes
    User "1" --> "0..*" Comment : writes
    Post "1" --> "0..*" Comment : has
    Post "0..*" --> "0..*" Tag : tagged with
```

## 디자인 패턴

### Repository Pattern

```mermaid
classDiagram
    class IRepository~T~ {
        <<interface>>
        +findById(id) T
        +findAll() List~T~
        +save(entity) T
        +delete(id) void
    }

    class UserRepository {
        -Database db
        +findById(id) User
        +findAll() List~User~
        +save(user) User
        +delete(id) void
        +findByEmail(email) User
    }

    IRepository <|.. UserRepository
```

### Service Layer

```mermaid
classDiagram
    class UserService {
        -UserRepository repository
        -PasswordHasher hasher
        -EmailService emailService
        +register(data) User
        +login(email, password) AuthResult
        +resetPassword(email) void
    }

    class UserRepository {
        +findByEmail(email) User
        +save(user) User
    }

    class PasswordHasher {
        +hash(password) String
        +verify(password, hash) Boolean
    }

    UserService --> UserRepository
    UserService --> PasswordHasher
```

## 작업 프로세스

1. **코드 분석**
   - LSP로 클래스/인터페이스 정의 찾기
   - 속성과 메서드 추출
   - 상속, 구성, 집합 관계 식별

2. **다이어그램 생성**
   - 클래스를 Mermaid 문법으로 매핑
   - 다중도와 함께 관계 추가
   - 접근 제한자 포함
   - 관련 클래스 그룹화

3. **렌더링**
   - `mermaid-render` 스킬 사용
   - `docs/design/` 디렉토리에 저장

## 출력 위치

`docs/design/` 디렉토리에 저장:
- `domain-model.svg`
- `service-layer.svg`
- `repository-pattern.svg`

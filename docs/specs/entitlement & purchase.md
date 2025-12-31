# Purchases & Entitlements Specification

> Context: Supabase + RevenueCat 기반 결제/권한 시스템  
> Purpose: 바이브 코딩 시 **결제/권한 도메인의 단일 컨텍스트 문서**

---

## 1. Design Principles

### Separation of Concerns

- **Purchases**: 결제/구매 “사실”을 기록하는 **불변 로그(audit log)**
- **Entitlements**: 유저가 현재 접근 가능한 **권한의 단일 진실(Single Source of Truth)**

### Read / Write Boundary

- **Write (create/update)**  
  → Edge Function + service role  
  → RevenueCat webhook 기반
- **Read (query)**  
  → Client Supabase SDK  
  → RLS로 본인 데이터만 접근

---

## 2. High-level Flow

```text
[User Purchase]
    ↓
[RevenueCat]
    ↓ (Webhook)
[Supabase Edge Function]
    ├─ insert purchase (idempotent)
    └─ upsert entitlement (current state)
    ↓
[Database]

[Client App]
    └─ Supabase SDK
        └─ SELECT entitlements (RLS)
```

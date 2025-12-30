# RevenueCat 설정 가이드

## 개요

이 프로젝트는 RevenueCat을 사용하여 인앱 구매와 구독을 관리합니다.

## RevenueCat 계정 설정

### 1. RevenueCat 계정 생성

1. [RevenueCat 웹사이트](https://www.revenuecat.com/)에 접속
2. 무료 계정 생성 (월 $2,500까지 무료)
3. 새 프로젝트 생성

### 2. 앱 설정

#### iOS 앱 설정

1. RevenueCat 대시보드에서 **Apps** 메뉴 선택
2. **+ New App** 클릭
3. 다음 정보 입력:
   - **App Name**: Korean Literature
   - **Bundle ID**: com.mailhyuil.library (iOS)
   - **Store**: App Store

#### Android 앱 설정

1. **+ New App** 클릭
2. 다음 정보 입력:
   - **App Name**: Korean Literature
   - **Package Name**: com.mailhyuil.library (Android)
   - **Store**: Google Play

### 3. API Keys 가져오기

1. RevenueCat 대시보드에서 **API Keys** 메뉴 선택
2. **Public API Keys** 섹션에서:
   - **Apple App Store** API Key 복사
   - **Google Play Store** API Key 복사

### 4. 환경 변수 설정

프로젝트 루트에 `.env` 파일을 생성하고 다음 내용을 추가:

```env
# Supabase
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# RevenueCat
REVENUECAT_APPLE_API_KEY=your_apple_api_key_here
REVENUECAT_GOOGLE_API_KEY=your_google_api_key_here
```

**주의**: `.env` 파일은 절대 Git에 커밋하지 마세요!

## Products & Offerings 설정

### 1. Products 생성

#### App Store Connect (iOS)

1. [App Store Connect](https://appstoreconnect.apple.com/) 로그인
2. **My Apps** > 앱 선택
3. **In-App Purchases** 섹션
4. **+** 버튼으로 신규 상품 생성
5. 상품 정보:
   - **Type**: Non-Consumable (컬렉션 구매)
   - **Product ID**: `collection_11111111_1111_1111_1111_111111111111`
   - **Price**: $2.99

#### Google Play Console (Android)

1. [Google Play Console](https://play.google.com/console/) 로그인
2. 앱 선택
3. **수익 창출** > **제품** > **인앱 상품**
4. **제품 만들기**
5. 상품 정보:
   - **Product ID**: `collection_11111111_1111_1111_1111_111111111111`
   - **가격**: $2.99

### 2. RevenueCat에 Products 추가

1. RevenueCat 대시보드 > **Products** 메뉴
2. **+ New** 클릭
3. 스토어에서 생성한 Product ID 입력
4. 양쪽 플랫폼 (iOS, Android) 모두 추가

### 3. Offerings 생성

1. RevenueCat 대시보드 > **Offerings** 메뉴
2. **+ New Offering** 클릭
3. Offering 정보:
   - **Identifier**: `default` (기본 Offering)
   - **Description**: Default offerings
4. **Packages** 추가:
   - **Identifier**: `collection_11111111_1111_1111_1111_111111111111`
   - **Product**: 위에서 생성한 Product 선택
5. **Make Current** 체크 (이 Offering을 기본으로 설정)

## Entitlements 설정

### 1. Entitlements 생성

1. RevenueCat 대시보드 > **Entitlements** 메뉴
2. **+ New Entitlement** 클릭
3. Entitlement 정보:
   - **Identifier**: `collection_11111111_1111_1111_1111_111111111111`
   - **Description**: 무료 컬렉션 액세스

### 2. Products와 Entitlements 연결

1. 생성한 Entitlement 선택
2. **Products** 섹션에서 **+ Add Product** 클릭
3. 해당 컬렉션의 Product 선택

## 테스트

### 1. 샌드박스 계정 생성 (iOS)

1. [App Store Connect](https://appstoreconnect.apple.com/)
2. **Users and Access** > **Sandbox Testers**
3. **+** 버튼으로 테스트 계정 생성

### 2. 테스트 라이센스 (Android)

1. [Google Play Console](https://play.google.com/console/)
2. **설정** > **라이선스 테스트**
3. 테스트 계정 이메일 추가

### 3. 앱에서 테스트

1. 에뮬레이터 또는 실제 기기에서 앱 실행
2. 컬렉션 목록 확인
3. 유료 컬렉션 탭
4. 구매 다이얼로그 확인
5. 샌드박스 계정으로 구매 진행
6. 구매 완료 후 컬렉션 잠금 해제 확인

## 트러블슈팅

### RevenueCat API Key가 설정되지 않았습니다

**증상**: 로그에 "⚠️ RevenueCat API Key가 설정되지 않았습니다" 표시

**해결책**:

1. `.env` 파일이 프로젝트 루트에 존재하는지 확인
2. API Key가 올바르게 입력되었는지 확인
3. 앱 재빌드 (`flutter clean && flutter run`)

### 구매가 작동하지 않음

**증상**: 구매 버튼을 눌렀지만 아무 일도 일어나지 않음

**해결책**:

1. RevenueCat 대시보드에서 Products와 Offerings가 올바르게 설정되었는지 확인
2. Product ID가 앱의 컬렉션 ID와 일치하는지 확인
3. 샌드박스 계정으로 로그인했는지 확인 (iOS)

### Entitlement가 작동하지 않음

**증상**: 구매 후에도 컬렉션이 잠금 상태

**해결책**:

1. RevenueCat 대시보드 > **Customers**에서 사용자의 Entitlements 확인
2. Product와 Entitlement가 올바르게 연결되었는지 확인
3. 앱 재시작

## 추가 자료

- [RevenueCat 공식 문서](https://docs.revenuecat.com/)
- [Flutter SDK 가이드](https://docs.revenuecat.com/docs/flutter)
- [RevenueCat Dashboard](https://app.revenuecat.com/)

## 결제 플로우

```txt
1. 사용자가 유료 컬렉션 탭
   ↓
2. CollectionDetailPage 표시
   ↓
3. "컬렉션 구매" 버튼 탭
   ↓
4. PurchaseDialog 표시
   ↓
5. RevenueCat Offerings 로드
   ↓
6. 상품 선택 및 구매
   ↓
7. CustomerInfo 업데이트
   ↓
8. Entitlements 자동 동기화
   ↓
9. 컬렉션 잠금 해제
```

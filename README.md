# Mople 
![iOS-Swift](https://img.shields.io/badge/platform-iOS-blue)
![Swift Version](https://img.shields.io/badge/swift-15.0-orange) 

<img width="1000" alt="무제 12_1" src="https://github.com/user-attachments/assets/00fce7b8-715c-4c19-a4d6-7ae7244f13fc" />


## Archiecture
<img width="500" alt="아키텍쳐 구성도_1" src="https://github.com/user-attachments/assets/ed1d4cd5-574b-4293-84d9-0b0a4d0594e6" />

## 기술 스택

- 아키텍처 & 설계 : Clean Architecture + ReactorKit
- 비동기 처리 : RxSwift
- 네트워크 통신 : URLSession + RxSwift
- 이미지 로딩 & 캐싱 : Kingfisher
- 로컬 데이터 저장 : Realm + UserDefaults
- 민감 정보 보호 : Keychain으로 사용자 토큰·이메일 등 보안 저장
- 협업 툴 : Jira, Notion, Discord, Figma

## 경험한 것

- 클린 아키텍처
  - 관심사의 명확한 분리: Presentation - Domain - Data 계층으로 책임 분리
  - 유지보수성 및 테스트 용이성 향상
  - 의존성 역전 원칙 적용으로 모듈 간 결합도 최소화
  - DI Container 의존성 주입을 통해 테스트 시 mock/테스트 유연한 처리

- ReactorKit
  - 단방향 데이터 흐름(UDF)을 통한 상태 관리 경험
  - Reactor는 사용자 액션을 받아 UseCase를 실행하고, 그 결과를 바탕으로 상태(State)를 업데이트
  - 각 계층의 명확한 역할 분리로 유지보수 및 테스트 용이성 확보

- 로그인 시스템 구현
  - 소셜 로그인(Kakao, Apple)을 통한 로그인 

- 로그인 상태 및 세션 관리
  - Keychain을 통한 보안 정보 관리

- JWT 토큰 사용 경험
  - API 요청 시 JWT 토큰을 사용하여 인증 처리
  - 토큰 만료 시 Refresh Token을 활용한 자동 재발급 로직 구현
  - 사용자 인증 및 권한 관리 경험
  - 자동 토큰 갱신 로직 및 만료 처리 구현

- 커스텀 UI, Alert 등 구현
  - 재사용 가능한 커스텀 뷰 및 컴포넌트 구현 경험
  - 커스텀 Alert 설계 및 구현

- API 통신 및 에러 처리
  - URLSession과 RxSwift 기반으로 효율적인 네트워크 처리
  - 공통 에러 처리 로직 설계 및 사용자 친화적인 에러 처리 구현
  - 네트워크 응답 모델(DTO)과 도메인 모델 간 변환(Mapping) 처리 경험

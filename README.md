# Mople 
![iOS-Swift](https://img.shields.io/badge/platform-iOS-blue)
![Swift Version](https://img.shields.io/badge/swift-15.0-orange) 

## Architecture
<img width="500" alt="아키텍쳐 구성도_1" src="https://github.com/user-attachments/assets/ed1d4cd5-574b-4293-84d9-0b0a4d0594e6" />

## Stack
- 아키텍처 & 설계 : Clean Architecture + ReactorKit
- 비동기 처리 : RxSwift
- 네트워크 통신 : URLSession + RxSwift
- 이미지 로딩 & 캐싱 : Kingfisher
- 이미지 업로드 : MultipartFrom
- 로컬 데이터 저장 : Realm + UserDefaults
- 민감 정보 보호 : Keychain
- 로그인 시스템 : Kakao, Apple
- 지도 시스템 : NMAPSMap
- 캘린더 : FSCalendar
- 알림 수신 및 화면 트랙킹 : Firebase
- 협업 툴 : Postman, Jira, Notion, Discord, Figma

## Experience
- 클린 아키텍처 및 ReactorKit 사용
  - Presentation 계층 (ViewController, Reactor)은 사용자 입력을 받고 상태(State)를 관리합니다.
  - Domain 계층 (UseCase)은 비즈니스 로직 수행을 담당하며, 데이터 요청을 처리합니다.
  - Data 계층 (Repository, NetworkService)은 실제 데이터 통신과 저장을 수행하며, Realm 및 URLSession을 활용합니다.
  - DI Container는 각 계층 간의 의존성을 주입하여 결합도를 낮추고, 테스트 시 Mock 객체를 주입할 수 있도록 구성했습니다.
 
- 코디네이터 패턴을 이용한 화면 관리
  - 코디네이터를 활용한 복잡한 화면 관리와 메모리 누수 방지
  - 앱 코디네이터 : 로그인, 메인 코디네이터 관리
  - 탭바 컨트롤러에 코디네이터 패턴 적용
 
- 커스텀 트랜지션 사용
  - 특정 화면(present/dismiss) 간 자연스러운 전환을 구현하여 사용자의 앱 경험을 향상시켰습니다.   
 
- RxCocoa / RxDataSource
  - RxCocoa를 이용한 UI 컴포넌트와의 데이터 바인딩 처리
  - RxDataSource를 활용한 효율적이고 유연한 테이블뷰 및 컬렉션뷰 관리

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
  - 자동 토큰 갱신 로직 및 만료 처리 구현
  - 사용자 인증 및 권한 관리 경험
  - API 요청이 동시에 발생할 때 토큰 만료로 인한 중복 갱신 요청 문제를 해결

- 커스텀 UI, Alert 등 구현
  - 재사용 가능한 커스텀 뷰 및 컴포넌트 구현 경험
  - 커스텀 Alert 설계 및 구현

- API 통신 및 에러 처리
  - URLSession과 RxSwift 기반으로 효율적인 네트워크 처리
  - 공통 에러 처리 로직 설계 및 사용자 친화적인 에러 처리 구현
  - 네트워크 응답 모델(DTO)과 도메인 모델 간 변환(Mapping) 처리 경험
  - 효율적인 데이터 요청을 위한 페이징 처리 구현
 
- 알림 및 딥링크 처리
  - 시스템 알림 수신을 통한 특정 화면 이동 구현
  - 초대링크(Scheme)를 통해 앱 실행 시 초대코드 파싱 및 모임 가입 처리
 
- 지도 및 위치 기반 기능
  - 장소 검색 및 지도에 위치 표시 구현
  - 외부 지도 앱과 연동하여 길찾기 기능 제공

- 애니메이션 및 화면 전환
  - 부드러운 애니메이션을 활용한 화면 전환
  - 네비게이션 간 자연스러운 전환을 위한 Transition 구현
 
## 스크린샷
<img width="1000" alt="무제 12_1" src="https://github.com/user-attachments/assets/00fce7b8-715c-4c19-a4d6-7ae7244f13fc" />
<img width="1000" alt="무제 13_1" src="https://github.com/user-attachments/assets/d6cc99f3-7005-46ca-a4d0-6b032ec7db59" />

![May-05-2025 07-24-07](https://github.com/user-attachments/assets/e6accc75-38f0-426c-aae6-32c825035c38)
![May-05-2025 07-23-41](https://github.com/user-attachments/assets/94d311e1-cdb4-4894-a071-f1290f5394e4)
![May-05-2025 07-22-49](https://github.com/user-attachments/assets/a9d92888-eae6-4c0b-9469-af94019565b7)



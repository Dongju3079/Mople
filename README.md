# Mople 
![iOS-Swift](https://img.shields.io/badge/platform-iOS-blue)
![Swift Version](https://img.shields.io/badge/swift-15.0-orange) 

<img width="1000" alt="무제 12_1" src="https://github.com/user-attachments/assets/00fce7b8-715c-4c19-a4d6-7ae7244f13fc" />


## Archiecture
<img width="500" alt="아키텍쳐 구성도_1" src="https://github.com/user-attachments/assets/ed1d4cd5-574b-4293-84d9-0b0a4d0594e6" />


## 기술 스택

🎯 플랫폼
iOS 15 이상 지원

🏗 아키텍처 & 설계
Clean Architecture + ReactorKit 기반 계층 분리

Coordinator 패턴으로 화면 전환 로직 관리

🔄 비동기 처리
RxSwift를 활용한 이벤트 드리븐 방식

🌐 네트워크 통신
URLSession + RxSwift 조합으로 API 호출 및 응답 처리

🖼 이미지 로딩 & 캐싱
Kingfisher로 비동기 이미지 다운로드 및 캐싱

💾 로컬 데이터 저장
Realm + UserDefaults를 이용한 캐시 및 설정 값 관리

🔒 민감 정보 보호
Keychain으로 사용자 토큰·비밀번호 등 보안 저장

✨ UI 컴포넌트 재사용성
Custom View 라이브러리화로 일관된 디자인·재사용성 강화

🤝 협업 툴
Jira, Notion, Discord, Figma를 통한 원활한 팀 커뮤니케이션







- [소개](#소개)
- [특징(Features)](#특징features)
- [아키텍처](#아키텍처)
- [설치 및 실행 방법](#설치-및-실행-방법)
- [사용 예시](#사용-예시)
- [코드 스니펫](#코드-스니펫)
- [기술 스택](#기술-스택)
- [라이선스](#라이선스)
- [문의](#문의)

---

## 2. 섹션별 작성 가이드

### 📖 소개
- 한두 문장으로 “이 프로젝트는 무엇인지”, “어떤 문제를 해결하는지” 를 요약  
- 핵심 기능 2~3가지를 나열

```markdown
## 소개
Mople은 사적인 모임 일정 관리 iOS 앱입니다.  
- **프라이빗 초대** 기반 멤버 관리  
- **캘린더 + 리스트** 동기화 뷰  
- **ReactorKit + 클린 아키텍처** 적용

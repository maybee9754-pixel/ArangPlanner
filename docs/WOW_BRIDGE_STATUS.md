# WoW 게임 적용 브리지 데모 (v0.5.0-demo)

현재 웹 스튜디오의 `docs/design.json` 6개 패널 좌표와 색상 값을 Lua 테이블 `Layout.lua`로 변환해 사용하는 **독립 시험판**을 로컬 ZIP으로 제작했습니다.

- 캔버스: 1440 × 810
- 구현: 상단 메뉴, 파밍 현황, 능력치 비교, 미획득 아이템, 중앙 장비 세팅, 오른쪽 전리품 목록
- 실제 연동: 장착 중인 아이템 아이콘/링크 조회, 캐릭터 모델 시도
- 미구현: 공허핵 스캔, 실제 보스 전리품 데이터, 정확한 파밍 달성률, 기존 GearPlanner 데이터 연동
- 실행 명령어: `/arang`
- 기존 애드온과 구분: `ArangPlanner` 폴더 별도, `GearPlanner`는 수정하지 않음

**현재 상태:** 게임용 ZIP은 대화에서 제공됨. 이 GitHub 저장소에 아직 애드온 소스와 Release ZIP이 게시되지는 않았습니다. Windows/WoW 게임 클라이언트에서 실제 테스트하지 않았습니다.

웹 스튜디오 변경은 `docs/design.json`에 적용되지만 WoW 클라이언트가 웹 데이터에 직접 접근하는 것은 아닙니다. 새 게임용 배포본을 만들 때마다 이 데이터로 `Layout.lua`를 생성하고 게임용 ZIP으로 묶어야 합니다.

## 다음 배포 단계

1. `ArangPlanner/ArangPlanner.toc`, `ArangPlanner/ArangPlanner.lua`, `ArangPlanner/Layout.lua` 전체 소스를 저장소에 업로드.
2. 구문 검사 및 WoW 인게임 확인.
3. 태그/Release로 검증한 ZIP 배포.
4. 업데이트 매니저로 설치 및 회귀 테스트.

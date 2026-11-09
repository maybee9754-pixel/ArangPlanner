# WoW Studio Bridge 현황

## v0.6.0-demo (개발 소스 등록됨)

- GitHub 게임용 애드온 소스: [ArangPlanner/](../ArangPlanner/)
- Lua 레이아웃: [ArangPlanner/Layout.lua](../ArangPlanner/Layout.lua)
- 웹 디자인 데이터: [docs/design.json](design.json)
- 테스트용 ZIP 자동 생성: [Build addon demo ZIP](../actions/workflows/demo-artifact.yml) → 성공한 실행의 **Artifacts**에서 다운로드

### 외형 수정
- 눈에 거슬리는 깨진 유니코드 심벌을 기본 도형 텍스처로 대체
- 패널과 헤더를 어두운 판타지 배경/은은한 보라색 테두리로 변경
- 왼쪽 원형 파밍 진행 표시를 게임용 도형으로 구현
- 중앙 캐릭터 뒤의 마법진과 장비 슬롯 장식 추가
- 상단 탭과 보스 목록 카드 외형 개선
- 실제 착용 장비 텍스처와 캐릭터 PlayerModel 유지

### 제한 사항
- 실제 파밍 수치 및 보스별 획득량은 **예시 데이터**입니다.
- WoW 클라이언트 실행 테스트는 아직 하지 않았습니다.
- 자동 ZIP 빌드가 GitHub Actions에서 성공하는지는 확인해야 합니다.
- **GitHub Release로 게시한 상태가 아니므로**, 윈도우 업데이트 매니저의 '새 버전 확인'에는 표시되지 않습니다.
- 웹 스튜디오에서 수정한 디자인이 게임에 즉시 동기화되는 구조는 아닙니다. 웹 디자인 수정 후 새 게임용 패키지가 필요합니다.
- 기존 GearPlanner 데이터/설정은 변경하지 않습니다.

이 데모는 실제 게임 UI 외형을 확인하기 위한 독립 시험판입니다.

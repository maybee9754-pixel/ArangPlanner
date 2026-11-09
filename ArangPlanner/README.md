# 아랑플래너 v1.2.0-alpha

기존 GearPlanner의 저작권 보호 소스 또는 미디어를 사용하지 않고 독립 작성한 UI 및 장비 등록 기능입니다.

## v1.2.0 새로운 인게임 UI

- 사용자가 확정한 **다크 차콜 / 톤 다운된 보라색 시안**을 게임용 TGA 텍스처와 실제 Lua UI 프레임으로 구현
- 광택이 있는 72px 상단 타이틀 바, 기본/활성/마우스오버 상태를 구분한 버튼
- 왼쪽: 전문화 및 목표 장비 통계, 미확인 목표 목록
- 중앙: 실제 장비 등록/제거/새로고침, 12개 단위 테이블, 페이지 이동
- 오른쪽: 전리품 추적 준비 상태 (획득 수치는 아직 계산하지 않으므로 임의 표시하지 않음)
- 상단 '장비 세팅 / 공격대 / 쐐기돌 / 획득 추적기 / 설정' 탭 전환. 미구현 탭에는 준비 중 안내가 나옴
- 아이템 ID 직접 입력, 가방 Shift+클릭, Ctrl+목표 클릭 제거 등 기존 동작 유지
- 실제 착용·가방 보유만 확인하며 미확인은 미획득 확정이 아님

## 게임 내 명령
- `/arang` 창 열기/닫기
- `/arang add 12345` 목표 등록
- `/arang remove 12345` 목표 제거
- `/arang scan` 장비 스캔
- `/arang status` 목표 통계
- `/arang debug` 전문화별 아이템 진단

## 배포와 설치
- 배포 ZIP `ArangPlanner_v1.2.0-alpha.zip`
- 기존 Windows 업데이터에 맞춰 `ArangPlanner/ArangPlanner.toc` 및 `ArangPlanner/ArangPlanner.lua`를 포함
- `ArangPlanner/Textures/` 아래 8종 TGA 텍스처 포함
- GitHub Actions가 `tools/render_v12_skin.py`로 PNG/TGA를 같은 규칙에서 생성
- WoW 완전 종료 → 기존 `ArangPlanner` 폴더 백업 → ZIP 설치 → 재시작 후 `/arang`
- 원본 `GearPlanner` 폴더와 `GearPlanner` SavedVariables는 절대 변경하지 않음
- 이전 `ArangPlannerDB` 구조를 유지하여 등록한 목표를 이어서 사용할 수 있게 설계

## 주의
웹에서 만든 시안과 최대한 비슷한 조명/그라데이션/톤으로 제작했지만, 웹 렌더러와 WoW UI는 다른 환경이라 픽셀 단위로 완전히 동일하지 않을 수 있습니다.
정식 획득 추적/공허핵/티어 변환 기능은 아직 구현되지 않았습니다.
Lua 구문 및 ZIP 구성은 자동 검사할 수 있지만 실제 WoW 클라이언트의 그래픽/인터랙션 테스트는 게임 내 확인이 필요합니다.

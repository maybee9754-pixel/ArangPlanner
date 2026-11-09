# 아랑플래너 v1.1.1-alpha

독립 작성한 WoW 장비 목표 관리 애드온입니다. 원본 GearPlanner Arang의 소스·미디어·프리셋·획득 기록은 포함하지 않습니다. 원본 GearPlanner의 모든 기능을 복제한 버전은 아닙니다.

## 구현
- `/arang`: 전문화별 목표 장비 테이블 열기/닫기
- 게임 UI에서 아이템 **ID 또는 아이템 링크**를 붙여넣어 등록/제거
- 전문화 전환 시 해당 전문화 목표 테이블을 자동 표시, 캐릭터별 분리 보관
- 목표 아이템의 상태: **착용**, **가방 보유**, **미확인** (과거 획득/은행 데이터는 보유로 간주하지 않음)
- 12개씩 페이지 이동. Shift+행 클릭으로 ID 입력, Ctrl+행 클릭으로 목표 제거
- 기존 `/arang add 아이템ID`, `/arang remove 아이템ID`, `/arang scan`, `/arang status` 유지
- 기존 v1.0.1의 `ArangPlannerDB.characters` 전문화별 목표 목록 호환

## 제한
현재 장비 및 가방에서 동일 **아이템 ID**가 확인되는지만 판정합니다. 아이템 변형/강화 수준 비교, 티어 변환 원본, 은행, 위대한 금고, 공격대/쐐기 공허핵 획득 증빙, 다른 전문화 아이템 반투명 표시는 아직 구현되지 않았습니다. `미확인`은 미획득 확정이 아닙니다.

## 설치
GitHub Release `ArangPlanner_v1.1.1-alpha.zip`을 다운로드하거나 기존 업데이트 매니저에서 설치합니다. ZIP 내부에 업데이트 매니저가 요구하는 `ArangPlanner/ArangPlanner.toc`와 `ArangPlanner/ArangPlanner.lua`가 포함됩니다. 이전 아랑플래너 폴더를 백업하고 설치 후 WoW 재시작. 기존 `GearPlanner` 폴더 및 그 SavedVariables는 변경하지 마세요.

## 독립 개발
Blizzard 게임 API만 사용하며 원본 GearPlanner의 All Rights Reserved 코드를 재배포하지 않습니다. 실제 WoW 클라이언트 전체 회귀 테스트는 별도로 필요합니다.

## v1.1.1 입력 오류 수정
- 기본 템플릿 입력칸을 글씨색과 포커스를 명시한 독립 EditBox로 교체
- 입력창 클릭 시 키보드 포커스 강제, 테두리 강조
- 가방 아이템 Shift+클릭 시 `ChatEdit_InsertLink` 후킹으로 입력란 자동 채움
- 실패 시 입력값 일부를 메시지로 출력하여 진단 가능
- 문제가 지속되면 `/arang add 12345` 명령으로 등록 가능

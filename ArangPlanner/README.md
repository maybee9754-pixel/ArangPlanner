# 아랑플래너 v1.0.0-alpha

기존 GearPlanner Arang의 사용 목적을 바탕으로 **별도 작성한 독립 개발 초기버전**입니다. 기존 GearPlanner의 All Rights Reserved 소스, 리소스, 프리셋, 기록은 포함하지 않습니다.

## 현재 가능한 작업
- `/arang` 창 열기/닫기
- 실제 장착 장비 16개 슬롯의 링크·아이콘 표시
- 캐릭터 GUID 및 전문화 ID별 목표 아이템 ID 저장
- `/arang add 12345`, `/arang remove 12345` 목표 등록·해제
- `/arang scan` 실제 착용 스캔, `/arang status` 착용 목표 통계

## 현재 불가능한 작업
- 기존 GearPlanner Arang v1.5 획득 추적, 공허핵/티어 원본 판정, 공격대/쐐기, 가방·은행 스캔, 주사위 하이라이트
- 기존 GearPlanner 데이터 자동 이전
- 완성된 GearPlanner급 UI. 현재 창은 최소 기능 검증용

**저장 키:** `ArangPlannerDB` (기존 GearPlanner 데이터에는 접근하지 않음). 이전 v0.9 UI 데모는 GitHub 이력에 남지만 해당 데모의 기능과 텍스처는 새 버전에 포함되지 않습니다.

설치: `_retail_/Interface/AddOns/ArangPlanner`에 폴더를 넣습니다. 기존 ArangPlanner가 있다면 **별도 백업** 후 교체하고 게임을 재시작합니다. 기존 GearPlanner 폴더는 삭제하지 마세요. WoW 클라이언트 실제 검증 전의 시험판입니다.

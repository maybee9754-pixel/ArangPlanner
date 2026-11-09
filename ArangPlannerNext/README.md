# Arang Planner Next (독립 구현 시험판)

> **공개 GitHub에 올려도 되는 독립 구현을 위한 첫 코드입니다.**
> 기존 GearPlanner 또는 GearPlanner Arang의 소스, 미디어, 비공개 프리셋, 획득 기록을 업로드하지 않았습니다.

이 폴더는 새롭게 작성한 간단한 WoW 애드온입니다. 현재 버전 `0.1.0-alpha`는 기존 GearPlanner Arang과 기능적으로 동등하지 않습니다.

## 현재 구현
- 다른 애드온과 이름/설정이 겹치지 않는 `ArangPlannerNext` 애드온
- `ArangPlannerNextDB`에 캐릭터 GUID 및 전문화 ID별 데이터 분리
- 실제 착용 슬롯 16개의 아이템 링크/아이콘 조회
- 장착 슬롯 스캔과 마지막 착용 아이템 ID 기록
- 사용자가 등록한 목표 itemID와 현재 착용 비교
- 간단한 게임 UI와 명령어

## 명령어
- `/arangnext`: 창 표시/숨기기
- `/arangnext scan`: 장착 장비 갱신
- `/arangnext add 12345`: 전문화의 목표 아이템 등록
- `/arangnext remove 12345`: 등록한 목표 제거
- `/arangnext status`: 목표/현재 착용 통계

## 하지 않는 기능
- 공허핵 획득/미획득 확정, 은행 및 가방 기록, 티어 변환 원본 추적
- 실제 레이드 보스·아이템 데이터베이스 및 프리셋
- 전문화 전환에 따른 다른 전문화 기록 표시
- 원본 GearPlanner의 데이터 가져오기
- 사용자가 제공한 v1.5 ZIP에 있는 원본 자산이나 코드를 포함하지 않음

## 설치 및 안전
`ArangPlannerNext` 폴더를 `_retail_/Interface/AddOns` 아래에 복사하세요. 원본 `GearPlanner` 및 기존 `ArangPlanner`와 별도 폴더/명령어/저장 키로 동작합니다.

이 코드는 개발용 알파이며 실제 WoW 클라이언트에서 실행 검증을 마치지 않았습니다. 외부 공개를 위한 법률 검토를 대체하지 않습니다.

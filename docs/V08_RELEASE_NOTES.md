# ArangPlanner v0.8.0-demo · 스타일 시스템 통일

## 이번 버전의 5단계

1. **타이틀 바**: 상단 그라데이션, 얇은 광선, 브랜드 영역 색조 개선
2. **버튼**: 기본/활성/마우스오버 3가지 텍스처와 반응형 발광 효과
3. **패널 헤더**: 모든 섹션의 이미지 스타일 통일, 보라색 강조
4. **슬롯과 패널**: 장비 슬롯/보스 목록 카드에 동일한 그라데이션 규칙 적용
5. **세부 배치**: 장비 슬롯 간격을 66→64로 줄이고 좌우 여백, 마법진 중심, 장신구 위치 소폭 조정

## 공통 이미지

`tools/render_textures.py`에서 같은 픽셀을 가진 PNG (웹) 및 TGA (WoW) 생성:
`title-bar`, `section-bar`, `button-active`, `button-idle`, `button-hover`, `slot-surface`, `panel-body`, `panel-header`, `arcane-circle`, `progress-ring`.

## 배포/설치

- 게임용 ZIP: `ArangPlanner_v0.8.0-demo.zip`
- 다운로드: [GitHub Releases](https://github.com/maybee9754-pixel/ArangPlanner/releases/tag/v0.8.0-demo)
- 배포 워크플로: [GitHub Actions](https://github.com/maybee9754-pixel/ArangPlanner/actions/workflows/demo-artifact.yml)
- 설치 위치: `World of Warcraft/_retail_/Interface/AddOns/ArangPlanner`
- 설치 후 게임 완전 재시작 → `/arang`

이 버전은 **UI 외형 시험판**입니다. 파밍 현황, 능력치 비교, 전리품의 숫자는 예시 데이터이며, 기존 GearPlanner와 데이터 연동하지 않습니다. WoW 게임 클라이언트에서의 최종 확인은 별도로 필요합니다.

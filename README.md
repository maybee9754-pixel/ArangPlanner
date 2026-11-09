# ArangPlanner | 아랑플래너

World of Warcraft용 **아랑플래너** 개발 저장소입니다.

> **현재 상태: 개발/시험 단계.** 게임 내 UI 시안은 확정되었지만 실제 기능이 구현된 정식판은 아직 배포하지 않았습니다. 자동 업데이트를 위한 GitHub Release도 아직 게시하지 않았습니다.

## 설치 없는 웹 스튜디오 (열람 전용)

- 웹주소: https://maybee9754-pixel.github.io/ArangPlanner/
- Python, GitHub CLI, WoW 설치 필요 없음. 웹브라우저에서 열람
- 상단 **최신 디자인 업데이트** 버튼으로 `docs/design.json`을 캐시 무시하고 새로 불러옴
- 이 저장소의 `docs/design.json`을 수정하면 다음 조회 시 디자인이 반영됨
- 처음 한 번: 저장소 **Settings → Pages → Build and deployment → Source: GitHub Actions** 활성화 필요할 수 있음
- GitHub Pages 자동 배포: `.github/workflows/pages.yml`
- 웹 미리보기는 게임 자체 실행이나 정식 애드온 패키지가 아닙니다.

## 확정 UI 방향
- 왼쪽: 파밍 현황, 능력치 비교, 미획득 아이템
- 가운데: 캐릭터 모델과 착용 장비 및 장신구
- 오른쪽: 보스별 전리품 목록
- 디자인: Wythic+ 장비 배치와 EXBOSS 계열의 어두운 패널 UI를 참고한 절제된 보라색 발광, 얇은 테두리

## 버전 안내
이전에 공유한 `v0.4.0-demo`는 **UI 시험용**으로, 실제 공허핵 스캔 및 획득 추적 완성본이 아닙니다. 초기 데모 파일은 사용자 로컬의 별도 ZIP으로 보유 중이며, 현재 이 저장소에는 소스가 아직 등록되지 않았습니다.

## 업데이트 운영 계획
1. 검증한 `ArangPlanner/` 폴더(TOC, Lua, 필요한 이미지 리소스)를 버전 관리에 등록합니다.
2. GitHub Actions를 사용해 검사 후 `ArangPlanner_vX.Y.Z.zip` 파일을 Release로 게시합니다.
3. Windows 업데이트 매니저가 이 저장소의 `releases/latest`를 확인하여 설치합니다.
4. 게임 안에서 `/reload`를 실행합니다. 신규 TOC/리소스 변경 시 게임 재시작이 필요할 수 있습니다.

배포 규칙: [docs/UPDATE_PROTOCOL.md](docs/UPDATE_PROTOCOL.md)  
개발 현황: [docs/DEVELOPMENT_STATUS.md](docs/DEVELOPMENT_STATUS.md)

**주의:** 기존 GearPlanner 폴더 및 게임 개인 저장 데이터(`WTF/`, `SavedVariables/`)는 저장소나 배포 ZIP에 포함하지 않습니다.

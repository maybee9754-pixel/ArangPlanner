# v0.7.0-demo: 웹 스튜디오 / WoW 공통 텍스처

## 변경 사항
- **같은 생성 코드** `tools/render_textures.py`로 웹용 PNG와 게임용 TGA 생성
- 이미지 4종: `panel-body`, `panel-header`, `progress-ring`, `arcane-circle`
- 실제 WoW Lua: `ArangPlanner/ArangPlanner.lua`에서 TGA 텍스처 경로 사용
- 웹 스튜디오: `docs/index.html`에서 PNG 자산 사용
- 기존 실제 착용 장비 아이콘과 캐릭터 3D 모델은 유지
- 파밍 수치와 보스 전리품은 **예시 데이터**로 유지

## 자동 배포
- 소스/텍스처 생성 코드가 변경되면 `.github/workflows/demo-artifact.yml` 실행
- Lua 구문 검사와 ZIP 경로/구성 검증 후 `v0.7.0-demo` GitHub Release 생성 시도
- ZIP: `ArangPlanner_v0.7.0-demo.zip`
- Release에서 ZIP을 다운로드하거나, Release 게시 후 업데이트 매니저에서 **새 버전 확인** 사용
- 릴리스가 아직 성공하지 않았으면 업데이터에서 404가 뜰 수 있습니다.

## 게임 설치
1. WoW를 종료합니다.
2. 업데이트 매니저에서 ZIP 설치. 대상: `World of Warcraft/_retail_/Interface/AddOns`
3. 기존 `ArangPlanner`는 백업한 뒤 교체하며, `GearPlanner`는 변경하지 않습니다.
4. WoW를 재시작하고 `/arang` 입력.

## 주의
- v0.7은 외형 **시험판**, 실제 획득 추적 기능이 아닙니다.
- 새 TGA 자산을 게임이 읽어야 하므로 반드시 WoW 재시작 후 확인합니다.
- GitHub Actions 실행 성공 및 실제 WoW에서의 렌더링은 별도 검증이 필요합니다.
- 웹 모델과 WoW PlayerModel은 서로 다릅니다.

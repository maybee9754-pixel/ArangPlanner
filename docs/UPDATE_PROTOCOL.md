# Arang Planner 자동 업데이트 배포 규칙

## 대상 저장소

`maybee9754-pixel/ArangPlanner`

## 배포 원칙

1. 테스트를 통과한 애드온 폴더 `ArangPlanner/`를 ZIP 루트에 둡니다.
2. ZIP에는 `ArangPlanner.toc`와 모든 필요한 Lua / 이미지 리소스가 포함되어야 합니다.
3. ZIP 안에 `WTF/`, `SavedVariables/` 등 개인 설정 및 게임 기록을 넣지 않습니다.
4. GitHub Release 태그는 `v0.5.0`과 같이 고유한 버전을 사용합니다.
5. Release asset 이름은 `ArangPlanner_vX.Y.Z.zip` 형식을 권장합니다.
6. 안정화 전에는 배포를 prerelease로 표시하고, 설치기는 기본적으로 prerelease를 무시하도록 설계합니다.
7. 설치기는 신뢰된 GitHub 저장소와 릴리스 자산 URL만 허용하며, 임의 URL로부터 설치하지 않습니다.
8. 업데이트 전에 기존 `AddOns/ArangPlanner` 폴더를 백업하고, 새 ZIP의 경로 및 파일 구성과 해시를 검증합니다.
9. 파일 교체 후 변경된 Lua는 게임에서 `/reload`로 적용할 수 있으나, TOC/신규 리소스는 게임 재시작이 필요할 수 있습니다.

## 현재 연결 상태

- GitHub 저장소 생성 확인
- GitHub 소스 저장소 초기 문서 설정 중
- 실제 애드온 ZIP GitHub Release **미게시**
- 업데이트 매니저 자동 다운로드 **미연결**

이 문서는 향후 배포 운영 지침입니다.

#!/usr/bin/env python3
"""Guard the shared web/game geometry and font contract."""
from pathlib import Path
import json, re

root=Path(__file__).resolve().parent.parent
data=json.loads((root/"docs/design.json").read_text(encoding="utf-8"))
toc=(root/"ArangPlanner/ArangPlanner.toc").read_text(encoding="utf-8")
lua=(root/"ArangPlanner/UI.lua").read_text(encoding="utf-8")
web=(root/"docs/index.html").read_text(encoding="utf-8")
contract=(root/"ArangPlanner/UIContract.lua").read_text(encoding="utf-8")
css=(root/"docs/ui-contract.css").read_text(encoding="utf-8")
version=data["gameVersion"]
assert f"## Version: {version}" in toc
assert "UIContract.lua\nUI.lua" in toc
assert "ArangPlanner v"+version in lua
assert "ArangPlanner v"+version in web
assert "C_AddOns.GetAddOnMetadata" in lua
assert "ArangPlannerUIContract" in contract
assert "local U=_G.ArangPlannerUIContract" in lua
assert "'ArangNanum'" in css
assert "FONT_ROOT" in lua and "SetFont(file,wanted" in lua
assert "ui-contract.css?v=1.3.0" in web
assert "applyLayout(data)" in web
assert "helpLines" in lua and "game-help" in web
assert "rightHelpLineHeight" in lua
assert set(data["panels"]) == {"header","left","middle","right"}
for i,p in enumerate(data["tabs"]):
    assert p["w"]>0 and p["h"]>0
    assert f".head .nav .tab:nth-child({i+1})" in css
for field in ["controls","table","typography","typeface"]:
    assert field in data
for k in ["NanumGothic-Regular.ttf","NanumGothic-Bold.ttf","NanumGothic-ExtraBold.ttf"]:
    assert k in css and k in contract
    if (root/"ArangPlanner/Fonts").exists():
        assert (root/"ArangPlanner/Fonts"/k).stat().st_size>100000
print("PASS: WoW/web version, generated geometry, shared font, help spacing, and texture contracts")

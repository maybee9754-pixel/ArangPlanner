#!/usr/bin/env python3
"""Validate the native game v1.4 and legacy web studio independently."""
from pathlib import Path
import json
root=Path(__file__).resolve().parent.parent
data=json.loads((root/"docs/design.json").read_text(encoding="utf-8"))
toc=(root/"ArangPlanner/ArangPlanner.toc").read_text(encoding="utf-8")
ui=(root/"ArangPlanner/UI.lua").read_text(encoding="utf-8")
core=(root/"ArangPlanner/ArangPlanner.lua").read_text(encoding="utf-8")
contract=(root/"ArangPlanner/UIContract.lua").read_text(encoding="utf-8")
css=(root/"docs/ui-contract.css").read_text(encoding="utf-8")
web=(root/"docs/index.html").read_text(encoding="utf-8")
assert "## Version: 1.5.0-alpha" in toc
assert "ArangPlanner.lua\nUIContract.lua\nSeasonData.lua\nLootCatalog.lua\nUI.lua" in toc
assert "_G.ArangPlanner" in core and "GearPlannerDB" not in core
assert "specBacking" in ui and "SetInventoryItem" in ui
assert "AP.LootCatalog.Instances" in ui and "AP.LootCatalog.Loot" in ui
assert "AP.GetTargetRows" in ui and "AP.TargetCounts" in ui
assert "AP.AddTarget" in ui and "AP.RemoveTarget" in ui
assert "ChatEdit_InsertLink" in ui and "AP.ToggleUI" in ui
assert 'ap-logo.tga' in ui
assert "ArangPlannerUIContract" in contract
assert "'ArangNanum'" in css
assert "applyLayout(data)" in web and "ui-contract.css?v=1.3.0" in web
assert len(data["tabs"])==5 and set(data["panels"])=={"header","left","middle","right"}
for font in ["NanumGothic-Regular.ttf","NanumGothic-Bold.ttf","NanumGothic-ExtraBold.ttf"]:
    assert font in css
    p=root/"ArangPlanner/Fonts"/font
    if p.exists():assert p.stat().st_size>100000
print("PASS: Native v1.4 gameplay UI, AP skin, target operations and legacy web v1.3 separately")

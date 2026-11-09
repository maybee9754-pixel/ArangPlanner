#!/usr/bin/env python3
"""Prevent silent desynchronization between the WoW visual and website preview.
This verifies the common graphic assets, coordinates, text sizes, and version
contract. It does not claim pixel-perfect render equivalence.
"""
from pathlib import Path
import json, re

root=Path(__file__).resolve().parent.parent
d=json.loads((root/"docs/design.json").read_text(encoding="utf-8"))
toc=(root/"ArangPlanner/ArangPlanner.toc").read_text(encoding="utf-8")
lua=(root/"ArangPlanner/UI.lua").read_text(encoding="utf-8")
web=(root/"docs/index.html").read_text(encoding="utf-8")
skin=(root/"tools/render_v12_skin.py").read_text(encoding="utf-8")
version=d["gameVersion"]
assert "## Version: "+version in toc, "TOC / design.json version mismatch"
assert "ArangPlanner v"+version in lua, "Lua header not updated"
assert "ArangPlanner v"+version in web, "Web header not updated"
assert 'applyLayout(data)' in web, "Web update must apply geometry, not just revision"
assert 'data.panels' in web, "Web must consume docs/design.json geometry"
assert "rightHelpLineHeight" in d["typography"], "Missing vertical rhythm"
assert "helpLines" in lua and "game-help" in web, "Right panel help not aligned"
assert "21)" in lua or "*21)" in lua, "Game line spacing not fixed"
for name in d["assets"]:
    assert f'face("{name}"' in skin, f"Generator missing {name}"
    assert f'assets/{name}.png' in web or f'"{name}.png"' in web or name in ["panel-header","panel-body","button-idle","button-active","button-hover","row-hover","row"], f"Web may not load {name}"

geometry={
    "header":r"frame\(root,12,12,1246,72",
    "left":r"frame\(root,12,97,258,608",
    "middle":r"frame\(root,281,97,697,608",
    "right":r"frame\(root,989,97,269,608",
}
for key,pattern in geometry.items():
    assert re.search(pattern,lua), f"Game panel {key} geometry diverged"
    p=d["panels"][key]
    expected={"header":(12,12,1246,72),"left":(12,97,258,608),"middle":(281,97,697,608),"right":(989,97,269,608)}[key]
    assert tuple(p[k] for k in ("x","y","w","h"))==expected, f"Web {key} geometry diverged"
print("PASS: same version, geometry, typography contract and skin source")

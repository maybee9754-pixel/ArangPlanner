#!/usr/bin/env python3
"""Fetch OFL-licensed Nanum Gothic for both builds from a single upstream.
Fonts remain third-party OFL assets; never treat them as ArangPlanner code.
"""
from pathlib import Path
from urllib.request import urlopen, Request
import hashlib,sys

root=Path(__file__).resolve().parent.parent
targets=[root/"ArangPlanner/Fonts",root/"docs/assets/fonts"]
base="https://raw.githubusercontent.com/google/fonts/main/ofl/nanumgothic/"
files=["NanumGothic-Regular.ttf","NanumGothic-Bold.ttf","NanumGothic-ExtraBold.ttf","OFL.txt"]
for filename in files:
    req=Request(base+filename,headers={"User-Agent":"ArangPlanner-independent-build/1.3"})
    with urlopen(req,timeout=90) as response:
        data=response.read()
    if filename.endswith(".ttf"):
        if not data.startswith(b"\x00\x01\x00\x00") or len(data)<100_000:
            raise RuntimeError("Invalid TTF fetched: "+filename)
    else:
        if b"SIL OPEN FONT LICENSE" not in data:
            raise RuntimeError("Missing OFL license")
    for folder in targets:
        folder.mkdir(parents=True,exist_ok=True)
        (folder/filename).write_bytes(data)
    print(filename,len(data),hashlib.sha256(data).hexdigest())
print("Both output folders have identical font bytes.")

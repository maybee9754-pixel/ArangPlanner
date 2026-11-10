-- Original season provider. Add verified IDs here at each season update.
-- Source records may be extended without changing UI or character SavedVariables.
local AP=_G.ArangPlanner
AP.ExtraSeasonSources={raid={},dungeon={},delve={},outdoor={}}

-- Verified "additional loot" that is cosmetic/collectible and must never be
-- registered as combat gear, even when WoW assigns an equipment slot.
-- Extend with verified IDs for future seasons, not guessed names/IDs.
AP.ExtraLootExcludedItems={
    [281227]=true, -- Soulcoiler's Rush'kah: Nek'zali cosmetic head appearance
}


-- Season 2 Tier 36 token mapping. Unlike wearables, these consumable tokens
-- generate combat tier armor. Never treat owning a token as owning the armor.
-- Item IDs are arranged in four armor-class groups per part.
AP.TierTokens={}
local armorGroups={
 {name="맹독매듭",classes={[5]=true,[8]=true,[9]=true}},
 {name="맹독경화",classes={[4]=true,[10]=true,[11]=true,[12]=true}},
 {name="맹독주조",classes={[3]=true,[7]=true,[13]=true}},
 {name="맹독단조",classes={[1]=true,[2]=true,[6]=true}},
}
local parts={
 {start=270910,slot=10,suffix="우상",boss="sentinels"},
 {start=270914,slot=1,suffix="입상",boss="fangs"},
 {start=270918,slot=7,suffix="성물",boss="sszorak"},
 {start=270922,slot=3,suffix="잔재",boss="explorers"},
 {start=270926,slot=5,suffix="표징",boss="vashnik"},
}
for _,part in ipairs(parts) do
 for i,g in ipairs(armorGroups) do
  AP.TierTokens[part.start+i-1]={
   id=part.start+i-1,slot=part.slot,boss=part.boss,
   name=g.name.." "..part.suffix,classes=g.classes,kind="tierToken"
  }
 end
end
AP.TierTokenBossNames={
 sentinels={"매장된 파수꾼","Entombed Sentinels"},
 fangs={"쌍둥이 송곳니","Twin Fangs"},
 sszorak={"스조라크","Sszorak"},
 explorers={"길 잃은 탐험가","Lost Explorers"},
 vashnik={"바쉬니크","Vashnik"},
}
-- The browser lists the actual wearable tier armor, never its source token.
-- Verified live 12.1 Rogue tier-set item IDs, one actual equip item per slot.
-- Do not guess other classes' item IDs: unverified mappings remain hidden.
AP.TierRewardItems={
 [4]={ -- Rogue: Chosen Bloodslayer's Hexweave
  [1]=271510, -- Chosen Bloodslayer's Spirit Shroud
  [3]=271508, -- Chosen Bloodslayer's Voodoo Guards
  [5]=271513, -- Chosen Bloodslayer's Banded Poncho
  [10]=271511, -- Chosen Bloodslayer's Fanged Grips
  [7]=271509, -- Chosen Bloodslayer's Reinforced Pants
 },
}
-- Season token IDs are acquisition-source metadata. Never use token itemID
-- as the displayed or registered target if a wearable result exists.
-- Only explicitly confirmed additional-loot cosmetic IDs are excluded.

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

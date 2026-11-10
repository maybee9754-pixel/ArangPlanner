# ArangPlanner v1.8.0-alpha

UI: black/gold, with compact mode, slot-click gear targeting, and equipment-only registration. The right loot browser is now item-first like classic GearPlanner Arang: **category → raid/dungeon → actual wearable item → source boss / loot route**. Raid items are aggregated from all bosses and grouped at raid level (no nested boss rows). Dungeon items remain aggregated from all dungeon bosses. Each item row uses Blizzard item icon and a separate second line for its verified encounter source. Unverified delve/outdoor loot remains empty rather than fictional.

Season 2 tier bosses drop class/armor-group tokens, but **the browser displays the actual resulting tier armor item**, not the consumable token. Internal token ID is solely source metadata. v1.8 currently includes externally verified Rogue (class 4) armor IDs for the five Tier 36 slots:
- Head 271510 (Chosen Bloodslayer's Spirit Shroud)
- Shoulder 271508 (Chosen Bloodslayer's Voodoo Guards)
- Chest 271513 (Chosen Bloodslayer's Banded Poncho)
- Hands 271511 (Chosen Bloodslayer's Fanged Grips)
- Legs 271509 (Chosen Bloodslayer's Reinforced Pants)

The source is shown as “매장된 파수꾼 · 티어 교환” for gloves. Other classes' unverified tier item IDs are deliberately omitted rather than replaced with token items or guessed IDs; class coverage will be expanded once verified. Relevant non-tier items still come from the in-game Encounter Journal.

The registered target ID is always a wearable gear item ID; **a tier token owned in bags does not count as possessing the tier armor**. Old season data, saved target slots, legacy GearPlanner databases and old tokens remain untouched.

Automated CI checks Lua syntax, native API mocks for actual tier gear and boss source, loot grouping, target-slot matching and release ZIP integrity. This test does not replace verification inside the WoW client.

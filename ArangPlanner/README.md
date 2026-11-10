# ArangPlanner 1.7.0-alpha

This update preserves the original black/gold GUI, independently written core, existing spec-specific empty gear-target slots, current-slot filtering, registration and compact mode.

Loot navigator is intentionally structured as:
- 공격대 > 맹독 심연 > individual bosses > items
- 공격대 > 님리사 (해일결속 동굴) > individual boss > items
- 공격대 > 키식스 (키식스 해방) > individual boss > items
- 쐐기돌 던전 > each dungeon > combined, deduplicated gear (no per-boss headers)
- 구렁, 야외 > category headings; no invented items or repetitive placeholder rows.

Virtual EJ instance named '쐐기돌 던전' is explicitly excluded from the M+ dungeon list.

Midnight Season 2 Tier 36 class-specific tokens are additional eligible gear-acquisition paths, mapped to tier head/shoulders/chest/hands/legs. A qualifying token appears under its verified raid boss in the relevant gear-slot filter even if Blizzard treats it as consumable. Registering saves *token ID as goal*, not claimed ownership of the resulting tier armor. This is not a catalyst-conversion or token redemption tracker. User may remove targets with Ctrl-click.

Cosmetic items and known additional-loot exclusions remain excluded. Season mapping is isolated in SeasonData.lua. Dungeon aggregation uses verified WoW encounter journal loot, not private GearPlanner source/data. Automated Lua mocked API tests cover token filtering, slot assignment, wrong-class exclusion and dungeon aggregation. WoW client runtime must be verified separately.

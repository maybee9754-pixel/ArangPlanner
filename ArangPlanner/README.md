# ArangPlanner 1.5.1-alpha

The independently authored black-and-gold UI now uses **Blizzard Encounter Journal** for collapsible Raid -> Instance -> Boss -> Loot lists and Dungeon -> Instance -> Boss -> Loot lists. Filtering for current specialization is applied where the API supports it. Click loot to fill the target registration field. Categories for Delve and Outdoor are present but await verified source mappings. No GearPlanner proprietary assets, source, or private loot history are used.

Central DressUpModel removed, replaced with dim class specialization art supplied by WoW (fallback to spec icon), while actual equipped items remain visible. UI layout, AP logo, existing target records and compact mode preserved.

Season providers `SeasonData.lua` and `LootCatalog.lua` are separate modules and can be replaced without rewriting UI. The currently active expansion journal tier is read from game data, rather than hard-coding season item IDs. Runtime API compatibility still requires in-game user verification.

## 1.5.1
No giant specialization icon when high-res background absent. Journal loot now distinguishes pending, unavailable, empty and nonempty responses; includes manual diagnostic on empty boss results. In-game runtime verification still required.

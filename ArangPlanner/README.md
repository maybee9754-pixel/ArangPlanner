# ArangPlanner 1.6.0-alpha

Original black-gold WoW addon. The central pane now starts with **EMPTY, clickable target slots**, never automatically populated from the character's equipped inventory. Click a center slot to filter the right-hand list to items that fit that actual slot. Select loot under Raid → Instance → Boss or Dungeon → Instance → Boss, then press Register. The registered goal is shown only in the selected central slot. Ctrl+click clears a slot.

The right-hand loot panel applies the **current specialization's Encounter Journal loot filter** and game-reported equipment inventory types. Non-equipment, such as food, reagents and consumables, is excluded. If the journal cannot verify the spec filter, the panel shows an error rather than unfiltered loot. Blizzard's C_Item.GetItemInfoInstant provides equip location, item class and icon. Items are still constrained by the game journal's loot data and available cached metadata.

Each character and specialization has an independent saved target-slot map in ArangPlannerDB. Legacy target IDs are retained in the DB unchanged but NOT automatically imported into the new planner (avoiding misleading counts and unexpected target slots). Existing GearPlanner data remains untouched. The left progress counts now use registered target slots only. SeasonData.lua / LootCatalog.lua remain separate for future seasons.

Current raid/dungeon source list comes from Encounter Journal; delve and outdoor data mappings remain WIP. This version is an alpha: no WoW-client runtime verification has been performed. An automated Lua mock test checks empty slots, non-equipment exclusion, class/spec-filter calls, item slot compatibility and persistence data behaviors.

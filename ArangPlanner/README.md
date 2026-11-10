# ArangPlanner 1.9.0-alpha

Independent WoW addon using a gold-black native-inspired visual style, now built as a wider 1460 × 850 responsive planning interface. Layout auto-scales to fit the WoW UI viewport. Compact mode is retained.

## User-visible changes
- Removed the top right "부위" filter button. The selected plan slot defaults to **머리** whenever a specialization is first opened or changed; clicking another equipment slot automatically changes loot filtering.
- Larger three-column UI, with a taller right-hand loot list and a new bottom configuration panel.
- Below item details: track (탐험가/모험가/노련가/용사/영웅/신화), upgrade rank (1–9), "맹독석 (계획)", "티어 변환 (계획)", and the Register button.
- Configuration is stored per character, per specialization and per slot, separately from the item ID. These are **planning preferences only**. They do not actually upgrade gear, apply enchantments, change an item variant, or imply that a tier conversion occurred.
- Catalyst flag is only available for head, shoulder, chest, hands and legs.
- Where tier loot is listed, its source now names both the boss token route and **울라텍 (잠자는 똬리)** as a potential alternative. "티어 교환" wording was removed.
- Raid/dungeon list continues to show actual equipped gear IDs rather than unwearable token IDs and item-specific sources. New season can replace data providers without resetting registered targets.

## Validation
GitHub Actions compiles all Lua files and runs mock tests verifying tier reward mapping, separate plan data, configuration rank/track/flags, slot safeguards, class filter and combat-equipment-only loot, plus ZIP structure. Only an actual WoW session can verify the final positioning and game API behavior.

Existing GearPlanner data and previous ArangPlanner goal IDs are not removed.

## 1.9.2 right panel layout
The in-game wide right-hand panel separates its source-filtered equipment browser from the selection, upgrade track, rank, Venomstone, Catalyst and registration editor. All code and art are independent ArangPlanner assets; GearPlanner code/art is not bundled.

## 1.9.4 standalone right panel
ArangPlanner now renders its own native raid/dungeon loot browser, selection preview and target-registration options with no GearPlanner dependency. The previous optional runtime panel bridge is no longer loaded. Existing specialization targets remain in ArangPlannerDB.

## v1.9.5-alpha standalone equipment browser
Native ArangPlanner-only right panel: source multi-filter, dark themed category rows, quality-colored loot, highlighted selection, item preview, upgrade track/rank dropdowns and target registration. No GearPlanner install or its files are required. WoW Encounter Journal supplies available loot; unimplemented providers are not falsely populated.

## 1.9.6 in-game visibility and layout corrections
Fix the selected equipment slot title being hidden by the refresh button, default-open the first raid/dungeon loot sections, improve dropdown labels and readability, and prevent missing-item and bottom-slot labels from overlapping. Still a self-contained ArangPlanner implementation.

## v1.9.7 dropdown refinement
The rank and upgrade dropdowns use native, individually drawn dark menu rows with radio selection indicators instead of inherited red Blizzard buttons; the popup stays an overlay and does not move other fields. No GearPlanner code or asset is required.

## v1.9.8 style update
Standalone bronze/stone right-panel controls, darker loot rows, purple raid groups, highlighted target selection and native custom dropdowns. Existing registered goals remain unchanged. No GearPlanner source/assets/dependency.

## 1.9.9 right panel grouping
Add native raid boss subheaders within each expanded raid, keeping selectable item rows, the GearPlanner-like nested layout, and the existing independent options dropdown. No dependency on GearPlanner.

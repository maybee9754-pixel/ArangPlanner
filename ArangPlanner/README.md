# ArangPlanner 1.4.2-alpha

Black and gold three-column equipment dashboard built from original code and Blizzard native UI templates. Left: real target acquisition and player statistics; center: PlayerModel live character and actual equipped slots; right: real registered item IDs and equipped/bag statuses. Raid/boss acquisition integrations and simulation are **not yet implemented** and are explicitly labelled development-only.

Install release ZIP with the updater, fully restart WoW, use `/arang`. Shift-click item link while the addon is open to fill input. Enter item ID or link to register; click registered icon to remove. Current specialization targets are saved in `ArangPlannerDB`; original GearPlanner DB is untouched.

The AP mark is an independently drawn golden icon from `tools/render_ap_logo.py`. Gold `#D4AF37` / black `#101014`. UI uses Blizzard native backdrop/dialog/button graphics, not copied GearPlanner assets.

The web studio from 1.3 is an older visual reference until next implementation pass.

## 1.4.1 fixes
Safe gear refresh for WoW restricted item links, slot fallbacks rather than question marks, opaque black panels, DressUpModel fallback, and top-right compact/restore control. Game runtime testing is still required.

## 1.4.2 camera and level correction
Use Blizzard's full-body preset camera 1 (previous camera 0 was face portrait only), disable portrait zoom, and read upgraded item level using actual equipped link rather than plain item ID. Core scan and SavedVariables unchanged.

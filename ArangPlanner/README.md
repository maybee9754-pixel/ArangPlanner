# ArangPlanner 1.4.0-alpha

Black and gold three-column equipment dashboard built from original code and Blizzard native UI templates. Left: real target acquisition and player statistics; center: PlayerModel live character and actual equipped slots; right: real registered item IDs and equipped/bag statuses. Raid/boss acquisition integrations and simulation are **not yet implemented** and are explicitly labelled development-only.

Install release ZIP with the updater, fully restart WoW, use `/arang`. Shift-click item link while the addon is open to fill input. Enter item ID or link to register; click registered icon to remove. Current specialization targets are saved in `ArangPlannerDB`; original GearPlanner DB is untouched.

The AP mark is an independently drawn golden icon from `tools/render_ap_logo.py`. Gold `#D4AF37` / black `#101014`. UI uses Blizzard native backdrop/dialog/button graphics, not copied GearPlanner assets.

The web studio from 1.3 is an older visual reference until next implementation pass.

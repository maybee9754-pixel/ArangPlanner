-- Run: lua tools/test_slot_plan.lua
-- Original API mocks for v1.6 slot/loot contract, not a WoW runtime emulator.
local itemTypes={
    [100]={"INVTYPE_HEAD",4},
    [101]={"",0},
    [102]={"INVTYPE_TRINKET",4},
    [103]={"INVTYPE_WEAPON",2},
    [104]={"INVTYPE_FEET",4},
    [105]={"INVTYPE_HEAD",4,5}, -- armor subclass cosmetic
    [281227]={"INVTYPE_HEAD",4,0}, -- confirmed extra loot ID override
}
C_Item={
    GetItemInfoInstant=function(id)
        local a=itemTypes[id]
        if not a then return nil end
        return id,"type",a[3]==5 and "Cosmetic" or "Armor",a[1],134400,a[2],a[3] or 0
    end,
    GetItemInfo=function(id)
        return "Item "..id,"|Hitem:"..id.."|h[Item]|h",4,100,1,
            "Armor","Cloth",1,"INVTYPE_HEAD",134400
    end,
    RequestLoadItemDataByID=function() end,
    GetItemIconByID=function()return 134400 end,
}
function UnitGUID()return "Player-Test-A" end
function GetRealmName()return "TestRealm" end
function UnitName()return "RogueA" end
function GetSpecialization()return 1 end
function GetSpecializationInfo()return 261,"잠행" end
function GetInventoryItemLink()return nil end
function GetInventoryItemTexture()return nil end
function UnitClass()return "Rogue","ROGUE",4 end
function UnitExists()return true end
function CreateFrame()return {RegisterEvent=function()end,SetScript=function()end}end
local filterClass,filterSpec=0,0
function EJ_GetLootFilter()return filterClass,filterSpec end
function EJ_SetLootFilter(c,s)filterClass,filterSpec=c,s end
function EJ_SelectInstance()end
function EJ_SelectEncounter()end
function EJ_GetNumLoot()return 4 end
function EJ_GetInstanceByIndex(i,raid)if i==1 then return raid and 10 or 20,raid and "맹독 심연" or "Test Dungeon" end end
function EJ_GetEncounterInfoByIndex(i)if i==1 then return "매장된 파수꾼",nil,500 end end
function EJ_GetNumTiers()return 2 end
function EJ_GetCurrentTier()return 1 end
function EJ_SelectTier()end
C_EncounterJournal={
    GetLootInfoByIndex=function(i)
        local id=({100,101,102,103})[i]
        return {itemID=id,encounterID=500,name="Item "..id,
            icon=134400,slot="Localized name"}
    end
}
SlashCmdList={}
dofile("ArangPlanner/ArangPlanner.lua")
dofile("ArangPlanner/SeasonData.lua")
dofile("ArangPlanner/LootCatalog.lua")
local AP=_G.ArangPlanner
assert(AP.LootCatalog.IsEquipment(100))
assert(not AP.LootCatalog.IsEquipment(101),"nongear in loot")
assert(not AP.LootCatalog.IsEquipment(105),"cosmetic subclass equip-slot item leaked")
assert(not AP.LootCatalog.IsEquipment(281227),"verified additional cosmetic loot leaked")
assert(not AP.LootCatalog.MatchesSlot(105,1),"cosmetic helm matched head")
assert(not AP.LootCatalog.MatchesSlot(281227,1),"extra loot matched head")
assert(AP.LootCatalog.MatchesSlot(100,1))
assert(not AP.LootCatalog.MatchesSlot(102,1))
assert(AP.LootCatalog.MatchesSlot(102,13))
assert(AP.LootCatalog.MatchesSlot(103,16))
assert(not AP.LootCatalog.MatchesSlot(103,13))
local sources=AP.LootCatalog.Instances()
assert(#sources.raid==1 and #sources.dungeon==1)
local loot,status=AP.LootCatalog.Loot(10,500)
assert(status=="ready")
assert(#loot==4,"expected 3 combat items + 1 rogue hands token, got "..#loot)
local tokenFound=false
for _,v in ipairs(loot) do
 if v.id==270911 and v.kind=="tierToken" then tokenFound=true end
end
assert(tokenFound,"verified hands tier token was not shown")
assert(AP.LootCatalog.IsTierTokenForClass(270911))
assert(AP.LootCatalog.MatchesSlot(270911,10))
assert(not AP.LootCatalog.MatchesSlot(270911,1))
assert(not AP.LootCatalog.IsTierTokenForClass(270910),"wrong class token was included")
local dungeonLoot=AP.LootCatalog.DungeonLoot(20)
assert(#dungeonLoot==3,"expected deduped dungeon gear without token")
assert(filterClass==0 and filterSpec==0,"journal filter not restored")
assert(next(AP.GetSlotTargets())==nil,"fresh planner must be empty")
assert(AP.GetSlotTarget(1)==nil)
assert(not AP.AssignSlotTarget(1,101),"non-gear assigned")
assert(not AP.AssignSlotTarget(1,105),"cosmetic assigned to head")
assert(not AP.AssignSlotTarget(1,281227),"known extra loot assigned to head")
assert(not AP.AssignSlotTarget(1,102),"trinket accepted as head")
assert(AP.AssignSlotTarget(1,100))
assert(AP.AssignSlotTarget(10,270911))
assert(not AP.AssignSlotTarget(1,270911),"tier hands token assigned to head")
assert(AP.AssignSlotTarget(13,102))
assert(AP.GetSlotTarget(1)==100)
assert(select(1,AP.SlotTargetCounts())==3)
assert(select(1,AP.TargetCounts())==0,"legacy target counts leaked")
local rows=AP.GetSlotTargetRows()
assert(#rows==3 and rows[1].slot==1 and rows[2].slot==10 and rows[3].slot==13)
assert(AP.ClearSlotTarget(1))
assert(AP.GetSlotTarget(1)==nil)
assert(AP.GetSlotTarget(13)==102)
print("PASS: independent empty slot plan, class/equipment filters, slot selection & target records")

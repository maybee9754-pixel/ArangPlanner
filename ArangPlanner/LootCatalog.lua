-- Original ArangPlanner Encounter Journal data adapter.
local AP=_G.ArangPlanner
local M={}
AP.LootCatalog=M
local cache,key
local function safe(fn,...)
    if type(fn)~="function" then return nil end
    local ok,a,b,c,d,e=pcall(fn,...)
    if ok then return a,b,c,d,e end
end
local function ensure()
    if type(EJ_GetInstanceByIndex)~="function" then
        if C_AddOns and type(C_AddOns.LoadAddOn)=="function" then
            pcall(C_AddOns.LoadAddOn,"Blizzard_EncounterJournal")
        elseif type(LoadAddOn)=="function" then
            pcall(LoadAddOn,"Blizzard_EncounterJournal")
        end
    end
    return type(EJ_GetInstanceByIndex)=="function"
end
function M.Season()
    local n=safe(EJ_GetNumTiers)
    local season=C_MythicPlus and safe(C_MythicPlus.GetCurrentSeason)
    return tostring(n or "?")..":"..tostring(season or "?")
end
function M.Invalidate()cache=nil;key=nil end
function M.Instances()
    if not ensure() then return nil,"모험 안내서 데이터가 아직 준비되지 않았습니다." end
    local now=M.Season()
    if cache and key==now then return cache end
    local previous=safe(EJ_GetCurrentTier)
    local tier=safe(EJ_GetNumTiers)
    if type(tier)=="number" and tier>0 then safe(EJ_SelectTier,tier) end
    local result={raid={},dungeon={},delve={},outdoor={}}
    for _,source in ipairs({"raid","dungeon"}) do
        local seen={}
        for i=1,100 do
            local id,name=safe(EJ_GetInstanceByIndex,i,source=="raid")
            if not id then break end
            if not seen[id] then
                result[source][#result[source]+1]={id=id,name=name or ("지역 "..id)}
                seen[id]=true
            end
        end
    end
    if type(previous)=="number" then safe(EJ_SelectTier,previous) end
    for _,source in ipairs({"raid","dungeon","delve","outdoor"}) do
        local extras=AP.ExtraSeasonSources and AP.ExtraSeasonSources[source] or {}
        for _,v in ipairs(extras) do
            if type(v.id)=="number" and type(v.name)=="string" then
                result[source][#result[source]+1]=v
            end
        end
    end
    cache=result;key=now
    return result
end
function M.Encounters(instance)
    if not ensure() then return {} end
    safe(EJ_SelectInstance,instance)
    local rows={}
    for i=1,40 do
        local name,_,id=safe(EJ_GetEncounterInfoByIndex,i,instance)
        if not id then break end
        rows[#rows+1]={id=id,name=name or ("보스 "..i)}
    end
    return rows
end
-- Reliable game inventory-type classification. Journal's localized slot names
-- cannot be used as English substrings. Reject consumables, recipes and other
-- non-equipment entries before exposing them in the planner.
local TYPES={
 [1]={INVTYPE_HEAD=true},[2]={INVTYPE_NECK=true},
 [3]={INVTYPE_SHOULDER=true},[5]={INVTYPE_CHEST=true,INVTYPE_ROBE=true},
 [6]={INVTYPE_WAIST=true},[7]={INVTYPE_LEGS=true},
 [8]={INVTYPE_FEET=true},[9]={INVTYPE_WRIST=true},
 [10]={INVTYPE_HAND=true},[11]={INVTYPE_FINGER=true},
 [12]={INVTYPE_FINGER=true},[13]={INVTYPE_TRINKET=true},
 [14]={INVTYPE_TRINKET=true},[15]={INVTYPE_CLOAK=true},
 [16]={INVTYPE_WEAPON=true,INVTYPE_2HWEAPON=true,
    INVTYPE_WEAPONMAINHAND=true,INVTYPE_RANGED=true,
    INVTYPE_RANGEDRIGHT=true,INVTYPE_THROWN=true},
 [17]={INVTYPE_WEAPON=true,INVTYPE_WEAPONOFFHAND=true,
    INVTYPE_HOLDABLE=true,INVTYPE_SHIELD=true},
}
function M.EquipmentType(itemID)
    if type(itemID)~="number" or type(GetItemInfoInstant)~="function" then return nil end
    -- (itemID, itemType, itemSubType, equipLoc, icon, classID, subclassID)
    local _,_,_,equipLoc,icon,classID=safe(GetItemInfoInstant,itemID)
    if type(equipLoc)~="string" or equipLoc=="" then return nil end
    if classID~=2 and classID~=4 then return nil end
    return equipLoc,icon
end
function M.IsEquipment(itemID)
    local loc=M.EquipmentType(itemID)
    if not loc then return false end
    for _,allowed in pairs(TYPES) do
        if allowed[loc] then return true end
    end
    return false
end
function M.MatchesSlot(itemID,slot)
    local allowed=TYPES[tonumber(slot)]
    if not allowed then return false end
    local loc=M.EquipmentType(itemID)
    return loc and allowed[loc] or false
end
function M.SlotLabel(slot)
    local names={[1]="머리",[2]="목",[3]="어깨",[5]="가슴",
        [6]="허리",[7]="다리",[8]="발",[9]="손목",[10]="손",
        [11]="반지 1",[12]="반지 2",[13]="장신구 1",[14]="장신구 2",
        [15]="등",[16]="주무기",[17]="보조무기"}
    return names[tonumber(slot)] or "전체"
end

-- Return (rows,status). status is loading/empty/ready, avoiding false "no loot".
-- Query both journal-modern and legacy APIs without invented item IDs.
function M.Loot(instance,encounter)
    if not ensure() then return {},"unavailable" end
    safe(EJ_SelectInstance,instance)
    safe(EJ_SelectEncounter,encounter)
    local oldClass,oldSpec=safe(EJ_GetLootFilter)
    local _,_,classID=UnitClass("player")
    local idx=GetSpecialization and GetSpecialization()
    local specID=idx and GetSpecializationInfo and GetSpecializationInfo(idx)
    local filtered=false
    if classID and specID and type(EJ_SetLootFilter)=="function" then
        safe(EJ_SetLootFilter,classID,specID)
        local checkClass,checkSpec=safe(EJ_GetLootFilter)
        filtered=(checkClass==classID and checkSpec==specID)
    end
    if not filtered then
        if oldClass~=nil then safe(EJ_SetLootFilter,oldClass,oldSpec) end
        return {},"filter-unavailable"
    end

    local count=safe(EJ_GetNumLoot)
    local upper=math.min(type(count)=="number" and count>0 and count or 50,200)
    local result,seen={},{}
    local valid=0
    for i=1,upper do
        local v
        if C_EncounterJournal and type(C_EncounterJournal.GetLootInfoByIndex)=="function" then
            v=safe(C_EncounterJournal.GetLootInfoByIndex,i)
        elseif type(EJ_GetLootInfoByIndex)=="function" then
            local id,enc,name,icon,slot,armor,link=safe(EJ_GetLootInfoByIndex,i)
            if id then v={itemID=id,encounterID=enc,name=name,icon=icon,slot=slot,armorType=armor,link=link} end
        end
        if type(v)=="table" and type(v.itemID)=="number" then
            valid=valid+1
            if not seen[v.itemID] and M.IsEquipment(v.itemID)
                and (v.encounterID==nil or v.encounterID==encounter) then
                seen[v.itemID]=true
                result[#result+1]={id=v.itemID,
                    name=v.name or ("아이템 "..v.itemID),
                    icon=v.icon,slot=v.slot,filterType=v.filterType,link=v.link}
            end
        elseif (not count or count==0) and i>=6 then
            break
        end
    end
    if oldClass~=nil then safe(EJ_SetLootFilter,oldClass,oldSpec) end
    if #result>0 then return result,"ready" end
    if (count==nil or count==0) and valid==0 then return result,"loading" end
    return result,"empty"
end
function M.Diagnostics(instance,encounter)
    if not ensure() then return "모험 안내서 없음" end
    safe(EJ_SelectInstance,instance)
    safe(EJ_SelectEncounter,encounter)
    local count=safe(EJ_GetNumLoot)
    local v=C_EncounterJournal and safe(C_EncounterJournal.GetLootInfoByIndex,1)
    return string.format("지역 %s 보스 %s / EJ_GetNumLoot=%s / 첫 아이템=%s",
        tostring(instance),tostring(encounter),tostring(count),
        tostring(type(v)=="table" and v.itemID or "nil"))
end

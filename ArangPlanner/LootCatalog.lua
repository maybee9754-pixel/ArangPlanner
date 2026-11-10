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
    if classID and specID then safe(EJ_SetLootFilter,classID,specID) end

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
            if not seen[v.itemID] and (v.encounterID==nil or v.encounterID==encounter) then
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

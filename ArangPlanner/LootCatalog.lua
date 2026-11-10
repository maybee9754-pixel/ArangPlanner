-- Original ArangPlanner Encounter Journal data adapter.
local AP=_G.ArangPlanner
local M={}
AP.LootCatalog=M
local cache,key
local function safe(fn,...)
    if type(fn)~="function" then return nil end
    local ok,a,b,c,d,e,f,g,h=pcall(fn,...)
    if ok then return a,b,c,d,e,f,g,h end
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
    if type(itemID)~="number" then return nil end
    local fn=C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant
    if type(fn)~="function" then return nil end
    -- (itemID, itemType, itemSubType, equipLoc, icon, classID, subclassID)
    -- Extra loot/cosmetic reward overrides are maintained per season.
    if AP.ExtraLootExcludedItems and AP.ExtraLootExcludedItems[itemID] then return nil end
    local _,_,itemSubType,equipLoc,icon,classID,subclassID=safe(fn,itemID)
    if type(equipLoc)~="string" or equipLoc=="" then return nil end
    if classID~=2 and classID~=4 then return nil end
    -- WoW armor subclass 5 is Cosmetic. These can have INVTYPE_HEAD etc.
    -- but have no combat equipment value (e.g. Nek'zali's cosmetic helm).
    if classID==4 and subclassID==5 then return nil end
    if classID==4 and type(itemSubType)=="string"
        and (itemSubType=="Cosmetic" or itemSubType=="장식용") then return nil end
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


local function tierInfo(itemID)
 return AP.TierTokens and AP.TierTokens[tonumber(itemID)]
end
function M.TierTokenInfo(itemID) return tierInfo(itemID) end
function M.IsTierTokenForClass(itemID)
 local t=tierInfo(itemID)
 if not t then return false end
 local _,_,classID=UnitClass("player")
 return type(classID)=="number" and t.classes[classID]==true
end
function M.TierRewardForToken(tokenID)
 local t=tierInfo(tokenID)
 if not t or not M.IsTierTokenForClass(tokenID) then return nil end
 local _,_,classID=UnitClass("player")
 local rewards=AP.TierRewardItems and AP.TierRewardItems[classID]
 local rewardID=rewards and rewards[t.slot]
 if not rewardID then return nil end
 if not M.MatchesSlot(rewardID,t.slot) then return nil end
 return rewardID,t.slot
end
-- Tokens are source-only metadata; never display or register them as gear.
function M.IsCandidate(itemID) return M.IsEquipment(itemID) end
function M.MakeTierReward(tokenID,boss)
 local rewardID,slot=M.TierRewardForToken(tokenID)
 if not rewardID then return nil end
 local itemName,link,icon
 if C_Item and type(C_Item.GetItemInfo)=="function" then
   itemName,link=safe(C_Item.GetItemInfo,rewardID)
 elseif type(GetItemInfo)=="function" then
   itemName,link=safe(GetItemInfo,rewardID)
 end
 if C_Item and type(C_Item.GetItemIconByID)=="function" then
   icon=safe(C_Item.GetItemIconByID,rewardID)
 end
 return {id=rewardID,slot=slot,name=itemName or ("아이템 ID "..rewardID),
     link=link,icon=icon,kind="tierGear",sourceBoss=boss or "",
     sourceText=(boss or "공격대").." · 울라텍 (잠자는 똬리)",tokenSourceID=tokenID}
end
-- Stable, explicit boss-to-token mapping for this season. The encounter
-- journal loot filter sometimes hides consumable-class tier tokens.
local function matchingBossTierGear(instance,encounter)
 local source=M.Instances()
 local raidFound=false
 for _,raid in ipairs(source and source.raid or {}) do
  local name=(raid.name or ""):lower()
  if raid.id==instance and (name:find("맹독 심연",1,true)
      or name:find("venomous abyss",1,true)) then raidFound=true;break end
 end
 if not raidFound then return {} end
 local bossName
 for _,boss in ipairs(M.Encounters(instance)) do
  if boss.id==encounter then bossName=boss.name;break end
 end
 if type(bossName)~="string" then return {} end
 local matches={}
 for tokenID,t in pairs(AP.TierTokens or {}) do
  if M.IsTierTokenForClass(tokenID) then
   for _,alias in ipairs(AP.TierTokenBossNames[t.boss] or {}) do
    if bossName:lower():find(alias:lower(),1,true) then
     local entry=M.MakeTierReward(tokenID,bossName)
     if entry then matches[#matches+1]=entry end
     break
    end
   end
  end
 end
 table.sort(matches,function(x,y)return x.id<y.id end)
 return matches
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
            if not seen[v.itemID] and (v.encounterID==nil or v.encounterID==encounter) then
                local displayed
                if tierInfo(v.itemID) then
                    displayed=M.MakeTierReward(v.itemID)
                elseif M.IsEquipment(v.itemID) then
                    displayed={id=v.itemID,name=v.name or ("아이템 "..v.itemID),
                        icon=v.icon,slot=v.slot,link=v.link,kind="equipment"}
                end
                if displayed and not seen[displayed.id] then
                    seen[v.itemID]=true
                    seen[displayed.id]=true
                    result[#result+1]=displayed
                end
            end
        elseif (not count or count==0) and i>=6 then
            break
        end
    end
    -- Add class-eligible boss tokens that the journal omitted from its
    -- filtered item results. Never inject cosmetics or arbitrary extras.
    for _,v in ipairs(matchingBossTierGear(instance,encounter)) do
        if not seen[v.id] then seen[v.id]=true;result[#result+1]=v end
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


-- M+ dungeon loot: one deduplicated list per dungeon, no boss headers.
-- Use each encounter's filtered journal loot so we don't require EJ's
-- instance-level aggregate to be available on all client builds.
-- Browser list is by zone, not boss. Source provenance is kept per item
-- and printed as a subdued second line. Unique item IDs are merged within
-- the zone; separate items with the same name remain distinct.
function M.RaidLoot(instance)
 local all,seen={},{}
 local loading=false
 for _,boss in ipairs(M.Encounters(instance)) do
  local loot,status=M.Loot(instance,boss.id)
  if status=="loading" then loading=true end
  for _,item in ipairs(loot) do
   if not seen[item.id] then
    seen[item.id]=true
    item.sourceBoss=boss.name
    item.sourceText=boss.name..
      (item.kind=="tierGear" and " · 울라텍 (잠자는 똬리)" or "")
    all[#all+1]=item
   end
  end
 end
 table.sort(all,function(a,b)
  if (a.sourceBoss or "")==(b.sourceBoss or "") then
   return (a.name or "")<(b.name or "")
  end
  return (a.sourceBoss or "")<(b.sourceBoss or "")
 end)
 return all,#all>0 and "ready" or (loading and "loading" or "empty")
end
function M.DungeonLoot(instance)
 local out,seen,loading={}, {}, false
 for _,boss in ipairs(M.Encounters(instance)) do
  local loot,status=M.Loot(instance,boss.id)
  if status=="loading" then loading=true end
  for _,item in ipairs(loot) do
   if not seen[item.id] then
    seen[item.id]=true
    item.sourceBoss=boss.name
    item.sourceText=boss.name or "던전"
    out[#out+1]=item
   end
  end
 end
 table.sort(out,function(a,b)return (a.name or "")<(b.name or "") end)
 return out,#out>0 and "ready" or (loading and "loading" or "empty")
end

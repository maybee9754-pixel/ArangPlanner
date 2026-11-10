-- ArangPlanner: independently authored core, target-table alpha 1.1.
-- Does not copy or import GearPlanner program code or its SavedVariables.
local ADDON_NAME = ...
local AP = {}
_G.ArangPlanner = AP

local function say(message)
    print("|cffb68bff아랑플래너|r " .. tostring(message))
end

local function database()
    if type(ArangPlannerDB) ~= "table" then
        ArangPlannerDB = { schema = 1, characters = {} }
    end
    if type(ArangPlannerDB.characters) ~= "table" then
        ArangPlannerDB.characters = {}
    end
    return ArangPlannerDB
end

local function characterKey()
    local guid = UnitGUID("player")
    if guid and guid ~= "" then return guid end
    return tostring(GetRealmName() or "unknown") .. ":" .. tostring(UnitName("player") or "unknown")
end

local function specKey()
    local index = GetSpecialization and GetSpecialization()
    local id = index and GetSpecializationInfo and GetSpecializationInfo(index)
    return tostring(id or 0)
end

local function state()
    local db = database()
    local key = characterKey()
    local char = db.characters[key]
    if type(char) ~= "table" then
        char = { name = UnitName("player"), realm = GetRealmName(), specs = {} }
        db.characters[key] = char
    end
    if type(char.specs) ~= "table" then char.specs = {} end
    local spec = specKey()
    local record = char.specs[spec]
    if type(record) ~= "table" then
        record = { targets = {}, lastSeen = {} }
        char.specs[spec] = record
    end
    if type(record.targets) ~= "table" then record.targets = {} end
    if type(record.lastSeen) ~= "table" then record.lastSeen = {} end
    if type(record.slotTargets) ~= "table" then record.slotTargets = {} end
    return record, key, spec
end

local SLOT_IDS = {1,2,3,15,5,9,10,6,7,8,11,12,13,14,16,17}
local function itemIDFromLink(link)
    if type(link) ~= "string" then return nil end
    return tonumber(link:match("item:(%d+)"))
end

function AP.GetDisplayRows()
    local record = state()
    local rows = {}
    for _, id in ipairs(SLOT_IDS) do
        local link = GetInventoryItemLink("player", id)
        local itemId = itemIDFromLink(link)
        rows[#rows+1] = {slot=id, itemId=itemId, link=link, icon=GetInventoryItemTexture("player",id)}
    end
    return rows
end

function AP.ScanEquipped()
    local record = state()
    local count = 0
    for _, row in ipairs(AP.GetDisplayRows()) do
        if row.itemId then
            record.lastSeen[tostring(row.slot)] = row.itemId
            count = count+1
        else
            record.lastSeen[tostring(row.slot)] = nil
        end
    end
    return count
end

function AP.AddTarget(itemId)
    itemId = AP.GetItemIDFromText(tostring(itemId or ""))
    if not itemId or itemId < 1 or itemId % 1 ~= 0 then return false end
    local record = state()
    record.targets[tostring(itemId)] = true
    if C_Item and C_Item.RequestLoadItemDataByID then C_Item.RequestLoadItemDataByID(itemId) end
    return true
end

function AP.RemoveTarget(itemId)
    itemId = AP.GetItemIDFromText(tostring(itemId or ""))
    if not itemId then return false end
    local record = state()
    record.targets[tostring(itemId)] = nil
    return true
end

-- All possession checks are current snapshots only; no inferred raid-drop provenance.
-- Query equipped gear and carried bags. Bank contents are intentionally excluded.
-- Keep target-table generation independent of inventory/item-cache failures.
-- A registered target MUST still render even if a bag API or item info fails.
local function equippedItemIDs()
    local result={}
    for _,slot in ipairs(SLOT_IDS) do
        local ok,link=pcall(GetInventoryItemLink,"player",slot)
        if ok and type(link)=="string" then
            local itemId=tonumber(link:match("item:(%d+)"))
            if itemId then result[tostring(itemId)]=true end
        end
    end
    return result
end

local function bagItemIDs()
    local result={}
    if not C_Container or not C_Container.GetContainerNumSlots or not C_Container.GetContainerItemID then return result end
    for bag=0,4 do
        local okSlots,count=pcall(C_Container.GetContainerNumSlots,bag)
        if okSlots and type(count)=="number" then
            for slot=1,count do
                local ok,itemId=pcall(C_Container.GetContainerItemID,bag,slot)
                if ok and type(itemId)=="number" then result[tostring(itemId)]=true end
            end
        end
    end
    return result
end

function AP.GetPossession()
    return equippedItemIDs(),bagItemIDs()
end

function AP.GetTargetRows()
    local record=state()
    local rows={}
    local equipped,bags=AP.GetPossession()
    for id, enabled in pairs(record.targets) do
        if enabled then
            local number=tonumber(id)
            if number then
                local name,link,icon
                local ok,gotName,gotLink,_,_,_,_,_,_,_,gotIcon=pcall(GetItemInfo,number)
                if ok then name,link,icon=gotName,gotLink,gotIcon end
                if not icon and C_Item and C_Item.GetItemIconByID then
                    local valid,result=pcall(C_Item.GetItemIconByID,number)
                    if valid then icon=result end
                end
                local status=equipped[id] and "착용" or (bags[id] and "가방 보유" or "미확인")
                rows[#rows+1]={
                    id=number,
                    name=name or ("아이템 ID "..id),
                    link=link,
                    icon=icon or 134400,
                    status=status
                }
            end
        end
    end
    table.sort(rows,function(x,y) return x.id < y.id end)
    return rows
end

-- The equipment planning UI is intentionally EMPTY until users register an
-- item to a specific slot. Legacy targets stay untouched for data preservation,
-- but are not silently imported into the new slot plan.
local PLAN_SLOTS={ [1]=true,[2]=true,[3]=true,[5]=true,[6]=true,[7]=true,
    [8]=true,[9]=true,[10]=true,[11]=true,[12]=true,[13]=true,
    [14]=true,[15]=true,[16]=true,[17]=true }
function AP.GetSlotTargets()
    local record=state()
    local result={}
    for k,id in pairs(record.slotTargets) do
        local slot=tonumber(k)
        if PLAN_SLOTS[slot] and type(id)=="number" and id>0 then
            result[slot]=id
        end
    end
    return result
end
function AP.GetSlotTarget(slot)
    slot=tonumber(slot)
    if not slot or not PLAN_SLOTS[slot] then return nil end
    local record=state()
    local id=record.slotTargets[tostring(slot)]
    return type(id)=="number" and id or nil
end
function AP.AssignSlotTarget(slot,itemID)
    slot=tonumber(slot)
    itemID=AP.GetItemIDFromText(tostring(itemID or ""))
    if not slot or not PLAN_SLOTS[slot] or not itemID or itemID%1~=0 then
        return false,"올바른 슬롯 또는 아이템 ID가 아닙니다."
    end
    if AP.LootCatalog and AP.LootCatalog.MatchesSlot and
        not AP.LootCatalog.MatchesSlot(itemID,slot) then
        return false,"선택한 부위에 착용하는 장비가 아닙니다."
    end
    local record=state()
    record.slotTargets[tostring(slot)]=itemID
    if C_Item and C_Item.RequestLoadItemDataByID then
        pcall(C_Item.RequestLoadItemDataByID,itemID)
    end
    return true
end
function AP.ClearSlotTarget(slot)
    slot=tonumber(slot)
    if not slot or not PLAN_SLOTS[slot] then return false end
    local record=state()
    record.slotTargets[tostring(slot)]=nil
    return true
end
function AP.GetSlotTargetRows()
    local result={}
    local equipped,bags=AP.GetPossession()
    for slot,id in pairs(AP.GetSlotTargets()) do
        local name,link,icon
        local ok,n,l,_,__,___,____,_____,______,_______,i=pcall(GetItemInfo,id)
        if ok then name,link,icon=n,l,i end
        if not icon and C_Item and C_Item.GetItemIconByID then
            local found,v=pcall(C_Item.GetItemIconByID,id)
            if found then icon=v end
        end
        local key=tostring(id)
        result[#result+1]={slot=slot,id=id,name=name or ("아이템 ID "..id),
            icon=icon,status=equipped[key] and "착용" or
                (bags[key] and "가방 보유" or "미확인")}
    end
    table.sort(result,function(a,b)return a.slot<b.slot end)
    return result
end
function AP.SlotTargetCounts()
    local total,owned=0,0
    local equipped,bags=AP.GetPossession()
    for _,id in pairs(AP.GetSlotTargets()) do
        total=total+1
        if equipped[tostring(id)] or bags[tostring(id)] then owned=owned+1 end
    end
    return total,owned
end

function AP.TargetCounts()
    local record=state()
    local total,possessed=0,0
    local equipped,bags=AP.GetPossession()
    for id, enabled in pairs(record.targets) do
        if enabled then
            total=total+1
            if equipped[id] or bags[id] then possessed=possessed+1 end
        end
    end
    return total,possessed
end

function AP.Debug()
    local record,key,spec=state()
    local total=0
    for id,on in pairs(record.targets) do
        if on then total=total+1;say("목표 ID "..tostring(id)) end
    end
    say("진단: 전문화 "..spec.." / 캐릭터 "..key.." / 등록 "..total)
    if AP.RefreshUI then
        local ok,err=pcall(AP.RefreshUI)
        if not ok then say("UI 갱신 오류: "..tostring(err)) end
    end
end

function AP.GetSpecName()
    local index = GetSpecialization and GetSpecialization()
    if index and GetSpecializationInfo then
        local _, name = GetSpecializationInfo(index)
        if name then return name end
    end
    return "알 수 없음"
end

function AP.GetItemIDFromText(text)
    if type(text) ~= "string" then return nil end
    local id = text:match("item:(%d+)") or text:match("^%s*(%d+)%s*$")
    return tonumber(id)
end

function AP.Info()
    local _, _, spec = state()
    local total, equipped = AP.TargetCounts()
    return spec, total, equipped
end

function AP.Status()
    local spec,total,equipped=AP.Info()
    say("전문화 "..AP.GetSpecName().." ("..spec..") | 등록 "..total.." | 현재 착용/가방 보유 "..equipped)
end

local eventFrame=CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:RegisterEvent("BAG_UPDATE_DELAYED")
eventFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
eventFrame:SetScript("OnEvent",function(_,event,arg)
    if event=="ADDON_LOADED" then
        if arg~=ADDON_NAME then return end
        database()
        say("독립형 개발 시험판 로드됨. /arang 도움말")
        return
    end
    if not UnitExists("player") then return end
    if event~="BAG_UPDATE_DELAYED" and event~="GET_ITEM_INFO_RECEIVED" then AP.ScanEquipped() end
    if AP.RefreshUI then
        local ok,err=pcall(AP.RefreshUI)
        if not ok then say("UI 갱신 오류: "..tostring(err)) end
    end
end)

SLASH_ARANGPLANNER1 = "/arang"
SlashCmdList.ARANGPLANNER = function(message)
    local action, value = (message or ""):match("^(%S+)%s*(.-)%s*$")
    action = action or ""
    if action=="" or action=="show" then
        if AP.ToggleUI then AP.ToggleUI() end
    elseif action=="scan" then
        local n=AP.ScanEquipped()
        if AP.RefreshUI then AP.RefreshUI() end
        say("스캔 완료")
    elseif action=="add" then
        say(AP.AddTarget(value) and ("목표 아이템 "..value.." 등록") or "아이템 ID가 올바르지 않음")
        if AP.RefreshUI then AP.RefreshUI() end
    elseif action=="remove" then
        say(AP.RemoveTarget(value) and ("목표 아이템 "..value.." 제외") or "아이템 ID가 올바르지 않음")
        if AP.RefreshUI then AP.RefreshUI() end
    elseif action=="status" then AP.Status()
    elseif action=="debug" then AP.Debug()
    else
        say("/arang | /arang scan | /arang add 아이템ID | /arang remove 아이템ID | /arang status | /arang debug")
    end
end

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
function AP.GetPossession()
    local equipped, bags = {}, {}
    for _, row in ipairs(AP.GetDisplayRows()) do
        if row.itemId then equipped[tostring(row.itemId)] = true end
    end
    if C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerItemID then
        for bag = 0, 4 do
            local count = C_Container.GetContainerNumSlots(bag) or 0
            for slot = 1, count do
                local itemId = C_Container.GetContainerItemID(bag,slot)
                if type(itemId) == "number" then bags[tostring(itemId)] = true end
            end
        end
    end
    return equipped, bags
end

function AP.GetTargetRows()
    local record = state()
    local equipped, bags = AP.GetPossession()
    local rows = {}
    for id, enabled in pairs(record.targets) do
        if enabled then
            local number = tonumber(id)
            if number then
                local name, link, _, _, _, _, _, _, _, icon = GetItemInfo(number)
                local stateText = equipped[id] and "착용" or (bags[id] and "가방 보유" or "미확인")
                rows[#rows+1] = {
                    id=number, name=name or ("아이템 "..id),
                    link=link, icon=icon or (C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(number)) or 134400,
                    status=stateText
                }
            end
        end
    end
    table.sort(rows,function(a,b) return a.id < b.id end)
    return rows
end

function AP.TargetCounts()
    local rows=AP.GetTargetRows()
    local possessed=0
    for _,row in ipairs(rows) do
        if row.status=="착용" or row.status=="가방 보유" then possessed=possessed+1 end
    end
    return #rows, possessed
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
    if AP.RefreshUI then AP.RefreshUI() end
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
    else
        say("/arang | /arang scan | /arang add 아이템ID | /arang remove 아이템ID | /arang status")
    end
end

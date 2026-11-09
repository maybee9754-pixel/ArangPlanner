-- ArangPlanner: independently authored core, first unified ArangPlanner alpha.
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
    itemId = tonumber(itemId)
    if not itemId or itemId < 1 or itemId % 1 ~= 0 then return false end
    local record = state()
    record.targets[tostring(itemId)] = true
    return true
end

function AP.RemoveTarget(itemId)
    itemId = tonumber(itemId)
    if not itemId then return false end
    local record = state()
    record.targets[tostring(itemId)] = nil
    return true
end

function AP.TargetCounts()
    local record = state()
    local current = {}
    for _, row in ipairs(AP.GetDisplayRows()) do
        if row.itemId then current[tostring(row.itemId)] = true end
    end
    local total, equipped = 0,0
    for id, enabled in pairs(record.targets) do
        if enabled then
            total = total+1
            if current[id] then equipped=equipped+1 end
        end
    end
    return total, equipped
end

function AP.Info()
    local _, _, spec = state()
    local total, equipped = AP.TargetCounts()
    return spec, total, equipped
end

function AP.Status()
    local spec,total,equipped=AP.Info()
    say("전문화 ID "..spec.." | 등록 "..total.." | 현재 착용 "..equipped)
end

local eventFrame=CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:SetScript("OnEvent",function(_,event,arg)
    if event=="ADDON_LOADED" then
        if arg~=ADDON_NAME then return end
        database()
        say("독립형 개발 시험판 로드됨. /arang 도움말")
        return
    end
    if not UnitExists("player") then return end
    AP.ScanEquipped()
    if AP.RefreshUI then AP.RefreshUI() end
end)

SLASH_ARANGPLANNER1 = "/arang"
SlashCmdList.ARANGPLANNER = function(message)
    local action, value = (message or ""):match("^(%S+)%s*(%S*)")
    action = action or ""
    if action=="" or action=="show" then
        if AP.ToggleUI then AP.ToggleUI() end
    elseif action=="scan" then
        local n=AP.ScanEquipped()
        if AP.RefreshUI then AP.RefreshUI() end
        say("스캔 완료 ("..n.."개 장착 슬롯)")
    elseif action=="add" then
        say(AP.AddTarget(value) and ("목표 아이템 "..value.." 등록") or "아이템 ID가 올바르지 않음")
        if AP.RefreshUI then AP.RefreshUI() end
    elseif action=="remove" then
        say(AP.RemoveTarget(value) and ("목표 아이템 "..value.." 제외") or "아이템 ID가 올바르지 않음")
        if AP.RefreshUI then AP.RefreshUI() end
    elseif action=="status" then AP.Status()
    else
        say("/arang | /arang scan | /arang add 12345 | /arang remove 12345 | /arang status")
    end
end

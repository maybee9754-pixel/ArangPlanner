-- ArangPlanner 1.4.1: independently created black-and-gold equipment dashboard.
-- Uses Blizzard UI templates and built-in item/model APIs. No GearPlanner art/code.
local AP=_G.ArangPlanner
local GOLD={.96,.76,.22}
local IVORY={.94,.91,.83}
local MUTED={.64,.62,.57}
local ROOT=CreateFrame("Frame","ArangPlannerWindow",UIParent,"BackdropTemplate")
ROOT:SetSize(1280,720)
ROOT:SetPoint("CENTER")
ROOT:SetClampedToScreen(true)
ROOT:SetFrameStrata("DIALOG")
ROOT:SetMovable(true)
ROOT:EnableMouse(true)
ROOT:RegisterForDrag("LeftButton")
ROOT:SetScript("OnDragStart",function(self)self:StartMoving()end)
ROOT:SetScript("OnDragStop",function(self)self:StopMovingOrSizing()end)
ROOT:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile=true,tileSize=32,edgeSize=27,insets={left=8,right=8,top=8,bottom=8}})
ROOT:SetBackdropColor(.025,.022,.03,1)
ROOT:SetBackdropBorderColor(.82,.65,.29,1)
ROOT:Hide()

local function color(t,c) t:SetTextColor(c[1],c[2],c[3]) end
local function label(p,txt,x,y,size,tint)
    local s=p:CreateFontString(nil,"OVERLAY",size or "GameFontHighlight")
    s:SetPoint("TOPLEFT",p,"TOPLEFT",x,-y)
    s:SetText(txt or "")
    color(s,tint or IVORY)
    s:SetJustifyH("LEFT")
    return s
end
local function tint(p, r,g,b,a, layer)
    local t=p:CreateTexture(nil,layer or "BACKGROUND")
    t:SetAllPoints()
    t:SetColorTexture(r,g,b,a or 1)
    return t
end
local function pane(parent,x,y,w,h)
    local p=CreateFrame("Frame",nil,parent,"BackdropTemplate")
    p:SetPoint("TOPLEFT",x,-y)
    p:SetSize(w,h)
    p:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile=true,tileSize=32,edgeSize=20,insets={left=5,right=5,top=5,bottom=5}})
    p:SetBackdropColor(.035,.031,.040,.99)
    p:SetBackdropBorderColor(.67,.52,.21,.95)
    return p
end
local function bar(parent,txt)
    local b=CreateFrame("Frame",nil,parent)
    b:SetPoint("TOPLEFT",12,-10);b:SetPoint("TOPRIGHT",-12,-10);b:SetHeight(27)
    tint(b,.18,.14,.075,.85)
    label(b,txt,12,5,"GameFontNormalLarge",GOLD)
    return b
end
local function button(parent,txt,x,y,w,h,fn)
    local b=CreateFrame("Button",nil,parent,"UIPanelButtonTemplate")
    b:SetPoint("TOPLEFT",x,-y);b:SetSize(w,h);b:SetText(txt)
    b:SetScript("OnClick",function()if fn then fn()end end)
    return b
end
local function newIcon(parent,x,y,w,h)
    local f=CreateFrame("Button",nil,parent,"BackdropTemplate")
    f:SetPoint("TOPLEFT",x,-y);f:SetSize(w,h)
    f:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
    f:SetBackdropColor(.06,.05,.07,1)
    f:SetBackdropBorderColor(.64,.48,.16,1)
    f.icon=f:CreateTexture(nil,"ARTWORK")
    f.icon:SetPoint("TOPLEFT",2,-2);f.icon:SetPoint("BOTTOMRIGHT",-2,2)
    f.icon:SetTexture("Interface\\PaperDoll\\UI-Backpack-EmptySlot")
    return f
end
local function alert(message)
    if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cffffcf4a아랑플래너|r "..message) end
end

-- Header: render the independently drawn AP mark, with no copied third-party emblem.
local top=pane(ROOT,13,11,1254,66)
local ap=top:CreateTexture(nil,"ARTWORK")
ap:SetPoint("LEFT",18,0);ap:SetSize(49,49)
ap:SetTexture("Interface\\AddOns\\ArangPlanner\\Textures\\ap-logo.tga")
local brand=label(top,"아랑플래너",78,13,"GameFontNormalLarge",GOLD)
local brandSub=label(top,"ARANG PLANNER",80,39,"GameFontHighlightSmall",MUTED)
local names={"장비 관리","공격대","쐐기돌","비교/시뮬","저장/불러오기"}
local tabs={}
local current=1
local content={}
local function switch(n)
    current=n
    for i,p in ipairs(content)do p:SetShown(i==n and not (ROOT:GetWidth()<600)) end
    for i,b in ipairs(tabs)do
        if i==n then b:LockHighlight() else b:UnlockHighlight() end
    end
end
for i,name in ipairs(names) do
    tabs[i]=button(top,name,316+(i-1)*145,12,137,39,function()switch(i)end)
end
button(top,"X",1183,16,38,31,function()ROOT:Hide()end)

-- Fixed three-column hierarchy, matching the approved screenshot.
local left=pane(ROOT,13,88,346,620)
local mid=pane(ROOT,366,88,559,620)
local right=pane(ROOT,932,88,335,620)
content[1]=CreateFrame("Frame",nil,ROOT)
content[1]:SetAllPoints(ROOT)

bar(left,"파밍 현황")
local rate=label(left,"0%  달성률",22,61,"GameFontNormalLarge",GOLD)
local counts=label(left,"등록 0    보유 0    미보유 0",22,106,"GameFontNormal",IVORY)
local special=label(left,"현재 전문화",22,138,"GameFontHighlightSmall",MUTED)
local stat=pane(left,11,198,324,236)
bar(stat,"능력치 비교")
local statRows={}
for i,entry in ipairs({{"아이템 레벨",0},{"지능",4},{"치명타",5},{"가속",6},{"특화",7},{"유연성",8}}) do
    local txt=label(stat,entry[1],18,47+(i-1)*29,"GameFontHighlight",IVORY)
    local val=stat:CreateFontString(nil,"OVERLAY","GameFontHighlight")
    val:SetPoint("TOPRIGHT",stat,"TOPRIGHT",-20,-47-(i-1)*29)
    color(val,MUTED)
    statRows[i]={label=txt,value=val,index=entry[2]}
end
local missing=pane(left,11,445,324,163)
bar(missing,"미획득 아이템")
local missingText=label(missing,"",18,55,"GameFontHighlightSmall",IVORY)
missingText:SetWidth(280);missingText:SetJustifyH("LEFT")

bar(mid,"장비 관리")
local specText=label(mid,"현재 장비",20,50,"GameFontNormal",GOLD)
local modelBacking=CreateFrame("Frame",nil,mid)
modelBacking:SetPoint("TOPLEFT",137,-105);modelBacking:SetSize(285,362)
tint(modelBacking,.08,.07,.11,.55)
local model=CreateFrame("DressUpModel",nil,modelBacking)
model:SetAllPoints()
local modelFallback=label(modelBacking,"캐릭터 모델 불러오는 중",42,166,"GameFontHighlightSmall",MUTED)
local modelLoaded=false
local function modelRefresh()
    if model.SetUnit then
        local ok=pcall(model.SetUnit,model,"player")
        modelFallback:SetShown(not ok)
        if ok then modelFallback:Hide();modelLoaded=true end
        if ok and model.SetCamera then pcall(model.SetCamera,model,0) end
    end
end
local slots={
    {1,15,105},{3,15,163},{5,15,221},{9,15,279},{10,15,337},
    {15,481,105},{6,481,163},{7,481,221},{8,481,279},{11,481,337},
    {2,87,475},{12,194,475},{13,301,475},{14,408,475},
    {16,140,539},{17,350,539}
}
local equipIcons={}
for _,sd in ipairs(slots)do
    local f=newIcon(mid,sd[2],sd[3],54,49)
    f.slot=sd[1]
    local itemLevel=label(f,"",3,30,"GameFontNormalSmall",GOLD)
    local equippedName=label(mid,"",sd[2]+((sd[2]>440) and -92 or 60),sd[3]+13,"GameFontHighlightSmall",IVORY)
    equippedName:SetWidth(90);equippedName:SetWordWrap(false)
    if sd[2]>440 then equippedName:SetJustifyH("RIGHT") end
    f:SetScript("OnEnter",function(self)
        GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
        GameTooltip:SetInventoryItem("player",self.slot)
        GameTooltip:Show()
    end)
    f:SetScript("OnLeave",function()GameTooltip:Hide()end)
    equipIcons[#equipIcons+1]={f=f,lvl=itemLevel,name=equippedName}
end
local help=label(mid,"장비 아이콘에 마우스를 올리면 실제 아이템 툴팁이 표시됩니다.",24,595,"GameFontHighlightSmall",MUTED)
help:SetWidth(513)

bar(right,"전리품")
local warning=label(right,"공격대·쐐기돌 전리품 연동은 개발 중입니다.",20,60,"GameFontHighlightSmall",IVORY)
warning:SetWidth(286)
warning:SetWordWrap(true)
local targetSummary=label(right,"전문화별 목표 아이템",20,112,"GameFontNormal",GOLD)
local selectedRows={}
local selectedIds={}
for i=1,6 do
    local y=144+(i-1)*51
    local icon=newIcon(right,16,y,38,38)
    local txt=label(right,"",61,y+5,"GameFontHighlightSmall",IVORY)
    txt:SetWidth(244);txt:SetWordWrap(false)
    local status=label(right,"",61,y+23,"GameFontHighlightSmall",MUTED)
    icon:SetScript("OnClick",function()
        local id=selectedIds[i]
        if id then
            AP.RemoveTarget(id)
            alert("목표 제외: "..id)
            if AP.RefreshUI then AP.RefreshUI() end
        end
    end)
    selectedRows[i]={icon=icon,txt=txt,status=status}
end
local input=CreateFrame("EditBox",nil,right,"InputBoxTemplate")
input:SetPoint("TOPLEFT",26,-477);input:SetSize(195,28)
input:SetAutoFocus(false);input:SetMaxLetters(256);input:EnableMouse(true)
local function add()
    if AP.AddTarget(input:GetText()) then
        input:SetText("");alert("목표 아이템 등록 완료")
        if AP.RefreshUI then AP.RefreshUI() end
    else alert("유효한 아이템 ID 또는 아이템 링크를 입력하세요.") end
end
button(right,"등록",230,472,84,32,add)
input:SetScript("OnEnterPressed",function(self)add();self:ClearFocus()end)
input:SetScript("OnEscapePressed",function(self)self:ClearFocus()end)
if type(ChatEdit_InsertLink)=="function" then
    hooksecurefunc("ChatEdit_InsertLink",function(link)
        if ROOT:IsShown() and type(link)=="string" and IsShiftKeyDown() and AP.GetItemIDFromText(link) then
            input:SetText(link);input:SetFocus()
        end
    end)
end
local note=label(right,"아이템 ID 입력 또는 가방 아이템 Shift+클릭",19,518,"GameFontHighlightSmall",MUTED)
note:SetWidth(300)
button(right,"목표 새로고침",20,550,288,32,function()AP.ScanEquipped();AP.RefreshUI()end)

-- Other top-level tabs are honest WIP panels, not made-up acquisition records.
for i=2,#names do
    local holder=pane(ROOT,13,88,1254,620)
    content[i]=holder
    bar(holder,names[i])
    label(holder,"이 화면은 개발 중입니다. 아직 실제 데이터와 연동되지 않았습니다.",40,86,"GameFontNormalLarge",IVORY)
    label(holder,"장비 관리 탭에서 현재 장비와 전문화별 목표 아이템을 사용할 수 있습니다.",40,126,"GameFontHighlight",MUTED)
    holder:Hide()
end

local function statValue(index)
    if index==0 then
        return string.format("%.1f",GetAverageItemLevel and (select(2,GetAverageItemLevel()) or 0) or 0)
    end
    if index==4 then return tostring(UnitStat("player",4) or 0) end
    if index==5 then return string.format("%.1f%%",GetCritChance and GetCritChance() or 0) end
    if index==6 then return string.format("%.1f%%",GetHaste and GetHaste() or 0) end
    if index==7 then return string.format("%.1f%%",GetMasteryEffect and GetMasteryEffect() or 0) end
    if index==8 then return string.format("%.1f%%",GetCombatRatingBonus and GetCombatRatingBonus(29) or 0) end
    return "—"
end
function AP.RefreshUI()
    if not ROOT or not ROOT:IsShown() then return end
    local total,have=AP.TargetCounts()
    rate:SetText(string.format("%.1f%%  달성률",total>0 and have*100/total or 0))
    counts:SetText(string.format("등록 %d     보유 %d     미보유 %d",total,have,total-have))
    special:SetText("현재 전문화: "..AP.GetSpecName())
    specText:SetText(AP.GetSpecName().." · 현재 장비")
    for _,r in ipairs(statRows)do r.value:SetText(statValue(r.index)) end
    local equipped=AP.GetDisplayRows()
    local mapped={}
    for _,r in ipairs(equipped)do mapped[r.slot]=r end
    for _,r in ipairs(equipIcons)do
        local slot=r.f.slot
        local data=mapped[slot]
        local icon=data and data.icon
        -- The 12.x WoW client may expose restricted item links in a UI context.
        -- Do not call GetItemInfo(link) unprotected: one failed lookup used to
        -- abort RefreshUI on the first slot and leave all others as red '?'.
        if icon then
            local ok=pcall(r.f.icon.SetTexture,r.f.icon,icon)
            if not ok then r.f.icon:SetTexture("Interface\\PaperDoll\\UI-Backpack-EmptySlot") end
        else
            local fallback
            if GetInventorySlotInfo then
                local nameByID={[1]="HeadSlot",[2]="NeckSlot",[3]="ShoulderSlot",[5]="ChestSlot",[6]="WaistSlot",[7]="LegsSlot",[8]="FeetSlot",[9]="WristSlot",[10]="HandsSlot",[11]="Finger0Slot",[12]="Finger1Slot",[13]="Trinket0Slot",[14]="Trinket1Slot",[15]="BackSlot",[16]="MainHandSlot",[17]="SecondaryHandSlot"}
                local slotName=nameByID[slot]
                if slotName then
                    local safe,_,tex=pcall(GetInventorySlotInfo,slotName)
                    if safe then fallback=tex end
                end
            end
            r.f.icon:SetTexture(fallback or "Interface\\PaperDoll\\UI-Backpack-EmptySlot")
        end
        local name
        if data and data.itemId then
            local ok,n=pcall(GetItemInfo,data.itemId)
            if ok and type(n)=="string" then name=n end
        end
        r.name:SetText(name or "")
        local lvl
        if data and data.itemId and C_Item and C_Item.GetDetailedItemLevelInfo then
            local ok,v=pcall(C_Item.GetDetailedItemLevelInfo,data.itemId or 0)
            if ok and type(v)=="number" then lvl=v end
        end
        r.lvl:SetText(lvl and tostring(lvl) or "")
    end
    if not modelLoaded then modelRefresh() end
    local rows=AP.GetTargetRows()
    local missingNames={}
    for i=1,6 do
        local data=rows[i]
        local c=selectedRows[i]
        selectedIds[i]=data and data.id
        c.icon:SetShown(data~=nil)
        c.txt:SetText(data and data.name or (i==1 and "등록된 목표 아이템이 없습니다." or ""))
        c.status:SetText(data and (tostring(data.id).."  ·  "..data.status) or "")
        if data then
            c.icon.icon:SetTexture(data.icon or 134400)
            if data.status=="미확인" then missingNames[#missingNames+1]=data.name end
        end
    end
    missingText:SetText(#missingNames>0 and table.concat(missingNames,"\n") or "미확인 목표 아이템 없음")
end
function AP.ToggleUI()
    if ROOT:IsShown() then ROOT:Hide() else ROOT:Show();switch(current);AP.RefreshUI() end
end
ROOT:SetScript("OnShow",function()if AP.RefreshUI then AP.RefreshUI()end end)
switch(1)

-- Compact mode keeps one installation and one character-specific data source.
-- It changes only the display, never scan or season tracking records.
local compactFrame=CreateFrame("Frame",nil,ROOT)
compactFrame:SetAllPoints()
compactFrame:Hide()
local compactHeader=label(compactFrame,"아랑플래너  |  요약",27,24,"GameFontNormalLarge",GOLD)
local compactSpec=label(compactFrame,"",27,82,"GameFontHighlight",IVORY)
local compactCount=label(compactFrame,"",27,121,"GameFontNormalLarge",GOLD)
local compactHint=label(compactFrame,"현재 착용 및 가방 보유 기준 · 자세히 보기로 복원",27,161,"GameFontHighlightSmall",MUTED)
compactHint:SetWidth(400)
local compact=false
local compactButton=button(top,"-",1138,16,38,31,nil)
local function saveCompact()
    if type(ArangPlannerDB)=="table" then
        ArangPlannerDB.settings=ArangPlannerDB.settings or {}
        ArangPlannerDB.settings.compact=compact
    end
end
local function setCompact(state)
    compact=not not state
    if compact then
        ROOT:SetSize(460,225)
    else ROOT:SetSize(1280,720) end
    top:SetShown(not compact)
    left:SetShown(not compact)
    mid:SetShown(not compact)
    right:SetShown(not compact)
    for i=2,#content do content[i]:SetShown(not compact and current==i) end
    compactFrame:SetShown(compact)
    if compact then
        local total,have=AP.TargetCounts()
        compactSpec:SetText("전문화: "..AP.GetSpecName())
        compactCount:SetText(string.format("목표 %d   보유 %d   미보유 %d",total,have,total-have))
    end
    saveCompact()
end
compactButton:SetScript("OnClick",function()setCompact(true)end)
button(compactFrame,"복원",360,18,76,32,function()setCompact(false);switch(current);AP.RefreshUI()end)
button(compactFrame,"X",360,177,76,30,function()ROOT:Hide()end)
local previousToggle=AP.ToggleUI
function AP.ToggleUI()
    if ROOT:IsShown() then ROOT:Hide() else
        ROOT:Show()
        local saved=type(ArangPlannerDB)=="table" and ArangPlannerDB.settings and ArangPlannerDB.settings.compact
        setCompact(saved==true)
        switch(current)
        if compact then
            for i=2,#content do content[i]:Hide() end
        end
        AP.RefreshUI()
    end
end

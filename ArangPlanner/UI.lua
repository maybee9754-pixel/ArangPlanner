-- ArangPlanner 1.9.1: independently created black-and-gold equipment dashboard.
-- Uses Blizzard UI templates and built-in item/model APIs. No GearPlanner art/code.
local AP=_G.ArangPlanner
local GOLD={.96,.76,.22}
local IVORY={.94,.91,.83}
local MUTED={.64,.62,.57}
local ROOT=CreateFrame("Frame","ArangPlannerWindow",UIParent,"BackdropTemplate")
ROOT:SetSize(1460,850)
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
local top=pane(ROOT,13,11,1434,66)
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
button(top,"X",1380,16,38,31,function()ROOT:Hide()end)

-- Fixed three-column hierarchy, matching the approved screenshot.
local left=pane(ROOT,13,88,346,744)
local mid=pane(ROOT,366,88,628,744)
local right=pane(ROOT,1001,88,446,744)
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
local specText=label(mid,"목표 장비 등록 | 부위를 선택하세요",20,50,"GameFontNormal",GOLD)
-- Specialization-responsive visual backdrop, no 3D model or proprietary art.
-- WoW provided specialization backgrounds only. Never stretch a low-res
-- 64x64 specialization icon into a large 3D panel.
local specBacking=CreateFrame("Frame",nil,mid)
specBacking:SetPoint("TOPLEFT",118,-92)
specBacking:SetSize(320,399)
local specTexture=specBacking:CreateTexture(nil,"BACKGROUND")
specTexture:SetAllPoints()
specTexture:SetAlpha(.15)
local specShade=specBacking:CreateTexture(nil,"BORDER")
specShade:SetAllPoints()
specShade:SetColorTexture(.025,.02,.028,.72)
local specSmallIcon=mid:CreateTexture(nil,"ARTWORK")
specSmallIcon:SetPoint("TOPLEFT",mid,"TOPLEFT",480,-46)
specSmallIcon:SetSize(19,19)
local specLoaded
local function modelRefresh()
    local index=GetSpecialization and GetSpecialization()
    if not index then return end
    local id,icon,background
    if C_SpecializationInfo and type(C_SpecializationInfo.GetSpecializationInfo)=="function" then
        local ok,a,_,__,d,___,____,_____,h=pcall(C_SpecializationInfo.GetSpecializationInfo,index)
        if ok then id,icon,background=a,d,h end
    end
    if not id and GetSpecializationInfo then
        local ok,a,_,__,d=pcall(GetSpecializationInfo,index)
        if ok then id,icon=a,d end
    end
    if type(id)=="number" and specLoaded==id then return end
    specLoaded=id
    specSmallIcon:SetTexture(icon or 134400)
    if type(background)=="string" and background~="" then
        local path=background:find("\\",1,true) and background
            or ("Interface\\TALENTFRAME\\"..background)
        specTexture:SetTexture(path)
        specTexture:SetAlpha(.18)
    else
        -- Leave as dark stone when Blizzard gives no high-resolution art.
        specTexture:SetTexture(nil)
    end
end
-- A target can be assigned only after the user selects a slot and registers
-- an eligible item from the loot panel. No inventory item is auto imported.
local selectedSlot=1
local refreshBrowser
local selectedItem=nil
local itemEntry
local selectedTitle,selectedDetail
local refreshOptions
local planSpec=nil
function AP.SelectPlanSlot(slot)
    selectedSlot=slot
    selectedItem=nil
    if itemEntry then itemEntry:SetText("") end
    if selectedTitle then selectedTitle:SetText("장비를 선택하세요.") end
    if selectedDetail then selectedDetail:SetText("선택 부위: "..AP.LootCatalog.SlotLabel(slot)) end
    if refreshOptions then refreshOptions(slot) end
    if AP.RefreshUI then AP.RefreshUI() end
    if refreshBrowser then refreshBrowser() end
end
local slots={
    {1,15,105},{3,15,163},{5,15,221},{9,15,279},{10,15,337},
    {15,481,105},{6,481,163},{7,481,221},{8,481,279},{11,481,337},
    {2,87,475},{12,194,475},{13,301,475},{14,408,475},
    {16,140,539},{17,350,539}
}
local equipIcons={}
for _,sd in ipairs(slots) do
    local slot,x,y=sd[1],sd[2],sd[3]
    local f=newIcon(mid,x,y,54,49)
    f.slot=slot
    f:RegisterForClicks("LeftButtonUp","RightButtonUp")
    f.icon:SetTexture(nil)
    local itemLevel=label(f,"",3,30,"GameFontNormalSmall",GOLD)
    local equippedName=label(mid,"",x+((x>440) and -92 or 60),y+12,"GameFontHighlightSmall",IVORY)
    equippedName:SetWidth(90)
    equippedName:SetWordWrap(false)
    if x>440 then equippedName:SetJustifyH("RIGHT") end
    f:SetScript("OnClick",function(self)
        if IsControlKeyDown and IsControlKeyDown() then
            if AP.ClearSlotTarget(self.slot) then
                alert(AP.LootCatalog.SlotLabel(self.slot).." 목표를 비웠습니다.")
            end
            AP.RefreshUI()
        else
            AP.SelectPlanSlot(self.slot)
        end
    end)
    f:SetScript("OnEnter",function(self)
        local id=AP.GetSlotTarget(self.slot)
        GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
        if id then
            local ok=pcall(GameTooltip.SetItemByID,GameTooltip,id)
            if not ok then GameTooltip:SetText(AP.LootCatalog.SlotLabel(self.slot)) end
        else GameTooltip:SetText(AP.LootCatalog.SlotLabel(self.slot).." · 미등록") end
        GameTooltip:AddLine("클릭: 부위 선택 / Ctrl+클릭: 목표 제거",.9,.8,.4)
        GameTooltip:Show()
    end)
    f:SetScript("OnLeave",function()GameTooltip:Hide()end)
    equipIcons[#equipIcons+1]={f=f,lvl=itemLevel,name=equippedName}
end
local help=label(mid,"빈 슬롯 클릭 → 전리품 선택 → 등급·강화 설정 → 등록    |    Ctrl+클릭: 제거",24,719,"GameFontHighlightSmall",MUTED)
help:SetWidth(575)

-- Raid / dungeon / delve / outdoor hierarchy, populated from WoW's journal.
bar(right,"전리품 목록")
local expanded={raid=true,dungeon=true,delve=true,outdoor=true}
local openInstance,openBoss={},{}
local browser=CreateFrame("ScrollFrame",nil,right,"UIPanelScrollFrameTemplate")
browser:SetPoint("TOPLEFT",right,"TOPLEFT",16,-59)
browser:SetSize(400,444)
local child=CreateFrame("Frame",nil,browser)
child:SetSize(374,444)
browser:SetScrollChild(child)
local buttons={}
local function clear()
    for _,f in ipairs(buttons) do f:Hide();f:SetParent(nil) end
    wipe(buttons)
end
selectedTitle=label(right,"장비를 선택하세요.",20,518,"GameFontNormal",GOLD)
selectedTitle:SetWidth(404)
selectedDetail=label(right,"획득처가 이곳에 표시됩니다.",20,540,"GameFontHighlightSmall",MUTED)
selectedDetail:SetWidth(405)
itemEntry=CreateFrame("EditBox",nil,right,"InputBoxTemplate")
itemEntry:SetPoint("TOPLEFT",25,-568);itemEntry:SetSize(302,28)
itemEntry:SetAutoFocus(false);itemEntry:SetMaxLetters(256);itemEntry:EnableMouse(true)

-- Configuration is a saved *plan*, not evidence of an upgraded item.
local tracks={"탐험가","모험가","노련가","용사","영웅","신화"}
local chosenTrack="영웅"
local chosenRank=1
local venomFlag=false
local catalystFlag=false
local trackLabel=label(right,"등급",20,612,"GameFontNormal",GOLD)
local rankLabel=label(right,"강화 단계",20,647,"GameFontNormal",GOLD)
local trackButton=button(right,"영웅 ▾",117,603,303,29,nil)
local rankButton=button(right,"1/6 ▾",117,638,303,29,nil)
local venomCheck=CreateFrame("CheckButton",nil,right,"UICheckButtonTemplate")
venomCheck:SetPoint("TOPLEFT",18,-671)
venomCheck:SetSize(27,27)
label(right,"맹독석 (계획)",52,675,"GameFontHighlight",IVORY)
local catalystCheck=CreateFrame("CheckButton",nil,right,"UICheckButtonTemplate")
catalystCheck:SetPoint("TOPLEFT",214,-671)
catalystCheck:SetSize(27,27)
label(right,"티어 변환 (계획)",248,675,"GameFontHighlight",IVORY)
local canCatalyst={ [1]=true,[3]=true,[5]=true,[7]=true,[10]=true }
refreshOptions=function(slot)
    local v=AP.GetSlotOptions(slot or 1)
    chosenTrack=v.track
    chosenRank=v.rank
    venomFlag=v.venom
    catalystFlag=v.catalyst
    trackButton:SetText(chosenTrack.." ▾")
    rankButton:SetText(chosenRank.."/6 ▾")
    venomCheck:SetChecked(venomFlag)
    catalystCheck:SetChecked(catalystFlag)
    catalystCheck:SetEnabled(canCatalyst[slot or 1]==true)
end
trackButton:SetScript("OnClick",function()
    local index=1
    for i,v in ipairs(tracks) do if v==chosenTrack then index=i;break end end
    chosenTrack=tracks[index%#tracks+1]
    trackButton:SetText(chosenTrack.." ▾")
end)
rankButton:SetScript("OnClick",function()
    chosenRank=chosenRank%6+1
    rankButton:SetText(chosenRank.."/6 ▾")
end)
venomCheck:SetScript("OnClick",function(self)venomFlag=self:GetChecked()==true end)
catalystCheck:SetScript("OnClick",function(self)catalystFlag=self:GetChecked()==true end)
refreshOptions(1)

local function registerItem()
    if not selectedSlot then
        alert("가운데에서 등록할 장비 부위를 먼저 선택하세요.")
        return
    end
    local id=AP.GetItemIDFromText(itemEntry:GetText())
    if not id then
        alert("오른쪽에서 아이템을 선택한 뒤 등록하세요.")
        return
    end
    if not AP.LootCatalog or not AP.LootCatalog.MatchesSlot(id,selectedSlot) then
        alert("선택한 부위에 착용할 수 있는 장비만 등록할 수 있습니다.")
        return
    end
    local ok,reason=AP.AssignSlotTarget(selectedSlot,id)
    if not ok then alert(reason or "등록 실패");return end
    AP.SetSlotOptions(selectedSlot,{
        track=chosenTrack,rank=chosenRank,
        venom=venomFlag,catalyst=catalystFlag})
    alert(AP.LootCatalog.SlotLabel(selectedSlot).." 목표 등록 완료")
    selectedItem=nil
    itemEntry:SetText("")
    if AP.RefreshUI then AP.RefreshUI() end
end
button(right,"등록",16,700,410,33,registerItem)
itemEntry:SetScript("OnEnterPressed",function(self)registerItem();self:ClearFocus()end)
itemEntry:SetScript("OnEscapePressed",function(self)self:ClearFocus()end)
if type(ChatEdit_InsertLink)=="function" then
    hooksecurefunc("ChatEdit_InsertLink",function(link)
        if ROOT:IsShown() and type(link)=="string" and IsShiftKeyDown() and AP.GetItemIDFromText(link) then
            itemEntry:SetText(link);itemEntry:SetFocus()
        end
    end)
end
local function selectItem(data)
    if not selectedSlot then
        alert("가운데 목표 장비 부위를 먼저 선택하세요.")
        return
    end
    if not AP.LootCatalog.MatchesSlot(data.id,selectedSlot) then
        alert("선택한 부위와 일치하지 않는 장비입니다.")
        return
    end
    selectedItem=data
    selectedTitle:SetText(data.name or ("아이템 "..data.id))
    selectedDetail:SetText(AP.LootCatalog.SlotLabel(selectedSlot).." · "
        ..(data.sourceText or "획득처 확인 필요"))
    itemEntry:SetText(tostring(data.id))
end
local function makeRow(y,h,depth,title,kind,action,item)
    local f=CreateFrame("Button",nil,child,"BackdropTemplate")
    f:SetPoint("TOPLEFT",child,"TOPLEFT",depth,-y)
    f:SetSize(374-depth,h)
    f:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",
        edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
    local group=(kind=="group")
    local zone=(kind=="instance")
    f:SetBackdropColor(group and .21 or zone and .15 or .075,
        group and .155 or zone and .105 or .065,.04,.96)
    f:SetBackdropBorderColor(group and .7 or zone and .46 or .27,
        group and .51 or zone and .32 or .22,.13,
        group and 1 or zone and .85 or .42)
    local textX=item and 43 or 10
    local name=label(f,title,textX,item and 6 or 7,
        "GameFontHighlightSmall",group and GOLD or IVORY)
    name:SetWidth(f:GetWidth()-textX-7)
    name:SetWordWrap(false)
    if item then
        local icon=f:CreateTexture(nil,"ARTWORK")
        icon:SetSize(34,34)
        icon:SetPoint("LEFT",5,0)
        icon:SetTexture(item.icon or (C_Item and C_Item.GetItemIconByID
            and C_Item.GetItemIconByID(item.id)) or 134400)
        local source=label(f,"획득처: "..(item.sourceText or "미확인"),
            textX,25,"GameFontHighlightSmall",MUTED)
        source:SetWidth(f:GetWidth()-textX-5)
        source:SetWordWrap(false)
        f:SetScript("OnEnter",function()
            GameTooltip:SetOwner(f,"ANCHOR_RIGHT")
            if item.link then pcall(GameTooltip.SetHyperlink,GameTooltip,item.link)
            elseif GameTooltip.SetItemByID then
                pcall(GameTooltip.SetItemByID,GameTooltip,item.id)
            end
            GameTooltip:Show()
        end)
        f:SetScript("OnLeave",function()GameTooltip:Hide()end)
    end
    f:SetScript("OnClick",action)
    buttons[#buttons+1]=f
end
refreshBrowser=function()
    if not ROOT:IsShown() or not right:IsShown() then return end
    if not AP.LootCatalog then return end
    local catalog=AP.LootCatalog
    local sources,reason=catalog.Instances()
    clear()
    local y,n=0,0
    local function add(h,depth,title,kind,fn,item)
        if n>=170 then return end
        makeRow(y,h,depth,title,kind,fn or function()end,item)
        y=y+h+3
        n=n+1
    end
    local function candidate(item)
        return catalog.IsEquipment(item.id)
            and (not selectedSlot or catalog.MatchesSlot(item.id,selectedSlot))
    end
    local function listItems(items,depth,emptyMessage,status)
        local shown=0
        for _,item in ipairs(items or {}) do
            if n>=170 then break end
            if candidate(item) then
                shown=shown+1
                add(49,depth,item.name,"item",function()selectItem(item)end,item)
            end
        end
        if shown==0 then
            local msg=status=="loading" and "전리품 불러오는 중 · 클릭해 새로고침"
                or status=="filter-unavailable" and "전문화 필터 적용 실패"
                or status=="unavailable" and "모험 안내서 연결 실패"
                or emptyMessage or "선택 부위 전리품 없음"
            add(27,depth,msg,"text",refreshBrowser)
        end
    end
    if not sources then
        add(38,0,reason or "모험 안내서를 불러올 수 없습니다.","group")
    else
        local names={
            {"맹독 심연",{"맹독 심연","The Venomous Abyss"}},
            {"님리사",{"해일결속 동굴","The Tidebound Grotto"}},
            {"키식스",{"키식스 해방","The Unbinding of Kithix"}},
        }
        local ordered={}
        local taken={}
        for _,wanted in ipairs(names) do
            for _,instance in ipairs(sources.raid or {}) do
                local found=false
                local actual=(instance.name or ""):lower()
                for _,alias in ipairs(wanted[2]) do
                    if actual:find(alias:lower(),1,true) then found=true;break end
                end
                if found and not taken[instance.id] then
                    taken[instance.id]=true
                    ordered[#ordered+1]={id=instance.id,name=wanted[1]}
                    break
                end
            end
        end
        add(31,0,(expanded.raid and "[-]  " or "[+]  ").."공격대","group",function()
            expanded.raid=not expanded.raid;refreshBrowser()
        end)
        if expanded.raid then
            for _,instance in ipairs(ordered) do
                if n>=170 then break end
                local id=instance.id
                local opened=openInstance[id]==true
                add(30,8,(opened and "[-] " or "[+] ")..instance.name,
                    "instance",function()
                        openInstance[id]=not openInstance[id]
                        refreshBrowser()
                    end)
                if opened then
                    -- Raid section is one combined gear list, with boss source
                    -- displayed on the second line of every item.
                    local items,status=catalog.RaidLoot(id)
                    listItems(items,14,"선택 부위 전리품 없음",status)
                end
            end
        end
        add(31,0,(expanded.dungeon and "[-]  " or "[+]  ").."쐐기돌 던전","group",function()
            expanded.dungeon=not expanded.dungeon;refreshBrowser()
        end)
        if expanded.dungeon then
            for _,instance in ipairs(sources.dungeon or {}) do
                if n>=170 then break end
                local title=instance.name or ""
                -- EJ lists a virtual "Mythic+ Dungeons" instance; it must not
                -- appear as another selectable dungeon under the category.
                local lower=title:lower()
                if title~="쐐기돌 던전" and lower~="mythic+ dungeons"
                    and lower~="mythic dungeons" then
                    local id=instance.id
                    local opened=openInstance["d"..id]==true
                    add(29,9,(opened and "[-] " or "[+] ")..title,"instance",function()
                        openInstance["d"..id]=not openInstance["d"..id]
                        refreshBrowser()
                    end)
                    if opened then
                        local items,status=catalog.DungeonLoot(id)
                        listItems(items,22,"선택 부위 전리품 없음",status)
                    end
                end
            end
        end
        -- Delve/outdoor source providers are unpopulated. Keep clean category
        -- headers without repeating misleading "data preparation" rows.
        for _,section in ipairs({{"delve","구렁"},{"outdoor","야외"}}) do
            local key,title=section[1],section[2]
            add(31,0,(expanded[key] and "[-]  " or "[+]  ")..title,"group",function()
                expanded[key]=not expanded[key];refreshBrowser()
            end)
            if expanded[key] then
                for _,instance in ipairs(sources[key] or {}) do
                    local id=instance.id
                    local opened=openInstance[key..id]==true
                    add(29,9,(opened and "[-] " or "[+] ")..instance.name,"instance",function()
                        openInstance[key..id]=not openInstance[key..id];refreshBrowser()
                    end)
                    if opened and catalog.DungeonLoot then
                        local items,status=catalog.DungeonLoot(id)
                        listItems(items,22,"전리품 없음",status)
                    end
                end
            end
        end
    end
    child:SetHeight(math.max(445,y))
end
button(right,"새로고침",330,564,92,32,function()
    if AP.LootCatalog then AP.LootCatalog.Invalidate() end
    refreshBrowser()
end)
local journalEvents=CreateFrame("Frame")
journalEvents:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
journalEvents:RegisterEvent("EJ_LOOT_DATA_RECIEVED")
journalEvents:SetScript("OnEvent",function()
    if not ROOT:IsShown() or not right:IsShown() then return end
    if C_Timer and C_Timer.After then
        C_Timer.After(.35,function()
            if ROOT:IsShown() and right:IsShown() then refreshBrowser() end
        end)
    end
end)

-- Other top-level tabs are honest WIP panels, not made-up acquisition records.
for i=2,#names do
    local holder=pane(ROOT,13,88,1434,744)
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
    local total,have=AP.SlotTargetCounts()
    rate:SetText(string.format("%.1f%%  달성률",total>0 and have*100/total or 0))
    counts:SetText(string.format("등록 %d     보유 %d     미보유 %d",total,have,total-have))
    special:SetText("현재 전문화: "..AP.GetSpecName())
    local specIndex=GetSpecialization and GetSpecialization()
    local currentSpec=specIndex and GetSpecializationInfo and GetSpecializationInfo(specIndex)
    if planSpec~=currentSpec then
        planSpec=currentSpec
        selectedSlot=1
        selectedItem=nil
        if itemEntry then itemEntry:SetText("") end
        if refreshOptions then refreshOptions(1) end
        if refreshBrowser then refreshBrowser() end
    end
    specText:SetText(AP.GetSpecName().." · 목표 장비 등록"
        ..(selectedSlot and (" | "..AP.LootCatalog.SlotLabel(selectedSlot)) or " | 부위를 선택하세요"))
    for _,r in ipairs(statRows) do r.value:SetText(statValue(r.index)) end
    local targets=AP.GetSlotTargets()
    local details=AP.GetSlotTargetRows()
    local bySlot={}
    for _,data in ipairs(details) do bySlot[data.slot]=data end
    for _,r in ipairs(equipIcons) do
        local slot=r.f.slot
        local data=bySlot[slot]
        local active=selectedSlot==slot
        r.f:SetBackdropBorderColor(active and 1 or .64,active and .83 or .48,
            active and .25 or .16,1)
        r.f:SetBackdropColor(active and .18 or .045,active and .13 or .04,
            active and .045 or .06,1)
        r.f.icon:SetTexture(data and data.icon or nil)
        r.lvl:SetText("")
        r.name:SetText(data and data.name or (AP.LootCatalog.SlotLabel(slot).." · 미등록"))
        if data and data.status=="착용" then r.lvl:SetText("✓") end
    end
    modelRefresh()
    local missingNames={}
    for _,data in ipairs(details) do
        if data.status=="미확인" then
            missingNames[#missingNames+1]=AP.LootCatalog.SlotLabel(data.slot)..": "..data.name
        end
    end
    missingText:SetText(#missingNames>0 and table.concat(missingNames,"\n")
        or "미획득 목표 아이템 없음")
end
function AP.ToggleUI()
    if ROOT:IsShown() then ROOT:Hide() else ROOT:Show();switch(current);AP.RefreshUI();refreshBrowser() end
end
ROOT:SetScript("OnShow",function()
    if UIParent and UIParent.GetWidth and UIParent.GetHeight then
        local w,h=UIParent:GetWidth(),UIParent:GetHeight()
        if w and h and w>0 and h>0 then
            ROOT:SetScale(math.min(1,(w-20)/1460,(h-20)/850))
        end
    end
    if AP.RefreshUI then AP.RefreshUI() end
end)
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
local compactButton=button(top,"-",1331,16,38,31,nil)
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
    else ROOT:SetSize(1460,850) end
    top:SetShown(not compact)
    left:SetShown(not compact)
    mid:SetShown(not compact)
    right:SetShown(not compact)
    for i=2,#content do content[i]:SetShown(not compact and current==i) end
    compactFrame:SetShown(compact)
    if compact then
        local total,have=AP.SlotTargetCounts()
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
        if not compact then refreshBrowser() end
    end
end

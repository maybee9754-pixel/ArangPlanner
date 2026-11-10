-- ArangPlanner 1.9.8: independently created black-and-gold equipment dashboard.
-- Uses Blizzard UI templates and built-in item/model APIs. No GearPlanner art/code.
local AP=_G.ArangPlanner
local GOLD={.96,.76,.22}
local IVORY={.94,.91,.83}
local MUTED={.64,.62,.57}
local ROOT=CreateFrame("Frame","ArangPlannerWindow",UIParent,"BackdropTemplate")
ROOT:SetSize(1565,850)
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
-- Original ArangPlanner bronze-stone controls, no third-party textures.
local function stoneButton(parent,txt,x,y,w,h,fn)
    local b=CreateFrame("Button",nil,parent,"BackdropTemplate")
    b:SetPoint("TOPLEFT",x,-y);b:SetSize(w,h)
    b:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
    b:SetBackdropColor(.09,.07,.065,1)
    b:SetBackdropBorderColor(.46,.35,.25,1)
    local title=b:CreateFontString(nil,"OVERLAY","GameFontHighlight")
    title:SetPoint("CENTER");title:SetWidth(w-15)
    title:SetText(txt);title:SetTextColor(.96,.83,.52)
    b.SetText=function(_,v)title:SetText(v)end
    b:SetScript("OnEnter",function(self)self:SetBackdropColor(.19,.14,.1,1)end)
    b:SetScript("OnLeave",function(self)self:SetBackdropColor(.09,.07,.065,1)end)
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
local top=pane(ROOT,13,11,1539,66)
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
button(top,"X",1485,16,38,31,function()ROOT:Hide()end)

-- Fixed three-column hierarchy, matching the approved screenshot.
local left=pane(ROOT,13,88,346,744)
local mid=pane(ROOT,366,88,628,744)
local right=pane(ROOT,1001,88,551,744)
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
missingText:SetWidth(280)
missingText:SetJustifyH("LEFT")
local missingRows={}
for i=1,5 do
    missingRows[i]=label(missing,"",18,52+(i-1)*24,"GameFontHighlightSmall",IVORY)
    missingRows[i]:SetWidth(289)
    missingRows[i]:SetWordWrap(false)
end
missingText:Hide()

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
    local lower=y>=470
    local equippedName=label(mid,"",lower and (x-7) or (x+((x>440) and -92 or 60)),
        lower and (y+54) or (y+12),"GameFontHighlightSmall",IVORY)
    equippedName:SetWidth(lower and 80 or 90)
    equippedName:SetWordWrap(false)
    if x>440 and not lower then equippedName:SetJustifyH("RIGHT") end
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

-- Independent loot explorer. Layout mirrors the familiar planning workflow,
-- but every frame, dropdown, selection and state handler is ArangPlanner code.
local filters={raid=true,dungeon=true,delve=true,outdoor=true}
local filterNames={{"raid","공격대"},{"dungeon","던전"},{"delve","구렁"},{"outdoor","기타"}}
local expanded={raid=true,dungeon=true,delve=true,outdoor=false}
local openInstance={}
local expandedInitialized=false
local browserButtons={}
local popup
local function closePopup()
    if popup then popup:Hide();popup=nil end
end
-- Lightweight popup with original ArangPlanner artwork. The selected
-- choice is highlighted without a red UIPanelButton, and the list opens
-- upward to remain inside the main window's equipment settings section.
local function dropdown(anchor,choices,onChoose,width,selected)
    if popup and popup.anchor==anchor then closePopup();return end
    closePopup()
    local frame=CreateFrame("Frame",nil,right,"BackdropTemplate")
    frame.anchor=anchor
    frame:SetSize(width or anchor:GetWidth(),#choices*24+8)
    frame:SetPoint("BOTTOMRIGHT",anchor,"TOPRIGHT",0,3)
    frame:SetFrameStrata("TOOLTIP")
    frame:SetFrameLevel(ROOT:GetFrameLevel()+95)
    frame:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",
        edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
    frame:SetBackdropColor(.04,.035,.043,1)
    frame:SetBackdropBorderColor(.54,.44,.24,1)
    frame:EnableMouse(true)
    for i,choice in ipairs(choices) do
        local row=CreateFrame("Button",nil,frame,"BackdropTemplate")
        row:SetPoint("TOPLEFT",frame,"TOPLEFT",4,-4-(i-1)*24)
        row:SetSize(frame:GetWidth()-8,23)
        row:SetFrameLevel(frame:GetFrameLevel()+1)
        row:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8"})
        row:SetBackdropColor(choice.value==selected and .18 or .055,
            choice.value==selected and .15 or .05,
            choice.value==selected and .09 or .06,1)
        local mark=label(row,choice.value==selected and "●" or "○",
            8,3,"GameFontHighlightSmall",choice.value==selected and GOLD or MUTED)
        local title=label(row,choice.label,30,3,"GameFontHighlight",IVORY)
        title:SetWidth(row:GetWidth()-38)
        row:SetScript("OnEnter",function(self)
            self:SetBackdropColor(.16,.13,.105,1)
        end)
        row:SetScript("OnLeave",function(self)
            self:SetBackdropColor(choice.value==selected and .18 or .055,
                choice.value==selected and .15 or .05,
                choice.value==selected and .09 or .06,1)
        end)
        row:SetScript("OnClick",function()
            onChoose(choice.value)
            closePopup()
        end)
    end
    popup=frame
end
local heading=label(right,"머리",20,14,"GameFontNormalLarge",IVORY)
heading:SetWidth(258)
heading:SetTextColor(1,.96,.85)
local sourceCaption=label(right,"전리품 목록",20,55,"GameFontHighlightSmall",GOLD)
sourceCaption:SetWidth(280)
local filterButton=stoneButton(right,"획득처 선택 ▾",373,15,160,29,nil)
local filterMenu=CreateFrame("Frame",nil,right,"BackdropTemplate")
filterMenu:SetPoint("TOPRIGHT",filterButton,"BOTTOMRIGHT",0,0)
filterMenu:SetSize(190,137)
filterMenu:SetFrameStrata("DIALOG")
filterMenu:SetFrameLevel(ROOT:GetFrameLevel()+110)
filterMenu:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",
    edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
filterMenu:SetBackdropColor(.035,.028,.035,.99)
filterMenu:SetBackdropBorderColor(.67,.52,.2,1)
filterMenu:EnableMouse(true)
local filterCount=label(filterMenu,"표시할 획득처",12,8,"GameFontHighlightSmall",GOLD)
local filterChecks={}
for i,entry in ipairs(filterNames) do
    local cb=CreateFrame("CheckButton",nil,filterMenu,"UICheckButtonTemplate")
    cb:SetSize(23,23)
    cb:SetPoint("TOPLEFT",filterMenu,"TOPLEFT",10,-28-(i-1)*25)
    cb:SetChecked(filters[entry[1]])
    label(filterMenu,entry[2],39,30+(i-1)*25,"GameFontHighlightSmall",IVORY)
    cb:SetScript("OnClick",function(self)
        filters[entry[1]]=self:GetChecked()==true
        if refreshBrowser then refreshBrowser() end
    end)
    filterChecks[i]=cb
end
filterMenu:Hide()
filterButton:SetScript("OnClick",function()
    closePopup()
    filterMenu:SetShown(not filterMenu:IsShown())
end)
local reload=stoneButton(right,"새로고침",280,15,89,29,function()
    if AP.LootCatalog then AP.LootCatalog.Invalidate() end
    if refreshBrowser then refreshBrowser() end
end)
reload:SetScript("OnEnter",function(self)
    GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
    GameTooltip:SetText("전리품 목록 새로고침")
    GameTooltip:Show()
end)
reload:SetScript("OnLeave",function() GameTooltip:Hide() end)
local browser=CreateFrame("ScrollFrame",nil,right,"UIPanelScrollFrameTemplate")
browser:SetPoint("TOPLEFT",right,"TOPLEFT",15,-84)
browser:SetSize(502,387)
local child=CreateFrame("Frame",nil,browser)
child:SetSize(474,387)
browser:SetScrollChild(child)
local function clearRows()
    for _,f in ipairs(browserButtons) do f:Hide();f:SetParent(nil) end
    wipe(browserButtons)
end
local function makeRow(y,h,depth,title,kind,action,item)
    local f=CreateFrame("Button",nil,child,"BackdropTemplate")
    f:SetPoint("TOPLEFT",child,"TOPLEFT",depth,-y)
    f:SetSize(474-depth,h)
    f:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",
        edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
    local main=(kind=="group")
    local region=(kind=="instance")
    local active=item and selectedItem and selectedItem.id==item.id
    if main then
        f:SetBackdropColor(.07,.06,.11,1)
        f:SetBackdropBorderColor(.33,.33,.56,1)
    elseif region then
        f:SetBackdropColor(.17,.13,.10,1)
        f:SetBackdropBorderColor(.30,.24,.17,1)
    elseif active then
        f:SetBackdropColor(.075,.19,.34,1)
        f:SetBackdropBorderColor(.34,.75,1,1)
    else
        f:SetBackdropColor(.11,.075,.065,1)
        f:SetBackdropBorderColor(.23,.17,.12,.7)
    end
    if kind=="group" then
        local dot=f:CreateTexture(nil,"ARTWORK")
        dot:SetPoint("LEFT",9,0)
        dot:SetSize(16,16)
        dot:SetTexture("Interface\\COMMON\\Indicator-Green")
    end
    local tx=item and 50 or main and 35 or 12
    local txt=label(f,title,tx,item and 6 or 8,
        main and "GameFontNormalLarge" or region and "GameFontNormal" or "GameFontHighlight",
        main and GOLD or region and GOLD or IVORY)
    txt:SetWidth(f:GetWidth()-tx-(item and 78 or 14))
    txt:SetWordWrap(false)
    if item then
        local icon=f:CreateTexture(nil,"ARTWORK")
        icon:SetSize(38,38)
        icon:SetPoint("LEFT",6,0)
        icon:SetTexture(item.icon or (C_Item and C_Item.GetItemIconByID
            and C_Item.GetItemIconByID(item.id)) or 134400)
        local name,_,quality,_,_,subtype
        if C_Item and C_Item.GetItemInfo then
            name,_,quality,_,_,subtype=C_Item.GetItemInfo(item.id)
        elseif GetItemInfo then
            name,_,quality,_,_,subtype=GetItemInfo(item.id)
        end
        if type(quality)=="number" and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality] then
            local c=ITEM_QUALITY_COLORS[quality]
            txt:SetTextColor(c.r,c.g,c.b)
        end
        local source=label(f,item.sourceBoss or item.sourceText or "획득처 확인 중",
            tx,27,"GameFontHighlightSmall",MUTED)
        source:SetWidth(f:GetWidth()-tx-13)
        source:SetWordWrap(false)
        if type(subtype)=="string" and subtype~="" then
            local armor=f:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
            armor:SetPoint("RIGHT",f,"RIGHT",-9,0)
            armor:SetText(subtype)
            armor:SetTextColor(.72,.68,.62)
        end
        if item.kind=="tierGear" then
            local tier=label(f,"T",30,31,"GameFontHighlightSmall",GOLD)
        end
        f:SetScript("OnEnter",function()
            GameTooltip:SetOwner(f,"ANCHOR_RIGHT")
            if item.link then pcall(GameTooltip.SetHyperlink,GameTooltip,item.link)
            elseif GameTooltip.SetItemByID then
                pcall(GameTooltip.SetItemByID,GameTooltip,item.id)
            end
            GameTooltip:Show()
        end)
        f:SetScript("OnLeave",function() GameTooltip:Hide() end)
    end
    f:SetScript("OnClick",function() closePopup();filterMenu:Hide();if action then action() end end)
    browserButtons[#browserButtons+1]=f
end
local options=pane(right,10,480,532,253)
options:SetBackdropColor(.018,.013,.014,1)
options:SetBackdropBorderColor(.4,.3,.19,1)
local separator=options:CreateTexture(nil,"ARTWORK")
separator:SetPoint("TOPLEFT",options,"TOPLEFT",7,-6)
separator:SetPoint("TOPRIGHT",options,"TOPRIGHT",-7,-6)
separator:SetHeight(2)
separator:SetColorTexture(.65,.46,.13,1)
local choiceIcon
choiceIcon=newIcon(right,35,496,39,39)
choiceIcon:EnableMouse(false)
choiceIcon.icon:SetTexture(nil)
selectedTitle=label(right,"장비를 선택하세요",84,502,"GameFontNormalLarge",IVORY)
selectedTitle:SetWidth(431)
selectedDetail=label(right,"목표 장비를 선택하세요",84,526,"GameFontHighlightSmall",IVORY)
selectedDetail:SetWidth(425)
itemEntry=CreateFrame("EditBox",nil,right,"InputBoxTemplate")
itemEntry:SetPoint("TOPLEFT",28,-549)
itemEntry:SetSize(484,23)
itemEntry:SetAutoFocus(false)
itemEntry:SetMaxLetters(256)
itemEntry:EnableMouse(true)
local trackLabel=label(right,"등급:",120,581,"GameFontNormal",GOLD)
local rankLabel=label(right,"강화 단계:",120,612,"GameFontNormal",GOLD)
local tracks={"탐험가","모험가","노련가","용사","영웅","신화"}
local chosenTrack,chosenRank="영웅",1
local venomFlag,catalystFlag=false,false
local trackButton=stoneButton(right,"영웅  ▾",241,577,273,27,nil)
local rankButton=stoneButton(right,"1/6  ▾",241,607,273,27,nil)
local venomCheck=CreateFrame("CheckButton",nil,right,"UICheckButtonTemplate")
venomCheck:SetPoint("TOPLEFT",155,-638);venomCheck:SetSize(26,26)
local venomLabel=label(right,"맹독석 강화 (계획)",185,643,"GameFontHighlightSmall",GOLD)
local catalystCheck=CreateFrame("CheckButton",nil,right,"UICheckButtonTemplate")
catalystCheck:SetPoint("TOPLEFT",155,-667);catalystCheck:SetSize(26,26)
local catalystLabel=label(right,"티어 변환 (계획)",185,672,"GameFontHighlightSmall",GOLD)
local originalText=label(right,"원본 장비: 선택한 장비",34,697,"GameFontHighlightSmall",MUTED)
originalText:SetWidth(476)
local canCatalyst={[1]=true,[3]=true,[5]=true,[7]=true,[10]=true}
local function updateOptions()
    trackButton:SetText(chosenTrack.."  ▾")
    rankButton:SetText(chosenRank.."/6  ▾")
    venomCheck:SetChecked(venomFlag)
    catalystCheck:SetChecked(catalystFlag)
    catalystCheck:SetEnabled(canCatalyst[selectedSlot or 1]==true)
end
refreshOptions=function(slot)
    local v=AP.GetSlotOptions(slot or 1)
    chosenTrack=v.track or "영웅"
    chosenRank=v.rank or 1
    venomFlag=v.venom==true
    catalystFlag=v.catalyst==true
    updateOptions()
end
trackButton:SetScript("OnClick",function()
    filterMenu:Hide()
    local c={}
    for _,name in ipairs(tracks)do c[#c+1]={label=name,value=name}end
    dropdown(trackButton,c,function(value)
        chosenTrack=value
        updateOptions()
    end,225,chosenTrack)
end)
rankButton:SetScript("OnClick",function()
    filterMenu:Hide()
    local c={}
    for i=1,6 do c[#c+1]={label=i.."/6",value=i}end
    dropdown(rankButton,c,function(value)
        chosenRank=value
        updateOptions()
    end,225,chosenRank)
end)
venomCheck:SetScript("OnClick",function(self)venomFlag=self:GetChecked()==true end)
catalystCheck:SetScript("OnClick",function(self)catalystFlag=self:GetChecked()==true end)
local function registerItem()
    local slot=selectedSlot or 1
    local id=AP.GetItemIDFromText(itemEntry:GetText())
    if not id then alert("전리품 목록에서 장비를 선택하세요.");return end
    if not AP.LootCatalog or not AP.LootCatalog.MatchesSlot(id,slot) then
        alert("선택한 슬롯과 장비 부위가 일치하지 않습니다.");return
    end
    local ok,reason=AP.AssignSlotTarget(slot,id)
    if not ok then alert(reason or "등록 실패");return end
    AP.SetSlotOptions(slot,{
        track=chosenTrack,rank=chosenRank,venom=venomFlag,catalyst=catalystFlag})
    alert(AP.LootCatalog.SlotLabel(slot).." 목표 등록 완료")
    if AP.RefreshUI then AP.RefreshUI() end
end
stoneButton(right,"등록",151,710,245,24,registerItem)
itemEntry:SetScript("OnEnterPressed",function(self)registerItem();self:ClearFocus()end)
itemEntry:SetScript("OnEscapePressed",function(self)self:ClearFocus()end)
if type(ChatEdit_InsertLink)=="function" then
    hooksecurefunc("ChatEdit_InsertLink",function(link)
        if ROOT:IsShown() and type(link)=="string" and IsShiftKeyDown()
            and AP.GetItemIDFromText(link) then itemEntry:SetText(link) end
    end)
end
local function selectItem(item)
    if not AP.LootCatalog.MatchesSlot(item.id,selectedSlot or 1) then
        alert("선택한 부위와 일치하지 않는 장비입니다.");return
    end
    selectedItem=item
    choiceIcon.icon:SetTexture(item.icon or (C_Item and C_Item.GetItemIconByID
        and C_Item.GetItemIconByID(item.id)) or 134400)
    selectedTitle:SetText(item.name or ("아이템 "..item.id))
    selectedDetail:SetText(item.sourceText or "획득처 확인 중")
    originalText:SetText("원본 장비: "..(item.name or ("아이템 "..item.id)))
    itemEntry:SetText(tostring(item.id))
    if refreshBrowser then refreshBrowser() end
end
refreshBrowser=function()
    if not ROOT:IsShown() or not right:IsShown() or not AP.LootCatalog then return end
    heading:SetText(AP.LootCatalog.SlotLabel(selectedSlot or 1))
    local catalog=AP.LootCatalog
    local sources,reason=catalog.Instances()
    clearRows()
    local y,count=0,0
    local function add(h,depth,title,kind,fn,item)
        if count>=160 then return end
        makeRow(y,h,depth,title,kind,fn,item)
        y=y+h+3;count=count+1
    end
    local function listItems(items,status)
        local shown=0
        for _,item in ipairs(items or {}) do
            if count>=160 then break end
            if catalog.IsEquipment(item.id) and catalog.MatchesSlot(item.id,selectedSlot or 1) then
                shown=shown+1
                add(53,12,item.name or ("아이템 "..item.id),"item",function()selectItem(item)end,item)
            end
        end
        if shown==0 then
            local msg=status=="loading" and "전리품 불러오는 중"
                or status=="filter-unavailable" and "전문화 전리품 필터 오류"
                or "선택 부위의 장비가 없습니다"
            add(28,10,msg,"text",refreshBrowser)
        end
    end
    if not sources then
        add(34,0,reason or "모험 안내서를 불러올 수 없습니다","group",refreshBrowser)
    else
        local raids={}
        local names={
            {"맹독 심연",{"맹독 심연","The Venomous Abyss"}},
            {"님리사",{"해일결속 동굴","The Tidebound Grotto"}},
            {"키식스",{"키식스 해방","The Unbinding of Kithix"}}}
        local taken={}
        for _,wanted in ipairs(names)do
            for _,v in ipairs(sources.raid or {})do
                if not taken[v.id] then
                    local actual=(v.name or ""):lower()
                    local found=false
                    for _,alias in ipairs(wanted[2])do
                        if actual:find(alias:lower(),1,true) then found=true;break end
                    end
                    if found then
                        raids[#raids+1]={id=v.id,name=wanted[1]}
                        taken[v.id]=true
                        break
                    end
                end
            end
        end
        local function section(key,title,instances,lootFn)
            if not filters[key] then return end
            add(38,0,(expanded[key] and "[-] " or "[+] ")..title,"group",function()
                expanded[key]=not expanded[key];refreshBrowser()
            end)
            if not expanded[key] then return end
            for _,v in ipairs(instances or {}) do
                if count>=160 then break end
                local id=v.id
                local opened=openInstance[key..tostring(id)]==true
                local zoneName=v.name or ("지역 "..id)
                if key~="dungeon" or
                    (zoneName~="쐐기돌 던전" and zoneName:lower()~="mythic+ dungeons") then
                    add(28,7,(opened and "[-] " or "[+] ")..zoneName,"instance",function()
                        openInstance[key..tostring(id)]=not openInstance[key..tostring(id)]
                        refreshBrowser()
                    end)
                    if opened then
                        local items,status=lootFn(id)
                        listItems(items,status)
                    end
                end
            end
        end
        -- Open the first actual raid and dungeon on first display, so users
        -- immediately see selectable equipment rather than empty closed rows.
        if not expandedInitialized then
            expandedInitialized=true
            if raids[1] then openInstance["raid"..tostring(raids[1].id)]=true end
            if sources.dungeon and sources.dungeon[1] then
                openInstance["dungeon"..tostring(sources.dungeon[1].id)]=true
            end
        end
        section("raid","공격대",raids,function(id)return catalog.RaidLoot(id)end)
        section("dungeon","던전",sources.dungeon,function(id)return catalog.DungeonLoot(id)end)
        section("delve","구렁",sources.delve or {},function(id)return catalog.DungeonLoot(id)end)
        section("outdoor","기타",sources.outdoor or {},function(id)return catalog.DungeonLoot(id)end)
    end
    child:SetHeight(math.max(387,y))
end
refreshOptions(1)
local journalEvents=CreateFrame("Frame")
journalEvents:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
journalEvents:RegisterEvent("EJ_LOOT_DATA_RECIEVED")
journalEvents:SetScript("OnEvent",function()
    if ROOT:IsShown() and right:IsShown() and C_Timer and C_Timer.After then
        C_Timer.After(.35,function()
            if ROOT:IsShown() and right:IsShown() then refreshBrowser() end
        end)
    end
end)

-- Other top-level tabs are honest WIP panels, not made-up acquisition records.
for i=2,#names do
    local holder=pane(ROOT,13,88,1539,744)
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
        if slot==2 or slot==12 or slot==13 or slot==14 or slot==16 or slot==17 then
            r.name:SetText(AP.LootCatalog.SlotLabel(slot))
        else
            local text=data and data.name or (AP.LootCatalog.SlotLabel(slot).." · 미등록")
            r.name:SetText(text)
        end
        if data and data.status=="착용" then r.lvl:SetText("✓") end
    end
    modelRefresh()
    local missingNames={}
    for _,data in ipairs(details) do
        if data.status=="미확인" then
            missingNames[#missingNames+1]=AP.LootCatalog.SlotLabel(data.slot)..": "..data.name
        end
    end
    for i,cell in ipairs(missingRows) do
        local value=missingNames[i] or (i==1 and #missingNames==0
            and "미획득 목표 아이템 없음" or "")
        cell:SetText(value)
    end
end
function AP.ToggleUI()
    if ROOT:IsShown() then ROOT:Hide() else ROOT:Show();switch(current);AP.RefreshUI();refreshBrowser() end
end
ROOT:SetScript("OnShow",function()
    if UIParent and UIParent.GetWidth and UIParent.GetHeight then
        local w,h=UIParent:GetWidth(),UIParent:GetHeight()
        if w and h and w>0 and h>0 then
            ROOT:SetScale(math.min(1,(w-20)/1565,(h-20)/850))
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
local compactButton=button(top,"-",1433,16,38,31,nil)
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
    else ROOT:SetSize(1565,850) end
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

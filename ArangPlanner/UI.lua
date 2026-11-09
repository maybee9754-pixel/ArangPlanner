-- ArangPlanner v1.2.1-alpha: in-game/web typography and spacing calibration.
-- All interactive labels are Blizzard Lua frames; art is generated from
-- tools/render_v12_skin.py, not copied from another addon.
local AP=_G.ArangPlanner
local TX="Interface\\AddOns\\ArangPlanner\\Textures\\"

local root=CreateFrame("Frame","ArangPlannerWindow",UIParent,"BackdropTemplate")
root:SetSize(1270,725)
root:SetPoint("CENTER")
root:SetClampedToScreen(true)
root:SetFrameStrata("DIALOG")
root:SetMovable(true)
root:EnableMouse(true)
root:RegisterForDrag("LeftButton")
root:SetScript("OnDragStart",root.StartMoving)
root:SetScript("OnDragStop",root.StopMovingOrSizing)
root:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",
                  edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
root:SetBackdropColor(.055,.054,.078,.99)
root:SetBackdropBorderColor(.30,.27,.36,1)

local function art(parent,filename,layer,alpha)
    local t=parent:CreateTexture(nil,layer or "BACKGROUND")
    t:SetAllPoints(parent)
    t:SetTexture(TX..filename..".tga")
    t:SetAlpha(alpha or 1)
    return t
end
local function text(parent,s,template)
    local fontObject=template or "GameFontHighlight"
    local f=parent:CreateFontString(nil,"OVERLAY",fontObject)
    -- Both frontends use the same numeric font sizes. Use the localized
    -- Blizzard font file so Korean glyph support remains intact.
    local sizes={GameFontHighlightSmall=12,GameFontNormalSmall=12,
        GameFontHighlight=13,GameFontNormal=13,GameFontNormalLarge=18}
    local wanted=sizes[fontObject]
    if wanted then
        local path,_,flags=f:GetFont()
        if path then f:SetFont(path,wanted,flags) end
    end
    f:SetText(s or "")
    return f
end
local function frame(parent,x,y,w,h,texture)
    local f=CreateFrame("Frame",nil,parent,"BackdropTemplate")
    f:SetPoint("TOPLEFT",parent,"TOPLEFT",x,-y)
    f:SetSize(w,h)
    f:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",
                    edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
    f:SetBackdropColor(.065,.063,.09,.97)
    f:SetBackdropBorderColor(.28,.25,.34,.85)
    if texture then art(f,texture,"BACKGROUND",.98) end
    return f
end
local function heading(parent,label)
    local bar=CreateFrame("Frame",nil,parent)
    bar:SetPoint("TOPLEFT",parent,"TOPLEFT",1,-1)
    bar:SetPoint("TOPRIGHT",parent,"TOPRIGHT",-1,-1)
    bar:SetHeight(33)
    art(bar,"panel-header")
    local t=text(bar,label,"GameFontNormal")
    t:SetPoint("LEFT",12,0)
    t:SetTextColor(.91,.88,.96)
    return bar
end
local function button(parent,caption,x,y,w,h,callback,active)
    local b=CreateFrame("Button",nil,parent,"BackdropTemplate")
    b:SetSize(w,h)
    b:SetPoint("TOPLEFT",parent,"TOPLEFT",x,-y)
    b:SetBackdrop({edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
    b:SetBackdropBorderColor(.32,.29,.38,.8)
    local idle=art(b,"button-idle","BACKGROUND")
    local on=art(b,"button-active","ARTWORK")
    local over=art(b,"button-hover","ARTWORK")
    over:SetAlpha(0)
    local label=text(b,caption,"GameFontHighlight")
    label:SetPoint("CENTER")
    label:SetTextColor(.94,.91,.97)
    b.activeTexture=on
    function b:SetVisualActive(yes)
        self.isActive=not not yes
        on:SetAlpha(self.isActive and 1 or 0)
        b:SetBackdropBorderColor(self.isActive and .57 or .32,self.isActive and .41 or .29,self.isActive and .69 or .38,.9)
    end
    b:SetVisualActive(active)
    b:SetScript("OnEnter",function()
        over:SetAlpha(b.isActive and .28 or .67)
    end)
    b:SetScript("OnLeave",function()over:SetAlpha(0)end)
    b:SetScript("OnClick",function()
        if callback then callback(b) end
    end)
    return b
end

-- Design-faithful title bar. Dragging only starts on non-button header area.
local header=frame(root,12,12,1246,72,"header")
header:EnableMouse(true)
header:RegisterForDrag("LeftButton")
header:SetScript("OnDragStart",function()root:StartMoving()end)
header:SetScript("OnDragStop",function()root:StopMovingOrSizing()end)
-- Native texture logo: Korean WoW fonts may not support decorative Unicode glyphs.
local mark=CreateFrame("Frame",nil,header)
mark:SetSize(35,35)
mark:SetPoint("LEFT",17,0)
local diamond=mark:CreateTexture(nil,"ARTWORK")
diamond:SetSize(21,21)
diamond:SetPoint("CENTER")
diamond:SetTexture("Interface\\Buttons\\WHITE8X8")
diamond:SetVertexColor(.69,.57,.85,.93)
diamond:SetRotation(math.pi/4)
local core=mark:CreateTexture(nil,"OVERLAY")
core:SetSize(12,12)
core:SetPoint("CENTER")
core:SetTexture("Interface\\Buttons\\WHITE8X8")
core:SetVertexColor(.90,.82,1,1)
core:SetRotation(math.pi/4)
local brand=text(header,"아랑플래너","GameFontNormalLarge")
brand:SetPoint("LEFT",mark,"RIGHT",10,9)
brand:SetTextColor(.96,.94,.98)
local ver=text(header,"ArangPlanner v1.2.0-alpha","GameFontHighlightSmall")
ver:SetPoint("LEFT",brand,"RIGHT",12,-1)
ver:SetTextColor(.66,.64,.72)
local tabs={}
local currentTab=1
local tabNames={"장비 세팅","공격대","쐐기돌","획득 추적기","설정"}
local function setTab(n)
    currentTab=n
    for i,b in ipairs(tabs) do b:SetVisualActive(i==n) end
    if AP.RefreshUI then AP.RefreshUI() end
end
local tabX={432,562,692,822,994}
local tabW={121,121,121,163,116}
for i,name in ipairs(tabNames) do
    tabs[i]=button(header,name,tabX[i],15,tabW[i],42,function()setTab(i)end,i==1)
end
button(header,"×",1177,17,45,38,function()root:Hide()end,false)

local left=frame(root,12,97,258,608,"panel-body")
local middle=frame(root,281,97,697,608,"panel-body")
local right=frame(root,989,97,269,608,"panel-body")
heading(left,"진행 현황")
heading(middle,"목표 장비 관리")
heading(right,"전리품 목록")

local summaryTitle=text(left,"현재 전문화","GameFontHighlightSmall")
summaryTitle:SetPoint("TOPLEFT",14,-48)
summaryTitle:SetTextColor(.67,.66,.74)
local specLabel=text(left,"","GameFontNormal")
specLabel:SetPoint("TOPLEFT",14,-70)
specLabel:SetTextColor(.94,.89,1)
local progress=text(left,"","GameFontHighlight")
progress:SetPoint("TOPLEFT",14,-117)
progress:SetWidth(225)
progress:SetJustifyH("LEFT")
progress:SetTextColor(.81,.74,.89)
local progressDetail=text(left,"","GameFontHighlightSmall")
progressDetail:SetPoint("TOPLEFT",14,-143)
progressDetail:SetWidth(228)
progressDetail:SetJustifyH("LEFT")
progressDetail:SetTextColor(.61,.79,.77)
local divider=left:CreateTexture(nil,"ARTWORK")
divider:SetPoint("TOPLEFT",14,-177)
divider:SetSize(228,1)
divider:SetColorTexture(.28,.26,.34,.76)
local missingTitle=text(left,"미확인 목표 아이템","GameFontNormal")
missingTitle:SetPoint("TOPLEFT",14,-195)
missingTitle:SetTextColor(.83,.77,.92)
local missingRows={}
for i=1,10 do
    local row=text(left,"","GameFontHighlightSmall")
    row:SetPoint("TOPLEFT",17,-226-(i-1)*28)
    row:SetWidth(221)
    row:SetJustifyH("LEFT")
    row:SetTextColor(.76,.71,.85)
    missingRows[i]=row
end

-- Input and registration controls remain fully independent of the screenshot.
local specLine=text(middle,"","GameFontNormal")
specLine:SetPoint("TOPLEFT",14,-47)
specLine:SetTextColor(.90,.82,.97)
local input=CreateFrame("EditBox","ArangPlannerItemEntry",middle,"BackdropTemplate")
input:SetSize(305,31)
input:SetPoint("TOPLEFT",14,-75)
input:SetFrameLevel(middle:GetFrameLevel()+8)
input:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
input:SetBackdropColor(.045,.045,.07,1)
input:SetBackdropBorderColor(.37,.34,.45,1)
input:SetTextInsets(8,8,0,0)
input:SetFontObject("ChatFontNormal")
input:SetTextColor(1,.94,1,1)
input:SetAutoFocus(false)
input:SetMaxLetters(1024)
input:EnableMouse(true)
input:EnableKeyboard(true)
input:SetScript("OnMouseDown",function(self)self:SetFocus()end)
input:SetScript("OnEditFocusGained",function(self)self:SetBackdropBorderColor(.71,.53,.83,1)end)
input:SetScript("OnEditFocusLost",function(self)self:SetBackdropBorderColor(.37,.34,.45,1)end)

local function notify(message)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cffb78cce아랑플래너|r "..message)
    end
end
local function add()
    local raw=input:GetText()
    if AP.AddTarget(raw) then
        input:SetText("")
        notify("목표 아이템 등록 완료")
        if AP.RefreshUI then AP.RefreshUI() end
    else
        notify("유효한 아이템 ID 또는 링크를 입력하세요.")
    end
end
button(middle,"등록",331,75,72,31,add,false)
button(middle,"제거",409,75,72,31,function()
    if AP.RemoveTarget(input:GetText()) then
        notify("목표 아이템 제거 완료")
        input:SetText("")
        if AP.RefreshUI then AP.RefreshUI() end
    else notify("제거할 아이템 ID 또는 링크를 입력하세요.") end
end,false)
button(middle,"새로고침",487,75,94,31,function()
    AP.ScanEquipped()
    if AP.RefreshUI then AP.RefreshUI() end
end,false)
input:SetScript("OnEnterPressed",function(self)add();self:ClearFocus()end)
input:SetScript("OnEscapePressed",function(self)self:ClearFocus()end)
if type(ChatEdit_InsertLink)=="function" then
    hooksecurefunc("ChatEdit_InsertLink",function(link)
        if not root:IsShown() or currentTab~=1 or not IsShiftKeyDown() or type(link)~="string" then return end
        if AP.GetItemIDFromText(link) then
            input:SetText(link)
            input:SetFocus()
        end
    end)
end
local hint=text(middle,"아이템 ID 직접 입력 · 가방 아이템 Shift+클릭","GameFontHighlightSmall")
hint:SetPoint("TOPLEFT",16,-115)
hint:SetTextColor(.64,.62,.70)

local headRow=frame(middle,10,137,678,29,"panel-header")
for _,v in ipairs({{"목표 아이템",39},{"아이템 ID",474},{"상태",575}}) do
    local t=text(headRow,v[1],"GameFontNormalSmall")
    t:SetPoint("LEFT",v[2],0)
end

local viewRows={}
for i=1,12 do
    local itemFrame=CreateFrame("Button",nil,middle,"BackdropTemplate")
    itemFrame:SetSize(678,31)
    itemFrame:SetPoint("TOPLEFT",middle,"TOPLEFT",10,-171-(i-1)*33)
    itemFrame:SetBackdrop({edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
    itemFrame:SetBackdropBorderColor(.22,.21,.29,.5)
    art(itemFrame,"row","BACKGROUND")
    local hover=art(itemFrame,"row-hover","ARTWORK")
    hover:SetAlpha(0)
    local icon=itemFrame:CreateTexture(nil,"ARTWORK",nil,1)
    icon:SetSize(24,24)
    icon:SetPoint("LEFT",5,0)
    local n=text(itemFrame,"","GameFontHighlightSmall")
    n:SetPoint("LEFT",icon,"RIGHT",8,0)
    n:SetWidth(423)
    n:SetJustifyH("LEFT")
    local id=text(itemFrame,"","GameFontHighlightSmall")
    id:SetPoint("LEFT",472,0)
    id:SetWidth(94)
    id:SetJustifyH("LEFT")
    id:SetTextColor(.70,.68,.77)
    local status=text(itemFrame,"","GameFontHighlightSmall")
    status:SetPoint("LEFT",575,0)
    status:SetWidth(96)
    status:SetJustifyH("LEFT")
    itemFrame:SetScript("OnEnter",function(self)
        hover:SetAlpha(.57)
        if self.itemId then
            GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
            local ok=pcall(GameTooltip.SetHyperlink,GameTooltip,"item:"..self.itemId)
            if ok then GameTooltip:Show() end
        end
    end)
    itemFrame:SetScript("OnLeave",function()
        hover:SetAlpha(0)
        GameTooltip:Hide()
    end)
    itemFrame:SetScript("OnClick",function(self)
        if not self.itemId then return end
        if IsControlKeyDown() then
            AP.RemoveTarget(self.itemId)
            if AP.RefreshUI then AP.RefreshUI() end
        elseif IsShiftKeyDown() then
            input:SetText(tostring(self.itemId))
            input:SetFocus()
        end
    end)
    viewRows[i]={frame=itemFrame,icon=icon,name=n,id=id,status=status}
end

local page=1
local prev=button(middle,"이전",15,580,72,27,function()
    page=math.max(1,page-1)
    if AP.RefreshUI then AP.RefreshUI() end
end,false)
local next=button(middle,"다음",607,580,72,27,function()
    page=page+1
    if AP.RefreshUI then AP.RefreshUI() end
end,false)
local pageLabel=text(middle,"","GameFontHighlightSmall")
pageLabel:SetPoint("BOTTOM",0,15)
pageLabel:SetTextColor(.72,.71,.79)
local placeholder=text(middle,"","GameFontNormalLarge")
placeholder:SetPoint("CENTER",0,40)
placeholder:SetWidth(610)
placeholder:SetJustifyH("CENTER")
placeholder:SetTextColor(.76,.70,.84)
placeholder:Hide()

local rightInfo=text(right,"공격대·쐐기돌 획득 추적","GameFontHighlight")
rightInfo:SetPoint("TOPLEFT",14,-55)
rightInfo:SetTextColor(.88,.81,.95)
local rightNote=text(right,"데이터 연동 준비 중","GameFontHighlightSmall")
rightNote:SetPoint("TOPLEFT",14,-86)
rightNote:SetTextColor(.66,.64,.74)
-- Explicit line frames prevent font ascent differences and automatic wrapping
-- from stacking Korean text on top of adjacent lines in WoW.
local helpLines={
    "현재 버전은 전문화별 목표",
    "등록과 착용/가방 확인을",
    "지원합니다.",
    "",
    "공허핵, 티어 변환, 보스",
    "전리품은 확인되지 않은",
    "수치를 표시하지 않습니다."
}
for i,line in ipairs(helpLines) do
    local fs=text(right,line,"GameFontHighlightSmall")
    fs:SetPoint("TOPLEFT",14,-126-(i-1)*21)
    fs:SetSize(237,18)
    fs:SetJustifyH("LEFT")
    fs:SetJustifyV("MIDDLE")
    fs:SetTextColor(.72,.70,.79)
end

local footer=text(root,"목표 목록: Ctrl+클릭 제거  ·  Shift+클릭 ID 입력  |  획득 상태는 현재 착용/가방 기준","GameFontHighlightSmall")
footer:SetPoint("BOTTOM",root,"BOTTOM",0,6)
footer:SetTextColor(.60,.59,.68)

function AP.RefreshUI()
    if not root:IsShown() then return end
    local ok, spec,total,owned=pcall(AP.Info)
    if not ok then
        specLine:SetText("장비 데이터 오류")
        notify("상태 갱신 오류: "..tostring(spec))
        return
    end
    local okName,specName=pcall(AP.GetSpecName)
    if not okName then specName="알 수 없음" end
    local signature=tostring(spec)..":"..specName
    if root.lastSpec~=signature then
        root.lastSpec=signature
        page=1
    end
    specLabel:SetText(specName.." ("..tostring(spec)..")")
    specLine:SetText("현재 전문화  |  "..specName.." ("..tostring(spec)..")")
    progress:SetText("목표 등록  "..total.."    보유 확인  "..owned)
    progressDetail:SetText("미확인  "..(total-owned).."개  ·  미획득 확정 아님")
    local success,targets=pcall(AP.GetTargetRows)
    if not success then
        notify("목표 테이블 오류: "..tostring(targets))
        return
    end
    for i=1,#missingRows do missingRows[i]:SetText("") end
    local m=1
    for _,v in ipairs(targets) do
        if v.status=="미확인" and m<=#missingRows then
            missingRows[m]:SetText("• "..(v.name or ("아이템 "..v.id)))
            m=m+1
        end
    end
    local showTable=currentTab==1
    input:SetShown(showTable)
    hint:SetShown(showTable)
    headRow:SetShown(showTable)
    prev:SetShown(showTable)
    next:SetShown(showTable)
    pageLabel:SetShown(showTable)
    -- All actual controls in the tab remain clickable, not image-only mockups.
    if showTable then
        placeholder:Hide()
        local pageCount=math.max(1,math.ceil(#targets/#viewRows))
        page=math.min(page,pageCount)
        for i,r in ipairs(viewRows) do
            local item=targets[(page-1)*#viewRows+i]
            r.frame.itemId=item and item.id or nil
            if item then
                r.frame:Show()
                r.icon:SetTexture(item.icon or 134400)
                r.name:SetText(item.link or item.name or tostring(item.id))
                r.id:SetText(tostring(item.id))
                r.status:SetText(item.status)
                if item.status=="착용" then r.status:SetTextColor(.42,.89,.69)
                elseif item.status=="가방 보유" then r.status:SetTextColor(.55,.80,.91)
                else r.status:SetTextColor(.90,.66,.75) end
            else r.frame:Hide() end
        end
        prev:SetEnabled(page>1)
        next:SetEnabled(page<pageCount)
        pageLabel:SetText(page.." / "..pageCount.." 페이지")
    else
        for _,r in ipairs(viewRows) do r.frame:Hide() end
        placeholder:Show()
        placeholder:SetText(tabNames[currentTab].."\n\n독립 구현 예정 기능입니다.\n실제 확인되지 않은 획득 정보는 표시하지 않습니다.")
    end
end
function AP.ToggleUI()
    if root:IsShown() then root:Hide()
    else root:Show();AP.RefreshUI() end
end
root:Hide()

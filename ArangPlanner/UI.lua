-- ArangPlanner independent target table UI (v1.1 alpha).
-- Uses Blizzard game API only. No GearPlanner source or third-party art.
local AP = _G.ArangPlanner
local root = CreateFrame("Frame", "ArangPlannerWindow", UIParent, "BackdropTemplate")
root:SetSize(720, 625)
root:SetPoint("CENTER")
root:SetFrameStrata("DIALOG")
root:SetClampedToScreen(true)
root:SetMovable(true)
root:EnableMouse(true)
root:RegisterForDrag("LeftButton")
root:SetScript("OnDragStart", root.StartMoving)
root:SetScript("OnDragStop", root.StopMovingOrSizing)
root:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
root:SetBackdropColor(.045,.035,.09,.98)
root:SetBackdropBorderColor(.49,.32,.68,1)

local header=CreateFrame("Frame",nil,root,"BackdropTemplate")
header:SetPoint("TOPLEFT",1,-1)
header:SetPoint("TOPRIGHT",-1,-1)
header:SetHeight(65)
header:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8"})
header:SetBackdropColor(.16,.09,.27,.93)
local title=header:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
title:SetPoint("TOPLEFT",19,-13)
title:SetText("|cffdbb8ff아랑플래너|r  |cffaaaaaa1.1 알파|r")
local subtitle=header:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
subtitle:SetPoint("TOPLEFT",20,-38)
subtitle:SetText("독립 구현 · 전문화별 장비 목표 테이블")
subtitle:SetTextColor(.71,.65,.80)
local close=CreateFrame("Button",nil,root,"UIPanelCloseButton")
close:SetPoint("TOPRIGHT",-2,-2)
close:SetScript("OnClick",function()root:Hide()end)

local function label(parent,text,size,x,y,color)
    local fs=parent:CreateFontString(nil,"OVERLAY",size or "GameFontHighlight")
    fs:SetPoint("TOPLEFT",x,y)
    fs:SetText(text)
    if color then fs:SetTextColor(unpack(color)) end
    return fs
end

local info=label(root,"", "GameFontNormal",19,-82)
local summary=label(root,"", "GameFontHighlightSmall",19,-104,{.77,.72,.84})

local entry=CreateFrame("EditBox",nil,root,"InputBoxTemplate")
entry:SetSize(190,27)
entry:SetPoint("TOPLEFT",28,-137)
entry:SetAutoFocus(false)
entry:SetMaxLetters(200)
entry:SetText("")
local hint=label(root,"아이템 ID 또는 아이템 링크 붙여넣기","GameFontHighlightSmall",29,-169,{.60,.57,.69})

local function actionButton(text,x,width,callback)
    local b=CreateFrame("Button",nil,root,"UIPanelButtonTemplate")
    b:SetSize(width,25)
    b:SetPoint("TOPLEFT",x,-137)
    b:SetText(text)
    b:SetScript("OnClick",callback)
    return b
end
local function refresh() if AP.RefreshUI then AP.RefreshUI() end end
local function insertTarget()
    if AP.AddTarget(entry:GetText()) then
        entry:SetText("")
        refresh()
    else
        UIErrorsFrame:AddMessage("아이템 ID 또는 링크를 입력하세요.",1,.35,.45)
    end
end
actionButton("등록",237,80,insertTarget)
actionButton("제거",325,80,function()
    if AP.RemoveTarget(entry:GetText()) then entry:SetText("");refresh()
    else UIErrorsFrame:AddMessage("제거할 아이템 ID 또는 링크를 입력하세요.",1,.35,.45) end
end)
actionButton("새로고침",413,100,function()AP.ScanEquipped();refresh()end)
entry:SetScript("OnEnterPressed",function(self)insertTarget();self:ClearFocus()end)
entry:SetScript("OnEscapePressed",function(self)self:ClearFocus()end)

local tableHeader=CreateFrame("Frame",nil,root,"BackdropTemplate")
tableHeader:SetPoint("TOPLEFT",18,-194)
tableHeader:SetSize(683,27)
tableHeader:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8"})
tableHeader:SetBackdropColor(.23,.14,.36,.96)
label(tableHeader,"목표 아이템","GameFontNormalSmall",39,-8)
label(tableHeader,"아이템 ID","GameFontNormalSmall",455,-8)
label(tableHeader,"보유 확인","GameFontNormalSmall",548,-8)

local viewRows={}
for i=1,12 do
    local b=CreateFrame("Button",nil,root,"BackdropTemplate")
    b:SetSize(683,28)
    b:SetPoint("TOPLEFT",18,-225-(i-1)*30)
    b:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
    b:SetBackdropColor(.105,.083,.17,i%2==0 and .73 or .93)
    b:SetBackdropBorderColor(.26,.20,.35,.60)
    local icon=b:CreateTexture(nil,"ARTWORK")
    icon:SetSize(23,23);icon:SetPoint("LEFT",5,0)
    local itemName=b:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    itemName:SetPoint("LEFT",icon,"RIGHT",10,0)
    itemName:SetWidth(405);itemName:SetJustifyH("LEFT")
    local idText=b:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    idText:SetPoint("LEFT",454,0);idText:SetWidth(92);idText:SetJustifyH("LEFT")
    local status=b:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    status:SetPoint("LEFT",547,0);status:SetWidth(128);status:SetJustifyH("LEFT")
    b:SetScript("OnEnter",function(self)
        self:SetBackdropBorderColor(.73,.50,1,.95)
        if self.itemID then
            GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
            GameTooltip:SetItemByID(self.itemID)
            GameTooltip:Show()
        end
    end)
    b:SetScript("OnLeave",function(self)
        self:SetBackdropBorderColor(.26,.20,.35,.60)
        GameTooltip:Hide()
    end)
    b:SetScript("OnClick",function(self,button)
        if self.itemID then
            if IsShiftKeyDown() then
                entry:SetText(tostring(self.itemID))
                entry:SetFocus()
            elseif IsControlKeyDown() then
                AP.RemoveTarget(self.itemID)
                refresh()
            end
        end
    end)
    viewRows[i]={button=b,icon=icon,name=itemName,id=idText,status=status}
end

local page=1
local previous=CreateFrame("Button",nil,root,"UIPanelButtonTemplate")
previous:SetSize(68,24);previous:SetPoint("BOTTOMLEFT",19,24);previous:SetText("이전")
local nextButton=CreateFrame("Button",nil,root,"UIPanelButtonTemplate")
nextButton:SetSize(68,24);nextButton:SetPoint("BOTTOMRIGHT",-18,24);nextButton:SetText("다음")
local pageInfo=root:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
pageInfo:SetPoint("BOTTOM",0,31)
local footer=label(root,"Shift+클릭: ID 입력   |   Ctrl+클릭: 목표 제거   |   상태는 현재 착용/가방 기준","GameFontHighlightSmall",93,-593,{.60,.58,.70})
footer:SetWidth(550)

function AP.RefreshUI()
    if not root:IsShown() then return end
    local spec,total,owned=AP.Info()
    local displayName=AP.GetSpecName()
    local key=spec..":"..displayName
    if root.lastSpec ~= key then
        page=1
        root.lastSpec=key
    end
    info:SetText("현재 전문화: "..displayName.." ("..spec..")")
    summary:SetText("등록 "..total.."개  |  착용 또는 가방 확인 "..owned.."개  |  미확인 "..(total-owned).."개")
    local targets=AP.GetTargetRows()
    local pageMax=math.max(1,math.ceil(#targets/#viewRows))
    if page>pageMax then page=pageMax end
    for i,row in ipairs(viewRows) do
        local item=targets[(page-1)*#viewRows+i]
        row.button.itemID=item and item.id or nil
        if item then
            row.button:Show()
            row.icon:SetTexture(item.icon)
            row.name:SetText(item.link or item.name)
            row.id:SetText(tostring(item.id))
            row.status:SetText(item.status)
            if item.status=="착용" then row.status:SetTextColor(.31,1,.67)
            elseif item.status=="가방 보유" then row.status:SetTextColor(.60,.92,1)
            else row.status:SetTextColor(.95,.66,.68) end
        else
            row.button:Hide()
        end
    end
    previous:SetEnabled(page>1)
    nextButton:SetEnabled(page<pageMax)
    pageInfo:SetText(page.." / "..pageMax.." 페이지")
end
previous:SetScript("OnClick",function()page=math.max(1,page-1);refresh()end)
nextButton:SetScript("OnClick",function()page=page+1;refresh()end)

function AP.ToggleUI()
    if root:IsShown() then root:Hide()
    else root:Show();AP.RefreshUI() end
end
root:Hide()

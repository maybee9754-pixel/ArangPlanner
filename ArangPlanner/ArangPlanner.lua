-- ArangPlanner v0.6.0-demo | visual refinement
-- This is a standalone visual demo. It does not import/alter GearPlanner saves.
local layout = ArangPlannerStudioLayout
if type(layout) ~= "table" or type(layout.panels) ~= "table" then return end
local W, H = layout.width or 1440, layout.height or 810
local function clamp(x,a,b) return math.max(a, math.min(b,x)) end
local function hex(v)
  if type(v)~="string" or not v:match("^#%x%x%x%x%x%x$") then return .45,.30,.67 end
  return tonumber(v:sub(2,3),16)/255,tonumber(v:sub(4,5),16)/255,tonumber(v:sub(6,7),16)/255
end
local FONT = "Fonts\\2002.TTF"
local function font(parent, text, size, color, align)
  local t=parent:CreateFontString(nil,"OVERLAY")
  t:SetFont(FONT,size or 12,"OUTLINE")
  t:SetJustifyH(align or "LEFT")
  t:SetTextColor(unpack(color or {0.94,0.90,1}))
  t:SetText(text or "")
  return t
end
local function fill(frame,color,alpha,layer)
  local tex=frame:CreateTexture(nil,layer or "BACKGROUND")
  tex:SetAllPoints()
  tex:SetColorTexture(unpack({hex(color)}))
  tex:SetAlpha(alpha or 1)
  return tex
end
local function backdrop(frame,color,edge,alpha)
  frame:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
  local r,g,b=hex(color); frame:SetBackdropColor(r,g,b,alpha or 1)
  r,g,b=hex(edge);frame:SetBackdropBorderColor(r,g,b,.90)
end
local function strip(parent, y, height, color, alpha)
  local t=parent:CreateTexture(nil,"ARTWORK")
  t:SetPoint("TOPLEFT",0,y)
  t:SetPoint("TOPRIGHT",0,y)
  t:SetHeight(height)
  local r,g,b=hex(color); t:SetColorTexture(r,g,b,alpha or 1)
  return t
end
local function borderGlow(f, color)
  local r,g,b=hex(color)
  -- 4 soft exterior edges. Kept behind content and within parent frames.
  local function edge(point1, point2, w,h)
    local t=f:CreateTexture(nil,"BACKGROUND",nil,1)
    t:SetPoint(point1,f,point1)
    t:SetPoint(point2,f,point2)
    if w then t:SetWidth(w) end
    if h then t:SetHeight(h) end
    t:SetColorTexture(r,g,b,.11)
  end
  edge("TOPLEFT","TOPRIGHT",nil,4)
  edge("BOTTOMLEFT","BOTTOMRIGHT",nil,3)
end
local root=CreateFrame("Frame","ArangPlannerStudioBridge",UIParent,"BackdropTemplate")
root:SetSize(W,H)
root:SetPoint("CENTER")
root:SetFrameStrata("HIGH")
root:SetClampedToScreen(true)
backdrop(root,"#0d0a19","#604580",.985)
borderGlow(root,"#a67df4")
root:Hide()
local panels={}
local function makePanel(id)
  local p=layout.panels[id]
  local f=CreateFrame("Frame",nil,root,"BackdropTemplate")
  f:SetPoint("TOPLEFT",root,"TOPLEFT",p.x,-p.y)
  f:SetSize(p.w,p.h)
  backdrop(f,"#131021",p.border,clamp((p.opacity or 100)/100,.4,1))
  borderGlow(f,"#b17aee")
  panels[id]=f
  if id ~= "header" then
    local h=CreateFrame("Frame",nil,f,"BackdropTemplate")
    h:SetPoint("TOPLEFT",1,-1)
    h:SetPoint("TOPRIGHT",-1,-1)
    h:SetHeight(39)
    backdrop(h,"#27183e","#5d3d86",.95)
    strip(h,-1,3,"#7046a0",.75)
    local mark=h:CreateTexture(nil,"ARTWORK")
    mark:SetSize(10,10);mark:SetPoint("LEFT",14,0)
    mark:SetColorTexture(.83,.61,1,1)
    mark:SetRotation(math.pi/4)
    local title=font(h,p.label,15,{.97,.92,1})
    title:SetPoint("LEFT",32,0)
    f.header=h
  end
  return f
end
for _,id in ipairs({"header","farming","compare","missing","equipment","loot"}) do makePanel(id) end
local head=panels.header
do
  backdrop(head,"#20162e","#7650a3",1)
  local logo=CreateFrame("Frame",nil,head,"BackdropTemplate")
  logo:SetSize(42,42);logo:SetPoint("LEFT",18,0)
  backdrop(logo,"#3c2662","#ad80df",1)
  local diamond=logo:CreateTexture(nil,"ARTWORK")
  diamond:SetSize(15,15);diamond:SetPoint("CENTER");diamond:SetColorTexture(.93,.73,1,1)
  diamond:SetRotation(math.pi/4)
  local name=font(head,"아랑플래너",23,{1,.92,1})
  name:SetPoint("TOPLEFT",76,-15)
  local subtitle=font(head,"ARANG PLANNER  |  STUDIO BRIDGE v0.6",9,{.72,.63,.83})
  subtitle:SetPoint("TOPLEFT",76,-47)
  local tabs={{"장비 세팅",true},{"파밍 계획",false},{"드랍 정보",false}}
  for i,entry in ipairs(tabs) do
    local b=CreateFrame("Button",nil,head,"BackdropTemplate")
    b:SetSize(104,40);b:SetPoint("RIGHT",head,"RIGHT",-55-(3-i)*113,0)
    backdrop(b,entry[2] and "#59338b" or "#221731",entry[2] and "#ad7bef" or "#55416f",1)
    local text=font(b,entry[1],12)
    text:SetPoint("CENTER")
    if entry[2] then strip(b,0,3,"#a86cff",.95) end
    b:SetScript("OnEnter",function()b:SetBackdropColor(.40,.25,.59,1)end)
    b:SetScript("OnLeave",function()local r,g,bl=hex(entry[2] and "#59338b" or "#221731");b:SetBackdropColor(r,g,bl,1)end)
  end
  local close=CreateFrame("Button",nil,head,"UIPanelCloseButton")
  close:SetSize(32,32);close:SetPoint("RIGHT",-6,0)
  close:SetScript("OnClick",function()root:Hide()end)
end
local farm=panels.farming
do
  local ring=CreateFrame("Frame",nil,farm)
  ring:SetSize(134,134);ring:SetPoint("TOPLEFT",11,-65)
  local cx,cy=67,67
  local radians=math.pi*2
  for i=1,72 do
    local angle=-(i-1)/72*radians-math.pi/2
    local radius=54
    local x,y=math.cos(angle)*radius,math.sin(angle)*radius
    local tick=ring:CreateTexture(nil,"ARTWORK")
    tick:SetSize(8,14)
    tick:SetPoint("CENTER",ring,"CENTER",x,y)
    tick:SetRotation(-angle)
    tick:SetColorTexture(i<=52 and .63 or .20,i<=52 and .36 or .14,i<=52 and 1 or .30,.95)
  end
  local dark=ring:CreateTexture(nil,"ARTWORK")
  dark:SetSize(91,91);dark:SetPoint("CENTER")
  dark:SetColorTexture(.07,.05,.14,.95)
  local cap=font(ring,"달성률",11,{.83,.75,.90},"CENTER")
  cap:SetPoint("CENTER",0,15)
  local number=font(ring,"72%",28,{.88,.77,1},"CENTER")
  number:SetPoint("CENTER",0,-11)
  local rows={{"등록","25",{.94,.89,1}},{"보유","18",{.45,.93,.72}},{"미보유","7",{1,.53,.71}}}
  for i,row in ipairs(rows) do
    local y=-83-(i-1)*42
    local a=font(farm,row[1],13,row[3]);a:SetPoint("TOPLEFT",175,y)
    local b=font(farm,row[2],16,row[3],"RIGHT");b:SetPoint("TOPRIGHT",-19,y)
  end
  local note=font(farm,"파밍 수치는 예시 데이터",10,{.62,.57,.70})
  note:SetPoint("BOTTOMLEFT",17,12)
end
local compare=panels.compare
do
  local rows={{"능력치","현재","목표"},{"지능","54,781","56,812"},{"치명타","32.4%","34.1%"},{"가속","27.1%","25.8%"},{"특화","41.8%","43.6%"},{"유연성","9.6%","9.2%"}}
  for i,row in ipairs(rows) do
    local y=-52-(i-1)*36
    if i>1 and i%2==0 then
      local bg=compare:CreateTexture(nil,"BACKGROUND")
      bg:SetPoint("TOPLEFT",9,y+4);bg:SetPoint("TOPRIGHT",-9,y+4);bg:SetHeight(34)
      bg:SetColorTexture(.19,.13,.28,.42)
    end
    for j,v in ipairs(row) do
      local color=i==1 and {.68,.60,.79} or (j==3 and {.48,.94,.73} or {.94,.9,1})
      local t=font(compare,v,i==1 and 10 or 12,color,j==1 and "LEFT" or "RIGHT")
      t:SetWidth(j==1 and 95 or 88)
      t:SetPoint("TOPLEFT",13+(j-1)*98,y)
    end
  end
  local note=font(compare,"비교 수치는 예시 데이터",10,{.61,.56,.70});note:SetPoint("BOTTOMLEFT",15,10)
end
local missing=panels.missing
do
  local value=font(missing,"7",40,{.75,.53,1});value:SetPoint("TOPLEFT",20,-55)
  local whole=font(missing,"/ 25",24,{.67,.60,.77});whole:SetPoint("BOTTOMLEFT",value,"BOTTOMRIGHT",5,5)
  local sub=font(missing,"목표 장비 중 미보유 · 예시",11,{.72,.64,.82});sub:SetPoint("BOTTOMLEFT",20,15)
end
local slots={}
local equipment=panels.equipment
local function gearRow(parent, name, slotId, x, y, width)
  local b=CreateFrame("Button",nil,parent,"BackdropTemplate")
  b:SetSize(width,57);b:SetPoint("TOPLEFT",x,y)
  backdrop(b,"#211731","#6f5292",.96)
  local stripTex=b:CreateTexture(nil,"BACKGROUND")
  stripTex:SetWidth(3);stripTex:SetPoint("TOPLEFT",2,-3);stripTex:SetPoint("BOTTOMLEFT",2,3)
  stripTex:SetColorTexture(.54,.34,.84,.75)
  local icon=b:CreateTexture(nil,"ARTWORK")
  icon:SetSize(42,42);icon:SetPoint("LEFT",8,0)
  icon:SetTexture(134400)
  local outline=CreateFrame("Frame",nil,b,"BackdropTemplate")
  outline:SetSize(44,44);outline:SetPoint("CENTER",icon,"CENTER")
  outline:SetFrameLevel(b:GetFrameLevel()+2)
  backdrop(outline,"#08060c","#ac8549",0)
  local text=font(b,name,12);text:SetPoint("TOPLEFT",60,-9)
  local detail=font(b,"미착용",10,{.69,.62,.79})
  detail:SetPoint("TOPLEFT",60,-31)
  detail:SetWidth(width-66)
  local arrow=font(b,"✓",13,{.46,.89,.65})
  arrow:SetPoint("RIGHT",-9,1)
  b:SetScript("OnEnter",function(self)
    self:SetBackdropBorderColor(.80,.58,1,1)
    local link=GetInventoryItemLink("player",slotId)
    if link then GameTooltip:SetOwner(self,"ANCHOR_RIGHT");GameTooltip:SetHyperlink(link);GameTooltip:Show()end
  end)
  b:SetScript("OnLeave",function(self)
    local r,g,z=hex("#6f5292");self:SetBackdropBorderColor(r,g,z,1)
    GameTooltip:Hide()
  end)
  slots[#slots+1]={frame=b,icon=icon,detail=detail,arrow=arrow,id=slotId}
  return b
end
local model
do
  local note=font(equipment,"비전 마법사   |   착용 장비",12,{.77,.65,.89})
  note:SetPoint("TOPLEFT",23,-54)
  local stage=CreateFrame("Frame",nil,equipment)
  stage:SetSize(305,355);stage:SetPoint("CENTER",0,9)
  local ring1=stage:CreateTexture(nil,"BACKGROUND")
  ring1:SetSize(292,292);ring1:SetPoint("CENTER")
  ring1:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-BACKGROUND")
  ring1:SetAlpha(.12)
  for n=1,48 do
    local a=n/48*math.pi*2
    local x,y=math.cos(a)*133,math.sin(a)*133
    local t=stage:CreateTexture(nil,"ARTWORK")
    t:SetSize(4,10);t:SetPoint("CENTER",stage,"CENTER",x,y)
    t:SetRotation(-a)
    t:SetColorTexture(.56,.39,.92,n%4==0 and .65 or .24)
  end
  for _,radius in ipairs({112,119}) do
    for n=1,96 do
      local a=n/96*math.pi*2
      local t=stage:CreateTexture(nil,"ARTWORK")
      t:SetSize(2,3)
      t:SetPoint("CENTER",stage,"CENTER",math.cos(a)*radius,math.sin(a)*radius)
      t:SetColorTexture(.57,.39,.88,.33)
    end
  end
  model=CreateFrame("PlayerModel",nil,equipment)
  model:SetSize(250,385);model:SetPoint("CENTER",0,2)
  model:SetFrameLevel(equipment:GetFrameLevel()+2)
  local l={{"머리",1},{"어깨",3},{"가슴",5},{"손목",9},{"망토",15},{"무기",16}}
  local r={{"손",10},{"허리",6},{"다리",7},{"발",8},{"반지 1",11},{"반지 2",12}}
  for i,s in ipairs(l) do gearRow(equipment,s[1],s[2],14,-90-(i-1)*66,229)end
  for i,s in ipairs(r) do gearRow(equipment,s[1],s[2],equipment:GetWidth()-243,-90-(i-1)*66,229)end
  gearRow(equipment,"장신구 1",13,136,-equipment:GetHeight()+78,220)
  gearRow(equipment,"장신구 2",14,374,-equipment:GetHeight()+78,220)
  for _,s in ipairs(slots)do s.frame:SetFrameLevel(equipment:GetFrameLevel()+4)end
  local foot=font(equipment,"실착용 아이콘 · 파밍 추적은 아직 연결되지 않음",10,{.76,.66,.87},"CENTER")
  foot:SetPoint("BOTTOM",0,6)
end
local loot=panels.loot
do
  local tabs={{"전리품 목록",true},{"등록 장비",false},{"추천 장비",false}}
  for i,v in ipairs(tabs) do
    local b=CreateFrame("Frame",nil,loot,"BackdropTemplate")
    b:SetSize(i==1 and 111 or 92,34);b:SetPoint("TOPLEFT",12+(i-1)*104,-53)
    backdrop(b,v[2] and "#57358d" or "#21182d",v[2] and "#9e75d7" or "#4e3a69",1)
    local text=font(b,v[1],10);text:SetPoint("CENTER")
  end
  local selector=CreateFrame("Frame",nil,loot,"BackdropTemplate")
  selector:SetPoint("TOPLEFT",13,-94);selector:SetSize(loot:GetWidth()-26,37)
  backdrop(selector,"#1c162b","#5d4780",.94)
  local place=font(selector,"공격대 (신화)     |     똬리의 제단",11,{.85,.77,.93})
  place:SetPoint("CENTER")
  local warning=font(loot,"공격대 보스  ·  예시 데이터",12,{.96,.73,.49})
  warning:SetPoint("TOPLEFT",14,-147)
  local names={"네크잘리","매장된 파수꾼","길 잃은 탐험가","바쉬니크","스조라크","쌍둥이 송곳니","줄잔","울라텍","키식스"}
  for i,v in ipairs(names) do
    local row=CreateFrame("Frame",nil,loot,"BackdropTemplate")
    row:SetSize(loot:GetWidth()-24,44);row:SetPoint("TOPLEFT",12,-179-(i-1)*49)
    backdrop(row,i==1 and "#2b1a40" or "#1c152a",i==1 and "#8c5db5" or "#5b4575",.98)
    local n=font(row,i..". "..v,12)
    n:SetPoint("LEFT",12,0)
    local count=font(row,i==1 and "5 / 7" or "0 / 6",11,{.78,.67,.90},"RIGHT")
    count:SetPoint("RIGHT",-12,0)
  end
end
local function updateGear()
  for _,s in ipairs(slots) do
    local icon=GetInventoryItemTexture("player",s.id)
    s.icon:SetTexture(icon or 134400)
    local link=GetInventoryItemLink("player",s.id)
    s.detail:SetText(link and "착용 중 · 마우스오버" or "미착용")
    s.arrow:SetShown(link~=nil)
  end
end
root:SetScript("OnShow",function()
  updateGear()
  if UnitExists("player") and model then pcall(function()model:SetUnit("player")end)end
end)
local events=CreateFrame("Frame")
events:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("UI_SCALE_CHANGED")
local function scaleWindow()
  local w,h=UIParent:GetWidth(),UIParent:GetHeight()
  root:SetScale(clamp(math.min((w-44)/W,(h-44)/H),.35,1))
end
events:SetScript("OnEvent",function(_,event)
  if event=="UI_SCALE_CHANGED" then scaleWindow()
  elseif root:IsShown() then updateGear()end
end)
scaleWindow()
SLASH_ARANGPLANNER1="/arang"
SLASH_ARANGPLANNER2="/아랑"
SlashCmdList.ARANGPLANNER=function(arg)
  if arg=="hide" then root:Hide()
  elseif arg=="" or arg=="show" or arg=="open" then
    if root:IsShown() then root:Hide() else root:Show()end
  else print("|cffbd91ef아랑플래너 v0.6 데모|r: /arang, /arang show, /arang hide") end
end
print("|cffbd91ef아랑플래너|r UI 데모 v0.6.0 (실제 공허핵 스캔 기능 없음). /arang 로 표시")

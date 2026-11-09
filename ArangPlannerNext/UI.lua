-- A deliberately small independent UI, not the original GearPlanner user interface.
local AP = _G.ArangPlannerNext
local root = CreateFrame("Frame", "ArangPlannerNextWindow", UIParent, "BackdropTemplate")
root:SetSize(480,555)
root:SetPoint("CENTER")
root:SetFrameStrata("DIALOG")
root:SetClampedToScreen(true)
root:SetMovable(true)
root:EnableMouse(true)
root:RegisterForDrag("LeftButton")
root:SetScript("OnDragStart", root.StartMoving)
root:SetScript("OnDragStop", root.StopMovingOrSizing)
root:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
root:SetBackdropColor(.06,.05,.12,.97)
root:SetBackdropBorderColor(.52,.35,.72,1)

local title=root:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
title:SetPoint("TOPLEFT",20,-18)
title:SetText("아랑플래너 Next | 독립 개발 시험판")
local subtitle=root:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
subtitle:SetPoint("TOPLEFT",20,-43)
subtitle:SetText("별도 저장소 사용 · 기존 GearPlanner와 무관")
subtitle:SetTextColor(.65,.59,.74)
local close=CreateFrame("Button",nil,root,"UIPanelCloseButton")
close:SetPoint("TOPRIGHT",0,0)
close:SetScript("OnClick",function()root:Hide()end)

local info=root:CreateFontString(nil,"OVERLAY","GameFontNormal")
info:SetPoint("TOPLEFT",20,-75)
info:SetWidth(440)
info:SetJustifyH("LEFT")

local rows={}
for i=1,16 do
    local panel=CreateFrame("Frame",nil,root,"BackdropTemplate")
    panel:SetSize(437,25)
    panel:SetPoint("TOPLEFT",20,-112-(i-1)*26)
    panel:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8"})
    panel:SetBackdropColor(.14,.11,.21,i%2==0 and .45 or .64)
    local icon=panel:CreateTexture(nil,"ARTWORK")
    icon:SetPoint("LEFT",3,0)
    icon:SetSize(21,21)
    local label=panel:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    label:SetPoint("LEFT",icon,"RIGHT",10,0)
    label:SetWidth(393)
    label:SetJustifyH("LEFT")
    rows[i]={icon=icon,label=label}
end

local footer=root:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
footer:SetPoint("BOTTOMLEFT",20,19)
footer:SetText("목표 추가: /arangnext add 아이템ID   |   /arangnext scan")
footer:SetTextColor(.67,.62,.77)

function AP.RefreshUI()
    if not root:IsShown() then return end
    local spec,total,equipped=AP.Info()
    info:SetText("전문화 "..spec.."  |  등록 목표 "..total.."  |  현재 착용 "..equipped.."  (스캔은 장착 장비만)")
    local current=AP.GetDisplayRows()
    for i,slot in ipairs(rows) do
        local item=current[i]
        if item then
            slot.icon:SetTexture(item.icon or 134400)
            slot.label:SetText("슬롯 "..item.slot.."  |  "..(item.link or "미착용"))
        else
            slot.icon:SetTexture(nil)
            slot.label:SetText("")
        end
    end
end

function AP.ToggleUI()
    if root:IsShown() then root:Hide()
    else root:Show();AP.RefreshUI() end
end
root:Hide()

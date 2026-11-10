-- Optional live-panel bridge: renders the user's installed GearPlanner UI.
-- Does not bundle/copy any GearPlanner code, data, or graphics.
local AP=_G.ArangPlanner
local B={}

local function originalPanel()
    if not LibStub then return end
    local ace=LibStub("AceAddon-3.0",true)
    if not ace or not ace.GetAddon then return end
    local ok,gp=pcall(ace.GetAddon,ace,"GearPlanner",true)
    if not ok or not gp then return end
    if not gp.MainFrame and type(gp.CreateMainFrame)=="function" then
        if not pcall(gp.CreateMainFrame,gp) then return end
    end
    local root=gp.RootContainer
    local w=root and root.children and root.children[2]
    local index=gp.GetModule and gp:GetModule("Index",true)
    if not w or not w.frame or not index or not index.widgets then return end
    return gp,w,index
end

local function mirror(gp,message,slot)
    slot=tonumber(slot)
    if not slot then return end
    if message=="GP_ITEM_UNREGISTERED" then
        if AP.ClearSlotTarget then AP.ClearSlotTarget(slot) end
    elseif message=="GP_ITEM_REGISTERED" then
        local reg=gp.RegisteredItems and gp.RegisteredItems[slot]
        if not reg or not reg.itemID then return end
        local ok=AP.AssignSlotTarget(slot,reg.itemID)
        if ok then
            local current=AP.GetSlotOptions(slot)
            local grade=reg.grade
            local names={explorer="탐험가",adventurer="모험가",
                veteran="노련가",champion="용사",hero="영웅",myth="신화"}
            if type(grade)=="string" then
                grade=names[grade:lower()] or grade
            end
            local allowed={["탐험가"]=true,["모험가"]=true,["노련가"]=true,
                ["용사"]=true,["영웅"]=true,["신화"]=true}
            AP.SetSlotOptions(slot,{track=allowed[grade] and grade or current.track,
                rank=tonumber(reg.level) or current.rank,
                venom=reg.venomstone==true,catalyst=reg.catalyst==true})
        end
    else return end
    if AP.RefreshUI then AP.RefreshUI() end
end

function AP.AttachGearPlannerPanel(root,anchor)
    if not root or not root:IsShown() then return false end
    local gp,w=originalPanel()
    if not gp then return false end
    if not B.host then
        B.host=CreateFrame("Frame",nil,root,"BackdropTemplate")
        B.host:SetPoint("TOPLEFT",anchor,"TOPLEFT",0,0)
        B.host:SetPoint("BOTTOMRIGHT",anchor,"BOTTOMRIGHT",0,0)
        B.host:SetFrameLevel(anchor:GetFrameLevel()+80)
        B.host:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8"})
        B.host:SetBackdropColor(.03,.025,.035,1)
    end
    if not B.widget then
        B.oldParent=w.frame:GetParent()
        B.points={}
        for i=1,w.frame:GetNumPoints() do
            B.points[#B.points+1]={w.frame:GetPoint(i)}
        end
        B.widget=w
        B.gp=gp
    end
    w.frame:SetParent(B.host)
    w.frame:ClearAllPoints()
    w.frame:SetAllPoints(B.host)
    w.frame:SetFrameLevel(B.host:GetFrameLevel()+1)
    w.frame:Show()
    B.host:Show()
    if gp.MainFrame then gp.MainFrame:Hide() end
    if not B.hooked and type(hooksecurefunc)=="function" then
        B.hooked=true
        hooksecurefunc(gp,"SendMessage",function(_,message,slot)
            if B.host and B.host:IsShown() then mirror(gp,message,slot) end
        end)
    end
    return true
end

function AP.SyncGearPlannerSlot(slot)
    if not B.host or not B.host:IsShown() then return end
    local gp=B.gp
    local index=gp and gp.GetModule and gp:GetModule("Index",true)
    if index and index.OnSlotClicked then
        local name=AP.LootCatalog and AP.LootCatalog.SlotLabel(slot) or "장비"
        pcall(index.OnSlotClicked,index,nil,name,slot)
    end
end

function AP.DetachGearPlannerPanel()
    if not B.widget then return end
    local frame=B.widget.frame
    frame:SetParent(B.oldParent)
    frame:ClearAllPoints()
    for _,point in ipairs(B.points or {}) do frame:SetPoint(unpack(point)) end
    if B.host then B.host:Hide() end
    B.widget=nil
    B.gp=nil
end

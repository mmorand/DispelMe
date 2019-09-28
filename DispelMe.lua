----------------------------------
-- NAMESPACE
----------------------------------
local _, namespace = ...;

local Dm_MainContainer = {}
local Dm_UnitFrames = {}

local BOXESGUTTER = 10
local BOXESHEIGHT = 20
local BOXESPERLINE = 5
local BOXESWIDTH = 50

local CONTAINERTOP = 0

local DM_PLAYER = {
    CLASSNAME = false,
    CANDISPEL = {
        Curse = false,
        Disease = false,
        Magic = false,
        Poison = false
    },
    SPELL1 = false,
    SPELL2 = false,
    PRIORITY1 = false,
    PRIORITY2 = false
}

local SPELLPRIORITY = { 'Curse', 'Magic', 'Poison', 'Disease' }

--[[
@TODO AJOUTER LES ID DES AUTRES SORTS POUR TOUTES LES CLASSES
]]--

local DM_CLASSES = {
    DRUID = {
        CANDISPEL = {
            Curse = true,
            Disease = false,
            Poison = true
        },
        PRIORITY1 = 'Curse',
        PRIORITY2 = 'Poison',
        SPELL1 = 2782,
        SPELL2 = 14253
    },
    PALADIN = {
        PRIORITY1 = 'Magic',
        SPELL1 = 2782,
    },
    MAGE = {
        PRIORITY1 = 'Curse',
        SPELL1 = 2782
    },
    PRIEST = {
        PRIORITY1 = 'Magic',
        PRIORITY2 = 'Disease',
        SPELL1 = 2782,
        SPELL2 = 14253
    },
    SHAMAN = {
        PRIORITY1 = 'Curse',
        PRIORITY2 = 'Poison',
        SPELL1 = 2782,
        SPELL2 = 14253
    }
}
local DM_COLORS = {
    Curse =     { r = 1.00, g = 0.00, b = 1.00 },
    Disease =   { r = 1.00, g = 0.67, b = 0.20 },
    Magic =     { r = 0.86, g = 0.08, b = 0.24 },
    Poison =    { r = 0.50, g = 1.00, b = 0.00 },

    DRUID =     { r = 1.00, g = 0.49, b = 0.04 },
    HUNTER =    { r = 0.67, g = 0.83, b = 0.45 },
    MAGE =      { r = 0.25, g = 0.78, b = 0.92 },
    PALADIN =   { r = 0.96, g = 0.55, b = 0.73 },
    PRIEST =    { r = 1.00, g = 1.00, b = 1.00 },
    ROGUE =     { r = 1.00, g = 0.96, b = 0.41 },
    SHAMAN =    { r = 0.00, g = 0.44, b = 0.87 },
    WARLOCK =   { r = 0.53, g = 0.53, b = 0.93 },
    WARRIOR =   { r = 0.78, g = 0.61, b = 0.43 },
}

function Dm_RoundValue(val, decimal)
    if (decimal) then
        return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
    else
        return math.floor(val+0.5)
    end
end

function Dm_GenerateMainFrame()

    Dm_MainContainer = CreateFrame("Frame", "Dm_MainContainer", UIParent)
    local Dm_ContainerHeight = (40 / BOXESPERLINE) * (BOXESHEIGHT + BOXESGUTTER) + BOXESGUTTER
    local Dm_ContainerWidth = BOXESPERLINE * (BOXESWIDTH + BOXESGUTTER) + BOXESGUTTER
    Dm_MainContainer:SetSize(Dm_ContainerWidth, (Dm_ContainerHeight + CONTAINERTOP))
    Dm_MainContainer:SetPoint("CENTER")

    Dm_MainContainer:SetMovable(true)
    Dm_MainContainer:EnableMouse(true)
    Dm_MainContainer:SetToplevel(true)
    Dm_MainContainer:RegisterForDrag("LeftButton")
    Dm_MainContainer:SetScript("OnDragStart", Dm_MainContainer.StartMoving)
    Dm_MainContainer:SetScript("OnDragStop", Dm_MainContainer.StopMovingOrSizing)
    Dm_MainContainer:SetScript("OnMouseUp", Dm_MainContainer.StopMovingOrSizing)

    Dm_MainContainer.texture = Dm_MainContainer:CreateTexture("Dm_MainContainerTexture", "BACKGROUND")
    Dm_MainContainer.texture:SetAllPoints()
    Dm_MainContainer.texture:SetColorTexture(0, 0, 0, 0.4)
end

function Dm_UpdateButton(target)

    if (UnitExists(target)) then

        Dm_UnitFrames[target].text = Dm_UnitFrames[target]:CreateFontString("Dm_DispelButtonText"..target, "ARTWORK")
        Dm_UnitFrames[target].text:SetFont("Fonts\\ARIALN.ttf", 10, "OUTLINE")
        Dm_UnitFrames[target].text:SetAllPoints()
        Dm_UnitFrames[target].text:SetText(UnitName(target))
        Dm_UnitFrames[target].text:SetWidth(BOXESWIDTH - 5)
        Dm_UnitFrames[target]:SetNormalFontObject("GameFontNormalSmall")
        Dm_UnitFrames[target]:SetAlpha(1)

        local Dm_classNameFr, Dm_className = UnitClass(target)
        local ClassColors = DM_COLORS[Dm_className]
        Dm_UnitFrames[target].texture = Dm_UnitFrames[target]:CreateTexture("Dm_DispelButtonTexture"..target, "BACKGROUND")
        Dm_UnitFrames[target].texture:SetAllPoints()
        Dm_UnitFrames[target].texture:SetColorTexture(ClassColors.r, ClassColors.g, ClassColors.b, 1)
    end
end

function Dm_GenerateButton(target, unitId)

    Dm_UnitFrames[target] = CreateFrame("Button", "Dm_DispelButton"..target, Dm_MainContainer, "SecureActionButtonTemplate")
    if (DM_PLAYER.SPELL1) then
        Dm_UnitFrames[target]:SetAttribute("type1", "spell")
        Dm_UnitFrames[target]:SetAttribute("spell", DM_PLAYER.SPELL1)
        Dm_UnitFrames[target]:SetAttribute("target", target)
    end
    if (DM_PLAYER.SPELL2) then
        Dm_UnitFrames[target]:SetAttribute("type2", "spell")
        Dm_UnitFrames[target]:SetAttribute("spell", DM_PLAYER.SPELL2)
        Dm_UnitFrames[target]:SetAttribute("target", target)
    end
    local posX = (unitId % BOXESPERLINE) * (BOXESWIDTH + BOXESGUTTER) + BOXESGUTTER
    local posY = math.floor(unitId / BOXESPERLINE) * (BOXESHEIGHT + BOXESGUTTER) + BOXESGUTTER
    Dm_UnitFrames[target]:SetPoint("TOPLEFT", posX, -(posY + CONTAINERTOP))
    Dm_UnitFrames[target]:SetWidth(BOXESWIDTH)
    Dm_UnitFrames[target]:SetHeight(BOXESHEIGHT)
    Dm_UnitFrames[target]:SetAlpha(0)
    Dm_UnitFrames[target].targetIndex = unitId + 1

    Dm_UpdateButton(target)
end

function Dm_DisplayBuff(target, index)
    Dm_UnitFrames[target].ticker = C_Timer.NewTicker(0.1, function(self)
        local _, _, _, _, _, etime = UnitDebuff(target, index)
        local RemainingTime = Dm_RoundValue(etime - GetTime(), 2)
        Dm_UnitFrames[target].text:SetText(RemainingTime)
    end)
end

function Dm_TriggerAura(target)

    local hasDebuff, index = false, 0
    for i = 1, 16, 1 do
        local _, _, _, type, _, etime = UnitDebuff(target, i, "HARMFUL")
        if (etime and etime > 0) then

            print(i, etime, type)

            --Magic/Poison/Disease/Curse

            hasDebuff = true
            index = i
        end
    end
    if (hasDebuff) then
        Dm_DisplayBuff(target, index)
    else
        Dm_UpdateButton(target)
    end
end

function Dm_SetPlayerAttributes()
    local Dm_PlayerClassNameFR, Dm_PlayerClassName = UnitClass("PLAYER")
    DM_PLAYER.CLASSNAME = Dm_PlayerClassName

    local usable = IsUsableSpell(DM_CLASSES[DM_PLAYER.CLASSNAME].SPELL1)
    if (usable) then
        DM_PLAYER.SPELL1 = DM_CLASSES[DM_PLAYER.CLASSNAME].SPELL1
    end

    if (DM_CLASSES[DM_PLAYER.CLASSNAME].SPELL2) then
        local usable = IsUsableSpell(DM_CLASSES[DM_PLAYER.CLASSNAME].SPELL2)
        if (usable) then
            DM_PLAYER.SPELL2 = DM_CLASSES[DM_PLAYER.CLASSNAME].SPELL2
        end
    end
end

function Dm_Init()

    Dm_GenerateMainFrame()

    Dm_GenerateButton("PLAYER", 0)

    for i = 1, 4, 1 do
        Dm_GenerateButton("PARTY"..i, i)
    end

    for i = 1, 40, 1 do
        Dm_GenerateButton("RAID"..i, i - 1)
    end

    return true
end

function Dm_OnLoad(self)

    self:RegisterEvent("LEARNED_SPELL_IN_TAB")
    self:RegisterEvent("UNIT_AURA")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")

    Dm_SetPlayerAttributes()
    if (DM_CLASSES[DM_PLAYER.CLASSNAME]) then
        Dm_Init()
    end
end

function Dm_OnUpdate(self, elapsed)
end

function Dm_OnEvent(self, event, ...)

    if (event == "UNIT_AURA") then
        local target = string.upper(...)
        Dm_TriggerAura(target)
        return
    end
end



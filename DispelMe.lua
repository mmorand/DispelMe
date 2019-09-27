----------------------------------
-- NAMESPACE
----------------------------------
local _, namespace = ...;

local Dm_MainContainer = {}
local Dm_UnitFrames = {}
local CONSTANTS = {
    BOXES = {
        GUTTER = 10,
        HEIGHT = 20,
        PERLINE = 5,
        WIDTH = 50
    },
    CONTAINER_TOP = 0
}
local PLAYER_ATTRIBUTES = {
    CLASSNAME = false,
    CANDISPEL = false,
    SPELL1 = false,
    SPELL2 = false,
    PRIORITY1 = false,
    PRIORITY2 = false
}
local CLASS_COLORS = {
    DRUID =     {r = 1.00, g = 0.49, b = 0.04 },
    HUNTER =    {r = 0.67, g = 0.83, b = 0.45 },
    MAGE =      {r = 0.25, g = 0.78, b = 0.92 },
    PALADIN =   {r = 0.96, g = 0.55, b = 0.73 },
    PRIEST =    {r = 1.00, g = 1.00, b = 1.00 },
    ROGUE =     {r = 1.00, g = 0.96, b = 0.41 },
    SHAMAN =    {r = 0.00, g = 0.44, b = 0.87 },
    WARLOCK =   {r = 0.53, g = 0.53, b = 0.93 },
    WARRIOR =   {r = 0.78, g = 0.61, b = 0.43 },
}
--[[
@TODO AJOUTER LES ID DES AUTRES SORTS POUR TOUTES LES CLASSES
]]--
local CLASS_SPELLS = {
    DRUID = {
        SPELL1 = 2782,
        SPELL2 = 14253
    },
    MAGE = {
        SPELL1 = 475
    },
    PALADIN = {

    },
    PRIEST = {
        SPELL1 = 527,
        SPELL2 = 528
    },
    SHAMAN = {

    },
    WARLOCK = {
        SPELL1 = 696
    }
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
    local Dm_ContainerHeight = (40 / CONSTANTS.BOXES.PERLINE) * (CONSTANTS.BOXES.HEIGHT + CONSTANTS.BOXES.GUTTER) + CONSTANTS.BOXES.GUTTER
    local Dm_ContainerWidth = CONSTANTS.BOXES.PERLINE * (CONSTANTS.BOXES.WIDTH + CONSTANTS.BOXES.GUTTER) + CONSTANTS.BOXES.GUTTER
    Dm_MainContainer:SetSize(Dm_ContainerWidth, (Dm_ContainerHeight + CONSTANTS.CONTAINER_TOP))
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
        Dm_UnitFrames[target].text:SetWidth(CONSTANTS.BOXES.WIDTH - 5)
        Dm_UnitFrames[target]:SetNormalFontObject("GameFontNormalSmall")
        Dm_UnitFrames[target]:SetAlpha(1)

        local Dm_classNameFr, Dm_className = UnitClass(target)
        local cColors = CLASS_COLORS[Dm_className]
        Dm_UnitFrames[target].texture = Dm_UnitFrames[target]:CreateTexture("Dm_DispelButtonTexture"..target, "BACKGROUND")
        Dm_UnitFrames[target].texture:SetAllPoints()
        Dm_UnitFrames[target].texture:SetColorTexture(cColors.r, cColors.g, cColors.b, 1)
    end
end

function Dm_GenerateButton(target, unitId)

    Dm_UnitFrames[target] = CreateFrame("Button", "Dm_DispelButton"..target, Dm_MainContainer, "SecureActionButtonTemplate")
    if (PLAYER_ATTRIBUTES.SPELL1) then
        Dm_UnitFrames[target]:SetAttribute("type1", "spell")
        Dm_UnitFrames[target]:SetAttribute("spell", PLAYER_ATTRIBUTES.SPELL1)
        Dm_UnitFrames[target]:SetAttribute("target", target)
    end
    if (PLAYER_ATTRIBUTES.SPELL2) then
        Dm_UnitFrames[target]:SetAttribute("type2", "spell")
        Dm_UnitFrames[target]:SetAttribute("spell", PLAYER_ATTRIBUTES.SPELL2)
        Dm_UnitFrames[target]:SetAttribute("target", target)
    end
    local posX = (unitId % CONSTANTS.BOXES.PERLINE) * (CONSTANTS.BOXES.WIDTH + CONSTANTS.BOXES.GUTTER) + CONSTANTS.BOXES.GUTTER
    local posY = math.floor(unitId / CONSTANTS.BOXES.PERLINE) * (CONSTANTS.BOXES.HEIGHT + CONSTANTS.BOXES.GUTTER) + CONSTANTS.BOXES.GUTTER
    Dm_UnitFrames[target]:SetPoint("TOPLEFT", posX, -(posY + CONSTANTS.CONTAINER_TOP))
    Dm_UnitFrames[target]:SetWidth(CONSTANTS.BOXES.WIDTH)
    Dm_UnitFrames[target]:SetHeight(CONSTANTS.BOXES.HEIGHT)
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
        local name, _, _, type, _, etime = UnitDebuff(target, i, "HARMFUL")
        if (name and etime and etime > 0) then
            print(i, etime, name, type)

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
    PLAYER_ATTRIBUTES.CLASSNAME = Dm_PlayerClassName

    local usable = IsUsableSpell(CLASS_SPELLS[PLAYER_ATTRIBUTES.CLASSNAME].SPELL1)
    if (usable) then
        PLAYER_ATTRIBUTES.SPELL1 = CLASS_SPELLS[PLAYER_ATTRIBUTES.CLASSNAME].SPELL1
    end

    if (CLASS_SPELLS[PLAYER_ATTRIBUTES.CLASSNAME].SPELL2) then
        local usable = IsUsableSpell(CLASS_SPELLS[PLAYER_ATTRIBUTES.CLASSNAME].SPELL2)
        if (usable) then
            PLAYER_ATTRIBUTES.SPELL2 = CLASS_SPELLS[PLAYER_ATTRIBUTES.CLASSNAME].SPELL2
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
    if (CLASS_SPELLS[PLAYER_ATTRIBUTES.CLASSNAME]) then
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



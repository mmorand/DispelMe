local Dm_MainContainer = {}
local Dm_UnitFrames = {}

local BOXESGUTTER = 10
local BOXESHEIGHT = 50
local BOXESPERLINE = 5
local BOXESWIDTH = 80

local CONTAINERTOP = 0

local DM_DEBUG_MODE = false

local DM_PLAYER = {
    CLASSNAME = false,
    CANDISPEL = {
        Curse = false,
        Disease = false,
        Magic = false,
        Poison = false
    },
    SPELL1 = false,
    SPELL2 = false
}

local DM_DISPEL = {
    DRUID = {
        {
            spellId = {2782},
            canDispel = {'Curse'},
            priority = true
        },
        {
            spellId = {2893, 8946},
            canDispel = {'Poison'}
        }
    },
    PALADIN = {
        {
            spellId = {4987},
            canDispel = {'Curse', 'Disease', 'Poison'},
            priority = true
        },
        {
            spellId = {1152},
            canDispel = {'Disease', 'Poison'}
        }
    },
    MAGE = {
        {
            spellId = {475},
            canDispel = {'Curse' },
            priority = true
        }
    },
    PRIEST = {
        {
            spellId = {552, 528},
            canDispel = {'Disease'}
        },
        {
            spellId = {988, 527},
            canDispel = {'Magic'},
            priority = true
        }
    },
    SHAMAN = {
        {
            spellId = {2870},
            canDispel = {'Disease'}
        },
        {
            spellId = {526},
            canDispel = {'Poison'},
            priority = true
        }
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

function Dm_Debug()

    print('DRUID')
    print(GetSpellInfo(2893)) -- Abolir le poison (multiple)
    print(GetSpellInfo(8946)) -- Guérison du poison
    print(GetSpellInfo(2782)) -- Délivrance de la malédiction

    print('MAGE')
    print(GetSpellInfo(475)) -- Délivrance de la malédiction mineure

    print('PALADIN')
    print(GetSpellInfo(4987)) -- Epuration (maladie-poison-magie)
    print(GetSpellInfo(1152)) -- Purification (maladie-poison)

    print('PRIEST')
    print(GetSpellInfo(527)) -- dissipation magie I
    print(GetSpellInfo(988)) -- dissipation magie II
    print(GetSpellInfo(552)) -- abolir la maladie (multiple)
    print(GetSpellInfo(528)) -- guérison des maladies

    print('SHAMAN')
    print(GetSpellInfo(2870)) -- Guérison des maladies
    print(GetSpellInfo(526)) -- Guérison du poison
end

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

        Dm_UnitFrames[target].text:SetFont("Fonts\\ARIALN.ttf", 15, "OUTLINE")
        Dm_UnitFrames[target].text:SetAllPoints()
        Dm_UnitFrames[target].text:SetText(UnitName(target))
        Dm_UnitFrames[target].text:SetWidth(BOXESWIDTH - 5)
        Dm_UnitFrames[target]:SetNormalFontObject("GameFontNormalSmall")
        Dm_UnitFrames[target]:SetAlpha(1)

        local Dm_classNameFr, Dm_className = UnitClass(target)
        local ClassColors = DM_COLORS[Dm_className]
        Dm_UnitFrames[target].texture:SetAllPoints()
        Dm_UnitFrames[target].texture:SetColorTexture(ClassColors.r, ClassColors.g, ClassColors.b, 1)
        Dm_UnitFrames[target].texture:SetToplevel(true)
    end
end

function Dm_GenerateButton(target, unitId)

    Dm_UnitFrames[target] = CreateFrame("Button", "Dm_DispelButton"..target, Dm_MainContainer, "SecureActionButtonTemplate")
    Dm_UnitFrames[target].text = Dm_UnitFrames[target]:CreateFontString("Dm_DispelButtonText"..target, "ARTWORK")
    Dm_UnitFrames[target].texture = Dm_UnitFrames[target]:CreateTexture("Dm_DispelButtonTexture"..target, "BACKGROUND")

    if (DM_PLAYER.SPELL1) then
        Dm_UnitFrames[target]:SetAttribute("type1", "spell")
        Dm_UnitFrames[target]:SetAttribute("spell", DM_PLAYER.SPELL1)
        Dm_UnitFrames[target]:SetAttribute("target", target)
    end
    if (DM_PLAYER.SPELL2) then
        -- @todo: Le clic droit ne fonctionne pas
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
    Dm_UnitFrames[target].ticker = C_Timer.NewTicker(0.1, function()
        local _, _, _, type, _, etime = UnitBuff(target, index)
        local RemainingTime = Dm_RoundValue(etime - GetTime(), 2)
        local debuffColors = DM_COLORS[type]

        Dm_UnitFrames[target].texture:SetColorTexture(debuffColors.r, debuffColors.g, debuffColors.b, 1)
        Dm_UnitFrames[target].text:SetText(RemainingTime)
    end)
end

function Dm_TriggerAura(target)

    local needDispelCurse, needDispelDisease, needDispelMagic, needDispelPoison = false, false, false, false
    local indexCurse, indexDisease, indexMagic, indexPoison = 0, 0, 0, 0

    for i = 1, 16, 1 do
        local _, _, _, type, _, etime = UnitBuff(target, i)
        if (etime and etime > 0) then

            print('une aura '..type)

            if (type == 'Curse') and DM_PLAYER.CANDISPEL.Curse then
                needDispelCurse = true
                indexCurse = i
            end
            if (type == 'Disease') and DM_PLAYER.CANDISPEL.Disease then
                needDispelDisease = true
                indexDisease = i
            end
            if (type == 'Magic') and DM_PLAYER.CANDISPEL.Magic then
                print('canDispel Magic')
                needDispelMagic = true
                indexMagic = i
            end
            if (type == 'Poison') and DM_PLAYER.CANDISPEL.Poison then
                needDispelPoison = true
                indexPoison = i
            end
        end
    end
    if (needDispelCurse) then
        print('curse')
        Dm_DisplayBuff(target, indexCurse)
    elseif (needDispelMagic) then
        print('magic')
        Dm_DisplayBuff(target, indexMagic)
    elseif (needDispelPoison) then
        print('poison')
        Dm_DisplayBuff(target, indexPoison)
    elseif (needDispelDisease) then
        print('disease')
        Dm_DisplayBuff(target, indexDisease)
    else
        print('no debuff')
        Dm_UpdateButton(target)
    end
end

function Dm_AssignSpellToPlayer(slot, spellId, canDispel)
    DM_PLAYER[slot] = spellId
    for index, value in pairs(canDispel) do
        DM_PLAYER.CANDISPEL[value] = true
    end
end

function Dm_SetPlayerAttributes()

    local spells = {}
    local Dm_PlayerClassNameFR, Dm_PlayerClassName = UnitClass("PLAYER")
    DM_PLAYER.CLASSNAME = Dm_PlayerClassName

    for spellIndex, spellInfos in pairs(DM_DISPEL[DM_PLAYER.CLASSNAME]) do
        for index, spellId in pairs(spellInfos.spellId) do
            local knowSpell = IsSpellKnown(spellId)
            if (knowSpell) then
                local spell = {
                    spellId = spellId,
                    canDispel = spellInfos.canDispel,
                    priority = spellInfos.priority
                }
                table.insert(spells, spell)
            end
        end
    end

    if (table.getn(spells) > 0) then
        if (table.getn(spells) > 1) then
            for i, spell in pairs(spells) do
                if (spell.priority) then
                    Dm_AssignSpellToPlayer('SPELL1', spell.spellId, spell.canDispel)
                else
                    Dm_AssignSpellToPlayer('SPELL2', spell.spellId, spell.canDispel)
                end
            end
        else
            for i, spell in pairs(spells) do
                Dm_AssignSpellToPlayer('SPELL1', spell.spellId, spell.canDispel)
            end
        end
    end
end

function Dm_Init()

    if (DM_DEBUG_MODE) then
        Dm_Debug()
    end

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

    if (DM_DISPEL[DM_PLAYER.CLASSNAME]) then
        Dm_Init()
    end
end

function Dm_OnEvent(self, event, ...)

    if (event == "UNIT_AURA") then
        local target = string.upper(...)
        Dm_TriggerAura(target)
        return
    end
end



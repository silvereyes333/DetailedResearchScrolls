ResearchScrollWarning = {
    name = "ResearchScrollWarning",
    title = "Research Scroll Warning",
    version = "1.0.1",
    author = "|c99CCEFsilvereyes|r",
}
local self               = ResearchScrollWarning
local CRAFT_SKILLS_ALL   = { CRAFTING_TYPE_BLACKSMITHING, CRAFTING_TYPE_CLOTHIER, CRAFTING_TYPE_WOODWORKING }
local CRAFT_SKILLS_SMITH = { CRAFTING_TYPE_BLACKSMITHING }
local CRAFT_SKILLS_CLOTH = { CRAFTING_TYPE_CLOTHIER }
local CRAFT_SKILLS_WOOD  = { CRAFTING_TYPE_WOODWORKING }
local COLOR_WARNING      = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_FAILED))
local ONE_DAY            = 86400
local TWO_DAYS           = 2 * ONE_DAY
local SEVEN_DAYS         = 7 * ONE_DAY
local FIFTEEN_DAYS       = 15 * ONE_DAY
local GRAND_SCROLL_DURATION
if GetAPIVersion() < 100020 then
    GRAND_SCROLL_DURATION = TWO_DAYS
else
    GRAND_SCROLL_DURATION = FIFTEEN_DAYS
end
local researchScrolls    = {
    -- Crown Research Scroll, Blacksmithing, 1 Day
    [125450] = {
        ["craftSkills"] = CRAFT_SKILLS_SMITH,
        ["duration"] = ONE_DAY,
    },
    -- Crown Research Scroll, Blacksmithing, 2 Day
    [125462] = {
        ["craftSkills"] = CRAFT_SKILLS_SMITH,
        ["duration"] = GRAND_SCROLL_DURATION,
    },
    -- Crown Research Scroll, Blacksmithing, 7 Day
    [125463] = {
        ["craftSkills"] = CRAFT_SKILLS_SMITH,
        ["duration"] = SEVEN_DAYS,
    },
    -- Crown Research Scroll, Clothing, 1 Day
    [125464] = {
        ["craftSkills"] = CRAFT_SKILLS_CLOTH,
        ["duration"] = ONE_DAY,
    },
    -- Crown Research Scroll, Clothing, 2 Day
    [125465] = {
        ["craftSkills"] = CRAFT_SKILLS_CLOTH,
        ["duration"] = GRAND_SCROLL_DURATION,
    },
    -- Crown Research Scroll, Clothing, 7 Day
    [125466] = {
        ["craftSkills"] = CRAFT_SKILLS_CLOTH,
        ["duration"] = SEVEN_DAYS,
    },
    -- Crown Research Scroll, Woodworking, 1 Day
    [125467] = {
        ["craftSkills"] = CRAFT_SKILLS_WOOD,
        ["duration"] = ONE_DAY,
    },
    -- Crown Research Scroll, Woodworking, 2 Day
    [125468] = {
        ["craftSkills"] = CRAFT_SKILLS_WOOD,
        ["duration"] = GRAND_SCROLL_DURATION,
    },
    -- Crown Research Scroll, Woodworking, 7 Day
    [125469] = {
        ["craftSkills"] = CRAFT_SKILLS_WOOD,
        ["duration"] = SEVEN_DAYS,
    },
    -- Crown Research Scroll, All, 1 Day
    [125470] = {
        ["craftSkills"] = CRAFT_SKILLS_ALL,
        ["duration"] = ONE_DAY,
    },
    -- Crown Research Scroll, All, 2 Day
    [125471] = {
        ["craftSkills"] = CRAFT_SKILLS_ALL,
        ["duration"] = GRAND_SCROLL_DURATION,
    },
    -- Crown Research Scroll, All, 7 Day
    [125472] = {
        ["craftSkills"] = CRAFT_SKILLS_ALL,
        ["duration"] = SEVEN_DAYS,
    },
    -- Research Scroll, Blacksmithing, 1 Day
    [125473] = {
        ["craftSkills"] = CRAFT_SKILLS_SMITH,
        ["duration"] = ONE_DAY,
    },
    -- Research Scroll, Clothing, 1 Day
    [125474] = {
        ["craftSkills"] = CRAFT_SKILLS_CLOTH,
        ["duration"] = ONE_DAY,
    },
    -- Research Scroll, Woodworking, 1 Day
    [125475] = {
        ["craftSkills"] = CRAFT_SKILLS_WOOD,
        ["duration"] = ONE_DAY,
    },
}
local activeResearchLines = {}

local function GetItemIdFromLink(itemLink)
    local itemId = select(4, ZO_LinkHandler_ParseLink(itemLink))
    if itemId and itemId ~= "" then
        return tonumber(itemId)
    end
end
local function MarkResearchActive(craftSkill, researchLineIndex, traitIndex)
    table.insert(activeResearchLines[craftSkill], { researchLineIndex = researchLineIndex, traitIndex = traitIndex })
end
local function MarkResearchComplete(craftSkill, researchLineIndex, traitIndex)
    for i=1,#activeResearchLines[craftSkill] do
        local activeResearch = activeResearchLines[craftSkill][i]
        if activeResearch.researchLineIndex == researchLineIndex and activeResearch.traitIndex == traitIndex then
            table.remove(activeResearchLines[craftSkill], i)
            return
        end
    end
end
local function GetRemainingResearchSeconds(craftSkill, researchLineIndex, traitIndex)
    return select(2, GetSmithingResearchLineTraitTimes(craftSkill, researchLineIndex, traitIndex))
end
function self.GetScrollDataForTooltip(itemLink)
    if not itemLink then return end
    local itemId = GetItemIdFromLink(itemLink)
    if not itemId then return end
    local scrollData = researchScrolls[itemId]
    if not scrollData then return end
    
    for _, craftSkill in ipairs(scrollData.craftSkills) do
        local skillResearch = activeResearchLines[craftSkill]
        if not skillResearch then return end
        if #skillResearch < 3 then
            return scrollData
        end
        local invalidResearchCount = 0
        for i = #skillResearch,1,-1 do
            local researchLineIndex = skillResearch[i].researchLineIndex
            local traitIndex        = skillResearch[i].traitIndex
            local seconds = GetRemainingResearchSeconds(craftSkill, researchLineIndex, traitIndex)
            local known = select(3, GetSmithingResearchLineTraitInfo(craftSkill, researchLineIndex, traitIndex))
            if known or not seconds then
                MarkResearchComplete(craftSkill, researchLineIndex, traitIndex)
            elseif seconds < scrollData.duration then
                invalidResearchCount = invalidResearchCount + 1
            end
            if (#skillResearch - invalidResearchCount) < 3 then
                return scrollData
            end
        end
    end
end
local function TooltipHook(tooltipControl, method, linkFunc)
	local origMethod = tooltipControl[method]

	tooltipControl[method] = function(control, ...)
		origMethod(control, ...)
        local itemLink = linkFunc(...)
        local scrollData = self.GetScrollDataForTooltip(itemLink)
        if scrollData then
            control:AddVerticalPadding(8)
            ZO_Tooltip_AddDivider(control)
            local warningText = GetString(SI_RESEARCHSCROLLWARNING_WARNING)
            warningText = zo_strformat(warningText, 3*#scrollData.craftSkills, scrollData.duration / ONE_DAY)
            warningText = COLOR_WARNING:Colorize(warningText)
            control:AddLine(warningText)
        end	
	end
end

local function ReturnItemLink(itemLink)
	return itemLink
end
local function HookToolTips()
    TooltipHook(ItemTooltip, "SetBagItem", GetItemLink)
    TooltipHook(ItemTooltip, "SetTradeItem", GetTradeItemLink)
    TooltipHook(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
    TooltipHook(ItemTooltip, "SetStoreItem", GetStoreItemLink)
    TooltipHook(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
    TooltipHook(ItemTooltip, "SetLootItem", GetLootItemLink)
    TooltipHook(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
    TooltipHook(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
    TooltipHook(ItemTooltip, "SetLink", ReturnItemLink)
    TooltipHook(PopupTooltip, "SetLink", ReturnItemLink)
end
local function UpdateActiveResearchLines()
    for _, craftSkill in ipairs(CRAFT_SKILLS_ALL) do
        activeResearchLines[craftSkill] = {}
        -- Total number of research lines for this craft skill
        local researchLineCount = GetNumSmithingResearchLines(craftSkill)
        
        -- Loop through each research line (e.g. axe, mace, etc.)
        for researchLineIndex = 1, researchLineCount do
            
            -- Get the total number of traits in the research line
            local numTraits = select(3, GetSmithingResearchLineInfo(craftSkill, researchLineIndex))
            
            for traitIndex = 1, numTraits do
                local secondsRemaining = GetRemainingResearchSeconds(craftSkill, researchLineIndex, traitIndex)
                if secondsRemaining then
                    MarkResearchActive(craftSkill, researchLineIndex, traitIndex)
                    break
                end
            end
        end
    end
end
local function OnResearchStarted(eventCode, craftSkill, researchLineIndex, traitIndex)
    MarkResearchActive(craftSkill, researchLineIndex, traitIndex)
end
local function OnResearchCompleted(eventCode, craftSkill, researchLineIndex, traitIndex)
    MarkResearchComplete(craftSkill, researchLineIndex, traitIndex)
end
local function HookResearchEvents()
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED, OnResearchCompleted)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_SMITHING_TRAIT_RESEARCH_STARTED, OnResearchStarted)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_SMITHING_TRAIT_RESEARCH_TIMES_UPDATED, UpdateActiveResearchLines)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_SKILLS_FULL_UPDATE, UpdateActiveResearchLines)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, UpdateActiveResearchLines)
end
local function OnAddonLoaded(event, name)
    if name ~= self.name then return end
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
    HookResearchEvents()
    HookToolTips()
end
EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
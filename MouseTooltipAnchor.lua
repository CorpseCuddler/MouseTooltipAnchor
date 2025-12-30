-- MouseTooltipAnchor.lua
-- Ascension / WoW 3.3.5a (Interface 30300)

local ADDON = ...
local OFFSET_X = 18   -- positive = to the right of cursor
local OFFSET_Y = -18  -- negative = below cursor

-- Ensure tooltip appears above most UI
local function RaiseTooltip(tt)
    if not tt or tt:IsForbidden and tt:IsForbidden() then return end

    -- "TOOLTIP" is typically already high, but we can force it
    tt:SetFrameStrata("TOOLTIP")
    tt:SetFrameLevel(1000)

    -- Optional: some servers/UIs use backdrops that can appear weirdly; keep it simple.
end

-- Force anchor to cursor with an offset
local function AnchorToCursor(tt)
    if not tt or not tt.SetOwner then return end

    -- Clear points and set owner to UIParent at cursor, then apply offset
    tt:ClearAllPoints()
    tt:SetOwner(UIParent, "ANCHOR_CURSOR", OFFSET_X, OFFSET_Y)

    RaiseTooltip(tt)
end

-- Hook the default tooltip anchor behavior
hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tt, parent)
    -- This fires whenever the game tries to place the tooltip
    AnchorToCursor(tt)
end)

-- Also handle when something sets the owner directly (many addons do)
local function HookTooltip(tt)
    if not tt or tt.__MouseTooltipAnchorHooked then return end
    tt.__MouseTooltipAnchorHooked = true

    hooksecurefunc(tt, "SetOwner", function(self, owner, anchor, xOff, yOff)
        -- Prevent recursion: SetOwner will call our hook again
        if self.__MTA_inSetOwner then return end

        self.__MTA_inSetOwner = true
        -- Only re-anchor if it's visible (avoid fighting early initialization)
        if self:IsShown() then
            AnchorToCursor(self)
        else
            -- Still raise it so when shown it's on top
            RaiseTooltip(self)
        end
        self.__MTA_inSetOwner = nil
    end)

    -- When shown, make sure strata/level stays high (some UIs change it)
    tt:HookScript("OnShow", function(self)
        AnchorToCursor(self)
    end)
end

-- Main tooltip + commonly-used secondary tooltips
HookTooltip(GameTooltip)
HookTooltip(ItemRefTooltip)        -- clickable links tooltip
HookTooltip(ShoppingTooltip1)      -- compare tooltips
HookTooltip(ShoppingTooltip2)
HookTooltip(ShoppingTooltip3)

-- Some frames use these (depends on UI/addons)
if GameTooltipStatusBar then
    RaiseTooltip(GameTooltipStatusBar)
end

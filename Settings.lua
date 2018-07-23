local addon = DetailedResearchScrolls

----------------- Settings -----------------------
function addon:GetSetting(settingName)
    if self.characterSettings.useAccountSettings then
        return self.accountSettings[settingName]
    else
        return self.characterSettings[settingName]
    end 
end

function addon:SetSetting(settingName, value)
    if self.characterSettings.useAccountSettings then
        self.accountSettings[settingName] = value
    else
        self.characterSettings[settingName] = value
    end 
end

local function tableCopyValues(source, dest)
    d("tableCopyValues("..type(source)..","..type(dest)..")")
    for key, value in pairs(source) do
        d(tostring(key)..":"..tostring(value))
        if type(value) == "table" then
            if type(dest[key]) ~= "table" then
                d("dest["..tostring(key).."] = {}")
                dest[key] = {}
            end
            tableCopyValues(value, dest[key])
        elseif key ~= "version" and type(value) ~= "function" then
            d("dest["..tostring(key).."] = "..tostring(value))
            dest[key] = value
        end
    end
end

function addon:CopyAccountSettingsToCharacter()
    tableCopyValues(getmetatable(DetailedResearchScrolls.accountSettings).__index,
                    getmetatable(DetailedResearchScrolls.characterSettings).__index)
end

function addon:SetupSettings()
    local LAM2 = LibStub("LibAddonMenu-2.0")
    
    self.defaults = 
    {
        notify                  = false,
        notifyChat              = true,
        notifySound             = true,
        notifyEveryLogin        = false,
        notifyOnlyWithInventory = true,
        notifyInventoryBags     = 
        {
            [BAG_BACKPACK]       = true,
            [BAG_BANK]           = true,
            [BAG_HOUSE_BANK_ONE] = true,
        }
    }
    
    local worldName = GetWorldName()
    self.accountSettings = ZO_SavedVars:NewAccountWide(addon.name .. "_Account", 1, nil, self.defaults, worldName)
    self.characterSettings = ZO_SavedVars:NewCharacterIdSettings(addon.name .. "_Character", 1, nil, { useAccountSettings = true }, worldName)

    local panelData = {
        type = "panel",
        name = addon.title,
        displayName = addon.title,
        author = addon.author,
        version = addon.version,
        slashCommand = "/detailedresearchscrolls",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM2:RegisterAddonPanel(self.name.."Options", panelData)

    local optionsTable = {
        -- Verbose
        {
            type    = "checkbox",
            name    = GetString(SI_DETAILEDRESEARCHSCROLLS_ACCOUNT_WIDE),
            getFunc = function() return self.characterSettings.useAccountSettings end,
            setFunc = function(value)
                self.characterSettings.useAccountSettings = value 
                -- The first time character-specific settings are chosen, copy the account-wide settings values
                if not value and self.characterSettings.notify == nil then
                    self:CopyAccountSettingsToCharacter()
                end
            end,
            default = true,
        },
        -- Cooldown notifications
        {
            type    = "checkbox",
            name    = GetString(SI_DETAILEDRESEARCHSCROLLS_CD_NOTICE),
            getFunc =  function() return self:GetSetting("notify") end,
            setFunc = function(value) self:SetSetting("notify", value) end,
            default = self.defaults.notify,
        },
        -- Chat notifications
        {
            type    = "checkbox",
            name    = GetString(SI_DETAILEDRESEARCHSCROLLS_CD_NOTICE_CHAT),
            getFunc =  function() return self:GetSetting("notifyChat") end,
            setFunc = function(value) self:SetSetting("notifyChat", value) end,
            default = self.defaults.notifyChat,
            disabled = function() return not self:GetSetting("notify") end
        },
        -- Sound notifications
        {
            type    = "checkbox",
            name    = GetString(SI_DETAILEDRESEARCHSCROLLS_CD_NOTICE_SOUND),
            getFunc =  function() return self:GetSetting("notifySound") end,
            setFunc = function(value) self:SetSetting("notifySound", value) end,
            default = self.defaults.notifySound,
            disabled = function() return not self:GetSetting("notify") end
        },
        -- Notify Every Login
        {
            type    = "checkbox",
            name    = GetString(SI_DETAILEDRESEARCHSCROLLS_CD_NOTICE_EVERY_LOGIN),
            getFunc =  function() return self:GetSetting("notifyEveryLogin") end,
            setFunc = function(value) self:SetSetting("notifyEveryLogin", value) end,
            default = self.defaults.notifyEveryLogin,
            disabled = function() return not self:GetSetting("notify") end
        },
        {
            type = "divider",
            width = "full",
        },
        -- Only notify with applicable scrolls in inventory
        {
            type    = "checkbox",
            name    = GetString(SI_DETAILEDRESEARCHSCROLLS_CD_NOTICE_ONLY_WITH_INV),
            getFunc =  function() return self:GetSetting("notifyOnlyWithInventory") end,
            setFunc = function(value) self:SetSetting("notifyOnlyWithInventory", value) end,
            default = self.defaults.notifyEveryLogin,
            disabled = function() return not self:GetSetting("notify") end
        },
    }
    local bags = {
        { bagId = BAG_BACKPACK,       name = GetString(SI_MAIN_MENU_INVENTORY) },
        { bagId = BAG_BANK,           name = GetString(SI_CURRENCYLOCATION1) },
        { bagId = BAG_HOUSE_BANK_ONE, name = GetString(SI_DETAILEDRESEARCHSCROLLS_HOUSING_STORAGE) },
    }
    
    local disableBagsOptions = function() return not self:GetSetting("notify") or not self:GetSetting("notifyOnlyWithInventory") end
    
    for i=1,#bags do
        local bagId = bags[i].bagId
        local bagName = bags[i].name
        table.insert(optionsTable, {
            type    = "checkbox",
            name    = bagName,
            getFunc = function() return self:GetSetting("notifyInventoryBags")[bagId] end,
            setFunc = function(value) self:GetSetting("notifyInventoryBags")[bagId] = value end,
            default = self.defaults.notifyInventoryBags[bagId],
            disabled = disableBagsOptions
        })
    end
    
    LAM2:RegisterOptionControls(self.name.."Options", optionsTable)
end

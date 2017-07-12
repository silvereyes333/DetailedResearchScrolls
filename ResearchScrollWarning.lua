ResearchScrollWarning = {
    name = "ResearchScrollWarning",
    title = "Research Scroll Warning",
    version = "1.0.0",
    author = "|c99CCEFsilvereyes|r",
}
local self = ResearchScrollWarning
local function OnAddonLoaded(event, name)
    if name ~= self.name then return end
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
end
EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
local strings = {
    ["SI_DETAILEDRESEARCHSCROLLS_WARNING"]              = "Weniger als <<1>> Analyse Zeitraum mit <<2[/1 Tag/$d Tagen]>> übrig.",
    ["SI_DETAILEDRESEARCHSCROLLS_ALL_TRAITS"]           = "<<1>>/<<2>> Fertigkeitslinien mit allen Eigenschaften.",
    ["SI_DETAILEDRESEARCHSCROLLS_NO_RESEARCH"]          = "Es ist keine Analyse aktiv.",
    ["SI_DETAILEDRESEARCHSCROLLS_RESEARCH_SLOT_UNUSED"] = "<<IN:1>> Analyseplatz nicht aktiv.",
}

-- Overwrite English strings
for stringId, value in pairs(strings) do
    DETAILEDRESEARCHSCROLLS_STRINGS[stringId] = value
end
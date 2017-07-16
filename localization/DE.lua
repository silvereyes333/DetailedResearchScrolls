local strings = {
    ["SI_DETAILEDRESEARCHSCROLLS_WARNING"] = "Weniger als <<1>> Analyse Zeitraum mit <<2[/1 Tag/$d Tagen]>> übrig."
}

-- Overwrite English strings
for stringId, value in pairs(strings) do
    DETAILEDRESEARCHSCROLLS_STRINGS[stringId] = value
end
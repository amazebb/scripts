# Print one tab separated row per alert from an NWS alerts json, most severe first:
# severity, event, start, end, headline, area, description, instructions.
# Newlines in the text become \037. Used by wxalerts alert_rows.

function val(l) {
    gsub(/^[^:]*: *"?|"?,? *$/, "", l)
    gsub(/\\n/, "\037", l); gsub(/\\"/, "\"", l); gsub(/\t/, " ", l)
    return l
}
/^                "areaDesc"/ { n++; area[n] = val($0) }
n && /^                "severity"/ { sev[n] = val($0) }
n && /^                "event"/ { event[n] = val($0) }
n && /^                "effective"/ { effective[n] = val($0) }
n && /^                "onset"/ { onset[n] = val($0) }
n && /^                "expires"/ { expires[n] = val($0) }
n && /^                "ends"/ { ends[n] = val($0) }
n && /^                "headline"/ { head[n] = val($0) }
n && /^                "description"/ { desc[n] = val($0) }
n && /^                "instruction"/ { instr[n] = val($0) == "null" ? "" : val($0) }
END {
    split("Extreme Severe Moderate Minor Unknown", order, " ")
    for (o = 1; o <= 5; o++)
        for (i = 1; i <= n; i++)
            if ((o < 5 && sev[i] == order[o]) || (o == 5 && sev[i] != "Extreme" && sev[i] != "Severe" && sev[i] != "Moderate" && sev[i] != "Minor"))
                printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", sev[i], event[i], (onset[i] != "" && onset[i] != "null") ? onset[i] : effective[i], (ends[i] != "" && ends[i] != "null") ? ends[i] : expires[i], head[i], area[i], desc[i], instr[i]
}

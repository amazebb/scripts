#!/usr/bin/env bash
# shellcheck disable=SC2329,SC2317,SC2016
source "$(dirname "$0")/lib.sh"

# alert_json: a Moderate Heat Advisory listed before a Severe Flood Watch
alert_json() {
  local f
  printf '{\n    "features": [\n'
  for f in "Moderate|Heat Advisory|HEAT DESC" "Severe|Flood Watch|FLOOD DESC\\nSECOND LINE"; do
    IFS='|' read -r sev ev desc <<<"$f"
    cat <<JSON
        {
            "properties": {
                "areaDesc": "Test County",
                "geocode": {
                    "UGC": [
                        "XXZ001"
                    ]
                },
                "onset": "2026-10-30T10:00:00-04:00",
                "ends": "2026-10-30T20:00:00-04:00",
                "expires": "2026-10-30T19:00:00-04:00",
                "severity": "$sev",
                "event": "$ev",
                "headline": "$ev issued for Test County",
                "description": "$desc",
                "instruction": "Stay safe.",
                "parameters": {
                    "NWSheadline": [
                        "x"
                    ]
                }
            }
        },
JSON
  done
  printf '    ]\n}\n'
}

wa_shims() {
  alert_json >"$TMP/alerts.json"
  shim curl 'case "$*" in
  *alerts/active*) [ -e "$TMP/noalerts" ] && echo "{\"features\": []}" || cat "$TMP/alerts.json" ;;
  *zippopotam*) echo "{\"places\":[{\"longitude\": \"-73.9967\", \"latitude\": \"40.7484\"}]}" ;;
  *ipinfo*) echo "40.7484,-73.9967" ;;
esac'
  rm -f "$TMP/noalerts"
}

# the most severe alert comes first, with severity, start and end time
wa_order() {
  wa_shims
  local out
  out=$(TZ=UTC "$BIN/wxalerts" 10001 2>&1 | sed 's/\x1b\[[0-9;]*m//g')
  [[ $out == "⚠ Flood Watch (Severe) from 30-Oct-2026 14:00 until 31-Oct-2026 00:00"* && $out == *"⚠ Heat Advisory (Moderate)"* &&
    $out == *"Flood Watch issued for Test County"* && $out == *"Area: Test County"* ]] &&
    [[ $out != *"FLOOD DESC"* ]]
}

# -l prints the description over several lines and the instructions
wa_long() {
  wa_shims
  local out
  out=$("$BIN/wxalerts" -l 10001 2>&1 | sed 's/\x1b\[[0-9;]*m//g')
  [[ $out == *"  FLOOD DESC"$'\n'"  SECOND LINE"* && $out == *"  Stay safe."* ]]
}

# -b is one line per alert and silent with none
wa_brief() {
  wa_shims
  local out
  out=$("$BIN/wxalerts" -b 10001 2>&1 | sed 's/\x1b\[[0-9;]*m//g')
  [[ $(wc -l <<<"$out") -eq 2 && $out == "⚠ Flood Watch (Severe)"* ]] || return 1
  touch "$TMP/noalerts"
  [[ -z $("$BIN/wxalerts" -b 10001 2>&1) && $("$BIN/wxalerts" 10001 2>&1) == *"No active alerts"* ]]
}

t "wxalerts: most severe first" wa_order
t "wxalerts: -l long text" wa_long
t "wxalerts: -b brief" wa_brief

exit $FAILED

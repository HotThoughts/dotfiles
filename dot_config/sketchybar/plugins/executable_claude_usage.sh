#!/bin/sh

. "$CONFIG_DIR/colors.sh"

IDLE() {
	sketchybar --set "$NAME" label="--" label.color="$WHITE"
	exit 0
}

CACHE_FILE="$HOME/.cache/claude-code/rate_limits.json"
[ -f "$CACHE_FILE" ] || IDLE

FIVE_HOUR_PCT=$(jq -r '.five_hour.used_percentage // empty' "$CACHE_FILE" 2>/dev/null)
FIVE_HOUR_RESET=$(jq -r '.five_hour.resets_at // empty' "$CACHE_FILE" 2>/dev/null)
SEVEN_DAY_PCT=$(jq -r '.seven_day.used_percentage // empty' "$CACHE_FILE" 2>/dev/null)
SEVEN_DAY_RESET=$(jq -r '.seven_day.resets_at // empty' "$CACHE_FILE" 2>/dev/null)

[ -z "$FIVE_HOUR_PCT" ] && [ -z "$SEVEN_DAY_PCT" ] && IDLE

NOW=$(date +%s)

if [ -n "$FIVE_HOUR_PCT" ] && [ -n "$FIVE_HOUR_RESET" ] && [ "$FIVE_HOUR_RESET" -ge "$NOW" ]; then
	FIVE_HOUR_LABEL="5h ${FIVE_HOUR_PCT%.*}%"
else
	FIVE_HOUR_LABEL="5h --"
fi

if [ -n "$SEVEN_DAY_PCT" ] && [ -n "$SEVEN_DAY_RESET" ] && [ "$SEVEN_DAY_RESET" -ge "$NOW" ]; then
	SEVEN_DAY_LABEL="7d ${SEVEN_DAY_PCT%.*}%"
else
	SEVEN_DAY_LABEL="7d --"
fi

sketchybar --set "$NAME" label="$FIVE_HOUR_LABEL · $SEVEN_DAY_LABEL" label.color="$WHITE"

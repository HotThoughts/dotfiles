#!/bin/sh

. "$CONFIG_DIR/colors.sh"

IDLE() {
	sketchybar --set "$NAME" label="--" label.color="$WHITE"
	exit 0
}

ROLLOUT_FILE=$(find "$HOME/.codex/sessions" -type f -name 'rollout-*.jsonl' -print0 2>/dev/null | xargs -0 ls -t 2>/dev/null | head -1)
[ -z "$ROLLOUT_FILE" ] && IDLE

RATE_LIMITS=$(jq -c 'select(.type=="event_msg" and .payload.type=="token_count") | .payload.rate_limits' "$ROLLOUT_FILE" 2>/dev/null | tail -1)
[ -z "$RATE_LIMITS" ] && IDLE

PRIMARY_PCT=$(echo "$RATE_LIMITS" | jq -r '.primary.used_percent // empty')
PRIMARY_RESET=$(echo "$RATE_LIMITS" | jq -r '.primary.resets_at // empty')
SECONDARY_PCT=$(echo "$RATE_LIMITS" | jq -r '.secondary.used_percent // empty')
SECONDARY_RESET=$(echo "$RATE_LIMITS" | jq -r '.secondary.resets_at // empty')

[ -z "$PRIMARY_PCT" ] && [ -z "$SECONDARY_PCT" ] && IDLE

NOW=$(date +%s)

if [ -n "$PRIMARY_PCT" ] && [ -n "$PRIMARY_RESET" ] && [ "$PRIMARY_RESET" -ge "$NOW" ]; then
	PRIMARY_LABEL="5h ${PRIMARY_PCT%.*}%"
else
	PRIMARY_LABEL="5h --"
fi

if [ -n "$SECONDARY_PCT" ] && [ -n "$SECONDARY_RESET" ] && [ "$SECONDARY_RESET" -ge "$NOW" ]; then
	SECONDARY_LABEL="7d ${SECONDARY_PCT%.*}%"
else
	SECONDARY_LABEL="7d --"
fi

sketchybar --set "$NAME" label="$PRIMARY_LABEL · $SECONDARY_LABEL" label.color="$WHITE"

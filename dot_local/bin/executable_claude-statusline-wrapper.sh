#!/bin/sh

INPUT=$(cat)

CACHE_DIR="$HOME/.cache/claude-code"
mkdir -p "$CACHE_DIR" 2>/dev/null

RATE_LIMITS=$(printf '%s' "$INPUT" | jq -c '.rate_limits // empty' 2>/dev/null)
if [ -n "$RATE_LIMITS" ] && [ "$RATE_LIMITS" != "null" ]; then
	TMP_FILE=$(mktemp "$CACHE_DIR/rate_limits.json.XXXXXX" 2>/dev/null)
	if [ -n "$TMP_FILE" ]; then
		printf '%s' "$RATE_LIMITS" >"$TMP_FILE" 2>/dev/null
		mv "$TMP_FILE" "$CACHE_DIR/rate_limits.json" 2>/dev/null
	fi
fi

printf '%s' "$INPUT" | cship

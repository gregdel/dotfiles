#!/bin/sh
# Claude Code Stop hook: warn in the chat when a request of the last turn missed
# the prompt cache, i.e. read back less than the previous request had cached
# (read + written). Output is a display-only systemMessage, so no tokens are used.
t=$(jq -r '.transcript_path // empty') && [ -r "$t" ] || exit 0
# Stop can fire before the final assistant entry is flushed to the transcript;
# wait (up to ~2s) until the last turn-relevant entry is a final assistant one.
i=0
until jq -en 'last(inputs | select(.isSidechain != true and (.type == "assistant"
    or (.type == "user" and .isMeta != true
        and (.message.content | type == "string" or any(.[]?; .type == "text"))))))
  | .type == "assistant" and .message.stop_reason != "tool_use"' "$t" >/dev/null; do
  i=$((i + 1)); [ "$i" -ge 20 ] && break; sleep 0.1
done
exec jq -cn --argjson min "${CACHE_MISS_MIN:-10000}" '
  def tok: if . < 1e3 then tostring elif . < 1e6 then "\(. / 1e3 | round)k" else "\(. / 1e5 | round / 10)M" end;
  reduce (inputs | select(.isSidechain != true)) as $e ({prev: 0, seen: {}, miss: []};
    if $e.type == "user" and $e.isMeta != true
       and ($e.message.content | type == "string" or any(.[]?; .type == "text")) then
      .miss = []
    elif $e.type == "system" and $e.subtype == "compact_boundary" then
      .prev = 0 | .miss = []
    elif $e.type == "assistant" and $e.message.model != "<synthetic>"
       and ($e.message.usage.input_tokens // 0) > 0 and (.seen[$e.requestId // ""] | not) then
      ($e.message.usage.cache_read_input_tokens // 0) as $read
      | .seen[$e.requestId // ""] = true
      | if .prev - $read >= $min then .miss += [.prev - $read] else . end
      | .prev = $read + ($e.message.usage.cache_creation_input_tokens // 0)
    else . end)
  | .miss | select(length > 0)
  | {systemMessage: "\u001b[1;33m⚠ cache miss: \(map(tok) | join(" + ")) tokens re-written\u001b[0m"}
' "$t"

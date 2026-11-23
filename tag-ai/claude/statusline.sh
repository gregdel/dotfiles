#!/bin/sh
# Claude Code status line, modelled on the pi status bar:
# cwd  model effort  cache/cost  context  5h/7d limits left  remote control
# Reads the session JSON on stdin. Remote Control state is not in that JSON;
# it is taken from bridgeSessionId in Claude's own ~/.claude/sessions/*.json.
exec jq -nr --arg home "$HOME" '
  def c($rgb): "\u001b[38;2;\($rgb)m\(.)\u001b[0m";
  def accent: c("215;119;87");
  def strong: c("255;255;255");
  def muted: c("153;153;153");
  def dim: c("80;80;80");
  def level($v): if $v > 90 then c("255;107;128") elif $v > 70 then c("255;193;7") else muted end;
  def f1: (. * 10 | round) as $n | "\($n / 10 | floor).\($n % 10)";
  def f3: (. * 1000 | round) as $n | "\($n / 1000 | floor).\($n % 1000 + 1000 | tostring | .[1:])";
  def tok:
    if . < 1000 then tostring
    elif . < 1e4 then "\(. / 1e3 | f1)k"
    elif . < 1e6 then "\(. / 1e3 | round)k"
    elif . < 1e7 then "\(. / 1e6 | f1)M"
    else "\(. / 1e6 | round)M" end;
  def left: (. - now) |
    if . <= 0 then ""
    elif . >= 86400 then "/\(. / 86400 | floor)d\(. % 86400 / 3600 | floor)h"
    elif . >= 3600 then "/\(. / 3600 | floor)h\(. % 3600 / 60 | floor)m"
    else "/\(. / 60 | floor)m" end;
  def lim($n): select(.) | .used_percentage as $u |
    "\($n) \(100 - ([[$u, 0] | max, 100] | min) | round)%\(.resets_at | left)" | level($u);

  input as $s
  | (try ([first(inputs | select(.sessionId? == $s.session_id and .bridgeSessionId))] | length > 0) catch false) as $rc
  | $s
  | (.workspace.current_dir // .cwd) as $cwd
  | ($cwd | if . == $home then "~" elif startswith($home + "/") then "~" + .[($home | length):] else . end) as $path
  | (.context_window.current_usage // {}) as $cu
  | (($cu.input_tokens // 0) + ($cu.cache_creation_input_tokens // 0) + ($cu.cache_read_input_tokens // 0)) as $prompt
  | [ ($path | accent),
      ([ (.model.display_name | strong),
         ([.effort.level // empty, (select(.thinking.enabled == false) | "no-think")] | join(" ") | select(. != "") | muted)
       ] | join(" ")),
      ([ (.prompt_cache.cache_write_tokens // 0 | select(. > 0) | "W\(tok)"),
         (select($prompt > 0) | "CH\($cu.cache_read_input_tokens // 0 | . * 100 / $prompt | f1)%"),
         (.cost.total_cost_usd // empty | "$\(f3)")
       ] | join(" ") | select(. != "") | muted),
      (.context_window | (.used_percentage // null) as $p
        | "\($p // "?")%/\(.context_window_size // 0 | tok)" | level($p // 0)),
      ([ (.rate_limits.five_hour | lim("5h")), (.rate_limits.seven_day | lim("7d")) ]
        | select(length > 0) | join(" · ")),
      ("RC" | if $rc then accent else dim end)
    ] | join("  ")
' - "$HOME"/.claude/sessions/*.json 2>/dev/null

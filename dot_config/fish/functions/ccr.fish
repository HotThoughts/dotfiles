function ccr --description "Pick and resume a Claude Code session"
    tv claude-sessions
    stty sane 2>/dev/null
    true
end

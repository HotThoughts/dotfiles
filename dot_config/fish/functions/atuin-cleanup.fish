function atuin-cleanup --description "Deduplicate and prune atuin history, delete failed commands"
    set today (date +%Y-%m-%d)

    set_color cyan; echo "==> Deduplicating history before $today..."; set_color normal
    atuin history dedup --before $today --dupkeep 1
    or return

    set_color cyan; echo "==> Pruning history..."; set_color normal
    atuin history prune
    or return

    set_color cyan; echo "==> Deleting failed commands..."; set_color normal
    atuin search --delete-it-all --exclude-exit 0

    set_color green; echo "==> Done."; set_color normal
end

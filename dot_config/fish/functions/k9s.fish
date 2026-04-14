function k9s --wraps k9s --description "k9s with pane title set to current context"
    set -l ctx (kubectl config current-context 2>/dev/null)
    test -n "$ctx"; and printf '\033]0;⎈ %s\007' $ctx
    command k9s $argv
end

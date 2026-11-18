# Package cooldown for `uv pip`/`uv tool` only. Doing it for everything edits
# (and re-resolves) existing lockfiles, see ~/.zshrc.
function uv --wraps uv
    if contains -- "$argv[1]" pip tool
        UV_EXCLUDE_NEWER="7 days" command uv $argv
    else
        command uv $argv
    end
end

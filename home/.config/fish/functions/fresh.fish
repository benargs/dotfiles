# fresh <cmd>: run one command with the package cooldowns off, e.g.
# `fresh npm i @thing`
# `fresh pip install -r requirements.txt`
function fresh
    env -u PIP_UPLOADED_PRIOR_TO -u npm_config_before npm_config_min_release_age=0 \
        UV_EXCLUDE_NEWER=false pnpm_config_minimum_release_age=0 $argv
end

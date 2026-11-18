function fish_user_key_bindings
    # replaces the default ctrl-f (accept autosuggestion); right arrow and ctrl-e still do that.
    # \cf rather than ctrl-f: fish 3.x (ubuntu) only knows the old key syntax
    bind \cf 'commandline -r sessioniser; commandline -f execute'
end

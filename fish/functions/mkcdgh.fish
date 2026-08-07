function mkcdgh
    mkdir -p $argv && cd $argv && git init && git add . && gh repo create --private CodewithFreper/$argv --source . --remote origin
end

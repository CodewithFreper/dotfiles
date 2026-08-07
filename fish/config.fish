# Ruta de mis dotfiles
set -gx DOTFILES ~/dotfiles

if status is-interactive
    $DOTFILES/scripts/saludo
end

if not pgrep -u $USER ssh-agent > /dev/null
    ssh-agent -c | source
end

ssh-add -q ~/.ssh/id_ed25519 2>/dev/null

# Navegador para GitHub CLI
if type -q explorer.exe
    set -gx BROWSER explorer.exe
end

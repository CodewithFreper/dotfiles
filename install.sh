#!/bin/bash

set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "🚀 Instalando dotfiles..."

echo "📦 Actualizando repositorios..."
sudo apt update

echo "🛠️ Instalando herramientas..."
sudo apt install -y fish curl lolcat git gh nano micro

echo "🔗 Creando enlace simbólico de Fish..."

mkdir -p ~/.config

if [ -e ~/.config/fish ] && [ ! -L ~/.config/fish ]; then
    echo "📦 Guardando configuración Fish antigua..."
    mv ~/.config/fish ~/.config/fish_backup
fi

ln -sfn "$DOTFILES/fish" ~/.config/fish

echo "✅ Fish enlazado con dotfiles"

echo "🎣 Instalando Fisher..."

if ! fish -c "type -q fisher"; then
    fish -c "
        curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
        fisher install jorgebucaran/fisher
    "
else
    echo "✅ Fisher ya está instalado"
fi

echo "🧩 Instalando plugins Fish..."
fish -c "fisher update"

echo "⚙️ Configurando Git..."

read -p "👤 Nombre de Git: " GIT_NAME
read -p "📧 Correo de GitHub: " GIT_EMAIL

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main
git config --global core.editor "micro"

echo "🌐 Configurando navegador para GitHub CLI..."

if command -v explorer.exe >/dev/null 2>&1; then
    echo "✅ Usando navegador de Windows"

    grep -qxF 'export BROWSER="explorer.exe"' ~/.bashrc \
        || echo 'export BROWSER="explorer.exe"' >> ~/.bashrc
fi

echo "🐟 Cambiando shell por defecto..."

if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(which fish)" ]; then
    chsh -s "$(which fish)"
fi

echo "🔐 Configurando SSH para GitHub..."

mkdir -p ~/.ssh
chmod 700 ~/.ssh

if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "🔑 Creando clave SSH..."

    ssh-keygen -t ed25519 \
        -C "$GIT_EMAIL" \
        -f ~/.ssh/id_ed25519 \
        -N ""
else
    echo "✅ Clave SSH existente"
fi

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

echo ""
echo "📋 Se abrirá la página para añadir tu clave SSH a GitHub."

if command -v explorer.exe >/dev/null 2>&1; then
    explorer.exe https://github.com/settings/keys >/dev/null 2>&1
fi

echo ""
echo "===== COPIA ESTA CLAVE ====="
echo

cat ~/.ssh/id_ed25519.pub

echo
read -p "Pulsa ENTER cuando hayas añadido la clave a GitHub..."

git config --global url."git@github.com:".insteadOf "https://github.com/"

echo "🐙 Iniciando sesión en GitHub..."

if ! gh auth status >/dev/null 2>&1; then
    gh auth login --git-protocol ssh --web
    gh auth setup-git
else
    echo "✅ GitHub CLI ya está autenticado"
fi

echo
echo "🎉 Instalación terminada."
echo "🔄 Cierra la terminal y vuelve a abrirla para usar Fish."

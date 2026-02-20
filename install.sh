#!/bin/bash

# =============================================================================
# Skedaddle Dotfiles Installation Script
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"; }
success() { echo -e "${GREEN}✓ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
error() { echo -e "${RED}✗ $1${NC}"; }

check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run as root"
        exit 1
    fi
}

backup_file() {
    local file="$1"
    if [[ -f "$file" ]] || [[ -d "$file" ]]; then
        local backup_dir="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$backup_dir"
        cp -r "$file" "$backup_dir/"
        log "Backed up $file to $backup_dir"
    fi
}

create_link() {
    local source="$1"
    local target="$2"
    local target_dir=$(dirname "$target")
    mkdir -p "$target_dir"
    backup_file "$target"
    ln -sf "$source" "$target"
    success "Linked $source -> $target"
}

install_dependencies() {
    log "Installing dependencies..."

    if command -v pacman &> /dev/null; then
        log "Detected Arch Linux/Manjaro"
        
        sudo pacman -S --needed \
            git \
            zsh \
            hyprland \
            hyprlock \
            hypridle \
            hyprpaper \
            hyprcursor \
            hyprlang \
            hyprutils \
            hyprgraphics \
            xdg-desktop-portal-hyprland \
            kitty \
            rofi \
            waybar \
            swaylock \
            wlogout \
            neovim \
            tmux \
            dunst \
            udiskie \
            blueman \
            network-manager-applet \
            polkit \
            cliphist \
            wl-clipboard \
            brightnessctl \
            playerctl \
            pamixer \
            jq \
            curl \
            wget \
            fzf \
            btop \
            htop \
            fastfetch \
            starship \
            ttf-jetbrains-mono \
            ttf-jetbrains-mono-nerd \
            ttf-fantasque-nerd \
            ttf-cascadia-code-nerd \
            ttf-ms-fonts \
            papirus-icon-theme \
            bibata-cursor-theme \
            cava \
            python-pywal \
            swww \
            qt6ct \
            qt5ct \
            kvantum \
            gwenview \
            dolphin \
            ark \
            spectacle \
            yakuake \
            vlc \
            firefox \
            brave \
            spotify \
            steam \
            discord \
            vesktop \
            signal \
            alacritty \
            eog \
            thunar \
            mako \
            slurp \
            grim \
            wlroots \
            xdotool \
            xorg-xprop \
            xorg-xrandr \
            polkit-kde \
            python-requests \
            gcc \
            make \
            cmake \
            rustup \
            go

        success "Dependencies installed"
    elif command -v apt &> /dev/null; then
        log "Detected Debian/Ubuntu"
        
        sudo apt update && sudo apt install -y \
            git \
            zsh \
            kitty \
            rofi \
            waybar \
            swaylock \
            wlogout \
            neovim \
            tmux \
            dunst \
            udiskie \
            blueman \
            network-manager-gnome \
            libpolkit-kde-1-1 \
            cliphist \
            wl-clipboard \
            brightnessctl \
            playerctl \
            jq \
            curl \
            wget \
            fzf \
            btop \
            htop \
            fastfetch \
            fonts-jetbrains-mono \
            fonts-nerd-fonts \
            papirus-icons \
            cava \
            python3-pywal \
            qt6ct \
            qt5ct \
            gwenview \
            dolphin \
            ark \
            vlc \
            firefox \
            chromium \
            spotify-client \
            discord \
            grim \
            slurp \
            polkit-kde-1

        success "Dependencies installed"
    elif command -v dnf &> /dev/null; then
        log "Detected Fedora"
        
        sudo dnf install -y \
            git \
            zsh \
            kitty \
            rofi \
            waybar \
            swaylock \
            wlogout \
            neovim \
            tmux \
            dunst \
            udiskie \
            blueman \
            NetworkManager-applet \
            polkit \
            cliphist \
            wl-clipboard \
            brightnessctl \
            playerctl \
            jq \
            curl \
            wget \
            fzf \
            btop \
            htop \
            fastfetch \
            jetbrains-mono-fonts \
            cava \
            python3-pywal \
            qt6ct \
            qt5ct \
            gwenview \
            dolphin \
            ark \
            vlc \
            firefox \
            chromium \
            spotify \
            discord \
            grim \
            slurp

        success "Dependencies installed"
    else
        warning "Unsupported package manager. Please install dependencies manually."
    fi
}

install_yay() {
    if ! command -v yay &> /dev/null && ! command -v yay &> /dev/null; then
        log "Installing yay..."
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si
        cd ~
        success "yay installed"
    fi
}

install_oh_my_zsh() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        success "Oh My Zsh installed"
    fi
    
    if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
    fi
    
    if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
    fi
}

install_starship() {
    if ! command -v starship &> /dev/null; then
        log "Installing Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        success "Starship installed"
    fi
}

install_vimplug() {
    log "Installing vim-plug for Neovim..."
    if [[ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]]; then
        sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
        success "vim-plug installed"
    else
        success "vim-plug already installed"
    fi
}

install_fonts() {
    log "Installing fonts..."
    
    mkdir -p ~/.local/share/fonts
    
    if [[ ! -d "$HOME/.local/share/fonts/Future-Cyan" ]]; then
        cd /tmp
        git clone https://github.com/Abinashbunty/Future-Cyan.git
        cp -r Future-Cyan ~/.local/share/fonts/
        fc-cache -f -v
        success "Future-Cyan font installed"
    fi
    
    if [[ ! -d "$HOME/.local/share/fonts/JetBrainsMono" ]]; then
        cd /tmp
        wget -O JetBrainsMono.zip https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip
        unzip -o JetBrainsMono.zip -d ~/.local/share/fonts/
        fc-cache -f -v
        success "JetBrains Mono installed"
    fi
}

install_swww() {
    if ! command -v swww &> /dev/null; then
        log "Installing swww (wallpaper daemon)..."
        cd /tmp
        git clone https://github.com/LGFae/swww.git
        cd swww
        cargo build --release
        sudo cp target/release/swww /usr/local/bin/
        sudo cp target/release/swww-daemon /usr/local/bin/
        success "swww installed"
    fi
}

install_cava() {
    if ! command -v cava &> /dev/null; then
        log "Installing cava (audio visualizer)..."
        cd /tmp
        git clone https://github.com/Audio4Linux/cava.git
        cd cava
        ./autogen.sh
        ./configure
        make
        sudo make install
        success "cava installed"
    fi
}

install_hyprland() {
    if ! command -v hyprland &> /dev/null; then
        log "Installing Hyprland from source..."
        cd /tmp
        git clone --recursive https://github.com/hyprwm/Hyprland.git
        cd Hyprland
        make release
        sudo make install
        success "Hyprland installed"
    fi
}

install_dotfiles() {
    log "Installing dotfiles..."
    
    local dotfiles_dir="$HOME/dotfiles"
    
    if [[ ! -d "$dotfiles_dir" ]]; then
        error "Dotfiles directory not found at $dotfiles_dir"
        exit 1
    fi
    
    create_link "$dotfiles_dir/.gitconfig" "$HOME/.gitconfig"
    create_link "$dotfiles_dir/.tmux.conf" "$HOME/.tmux.conf"
    create_link "$dotfiles_dir/.p10k.zsh" "$HOME/.p10k.zsh"
    create_link "$dotfiles_dir/.gtkrc-2.0" "$HOME/.gtkrc-2.0"
    
    create_link "$dotfiles_dir/zsh/.zshrc" "$HOME/.zshrc"
    
    create_link "$dotfiles_dir/hyde/.config/hyde" "$HOME/.config/hyde"
    create_link "$dotfiles_dir/hypr/.config/hypr" "$HOME/.config/hypr"
    create_link "$dotfiles_dir/kitty/.config/kitty" "$HOME/.config/kitty"
    create_link "$dotfiles_dir/nvim/.config/nvim" "$HOME/.config/nvim"
    create_link "$dotfiles_dir/rofi/.config/rofi" "$HOME/.config/rofi"
    create_link "$dotfiles_dir/waybar/.config/waybar" "$HOME/.config/waybar"
    create_link "$dotfiles_dir/swaylock/.config/swaylock" "$HOME/.config/swaylock"
    create_link "$dotfiles_dir/wlogout/.config/wlogout" "$HOME/.config/wlogout"
    
    if ! grep -q ".local/bin" "$HOME/.zshrc" 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
    fi
}

copy_scripts() {
    log "Copying user scripts to ~/.local/share/bin..."
    
    local scripts_target="$HOME/.local/share/bin"
    mkdir -p "$scripts_target"
    
    if [[ -d "$HOME/dotfiles/hypr/.config/hypr/scripts" ]]; then
        cp -r "$HOME/dotfiles/hypr/.config/hypr/scripts"/* "$scripts_target/" 2>/dev/null || true
    fi
    
    if [[ -d "$HOME/dotfiles/scripts" ]]; then
        cp -r "$HOME/dotfiles/scripts"/* "$scripts_target/" 2>/dev/null || true
    fi
    
    chmod +x "$scripts_target"/*.sh 2>/dev/null || true
    chmod +x "$scripts_target"/*.py 2>/dev/null || true
    
    success "Scripts copied to $scripts_target"
}

set_shell() {
    if [[ "$SHELL" != *"zsh"* ]]; then
        log "Changing default shell to ZSH..."
        chsh -s "$(which zsh)" || warning "Failed to change shell. Please run 'chsh -s \$(which zsh)' manually"
    else
        success "ZSH is already the default shell"
    fi
}

install_cursor() {
    log "Setting cursor..."
    hyprctl setcursor Bibata-Modern-Ice 20 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-size 20 2>/dev/null || true
}

main() {
    log "Starting Skedaddle dotfiles installation..."
    
    check_root
    
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/.dotfiles_backup"
    mkdir -p "$HOME/.local/share/bin"
    
    install_dependencies
    install_oh_my_zsh
    install_starship
    install_vimplug
    install_fonts
    install_dotfiles
    copy_scripts
    set_shell
    install_cursor
    
    log "Installation complete!"
    log "Please restart your terminal or run 'source ~/.zshrc' to apply changes"
    log "Run :PlugInstall in Neovim to install plugins"
    log "Start Hyprland with 'Hyprland' or 'startx' depending on your setup"
    
    success "Skedaddle dotfiles installed successfully!"
}

trap 'error "Installation interrupted"; exit 1' INT

main "$@"

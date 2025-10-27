#!/usr/bin/env zsh

# Optimized font installation for dotfiles
# This script handles nerd font installation for Linux systems

install_nerd_fonts() {
    local nerd_font='https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3'

    # Font mapping: URL -> filename pattern
    typeset -A fonts=(
        "${nerd_font}/DejaVuSansMono.zip" "DejaVu Sans Mono Nerd Font Complete.ttf"
        "${nerd_font}/DroidSansMono.zip" "Droid Sans Mono Nerd Font Complete.otf"
        "${nerd_font}/Go-Mono.zip" "Go Mono Nerd Font Complete.ttf"
        "${nerd_font}/Hack.zip" "Hack Regular Nerd Font Complete Mono.ttf"
        "${nerd_font}/FiraCode.zip" "Fira Code Regular Nerd Font Complete Mono.ttf"
        "${nerd_font}/JetBrainsMono.zip" "JetBrains Mono Regular Nerd Font Complete Mono.ttf"
        "${nerd_font}/Meslo.zip" "Meslo LG S Regular Nerd Font Complete Mono.ttf"
        "${nerd_font}/SourceCodePro.zip" "Sauce Code Pro Nerd Font Complete Mono.ttf"
        "https://github.com/googlefonts/noto-emoji/raw/main/fonts/NotoColorEmoji.ttf" "NotoColorEmoji.ttf"
    )

    local fonts_dir="${HOME}/.local/share/fonts"
    local install_fonts=()

    # Ensure fonts directory exists
    mkdir -p "$fonts_dir"

    # Check which fonts need to be installed
    for font_url in "${(@k)fonts}"; do
        local font_pattern="${fonts[$font_url]}"
        if [[ -z "$(find "$fonts_dir" -name "$font_pattern" -print -quit 2>/dev/null)" ]]; then
            install_fonts+=("$font_url")
        fi
    done

    # Install missing fonts
    if [[ ${#install_fonts[@]} -gt 0 ]]; then
        print_status info "Installing nerd fonts:"
        for font_url in "${install_fonts[@]}"; do
            echo "  ${fonts[$font_url]}"
        done

        for font_url in "${install_fonts[@]}"; do
            echo "Downloading $font_url"
            local font_file=$(basename "${font_url}")

            if ! wget -q "$font_url" -O "$font_file"; then
                print_status warning "Failed to download $font_url"
                continue
            fi

            if [[ "$font_file" == *".zip" ]]; then
                if command -v unzip >/dev/null 2>&1; then
                    unzip -o "$font_file" -d "$fonts_dir" && rm "$font_file"
                else
                    print_status warning "unzip not available, skipping $font_file"
                    rm "$font_file"
                fi
            else
                mv "$font_file" "$fonts_dir"
            fi
        done

        # Clean up Windows font variants
        find "$fonts_dir" -name '*Windows Compatible*' -delete 2>/dev/null || true

        # Update font cache
        if command -v fc-cache >/dev/null 2>&1; then
            fc-cache -fv
        fi
    else
        print_status success "All nerd fonts already installed."
    fi
}

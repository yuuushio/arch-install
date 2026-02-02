#!/usr/bin/env bash
set -euo pipefail

sudo pacman -Syu --noconfirm

# Minimal niri adjuncts (Wayland-native)
sudo pacman -S --needed --noconfirm \
  foot \
  fuzzel \
  mako \
  waybar \
  wl-clipboard \
  grim slurp \
  swaylock swayidle \
  gammastep \
  brightnessctl \
  xwayland-satellite

# niri will load ~/.config/niri/config.kdl (and can auto-create it). :contentReference[oaicite:13]{index=13}
mkdir -p "$HOME/.config/niri"

# Seed config from the packaged default if it does not exist.
# Arch's niri package ships /usr/share/doc/niri/default-config.kdl. :contentReference[oaicite:14]{index=14}
if [[ ! -f "$HOME/.config/niri/config.kdl" ]]; then
  cp /usr/share/doc/niri/default-config.kdl "$HOME/.config/niri/config.kdl"
fi

# Add an include for local overrides, idempotently.
if ! grep -q '^include "local.kdl"' "$HOME/.config/niri/config.kdl"; then
  tmp="$(mktemp)"
  {
    echo 'include "local.kdl"'
    cat "$HOME/.config/niri/config.kdl"
  } > "$tmp"
  mv "$tmp" "$HOME/.config/niri/config.kdl"
fi

# Local overrides: terminal + a few pragmatic binds.
cat > "$HOME/.config/niri/local.kdl" <<'EOF'
binds {
  // Terminal
  Mod+T { spawn "foot"; }

  // Launcher
  Mod+D { spawn "fuzzel"; }

  // Lock
  Mod+L { spawn "swaylock"; }

  // Screenshot to a file via grim+slurp (Wayland-native). :contentReference[oaicite:15]{index=15}
  Print { spawn "sh" "-lc" "grim -g \"$(slurp)\" \"$HOME/Pictures/screen-$(date +%F-%H%M%S).png\""; }
}

spawn-at-startup "polkit-gnome-authentication-agent-1"
spawn-at-startup "gammastep"
EOF

printf '\nNotes:\n'
printf '  - mako is D-Bus activated; no service enablement is required.\n'
printf '  - If you dislike X11 compatibility, remove xwayland-satellite.\n'
printf '  - Validate config with: niri validate\n'

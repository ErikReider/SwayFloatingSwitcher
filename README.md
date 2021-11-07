# SwayFloatingSwitcher

A simple alt-tab daemon for switching between floating windows with Alt+Tab.

## Important inforamtion

At the time of writing releasing the left Alt key hides the switcher

## Install

Arch:
The package is available on the [AUR](https://aur.archlinux.org/packages/swayfloatingswitcher-git/)

Other:

```zsh
meson build
ninja -C build
meson install -C build
```

## Sway Usage

```ini
# Switcher Daemon
exec swayfloatingswitcher

# Switch between programs. MUST USE ALT!
bindsym Alt+Tab exec swayfloatingswitcher-client --next
bindsym Alt+Shift+Tab exec swayfloatingswitcher-client --previous
```


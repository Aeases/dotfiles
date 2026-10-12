#!/usr/bin/env zsh
# Idle brightness for hypridle.
#   soft:    before the lock, dim to 70% of the current level (saves it for `restore`)
#   deep:    only while locked, drop to near-black just before the screen turns off
#   restore: back to the level saved by `soft`, only if `soft` actually dimmed
#   kbd-off / kbd-restore: keyboard backlight

noctalia=~/repos/noctalia-shell/build/noctalia
kbd=chromeos::kbd_backlight

dimmed=$XDG_RUNTIME_DIR/idle-dimmed

# Noctalia's brightness OSD fires on any backlight change, so hide OSDs around ours.
# The override is runtime-only; the sleep lets its inotify watcher see the change first.
quiet() {
  $noctalia msg osd-disable >/dev/null 2>&1
  "$@"
  sleep 0.3
  $noctalia msg osd-enable >/dev/null 2>&1
}

case $1 in
  soft)
    quiet brightnessctl -q -s set $(( $(brightnessctl g 2>/dev/null) * 7 / 10 ))
    touch $dimmed
    ;;
  deep)
    # Noctalia sets the logind LockedHint while its lock screen is up.
    [[ "$(loginctl show-session auto -p LockedHint --value)" == yes ]] || exit 0
    [[ -f $dimmed ]] || exit 0   # nothing saved to come back to
    quiet brightnessctl -q set 10   # no -s: keep the pre-dim level saved by `soft`
    ;;
  restore)
    rm $dimmed 2>/dev/null || exit 0   # also claims it: two listeners restore on resume
    quiet brightnessctl -q -r
    ;;
  kbd-off)
    quiet brightnessctl -q -sd $kbd set 0
    ;;
  kbd-restore)
    quiet brightnessctl -q -rd $kbd
    ;;
esac

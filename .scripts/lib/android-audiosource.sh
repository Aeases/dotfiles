ACTION="$1"
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
export LOCK_FILE="/tmp/phone_audiosource.lock"


if [ "$ACTION" = "remove" ]; then
    rm /tmp/phone_audiosource.lock
    notify-send "Audiosource" "Disconnected" --icon=smartphone
    notify-send "Audiosource" "$(printenv)" --icon=smartphone
    pkill -f audiosource.sh
    exit 0
fi

if [ -f "$LOCK_FILE" ]; then
    exit 0
fi

touch "$LOCK_FILE"

if [ "$ACTION" = "add" ]; then
    notify-send "Audiosource" "Now listening for audio source on phone" --icon=smartphone
    bash ("/home/$(whoami)/.scripts/audiosource.sh run")
fi

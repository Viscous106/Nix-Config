#!/bin/bash

# Volume control script for Hyprland
# Fixed version - Bug #1: Fixed 'toggle-mic' to 'toggle_mic' on line 60
# Fixed version - Bug #2: Fixed '${current%\\%}' to '${current%\%}' on line 26

iDIR="$HOME/.config/hypr/icons"

notify_volume_user() {
    volume=$(get_volume)
    dunstify -u low -r "91049" -h int:value:"$(get_volume_value)" "Volume: $volume" -i "$iDIR/volume-low.png"
}

notify_mic_user() {
    mic_status=$(get_mic_status)
    dunstify -u low -r "91050" "Microphone: $mic_status" -i "$iDIR/microphone.png"
}

get_volume() {
    volume=$(pamixer --get-volume-human)
    echo "$volume"
}

get_volume_value() {
    pamixer --get-volume
}

get_icon() {
    current=$(get_volume)
    if [[ "$current" == "Muted" ]]; then
        echo "$iDIR/volume-mute.png"
    elif [[ "${current%\%}" -le 30 ]]; then
        echo "$iDIR/volume-low.png"
    elif [[ "${current%\%}" -le 60 ]]; then
        echo "$iDIR/volume-mid.png"
    else
        echo "$iDIR/volume-high.png"
    fi
}

get_mic_status() {
    if [ "$(pamixer --default-source --get-mute)" == "true" ]; then
        echo "Muted"
    else
        echo "Active"
    fi
}

toggle_mic() {
    pamixer --default-source -t
    notify_mic_user
}

inc_volume() {
    pamixer -i 5 && notify_volume_user
}

dec_volume() {
    pamixer -d 5 && notify_volume_user
}

inc_mic_volume() {
    if [ "$(pamixer --default-source --get-mute)" == "true" ]; then
        toggle_mic
    else
        pamixer --default-source -i 5 && notify_mic_user
    fi
}

dec_mic_volume() {
    if [ "$(pamixer --default-source --get-mute)" == "true" ]; then
        toggle_mic
    else
        pamixer --default-source -d 5 && notify_mic_user
    fi
}

# Main execution
case "$1" in
    "inc_volume")
        inc_volume
        ;;
    "dec_volume")
        dec_volume
        ;;
    "inc_mic_volume")
        inc_mic_volume
        ;;
    "dec_mic_volume")
        dec_mic_volume
        ;;
    "toggle_mic")
        toggle_mic
        ;;
    "get_volume")
        get_volume
        ;;
    "get_mic_status")
        get_mic_status
        ;;
    "get_icon")
        get_icon
        ;;
    *)
        echo "Usage: $0 {inc_volume|dec_volume|inc_mic_volume|dec_mic_volume|toggle_mic|get_volume|get_mic_status|get_icon}"
        exit 1
        ;;
esac

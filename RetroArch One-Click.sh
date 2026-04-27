#!/bin/bash

# =======================================================
# RetroArch One-Click Set Up v1.0
# by djparent
# =======================================================

# Copyright (c) 2026 djparent
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

if [ "$(id -u)" -ne 0 ]; then
    exec sudo -- "$0" "$@"
fi

CURR_TTY="/dev/tty1"

printf "\e[?25l" > "$CURR_TTY"
printf "\033[H\033[2J" > "$CURR_TTY"
printf "=========================================================\n" > "$CURR_TTY"
printf "            RetroArch One-Click Settings\n" > "$CURR_TTY"
printf "                    by djparent\n" > "$CURR_TTY"
printf "=========================================================\n" > "$CURR_TTY"
printf "Starting, please wait..." > "$CURR_TTY"
sleep 0.5

set_cfg() {
    local key="$1" val="$2" file="$3"
    if grep -q "^${key} =" "$file"; then
        sed -i "s/^${key} = .*/${key} = \"${val}\"/" "$file"
    else
        echo "${key} = \"${val}\"" >> "$file"
    fi
    printf "  Setting %-40s = %s\n" "$key" "$val" > "$CURR_TTY"
	sleep 0.1
}

CONFIGS=(
    /home/ark/.config/retroarch/retroarch.cfg
    /home/ark/.config/retroarch32/retroarch.cfg
)

declare -A SETTINGS=(
    [config_save_on_exit]="true"
    [sort_savefiles_by_core_name]="true"
    [sort_savestates_by_core_name]="true"
    [sort_savefiles_by_content_enable]="true"
    [sort_savestates_by_content_enable]="true"
    [sort_screenshots_by_content_enable]="true"
    [savefiles_in_content_dir]="false"
    [savestates_in_content_dir]="false"
    [screenshots_in_content_dir]="false"
    [savestate_auto_save]="true"
    [savestate_auto_load]="true"
    [aspect_ratio_index]="22"
    [menu_driver]="ozone"
    [input_menu_toggle_gamepad_combo]="9"
    [input_exit_emulator_gamepad_combo]="2"
    [video_frame_delay_auto]="true"
)

for cfg in "${CONFIGS[@]}"; do
    printf "\nApplying to: %s\n" "$cfg" > "$CURR_TTY"
    for key in "${!SETTINGS[@]}"; do
        set_cfg "$key" "${SETTINGS[$key]}" "$cfg"
    done
done

printf "\n------------------------------------\n" > "$CURR_TTY"
printf "Done.\n" > "$CURR_TTY"

sleep 1
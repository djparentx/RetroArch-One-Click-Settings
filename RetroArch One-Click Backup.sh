#!/bin/bash

# ========================================
# RetroArch One-Click Backup v1.0
# by djparent
# ========================================

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

# Quick Reference Indexes
# =======================
# menu_driver values
# ------------------
# ozone
# glui
# rgui
# xmb

# gamepad_combo values
# --------------------------------------
# 0: None
# 1: Down + Y + L1 + R1
# 2: L3 + R3
# 3: L1 + R1 + Start + Select
# 4: Start + Select
# 5: L3 + R1
# 6: L1 + R1
# 7: Hold Start (2 seconds)
# 8: Hold Select (2 seconds)
# 9: Down + Select
# 10: L2 + R2

# aspect_ratio_index
# ------------------
# 0:	4:3				Standard full screen for most retro consoles.
# 1:	16:9			Modern widescreen displays.
# 2:	16:10			Common for many PC monitors and handhelds.
# 3:	16:15			Often used for NES (pixel aspect ratio).
# 4:	1:1				Perfect square.
# 5:	2:1				Extra wide.
# 6:	3:2				Native ratio for GBA and some handheld screens.
# 7:	3:4				TATE/Portrait mode for arcade games.
# 8:	4:1				Extremely wide.
# 9:	4:4				Alternative square mapping.
# 10:	5:4				Common older LCD monitor ratio.
# 11:	6:5				Alternative NES/SNES ratio.
# 12:	7:9				Vertical arcade orientation.
# 13:	8:3				Ultra-wide.
# 14:	8:7				Original pixel aspect ratio for SNES.
# 15:	19:12			Specialized widescreen variant.
# 16:	19:14			Specialized vertical variant.
# 17:	30:17			Specific wide format.
# 18:	32:9			Super ultra-wide monitors.
# 19:	10:9			Common Game Boy (DMG) ratio.
# 20:					Config	Uses the float value from video_aspect_ratio.
# 21:	1:1 PAR			Square Pixel aspect ratio.
# 22:	Core Provided	Uses the aspect ratio suggested by the emulator core.
# 23:	Custom			Allows manual sizing via custom_viewport settings.

# =======================================================
# Root privileges check
# =======================================================
if [ "$(id -u)" -ne 0 ]; then
    exec sudo -- "$0" "$@"
fi

# =======================================================
# Initialization
# =======================================================
export TERM=linux

# =======================================================
# Variables
# =======================================================
GPTOKEYB_PID=""
CURR_TTY="/dev/tty1"
BASE_DIR="/roms/backup"
TMP_KEYS="/tmp/keys.gptk.$$"
BACKUP_DIR="$BASE_DIR/RetroArch"
ZIP_DIR="$BASE_DIR/RetroArch_Backup.zip"
RETRO64_DIR="/home/ark/.config/retroarch"
RETRO32_DIR="/home/ark/.config/retroarch32"

if [ -f "$ES_CONF" ]; then
    ES_DETECTED=$(grep "name=\"Language\"" "$ES_CONF" | grep -o 'value="[^"]*"' | cut -d '"' -f 2)
    [ -n "$ES_DETECTED" ] && SYSTEM_LANG="$ES_DETECTED"
fi
# -------------------------------------------------------
# Default configuration : EN
# -------------------------------------------------------
T_BACKTITLE="RetroArch One-Click Backup by djparent"
T_MAIN_TITLE="Main Menu"
T_STARTING="Starting."
T_EXIT="Exit"
T_BACKUP="Backup RetroArch Settings"
T_RESTORE="Restore RetroArch Settings"
T_ONECLICK="Apply One-Click Settings"
T_ONE_TITLE="Settings Successful"
T_ONE_MSG="RetroArch settings have been applied."
T_NO_TITLE="No Backups Available"
T_NO_MSG="Nothing to Restore"
T_REST_TITLE="Restoration Successful"
T_REST_MSG="RetroArch settings have been restored."
T_BACKUP_TITLE="Backup Successful"
T_BACKUP_MSG="RetroArch settings have been backed up to:\n/roms/backup/RetroArch_Backup.zip."
T_WAIT="Please wait..."

# --- FRANÇAIS (FR) --- 
if [[ "$SYSTEM_LANG" == *"fr"* ]]; then
T_BACKTITLE="Sauvegarde RetroArch One-Click par djparent"
T_MAIN_TITLE="Menu principal"
T_STARTING="Demarrage."
T_EXIT="Quitter"
T_BACKUP="Sauvegarder les parametres RetroArch"
T_RESTORE="Restaurer les parametres RetroArch"
T_ONECLICK="Appliquer les parametres One-Click"
T_ONE_TITLE="Parametres appliques"
T_ONE_MSG="Les parametres RetroArch ont ete appliques."
T_NO_TITLE="Aucune sauvegarde disponible"
T_NO_MSG="Rien a restaurer"
T_REST_TITLE="Restauration reussie"
T_REST_MSG="Les parametres RetroArch ont ete restaures."
T_BACKUP_TITLE="Sauvegarde reussie"
T_BACKUP_MSG="Les parametres RetroArch ont ete sauvegardes dans :\n/roms/backup/RetroArch_Backup.zip."
T_WAIT="Veuillez patienter..."

# --- ESPAÑOL (ES) ---
elif [[ "$SYSTEM_LANG" == *"es"* ]]; then
T_BACKTITLE="Copia de seguridad RetroArch One-Click por djparent"
T_MAIN_TITLE="Menu principal"
T_STARTING="Iniciando."
T_EXIT="Salir"
T_BACKUP="Guardar configuracion de RetroArch"
T_RESTORE="Restaurar configuracion de RetroArch"
T_ONECLICK="Aplicar configuracion One-Click"
T_ONE_TITLE="Configuracion aplicada"
T_ONE_MSG="La configuracion de RetroArch ha sido aplicada."
T_NO_TITLE="No hay copias disponibles"
T_NO_MSG="Nada que restaurar"
T_REST_TITLE="Restauracion completada"
T_REST_MSG="La configuracion de RetroArch ha sido restaurada."
T_BACKUP_TITLE="Copia completada"
T_BACKUP_MSG="La configuracion de RetroArch se ha guardado en:\n/roms/backup/RetroArch_Backup.zip."
T_WAIT="Por favor espere..."

# --- PORTUGUÊS (PT) ---
elif [[ "$SYSTEM_LANG" == *"pt"* ]]; then
T_BACKTITLE="Backup RetroArch One-Click por djparent"
T_MAIN_TITLE="Menu principal"
T_STARTING="Iniciando."
T_EXIT="Sair"
T_BACKUP="Fazer backup das configuracoes do RetroArch"
T_RESTORE="Restaurar configuracoes do RetroArch"
T_ONECLICK="Aplicar configuracoes One-Click"
T_ONE_TITLE="Configuracoes aplicadas"
T_ONE_MSG="As configuracoes do RetroArch foram aplicadas."
T_NO_TITLE="Nenhum backup disponivel"
T_NO_MSG="Nada para restaurar"
T_REST_TITLE="Restauracao concluida"
T_REST_MSG="As configuracoes do RetroArch foram restauradas."
T_BACKUP_TITLE="Backup concluido"
T_BACKUP_MSG="As configuracoes do RetroArch foram salvas em:\n/roms/backup/RetroArch_Backup.zip."
T_WAIT="Por favor aguarde..."

# --- ITALIANO (IT) ---
elif [[ "$SYSTEM_LANG" == *"it"* ]]; then
T_BACKTITLE="Backup RetroArch One-Click di djparent"
T_MAIN_TITLE="Menu principale"
T_STARTING="Avvio."
T_EXIT="Esci"
T_BACKUP="Esegui backup impostazioni RetroArch"
T_RESTORE="Ripristina impostazioni RetroArch"
T_ONECLICK="Applica impostazioni One-Click"
T_ONE_TITLE="Impostazioni applicate"
T_ONE_MSG="Le impostazioni di RetroArch sono state applicate."
T_NO_TITLE="Nessun backup disponibile"
T_NO_MSG="Niente da ripristinare"
T_REST_TITLE="Ripristino completato"
T_REST_MSG="Le impostazioni di RetroArch sono state ripristinate."
T_BACKUP_TITLE="Backup completato"
T_BACKUP_MSG="Le impostazioni di RetroArch sono state salvate in:\n/roms/backup/RetroArch_Backup.zip."
T_WAIT="Attendere..."

# --- DEUTSCH (DE) ---
elif [[ "$SYSTEM_LANG" == *"de"* ]]; then
T_BACKTITLE="RetroArch One-Click Backup von djparent"
T_MAIN_TITLE="Hauptmenu"
T_STARTING="Startet."
T_EXIT="Beenden"
T_BACKUP="RetroArch Einstellungen sichern"
T_RESTORE="RetroArch Einstellungen wiederherstellen"
T_ONECLICK="One-Click Einstellungen anwenden"
T_ONE_TITLE="Einstellungen erfolgreich"
T_ONE_MSG="RetroArch Einstellungen wurden angewendet."
T_NO_TITLE="Keine Backups verfuegbar"
T_NO_MSG="Nichts zum Wiederherstellen"
T_REST_TITLE="Wiederherstellung erfolgreich"
T_REST_MSG="RetroArch Einstellungen wurden wiederhergestellt."
T_BACKUP_TITLE="Backup erfolgreich"
T_BACKUP_MSG="RetroArch Einstellungen wurden nach:\n/roms/backup/RetroArch_Backup.zip gesichert."
T_WAIT="Bitte warten..."

# --- POLSKI (PL) ---
elif [[ "$SYSTEM_LANG" == *"pl"* ]]; then
T_BACKTITLE="Backup RetroArch One-Click od djparent"
T_MAIN_TITLE="Menu glowne"
T_STARTING="Uruchamianie."
T_EXIT="Wyjscie"
T_BACKUP="Utworz kopie ustawien RetroArch"
T_RESTORE="Przywroc ustawienia RetroArch"
T_ONECLICK="Zastosuj ustawienia One-Click"
T_ONE_TITLE="Ustawienia zastosowane"
T_ONE_MSG="Ustawienia RetroArch zostaly zastosowane."
T_NO_TITLE="Brak kopii zapasowych"
T_NO_MSG="Nic do przywrocenia"
T_REST_TITLE="Przywracanie zakonczone"
T_REST_MSG="Ustawienia RetroArch zostaly przywrocone."
T_BACKUP_TITLE="Kopia wykonana"
T_BACKUP_MSG="Ustawienia RetroArch zapisano w:\n/roms/backup/RetroArch_Backup.zip."
T_WAIT="Prosze czekac..."
fi

# =======================================================
# Start gamepad input
# =======================================================
Start_GPTKeyb() {
    pkill -9 -f gptokeyb 2>/dev/null || true
    if [ -n "${GPTOKEYB_PID:-}" ]; then
        kill "$GPTOKEYB_PID" 2>/dev/null
    fi
    sleep 0.1
	/opt/inttools/gptokeyb -1 "$0" -c "$TMP_KEYS" > /dev/null 2>&1 &
    GPTOKEYB_PID=$!
}

# =======================================================
# Stop gamepad input
# =======================================================
Stop_GPTKeyb() {
    if [ -n "$GPTOKEYB_PID" ]; then
        kill "$GPTOKEYB_PID" 2>/dev/null
        GPTOKEYB_PID=""
    fi
}

# =======================================================
# Font Selection
# =======================================================
ORIGINAL_FONT=$(setfont -v 2>&1 | grep -o '/.*\.psf.*')
setfont /usr/share/consolefonts/Lat7-TerminusBold22x11.psf.gz

# =======================================================
# Display Management
# =======================================================
printf "\e[?25l" > "$CURR_TTY"
dialog --clear
Stop_GPTKeyb
pgrep -f osk.py | xargs kill -9
printf "\033[H\033[2J" > "$CURR_TTY"
printf "=========================================================\n\n" > "$CURR_TTY"
printf "      $T_BACKTITLE\n\n" > "$CURR_TTY"
printf "=========================================================\n" > "$CURR_TTY"
printf "$T_STARTING $T_WAIT" > "$CURR_TTY"
sleep 0.5

# =======================================================
# Exit the script
# =======================================================
Exit_Menu() {
	trap - EXIT
    printf "\033[H\033[2J" > "$CURR_TTY"
    printf "\e[?25h" > "$CURR_TTY"
	Stop_GPTKeyb
    rm -f "$TMP_KEYS"
    if [[ ! -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
        [ -n "$ORIGINAL_FONT" ] && setfont "$ORIGINAL_FONT"
    fi

    exit 0
}

# =======================================================
# One-Click RetroArch Settings
# =======================================================
OneClick() {
	dialog --backtitle "$T_BACKTITLE" --infobox "\n    $T_WAIT" 5 40 2>&1 > "$CURR_TTY"
	
	set_cfg() {
		local key="$1" val="$2" file="$3"
		if grep -q "^${key} =" "$file"; then
			sed -i "s/^${key} = .*/${key} = \"${val}\"/" "$file"
		else
			echo "${key} = \"${val}\"" >> "$file"
		fi
	}

	local -a CONFIGS=(
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
		[input_menu_toggle_gamepad_combo]="8"
		[input_quit_gamepad_combo]="4"
		[video_frame_delay_auto]="true"
)

	for cfg in "${CONFIGS[@]}"; do
		for key in "${!SETTINGS[@]}"; do
			set_cfg "$key" "${SETTINGS[$key]}" "$cfg"
		done
	done

	dialog --backtitle "$T_BACKTITLE" \
		   --title "$T_ONE_TITLE" \
		   --msgbox "$T_ONE_MSG" \
		   7 40 2>&1 > "$CURR_TTY"
	
	unset -f set_cfg
}

# =======================================================
# Restore RetroArch Settings
# =======================================================
Restore() {
	if [[ ! -f "$ZIP_DIR" ]]; then
		dialog --backtitle "T_BACKTITLE" \
			   --title "$T_NO_TITLE" \
			   --msgbox "$T_NO_MSG" \
			   7 40 2>&1 > "$CURR_TTY"
		return
	fi
	
	dialog --backtitle "$T_BACKTITLE" --infobox "\n    $T_WAIT" 5 40 2>&1 > "$CURR_TTY"
	
	unzip -q "$ZIP_DIR" -d "$BASE_DIR"
	
	cp -a "$BACKUP_DIR/retroarch.bak" "$RETRO64_DIR/retroarch.cfg"
	cp -a "$BACKUP_DIR/retroarch32.bak" "$RETRO32_DIR/retroarch.cfg"
	cp -a "$BACKUP_DIR/retroarch-core-options.bak" "$RETRO64_DIR/retroarch-core-options.cfg"
	cp -a "$BACKUP_DIR/retroarch-core-options32.bak" "$RETRO32_DIR/retroarch-core-options.cfg"	
	
	cp -a "$BACKUP_DIR/config/." "$RETRO64_DIR/config/"
	cp -a "$BACKUP_DIR/config32/." "$RETRO32_DIR/config/"
	cp -a "$BACKUP_DIR/saves/." "$RETRO64_DIR/saves/"
	cp -a "$BACKUP_DIR/saves32/." "$RETRO32_DIR/saves/"
	cp -a "$BACKUP_DIR/states/." "$RETRO64_DIR/states/"
	cp -a "$BACKUP_DIR/states32/." "$RETRO32_DIR/states/"
	
	rm -rf "$BACKUP_DIR"
	
	chown -R ark:ark "$RETRO32_DIR"
	chown -R ark:ark "$RETRO64_DIR"
	
	dialog --backtitle "$T_BACKTITLE" \
		   --title "$T_REST_TITLE" \
		   --msgbox "$T_REST_MSG" \
		   7 40 2>&1 > "$CURR_TTY"	
}

# =======================================================
# Backup RetroArch Settings
# =======================================================
Backup() {
	dialog --backtitle "$T_BACKTITLE" --infobox "\n    $T_WAIT" 5 40 2>&1 > "$CURR_TTY"
	
	rm -f "$ZIP_DIR"
	
	mkdir -p "$BACKUP_DIR" \
			 "$BACKUP_DIR/config" \
			 "$BACKUP_DIR/config32" \
			 "$BACKUP_DIR/saves" \
			 "$BACKUP_DIR/saves32" \
			 "$BACKUP_DIR/states" \
			 "$BACKUP_DIR/states32"
	
	rm -rf "$BACKUP_DIR/config"/* \
			 "$BACKUP_DIR/config32"/* \
			 "$BACKUP_DIR/saves"/* \
			 "$BACKUP_DIR/saves32"/* \
			 "$BACKUP_DIR/states"/* \
			 "$BACKUP_DIR/states32"/*
			 
	cp -a "$RETRO64_DIR/retroarch.cfg" "$BACKUP_DIR/retroarch.bak"
	cp -a "$RETRO32_DIR/retroarch.cfg" "$BACKUP_DIR/retroarch32.bak"
	cp -a "$RETRO64_DIR/retroarch-core-options.cfg" "$BACKUP_DIR/retroarch-core-options.bak"
	cp -a "$RETRO32_DIR/retroarch-core-options.cfg" "$BACKUP_DIR/retroarch-core-options32.bak"
	
	cp -a "$RETRO64_DIR/config/." "$BACKUP_DIR/config/"
	cp -a "$RETRO32_DIR/config/." "$BACKUP_DIR/config32/"
	cp -a "$RETRO64_DIR/saves/." "$BACKUP_DIR/saves/"
	cp -a "$RETRO32_DIR/saves/." "$BACKUP_DIR/saves32/"
	cp -a "$RETRO64_DIR/states/." "$BACKUP_DIR/states/"
	cp -a "$RETRO32_DIR/states/." "$BACKUP_DIR/states32/"
	
(
    cd "$BASE_DIR" || return
    zip -rq "RetroArch_Backup.zip" "RetroArch" || return
)
	
	rm -rf "$BACKUP_DIR"
	
	dialog --backtitle "$T_BACKTITLE" \
		   --title "$T_BACKUP_TITLE" \
		   --msgbox "$T_BACKUP_MSG" \
		   8 45 2>&1 > "$CURR_TTY"
}

# =======================================================
# Main Menu dialog
# =======================================================
Main_Menu() {
	while true; do
		# --- keep gptokeyb alive ---
		if [[ -z $(pgrep -f gptokeyb) ]]; then
			Start_GPTKeyb
		fi
		
		local CHOICE
		CHOICE=$(dialog \
			--clear \
			--colors \
			--no-collapse \
			--cancel-label "$T_EXIT" \
			--backtitle "$T_BACKTITLE" \
			--title "$T_MAIN_TITLE" \
			--menu "$T_STATUS" \
			9 45 6 \
			"1" "$T_BACKUP" \
            "2" "$T_RESTORE" \
			"3" "$T_ONECLICK" \
            2>&1 > "$CURR_TTY")
			
			[[ $? -ne 0 ]] && Exit_Menu

			case "$CHOICE" in
				1) Backup ;;
				2) Restore ;;
				3) OneClick ;;
			esac
	done
}

# =======================================================
# Gamepad Setup
# =======================================================
export SDL_GAMECONTROLLERCONFIG_FILE="/opt/inttools/gamecontrollerdb.txt"
chmod 666 /dev/uinput
cp /opt/inttools/keys.gptk "$TMP_KEYS"
if grep -q '^b = backspace' "$TMP_KEYS"; then
    sed -i 's/^b = .*/b = esc/' "$TMP_KEYS"
    sed -i 's/^a = .*/a = enter/' "$TMP_KEYS"
fi
Start_GPTKeyb

# =======================================================
# Main Execution
# =======================================================
printf "\033[H\033[2J" > "$CURR_TTY"
dialog --clear
trap Exit_Menu EXIT

Main_Menu

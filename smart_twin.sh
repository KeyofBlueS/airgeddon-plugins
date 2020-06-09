#!/usr/bin/env bash

# Smart-Twin airgeddon plugin

# Version:    0.0.1
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/airgeddon-plugins
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

# airgeddon Repository: https://github.com/v1s1t0r1sh3r3/airgeddon

#Global shellcheck disabled warnings
#shellcheck disable=SC2034,SC2154

plugin_name="Smart-Twin"
plugin_description="Enable/Disable Evil Twin Access Point based on Target availability. Only work in Pursuit Mode"
plugin_author="KeyofBlueS"

plugin_enabled=1

plugin_minimum_ag_affected_version="10.20"
plugin_maximum_ag_affected_version=""
plugin_distros_supported=("*")

#Check Target availability and enable/disable Evil Twin AP accordingly
function manage_evil_twin_ap() {

	debug_print

	target_check=1
	access_point_down=0
	ap_timeout=20

	while true; do
		current_time="$(date "+%Y%m%d%H%M%S")"
		if grep -Eq "^${bssid}, " "${tmpdir}dos_pm-01.csv" > /dev/null 2>&1; then
			lastseen="$(grep -E "^${bssid}, " "${tmpdir}dos_pm-01.csv" | awk -F', ' '{print $3}' | tr -d '\-\ \:')"
			elapsed_time="$(expr "${current_time}" - "${lastseen}")"
		else
			elapsed_time="${ap_timeout}"
		fi
		if [[ "${elapsed_time}" -lt "${ap_timeout}" ]]; then
			access_point_down=0
			if hostapd_cli status interface "${interface}" 2>/dev/null | grep -q "state=DISABLED"; then
				echo
				if hostapd_cli enable interface "${interface}" > /dev/null 2>&1; then
					language_strings "${language}" "smart_twin_text_0" "green"
					if [ "${et_mode}" = "et_captive_portal" ] && ! pgrep -f "${optional_tools_names[12]} -i ${interface} -f ${tmpdir}${hosts_file}" > /dev/null 2>&1; then
						launch_dns_blackhole
					fi
				else
					language_strings "${language}" "smart_twin_text_1" "red"
				fi
			fi
		else
			access_point_down="$(expr "${access_point_down}" + 1)"
			if [[ "${access_point_down}" -gt 2 ]] && hostapd_cli status interface "${interface}" 2>/dev/null | grep -q "state=ENABLED"; then
				echo
				if hostapd_cli disable interface "${interface}" > /dev/null 2>&1; then
					language_strings "${language}" "smart_twin_text_2" "yellow"
				else
					language_strings "${language}" "smart_twin_text_3" "red"
				fi
			fi
		fi
		if ! pgrep -f "hostapd ${tmpdir}${current_hostapd_file}" > /dev/null 2>&1; then
			unset target_check
			break
		fi
		sleep 4
	done
}

#Posthook to deploy manage_evil_twin_ap
function smart_twin_posthook_exec_et_deauth() {

	debug_print

	if [ "${current_menu}" = "evil_twin_attacks_menu" ] && [ "${dos_pursuit_mode}" -eq 1 ] && ! echo "${target_check}" | grep -xq "1"; then
		manage_evil_twin_ap &
	fi
}

#Enable ctrl_interface in hostapd config
function set_hostapd_config_ctrl_interface() {

	debug_print

	{
	echo -e "ctrl_interface=/var/run/hostapd"
	echo -e "ctrl_interface_group=0"
	} >> "${tmpdir}${current_hostapd_file}"
}

#Posthook to set hostapd config
function smart_twin_posthook_set_hostapd_config() {

	debug_print

	current_hostapd_file="${hostapd_file}"
	set_hostapd_config_ctrl_interface
}

#Posthook to set hostapd-wpe config
function smart_twin_posthook_set_hostapd_wpe_config() {

	debug_print

	current_hostapd_file="${hostapd_wpe_file}"
	set_hostapd_config_ctrl_interface
}

#Custom function. Create text messages to be used in Smart-Twin plugin
function initialize_smart_twin_language_strings() {

	debug_print

	declare -gA arr
	arr["ENGLISH","smart_twin_text_0"]="Target detected, Evil Twin AP enabled"
	arr["SPANISH","smart_twin_text_0"]="\${pending_of_translation} Objetivo detectado, Evil Twin AP habilitado"
	arr["FRENCH","smart_twin_text_0"]="\${pending_of_translation} Cible détectée, Evil Twin AP activé"
	arr["CATALAN","smart_twin_text_0"]="\${pending_of_translation} S'ha detectat l'objectiu: l'AP Evil Twin està activada"
	arr["PORTUGUESE","smart_twin_text_0"]="\${pending_of_translation} Alvo detectado, Evil Twin AP ativado"
	arr["RUSSIAN","smart_twin_text_0"]="\${pending_of_translation} Обнаружена цель, включена злая двойная точка доступа"
	arr["GREEK","smart_twin_text_0"]="\${pending_of_translation} Εντοπίστηκε στόχος, ενεργοποιήθηκε το Evil Twin AP"
	arr["ITALIAN","smart_twin_text_0"]="Target rilevato, Evil Twin AP abilitato"
	arr["POLISH","smart_twin_text_0"]="\${pending_of_translation} Wykryto cel, włączony Zły Twin AP"
	arr["GERMAN","smart_twin_text_0"]="\${pending_of_translation} Ziel erkannt, Evil Twin AP aktiviert"
	arr["TURKISH","smart_twin_text_0"]="\${pending_of_translation} Hedef tespit edildi, Evil Twin AP etkin"

	arr["ENGLISH","smart_twin_text_1"]="Error enabling Evil Twin AP"
	arr["SPANISH","smart_twin_text_1"]="\${pending_of_translation} Error al habilitar Evil Twin AP"
	arr["FRENCH","smart_twin_text_1"]="\${pending_of_translation} Erreur lors de l'activation de Evil Twin AP"
	arr["CATALAN","smart_twin_text_1"]="\${pending_of_translation} Error en habilitar Evil Twin AP"
	arr["PORTUGUESE","smart_twin_text_1"]="\${pending_of_translation} Erro ao ativar o Evil Twin AP"
	arr["RUSSIAN","smart_twin_text_1"]="\${pending_of_translation} Ошибка включения Evil Twin AP"
	arr["GREEK","smart_twin_text_1"]="\${pending_of_translation} Σφάλμα κατά την ενεργοποίηση του Evil Twin AP"
	arr["ITALIAN","smart_twin_text_1"]="Errore durante l'attivazione dell'Evil Twin AP"
	arr["POLISH","smart_twin_text_1"]="\${pending_of_translation} Błąd podczas włączania Evil Twin AP"
	arr["GERMAN","smart_twin_text_1"]="\${pending_of_translation} Fehler beim Aktivieren des Evil Twin AP"
	arr["TURKISH","smart_twin_text_1"]="\${pending_of_translation} Evil Twin AP etkinleştirilirken hata oluştu"

	arr["ENGLISH","smart_twin_text_2"]="Target not detected, Evil Twin AP disabled"
	arr["SPANISH","smart_twin_text_2"]="\${pending_of_translation} Objetivo no detectado, Evil Twin AP deshabilitado"
	arr["FRENCH","smart_twin_text_2"]="\${pending_of_translation} Cible non détectée, Evil Twin AP désactivé"
	arr["CATALAN","smart_twin_text_2"]="\${pending_of_translation} Objectiu no detectat, desactivat AP Evil Twin"
	arr["PORTUGUESE","smart_twin_text_2"]="\${pending_of_translation} Alvo não detectado, AP Evil Twin desativado"
	arr["RUSSIAN","smart_twin_text_2"]="\${pending_of_translation} Цель не обнаружена, злая двойная точка доступа отключена"
	arr["GREEK","smart_twin_text_2"]="\${pending_of_translation} Ο στόχος δεν εντοπίστηκε, το Evil Twin AP απενεργοποιήθηκε"
	arr["ITALIAN","smart_twin_text_2"]="Target non rilevato, Evil Twin AP disabilitato"
	arr["POLISH","smart_twin_text_2"]="\${pending_of_translation} Nie wykryto celu, Złe Podwójne AP wyłączone"
	arr["GERMAN","smart_twin_text_2"]="\${pending_of_translation} Ziel nicht erkannt, Evil Twin AP deaktiviert"
	arr["TURKISH","smart_twin_text_2"]="\${pending_of_translation} Hedef tespit edilmedi, Evil Twin AP devre dışı"

	arr["ENGLISH","smart_twin_text_3"]="Error disabling Evil Twin AP"
	arr["SPANISH","smart_twin_text_3"]="\${pending_of_translation} Error al deshabilitar Evil Twin AP"
	arr["FRENCH","smart_twin_text_3"]="\${pending_of_translation} Erreur lors de la désactivation de Evil Twin AP"
	arr["CATALAN","smart_twin_text_3"]="\${pending_of_translation} Error en desactivar Evil Twin AP"
	arr["PORTUGUESE","smart_twin_text_3"]="\${pending_of_translation} Erro ao desativar o Evil Twin AP"
	arr["RUSSIAN","smart_twin_text_3"]="\${pending_of_translation} Ошибка отключения Evil Twin AP"
	arr["GREEK","smart_twin_text_3"]="\${pending_of_translation} Σφάλμα κατά την απενεργοποίηση του Evil Twin AP"
	arr["ITALIAN","smart_twin_text_3"]="Errore durante la disabilitazione dell'Evil Twin AP"
	arr["POLISH","smart_twin_text_3"]="\${pending_of_translation} Błąd podczas wyłączania złego podwójnego AP"
	arr["GERMAN","smart_twin_text_3"]="\${pending_of_translation} Fehler beim Deaktivieren des Evil Twin AP"
	arr["TURKISH","smart_twin_text_3"]="\${pending_of_translation} Evil Twin AP devre dışı bırakılırken hata oluştu"
}

initialize_smart_twin_language_strings

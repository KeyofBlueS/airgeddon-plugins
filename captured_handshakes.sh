#!/usr/bin/env bash

# Captured-Handshakes airgeddon plugin

# Version:    0.0.3
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/airgeddon-plugins
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

# airgeddon Repository: https://github.com/v1s1t0r1sh3r3/airgeddon

#Global shellcheck disabled warnings
#shellcheck disable=SC2034,SC2154

plugin_name="Captured-Handshakes"
plugin_description="Select captured handshakes from a list"
plugin_author="KeyofBlueS"

plugin_enabled=1

plugin_minimum_ag_affected_version="10.20"
plugin_maximum_ag_affected_version=""
plugin_distros_supported=("*")


# Put Your captured handshakes files in plugins/captured_handshakes/HANDSHAKES
# then choose one of them inside airgeddon itself.

captured_handshakes_dir="captured_handshakes/"

#Captured handshakes selection menu
function list_captured_handshakes_files() {

	debug_print

	manual_handshakes_text="$(echo "${arr[${language},captured_handshakes_text_1]}")"
	likely_tip="0"
	while true; do
		clear
		if [ "${current_menu}" = "handshake_pmkid_tools_menu" ]; then
			language_strings "${language}" 120 "title"
		elif [ "${current_menu}" = "decrypt_menu" ]; then
			language_strings "${language}" 170 "title"
		elif [ "${current_menu}" = "evil_twin_attacks_menu" ]; then
			language_strings "${language}" 293 "title"
			print_iface_selected
			print_et_target_vars
			print_iface_internet_selected
		fi
		echo
		language_strings "${language}" "captured_handshakes_text_0" "green"
		print_simple_separator

		echo "${manual_handshakes_text}" > "${tmpdir}ag.captured_handshakes.txt"
		ls -d1 -- "${scriptfolder}${plugins_dir}${captured_handshakes_dir}"* 2>/dev/null | rev | awk -F'/' '{print $1}' | rev | sort >> "${tmpdir}ag.captured_handshakes.txt"
		local i=0
		while IFS=, read -r exp_handshake; do

			i=$((i + 1))

			if [ ${i} -le 9 ]; then
				sp1=" "
			else
				sp1=""
			fi

			handshake_color="${normal_color}"
			unset likely
			
			if [[ -n "${essid}" ]] && [[ -n "${bssid}" ]]; then
				if ! echo "${exp_handshake}" | grep -q "${manual_handshakes_text}"; then
					if cat "${scriptfolder}${plugins_dir}${captured_handshakes_dir}${exp_handshake}" | grep -Fq "${essid}" > /dev/null 2>&1 || echo "${exp_handshake}" | grep -q "${bssid}"; then
						likely_tip="1"
						handshake_color="${yellow_color}"
						likely="*"
					fi
				fi
			fi

			handshake=${exp_handshake}
			echo -e "${handshake_color} ${sp1}${i}) ${handshake} ${likely}"  
		done < "${tmpdir}ag.captured_handshakes.txt"

		unset selected_captured_handshake
		echo
		if [ ${likely_tip} -eq 1 ]; then
			language_strings "${language}" "captured_handshakes_text_2" "yellow"
			likely_tip="0"
		fi
		if ! cat "${tmpdir}ag.captured_handshakes.txt" | grep -Exvq "${manual_handshakes_text}$"; then
			language_strings "${language}" "captured_handshakes_text_3" "yellow"
			language_strings "${language}" "captured_handshakes_text_4" "yellow"
			echo_brown "${scriptfolder}${plugins_dir}${captured_handshakes_dir}HANDSHAKES.cap"
		fi
		read -rp "> " selected_captured_handshake
		if [[ ! "${selected_captured_handshake}" =~ ^[[:digit:]]+$ ]] || [[ "${selected_captured_handshake}" -gt "${i}" ]] || [[ "${selected_captured_handshake}" -lt 1 ]]; then
			echo
			language_strings "${language}" "captured_handshakes_text_5" "red"
			language_strings "${language}" 115 "read"
		else
			break
		fi
	done
	if [[ "${selected_captured_handshake}" -eq 1 ]]; then
		unset et_handshake
		unset enteredpath
		unset handshakepath
	else
		captured_handshake="${scriptfolder}${plugins_dir}${captured_handshakes_dir}$(sed -n "${selected_captured_handshake}"p "${tmpdir}ag.captured_handshakes.txt")"
		et_handshake="${captured_handshake}"
		enteredpath="${captured_handshake}"
		rm "${tmpdir}ag.captured_handshakes.txt"
		language_strings "${language}" "captured_handshakes_text_6" "yellow"
		echo_yellow "${captured_handshake}"
		language_strings "${language}" 115 "read"
	fi
}

#Evil twin captured handshakes selection menu
function captured_handshakes_prehook_ask_et_handshake_file() {

	debug_print

	list_captured_handshakes_files
}

#Clean captured handshakes selection menu
function captured_handshakes_prehook_clean_handshake_file_option() {

	debug_print

	list_captured_handshakes_files
}

#Personal captured handshakes decrypt selection menu
function captured_handshakes_prehook_personal_decrypt_menu() {

	debug_print

	if [ "${current_menu}" = "decrypt_menu" ]; then
		list_captured_handshakes_files
	fi
}

#Enterprise captured handshakes decrypt selection menu
function captured_handshakes_prehook_enterprise_decrypt_menu() {

	debug_print

	if [ "${current_menu}" = "decrypt_menu" ]; then
		list_captured_handshakes_files
	fi
}

#Set default save path to captured_handshakes_dir
function set_custom_default_save_path() {

	debug_print

	if [ "${is_docker}" -eq 1 ]; then
		default_save_path="${docker_io_dir}"
	else
		default_save_path="${scriptfolder}${plugins_dir}${captured_handshakes_dir}"
	fi
}

#Set default save path to captured_handshakes_dir on launch_handshake_capture
function captured_handshakes_prehook_launch_handshake_capture() {

	debug_print

	set_custom_default_save_path
}

#Set default save path to captured_handshakes_dir on launch_pmkid_capture
function captured_handshakes_prehook_launch_pmkid_capture() {

	debug_print

	set_custom_default_save_path
}

#Restore default save path
function captured_handshakes_posthook_validate_path() {

	debug_print

	if [ "${is_docker}" -eq 1 ]; then
		default_save_path="${docker_io_dir}"
	else
		default_save_path="${user_homedir}"
	fi
}

#Custom function. Create text messages to be used in captured handshakes plugin
function initialize_captured_handshakes_language_strings() {

	debug_print

	arr["ENGLISH","captured_handshakes_text_0"]="Select captured handshake file:"
	arr["SPANISH","captured_handshakes_text_0"]="\${pending_of_translation} Seleccione el archivo de handshake capturado:"
	arr["FRENCH","captured_handshakes_text_0"]="\${pending_of_translation} Sélectionnez le fichier de handshake capturé:"
	arr["CATALAN","captured_handshakes_text_0"]="\${pending_of_translation} Seleccioneu el fitxer de handshake capturat:"
	arr["PORTUGUESE","captured_handshakes_text_0"]="\${pending_of_translation} Selecione o arquivo de handshake capturado:"
	arr["RUSSIAN","captured_handshakes_text_0"]="\${pending_of_translation} Выберите захваченный файл рукопожатия:"
	arr["GREEK","captured_handshakes_text_0"]="\${pending_of_translation} Επιλέξτε το αρχείο χειραψίας που έχετε τραβήξει:"
	arr["ITALIAN","captured_handshakes_text_0"]="Seleziona il file di handshake catturato:"
	arr["POLISH","captured_handshakes_text_0"]="\${pending_of_translation} Wybierz przechwycony plik uzgadniania:"
	arr["GERMAN","captured_handshakes_text_0"]="\${pending_of_translation} Erfasste Handshake-Datei auswählen:"
	arr["TURKISH","captured_handshakes_text_0"]="\${pending_of_translation} Yakalanan el sıkışma dosyasını seçin:"

	arr["ENGLISH","captured_handshakes_text_1"]="Manually enter the path of the captured handshake file"
	arr["SPANISH","captured_handshakes_text_1"]="\${pending_of_translation} Ingrese manualmente la ruta del archivo de handshake capturado"
	arr["FRENCH","captured_handshakes_text_1"]="\${pending_of_translation} Entrez manuellement le chemin du fichier de handshake capturé"
	arr["CATALAN","captured_handshakes_text_1"]="\${pending_of_translation} Introduïu manualment la ruta del fitxer de handshake capturat"
	arr["PORTUGUESE","captured_handshakes_text_1"]="\${pending_of_translation} Insira manualmente o caminho do arquivo de handshake capturado"
	arr["RUSSIAN","captured_handshakes_text_1"]="\${pending_of_translation} Вручную введите путь к захваченному файлу рукопожатия"
	arr["GREEK","captured_handshakes_text_1"]="\${pending_of_translation} Εισαγάγετε μη αυτόματα τη διαδρομή του καταγεγραμμένου αρχείου χειραψίας"
	arr["ITALIAN","captured_handshakes_text_1"]="Inserisci manualmente il percorso del file di handshake"
	arr["POLISH","captured_handshakes_text_1"]="\${pending_of_translation} Ręcznie wprowadź ścieżkę przechwyconego pliku uzgadniania"
	arr["GERMAN","captured_handshakes_text_1"]="\${pending_of_translation} Geben Sie den Pfad der erfassten Handshake-Datei manuell ein"
	arr["TURKISH","captured_handshakes_text_1"]="\${pending_of_translation} Yakalanan el sıkışma dosyasının yolunu el ile girin"

	arr["ENGLISH","captured_handshakes_text_2"]="(*) Likely"
	arr["SPANISH","captured_handshakes_text_2"]="\${pending_of_translation} (*) Probable"
	arr["FRENCH","captured_handshakes_text_2"]="\${pending_of_translation} (*) Probable"
	arr["CATALAN","captured_handshakes_text_2"]="\${pending_of_translation} (*) Probablement"
	arr["PORTUGUESE","captured_handshakes_text_2"]="\${pending_of_translation} (*) Provável"
	arr["RUSSIAN","captured_handshakes_text_2"]="\${pending_of_translation} (*) Скорее всего"
	arr["GREEK","captured_handshakes_text_2"]="\${pending_of_translation} (*) Πιθανός"
	arr["ITALIAN","captured_handshakes_text_2"]="(*) Probabile"
	arr["POLISH","captured_handshakes_text_2"]="\${pending_of_translation} (*) Prawdopodobne"
	arr["GERMAN","captured_handshakes_text_2"]="\${pending_of_translation} (*) Wahrscheinlich"
	arr["TURKISH","captured_handshakes_text_2"]="\${pending_of_translation} (*) muhtemelen"

	arr["ENGLISH","captured_handshakes_text_3"]="No captured handshake file found!"
	arr["SPANISH","captured_handshakes_text_3"]="\${pending_of_translation} ¡No se encontraron handshake capturados!"
	arr["FRENCH","captured_handshakes_text_3"]="\${pending_of_translation} Aucun fichier de handshake capturé trouvé!"
	arr["CATALAN","captured_handshakes_text_3"]="\${pending_of_translation} No s'ha trobat cap fitxer de handshake capturat!"
	arr["PORTUGUESE","captured_handshakes_text_3"]="\${pending_of_translation} Nenhum arquivo de handshake capturado encontrado!"
	arr["RUSSIAN","captured_handshakes_text_3"]="\${pending_of_translation} Не найден захваченный файл рукопожатия!"
	arr["GREEK","captured_handshakes_text_3"]="\${pending_of_translation} Δεν βρέθηκε αρχείο χειραψίας!"
	arr["ITALIAN","captured_handshakes_text_3"]="Nessun file di handshake catturato trovato!"
	arr["POLISH","captured_handshakes_text_3"]="\${pending_of_translation} Nie znaleziono przechwyconego pliku uzgadniania!"
	arr["GERMAN","captured_handshakes_text_3"]="\${pending_of_translation} Keine erfasste Handshake-Datei gefunden!"
	arr["TURKISH","captured_handshakes_text_3"]="\${pending_of_translation} Yakalanan bir el sıkışma dosyası bulunamadı!"

	arr["ENGLISH","captured_handshakes_text_4"]="Please put Your captured handshakes files in:"
	arr["SPANISH","captured_handshakes_text_4"]="\${pending_of_translation} Ponga sus archivos de handshake capturados en:"
	arr["FRENCH","captured_handshakes_text_4"]="\${pending_of_translation} Veuillez mettre vos fichiers de handshake capturés dans:"
	arr["CATALAN","captured_handshakes_text_4"]="\${pending_of_translation} Introduïu els fitxers de handshake capturats:"
	arr["PORTUGUESE","captured_handshakes_text_4"]="\${pending_of_translation} Coloque seus arquivos de handshakes capturados em:"
	arr["RUSSIAN","captured_handshakes_text_4"]="\${pending_of_translation} Пожалуйста, поместите ваши захваченные файлы рукопожатий в:"
	arr["GREEK","captured_handshakes_text_4"]="\${pending_of_translation} Τοποθετήστε τα αρχεία χειραψιών που έχετε τραβήξει:"
	arr["ITALIAN","captured_handshakes_text_4"]="Inserisci i file di handshake catturati in:"
	arr["POLISH","captured_handshakes_text_4"]="\${pending_of_translation} Umieść swoje przechwycone pliki uzgadniania:"
	arr["GERMAN","captured_handshakes_text_4"]="\${pending_of_translation} Bitte legen Sie Ihre erfassten Handshakes-Dateien ein:"
	arr["TURKISH","captured_handshakes_text_4"]="\${pending_of_translation} Lütfen Yakalanan tokalaşma dosyalarınızı buraya yerleştirin:"

	arr["ENGLISH","captured_handshakes_text_5"]="Invalid captured handshake was chosen!"
	arr["SPANISH","captured_handshakes_text_5"]="\${pending_of_translation} Se eligió un handshake capturado no válido!"
	arr["FRENCH","captured_handshakes_text_5"]="\${pending_of_translation} Une handshake capturée non valide a été choisie!"
	arr["CATALAN","captured_handshakes_text_5"]="\${pending_of_translation} S'ha escollit un handshake capturat no vàlid!"
	arr["PORTUGUESE","captured_handshakes_text_5"]="\${pending_of_translation} O handshake capturado inválido foi escolhido!"
	arr["RUSSIAN","captured_handshakes_text_5"]="\${pending_of_translation} Неверное захваченное рукопожатие было выбрано!"
	arr["GREEK","captured_handshakes_text_5"]="\${pending_of_translation} Επιλέχθηκε μη έγκυρη χειραψία!"
	arr["ITALIAN","captured_handshakes_text_5"]="Scelta non valida!"
	arr["POLISH","captured_handshakes_text_5"]="\${pending_of_translation} Wybrano nieprawidłowy ujęty uścisk dłoni!"
	arr["GERMAN","captured_handshakes_text_5"]="\${pending_of_translation} Es wurde ein ungültiger erfasster handshake ausgewählt!"
	arr["TURKISH","captured_handshakes_text_5"]="\${pending_of_translation} Geçersiz yakalanan el sıkışma seçildi!"

	arr["ENGLISH","captured_handshakes_text_6"]="Captured handshake choosen:"
	arr["SPANISH","captured_handshakes_text_6"]="\${pending_of_translation} Handshake capturado elegido:"
	arr["FRENCH","captured_handshakes_text_6"]="\${pending_of_translation} Handshake capturée choisie:"
	arr["CATALAN","captured_handshakes_text_6"]="\${pending_of_translation} Handshake capturat:"
	arr["PORTUGUESE","captured_handshakes_text_6"]="\${pending_of_translation} Handshake capturado escolhido:"
	arr["RUSSIAN","captured_handshakes_text_6"]="\${pending_of_translation} Захваченное рукопожатие выбрано:"
	arr["GREEK","captured_handshakes_text_6"]="\${pending_of_translation} Επιλεγμένη χειραψία:"
	arr["ITALIAN","captured_handshakes_text_6"]="Handshake scelto:"
	arr["POLISH","captured_handshakes_text_6"]="\${pending_of_translation} Wybrany uścisk dłoni:"
	arr["GERMAN","captured_handshakes_text_6"]="\${pending_of_translation} Erfasster Handshake ausgewählt:"
	arr["TURKISH","captured_handshakes_text_6"]="\${pending_of_translation} Yakalanan el sıkışma seçildi:"
}

initialize_captured_handshakes_language_strings

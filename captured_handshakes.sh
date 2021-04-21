#!/usr/bin/env bash

# Captured-Handshakes airgeddon plugin

# Version:    0.1.10
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

plugin_minimum_ag_affected_version="10.30"
plugin_maximum_ag_affected_version=""
plugin_distros_supported=("*")

################################# USER CONFIG SECTION #################################

# Put Your captured handshakes files in a directory of Your choice
# Default is plugins/captured_handshakes/HANDSHAKES
# Example:
captured_handshakes_dir="${scriptfolder}${plugins_dir}captured_handshakes/"
# then choose one of them inside airgeddon itself.

############################## END OF USER CONFIG SECTION ##############################

#Captured handshakes selection menu
function list_captured_handshakes_files() {

	debug_print

	manual_handshakes_text="this_is_the_manual_handshakes_text"
	likely_tip="0"
	unsupported_tip="0"
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
		ls -pd1 -- "${captured_handshakes_dir}"* 2>/dev/null | grep -v /$ | rev | awk -F'/' '{print $1}' | rev | sort >> "${tmpdir}ag.captured_handshakes.txt"
		local i=1
		while IFS=, read -r exp_handshake; do

			if [[ -f "${captured_handshakes_dir}${exp_handshake}" ]] || [[ "${exp_handshake}" = "${manual_handshakes_text}" ]]; then
				if [[ "${exp_handshake}" = "${manual_handshakes_text}" ]]; then
					language_strings "${language}" "captured_handshakes_text_1"
				else
					i=$((i + 1))

					if [ ${i} -le 9 ]; then
						sp1=" "
					else
						sp1=""
					fi

					handshake_color="${normal_color}"
					unset likely

					if ! aircrack-ng "${captured_handshakes_dir}${exp_handshake}" 2>&1 | grep -Fq "Unsupported file format (not a pcap or IVs file)."; then
						if [[ -n "${essid}" ]] && [[ -n "${bssid}" ]] && ! echo "${exp_handshake}" | grep -q "${manual_handshakes_text}" && aircrack-ng -q "${captured_handshakes_dir}${exp_handshake}" -b "${bssid}" > /dev/null 2>&1 && aircrack-ng -q "${captured_handshakes_dir}${exp_handshake}" -e "${essid}" > /dev/null 2>&1; then
							set_likely
						fi
					else
						if cat "${captured_handshakes_dir}${exp_handshake}" | grep -Eq "^[[:alnum:]]{32}\*[[:alnum:]]{12}\*[[:alnum:]]{12}\*[[:alnum:]]+$"; then
							clean_bssid="$(echo "${bssid}" | tr -d ':')"
							ascii_essid="$(cat "${captured_handshakes_dir}${exp_handshake}" | rev | awk -F'*' '{print $1}' | rev | awk 'RT{printf "%c", strtonum("0x"RT)}' RS='[0-9A-Fa-f]{2}')"
							if echo "${essid}" | grep -q "${ascii_essid}" && cat "${captured_handshakes_dir}${exp_handshake}" | awk -F'*' '{print $2}' | grep -iq "${clean_bssid}"; then
								set_likely
							fi
						else
							unsupported_tip="1"
							likely="!"
							handshake_color="${red_color}"
						fi
					fi

					handshake=${exp_handshake}
					echo -e "${handshake_color} ${sp1}${i}) ${handshake} ${likely}"
				fi
			fi
		done < "${tmpdir}ag.captured_handshakes.txt"

		unset selected_captured_handshake
		echo
		if [ "${current_menu}" = "evil_twin_attacks_menu" ]; then
			warning_color="red"
		else
			warning_color="yellow"
		fi
		if ! cat "${tmpdir}ag.captured_handshakes.txt" | grep -Exvq "${manual_handshakes_text}$"; then
			language_strings "${language}" "captured_handshakes_text_5" "${warning_color}"
			language_strings "${language}" "captured_handshakes_text_6" "${warning_color}"
			echo_brown "${captured_handshakes_dir}HANDSHAKES.cap"
		else
			if [ "${likely_tip}" -eq 1 ]; then
				language_strings "${language}" "captured_handshakes_text_2" "yellow"
			else
				if [[ -n "${essid}" ]] && [[ -n "${bssid}" ]]; then
					language_strings "${language}" "captured_handshakes_text_4" "${warning_color}"
				fi
			fi
			if [ "${unsupported_tip}" -eq 1 ]; then
				language_strings "${language}" "captured_handshakes_text_3" "red"
			fi
		fi
		likely_tip="0"
		unsupported_tip="0"
		read -rp "> " selected_captured_handshake
		if [[ ! "${selected_captured_handshake}" =~ ^[[:digit:]]+$ ]] || [[ "${selected_captured_handshake}" -gt "${i}" ]] || [[ "${selected_captured_handshake}" -lt 1 ]]; then
			echo
			language_strings "${language}" "captured_handshakes_text_7" "red"
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
		captured_handshake="${captured_handshakes_dir}$(sed -n "${selected_captured_handshake}"p "${tmpdir}ag.captured_handshakes.txt")"
		et_handshake="${captured_handshake}"
		enteredpath="${captured_handshake}"
		rm "${tmpdir}ag.captured_handshakes.txt"
		language_strings "${language}" "captured_handshakes_text_8" "yellow"
		echo_yellow "${captured_handshake}"
		language_strings "${language}" 115 "read"
	fi
}

#Set likely tip
function set_likely() {

	debug_print

	likely_tip="1"
	likely="*"
	handshake_color="${yellow_color}"
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
	
	stored_default_save_path="${default_save_path}"

	if [ "${is_docker}" -eq 1 ]; then
		default_save_path="${docker_io_dir}"
	else
		default_save_path="${captured_handshakes_dir}"
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

#Set default save path to captured_handshakes_dir on capture_handshake_evil_twin
function captured_handshakes_prehook_capture_handshake_evil_twin() {

	debug_print

	set_custom_default_save_path
}

#Restore default save path
function restore_default_save_path() {

	debug_print

	if [ "${is_docker}" -eq 1 ]; then
		default_save_path="${docker_io_dir}"
	else
		default_save_path="${stored_default_save_path}"
	fi
}

#Restore default save path after launch_handshake_capture
function captured_handshakes_posthook_launch_handshake_capture() {

	debug_print

	restore_default_save_path
}

#Restore default save path after launch_pmkid_capture
function captured_handshakes_posthook_launch_pmkid_capture() {

	debug_print

	restore_default_save_path
}

#Restore default save path after capture_handshake_evil_twin
function captured_handshakes_posthook_capture_handshake_evil_twin() {

	debug_print

	restore_default_save_path
}

#Check if captured_handshakes_dir exist
function check_captured_handshakes_dir() {

	debug_print

	lastchar_captured_handshakes_dir=${captured_handshakes_dir: -1}
	if [ "${lastchar_captured_handshakes_dir}" != "/" ]; then
		captured_handshakes_dir="${captured_handshakes_dir}/"
	fi
	
	if [[ ! -d "${captured_handshakes_dir}" ]]; then
		mkdir -p "${captured_handshakes_dir}"
		folder_owner="$(ls -ld "${captured_handshakes_dir}.." | awk -F' ' '{print $3}')"
		folder_group="$(ls -ld "${captured_handshakes_dir}.." | awk -F' ' '{print $4}')"
		chown "${folder_owner}":"${folder_group}" -R "${captured_handshakes_dir}"
	fi
}

#Custom function. Create text messages to be used in captured handshakes plugin
function initialize_captured_handshakes_language_strings() {

	debug_print

	declare -gA arr
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
	arr["ARABIC","captured_handshakes_text_0"]="\${pending_of_translation} :حدد ملف المصافحة الملتقطة"

	arr["ENGLISH","captured_handshakes_text_1"]="  1) Manually enter the path of the captured handshake file"
	arr["SPANISH","captured_handshakes_text_1"]="  1) \${cyan_color}\${pending_of_translation}\${normal_color} Ingrese manualmente la ruta del archivo de handshake capturado"
	arr["FRENCH","captured_handshakes_text_1"]="  1) \${cyan_color}\${pending_of_translation}\${normal_color} Entrez manuellement le chemin du fichier de handshake capturé"
	arr["CATALAN","captured_handshakes_text_1"]="  1) \${cyan_color}\${pending_of_translation}\${normal_color} Introduïu manualment la ruta del fitxer de handshake capturat"
	arr["PORTUGUESE","captured_handshakes_text_1"]="  1) \${cyan_color}\${pending_of_translation}\${normal_color} Insira manualmente o caminho do arquivo de handshake capturado"
	arr["RUSSIAN","captured_handshakes_text_1"]="  1) \${cyan_color}\${pending_of_translation}\${normal_color} Вручную введите путь к захваченному файлу рукопожатия"
	arr["GREEK","captured_handshakes_text_1"]="  1) \${cyan_color}\${pending_of_translation}\${normal_color} Εισαγάγετε μη αυτόματα τη διαδρομή του καταγεγραμμένου αρχείου χειραψίας"
	arr["ITALIAN","captured_handshakes_text_1"]="  1) Inserisci manualmente il percorso del file di handshake"
	arr["POLISH","captured_handshakes_text_1"]="  1) \${cyan_color}\${pending_of_translation}\${normal_color} Ręcznie wprowadź ścieżkę przechwyconego pliku uzgadniania"
	arr["GERMAN","captured_handshakes_text_1"]="  1) \${cyan_color}\${pending_of_translation}\${normal_color} Geben Sie den Pfad der erfassten Handshake-Datei manuell ein"
	arr["TURKISH","captured_handshakes_text_1"]="  1) \${cyan_color}\${pending_of_translation}\${normal_color} Yakalanan el sıkışma dosyasının yolunu el ile girin"
	arr["ARABIC","captured_handshakes_text_1"]="  1) \${cyan_color}\${pending_of_translation}\${normal_color} أدخل مسار ملف المصافحة الملتقط يدويًا"

	arr["ENGLISH","captured_handshakes_text_2"]="(*) Likely"
	arr["SPANISH","captured_handshakes_text_2"]="\${pending_of_translation} (*) Probable"
	arr["FRENCH","captured_handshakes_text_2"]="\${pending_of_translation} (*) Probable"
	arr["CATALAN","captured_handshakes_text_2"]="\${pending_of_translation} (*) probable"
	arr["PORTUGUESE","captured_handshakes_text_2"]="\${pending_of_translation} (*) Provável"
	arr["RUSSIAN","captured_handshakes_text_2"]="\${pending_of_translation} (*) Скорее всего"
	arr["GREEK","captured_handshakes_text_2"]="\${pending_of_translation} (*) Πιθανός"
	arr["ITALIAN","captured_handshakes_text_2"]="(*) Probabile"
	arr["POLISH","captured_handshakes_text_2"]="\${pending_of_translation} (*) Prawdopodobne"
	arr["GERMAN","captured_handshakes_text_2"]="\${pending_of_translation} (*) Wahrscheinlich"
	arr["TURKISH","captured_handshakes_text_2"]="\${pending_of_translation} (*) muhtemelen"
	arr["ARABIC","captured_handshakes_text_2"]="\${pending_of_translation} (*) مرجح"

	arr["ENGLISH","captured_handshakes_text_3"]="(!) Unsupported file format"
	arr["SPANISH","captured_handshakes_text_3"]="\${pending_of_translation} (!) Formato de archivo no soportado"
	arr["FRENCH","captured_handshakes_text_3"]="\${pending_of_translation} (!) Format de fichier non pris en charge"
	arr["CATALAN","captured_handshakes_text_3"]="\${pending_of_translation} (!) Format de fitxer no compatible"
	arr["PORTUGUESE","captured_handshakes_text_3"]="\${pending_of_translation} (!) Formato de arquivo não suportado"
	arr["RUSSIAN","captured_handshakes_text_3"]="\${pending_of_translation} (!) Неподдерживаемый формат файла"
	arr["GREEK","captured_handshakes_text_3"]="\${pending_of_translation} (!) Μη υποστηριζόμενη μορφή αρχείου"
	arr["ITALIAN","captured_handshakes_text_3"]="(!) Formato file non supportato"
	arr["POLISH","captured_handshakes_text_3"]="\${pending_of_translation} (!) Niewspierany format pliku"
	arr["GERMAN","captured_handshakes_text_3"]="\${pending_of_translation} (!) Nicht unterstütztes Dateiformat"
	arr["TURKISH","captured_handshakes_text_3"]="\${pending_of_translation} (!) Desteklenmeyen dosya formatı"
	arr["ARABIC","captured_handshakes_text_3"]="\${pending_of_translation} (!) تنسيق ملف غير معتمد"

	arr["ENGLISH","captured_handshakes_text_4"]="No captured handshake file for the selected network found!"
	arr["SPANISH","captured_handshakes_text_4"]="\${pending_of_translation} ¡No se encontró ningún archivo de handshake capturado para la red seleccionada!"
	arr["FRENCH","captured_handshakes_text_4"]="\${pending_of_translation} Aucun fichier de handshake capturé pour le réseau sélectionné trouvé!"
	arr["CATALAN","captured_handshakes_text_4"]="\${pending_of_translation} No s'ha trobat cap fitxer de handshake capturat per a la xarxa seleccionada!"
	arr["PORTUGUESE","captured_handshakes_text_4"]="\${pending_of_translation} Nenhum arquivo de handshake capturado para a rede selecionada foi encontrado!"
	arr["RUSSIAN","captured_handshakes_text_4"]="\${pending_of_translation} Не найден захваченный файл рукопожатия для выбранной сети!"
	arr["GREEK","captured_handshakes_text_4"]="\${pending_of_translation} Δεν βρέθηκε αρχείο χειραψίας για το επιλεγμένο δίκτυο!"
	arr["ITALIAN","captured_handshakes_text_4"]="Nessun file di handshake catturato trovato per la rete selezionata!"
	arr["POLISH","captured_handshakes_text_4"]="\${pending_of_translation} Nie znaleziono przechwyconego pliku uzgadniania dla wybranej sieci!"
	arr["GERMAN","captured_handshakes_text_4"]="\${pending_of_translation} Keine erfasste Handshake-Datei für das ausgewählte Netzwerk gefunden!"
	arr["TURKISH","captured_handshakes_text_4"]="\${pending_of_translation} Seçilen ağ için yakalanan el sıkışma dosyası bulunamadı!"
	arr["ARABIC","captured_handshakes_text_4"]="\${pending_of_translation} لم يتم العثور على ملف مصافحة تم التقاطه للشبكة المحددة"

	arr["ENGLISH","captured_handshakes_text_5"]="No captured handshake file found!"
	arr["SPANISH","captured_handshakes_text_5"]="\${pending_of_translation} ¡No se encontraron handshake capturados!"
	arr["FRENCH","captured_handshakes_text_5"]="\${pending_of_translation} Aucun fichier de handshake capturé trouvé!"
	arr["CATALAN","captured_handshakes_text_5"]="\${pending_of_translation} No s'ha trobat cap fitxer de handshake capturat!"
	arr["PORTUGUESE","captured_handshakes_text_5"]="\${pending_of_translation} Nenhum arquivo de handshake capturado encontrado!"
	arr["RUSSIAN","captured_handshakes_text_5"]="\${pending_of_translation} Не найден захваченный файл рукопожатия!"
	arr["GREEK","captured_handshakes_text_5"]="\${pending_of_translation} Δεν βρέθηκε αρχείο χειραψίας!"
	arr["ITALIAN","captured_handshakes_text_5"]="Nessun file di handshake catturato trovato!"
	arr["POLISH","captured_handshakes_text_5"]="\${pending_of_translation} Nie znaleziono przechwyconego pliku uzgadniania!"
	arr["GERMAN","captured_handshakes_text_5"]="\${pending_of_translation} Keine erfasste Handshake-Datei gefunden!"
	arr["TURKISH","captured_handshakes_text_5"]="\${pending_of_translation} Yakalanan bir el sıkışma dosyası bulunamadı!"
	arr["ARABIC","captured_handshakes_text_5"]="\${pending_of_translation} لم يتم العثور على ملف مصافحة تم التقاطه"

	arr["ENGLISH","captured_handshakes_text_6"]="Please put Your captured handshakes files in:"
	arr["SPANISH","captured_handshakes_text_6"]="\${pending_of_translation} Ponga sus archivos de handshake capturados en:"
	arr["FRENCH","captured_handshakes_text_6"]="\${pending_of_translation} Veuillez mettre vos fichiers de handshake capturés dans:"
	arr["CATALAN","captured_handshakes_text_6"]="\${pending_of_translation} Introduïu els fitxers de handshake capturats:"
	arr["PORTUGUESE","captured_handshakes_text_6"]="\${pending_of_translation} Coloque seus arquivos de handshakes capturados em:"
	arr["RUSSIAN","captured_handshakes_text_6"]="\${pending_of_translation} Пожалуйста, поместите ваши захваченные файлы рукопожатий в:"
	arr["GREEK","captured_handshakes_text_6"]="\${pending_of_translation} Τοποθετήστε τα αρχεία χειραψιών που έχετε τραβήξει:"
	arr["ITALIAN","captured_handshakes_text_6"]="Inserisci i file di handshake catturati in:"
	arr["POLISH","captured_handshakes_text_6"]="\${pending_of_translation} Umieść swoje przechwycone pliki uzgadniania:"
	arr["GERMAN","captured_handshakes_text_6"]="\${pending_of_translation} Bitte legen Sie Ihre erfassten Handshakes-Dateien ein:"
	arr["TURKISH","captured_handshakes_text_6"]="\${pending_of_translation} Lütfen Yakalanan tokalaşma dosyalarınızı buraya yerleştirin:"
	arr["ARABIC","captured_handshakes_text_6"]="\${pending_of_translation} يرجى وضع ملفات المصافحة التي تم التقاطها"

	arr["ENGLISH","captured_handshakes_text_7"]="Invalid captured handshake was chosen!"
	arr["SPANISH","captured_handshakes_text_7"]="\${pending_of_translation} Se eligió un handshake capturado no válido!"
	arr["FRENCH","captured_handshakes_text_7"]="\${pending_of_translation} Une handshake capturée non valide a été choisie!"
	arr["CATALAN","captured_handshakes_text_7"]="\${pending_of_translation} S'ha escollit un handshake capturat no vàlid!"
	arr["PORTUGUESE","captured_handshakes_text_7"]="\${pending_of_translation} O handshake capturado inválido foi escolhido!"
	arr["RUSSIAN","captured_handshakes_text_7"]="\${pending_of_translation} Неверное захваченное рукопожатие было выбрано!"
	arr["GREEK","captured_handshakes_text_7"]="\${pending_of_translation} Επιλέχθηκε μη έγκυρη χειραψία!"
	arr["ITALIAN","captured_handshakes_text_7"]="Scelta non valida!"
	arr["POLISH","captured_handshakes_text_7"]="\${pending_of_translation} Wybrano nieprawidłowy ujęty uścisk dłoni!"
	arr["GERMAN","captured_handshakes_text_7"]="\${pending_of_translation} Es wurde ein ungültiger erfasster handshake ausgewählt!"
	arr["TURKISH","captured_handshakes_text_7"]="\${pending_of_translation} Geçersiz yakalanan el sıkışma seçildi!"
	arr["ARABIC","captured_handshakes_text_7"]="\${pending_of_translation} تم اختيار مصافحة تم التقاطها غير صالحة"

	arr["ENGLISH","captured_handshakes_text_8"]="Captured handshake choosen:"
	arr["SPANISH","captured_handshakes_text_8"]="\${pending_of_translation} Handshake capturado elegido:"
	arr["FRENCH","captured_handshakes_text_8"]="\${pending_of_translation} Handshake capturée choisie:"
	arr["CATALAN","captured_handshakes_text_8"]="\${pending_of_translation} Handshake capturat:"
	arr["PORTUGUESE","captured_handshakes_text_8"]="\${pending_of_translation} Handshake capturado escolhido:"
	arr["RUSSIAN","captured_handshakes_text_8"]="\${pending_of_translation} Захваченное рукопожатие выбрано:"
	arr["GREEK","captured_handshakes_text_8"]="\${pending_of_translation} Επιλεγμένη χειραψία:"
	arr["ITALIAN","captured_handshakes_text_8"]="Handshake scelto:"
	arr["POLISH","captured_handshakes_text_8"]="\${pending_of_translation} Wybrany uścisk dłoni:"
	arr["GERMAN","captured_handshakes_text_8"]="\${pending_of_translation} Erfasster Handshake ausgewählt:"
	arr["TURKISH","captured_handshakes_text_8"]="\${pending_of_translation} Yakalanan el sıkışma seçildi:"
	arr["ARABIC","captured_handshakes_text_8"]="\${pending_of_translation} تم اختيار المصافحة الملتقطة"
}

check_captured_handshakes_dir
initialize_captured_handshakes_language_strings

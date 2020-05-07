#!/usr/bin/env bash

# Sort-Targets airgeddon plugin

# Version:    0.1.0
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/airgeddon-plugins
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

# airgeddon Repository: https://github.com/v1s1t0r1sh3r3/airgeddon

#Global shellcheck disabled warnings
#shellcheck disable=SC2034,SC2154

plugin_name="Sort-Targets"
plugin_description="Sort targets by a value of Your choice"
plugin_author="KeyofBlueS"

plugin_enabled=1

plugin_minimum_ag_affected_version="10.20"
plugin_maximum_ag_affected_version=""
plugin_distros_supported=("*")

################################# USER CONFIG SECTION #################################

# When selecting targets, sort them by one of the following value:
# "bssid", "channel", "power", "essid", "encryption", "default"
# or:
# "menu"
# if You want to choose sorting within a menu, this override reverse option too.
# Example:
#sort_by="power"
sort_by=menu

# Set reverse to "true" to reverse the result of comparisons, otherwise set to "false"
# Example:
reverse=false

# If You set sort_by="menu", You can make remember Your sort choice in current session
# by set remember_sort to "true", otherwise set to "false"
# Example:
remember_sort=false

############################## END OF USER CONFIG SECTION ##############################

#Sort targets
function sort_targets_prehook_select_target() {

	debug_print

	stored_sort_by="${sort_by}"
	stored_reverse="${reverse}"
	if [[ "${sort_by}" = "menu" ]]; then
		while true; do
			clear
			echo 
			language_strings "${language}" "sort_targets_text_0" "green"
			echo
			print_simple_separator
			echo -en " 1) bssid" && echo -e "       7) bssid (${arr[${language},sort_targets_text_1]})"
			echo -en " 2) channel" && echo -e "     8) channel (${arr[${language},sort_targets_text_1]})"
			echo -en " 3) power" && echo -e "       9) power (${arr[${language},sort_targets_text_1]})"
			echo -en " 4) essid" && echo -e "      10) essid (${arr[${language},sort_targets_text_1]})"
			echo -en " 5) encryption" && echo -e " 11) encryption (${arr[${language},sort_targets_text_1]})"
			echo -en " 6) default" && echo -e "    12) default (${arr[${language},sort_targets_text_1]})"
			print_simple_separator
			read -rp "> " sort_by

			case $sort_by in
				1)
					sort_by="bssid"; reverse=false; break
				;;
				2)
					sort_by="channel"; reverse=false; break
				;;
				3)
					sort_by="power"; reverse=false; break
				;;
				4)
					sort_by="essid"; reverse=false; break
				;;
				5)
					sort_by="encryption"; reverse=false; break
				;;
				6)
					sort_by="default"; reverse=false; break
				;;
				7)
					sort_by="bssid"; reverse=true; break
				;;
				8)
					sort_by="channel"; reverse=true; break
				;;
				9)
					sort_by="power"; reverse=true; break
				;;
				10)
					sort_by="essid"; reverse=true; break
				;;
				11)
					sort_by="encryption"; reverse=true; break
				;;
				12)
					sort_by="default"; reverse=true; break
				;;
				*)
					echo
					language_strings "${language}" "sort_targets_text_2" "red"
					language_strings "${language}" 115 "read"
				;;
			esac
		done
	fi
	
	if [[ "${sort_by}" = "bssid" ]]; then
		sort_options="-d -k 1"
	elif [[ "${sort_by}" = "channel" ]]; then
		sort_options="-n -k 2"
	elif [[ "${sort_by}" = "power" ]]; then
		sort_options="-n -k 3"
	elif [[ "${sort_by}" = "essid" ]]; then
		sort_options="-d -k 4"
	elif [[ "${sort_by}" = "encryption" ]]; then
		sort_options="-d -k 5"
	else
		sort_options="-d -k 4"
	fi
	
	if [[ "${reverse}" = "true" ]]; then
		sort_options="${sort_options} -r"
	fi

	sort -t "," ${sort_options} "${tmpdir}wnws.txt" > "${tmpdir}wnws.txt_tmp"
	mv "${tmpdir}wnws.txt_tmp" "${tmpdir}wnws.txt"
	
	unset sort_options
	
	if [[ "${remember_sort}" = "false" ]]; then
		sort_by="${stored_sort_by}"
		reverse="${stored_reverse}"
	fi
}

#Custom function. Create text messages to be used in sort targets plugin
function initialize_sort_targets_language_strings() {

	debug_print

	arr["ENGLISH","sort_targets_text_0"]="Select the order in which to display the list of targets:"
	arr["SPANISH","sort_targets_text_0"]="\${pending_of_translation} Seleccione el orden en el que se mostrará la lista de objetivos:"
	arr["FRENCH","sort_targets_text_0"]="\${pending_of_translation} Sélectionnez l'ordre dans lequel afficher la liste des cibles:"
	arr["CATALAN","sort_targets_text_0"]="\${pending_of_translation} Seleccioneu l’ordre en què es mostrarà la llista d’objectius:"
	arr["PORTUGUESE","sort_targets_text_0"]="\${pending_of_translation} Selecione a ordem na qual exibir a lista de destinos:"
	arr["RUSSIAN","sort_targets_text_0"]="\${pending_of_translation} Выберите порядок отображения списка целей:"
	arr["GREEK","sort_targets_text_0"]="\${pending_of_translation} Επιλέξτε τη σειρά με την οποία θα εμφανιστεί η λίστα των στόχων:"
	arr["ITALIAN","sort_targets_text_0"]="Seleziona lordine in cui visualizzare l'elenco degli obbiettivi:"
	arr["POLISH","sort_targets_text_0"]="\${pending_of_translation} Wybierz kolejność wyświetlania listy celów:"
	arr["GERMAN","sort_targets_text_0"]="\${pending_of_translation} Wählen Sie die Reihenfolge aus, in der die Liste der Ziele angezeigt werden soll:"
	arr["TURKISH","sort_targets_text_0"]="\${pending_of_translation} Hedef listesinin görüntüleneceği sırayı seçin:"

	arr["ENGLISH","sort_targets_text_1"]="reverse"
	arr["SPANISH","sort_targets_text_1"]="\${pending_of_translation} inverso"
	arr["FRENCH","sort_targets_text_1"]="\${pending_of_translation} inverser"
	arr["CATALAN","sort_targets_text_1"]="\${pending_of_translation} revés"
	arr["PORTUGUESE","sort_targets_text_1"]="\${pending_of_translation} reverter"
	arr["RUSSIAN","sort_targets_text_1"]="\${pending_of_translation} обратный"
	arr["GREEK","sort_targets_text_1"]="\${pending_of_translation} αντίστροφος"
	arr["ITALIAN","sort_targets_text_1"]="invertito"
	arr["POLISH","sort_targets_text_1"]="\${pending_of_translation} odwrotność"
	arr["GERMAN","sort_targets_text_1"]="\${pending_of_translation} umgekehrt"
	arr["TURKISH","sort_targets_text_1"]="\${pending_of_translation} ters"

	arr["ENGLISH","sort_targets_text_2"]="Invalid choice!"
	arr["SPANISH","sort_targets_text_2"]="\${pending_of_translation} ¡Elección inválida!"
	arr["FRENCH","sort_targets_text_2"]="\${pending_of_translation} Choix invalide!"
	arr["CATALAN","sort_targets_text_2"]="\${pending_of_translation} Elecció no vàlida!"
	arr["PORTUGUESE","sort_targets_text_2"]="\${pending_of_translation} Escolha inválida!"
	arr["RUSSIAN","sort_targets_text_2"]="\${pending_of_translation} Неверный выбор!"
	arr["GREEK","sort_targets_text_2"]="\${pending_of_translation} Μη έγκυρη επιλογή!"
	arr["ITALIAN","sort_targets_text_2"]="Scelta non valida!"
	arr["POLISH","sort_targets_text_2"]="\${pending_of_translation} Nieprawidłowy wybór!"
	arr["GERMAN","sort_targets_text_2"]="\${pending_of_translation} Ungültige Wahl!"
	arr["TURKISH","sort_targets_text_2"]="\${pending_of_translation} Geçersiz seçim!"
}

initialize_sort_targets_language_strings

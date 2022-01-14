#!/usr/bin/env bash

# Sort-Targets airgeddon plugin

# Version:    0.1.3
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

plugin_minimum_ag_affected_version="10.30"
plugin_maximum_ag_affected_version=""
plugin_distros_supported=("*")

################################# USER CONFIG SECTION #################################

# When selecting targets, sort them by one of the following value:
# "bssid", "channel", "power", "clients", "essid", "encryption", "default"
# or:
# "menu"
# if You want to choose sorting within a menu, this override reverse option too.
# Example:
#sort_by="power"
sort_by=menu
# Also, this plug-in add the value "clients" (CLI) to the target selection list, so you
# can view the amount of clients connected to each Access Point.
# The more you leave the "Exploring for targets" window running, the more clients will
# be discovered.


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

	echo -n "" > "${tmpdir}wnws.txt_tmp"
	while IFS=, read -r exp_mac exp_channel exp_power exp_essid exp_enc; do

		client_n="$(awk -F '<' '/<BSSID>/ {print $2} /<wireless-client/ {print $2} /cdp-portid>/ {print $5}' "${tmpdir}nws-01.kismet.netxml" | tr '\n' ' '  | sed 's#  #\n#g' | grep -F "${exp_mac}" | grep -o 'number=' | wc -l)"
		echo "${exp_mac},${exp_channel},${exp_power},${client_n},${exp_essid},${exp_enc}" >> "${tmpdir}wnws.txt_tmp"
	done < "${tmpdir}wnws.txt"
	mv "${tmpdir}wnws.txt_tmp" "${tmpdir}wnws.txt"


	stored_sort_by="${sort_by}"
	stored_reverse="${reverse}"
	if [[ "${sort_by}" = "menu" ]]; then
		while true; do
			clear
			echo 
			language_strings "${language}" "sort_targets_text_0" "green"
			echo
			print_simple_separator
			language_strings "${language}" "sort_targets_text_1"
			language_strings "${language}" "sort_targets_text_2"
			language_strings "${language}" "sort_targets_text_3"
			language_strings "${language}" "sort_targets_text_4"
			language_strings "${language}" "sort_targets_text_5"
			language_strings "${language}" "sort_targets_text_6"
			language_strings "${language}" "sort_targets_text_7"
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
					sort_by="clients"; reverse=false; break
				;;
				5)
					sort_by="essid"; reverse=false; break
				;;
				6)
					sort_by="encryption"; reverse=false; break
				;;
				7)
					sort_by="default"; reverse=false; break
				;;
				8)
					sort_by="bssid"; reverse=true; break
				;;
				9)
					sort_by="channel"; reverse=true; break
				;;
				10)
					sort_by="power"; reverse=true; break
				;;
				11)
					sort_by="clients"; reverse=true; break
				;;
				12)
					sort_by="essid"; reverse=true; break
				;;
				13)
					sort_by="encryption"; reverse=true; break
				;;
				14)
					sort_by="default"; reverse=true; break
				;;
				*)
					echo
					language_strings "${language}" "sort_targets_text_8" "red"
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
	elif [[ "${sort_by}" = "clients" ]]; then
		sort_options="-n -k 4"
	elif [[ "${sort_by}" = "essid" ]]; then
		sort_options="-d -k 5"
	elif [[ "${sort_by}" = "encryption" ]]; then
		sort_options="-d -k 6"
	else
		sort_options="-d -k 5"
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

#Create a menu to select target from the parsed data
function sort_targets_override_select_target() {

	debug_print

	clear
	language_strings "${language}" 104 "title"
	echo
	language_strings "${language}" "sort_targets_text_9" "green"
	print_large_separator
	local i=0
	while IFS=, read -r exp_mac exp_channel exp_power exp_client_n exp_essid exp_enc; do

		i=$((i + 1))

		if [ ${i} -le 9 ]; then
			sp1=" "
		else
			sp1=""
		fi

		if [[ ${exp_channel} -le 9 ]]; then
			sp2="  "
			if [[ ${exp_channel} -eq 0 ]]; then
				exp_channel="-"
			fi
			if [[ ${exp_channel} -lt 0 ]]; then
				sp2=" "
			fi
		elif [[ ${exp_channel} -ge 10 ]] && [[ ${exp_channel} -lt 99 ]]; then
			sp2=" "
		else
			sp2=""
		fi

		if [[ ${exp_client_n} -le 9 ]]; then
			sp3=" "
		else
			sp3=""
		fi

		if [[ "${exp_power}" = "" ]]; then
			exp_power=0
		fi

		if [[ ${exp_power} -le 9 ]]; then
			sp4=" "
		else
			sp4=""
		fi

		airodump_color="${normal_color}"
		client=$(grep "${exp_mac}" < "${tmpdir}clts.csv")
		if [ "${client}" != "" ]; then
			airodump_color="${yellow_color}"
			client="*"
			sp5=""
		else
			sp5=" "
		fi

		enc_length=${#exp_enc}
		if [ "${enc_length}" -gt 3 ]; then
			sp6=""
		elif [ "${enc_length}" -eq 0 ]; then
			sp6="    "
		else
			sp6=" "
		fi

		network_names[$i]=${exp_essid}
		channels[$i]=${exp_channel}
		macs[$i]=${exp_mac}
		encs[$i]=${exp_enc}
		echo -e "${airodump_color} ${sp1}${i})${client}  ${sp5}${exp_mac}  ${sp2}${exp_channel}    ${sp4}${exp_power}%    ${sp3}${exp_client_n}   ${exp_enc}${sp6}   ${exp_essid}"
	done < "${tmpdir}wnws.txt"

	echo
	if [ ${i} -eq 1 ]; then
		language_strings "${language}" 70 "yellow"
		selected_target_network=1
		language_strings "${language}" 115 "read"
	else
		language_strings "${language}" 71 "yellow"
		print_large_separator
		language_strings "${language}" 3 "green"
		read -rp "> " selected_target_network
	fi

	while [[ ! ${selected_target_network} =~ ^[[:digit:]]+$ ]] || (( selected_target_network < 1 || selected_target_network > i )); do
		echo
		language_strings "${language}" 72 "red"
		echo
		language_strings "${language}" 3 "green"
		read -rp "> " selected_target_network
	done

	essid=${network_names[${selected_target_network}]}
	channel=${channels[${selected_target_network}]}
	bssid=${macs[${selected_target_network}]}
	enc=${encs[${selected_target_network}]}
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
	arr["ITALIAN","sort_targets_text_0"]="Seleziona l'ordine in cui visualizzare l'elenco degli obbiettivi:"
	arr["POLISH","sort_targets_text_0"]="\${pending_of_translation} Wybierz kolejność wyświetlania listy celów:"
	arr["GERMAN","sort_targets_text_0"]="\${pending_of_translation} Wählen Sie die Reihenfolge aus, in der die Liste der Ziele angezeigt werden soll:"
	arr["TURKISH","sort_targets_text_0"]="\${pending_of_translation} Hedef listesinin görüntüleneceği sırayı seçin:"
	arr["ARABIC","sort_targets_text_0"]="\${pending_of_translation} حدد الترتيب الذي تريد عرض قائمة الأهداف به"

	arr["ENGLISH","sort_targets_text_1"]=" 1) bssid       8) bssid (reverse)"
	arr["SPANISH","sort_targets_text_1"]=" 1) bssid       8) bssid (\${cyan_color}\${pending_of_translation}\${normal_color} inverso)"
	arr["FRENCH","sort_targets_text_1"]=" 1) bssid       8) bssid (\${cyan_color}\${pending_of_translation}\${normal_color} inverser)"
	arr["CATALAN","sort_targets_text_1"]=" 1) bssid       8) bssid (\${cyan_color}\${pending_of_translation}\${normal_color} revés)"
	arr["PORTUGUESE","sort_targets_text_1"]=" 1) bssid       8) bssid (\${cyan_color}\${pending_of_translation}\${normal_color} reverter)"
	arr["RUSSIAN","sort_targets_text_1"]=" 1) bssid       8) bssid (\${cyan_color}\${pending_of_translation}\${normal_color} обратный)"
	arr["GREEK","sort_targets_text_1"]=" 1) bssid       8) bssid (\${cyan_color}\${pending_of_translation}\${normal_color} αντίστροφος)"
	arr["ITALIAN","sort_targets_text_1"]=" 1) bssid       8) bssid (invertito)"
	arr["POLISH","sort_targets_text_1"]=" 1) bssid       8) bssid (\${cyan_color}\${pending_of_translation}\${normal_color} odwrotność)"
	arr["GERMAN","sort_targets_text_1"]=" 1) bssid       8) bssid (\${cyan_color}\${pending_of_translation}\${normal_color} umgekehrt)"
	arr["TURKISH","sort_targets_text_1"]=" 1) bssid       8) bssid (\${cyan_color}\${pending_of_translation}\${normal_color} ters)"
	arr["ARABIC","sort_targets_text_1"]=" 1) bssid       8) bssid (\${cyan_color}\${pending_of_translation}\${normal_color} يعكس)"

	arr["ENGLISH","sort_targets_text_2"]=" 2) channel     9) channel (reverse)"
	arr["SPANISH","sort_targets_text_2"]=" 2) channel     9) channel (\${cyan_color}\${pending_of_translation}\${normal_color} inverso)"
	arr["FRENCH","sort_targets_text_2"]=" 2) channel     9) channel (\${cyan_color}\${pending_of_translation}\${normal_color} inverser)"
	arr["CATALAN","sort_targets_text_2"]=" 2) channel     9) channel (\${cyan_color}\${pending_of_translation}\${normal_color} revés)"
	arr["PORTUGUESE","sort_targets_text_2"]=" 2) channel     9) channel (\${cyan_color}\${pending_of_translation}\${normal_color} reverter)"
	arr["RUSSIAN","sort_targets_text_2"]=" 2) channel     9) channel (\${cyan_color}\${pending_of_translation}\${normal_color} обратный)"
	arr["GREEK","sort_targets_text_2"]=" 2) channel     9) channel (\${cyan_color}\${pending_of_translation}\${normal_color} αντίστροφος)"
	arr["ITALIAN","sort_targets_text_2"]=" 2) channel     9) channel (invertito)"
	arr["POLISH","sort_targets_text_2"]=" 2) channel     9) channel (\${cyan_color}\${pending_of_translation}\${normal_color} odwrotność)"
	arr["GERMAN","sort_targets_text_2"]=" 2) channel     9) channel (\${cyan_color}\${pending_of_translation}\${normal_color} umgekehrt)"
	arr["TURKISH","sort_targets_text_2"]=" 2) channel     9) channel (\${cyan_color}\${pending_of_translation}\${normal_color} ters)"
	arr["ARABIC","sort_targets_text_2"]=" 2) channel     9) channel (\${cyan_color}\${pending_of_translation}\${normal_color} يعكس)"

	arr["ENGLISH","sort_targets_text_3"]=" 3) power       10) power (reverse)"
	arr["SPANISH","sort_targets_text_3"]=" 3) power       10) power (\${cyan_color}\${pending_of_translation}\${normal_color} inverso)"
	arr["FRENCH","sort_targets_text_3"]=" 3) power       10) power (\${cyan_color}\${pending_of_translation}\${normal_color} inverser)"
	arr["CATALAN","sort_targets_text_3"]=" 3) power       10) power (\${cyan_color}\${pending_of_translation}\${normal_color} revés)"
	arr["PORTUGUESE","sort_targets_text_3"]=" 3) power       10) power (\${cyan_color}\${pending_of_translation}\${normal_color} reverter)"
	arr["RUSSIAN","sort_targets_text_3"]=" 3) power       10) power (\${cyan_color}\${pending_of_translation}\${normal_color} обратный)"
	arr["GREEK","sort_targets_text_3"]=" 3) power       10) power (\${cyan_color}\${pending_of_translation}\${normal_color} αντίστροφος)"
	arr["ITALIAN","sort_targets_text_3"]=" 3) power       10) power (invertito)"
	arr["POLISH","sort_targets_text_3"]=" 3) power       10) power (\${cyan_color}\${pending_of_translation}\${normal_color} odwrotność)"
	arr["GERMAN","sort_targets_text_3"]=" 3) power       10) power (\${cyan_color}\${pending_of_translation}\${normal_color} umgekehrt)"
	arr["TURKISH","sort_targets_text_3"]=" 3) power       10) power (\${cyan_color}\${pending_of_translation}\${normal_color} ters)"
	arr["ARABIC","sort_targets_text_3"]=" 3) power       10) power (\${cyan_color}\${pending_of_translation}\${normal_color} يعكس)"

	arr["ENGLISH","sort_targets_text_4"]=" 4) clients     11) clients (reverse)"
	arr["SPANISH","sort_targets_text_4"]=" 4) clients     11) clients (\${cyan_color}\${pending_of_translation}\${normal_color} inverso)"
	arr["FRENCH","sort_targets_text_4"]=" 4) clients     11) clients (\${cyan_color}\${pending_of_translation}\${normal_color} inverser)"
	arr["CATALAN","sort_targets_text_4"]=" 4) clients     11) clients (\${cyan_color}\${pending_of_translation}\${normal_color} revés)"
	arr["PORTUGUESE","sort_targets_text_4"]=" 4) clients     11) clients (\${cyan_color}\${pending_of_translation}\${normal_color} reverter)"
	arr["RUSSIAN","sort_targets_text_4"]=" 4) clients     11) clients (\${cyan_color}\${pending_of_translation}\${normal_color} обратный)"
	arr["GREEK","sort_targets_text_4"]=" 4) clients     11) clients (\${cyan_color}\${pending_of_translation}\${normal_color} αντίστροφος)"
	arr["ITALIAN","sort_targets_text_4"]=" 4) clients     11) clients (invertito)"
	arr["POLISH","sort_targets_text_4"]=" 4) clients     11) clients (\${cyan_color}\${pending_of_translation}\${normal_color} odwrotność)"
	arr["GERMAN","sort_targets_text_4"]=" 4) clients     11) clients (\${cyan_color}\${pending_of_translation}\${normal_color} umgekehrt)"
	arr["TURKISH","sort_targets_text_4"]=" 4) clients     11) clients (\${cyan_color}\${pending_of_translation}\${normal_color} ters)"
	arr["ARABIC","sort_targets_text_4"]=" 4) clients     11) clients (\${cyan_color}\${pending_of_translation}\${normal_color} يعكس)"

	arr["ENGLISH","sort_targets_text_5"]=" 5) essid       12) essid (reverse)"
	arr["SPANISH","sort_targets_text_5"]=" 5) essid       12) essid (\${cyan_color}\${pending_of_translation}\${normal_color} inverso)"
	arr["FRENCH","sort_targets_text_5"]=" 5) essid       12) essid (\${cyan_color}\${pending_of_translation}\${normal_color} inverser)"
	arr["CATALAN","sort_targets_text_5"]=" 5) essid       12) essid (\${cyan_color}\${pending_of_translation}\${normal_color} revés)"
	arr["PORTUGUESE","sort_targets_text_5"]=" 5) essid       12) essid (\${cyan_color}\${pending_of_translation}\${normal_color} reverter)"
	arr["RUSSIAN","sort_targets_text_5"]=" 5) essid       12) essid (\${cyan_color}\${pending_of_translation}\${normal_color} обратный)"
	arr["GREEK","sort_targets_text_5"]=" 5) essid       12) essid (\${cyan_color}\${pending_of_translation}\${normal_color} αντίστροφος)"
	arr["ITALIAN","sort_targets_text_5"]=" 5) essid       12) essid (invertito)"
	arr["POLISH","sort_targets_text_5"]=" 5) essid       12) essid (\${cyan_color}\${pending_of_translation}\${normal_color} odwrotność)"
	arr["GERMAN","sort_targets_text_5"]=" 5) essid       12) essid (\${cyan_color}\${pending_of_translation}\${normal_color} umgekehrt)"
	arr["TURKISH","sort_targets_text_5"]=" 5) essid       12) essid (\${cyan_color}\${pending_of_translation}\${normal_color} ters)"
	arr["ARABIC","sort_targets_text_5"]=" 5) essid       12) essid (\${cyan_color}\${pending_of_translation}\${normal_color} يعكس)"

	arr["ENGLISH","sort_targets_text_6"]=" 6) encryption  13) encryption (reverse)"
	arr["SPANISH","sort_targets_text_6"]=" 6) encryption  13) encryption (\${cyan_color}\${pending_of_translation}\${normal_color} inverso)"
	arr["FRENCH","sort_targets_text_6"]=" 6) encryption  13) encryption (\${cyan_color}\${pending_of_translation}\${normal_color} inverser)"
	arr["CATALAN","sort_targets_text_6"]=" 6) encryption  13) encryption (\${cyan_color}\${pending_of_translation}\${normal_color} revés)"
	arr["PORTUGUESE","sort_targets_text_6"]=" 6) encryption  13) encryption (\${cyan_color}\${pending_of_translation}\${normal_color} reverter)"
	arr["RUSSIAN","sort_targets_text_6"]=" 6) encryption  13) encryption (\${cyan_color}\${pending_of_translation}\${normal_color} обратный)"
	arr["GREEK","sort_targets_text_6"]=" 6) encryption  13) encryption (\${cyan_color}\${pending_of_translation}\${normal_color} αντίστροφος)"
	arr["ITALIAN","sort_targets_text_6"]=" 6) encryption  13) encryption (invertito)"
	arr["POLISH","sort_targets_text_6"]=" 6) encryption  13) encryption (\${cyan_color}\${pending_of_translation}\${normal_color} odwrotność)"
	arr["GERMAN","sort_targets_text_6"]=" 6) encryption  13) encryption (\${cyan_color}\${pending_of_translation}\${normal_color} umgekehrt)"
	arr["TURKISH","sort_targets_text_6"]=" 6) encryption  13) encryption (\${cyan_color}\${pending_of_translation}\${normal_color} ters)"
	arr["ARABIC","sort_targets_text_6"]=" 6) encryption  13) encryption (\${cyan_color}\${pending_of_translation}\${normal_color} يعكس)"

	arr["ENGLISH","sort_targets_text_7"]=" 7) default     14) default (reverse)"
	arr["SPANISH","sort_targets_text_7"]=" 7) default     14) default (\${cyan_color}\${pending_of_translation}\${normal_color} inverso)"
	arr["FRENCH","sort_targets_text_7"]=" 7) default     14) default (\${cyan_color}\${pending_of_translation}\${normal_color} inverser)"
	arr["CATALAN","sort_targets_text_7"]=" 7) default     14) default (\${cyan_color}\${pending_of_translation}\${normal_color} revés)"
	arr["PORTUGUESE","sort_targets_text_7"]=" 7) default     14) default (\${cyan_color}\${pending_of_translation}\${normal_color} reverter)"
	arr["RUSSIAN","sort_targets_text_7"]=" 7) default     14) default (\${cyan_color}\${pending_of_translation}\${normal_color} обратный)"
	arr["GREEK","sort_targets_text_7"]=" 7) default     14) default (\${cyan_color}\${pending_of_translation}\${normal_color} αντίστροφος)"
	arr["ITALIAN","sort_targets_text_7"]=" 7) default     14) default (invertito)"
	arr["POLISH","sort_targets_text_7"]=" 7) default     14) default (\${cyan_color}\${pending_of_translation}\${normal_color} odwrotność)"
	arr["GERMAN","sort_targets_text_7"]=" 7) default     14) default (\${cyan_color}\${pending_of_translation}\${normal_color} umgekehrt)"
	arr["TURKISH","sort_targets_text_7"]=" 7) default     14) default (\${cyan_color}\${pending_of_translation}\${normal_color} ters)"
	arr["ARABIC","sort_targets_text_7"]=" 7) default     14) default (\${cyan_color}\${pending_of_translation}\${normal_color} يعكس)"

	arr["ENGLISH","sort_targets_text_8"]="Invalid choice!"
	arr["SPANISH","sort_targets_text_8"]="\${pending_of_translation} ¡Elección inválida!"
	arr["FRENCH","sort_targets_text_8"]="\${pending_of_translation} Choix invalide!"
	arr["CATALAN","sort_targets_text_8"]="\${pending_of_translation} Elecció no vàlida!"
	arr["PORTUGUESE","sort_targets_text_8"]="\${pending_of_translation} Escolha inválida!"
	arr["RUSSIAN","sort_targets_text_8"]="\${pending_of_translation} Неверный выбор!"
	arr["GREEK","sort_targets_text_8"]="\${pending_of_translation} Μη έγκυρη επιλογή!"
	arr["ITALIAN","sort_targets_text_8"]="Scelta non valida!"
	arr["POLISH","sort_targets_text_8"]="\${pending_of_translation} Nieprawidłowy wybór!"
	arr["GERMAN","sort_targets_text_8"]="\${pending_of_translation} Ungültige Wahl!"
	arr["TURKISH","sort_targets_text_8"]="\${pending_of_translation} Geçersiz seçim!"
	arr["ARABIC","sort_targets_text_8"]="\${pending_of_translation} اختيار غير صحيح"

	arr["ENGLISH","sort_targets_text_9"]="  N.         BSSID      CHANNEL  PWR   CLI   ENC    ESSID"
	arr["SPANISH","sort_targets_text_9"]="  N.         BSSID        CANAL  PWR   CLI   ENC    ESSID"
	arr["FRENCH","sort_targets_text_9"]="  N.         BSSID        CANAL  PWR   CLI   ENC    ESSID"
	arr["CATALAN","sort_targets_text_9"]="  N.         BSSID        CANAL  PWR   CLI   ENC    ESSID"
	arr["PORTUGUESE","sort_targets_text_9"]="  N.         BSSID        CANAL  PWR   CLI   ENC    ESSID"
	arr["RUSSIAN","sort_targets_text_9"]="  N.         BSSID      CHANNEL  PWR   CLI   ENC    ESSID"
	arr["GREEK","sort_targets_text_9"]="  N.         BSSID      CHANNEL  PWR   CLI   ENC    ESSID"
	arr["ITALIAN","sort_targets_text_9"]="  N.         BSSID       CANALE  PWR   CLI   ENC    ESSID"
	arr["POLISH","sort_targets_text_9"]="  N.         BSSID        KANAŁ  PWR   CLI   ENC    ESSID"
	arr["GERMAN","sort_targets_text_9"]="  N.         BSSID        KANAL  PWR   CLI   ENC    ESSID"
	arr["TURKISH","sort_targets_text_9"]="  N.         BSSID      KANAL  PWR   CLI   ENC    ESSID"
	arr["ARABIC","sort_targets_text_9"]="  N.         BSSID      CHANNEL  PWR   CLI   ENC    ESSID"
}

initialize_sort_targets_language_strings

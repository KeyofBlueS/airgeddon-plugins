#!/usr/bin/env bash

# Regdomain airgeddon plugin

# Version:    0.1.1
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/airgeddon-plugins
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

# airgeddon Repository: https://github.com/v1s1t0r1sh3r3/airgeddon

#Global shellcheck disabled warnings
#shellcheck disable=SC2034,SC2154

plugin_name="Regdomain"
plugin_description="Set regulatory domain to affect the availability of wireless channels and txpower"
plugin_author="KeyofBlueS"

plugin_enabled=1

plugin_minimum_ag_affected_version="10.30"
plugin_maximum_ag_affected_version=""
plugin_distros_supported=("*")

################################# USER CONFIG SECTION #################################

# You can check the country codes database i.e. here:
# https://git.kernel.org/pub/scm/linux/kernel/git/sforshee/wireless-regdb.git/tree/db.txt
# Set the country code
# Example:
regulatory_domain=BZ

############################## END OF USER CONFIG SECTION ##############################

#Custom function to set regulatory domain
function get_regulatory_domain() {
	current_regulatory_domain="$(iw reg get | grep -m1 "country" | awk -F' ' '{print $2}' | awk -F':' '{print $1}')"
}
function set_regulatory_domain() {

	debug_print

	language_strings "${language}" "regdomain_text_0" "blue"

	#Get current regulatory domain
	get_regulatory_domain
	if [ -z "${regulatory_domain}" ]; then
		regulatory_domain="${current_regulatory_domain}"
	fi

	#Check regulatory domain
	if [ "${current_regulatory_domain}" != "${regulatory_domain}" ]; then
		#Terminate WiFi connections as they could prevent to set regulatory domain
		active_connections="$(nmcli -t -f uuid,type connection show --active | grep "wireless" | awk -F":" '{print $1}')"
		if [ -n "${active_connections}" ]; then
			for active_connection in ${active_connections}; do
				nmcli con down uuid "${active_connection}" > /dev/null 2>&1
			done
		fi
		#Set regulatory domain
		iw reg set "${regulatory_domain}" > /dev/null 2>&1
		#Reconnect previously disconnected WiFi connections
		if [ -n "${active_connections}" ]; then
			for active_connection in ${active_connections}; do
				nmcli con up uuid "${active_connection}" > /dev/null 2>&1 &
			done
		fi
		#Check regulatory domain again
		get_regulatory_domain
		if [ "${current_regulatory_domain}" != "${regulatory_domain}" ]; then
			language_strings "${language}" "regdomain_text_1" "red"
		fi
	fi
	language_strings "${language}" "regdomain_text_2" "yellow"
	echo_yellow "${current_regulatory_domain}"
	echo
}

#Prehook to set regulatory domain when setting interface in monitor mode
function regdomain_prehook_monitor_option() {

	debug_print

	set_regulatory_domain
}

#Prehook to set regulatory domain when setting interface in managed mode
function regdomain_prehook_managed_option() {

	debug_print

	set_regulatory_domain
}

#Override to try to set txpower to 30.00 dBm
function regdomain_override_set_mode_without_airmon() {

	debug_print

	local error
	local mode

	ip link set "${1}" down > /dev/null 2>&1

	iw dev "${1}" set txpower fixed 30mBm > /dev/null 2>&1

	if [ "${2}" = "monitor" ]; then
		mode="monitor"
		iw "${1}" set monitor control > /dev/null 2>&1
	else
		mode="managed"
		iw "${1}" set type managed > /dev/null 2>&1
	fi

	error=$?
	ip link set "${1}" up > /dev/null 2>&1

	if [ "${error}" != 0 ]; then
		return 1
	fi
	return 0
}

#Custom function. Create text messages to be used in regdomain plugin
function initialize_regdomain_language_strings() {

	debug_print

	arr["ENGLISH","regdomain_text_0"]="Setting regulatory domain..."
	arr["SPANISH","regdomain_text_0"]="\${pending_of_translation} Establecer dominio regulador..."
	arr["FRENCH","regdomain_text_0"]="\${pending_of_translation} Définition du domaine réglementaire..."
	arr["CATALAN","regdomain_text_0"]="\${pending_of_translation} Configuració del domini regulador..."
	arr["PORTUGUESE","regdomain_text_0"]="\${pending_of_translation} Definindo domínio regulador..."
	arr["RUSSIAN","regdomain_text_0"]="\${pending_of_translation} Настройка нормативного домена..."
	arr["GREEK","regdomain_text_0"]="\${pending_of_translation} Ορισμός ρυθμιστικού τομέα..."
	arr["ITALIAN","regdomain_text_0"]="Imposto il regulatory domain..."
	arr["POLISH","regdomain_text_0"]="\${pending_of_translation} Ustawianie domeny regulacyjnej..."
	arr["GERMAN","regdomain_text_0"]="\${pending_of_translation} Festlegen der regulatorischen Domäne..."
	arr["TURKISH","regdomain_text_0"]="\${pending_of_translation} Yasal alan adı ayarlanıyor..."
	arr["ARABIC","regdomain_text_0"]="\${pending_of_translation} تحديد المجال التنظيمي"

	arr["ENGLISH","regdomain_text_1"]="Error while setting regulatory domain!"
	arr["SPANISH","regdomain_text_1"]="\${pending_of_translation} ¡Error al configurar el dominio regulador!"
	arr["FRENCH","regdomain_text_1"]="\${pending_of_translation} Erreur lors de la définition du domaine réglementaire!"
	arr["CATALAN","regdomain_text_1"]="\${pending_of_translation} S'ha produït un error en configurar el domini regulador!"
	arr["PORTUGUESE","regdomain_text_1"]="\${pending_of_translation} Erro ao definir o domínio regulatório!"
	arr["RUSSIAN","regdomain_text_1"]="\${pending_of_translation} Ошибка при настройке регуляторного домена!"
	arr["GREEK","regdomain_text_1"]="\${pending_of_translation} Σφάλμα κατά τη ρύθμιση του ρυθμιστικού τομέα!"
	arr["ITALIAN","regdomain_text_1"]="Errore durante l'impostazione del regulatory domain!"
	arr["POLISH","regdomain_text_1"]="\${pending_of_translation} Błąd podczas ustawiania domeny regulacyjnej!"
	arr["GERMAN","regdomain_text_1"]="\${pending_of_translation} Fehler beim Einstellen der Regulierungsdomäne!"
	arr["TURKISH","regdomain_text_1"]="\${pending_of_translation} Yasal alan adı ayarlanırken hata oluştu!"
	arr["ARABIC","regdomain_text_1"]="\${pending_of_translation} خطأ أثناء تعيين المجال التنظيمي"

	arr["ENGLISH","regdomain_text_2"]="Current regulatory domain is:"
	arr["SPANISH","regdomain_text_2"]="\${pending_of_translation} El dominio regulador actual es:"
	arr["FRENCH","regdomain_text_2"]="\${pending_of_translation} Le domaine réglementaire actuel est:"
	arr["CATALAN","regdomain_text_2"]="\${pending_of_translation} El domini regulador actual és:"
	arr["PORTUGUESE","regdomain_text_2"]="\${pending_of_translation} O domínio regulatório atual é:"
	arr["RUSSIAN","regdomain_text_2"]="\${pending_of_translation} Текущий регуляторный домен:"
	arr["GREEK","regdomain_text_2"]="\${pending_of_translation} Ο τρέχων κανονιστικός τομέας είναι:"
	arr["ITALIAN","regdomain_text_2"]="L'attuale regulatory domain è:"
	arr["POLISH","regdomain_text_2"]="\${pending_of_translation} Obecna domena regulacyjna to:"
	arr["GERMAN","regdomain_text_2"]="\${pending_of_translation} Aktuelle regulatorische Domäne ist:"
	arr["TURKISH","regdomain_text_2"]="\${pending_of_translation} Mevcut yasal alan adı:"
	arr["ARABIC","regdomain_text_2"]="\${pending_of_translation} المجال التنظيمي الحالي هو"
}

initialize_regdomain_language_strings

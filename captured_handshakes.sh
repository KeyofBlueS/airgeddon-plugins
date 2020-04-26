#!/usr/bin/env bash

# Captured-Handshakes airgeddon plugin

# Version:    0.0.2
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

plugin_minimum_ag_affected_version="10.0"
plugin_maximum_ag_affected_version=""
plugin_distros_supported=("*")


# Put Your captured handshakes files in plugins/captured_handshakes/HANDSHAKES
# then choose one of them inside airgeddon itself.

captured_handshakes_dir="captured_handshakes/"

#Captured handshakes selection menu
function list_captured_handshakes_files() {

	debug_print

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
		language_strings "${language}" 154 "green"
		print_simple_separator

		echo "Manually enter the path of the captured handshake file" > "${tmpdir}ag.captured_handshakes.txt"
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
			likely_tip="0"
			unset likely
			if [[ -n "${essid}" ]] && [[ -n "${bssid}" ]]; then
				if ! echo "${exp_handshake}" | grep -q "Manually enter the path of the captured handshake file"; then
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
			echo_yellow "(*) Likely"
			unset likely_tip
		fi
		cat "${tmpdir}ag.captured_handshakes.txt" | grep -Exvq "Manually enter the path of the captured handshake file$"
		if [[ "${?}" != 0 ]]; then
			echo_yellow "No captured handshakes found!"
			echo_brown "Please put Your captured handshakes files in:"
			echo_brown "${scriptfolder}${plugins_dir}${captured_handshakes_dir}/HANDSHAKES.cap"
		fi
		read -rp "> " selected_captured_handshake
		if [[ ! "${selected_captured_handshake}" =~ ^[[:digit:]]+$ ]] || [[ "${selected_captured_handshake}" -gt "${i}" ]] || [[ "${selected_captured_handshake}" -lt 1 ]]; then
			echo
			echo_red "Invalid captured handshake was chosen"
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
		echo_yellow "Captured handshake choosen: ${captured_handshake}"
		language_strings "${language}" 115 "read"
	fi
}

#Evil twin captured handshakes selection menu
function captured_handshakes_prehook_ask_et_handshake_file() {

	list_captured_handshakes_files
}

#Clean captured handshakes selection menu
function captured_handshakes_prehook_clean_handshake_file_option() {

	list_captured_handshakes_files
}

#Personal captured handshakes decrypt selection menu
function captured_handshakes_prehook_personal_decrypt_menu() {
	if [ "${current_menu}" = "decrypt_menu" ]; then
		list_captured_handshakes_files
	fi
}

#Enterprise captured handshakes decrypt selection menu
function captured_handshakes_prehook_enterprise_decrypt_menu() {
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

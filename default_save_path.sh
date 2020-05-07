#!/usr/bin/env bash

# Default-Save-Path airgeddon plugin

# Version:    0.0.1
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/airgeddon-plugins
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

# airgeddon Repository: https://github.com/v1s1t0r1sh3r3/airgeddon

#Global shellcheck disabled warnings
#shellcheck disable=SC2034,SC2154

plugin_name="Default-Save-Path"
plugin_description="#Set the default directory for saving files"
plugin_author="KeyofBlueS"

plugin_enabled=1

plugin_minimum_ag_affected_version="10.0"
plugin_maximum_ag_affected_version=""
plugin_distros_supported=("*")

################################# USER CONFIG SECTION #################################

# Set the default directory for saving files
# Default is plugins/output/
# Example:
custom_default_save_path="${scriptfolder}${plugins_dir}output/"

############################## END OF USER CONFIG SECTION ##############################

#Set the default directory for saving files
function default_save_path_override_set_default_save_path() {

	debug_print

	lastchar_custom_default_save_path=${custom_default_save_path: -1}
	if [ "${lastchar_custom_default_save_path}" != "/" ]; then
		custom_default_save_path="${custom_default_save_path}/"
	fi
	
	if [[ ! -d "${custom_default_save_path}/" ]]; then
		mkdir -p "${custom_default_save_path}/"
		folder_owner="$(ls -ld "${custom_default_save_path}.." | awk -F' ' '{print $3}')"
		folder_group="$(ls -ld "${custom_default_save_path}.." | awk -F' ' '{print $4}')"
		chown "${folder_owner}":"${folder_group}" -R "${custom_default_save_path}"
	fi

	if [ "${is_docker}" -eq 1 ]; then
		default_save_path="${docker_io_dir}"
	else
		default_save_path="${custom_default_save_path}"
	fi
}

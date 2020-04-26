#!/usr/bin/env bash

# Sort-Targets airgeddon plugin

# Version:    0.0.1
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

plugin_minimum_ag_affected_version="10.0"
plugin_maximum_ag_affected_version=""
plugin_distros_supported=("*")

# When selecting targets, sort them by one of the following value:
# bssid, channel, power, essid, encryption, default
# Example:
sort_by="power"

# Set reverse to 1 to reverse the result of comparisons, otherwise set to 0
# Example:
reverse=1

function sort_targets_prehook_select_target() {
	
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
	
	if [[ "${reverse}" -eq "1" ]]; then
		sort_options="${sort_options} -r"
	fi

	sort -t "," ${sort_options} "${tmpdir}wnws.txt" > "${tmpdir}wnws.txt_tmp"
	mv "${tmpdir}wnws.txt_tmp" "${tmpdir}wnws.txt"
	
	unset sort_options
}

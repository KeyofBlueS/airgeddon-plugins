#!/usr/bin/env bash

# Regdomain airgeddon plugin

# Version:    0.0.1
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

plugin_minimum_ag_affected_version="10.0"
plugin_maximum_ag_affected_version=""
plugin_distros_supported=("*")

#Set the country code
#Example:
#regulatory_domain=BZ

#Custom function to set regulatory domain
function set_regulatory_domain() {

	#Get current regulatory domain
	current_regulatory_domain="$(iw reg get | grep "country" | awk -F' ' '{print $2}' | awk -F':' '{print $1}')"
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
		current_regulatory_domain="$(iw reg get | grep "country" | awk -F' ' '{print $2}' | awk -F':' '{print $1}')"
		if [ "${current_regulatory_domain}" != "${regulatory_domain}" ]; then
			echo -e "\e[1;31mError setting Regulatory Domain: ${current_regulatory_domain}\e[0m"
		else
			echo -e "\e[1;32mRegulatory Domain: ${current_regulatory_domain}\e[0m"
		fi
	else
		echo -e "\e[1;32mRegulatory Domain: ${current_regulatory_domain}\e[0m"
	fi
}

#Prehook to set regulatory domain when setting interface in monitor mode
function regulatory_domain_prehook_monitor_option() {

	set_regulatory_domain
}

#Prehook to set regulatory domain when setting interface in managed mode
function regulatory_domain_prehook_managed_option() {

	set_regulatory_domain
}

#Override to try to set txpower to 30.00 dBm
function regulatory_domain_override_set_mode_without_airmon() {

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

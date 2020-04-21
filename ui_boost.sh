#!/usr/bin/env bash

# UI-Boost airgeddon plugin

# Version:    0.1.6
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/airgeddon-plugins
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

# airgeddon Repository: https://github.com/v1s1t0r1sh3r3/airgeddon

#Global shellcheck disabled warnings
#shellcheck disable=SC2034,SC2154

plugin_name="UI-Boost"
plugin_description="Speed up user interface by making a specifc language strings file"
plugin_author="KeyofBlueS"

plugin_enabled=1

plugin_minimum_ag_affected_version="10.0"
plugin_maximum_ag_affected_version=""
plugin_distros_supported=("*")

#Enabled 1 / Disabled 0 - Use hardcoded language menu strings when in language_menu - Default value 0
#Enabling it it's a faster but a less reilable approach than using
#original language_strings_file, in case of changes in this last.
hardcoded_language_menu_strings=0

#Custom function to make specifc language strings file
function make_specifc_language_strings() {

	# detect languages to be excluded
	if [ -n "${languages_to_exclude}" ]; then
		unset languages_to_exclude
	fi
	for language_to_exclude in "${lang_association[@]}"; do
		if [ "${language_to_exclude}" != "${language}" ]; then
			if [ -z "${languages_to_exclude}" ]; then
				languages_to_exclude="${language_to_exclude}"
			else
				languages_to_exclude="${languages_to_exclude}|${language_to_exclude}"
			fi
		fi
	done

	# make specifc language strings file
	touch "${scriptfolder}${language_strings_file_complete%.*}"_"${language}".sh && chmod +x "${scriptfolder}${language_strings_file_complete%.*}"_"${language}".sh
	cat "${scriptfolder}${language_strings_file_complete}" | grep -Ev "\[\"(${languages_to_exclude})\"\,?[[:digit:]]*\]=" > "${scriptfolder}${language_strings_file_complete%.*}"_"${language}".sh

	# setting new language_strings_file variable
	language_strings_file="${language_strings_file_complete%.*}"_"${language}".sh
	source "${scriptfolder}${language_strings_file}"
	# update current language
	language_current="${language}"
}

#Custom function to check if specifc language strings file exist and it's coherence
function check_specifc_language_strings() {

	if [ -e "${scriptfolder}${language_strings_file_complete%.*}"_"${language}".sh ]; then
		unset language_strings_version
		unset set_language_strings_version
		source "${scriptfolder}${language_strings_file_complete%.*}"_"${language}".sh
		set_language_strings_version
		if [ "${language_strings_version}" != "${language_strings_expected_version}" ]; then
			make_specifc_language_strings
		fi
		# setting new language_strings_file variable
		language_strings_file="${language_strings_file_complete%.*}"_"${language}".sh
		source "${scriptfolder}${language_strings_file}"
		# update current language
		language_current="${language}"
	else
		make_specifc_language_strings
	fi
}

#Posthook to store some variables
function ui_boost_posthook_remap_colors() {

	# store current language
	language_current="${language}"
	# store language_strings_file
	language_strings_file_complete="${language_strings_file}"
	check_specifc_language_strings
}

#Prehook to let user change language in options menu
function ui_boost_prehook_language_menu() {

	if [ "${hardcoded_language_menu_strings}" -eq "1" ]; then
		#hardcoded language_menu strings
		declare -gA arr
		arr["ENGLISH",83]="Language changed to English"
		arr["SPANISH",83]="Idioma cambiado a Español"
		arr["FRENCH",83]="Le script sera maintenant en Français"
		arr["CATALAN",83]="Idioma canviat a Català"
		arr["PORTUGUESE",83]="Idioma alterado para Português"
		arr["RUSSIAN",83]="Язык изменён на русский"
		arr["GREEK",83]="Η γλώσσα άλλαξε στα Ελληνικά"
		arr["ITALIAN",83]="Lingua cambiata in Italiano"
		arr["POLISH",83]="Zmieniono język na Polski"
		arr["GERMAN",83]="Sprache wurde auf Deutsch geändert"
		arr["TURKISH",83]="Dil Türkçe olarak değiştirildi"

		arr["ENGLISH",115]="Press [Enter] key to continue..."
		arr["SPANISH",115]="Pulsa la tecla [Enter] para continuar..."
		arr["FRENCH",115]="Pressez [Enter] pour continuer..."
		arr["CATALAN",115]="Prem la tecla [Enter] per continuar..."
		arr["PORTUGUESE",115]="Pressione a tecla [Enter] para continuar..."
		arr["RUSSIAN",115]="Нажмите клавишу [Enter] для продолжения..."
		arr["GREEK",115]="Πατήστε το κουμπί [Enter] για να συνεχίσετε..."
		arr["ITALIAN",115]="Premere il tasto [Enter] per continuare..."
		arr["POLISH",115]="Naciśnij klawisz [Enter], aby kontynuować..."
		arr["GERMAN",115]="Drücken Sie die [Enter]-Taste, um fortzufahren..."
		arr["TURKISH",115]="Devam etmek için [Enter] tuşlayınız..."

		arr["ENGLISH",251]="You have chosen the same language that was selected. No changes will be done"
		arr["SPANISH",251]="Has elegido el mismo idioma que estaba seleccionado. No se realizarán cambios"
		arr["FRENCH",251]="Vous venez de choisir la langue qui est en usage. Pas de changements"
		arr["CATALAN",251]="Has triat el mateix idioma que estava seleccionat. No es realitzaran canvis"
		arr["PORTUGUESE",251]="Você escolheu o mesmo idioma que estava selecionado. Nenhuma alteração será feita"
		arr["RUSSIAN",251]="Вы выбрали такой же язык, какой и был. Никаких изменений не будет сделано"
		arr["GREEK",251]="Επιλέξατε την ίδια γλώσσα που ήταν ήδη επιλεγμένη. Δεν θα γίνει καμία αλλαγή"
		arr["ITALIAN",251]="Hai scelto la stessa lingua che è giá selezionata. Non sará effettutata nessuna modifica"
		arr["POLISH",251]="Wybrałeś ten sam język, który jest używany. Żadne zmiany nie zostaną wprowadzone"
		arr["GERMAN",251]="Sie haben die selbe Sprache ausgewählt. Es werden keine Änderungen vorgenommen"
		arr["TURKISH",251]="Seçilmiş olan dili seçtiniz. Hiçbir değişiklik yapılmayacak"
	else
		unset language_strings_version
		source "${scriptfolder}${language_strings_file_complete}"
	fi

	if [ "${language_current}" != "${language}" ]; then
		check_specifc_language_strings
	fi
}

#Prehook to restore complete language strings when an interruption is
#detected (i.e. CTRL+C) just after a language is selected in options menu.
#It's a slower but a more reilable approach than hardcode all needed language
#strings here, in case of changes in the original language_strings_file.
function ui_boost_prehook_capture_traps() {

	if [ "${current_menu}" = "language_menu" ]; then
		unset language_strings_version
		source "${scriptfolder}${language_strings_file_complete}"
	fi
}

#Posthook to restore specifc language strings if user choose to not terminate the script anymore
function ui_boost_posthook_capture_traps() {

	if [ "${current_menu}" = "language_menu" ]; then
		check_specifc_language_strings
	fi
}

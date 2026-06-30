class_name LocaleCatalog
extends RefCounted

const LOCALE_RU := "ru"
const LOCALE_EN := "en"
const LOCALE_SR := "sr"
const LOCALE_ES := "es"
const LOCALE_HI := "hi"
const LOCALE_DE := "de"
const LOCALE_FR := "fr"
const LOCALE_IT := "it"

const ORDER: Array[String] = [
	LOCALE_RU, LOCALE_EN, LOCALE_SR, LOCALE_ES, LOCALE_HI, LOCALE_DE, LOCALE_FR, LOCALE_IT,
]

const NATIVE_NAMES: Dictionary = {
	LOCALE_RU: "Русский",
	LOCALE_EN: "English",
	LOCALE_SR: "Српски",
	LOCALE_ES: "Español",
	LOCALE_HI: "हिन्दी",
	LOCALE_DE: "Deutsch",
	LOCALE_FR: "Français",
	LOCALE_IT: "Italiano",
}

const FLAG_ICON_PATHS: Dictionary = {
	LOCALE_RU: "res://assets/ui/flags/flag_ru.svg",
	LOCALE_EN: "res://assets/ui/flags/flag_en.svg",
	LOCALE_SR: "res://assets/ui/flags/flag_sr.svg",
	LOCALE_ES: "res://assets/ui/flags/flag_es.svg",
	LOCALE_HI: "res://assets/ui/flags/flag_hi.svg",
	LOCALE_DE: "res://assets/ui/flags/flag_de.svg",
	LOCALE_FR: "res://assets/ui/flags/flag_fr.svg",
	LOCALE_IT: "res://assets/ui/flags/flag_it.svg",
}


static func normalize(code: String) -> String:
	var lowered := code.to_lower()
	if ORDER.has(lowered):
		return lowered
	return LOCALE_RU


static func detect_from_system() -> String:
	return normalize(OS.get_locale_language())


static func uses_exclusion_conditions(locale: String) -> bool:
	var normalized := normalize(locale)
	return normalized == LOCALE_FR or normalized == LOCALE_IT


static func native_name(locale: String) -> String:
	return str(NATIVE_NAMES.get(normalize(locale), NATIVE_NAMES[LOCALE_RU]))


static func flag_icon_path(locale: String) -> String:
	return str(FLAG_ICON_PATHS.get(normalize(locale), FLAG_ICON_PATHS[LOCALE_RU]))

extends Node

signal locale_changed(locale: String)

const LOCALE_RU := "ru"
const LOCALE_EN := "en"

var _locale: String = LOCALE_RU
var _account: PDataAccount = null


func _ready() -> void:
	pass


func init_from_account(account: PDataAccount) -> void:
	_account = account
	if account == null:
		set_locale(detect_system_locale(), false)
		return
	account.ensure_language_initialized()
	set_locale(account.get_language(), false)


func detect_system_locale() -> String:
	var language := OS.get_locale_language().to_lower()
	if language == LOCALE_EN:
		return LOCALE_EN
	return LOCALE_RU


func get_locale() -> String:
	return _locale


func set_locale(code: String, persist: bool = true) -> void:
	var normalized := LOCALE_EN if code == LOCALE_EN else LOCALE_RU
	var changed := normalized != _locale
	_locale = normalized
	TranslationServer.set_locale(_locale)
	if persist and _account:
		_account.set_language(_locale)
	if changed:
		locale_changed.emit(_locale)


func text(key: String) -> String:
	return LocaleStrings.lookup(_locale, key)


func textf(key: String, args: Array) -> String:
	return text(key) % args


func get_slime_names() -> Array[String]:
	return LocaleStrings.get_slime_names(_locale)


func get_slime_name(preset_id: int) -> String:
	return LocaleStrings.get_slime_name(_locale, preset_id)


func get_rules_text() -> String:
	return LocaleStrings.get_rules_text(_locale)


func apply_cards_to(config: GameConfig) -> void:
	if config == null:
		return
	config.cards = GameDecks.get_cards(_locale)

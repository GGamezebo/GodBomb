extends Node

signal locale_changed(locale: String)

const LOCALE_RU := LocaleCatalog.LOCALE_RU
const LOCALE_EN := LocaleCatalog.LOCALE_EN

var _locale: String = LocaleCatalog.LOCALE_RU
var _account: PDataAccount = null


func _ready() -> void:
	pass


func init_from_account(account: PDataAccount) -> void:
	_account = account
	if account == null:
		set_locale(LocaleCatalog.detect_from_system(), false)
		return
	account.ensure_language_initialized()
	set_locale(account.get_language(), false)


func detect_system_locale() -> String:
	return LocaleCatalog.detect_from_system()


func get_locale() -> String:
	return _locale


func set_locale(code: String, persist: bool = true) -> void:
	var normalized := LocaleCatalog.normalize(code)
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

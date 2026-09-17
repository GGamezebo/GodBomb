class_name GameDecks
extends RefCounted

const DIFFICULTY_EASY := 0
const DIFFICULTY_MEDIUM := 1
const DIFFICULTY_HARD := 2
const DEFAULT_DIFFICULTY := DIFFICULTY_MEDIUM

const RUSSIAN_EASY: Array[String] = [
	"ка", "ма", "ли", "за", "ди", "ло", "от", "да", "те", "ал", "ак", "ов",
	"га", "та", "ро", "ад", "он", "ни", "во", "по", "ле", "не", "па", "ил",
	"со", "на", "мо", "ар", "ки", "са", "ба", "то", "хо", "од", "ко", "ан",
	"но", "ру", "ам", "ин", "ра", "ла", "ва", "ти", "ас", "му", "ус", "ун",
	"ит", "ок", "ор", "ев", "ук", "ча", "ке", "ик",
]

const RUSSIAN_MEDIUM: Array[String] = [
	"мат", "воз", "лю", "вик", "ран", "ат", "ом", "вар", "тор", "фон", "лог", "ром",
	"рез", "уб", "вод", "акт", "пан", "док", "век", "мер", "мас", "бол", "коп", "дел",
	"сон", "мет", "дик", "жу", "кол", "пит", "аст", "ант", "лос", "тел", "ист", "род",
	"ник", "кин", "рог", "ск", "ход", "лов", "тик", "ост", "аз", "хоз", "вед", "лом",
	"уз",
]

const RUSSIAN_HARD: Array[String] = [
	"изм", "суда", "инт", "ласт", "метр",
]

const ENGLISH_EASY: Array[String] = [
	"ST", "TH", "SH", "CH", "TR", "PL", "BL", "BR", "CL", "CR", "DR", "FL",
	"FR", "GL", "GR", "SP", "AND", "ING", "ALL", "AY", "ATE", "ONE", "OLD", "ACE",
	"AGE", "AIN", "AKE", "AME", "ARE", "ICE", "IDE", "IKE", "INE", "END", "EST", "ILL",
	"ICK", "OOK", "OON", "EAR", "EAT", "ELL", "ANT",
]

const ENGLISH_MEDIUM: Array[String] = [
	"KN", "PH", "SC", "SK", "SL", "SM", "SN", "SW", "TW", "WH", "WR", "STR",
	"ANG", "ANK", "AST", "ECK", "INK", "OCK", "ONG", "AMP", "ARK", "ENT", "IND", "INT",
	"ISH", "ITE", "OOM", "UST", "ALE", "ANE", "APE", "AVE", "EED", "EEN", "EEP", "EER",
	"EET", "IFE", "ILE", "IME", "IPE", "IRE", "ISE", "IVE", "OKE", "OOL", "ORE", "OSE",
	"OTE",
]

const ENGLISH_HARD: Array[String] = [
	"PR", "SHR", "THR", "UNK", "GHT", "ILD",
]

const SERBIAN_EASY: Array[String] = [
	"БА", "БЕ", "БИ", "БО", "БУ", "ВА", "ВЕ", "ВИ", "ВО", "ВУ", "ДА", "ДЕ",
	"ДИ", "ДО", "ДУ", "КА", "КЕ", "КИ", "КО", "КУ", "МА", "МЕ", "МИ", "МО",
	"МУ", "ПА", "ПЕ", "ПИ", "ПО", "ПУ", "РА", "РЕ", "РИ", "РО", "РУ", "СА",
	"СЕ", "СИ", "СО", "СУ", "ТА", "ТЕ", "ТИ", "ТО", "ТУ", "АН", "ЕН", "ИН",
	"ОН", "АТ", "ЕТ", "ИТ", "ОТ", "АР", "ЕР", "ОР",
]

const SERBIAN_MEDIUM: Array[String] = [
	"СТ", "ПР", "ТР", "КР", "ГР", "БР", "ВР", "СП", "СК", "СМ", "СН", "ПЛ",
	"КЛ", "ГЛ", "ДР", "БЛ", "АК", "ЕК", "ИК", "ОК", "УК", "ИР", "УР", "УН",
	"АЦ", "ЕЦ", "ИЦ", "АВ", "ЕВ", "ИВ", "ОВ", "УВ", "АШ", "ЕШ", "ИШ", "УТ",
]

const SERBIAN_HARD: Array[String] = [
	"ФЛ", "ЗД", "ЗВ", "ЗМ", "ЦВ", "ЧВ", "ФР", "ШТ", "ШК", "ШП", "ХВ", "ХР",
	"ПС", "ЊЕ", "ОЦ", "УЦ", "ОШ", "УШ",
]

const SPANISH_EASY: Array[String] = [
	"BA", "BE", "BI", "BO", "BU", "CA", "CE", "CI", "CO", "CU", "DA", "DE",
	"DI", "DO", "DU", "MA", "ME", "MI", "MO", "MU", "PA", "PE", "PI", "PO",
	"PU", "RA", "RE", "RI", "RO", "RU", "SA", "SE", "SI", "SO", "SU", "TA",
	"TE", "TI", "TO", "TU", "AL", "AN", "AR", "EN", "ER", "ES", "IN", "ON",
	"OR", "CH", "LL", "QU", "TR", "PL", "BL", "BR", "CL", "CR", "GR",
]

const SPANISH_MEDIUM: Array[String] = [
	"DR", "FL", "FR", "GL", "PR", "RR", "EST", "ESP", "ESC", "TRA", "PRE", "PRO",
	"PRI", "BRA", "CLA", "AD", "AS", "ED", "EL", "ID", "IL", "IR", "IS", "OS",
	"UN", "UR", "US", "IA", "IO", "IE", "FA", "FE", "FI", "FO", "FU", "GA",
	"GO", "GU", "JA", "JO", "JU", "UE", "UA",
]

const SPANISH_HARD: Array[String] = [
	"GUE", "GUI", "CRI", "PLU", "FLE", "AZ", "EZ", "IZ", "OZ", "UI", "UO", "GE",
	"GI", "JE", "JI",
]

const HINDI_EASY: Array[String] = [
	"अ", "आ", "इ", "ई", "उ", "ऊ", "ए", "ओ", "क", "ग", "च", "ज",
	"त", "द", "न", "प", "ब", "म", "य", "र", "ल", "व", "स", "ह",
	"का", "गा", "चा", "जा", "ता", "दा", "ना", "पा", "मा", "या", "रा", "ला",
	"वा", "सा", "हा", "कि", "गि", "चि", "जि", "ति", "दि", "नि", "पि", "बि",
	"मि", "रि", "लि", "सि", "हि",
]

const HINDI_MEDIUM: Array[String] = [
	"ऐ", "औ", "ख", "घ", "छ", "झ", "ट", "ठ", "ड", "ढ", "थ", "ध",
	"फ", "भ", "श", "ष", "वि", "अं", "कं", "गं", "नं", "पं", "मं", "सं",
	"हं", "क्र", "प्र", "त्र", "श्र", "स्व", "स्त",
]

const HINDI_HARD: Array[String] = [
	"क्ष", "ज्ञ", "स्थ", "स्प", "द्र", "ध्य", "न्त्य", "च्छ", "ज्व", "क्त", "ष्ण", "ह्य",
	"द्व", "चं", "जं", "तं", "दं", "ऑ", "डॉ", "ख़", "ग़", "ज़", "फ़", "ड़",
	"ढ़",
]

const GERMAN_EASY: Array[String] = [
	"AL", "AND", "END", "UND", "ALL", "EIN", "TER", "BER", "GEN", "TEN", "ST", "SP",
	"CH", "CK", "SCH", "UNG", "VER", "VOR", "ACH", "ICH", "ANG", "ING", "ELL", "ILL",
	"ANN", "ENN", "EST", "IST", "ART", "AUS",
]

const GERMAN_MEDIUM: Array[String] = [
	"TRA", "ENT", "LAN", "BAR", "LIC", "OCH", "UCH", "IND", "ANK", "INK", "AMP", "UMP",
	"ONG", "ECK", "ICK", "OCK", "UCK", "AST", "OST", "ALT", "ELT", "ILT", "OLT", "ARG",
	"ORT",
]

const GERMAN_HARD: Array[String] = [
]

const FRENCH_EASY: Array[String] = [
	"AN", "EN", "IN", "ON", "UN", "ER", "AI", "OU", "AU", "EU", "CH", "QU",
	"ANT", "ENT", "AGE", "ION", "EUR", "EST", "ALL", "ELL", "BL", "BR", "CL", "CR",
	"DR", "FL", "FR", "GL", "GR", "PL", "PR", "TR",
]

const FRENCH_MEDIUM: Array[String] = [
	"AM", "EM", "IM", "OM", "AIN", "EZ", "AIS", "AIT", "ILL", "OI", "UI", "EAU",
	"ART", "ARD", "OUR", "OIR", "IER", "ETTE", "VR", "SC", "SP", "GU",
]

const FRENCH_HARD: Array[String] = [
]

const ITALIAN_EASY: Array[String] = [
	"CH", "CI", "GI", "CE", "GE", "SC", "QU", "ST", "SP", "TR", "PR", "BR",
	"CR", "GR", "PL", "BL", "CL", "AL", "EL", "IL", "OL", "AR", "ER", "IR",
	"OR", "AN", "EN", "IN", "ON", "UN", "ATO", "ONE", "INO", "NT", "ND",
]

const ITALIAN_MEDIUM: Array[String] = [
	"GH", "GL", "GN", "UTO", "ITO", "ARI", "GIO", "FR", "DR", "FL", "MP", "MB",
	"NS", "NC", "EST", "ANT", "ZIO", "NZA",
]

const ITALIAN_HARD: Array[String] = [
	"BCO", "PS",
]

static func normalize_difficulty(value: Variant) -> int:
	var level := int(value) if value != null else DEFAULT_DIFFICULTY
	return clampi(level, DIFFICULTY_EASY, DIFFICULTY_HARD)

static func _tiers_for(locale: String) -> Array:
	match LocaleCatalog.normalize(locale):
		LocaleCatalog.LOCALE_EN:
			return [ENGLISH_EASY, ENGLISH_MEDIUM, ENGLISH_HARD]
		LocaleCatalog.LOCALE_SR:
			return [SERBIAN_EASY, SERBIAN_MEDIUM, SERBIAN_HARD]
		LocaleCatalog.LOCALE_ES:
			return [SPANISH_EASY, SPANISH_MEDIUM, SPANISH_HARD]
		LocaleCatalog.LOCALE_HI:
			return [HINDI_EASY, HINDI_MEDIUM, HINDI_HARD]
		LocaleCatalog.LOCALE_DE:
			return [GERMAN_EASY, GERMAN_MEDIUM, GERMAN_HARD]
		LocaleCatalog.LOCALE_FR:
			return [FRENCH_EASY, FRENCH_MEDIUM, FRENCH_HARD]
		LocaleCatalog.LOCALE_IT:
			return [ITALIAN_EASY, ITALIAN_MEDIUM, ITALIAN_HARD]
		_:
			return [RUSSIAN_EASY, RUSSIAN_MEDIUM, RUSSIAN_HARD]


static func get_cards(locale: String, difficulty: int = DEFAULT_DIFFICULTY) -> PackedStringArray:
	var level := normalize_difficulty(difficulty)
	var tiers: Array = _tiers_for(locale)
	var result: Array[String] = []
	result.append_array(tiers[0])
	if level >= DIFFICULTY_MEDIUM:
		result.append_array(tiers[1])
	if level >= DIFFICULTY_HARD:
		result.append_array(tiers[2])
	return PackedStringArray(result)

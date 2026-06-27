class_name GameDecks
extends RefCounted

const RUSSIAN_CARDS: Array[String] = [
	"лом", "ка", "ев", "ма", "ли", "ук", "за", "вед", "ди", "ло", "аз", "ост",
	"от", "мат", "воз", "лю", "вик", "да", "хоз", "ран", "ат", "те", "ом",
	"ал", "ак", "ов", "изм", "вар", "га", "тор", "ус", "та", "ро", "ад",
	"фон", "лог", "ром", "он", "рез", "уб", "ни", "во", "вод", "акт", "по",
	"ча", "ор", "пан", "ле", "док", "не", "ке", "век", "мер", "мас", "бол",
	"суда", "ок", "па", "коп", "дел", "ил", "со", "на", "мо", "уз", "ар",
	"ки", "сон", "мет", "ик", "са", "ба", "то", "дик", "жу", "хо", "од",
	"инт", "ко", "ласт", "ун", "кол", "ан", "но", "пит", "ру", "ит", "аст",
	"ант", "лос", "му", "тел", "ист", "ам", "род", "ин", "ник", "кин", "ра",
	"рог", "ла", "ва", "ск", "ти", "ход", "лов", "тик", "метр", "ас",
]

const ENGLISH_CARDS: Array[String] = [
	"BL", "BR", "CH", "CL", "CR", "DR", "FL", "FR", "GL", "GR", "KN", "PH", "PL", "PR",
	"SC", "SH", "SK", "SL", "SM", "SN", "SP", "ST", "SW", "TH", "TR", "TW", "WH", "WR",
	"SHR", "STR", "THR", "ANG", "ANK", "AST", "ECK", "ELL", "END", "EST", "ICK", "ILL",
	"ING", "INK", "OCK", "ONG", "UNK", "ALL", "AMP", "AND", "ANT", "ARK", "ENT", "GHT",
	"ILD", "IND", "INT", "ISH", "ITE", "OOM", "UST", "ACE", "AGE", "AIN", "AKE", "ALE",
	"AME", "ANE", "APE", "ARE", "ATE", "AVE", "AY", "EAR", "EAT", "EED", "EEN", "EEP",
	"EER", "EET", "ICE", "IDE", "IFE", "IKE", "ILE", "IME", "INE", "IPE", "IRE", "ISE",
	"IVE", "OKE", "OLD", "ONE", "OOK", "OOL", "OON", "ORE", "OSE", "OTE",
]

const SERBIAN_CARDS: Array[String] = [
	"СТ", "ПР", "ТР", "КР", "ГР", "БР", "ВР", "СП", "СК", "СМ",
	"СН", "ПЛ", "КЛ", "ГЛ", "ФЛ", "ЗД", "ЗВ", "ЗМ", "ЦВ", "ЧВ",
	"ДР", "ФР", "ШТ", "ШК", "ШП", "ХВ", "ХР", "БЛ", "ПС", "ЊЕ",
	"АК", "ЕК", "ИК", "ОК", "УК", "АР", "ЕР", "ИР", "ОР", "УР",
	"АН", "ЕН", "ИН", "ОН", "УН", "АЦ", "ЕЦ", "ИЦ", "ОЦ", "УЦ",
	"АШ", "ЕШ", "ИШ", "ОШ", "УШ", "АТ", "ЕТ", "ИТ", "ОТ", "УТ",
	"АВ", "ЕВ", "ИВ", "ОВ", "УВ",
	"БА", "БЕ", "БИ", "БО", "БУ", "ВА", "ВЕ", "ВИ", "ВО", "ВУ",
	"ДА", "ДЕ", "ДИ", "ДО", "ДУ", "КА", "КЕ", "КИ", "КО", "КУ",
	"МА", "МЕ", "МИ", "МО", "МУ", "ПА", "ПЕ", "ПИ", "ПО", "ПУ",
	"РА", "РЕ", "РИ", "РО", "РУ", "СА", "СЕ", "СИ", "СО", "СУ",
	"ТА", "ТЕ", "ТИ", "ТО", "ТУ",
]

const SPANISH_CARDS: Array[String] = [
	"BL", "BR", "CL", "CR", "DR", "FL", "FR", "GL", "GR", "PL",
	"PR", "TR", "CH", "LL", "RR", "QU", "GUE", "GUI", "EST", "ESP",
	"ESC", "TRA", "PRE", "PRO", "PRI", "BRA", "CRI", "CLA", "PLU", "FLE",
	"AD", "AL", "AN", "AR", "AS", "ED", "EL", "EN", "ER", "ES",
	"ID", "IL", "IN", "IR", "IS", "ON", "OR", "OS", "UN", "UR",
	"US", "AZ", "EZ", "IZ", "OZ", "IA", "IO", "IE", "UA", "UE", "UI", "UO",
	"BA", "BE", "BI", "BO", "BU", "CA", "CE", "CI", "CO", "CU",
	"DA", "DE", "DI", "DO", "DU", "FA", "FE", "FI", "FO", "FU",
	"GA", "GE", "GI", "GO", "GU", "JA", "JE", "JI", "JO", "JU",
	"MA", "ME", "MI", "MO", "MU", "PA", "PE", "PI", "PO", "PU",
	"RA", "RE", "RI", "RO", "RU", "SA", "SE", "SI", "SO", "SU",
	"TA", "TE", "TI", "TO", "TU",
]

const HINDI_CARDS: Array[String] = [
	"अ", "आ", "इ", "ई", "उ", "ऊ", "ए", "ऐ", "ओ", "औ",
	"क", "ख", "ग", "घ", "च", "छ", "ज", "झ", "ट", "ठ",
	"ड", "ढ", "त", "थ", "द", "ध", "न", "प", "फ", "ब",
	"भ", "म", "य", "र", "ल", "व", "श", "ष", "स", "ह",
	"का", "गा", "चा", "जा", "ता", "दा", "ना", "पा", "मा", "या",
	"रा", "ला", "वा", "सा", "हा", "कि", "गि", "चि", "जि", "ति",
	"दि", "नि", "पि", "बि", "मि", "रि", "लि", "वि", "सि", "हि",
	"क्र", "प्र", "त्र", "क्ष", "ज्ञ", "श्र", "स्व", "स्थ", "स्प", "स्त",
	"द्र", "ध्य", "न्त्य", "च्छ", "ज्व", "क्त", "ष्ण", "ह्य", "द्व",
	"अं", "कं", "गं", "चं", "जं", "तं", "दं", "नं", "पं", "मं",
	"सं", "हं", "ऑ", "डॉ", "ख़", "ग़", "ज़", "फ़", "ड़", "ढ़",
]

const GERMAN_CARDS: Array[String] = [
	"TRA", "AL", "ENT", "ART", "LAN",
	"UNG", "VER", "VOR", "BAR", "LIC",
	"ACH", "ICH", "OCH", "UCH", "AUS",
	"SCH", "CH", "CK", "ST", "SP",
	"EIN", "TER", "BER", "GEN", "TEN",
	"AND", "END", "IND", "UND", "ALL",
	"ELL", "ILL", "ANK", "INK", "AMP",
	"UMP", "ANG", "ING", "ONG", "ECK",
	"ICK", "OCK", "UCK", "AST", "EST",
	"IST", "OST", "ANN", "ENN", "ALT",
	"ELT", "ILT", "OLT", "ARG", "ORT",
]

const FRENCH_CARDS: Array[String] = [
	"AN", "AM", "EN", "EM", "IN", "IM", "ON", "OM", "UN", "AIN",
	"ER", "EZ", "AI", "AIS", "AIT", "ANT", "ENT", "AGE", "ION", "EUR",
	"CH", "QU", "GU", "ILL", "OU", "OI", "UI", "AU", "EAU", "EU",
	"ART", "ARD", "OUR", "OIR", "IER", "EST", "ALL", "ELL", "ETTE",
	"BL", "BR", "CL", "CR", "DR", "FL", "FR", "GL", "GR", "PL",
	"PR", "TR", "VR", "SC", "SP",
]

const ITALIAN_CARDS: Array[String] = [
	"CH", "GH", "GL", "GN", "CI", "GI", "CE", "GE", "SC", "QU",
	"ATO", "UTO", "ITO", "ONE", "INO", "ARI", "ZIO", "BCO", "NZA", "GIO",
	"ST", "SP", "TR", "PR", "BR", "CR", "GR", "FR", "DR", "PL",
	"BL", "CL", "FL", "PS", "MP", "MB", "NT", "ND", "NS", "NC",
	"AL", "EL", "IL", "OL", "AR", "ER", "IR", "OR", "AN", "EN",
	"IN", "ON", "UN", "EST", "ANT",
]


static func get_cards(locale: String) -> PackedStringArray:
	match LocaleCatalog.normalize(locale):
		LocaleCatalog.LOCALE_EN:
			return PackedStringArray(ENGLISH_CARDS)
		LocaleCatalog.LOCALE_SR:
			return PackedStringArray(SERBIAN_CARDS)
		LocaleCatalog.LOCALE_ES:
			return PackedStringArray(SPANISH_CARDS)
		LocaleCatalog.LOCALE_HI:
			return PackedStringArray(HINDI_CARDS)
		LocaleCatalog.LOCALE_DE:
			return PackedStringArray(GERMAN_CARDS)
		LocaleCatalog.LOCALE_FR:
			return PackedStringArray(FRENCH_CARDS)
		LocaleCatalog.LOCALE_IT:
			return PackedStringArray(ITALIAN_CARDS)
		_:
			return PackedStringArray(RUSSIAN_CARDS)

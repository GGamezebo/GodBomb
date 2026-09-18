class_name GameDecks
extends RefCounted

const DIFFICULTY_EASY := 0
const DIFFICULTY_MEDIUM := 1
const DIFFICULTY_HARD := 2
const DEFAULT_DIFFICULTY := DIFFICULTY_MEDIUM

## Restriction flags: "B" = hard at word start, "E" = hard at word end, "BE" = both.
## Standard locales (BEGIN/END/ANYWHERE): forbid Type.BEGIN if B, Type.END if E.
## Exclusion locales FR/IT (NOT_BEGIN / NOT_END): B forbids Type.END, E forbids Type.BEGIN.

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

const RUSSIAN_RESTRICT: Dictionary = {
	"изм": "B",
	"инт": "E",
	"коп": "E",
	"мас": "E",
	"кин": "E",
	"лю": "E",
}

# English: Pass the Bomb (Piatnik 1994) letter cards + Bomb Party easy clusters.
const ENGLISH_EASY: Array[String] = [
	"ST", "TH", "SH", "CH", "TR", "PL", "BL", "BR", "CL", "CR", "DR", "FL",
	"FR", "GR", "SP", "AND", "ING", "ALL", "AL", "EN", "AT", "OR", "RE", "TO",
	"SO", "PA", "MA", "BO", "DO", "HO", "LE", "EL", "IN", "ON", "AR", "ER",
	"CAR", "CAT", "SHE", "STR", "EAR", "EAT", "ILL", "ANT", "ENT",
]

const ENGLISH_MEDIUM: Array[String] = [
	"ACK", "ACT", "AME", "ANG", "ANK", "ARM", "CEN", "CI", "CRI", "DEN",
	"FRE", "GER", "GLA", "HAL", "HIN", "IA", "IG", "IMP", "INC", "IND",
	"IR", "JO", "LAY", "MB", "MER", "OND", "OUR", "PIC", "PLE", "POR",
	"RAT", "RES", "RIC", "STE", "TCH", "TEL", "TIC", "TOR", "UNT", "VAN",
	"TER", "EST", "ACE", "AGE", "ATE", "OCK",
]

const ENGLISH_HARD: Array[String] = [
	"GHT", "KN", "WR", "THR", "SHR", "UNK", "ILD", "PS", "OX", "UB",
	"VO", "WO", "OCH", "OLL", "ABS", "DUC", "NAP", "RIB", "RIG", "PEA",
	"PED", "AU", "BES", "WH", "TW", "SW", "SK", "SL", "SM", "SN",
	"SC", "PR", "PH", "FF", "RR", "KL",
]

const ENGLISH_RESTRICT: Dictionary = {
	"ING": "B",
	"ACK": "B",
	"TCH": "B",
	"GHT": "B",
	"OCK": "B",
	"ILD": "B",
	"OLL": "B",
	"OCH": "B",
	"OND": "B",
	"IA": "B",
	"MB": "B",
	"UB": "B",
	"FF": "B",
	"RR": "B",
	"PS": "E",
	"STR": "E",
	"BL": "E",
	"BR": "E",
	"CL": "E",
	"CR": "E",
	"DR": "E",
	"FL": "E",
	"FR": "E",
	"GR": "E",
	"PL": "E",
	"SP": "E",
	"TR": "E",
	"PR": "E",
	"WR": "E",
	"KN": "E",
	"WH": "E",
	"TW": "E",
	"SW": "E",
	"SL": "E",
	"SM": "E",
	"SN": "E",
	"SC": "E",
	"KL": "E",
	"THR": "E",
	"SHR": "E",
	"GLA": "E",
	"CRI": "E",
	"FRE": "E",
	"STE": "E",
	"SHE": "E",
	"IMP": "E",
	"INC": "E",
	"CEN": "E",
	"CI": "E",
	"RES": "E",
	"VO": "E",
	"WO": "E",
}

# Serbian: Piatnik-style CV syllables + clusters (Balkan Tik Tak Bum).
const SERBIAN_EASY: Array[String] = [
	"БА", "БЕ", "БИ", "БО", "БУ", "ВА", "ВЕ", "ВИ", "ВО", "ВУ", "ДА", "ДЕ",
	"ДИ", "ДО", "ДУ", "КА", "КЕ", "КИ", "КО", "КУ", "МА", "МЕ", "МИ", "МО",
	"МУ", "ПА", "ПЕ", "ПИ", "ПО", "ПУ", "РА", "РЕ", "РИ", "РО", "РУ", "СА",
	"СЕ", "СИ", "СО", "СУ", "ТА", "ТЕ", "ТИ", "ТО", "ТУ", "АН", "ЕН", "ИН",
	"ОН", "АТ", "ЕТ", "ИТ", "ОТ", "АР", "ЕР", "ОР", "ЛА", "ЛЕ", "ЛИ", "ЛО",
	"НА", "НЕ", "НИ", "НО", "ЈА", "ЈЕ",
]

const SERBIAN_MEDIUM: Array[String] = [
	"СТ", "ПР", "ТР", "КР", "ГР", "БР", "ВР", "СП", "СК", "СМ", "СН", "ПЛ",
	"КЛ", "ГЛ", "ДР", "БЛ", "АК", "ЕК", "ИК", "ОК", "УК", "ИР", "УР", "УН",
	"АЦ", "ЕЦ", "ИЦ", "АВ", "ЕВ", "ИВ", "ОВ", "УВ", "АШ", "ЕШ", "ИШ", "УТ",
	"АЈ", "ОЈ", "ОСТ", "НИК", "СТВ", "ИЦА",
]

const SERBIAN_HARD: Array[String] = [
	"ФЛ", "ЗД", "ЗВ", "ЗМ", "ЦВ", "ЧВ", "ФР", "ШТ", "ШК", "ШП", "ХВ", "ХР",
	"ПС", "ЊЕ", "ОЦ", "УЦ", "ОШ", "УШ", "ЉУ", "ЊА", "ЋЕ", "ЂА", "ЖД",
]

const SERBIAN_RESTRICT: Dictionary = {
	"ПР": "E",
	"ТР": "E",
	"КР": "E",
	"ГР": "E",
	"БР": "E",
	"ВР": "E",
	"СП": "E",
	"СМ": "E",
	"СН": "E",
	"ПЛ": "E",
	"КЛ": "E",
	"ГЛ": "E",
	"ДР": "E",
	"БЛ": "E",
	"ФЛ": "E",
	"ЗВ": "E",
	"ЗМ": "E",
	"ЦВ": "E",
	"ЧВ": "E",
	"ФР": "E",
	"ШК": "E",
	"ШП": "E",
	"ХВ": "E",
	"ХР": "E",
	"ПС": "E",
	"ЉУ": "E",
	"ЂА": "E",
	"СТВ": "B",
	"ИЦА": "B",
	"ЖД": "BE",
	"ОЦ": "E",
	"УЦ": "E",
}

# Spanish: Goliath Tic Tac Boum sílabas + sílabas trabadas.
const SPANISH_EASY: Array[String] = [
	"BA", "BE", "BI", "BO", "BU", "CA", "CE", "CI", "CO", "CU", "DA", "DE",
	"DI", "DO", "DU", "MA", "ME", "MI", "MO", "MU", "PA", "PE", "PI", "PO",
	"PU", "RA", "RE", "RI", "RO", "RU", "SA", "SE", "SI", "SO", "SU", "TA",
	"TE", "TI", "TO", "TU", "AL", "AN", "AR", "EN", "ER", "ES", "IN", "ON",
	"OR", "CH", "LL", "QU", "TR", "PL", "BL", "BR", "CL", "CR", "GR", "LA",
	"LO", "NA",
]

const SPANISH_MEDIUM: Array[String] = [
	"DR", "FL", "FR", "GL", "PR", "RR", "EST", "ESP", "ESC", "TRA", "TRE", "TRI",
	"PRE", "PRO", "PRI", "BRA", "CLA", "ADO", "IDO", "ANTE", "AD", "AS", "ED",
	"EL", "ID", "IL", "IR", "IS", "OS", "UN", "UR", "US", "IA", "IO", "IE",
	"FA", "FE", "FI", "FO", "FU", "GA", "GO", "GU", "JA", "JO", "JU", "UE",
	"UA", "DAD",
]

const SPANISH_HARD: Array[String] = [
	"GUE", "GUI", "CRI", "PLU", "FLE", "AZ", "EZ", "IZ", "OZ", "UI", "UO", "GE",
	"GI", "JE", "JI", "TRO", "IÓN", "ÑA", "ÑO", "TL", "BLE", "MENTE",
]

const SPANISH_RESTRICT: Dictionary = {
	"RR": "BE",
	"LL": "E",
	"CH": "E",
	"QU": "E",
	"BL": "E",
	"BR": "E",
	"CL": "E",
	"CR": "E",
	"DR": "E",
	"FL": "E",
	"FR": "E",
	"GL": "E",
	"GR": "E",
	"PL": "E",
	"PR": "E",
	"TR": "E",
	"TRA": "E",
	"TRE": "E",
	"TRI": "E",
	"TRO": "E",
	"PRE": "E",
	"PRO": "E",
	"PRI": "E",
	"BRA": "E",
	"CLA": "E",
	"CRI": "E",
	"PLU": "E",
	"FLE": "E",
	"EST": "E",
	"ESP": "E",
	"ESC": "E",
	"GUI": "E",
	"IÓN": "B",
	"ÑA": "B",
	"ÑO": "B",
	"TL": "BE",
	"DAD": "B",
	"BLE": "B",
	"IDO": "B",
}

const HINDI_EASY: Array[String] = [
	"अ", "आ", "इ", "ई", "उ", "ए", "ओ", "क", "ग", "च", "ज",
	"त", "द", "न", "प", "ब", "म", "य", "र", "ल", "व", "स", "ह",
	"का", "गा", "चा", "जा", "ता", "दा", "ना", "पा", "मा", "या", "रा", "ला",
	"वा", "सा", "हा", "कि", "गि", "चि", "जि", "ति", "दि", "नि", "पि", "बि",
	"मि", "रि", "लि", "सि", "हि",
]

const HINDI_MEDIUM: Array[String] = [
	"ऊ", "ऐ", "औ", "ख", "घ", "छ", "झ", "ट", "ठ", "ड", "ढ", "थ", "ध",
	"फ", "भ", "श", "ष", "वि", "अं", "कं", "गं", "नं", "पं", "मं", "सं",
	"हं", "क्र", "प्र", "त्र", "श्र", "स्व", "स्त",
]

const HINDI_HARD: Array[String] = [
	"क्ष", "ज्ञ", "स्थ", "स्प", "द्र", "ध्य", "न्त्य", "च्छ", "ज्व", "क्त", "ष्ण", "ह्य",
	"द्व", "चं", "जं", "तं", "दं", "ऑ", "डॉ", "ख़", "ग़", "ज़", "फ़", "ड़",
	"ढ़",
]

const HINDI_RESTRICT: Dictionary = {
	"अ": "E",
	"आ": "E",
	"इ": "E",
	"ई": "E",
	"उ": "E",
	"ऊ": "E",
	"ए": "E",
	"ऐ": "E",
	"ओ": "E",
	"औ": "E",
	"ऑ": "E",
	"अं": "E",
	"कं": "E",
	"गं": "E",
	"नं": "E",
	"पं": "E",
	"मं": "E",
	"सं": "E",
	"हं": "E",
	"चं": "E",
	"जं": "E",
	"तं": "E",
	"दं": "E",
	"क्ष": "E",
	"ज्ञ": "E",
	"स्थ": "E",
	"स्प": "E",
	"द्र": "E",
	"ध्य": "E",
	"न्त्य": "BE",
	"च्छ": "E",
	"ज्व": "E",
	"क्त": "E",
	"ष्ण": "BE",
	"ह्य": "BE",
	"द्व": "E",
	"क्र": "E",
	"प्र": "E",
	"त्र": "E",
	"श्र": "E",
	"स्व": "E",
	"स्त": "E",
	"डॉ": "E",
	"ड़": "B",
	"ढ़": "B",
}

# German: Tick Tack Bumm Buchstabengruppen (TRA, AL, ENT, SCH, UNG, OHL, ÄL, …).
const GERMAN_EASY: Array[String] = [
	"AL", "EN", "ER", "EL", "IN", "UN", "AN", "ST", "SP", "CH", "SCH", "EIN",
	"AND", "END", "UND", "ALL", "TER", "BER", "GEN", "TEN", "UNG", "VER", "ACH", "ICH",
	"ANG", "ING", "EST", "IST", "ART", "AUS", "GE", "BE", "TE", "LE", "IE", "DE",
	"RE", "HE",
]

const GERMAN_MEDIUM: Array[String] = [
	"TRA", "ENT", "LAN", "BAR", "LICH", "OCH", "UCH", "IND", "ANK", "INK", "AMP", "ECK",
	"ICK", "OCK", "UCK", "AST", "OST", "ALT", "ELT", "ORT", "HEIT", "KEIT", "ISCH", "PF",
	"TZ", "CK", "VOR", "ANN", "ENN", "ILL", "ELL", "ARG", "WI", "WEN", "ONG",
]

const GERMAN_HARD: Array[String] = [
	"OHL", "AUL", "BLI", "ÄL", "DRI", "UMP", "ILT", "OLT", "SCHR", "PFL", "SPR", "STR",
	"QU", "ÖL", "ÄU", "EU", "AU", "CHR", "ZW", "KN", "PS", "GL", "BR", "KR",
]

const GERMAN_RESTRICT: Dictionary = {
	"UNG": "B",
	"HEIT": "B",
	"KEIT": "B",
	"LICH": "B",
	"ISCH": "B",
	"CK": "B",
	"TZ": "B",
	"OHL": "B",
	"ÄL": "B",
	"ILT": "B",
	"OLT": "B",
	"UMP": "B",
	"ONG": "B",
	"OCK": "B",
	"UCK": "B",
	"TRA": "E",
	"VER": "E",
	"VOR": "E",
	"SP": "E",
	"WI": "E",
	"WEN": "E",
	"BLI": "E",
	"DRI": "E",
	"SCHR": "E",
	"PFL": "E",
	"SPR": "E",
	"STR": "E",
	"QU": "E",
	"CHR": "E",
	"ZW": "E",
	"KN": "E",
	"PS": "BE",
	"GL": "E",
	"BR": "E",
	"KR": "E",
	"AUL": "B",
	"ÖL": "E",
}

# French: Tic Tac Boum cartes sons (SAN, UN, JAN, LA, TE, PA, OI, OIN, ION, …).
const FRENCH_EASY: Array[String] = [
	"AN", "EN", "IN", "ON", "UN", "ER", "OU", "AU", "EU", "CH", "QU", "ANT",
	"ENT", "AGE", "ION", "EUR", "EST", "ALL", "ELL", "LA", "TE", "PA", "OI", "AI",
	"LE", "RE", "DE", "ME", "TA", "RA", "TR", "PL", "BL", "BR", "CR", "GR",
	"PR", "ET", "OR",
]

const FRENCH_MEDIUM: Array[String] = [
	"AM", "EM", "IM", "OM", "AIN", "EZ", "AIS", "AIT", "ILL", "UI", "EAU", "ART",
	"ARD", "OUR", "OIR", "IER", "ETTE", "SAN", "JAN", "OIN", "IEN", "EIN", "MENT", "TION",
	"QUE", "GUI", "GUE", "VR", "SC", "SP", "DR", "FL", "FR", "GL", "CL", "ES",
	"IR", "UR",
]

const FRENCH_HARD: Array[String] = [
	"GN", "PH", "TH", "YE", "OEU", "AIL", "EIL", "EUIL", "RH", "OY", "UY", "OUIL",
	"OE", "PT", "MN", "GU",
]

const FRENCH_RESTRICT: Dictionary = {
	"ION": "B",
	"TION": "B",
	"ETTE": "B",
	"OIR": "B",
	"OIN": "B",
	"IEN": "B",
	"EIN": "B",
	"AIL": "B",
	"EIL": "B",
	"EUIL": "B",
	"OUIL": "B",
	"GN": "B",
	"OEU": "B",
	"PT": "B",
	"MN": "B",
	"YE": "B",
	"RH": "B",
	"BL": "E",
	"BR": "E",
	"CL": "E",
	"CR": "E",
	"DR": "E",
	"FL": "E",
	"FR": "E",
	"GL": "E",
	"GR": "E",
	"PL": "E",
	"PR": "E",
	"TR": "E",
	"SP": "E",
	"SC": "E",
	"QU": "E",
	"GUI": "E",
	"VR": "E",
	"SAN": "E",
	"JAN": "E",
	"PH": "E",
	"TH": "E",
	"GU": "E",
}

# Italian: Passa la Bomba 2–3 letter combinations.
const ITALIAN_EASY: Array[String] = [
	"CH", "CI", "GI", "CE", "GE", "SC", "QU", "ST", "SP", "TR", "PR", "BR",
	"CR", "GR", "PL", "BL", "CL", "AL", "EL", "IL", "OL", "AR", "ER", "IR",
	"OR", "AN", "EN", "IN", "ON", "UN", "ATO", "ONE", "INO", "NT", "ND", "LA",
	"LE", "RA", "RE", "TA", "TO", "MA", "CA", "PA", "SA",
]

const ITALIAN_MEDIUM: Array[String] = [
	"GH", "GL", "GN", "UTO", "ITO", "ARI", "GIO", "FR", "DR", "FL", "MP", "MB",
	"NS", "NC", "EST", "ANT", "ZIO", "NZA", "STR", "PRE", "PRO", "TRA", "ARE", "ERE",
	"IRE", "ELL", "ITA", "CIA", "CIO", "GIU", "MENT", "ZZA", "CO", "LO", "NO",
]

const ITALIAN_HARD: Array[String] = [
	"BCO", "PS", "CCH", "GGH", "SCI", "SCH", "GLI", "SCE", "GNI", "NCH", "ZZ", "ZI",
]

const ITALIAN_RESTRICT: Dictionary = {
	"ATO": "B",
	"UTO": "B",
	"ITO": "B",
	"ONE": "B",
	"NZA": "B",
	"ZZA": "B",
	"MENT": "B",
	"ELL": "B",
	"BCO": "BE",
	"CCH": "BE",
	"GGH": "BE",
	"PS": "E",
	"BL": "E",
	"BR": "E",
	"CL": "E",
	"CR": "E",
	"DR": "E",
	"FL": "E",
	"FR": "E",
	"GL": "E",
	"GR": "E",
	"PL": "E",
	"PR": "E",
	"TR": "E",
	"SP": "E",
	"STR": "E",
	"PRE": "E",
	"PRO": "E",
	"TRA": "E",
	"QU": "E",
	"GH": "E",
	"SCI": "E",
	"SCH": "E",
	"GLI": "E",
	"SCE": "E",
	"GNI": "E",
	"NCH": "E",
	"ZIO": "E",
	"MP": "B",
	"MB": "B",
	"ZZ": "B",
}


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


static func _restrictions_for(locale: String) -> Dictionary:
	match LocaleCatalog.normalize(locale):
		LocaleCatalog.LOCALE_EN:
			return ENGLISH_RESTRICT
		LocaleCatalog.LOCALE_SR:
			return SERBIAN_RESTRICT
		LocaleCatalog.LOCALE_ES:
			return SPANISH_RESTRICT
		LocaleCatalog.LOCALE_HI:
			return HINDI_RESTRICT
		LocaleCatalog.LOCALE_DE:
			return GERMAN_RESTRICT
		LocaleCatalog.LOCALE_FR:
			return FRENCH_RESTRICT
		LocaleCatalog.LOCALE_IT:
			return ITALIAN_RESTRICT
		_:
			return RUSSIAN_RESTRICT


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


static func allowed_conditions(locale: String, syllable: String) -> Array[int]:
	var flags := str(_restrictions_for(locale).get(syllable, ""))
	var hard_begin := flags.contains("B")
	var hard_end := flags.contains("E")
	var result: Array[int] = [WordCondition.Type.ANYWHERE]
	if LocaleCatalog.uses_exclusion_conditions(locale):
		if not hard_end:
			result.append(WordCondition.Type.BEGIN)
		if not hard_begin:
			result.append(WordCondition.Type.END)
	else:
		if not hard_begin:
			result.append(WordCondition.Type.BEGIN)
		if not hard_end:
			result.append(WordCondition.Type.END)
	return result


static func random_condition(syllable: String) -> int:
	var allowed := allowed_conditions(LocaleService.get_locale(), syllable)
	if allowed.is_empty():
		return WordCondition.Type.ANYWHERE
	return allowed[randi() % allowed.size()]

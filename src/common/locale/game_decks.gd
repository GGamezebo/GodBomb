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


static func get_cards(locale: String) -> PackedStringArray:
	if locale == "en":
		return PackedStringArray(ENGLISH_CARDS)
	return PackedStringArray(RUSSIAN_CARDS)

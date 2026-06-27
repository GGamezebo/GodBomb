class_name LocaleStringsLocales
extends RefCounted

const RULES_TEXT_SR := """[font_size=36]Brza žurka-reči na jednom ekranu: sedite u krug, predajete bombu-telefon i smišljate reči u hodu. Ako zakasniš — bum i kazneni poen.

[font_size=40][b]Kako se igra?[/b][/font_size]
Na brojčaniku je slog (na primer «СТ») i pravilo gde mora da bude u reči.

Izgovori reč naglas i kratko tapni ekran da predaš bombu sledećem.

[font_size=40][b]Kada je bum?[/b][/font_size]
Tajmer je skriven i nasumičan: nekad eksplodira odmah, nekad posle više krugova.

[font_size=40][b]Ko pobeđuje?[/b][/font_size]
Na kraju partije pobeđuje igrač sa najmanje kaznenih poena.

[center][font_size=40][b]Srećno![/b][/font_size][/center]"""

const RULES_TEXT_ES := """[font_size=36]Un juego de palabras para fiestas en una sola pantalla: sentaos en círculo, pasad la bomba-teléfono por turnos e inventad palabras al instante. Si tardas — boom y penalización.

[font_size=40][b]¿Cómo se juega?[/b][/font_size]
En el dial aparece una sílaba (por ejemplo «CH») y una condición: al inicio, en cualquier parte o al final.

Di una palabra en voz alta y toca rápido la pantalla para pasar la bomba.

[font_size=40][b]¿Cuándo explota?[/b][/font_size]
El temporizador es oculto y aleatorio. Puede explotar enseguida o tardar varios turnos.

[font_size=40][b]¿Quién gana?[/b][/font_size]
Al final gana quien tenga menos penalizaciones.

[center][font_size=40][b]¡A jugar![/b][/font_size][/center]"""

const RULES_TEXT_HI := """[font_size=36]एक स्क्रीन पर खेलने वाला मजेदार पार्टी वर्ड गेम: गोल बैठें, फोन-बम को बारी-बारी पास करें और तुरंत शब्द बोलें। देर हुई — बूम और पेनल्टी।

[font_size=40][b]कैसे खेलें?[/b][/font_size]
डायल पर एक अक्षर/सिलेबल (जैसे «क») और नियम दिखता है: शुरुआत, कहीं भी, या अंत।

शब्द ज़ोर से बोलें और स्क्रीन पर जल्दी टैप करके बम आगे पास करें।

[font_size=40][b]बूम कब होगा?[/b][/font_size]
टाइमर छुपा और रैंडम है। कभी तुरंत, कभी कई टर्न बाद।

[font_size=40][b]कौन जीतेगा?[/b][/font_size]
मैच के अंत में सबसे कम पेनल्टी वाला खिलाड़ी जीतता है।

[center][font_size=40][b]मज़े से खेलिए![/b][/font_size][/center]"""

const RULES_TEXT_DE := """[font_size=36]Ein schnelles Party-Wortspiel auf einem Bildschirm: Setzt euch im Kreis, gebt die Handy-Bombe reihum weiter und ruft passende Wörter. Zu langsam — bumm und ein Strafpunkt.

[font_size=40][b]Wie spielt man?[/b][/font_size]
Auf dem Zifferblatt steht eine Silbe (z. B. «CH») und eine Bedingung: am Anfang, irgendwo oder am Ende.

Sag ein Wort laut und tippe kurz auf den Bildschirm, um die Bombe weiterzugeben.

[font_size=40][b]Wann macht es bumm?[/b][/font_size]
Der Timer ist versteckt und zufällig. Manchmal sofort, manchmal erst nach vielen Zügen.

[font_size=40][b]Wer gewinnt?[/b][/font_size]
Am Ende gewinnt, wer die wenigsten Strafpunkte hat.

[center][font_size=40][b]Viel Spaß![/b][/font_size][/center]"""

const RULES_TEXT_FR := """[font_size=36]Jeu de mots explosif pour soirée sur un seul écran: asseyez-vous en cercle, passez la bombe-téléphone à tour de rôle et trouvez des mots vite. Trop lent — boum et pénalité.

[font_size=40][b]Comment jouer ?[/b][/font_size]
Le cadran affiche un groupe de lettres et une règle:
- [b]TIC[/b] = [b]début interdit[/b] (exemple avec «CH»: «é[bgcolor=#ffffff22]ch[/bgcolor]ec», pas «[bgcolor=#ffffff22]ch[/bgcolor]at»)
- [b]TIC TAC[/b] = [b]partout[/b] (avec «CH»: «[bgcolor=#ffffff22]ch[/bgcolor]at», «ma[bgcolor=#ffffff22]ch[/bgcolor]ine», «ri[bgcolor=#ffffff22]ch[/bgcolor]e»)
- [b]BOUM[/b] = [b]fin interdite[/b] (avec «ER»: «[bgcolor=#ffffff22]er[/bgcolor]reur», pas «chant[bgcolor=#ffffff22]er[/bgcolor]»)

Dis un mot à voix haute puis touche vite l'écran pour passer la bombe.

[font_size=40][b]Quand ça explose ?[/b][/font_size]
Le minuteur est caché et aléatoire: parfois immédiat, parfois après plusieurs tours.

[font_size=40][b]Qui gagne ?[/b][/font_size]
Le joueur avec le moins de pénalités gagne.

[center][font_size=40][b]Bonne partie ![/b][/font_size][/center]"""

const RULES_TEXT_IT := """[font_size=36]Gioco di parole esplosivo da festa su uno schermo: sedetevi in cerchio, passate la bomba-telefono a turno e trovate parole al volo. Se sei lento — boom e penalità.

[font_size=40][b]Come si gioca?[/b][/font_size]
Il quadrante mostra una sillaba e una regola:
- [b]TIC[/b] = [b]inizio vietato[/b] (con «ST»: «pa[bgcolor=#ffffff22]st[/bgcolor]a», non «[bgcolor=#ffffff22]st[/bgcolor]ella»)
- [b]TIC TAC[/b] = [b]libero[/b] (con «ST»: «[bgcolor=#ffffff22]st[/bgcolor]ella», «pa[bgcolor=#ffffff22]st[/bgcolor]a», «te[bgcolor=#ffffff22]st[/bgcolor]a»)
- [b]BOMBA[/b] = [b]fine vietata[/b] (con «ATO»: «[bgcolor=#ffffff22]ato[/bgcolor]mo», non «gel[bgcolor=#ffffff22]ato[/bgcolor]»)

Pronuncia una parola ad alta voce e tocca velocemente lo schermo per passare la bomba.

[font_size=40][b]Quando esplode?[/b][/font_size]
Il timer è nascosto e casuale: a volte subito, a volte dopo molti turni.

[font_size=40][b]Chi vince?[/b][/font_size]
Vince chi ha meno penalità.

[center][font_size=40][b]Buon divertimento![/b][/font_size][/center]"""

const _SR: Dictionary = {
	"SETTINGS_TITLE": "Podešavanja",
	"SETTINGS_LANGUAGE": "Jezik",
	"SETTINGS_GAME_TIME": "Trajanje partije: %d min",
	"SETTINGS_MUSIC_MENU": "Muzika u meniju",
	"SETTINGS_MUSIC_VOLUME": "Jačina muzike",
	"SETTINGS_SFX_VOLUME": "Jačina zvukova",
	"SETTINGS_HAPTICS": "Vibracija",
	"SETTINGS_HAPTICS_STRENGTH": "Jačina vibracije",
	"SETTINGS_RESET_HINT": "Resetuje podešavanja, savete i podrazumevana imena igrača.",
	"SETTINGS_RESET": "Resetuj napredak",
	"SETTINGS_RESET_CONFIRM": "Sigurno resetovati?",
	"SETTINGS_CLOSE": "Zatvori",
	"MENU_START": "START",
	"RULES_TITLE": "Pravila igre",
	"RULES_GAME_NAME": "Tik-Tak-Bada-Bum",
	"RULES_SKIP": "Preskoči",
	"RULES_TUTORIAL": "Pokreni tutorijal",
	"RULES_CLOSE": "Zatvori",
	"RULES_NEXT": "Dalje",
	"HINT_SWAP_IDLE": "Prevuci slajma na suseda da zamenite mesta",
	"HINT_SWAP_DRAG": "Pusti da zamenite mesta",
	"HINT_REMOVE": "Pusti na «+» da ukloniš igrača",
	"HINT_MIN_PLAYERS": "Potrebna su najmanje 2 igrača",
	"HINT_HOLD_EDIT": "Drži 1,5 s za ime i boju",
	"PLAYER_DEFAULT": "Igrač",
	"PLAYER_EDIT_PLACEHOLDER": "Ime (do 12 znakova)",
	"EDIT_CANCEL": "Otkaži",
	"EDIT_ADD": "Dodaj",
	"EDIT_APPLY": "Primeni",
	"WORD_COND_BEGIN": "Slog na početku reči",
	"WORD_COND_ANYWHERE": "Slog bilo gde u reči",
	"WORD_COND_END": "Slog na kraju reči",
	"WORD_COND_NOT_BEGIN": "Slog nije na početku",
	"WORD_COND_NOT_END": "Slog nije na kraju",
	"LOADING": "UČITAVANJE",
	"EXIT_CONFIRM_MESSAGE": "Završiti partiju?",
	"EXIT_CANCEL": "Otkaži",
	"EXIT_CONFIRM": "Izađi",
	"EMERGENCY_TITLE": "Hitna pauza",
	"EMERGENCY_EXPLANATION": "Pogrešna reč ili slučajan dodir? Izaberi ko ponavlja potez.",
	"EMERGENCY_CONTINUE": "Nastavi",
	"LOBBY_EXPLANATION": "Promeni sastav za stolom — partija se ne prekida.",
	"LOBBY_READY": "SPREMNO",
	"RESULT_RANKING": "RANG LISTA",
	"RESULT_WINNER": "POBEDNIK",
	"RESULT_FEWER_PENALTIES": "MANJE KAZNI",
	"RESULT_TO_MENU": "U MENI",
	"EXPLOSION_BOOM": "BUM!",
	"ACTION_HINT_TAP": "Dodirni ekran — predaj bombu",
	"TIME_PROGRESS_LABEL": "Do kraja partije",
	"HUD_LOTTERY": "Žreb — ko ide prvi?",
	"HUD_READY": "Spremni?",
	"HUD_START_ROUND": "Pokreni rundu",
	"HUD_START_ROUND_HINT": "Dodirni «Pokreni rundu»",
	"ONBOARDING_SKIP": "Preskoči",
	"ONBOARDING_GOT_IT": "Jasno",
	"ONBOARDING_ADD_TITLE": "Okupi ekipu",
	"ONBOARDING_ADD_BODY": "Dodirni «+» i dodaj tri igrača da savladaš raspored.",
	"ONBOARDING_NAME_TITLE": "Daj imena",
	"ONBOARDING_NAME_BODY": "Drži slajma oko 1,5 s da otvoriš ime i boju.",
	"ONBOARDING_SWAP_TITLE": "Raspored sedenja",
	"ONBOARDING_SWAP_BODY": "Prevuci jednog slajma na drugog da zamenite mesta.",
	"ONBOARDING_START_TITLE": "U boj!",
	"ONBOARDING_START_BODY": "Kad su svi spremni — dodirni «START».",
	"ONBOARDING_CHOICE_TITLE": "Žreb",
	"ONBOARDING_CHOICE_BODY": "Brojčanik bira ko igra prvi. Prati osvetljenog igrača.",
	"ONBOARDING_READY_TITLE": "Početak runde",
	"ONBOARDING_READY_BODY": "Dodirni «Pokreni rundu» dole da počne odbrojavanje.",
	"ONBOARDING_PLAY_TITLE": "Tvoj potez",
	"ONBOARDING_TIME_UP_TITLE": "Vreme je isteklo",
	"ONBOARDING_DONE_TITLE": "Tutorijal završen!",
	"ONBOARDING_DONE_BODY": "Sada znaš pravila igre Tik-Tak-Bada-Bum. Okupi društvo i igraj!",
	"TUTORIAL_PLAY_BODY": "Slog «%s» — %s.\nOdgovaraju reči: %s.\nNa primer: «%s».\n%s",
	"TUTORIAL_EXPLOSION": "%s nije stigao/la da smisli reč — bomba je eksplodirala.",
}

const _ES: Dictionary = {
	"SETTINGS_TITLE": "Ajustes",
	"SETTINGS_LANGUAGE": "Idioma",
	"SETTINGS_GAME_TIME": "Duración de la partida: %d min",
	"SETTINGS_MUSIC_MENU": "Música del menú",
	"SETTINGS_MUSIC_VOLUME": "Volumen de música",
	"SETTINGS_SFX_VOLUME": "Volumen de efectos",
	"SETTINGS_HAPTICS": "Vibración",
	"SETTINGS_HAPTICS_STRENGTH": "Intensidad de vibración",
	"SETTINGS_RESET_HINT": "Restablece ajustes, pistas y nombres por defecto.",
	"SETTINGS_RESET": "Restablecer progreso",
	"SETTINGS_RESET_CONFIRM": "¿Seguro que quieres restablecer?",
	"SETTINGS_CLOSE": "Cerrar",
	"MENU_START": "INICIAR",
	"RULES_TITLE": "Reglas del juego",
	"RULES_GAME_NAME": "Tic-Tac-Bada-Boum",
	"RULES_SKIP": "Saltar",
	"RULES_TUTORIAL": "Iniciar tutorial",
	"RULES_CLOSE": "Cerrar",
	"RULES_NEXT": "Siguiente",
	"HINT_SWAP_IDLE": "Arrastra un slime al vecino para cambiar sitios",
	"HINT_SWAP_DRAG": "Suelta para intercambiar lugares",
	"HINT_REMOVE": "Suelta sobre «+» para quitar jugador",
	"HINT_MIN_PLAYERS": "Se necesitan al menos 2 jugadores",
	"HINT_HOLD_EDIT": "Mantén 1,5 s para nombre y color",
	"PLAYER_DEFAULT": "Jugador",
	"PLAYER_EDIT_PLACEHOLDER": "Nombre (hasta 12 caracteres)",
	"EDIT_CANCEL": "Cancelar",
	"EDIT_ADD": "Añadir",
	"EDIT_APPLY": "Aplicar",
	"WORD_COND_BEGIN": "Sílaba al inicio de la palabra",
	"WORD_COND_ANYWHERE": "Sílaba en cualquier parte",
	"WORD_COND_END": "Sílaba al final de la palabra",
	"WORD_COND_NOT_BEGIN": "Sílaba no al inicio",
	"WORD_COND_NOT_END": "Sílaba no al final",
	"LOADING": "CARGANDO",
	"EXIT_CONFIRM_MESSAGE": "¿Terminar la partida?",
	"EXIT_CANCEL": "Cancelar",
	"EXIT_CONFIRM": "Salir",
	"EMERGENCY_TITLE": "Pausa de emergencia",
	"EMERGENCY_EXPLANATION": "¿Palabra incorrecta o toque accidental? Elige quién repite turno.",
	"EMERGENCY_CONTINUE": "Continuar",
	"LOBBY_EXPLANATION": "Cambia la mesa de jugadores — la partida no se detiene.",
	"LOBBY_READY": "LISTO",
	"RESULT_RANKING": "CLASIFICACIÓN",
	"RESULT_WINNER": "GANADOR",
	"RESULT_FEWER_PENALTIES": "MENOS PENALIZACIONES",
	"RESULT_TO_MENU": "AL MENÚ",
	"EXPLOSION_BOOM": "¡BOOM!",
	"ACTION_HINT_TAP": "Toca la pantalla — pasa la bomba",
	"TIME_PROGRESS_LABEL": "Tiempo restante",
	"HUD_LOTTERY": "Sorteo — ¿quién empieza?",
	"HUD_READY": "¿Listos?",
	"HUD_START_ROUND": "Iniciar ronda",
	"HUD_START_ROUND_HINT": "Toca «Iniciar ronda»",
	"ONBOARDING_SKIP": "Saltar",
	"ONBOARDING_GOT_IT": "Entendido",
	"ONBOARDING_ADD_TITLE": "Forma el equipo",
	"ONBOARDING_ADD_BODY": "Pulsa «+» y añade tres jugadores para aprender la mesa.",
	"ONBOARDING_NAME_TITLE": "Pon nombres",
	"ONBOARDING_NAME_BODY": "Mantén un slime ~1,5 s para abrir nombre y color.",
	"ONBOARDING_SWAP_TITLE": "Asientos",
	"ONBOARDING_SWAP_BODY": "Arrastra un slime sobre otro para cambiar asientos.",
	"ONBOARDING_START_TITLE": "¡A jugar!",
	"ONBOARDING_START_BODY": "Cuando todos estén listos — toca «INICIAR».",
	"ONBOARDING_CHOICE_TITLE": "Sorteo",
	"ONBOARDING_CHOICE_BODY": "El dial elegirá quién va primero.",
	"ONBOARDING_READY_TITLE": "Comenzar ronda",
	"ONBOARDING_READY_BODY": "Toca «Iniciar ronda» abajo para iniciar la cuenta atrás.",
	"ONBOARDING_PLAY_TITLE": "Tu turno",
	"ONBOARDING_TIME_UP_TITLE": "Se acabó el tiempo",
	"ONBOARDING_DONE_TITLE": "¡Tutorial completado!",
	"ONBOARDING_DONE_BODY": "Ahora conoces las reglas de Tic-Tac-Bada-Boum. ¡Reúne a tus amigos y juega!",
	"TUTORIAL_PLAY_BODY": "Sílaba «%s» — %s.\nPalabras válidas: %s.\nPor ejemplo: «%s».\n%s",
	"TUTORIAL_EXPLOSION": "%s se quedó sin tiempo para decir una palabra — la bomba explotó.",
}

const _HI: Dictionary = {
	"SETTINGS_TITLE": "सेटिंग्स",
	"SETTINGS_LANGUAGE": "भाषा",
	"SETTINGS_GAME_TIME": "मैच की अवधि: %d मिनट",
	"SETTINGS_MUSIC_MENU": "मेन्यू संगीत",
	"SETTINGS_MUSIC_VOLUME": "संगीत आवाज़",
	"SETTINGS_SFX_VOLUME": "ध्वनि प्रभाव आवाज़",
	"SETTINGS_HAPTICS": "वाइब्रेशन",
	"SETTINGS_HAPTICS_STRENGTH": "वाइब्रेशन ताकत",
	"SETTINGS_RESET_HINT": "सेटिंग्स, संकेत और डिफ़ॉल्ट नाम रीसेट होंगे।",
	"SETTINGS_RESET": "प्रगति रीसेट करें",
	"SETTINGS_RESET_CONFIRM": "क्या सच में रीसेट करें?",
	"SETTINGS_CLOSE": "बंद करें",
	"MENU_START": "शुरू करें",
	"RULES_TITLE": "खेल के नियम",
	"RULES_GAME_NAME": "टिक-टैक-बादाबूम",
	"RULES_SKIP": "छोड़ें",
	"RULES_TUTORIAL": "ट्यूटोरियल शुरू करें",
	"RULES_CLOSE": "बंद करें",
	"RULES_NEXT": "आगे",
	"HINT_SWAP_IDLE": "सीट बदलने के लिए स्लाइम को पड़ोसी पर खींचें",
	"HINT_SWAP_DRAG": "जगह बदलने के लिए छोड़ें",
	"HINT_REMOVE": "खिलाड़ी हटाने के लिए «+» पर छोड़ें",
	"HINT_MIN_PLAYERS": "कम से कम 2 खिलाड़ी चाहिए",
	"HINT_HOLD_EDIT": "नाम और रंग के लिए 1.5 सेकंड दबाए रखें",
	"PLAYER_DEFAULT": "खिलाड़ी",
	"PLAYER_EDIT_PLACEHOLDER": "नाम (अधिकतम 12 अक्षर)",
	"EDIT_CANCEL": "रद्द करें",
	"EDIT_ADD": "जोड़ें",
	"EDIT_APPLY": "लागू करें",
	"WORD_COND_BEGIN": "सिलेबल शब्द की शुरुआत में",
	"WORD_COND_ANYWHERE": "सिलेबल शब्द में कहीं भी",
	"WORD_COND_END": "सिलेबल शब्द के अंत में",
	"WORD_COND_NOT_BEGIN": "सिलेबल शुरुआत में नहीं",
	"WORD_COND_NOT_END": "सिलेबल अंत में नहीं",
	"LOADING": "लोड हो रहा है",
	"EXIT_CONFIRM_MESSAGE": "क्या मैच समाप्त करें?",
	"EXIT_CANCEL": "रद्द करें",
	"EXIT_CONFIRM": "बाहर निकलें",
	"EMERGENCY_TITLE": "आपात विराम",
	"EMERGENCY_EXPLANATION": "गलत शब्द या गलती से टैप? चुनें कौन टर्न दोहराएगा।",
	"EMERGENCY_CONTINUE": "जारी रखें",
	"LOBBY_EXPLANATION": "खिलाड़ियों की व्यवस्था बदलें — मैच नहीं रुकेगा।",
	"LOBBY_READY": "तैयार",
	"RESULT_RANKING": "रैंकिंग",
	"RESULT_WINNER": "विजेता",
	"RESULT_FEWER_PENALTIES": "कम पेनल्टी",
	"RESULT_TO_MENU": "मेन्यू पर जाएँ",
	"EXPLOSION_BOOM": "बूम!",
	"ACTION_HINT_TAP": "स्क्रीन टैप करें — बम पास करें",
	"TIME_PROGRESS_LABEL": "मैच समाप्ति तक",
	"HUD_LOTTERY": "लॉटरी — पहले कौन खेलेगा?",
	"HUD_READY": "तैयार?",
	"HUD_START_ROUND": "राउंड शुरू करें",
	"HUD_START_ROUND_HINT": "«राउंड शुरू करें» दबाएँ",
	"ONBOARDING_SKIP": "छोड़ें",
	"ONBOARDING_GOT_IT": "समझ गया",
	"ONBOARDING_ADD_TITLE": "टीम बनाएं",
	"ONBOARDING_ADD_BODY": "«+» दबाकर तीन खिलाड़ी जोड़ें और टेबल समझें।",
	"ONBOARDING_NAME_TITLE": "नाम दें",
	"ONBOARDING_NAME_BODY": "स्लाइम को ~1.5 सेकंड दबाएँ, नाम और रंग खुलेंगे।",
	"ONBOARDING_SWAP_TITLE": "बैठने की जगह",
	"ONBOARDING_SWAP_BODY": "एक स्लाइम को दूसरे पर खींचें और सीट बदलें।",
	"ONBOARDING_START_TITLE": "खेल शुरू!",
	"ONBOARDING_START_BODY": "सब तैयार हों तो «शुरू करें» दबाएँ।",
	"ONBOARDING_CHOICE_TITLE": "लॉटरी",
	"ONBOARDING_CHOICE_BODY": "डायल तय करेगा कौन पहले खेलेगा।",
	"ONBOARDING_READY_TITLE": "राउंड की शुरुआत",
	"ONBOARDING_READY_BODY": "नीचे «राउंड शुरू करें» दबाएँ, काउंटडाउन शुरू होगा।",
	"ONBOARDING_PLAY_TITLE": "आपकी बारी",
	"ONBOARDING_TIME_UP_TITLE": "समय समाप्त",
	"ONBOARDING_DONE_TITLE": "ट्यूटोरियल पूरा!",
	"ONBOARDING_DONE_BODY": "अब आपको टिक-टैक-बादाबूम के नियम पता हैं। दोस्तों को बुलाइए और खेलिए!",
	"TUTORIAL_PLAY_BODY": "सिलेबल «%s» — %s.\nमान्य शब्द: %s.\nउदाहरण: «%s».\n%s",
	"TUTORIAL_EXPLOSION": "%s समय पर शब्द नहीं बोल पाया/पाई — बम फट गया।",
}

const _DE: Dictionary = {
	"SETTINGS_TITLE": "Einstellungen",
	"SETTINGS_LANGUAGE": "Sprache",
	"SETTINGS_GAME_TIME": "Spieldauer: %d Min",
	"SETTINGS_MUSIC_MENU": "Menümusik",
	"SETTINGS_MUSIC_VOLUME": "Musiklautstärke",
	"SETTINGS_SFX_VOLUME": "Effektlautstärke",
	"SETTINGS_HAPTICS": "Vibration",
	"SETTINGS_HAPTICS_STRENGTH": "Vibrationsstärke",
	"SETTINGS_RESET_HINT": "Setzt Einstellungen, Hinweise und Standardnamen zurück.",
	"SETTINGS_RESET": "Fortschritt zurücksetzen",
	"SETTINGS_RESET_CONFIRM": "Wirklich zurücksetzen?",
	"SETTINGS_CLOSE": "Schließen",
	"MENU_START": "START",
	"RULES_TITLE": "Spielregeln",
	"RULES_GAME_NAME": "Tic-Tac-Bada-Bumm",
	"RULES_SKIP": "Überspringen",
	"RULES_TUTORIAL": "Tutorial starten",
	"RULES_CLOSE": "Schließen",
	"RULES_NEXT": "Weiter",
	"HINT_SWAP_IDLE": "Ziehe einen Schleim auf den Nachbarn zum Platztausch",
	"HINT_SWAP_DRAG": "Loslassen zum Tauschen",
	"HINT_REMOVE": "Auf «+» ziehen, um Spieler zu entfernen",
	"HINT_MIN_PLAYERS": "Mindestens 2 Spieler nötig",
	"HINT_HOLD_EDIT": "1,5 s halten für Name und Farbe",
	"PLAYER_DEFAULT": "Spieler",
	"PLAYER_EDIT_PLACEHOLDER": "Name (bis zu 12 Zeichen)",
	"EDIT_CANCEL": "Abbrechen",
	"EDIT_ADD": "Hinzufügen",
	"EDIT_APPLY": "Anwenden",
	"WORD_COND_BEGIN": "Silbe am Wortanfang",
	"WORD_COND_ANYWHERE": "Silbe irgendwo im Wort",
	"WORD_COND_END": "Silbe am Wortende",
	"WORD_COND_NOT_BEGIN": "Silbe nicht am Anfang",
	"WORD_COND_NOT_END": "Silbe nicht am Ende",
	"LOADING": "LÄDT",
	"EXIT_CONFIRM_MESSAGE": "Spiel beenden?",
	"EXIT_CANCEL": "Abbrechen",
	"EXIT_CONFIRM": "Verlassen",
	"EMERGENCY_TITLE": "Notfallpause",
	"EMERGENCY_EXPLANATION": "Falsches Wort oder Fehlklick? Wähle, wer den Zug wiederholt.",
	"EMERGENCY_CONTINUE": "Weiter",
	"LOBBY_EXPLANATION": "Spielerrunde ändern — das Match läuft weiter.",
	"LOBBY_READY": "FERTIG",
	"RESULT_RANKING": "RANGLISTE",
	"RESULT_WINNER": "SIEGER",
	"RESULT_FEWER_PENALTIES": "WENIGER STRAFPUNKTE",
	"RESULT_TO_MENU": "ZUM MENÜ",
	"EXPLOSION_BOOM": "BUMM!",
	"ACTION_HINT_TAP": "Bildschirm tippen — Bombe weitergeben",
	"TIME_PROGRESS_LABEL": "Restspielzeit",
	"HUD_LOTTERY": "Los entscheidet — wer beginnt?",
	"HUD_READY": "Bereit?",
	"HUD_START_ROUND": "Runde starten",
	"HUD_START_ROUND_HINT": "Tippe «Runde starten»",
	"ONBOARDING_SKIP": "Überspringen",
	"ONBOARDING_GOT_IT": "Verstanden",
	"ONBOARDING_ADD_TITLE": "Team aufstellen",
	"ONBOARDING_ADD_BODY": "Tippe auf «+» und füge drei Spieler hinzu.",
	"ONBOARDING_NAME_TITLE": "Namen vergeben",
	"ONBOARDING_NAME_BODY": "Halte einen Schleim ~1,5 s für Name und Farbe.",
	"ONBOARDING_SWAP_TITLE": "Sitzordnung",
	"ONBOARDING_SWAP_BODY": "Ziehe einen Schleim auf einen anderen zum Tauschen.",
	"ONBOARDING_START_TITLE": "Los geht's!",
	"ONBOARDING_START_BODY": "Wenn alle bereit sind — tippe «START».",
	"ONBOARDING_CHOICE_TITLE": "Auslosung",
	"ONBOARDING_CHOICE_BODY": "Das Rad wählt den ersten Spieler.",
	"ONBOARDING_READY_TITLE": "Rundenstart",
	"ONBOARDING_READY_BODY": "Unten «Runde starten» tippen, dann beginnt der Countdown.",
	"ONBOARDING_PLAY_TITLE": "Du bist dran",
	"ONBOARDING_TIME_UP_TITLE": "Zeit abgelaufen",
	"ONBOARDING_DONE_TITLE": "Tutorial abgeschlossen!",
	"ONBOARDING_DONE_BODY": "Jetzt kennst du die Regeln von Tic-Tac-Bada-Bumm. Viel Spaß mit Freunden!",
	"TUTORIAL_PLAY_BODY": "Silbe «%s» — %s.\nPassende Wörter: %s.\nZum Beispiel: «%s».\n%s",
	"TUTORIAL_EXPLOSION": "%s war zu langsam mit einem Wort — die Bombe ist explodiert.",
}

const _FR: Dictionary = {
	"SETTINGS_TITLE": "Paramètres",
	"SETTINGS_LANGUAGE": "Langue",
	"SETTINGS_GAME_TIME": "Durée de partie: %d min",
	"SETTINGS_MUSIC_MENU": "Musique du menu",
	"SETTINGS_MUSIC_VOLUME": "Volume de la musique",
	"SETTINGS_SFX_VOLUME": "Volume des effets",
	"SETTINGS_HAPTICS": "Vibration",
	"SETTINGS_HAPTICS_STRENGTH": "Intensité de vibration",
	"SETTINGS_RESET_HINT": "Réinitialise paramètres, astuces et noms par défaut.",
	"SETTINGS_RESET": "Réinitialiser la progression",
	"SETTINGS_RESET_CONFIRM": "Confirmer la réinitialisation ?",
	"SETTINGS_CLOSE": "Fermer",
	"MENU_START": "JOUER",
	"RULES_TITLE": "Règles du jeu",
	"RULES_GAME_NAME": "Tic-Tac-Bada-Boum",
	"RULES_SKIP": "Passer",
	"RULES_TUTORIAL": "Lancer le tutoriel",
	"RULES_CLOSE": "Fermer",
	"RULES_NEXT": "Suivant",
	"HINT_SWAP_IDLE": "Fais glisser un slime sur un voisin pour échanger",
	"HINT_SWAP_DRAG": "Relâche pour échanger les places",
	"HINT_REMOVE": "Relâche sur «+» pour retirer un joueur",
	"HINT_MIN_PLAYERS": "Au moins 2 joueurs requis",
	"HINT_HOLD_EDIT": "Maintiens 1,5 s pour nom et couleur",
	"PLAYER_DEFAULT": "Joueur",
	"PLAYER_EDIT_PLACEHOLDER": "Nom (12 caractères max)",
	"EDIT_CANCEL": "Annuler",
	"EDIT_ADD": "Ajouter",
	"EDIT_APPLY": "Appliquer",
	"WORD_COND_BEGIN": "Syllabe en début de mot",
	"WORD_COND_ANYWHERE": "Syllabe n'importe où",
	"WORD_COND_END": "Syllabe en fin de mot",
	"WORD_COND_NOT_BEGIN": "Début interdit",
	"WORD_COND_NOT_END": "Fin interdite",
	"LOADING": "CHARGEMENT",
	"EXIT_CONFIRM_MESSAGE": "Quitter la partie ?",
	"EXIT_CANCEL": "Annuler",
	"EXIT_CONFIRM": "Quitter",
	"EMERGENCY_TITLE": "Pause d'urgence",
	"EMERGENCY_EXPLANATION": "Mot incorrect ou appui accidentel ? Choisis qui rejoue le tour.",
	"EMERGENCY_CONTINUE": "Continuer",
	"LOBBY_EXPLANATION": "Modifie les joueurs autour de la table sans arrêter la partie.",
	"LOBBY_READY": "PRÊT",
	"RESULT_RANKING": "CLASSEMENT",
	"RESULT_WINNER": "GAGNANT",
	"RESULT_FEWER_PENALTIES": "MOINS DE PÉNALITÉS",
	"RESULT_TO_MENU": "AU MENU",
	"EXPLOSION_BOOM": "BOUM !",
	"ACTION_HINT_TAP": "Touchez l'écran — passez la bombe",
	"TIME_PROGRESS_LABEL": "Temps restant",
	"HUD_LOTTERY": "Tirage au sort — qui commence ?",
	"HUD_READY": "Prêts ?",
	"HUD_START_ROUND": "Démarrer la manche",
	"HUD_START_ROUND_HINT": "Touchez «Démarrer la manche»",
	"ONBOARDING_SKIP": "Passer",
	"ONBOARDING_GOT_IT": "Compris",
	"ONBOARDING_ADD_TITLE": "Composez l'équipe",
	"ONBOARDING_ADD_BODY": "Touchez «+» et ajoutez trois joueurs.",
	"ONBOARDING_NAME_TITLE": "Donnez des noms",
	"ONBOARDING_NAME_BODY": "Maintenez un slime ~1,5 s pour nom et couleur.",
	"ONBOARDING_SWAP_TITLE": "Placement",
	"ONBOARDING_SWAP_BODY": "Glissez un slime sur un autre pour échanger les places.",
	"ONBOARDING_START_TITLE": "En jeu !",
	"ONBOARDING_START_BODY": "Quand tout le monde est prêt — touchez «JOUER».",
	"ONBOARDING_CHOICE_TITLE": "Tirage",
	"ONBOARDING_CHOICE_BODY": "Le cadran choisit le premier joueur.",
	"ONBOARDING_READY_TITLE": "Début de manche",
	"ONBOARDING_READY_BODY": "Touchez «Démarrer la manche» en bas pour lancer le compte à rebours.",
	"ONBOARDING_PLAY_TITLE": "À vous",
	"ONBOARDING_TIME_UP_TITLE": "Temps écoulé",
	"ONBOARDING_DONE_TITLE": "Tutoriel terminé !",
	"ONBOARDING_DONE_BODY": "Vous connaissez maintenant les règles de Tic-Tac-Bada-Boum. Amusez-vous !",
	"TUTORIAL_PLAY_BODY": "Syllabe «%s» — %s.\nMots valides: %s.\nPar exemple: «%s».\n%s",
	"TUTORIAL_EXPLOSION": "%s n'a pas trouvé de mot à temps — la bombe a explosé.",
}

const _IT: Dictionary = {
	"SETTINGS_TITLE": "Impostazioni",
	"SETTINGS_LANGUAGE": "Lingua",
	"SETTINGS_GAME_TIME": "Durata partita: %d min",
	"SETTINGS_MUSIC_MENU": "Musica del menu",
	"SETTINGS_MUSIC_VOLUME": "Volume musica",
	"SETTINGS_SFX_VOLUME": "Volume effetti",
	"SETTINGS_HAPTICS": "Vibrazione",
	"SETTINGS_HAPTICS_STRENGTH": "Intensità vibrazione",
	"SETTINGS_RESET_HINT": "Reimposta impostazioni, suggerimenti e nomi predefiniti.",
	"SETTINGS_RESET": "Reimposta progresso",
	"SETTINGS_RESET_CONFIRM": "Confermi il reset?",
	"SETTINGS_CLOSE": "Chiudi",
	"MENU_START": "INIZIA",
	"RULES_TITLE": "Regole del gioco",
	"RULES_GAME_NAME": "Tic-Tac-Bada-Bomba",
	"RULES_SKIP": "Salta",
	"RULES_TUTORIAL": "Avvia tutorial",
	"RULES_CLOSE": "Chiudi",
	"RULES_NEXT": "Avanti",
	"HINT_SWAP_IDLE": "Trascina uno slime sul vicino per scambiare posto",
	"HINT_SWAP_DRAG": "Rilascia per scambiare",
	"HINT_REMOVE": "Rilascia su «+» per rimuovere un giocatore",
	"HINT_MIN_PLAYERS": "Servono almeno 2 giocatori",
	"HINT_HOLD_EDIT": "Tieni premuto 1,5 s per nome e colore",
	"PLAYER_DEFAULT": "Giocatore",
	"PLAYER_EDIT_PLACEHOLDER": "Nome (max 12 caratteri)",
	"EDIT_CANCEL": "Annulla",
	"EDIT_ADD": "Aggiungi",
	"EDIT_APPLY": "Applica",
	"WORD_COND_BEGIN": "Sillaba a inizio parola",
	"WORD_COND_ANYWHERE": "Sillaba in qualsiasi posizione",
	"WORD_COND_END": "Sillaba a fine parola",
	"WORD_COND_NOT_BEGIN": "Inizio vietato",
	"WORD_COND_NOT_END": "Fine vietata",
	"LOADING": "CARICAMENTO",
	"EXIT_CONFIRM_MESSAGE": "Terminare la partita?",
	"EXIT_CANCEL": "Annulla",
	"EXIT_CONFIRM": "Esci",
	"EMERGENCY_TITLE": "Pausa di emergenza",
	"EMERGENCY_EXPLANATION": "Parola sbagliata o tocco accidentale? Scegli chi ripete il turno.",
	"EMERGENCY_CONTINUE": "Continua",
	"LOBBY_EXPLANATION": "Cambia i giocatori al tavolo senza interrompere la partita.",
	"LOBBY_READY": "PRONTO",
	"RESULT_RANKING": "CLASSIFICA",
	"RESULT_WINNER": "VINCITORE",
	"RESULT_FEWER_PENALTIES": "MENO PENALITÀ",
	"RESULT_TO_MENU": "AL MENU",
	"EXPLOSION_BOOM": "BOOM!",
	"ACTION_HINT_TAP": "Tocca lo schermo — passa la bomba",
	"TIME_PROGRESS_LABEL": "Tempo rimanente",
	"HUD_LOTTERY": "Sorteggio — chi inizia?",
	"HUD_READY": "Pronti?",
	"HUD_START_ROUND": "Avvia round",
	"HUD_START_ROUND_HINT": "Tocca «Avvia round»",
	"ONBOARDING_SKIP": "Salta",
	"ONBOARDING_GOT_IT": "Capito",
	"ONBOARDING_ADD_TITLE": "Crea la squadra",
	"ONBOARDING_ADD_BODY": "Tocca «+» e aggiungi tre giocatori.",
	"ONBOARDING_NAME_TITLE": "Dai i nomi",
	"ONBOARDING_NAME_BODY": "Tieni premuto uno slime ~1,5 s per nome e colore.",
	"ONBOARDING_SWAP_TITLE": "Posti a sedere",
	"ONBOARDING_SWAP_BODY": "Trascina uno slime su un altro per scambiare posto.",
	"ONBOARDING_START_TITLE": "Si parte!",
	"ONBOARDING_START_BODY": "Quando tutti sono pronti — tocca «INIZIA».",
	"ONBOARDING_CHOICE_TITLE": "Sorteggio",
	"ONBOARDING_CHOICE_BODY": "Il quadrante sceglie chi parte per primo.",
	"ONBOARDING_READY_TITLE": "Inizio round",
	"ONBOARDING_READY_BODY": "Tocca «Avvia round» in basso per iniziare il conto alla rovescia.",
	"ONBOARDING_PLAY_TITLE": "Tocca a te",
	"ONBOARDING_TIME_UP_TITLE": "Tempo scaduto",
	"ONBOARDING_DONE_TITLE": "Tutorial completato!",
	"ONBOARDING_DONE_BODY": "Ora conosci le regole di Tic-Tac-Bada-Bomba. Invita gli amici e gioca!",
	"TUTORIAL_PLAY_BODY": "Sillaba «%s» — %s.\nParole valide: %s.\nPer esempio: «%s».\n%s",
	"TUTORIAL_EXPLOSION": "%s non ha trovato una parola in tempo — la bomba è esplosa.",
}

const SLIME_SR: Array[String] = [
	"Crvena", "Plava", "Zelena", "Roze", "Narandžasta", "Žuta",
	"Crna", "Bela", "Ljubičasta", "Braon", "Tirkizna", "Limeta",
]

const SLIME_ES: Array[String] = [
	"Rojo", "Azul", "Verde", "Rosa", "Naranja", "Amarillo",
	"Negro", "Blanco", "Morado", "Marrón", "Cian", "Lima",
]

const SLIME_HI: Array[String] = [
	"लाल", "नीला", "हरा", "गुलाबी", "नारंगी", "पीला",
	"काला", "सफ़ेद", "बैंगनी", "भूरा", "सियान", "लाइम",
]

const SLIME_DE: Array[String] = [
	"Rot", "Blau", "Grün", "Pink", "Orange", "Gelb",
	"Schwarz", "Weiß", "Lila", "Braun", "Türkis", "Limette",
]

const SLIME_FR: Array[String] = [
	"Rouge", "Bleu", "Vert", "Rose", "Orange", "Jaune",
	"Noir", "Blanc", "Violet", "Marron", "Cyan", "Citron vert",
]

const SLIME_IT: Array[String] = [
	"Rosso", "Blu", "Verde", "Rosa", "Arancione", "Giallo",
	"Nero", "Bianco", "Viola", "Marrone", "Ciano", "Lime",
]


static func ui_table(locale: String) -> Dictionary:
	match _short_locale(locale):
		"sr":
			return _SR
		"es":
			return _ES
		"hi":
			return _HI
		"de":
			return _DE
		"fr":
			return _FR
		"it":
			return _IT
		_:
			return {}


static func rules_text(locale: String) -> String:
	match _short_locale(locale):
		"sr":
			return RULES_TEXT_SR
		"es":
			return RULES_TEXT_ES
		"hi":
			return RULES_TEXT_HI
		"de":
			return RULES_TEXT_DE
		"fr":
			return RULES_TEXT_FR
		"it":
			return RULES_TEXT_IT
		_:
			return ""


static func slime_names(locale: String) -> Array[String]:
	match _short_locale(locale):
		"sr":
			return SLIME_SR.duplicate()
		"es":
			return SLIME_ES.duplicate()
		"hi":
			return SLIME_HI.duplicate()
		"de":
			return SLIME_DE.duplicate()
		"fr":
			return SLIME_FR.duplicate()
		"it":
			return SLIME_IT.duplicate()
		_:
			return []


static func _short_locale(locale: String) -> String:
	var normalized := locale.strip_edges().to_lower()
	if normalized.length() >= 2:
		return normalized.substr(0, 2)
	return normalized

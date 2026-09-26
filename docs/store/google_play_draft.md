# Google Play Console — Tic-Tac-Bada-Boom

Ready-to-paste answers for Play Console. General store notes → [listing.md](./listing.md).
Console: https://play.google.com/console

Facts this draft relies on (re-check if the code changes):
- Android build: **no INTERNET permission**, only `VIBRATE`; no ads, analytics or crash SDKs.
- Local save only (`user://`): player names, colors, settings, tutorial flags.
- Google Play In-App Review (`com.google.android.play:review`) — dialog handled by Google.
- Package `com.tictacbadaboom.app`, preset `Android` → AAB, feature `play`.

---

## 1. Create app

| Field | Value |
|---|---|
| App name (≤30) | `Tic-Tac-Bada-Boom` |
| Default language | Russian – ru-RU *(or English – en-US if you target the world first)* |
| App or game | **Game** |
| Free or paid | **Free** (can't switch free → paid later) |
| Declarations | Developer Program Policies + US export laws — **you accept yourself** |

---

## 2. App content (Policy → App content)

### Privacy policy
URL of the hosted `docs/privacy/index.html` (see §6). Replace `Igorion` / `iyubelyash@gmail.com` first.

### App access
**All functionality is available without any access restrictions.**

### Ads
**No, my app does not contain ads.**

### Content rating (IARC questionnaire)
- Email: your contact email · Category: **Game**
- Violence: **No** (cartoon bomb “explodes” as a score event, no characters are harmed — if unsure answer “cartoon/fantasy violence: No”, the explosion is abstract)
- Fear / sexuality / language / controlled substances / gambling: **No**
- User interaction / chat / sharing user content / sharing location: **No**
- Digital purchases: **No**
- Expected result: **PEGI 3 / ESRB Everyone / 0+**

### Target audience and content
- Target age groups: **13–15, 16–17, 18+** *(recommended for the first release — selecting under-13 puts the app under the Families Policy with extra review; the game has no ads/data so it would pass, but it is slower)*
- “Could your store listing unintentionally appeal to children?” → **Yes** is safer if Google asks (cartoon art); explain: *party word game for families and friends; no ads, no data collection, no purchases.*

### Data safety
- Does your app collect or share any of the required user data types? → **No**
- *(Local-only storage is not “collection” per Google’s definition — data never leaves the device.)*
- Resulting label: **No data collected · No data shared**

### Advertising ID
**No** — the app does not use advertising ID.

### Government apps / Financial features / Health / News / COVID-19
**No / None** everywhere.

---

## 3. Store settings

| Field | Value |
|---|---|
| App category | **Game → Word** |
| Tags (≤5) | Word, Party, Casual, Local multiplayer, Trivia *(pick from Google's list)* |
| Contact email | `iyubelyash@gmail.com` (shown publicly) |
| Website | optional |

---

## 4. Main store listing

### Graphics

| Asset | Spec | File (not in build) |
|---|---|---|
| App icon | 512×512 PNG 32-bit, ≤1 MB | `assets/reference/store/yandex_icon_512.png` |
| Feature graphic | 1024×500 PNG/JPG, no alpha | `assets/reference/store/google_play_feature_1024x500.png` |
| Phone screenshots | 2–8, 9:16, 1080×1920 | RU: `assets/reference/store/yandex_screen_shots_ru/` · EN: `…_en/` |
| Video | optional, YouTube URL | — |

Pick 4–8 screenshots: lobby → syllable on dial → pass sparks → explosion → results → table-center mode.

### Русский (ru-RU)

**Краткое описание (≤80):**
```
Бомба-слова на одном телефоне. Передавай, придумывай, не взорвись!
```

**Полное описание (≤4000):**
```
Садитесь кругом. Один телефон — бомба. 💣

На циферблате слог и условие: слог в начале, в конце или в любом месте слова. Назовите подходящее слово вслух и коротким тапом передайте бомбу соседу. Таймер скрыт — может рвануть сразу, а может дать много кругов. Не успели — бум и штрафное очко!

КАК ИГРАТЬ
• Добавьте от 2 до 12 игроков, задайте имена и цвета слаймов.
• Выберите длительность партии и сложность.
• Придумывайте слова и передавайте бомбу тапом.
• Меньше штрафов — выше место. При ничьей — овертайм на вылет до одного победителя.

ОСОБЕННОСТИ
• Локальная игра для компании на одном телефоне — без аккаунтов и интернета.
• Режим «телефон в центре»: положите смартфон на стол, текст сам повернётся к текущему игроку.
• Аварийная кнопка — если ошиблись словом или случайно нажали.
• Три уровня сложности.
• 8 языков: русский, английский, сербский, испанский, хинди, немецкий, французский, итальянский.
• Без рекламы.

Идеально для вечеринок, семейных вечеров, поездок и посиделок с друзьями.
```

### English (en-US)

**Short description (≤80):**
```
Party word bomb on one phone. Pass it, invent words, don't explode!
```

**Full description (≤4000):**
```
Sit in a circle. One phone is the bomb. 💣

The dial shows a syllable and a rule: at the start, at the end, or anywhere in the word. Say a fitting word out loud and tap once to pass the bomb. The fuse is hidden — it may blow right away or last many rounds. Too slow? Boom — a penalty point!

HOW TO PLAY
• Add 2 to 12 players, set names and slime colors.
• Choose match length and difficulty.
• Invent words and pass the bomb with a tap.
• Fewest penalties win. Ties go to overtime knockout until one winner remains.

FEATURES
• Local party game on one phone — no accounts, no internet needed.
• “Phone in the center” mode: put the phone on the table and the text turns to the current player.
• Emergency button for a wrong word or a mis-tap.
• Three difficulty levels.
• 8 languages: English, Russian, Serbian, Spanish, Hindi, German, French, Italian.
• No ads.

Perfect for parties, family nights, road trips and hanging out with friends.
```

---

## 5. Release plan

1. **Internal testing** — upload the first signed AAB right away (checks signing, lets you install via Play and see the In-App Review dialog).
2. **Closed testing** — required for new personal accounts: **≥12 testers opted-in for 14 consecutive days**. Add testers by email list, share the opt-in link.
3. **Apply for production** (Dashboard) after 14 days → answer the questionnaire about the test → production release.
4. Countries: all (or start with RU/CIS + EN markets).

Every upload: `version/code` +1 in `export_presets.cfg` (`version/name` e.g. `1.0.1`).

---

## 6. Hosting the privacy policy

The file `docs/privacy/index.html` must be reachable by a public URL that works without login:
- **GitHub Pages** — only if the repo is public (or on a paid plan); otherwise a separate public repo with just this page.
- **Google Sites** — paste the text, publish, copy the URL.

---

## Checklist

- [ ] Placeholders in `docs/privacy/index.html` replaced, page hosted, URL works in incognito
- [ ] Upload keystore created (`tools/create_android_release_keystore.ps1`), `secrets/` backed up offline
- [ ] Release AAB exported (preset `Android`, Release), `version/code` unique
- [ ] App content: privacy, app access, ads, rating, audience, data safety, ad ID — all green
- [ ] Store listing RU + EN, icon, feature graphic, 4–8 screenshots
- [ ] Internal test install from Play: vibration, black splash, review dialog after 3 matches
- [ ] Closed test: 12+ testers, 14 days

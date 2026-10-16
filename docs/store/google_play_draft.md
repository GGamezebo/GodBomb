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
| App name (≤30) | `TicTacBadaBoom: Party Game` (since 2026-10-16; was `Tic-Tac-Bada-Boom`). On the phone: `TicTacBadaBoom` (`package/name`) |
| Default language | Russian – ru-RU *(or English – en-US if you target the world first)* |
| App or game | **Game** |
| Free or paid | **Free** (can't switch free → paid later) |
| Declarations | Developer Program Policies + US export laws — **you accept yourself** |

---

## 2. App content (Policy → App content)

### Privacy policy
**https://igorion.itch.io/tic-tac-bada-boom-privacy** (source: `docs/privacy/index.html`, see §6).

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
| Phone screenshots | 2–8, 9:16, 1080×1920 | Captioned (live order 01→06): `assets/reference/store/google_play_screens/{ru,en}/`, generated from real frames in `yandex_screen_shots_*/_original*` |
| Video | optional, YouTube URL (public or unlisted) | Ad 14 s, 1920×1080: `assets/reference/store/google_play_ad_16x9.mp4` (bar boom → English gameplay with party lines → logo, music fades out). Also `en_gameplay_16x9.mp4`, `en_promo_ad_16x9.mp4`. Upload to YouTube and paste the link. Portrait cut: `en_gameplay_9x16.mp4`. |

Pick 4–8 screenshots: lobby → syllable on dial → pass sparks → explosion → results → table-center mode.

### Русский (ru-RU)

Live since 2026-10-15 (ASO pass: «игра в слова», «для компании», «на одном телефоне», «горячая картошка», «вечеринки»; no competitor brands).

**Краткое описание (≤80):**
```
Игра в слова для компании на одном телефоне. Передай бомбу, пока не рвануло!
```

**Полное описание (≤4000):**
```
Tic-Tac-Bada-Boom — быстрая игра в слова для компании друзей на одном телефоне. Как «горячая картошка», только вместо картошки — тикающая бомба. 💣

КАК ИГРАТЬ
• На бомбе появляется слог и условие: слог в начале слова, в конце или в любом месте.
• Назови подходящее слово вслух и коротким тапом передай бомбу следующему игроку.
• Таймер скрыт: бомба может взорваться сразу, а может продержаться много кругов.
• Не успел — бум! Штрафное очко. Побеждает тот, у кого меньше штрафов. При ничьей — овертайм на вылет.

ДЛЯ ЧЕГО
Вечеринки, дни рождения, семейные вечера, поездки и любые посиделки с друзьями. Никаких карточек, поля и подготовки — нужен только один телефон и компания.

ОСОБЕННОСТИ
• От 2 до 12 игроков на одном устройстве, без аккаунтов и регистрации.
• Работает без интернета.
• Без рекламы.
• Режим «телефон в центре стола»: текст сам поворачивается к текущему игроку.
• Три уровня сложности.
• Аварийная пауза, если ошиблись словом или случайно нажали.
• 8 языков: русский, английский, сербский, испанский, хинди, немецкий, французский, итальянский.

Садитесь в круг, передавайте бомбу — и пусть она взорвётся не у вас!
```

### English (en-US)

**Short description (≤80):**
```
Party word game for friends on one phone. Pass the bomb before it explodes!
```

**Full description (≤4000):**
```
Tic-Tac-Bada-Boom is a fast party word game for a group of friends, played on a single phone. Think hot potato, but with a ticking bomb and words. 💣

HOW TO PLAY
• The bomb shows a syllable and a rule: at the start of the word, at the end, or anywhere in it.
• Say a matching word out loud and tap to pass the bomb to the next player.
• The timer is hidden: the bomb can go off right away or survive many rounds.
• Too slow? Boom! You get a penalty point. Fewest penalties wins. A tie goes to sudden-death overtime.

PERFECT FOR
Parties, birthdays, family game nights, road trips and any get-together with friends. No board, no cards, no setup: just one phone and a circle of people.

FEATURES
• 2 to 12 players on one device, no accounts or sign-up.
• Works offline, no internet needed.
• No ads.
• "Phone in the center" mode: put the phone on the table and the text turns to face the current player.
• Three difficulty levels.
• Emergency pause for a wrong word or an accidental tap.
• 8 languages: English, Russian, Serbian, Spanish, Hindi, German, French, Italian.

Sit in a circle, pass the bomb, and make sure it doesn't go off in your hands!
```

**Video (both languages, set on en-US, ru-RU inherits):** https://www.youtube.com/watch?v=CkWwSkvXi1w (`google_play_ad_16x9.mp4`, public on the Igorion channel).

**AI declaration:** icon, feature graphic and video are marked as AI-generated; screenshots are not.

---

## 5. Release plan

**Status (2026-10-16):** release `6 (1.0.5)` (new app icon, themed-icon layer, launcher name `TicTacBadaBoom`) sent for review; listing changes (new title en/ru, new icon marked as AI) sent for review; tags set to Word, Board games, Casual, Trivia; screenshots replaced with captioned ones (`assets/reference/store/google_play_screens/`).

**Status (2026-10-15):** production live (1.0.4). Store listing update (new EN/RU descriptions + YouTube video) sent for review.

**Earlier (2026-10-14):** production access granted; production release `5 (1.0.4)` (all countries, full rollout) sent for Google review. Managed publishing is ON — after approval press «Опубликовать» in Publishing overview. Closed test (Google Group `tic-tac-bada-boom-testers`) stays as the pre-release channel.

**Earlier (2026-09-27):** internal testing live — release `1 (1.0)`, testers list «Internal testers» (owner only). Opt-in link: https://play.google.com/apps/internaltest/4701361120510454944 (works only for listed emails). Price: Free. Next: closed testing via a Google Group (≥12 testers × 14 days).

1. **Internal testing** — upload the first signed AAB right away (checks signing, lets you install via Play and see the In-App Review dialog).
2. **Closed testing** — required for new personal accounts: **≥12 testers opted-in for 14 consecutive days**. Add testers by email list, share the opt-in link.
3. **Apply for production** (Dashboard) after 14 days → answer the questionnaire about the test → production release.
4. Countries: all (or start with RU/CIS + EN markets).

Every upload: `version/code` +1 in `export_presets.cfg` (`version/name` e.g. `1.0.1`).

---

## 6. Hosting the privacy policy

Hosted on itch.io as a separate public project (classification *Other*, no files, payments off): **https://igorion.itch.io/tic-tac-bada-boom-privacy**. The game page https://igorion.itch.io/tic-tac-bada-boom links to it. When `docs/privacy/index.html` changes, paste the new body into that project's description (itch.io → Edit project) and update the effective date.

---

## Checklist

- [x] Privacy policy hosted on itch.io, opens without login
- [ ] Upload keystore created (`tools/create_android_release_keystore.ps1`), `secrets/` backed up offline
- [ ] Release AAB exported (preset `Android`, Release), `version/code` unique
- [ ] App content: privacy, app access, ads, rating, audience, data safety, ad ID — all green
- [ ] Store listing RU + EN, icon, feature graphic, 4–8 screenshots
- [ ] Internal test install from Play: vibration, black splash, review dialog after 3 matches
- [ ] Closed test: 12+ testers, 14 days

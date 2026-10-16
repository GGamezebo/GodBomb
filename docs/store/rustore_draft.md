# RuStore — Tic-Tac-Bada-Boom

Console: https://console.rustore.ru/apps/2063768470 · general notes → [listing.md](./listing.md), texts reused from [google_play_draft.md](./google_play_draft.md).

Facts (re-check if code changes): no INTERNET permission, only `VIBRATE`; no ads, analytics, purchases; local save only (`user://`). Package `com.tictacbadaboom.app`, preset `RuStore APK` (feature `rustore`, no Google Play code).

## Build

1. Export preset **RuStore APK** (Release) → `bin/android/tictacbadaboom_rustore.apk`. Fill the keystore in Export → Options first (credentials are per preset).
2. `version/code` must be unique in the RuStore console and higher than any earlier upload there.
3. Sanity check on a phone **without** Google Play (or at least: install the APK, play 3 matches, no crash on return to menu).

## Signing

Console → «Подпись приложения»: upload your own key or hand signing to RuStore. The key cannot be changed after publishing.

## Store page

| Field | Value |
|---|---|
| Name | `Tic-Tac-Bada-Boom` |
| Short description (already set) | `Бомба-слова на одном телефоне. Передавай, придумывай, не взорвись.` |
| Full description | RU text from `google_play_draft.md` §4 |
| Category | Games → Word / Party |
| Price | Free |
| Icon 512×512 | `assets/reference/store/yandex_icon_512.png` |
| Screenshots (portrait) | `assets/reference/store/yandex_screen_shots_ru/` |
| Video (optional) | `assets/reference/store/yandex_promo_ad_16x9.mp4` / `en_gameplay_9x16.mp4` |
| Privacy policy | https://igorion.itch.io/tic-tac-bada-boom-privacy |

## Age rating (console questionnaire)

Violence / fear / sexual content / language / substances / gambling: No · user chat or content: No · purchases: No · ads: No. Expected 0+ (re-check what the console proposes).

## Checklist

- [ ] Developer profile verified (Разработчик)
- [ ] Preset `RuStore APK` exported, keystore chosen, `version/code` unique
- [ ] Signing configured in console
- [ ] Store page: description, category, icon, screenshots
- [ ] Age rating questionnaire
- [ ] Privacy policy link
- [ ] Sent to moderation

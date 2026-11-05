# Лицензии и атрибуция

Проект «Sector 9» — учебный вертикальный срез. Ниже перечислены все сторонние
материалы, которые входят в репозиторий и в Windows-сборку, а также авторские
материалы, созданные для проекта.

## Сторонние материалы

### Портрет Гриши — Strangers Vol.1

- **Автор:** Francisco Lemos
- **Источник:** https://lemos.itch.io/strangers-vol-1
- **Лицензия:** Creative Commons Attribution 4.0 International (CC BY 4.0)
  https://creativecommons.org/licenses/by/4.0/
- **Что использовано:** `Strangers_019.png` из пака, сохранён как
  `assets/portraits/grisha.png`.
- **Изменения:** исходный файл не изменялся. В интерфейсе портрет тонируется
  цветом чернил и накладывается на бумажную карточку.
- **Текст лицензии:** `assets/portraits/LICENSE-CC-BY-4.txt`.

Атрибуция для указания при распространении:
`Портрет: Francisco Lemos, Strangers Vol.1, CC BY 4.0, https://lemos.itch.io/strangers-vol-1`.

### Дождь, город и неон — Rainy City Ambience SFX Pack

- **Автор:** bobkingg
- **Источник:** https://bobkingg.itch.io/rainy-city-ambience-sfx-pack
- **Лицензия:** CC0 1.0 Universal (Public Domain Dedication)
  https://creativecommons.org/publicdomain/zero/1.0/
- **Что использовано:**
  - `01-rain-on-awning.wav` → `assets/audio/rain_loop.wav`;
  - `03-distant-traffic-hum.wav` → `assets/audio/traffic_hum.wav`;
  - `04-neon-sign-buzz.wav` → `assets/audio/neon_buzz.wav`;
  - `05-wet-footsteps-passby.wav` → `assets/audio/footsteps_pass.wav`;
  - `06-far-thunder-roll.wav` → `assets/audio/thunder.wav`;
  - `07-drain-gurgle-loop.wav` → `assets/audio/drain_loop.wav`.
- **Изменения:** файлы переименованы; из записи проходящих шагов выделен
  короткий `assets/audio/footstep.wav`.
- **Текст лицензии:** `assets/audio/LICENSE-CC0-RainyCity.txt`.

Атрибуция не требуется по условиям CC0, но автор указан из уважения к работе.

### Щелчок щитка — SFX: Circuit breaker

- **Автор:** Cleyton Kauffman (CleytonKauffman)
- **Источник:** https://opengameart.org/content/sfx-circuit-breaker
- **Лицензия:** CC0 1.0 Universal
  https://creativecommons.org/publicdomain/zero/1.0/
- **Что использовано:** `assets/audio/breaker.ogg`.
- **Изменения:** файл не изменялся.

### Шрифты

Все три шрифта распространяются по SIL Open Font License 1.1
(https://openfontlicense.org/). Тексты лицензий лежат рядом со шрифтами.

| Шрифт | Файл | Автор / источник | Лицензия |
| --- | --- | --- | --- |
| EB Garamond | `assets/fonts/EBGaramond.ttf` | The EB Garamond Project Authors, https://github.com/octaviopardo/EBGaramond12 | SIL OFL 1.1, `assets/fonts/OFL-EBGaramond.txt` |
| PT Mono | `assets/fonts/PTMono-Regular.ttf` | ParaType Ltd., https://www.paratype.com/fonts/pt/pt-mono | SIL OFL 1.1, `assets/fonts/OFL-PTMono.txt` |
| Oswald | `assets/fonts/Oswald.ttf` | The Oswald Project Authors, https://github.com/googlefonts/OswaldFont | SIL OFL 1.1, `assets/fonts/OFL-Oswald.txt` |

## Авторские материалы проекта

Следующие материалы созданы специально для этого вертикального среза:

- все SVG-спрайты и текстуры в `assets/sprites/` и `assets/textures/`, кроме
  бумажной текстуры, включая щиток, тумблеры, кабели, записку, персонажей,
  дождь, брызги, свет и тени;
- процедурная графика в `scripts/world.gd`: асфальт, бетон, окна, трубы, постеры,
  лужи, отражения, мусор и граффити;
- шейдеры виньетки, зерна и бумаги в `scenes/hud.tscn` и `scripts/ink_panel.gd`;
- `assets/textures/paper.jpg` — процедурно сгенерированная бумажная текстура;
- `assets/audio/tick.wav`, `assets/audio/fail.wav`, `assets/audio/powerup.wav` —
  синтезированные звуки для печатной машинки, короткого замыкания и включения питания;
- весь код на GDScript, сцены, JSON-диалоги и тексты.

Эти материалы можно использовать в рамках проекта и его сборки. Если планируется
переиспользовать их отдельно, лучше сначала связаться с автором проекта.

## Материалы, которые не входят в репозиторий

- **OhmTap — OT01 Industrial Electrical Devices** (https://ohmtap.itch.io/ot01-industrial-electrical-devices)
  использовался только как визуальный референс для формы щитка. Файлы пака
  намеренно не включены в репозиторий и сборку, потому что его лицензия запрещает
  распространять ассеты отдельно. Вся графика щитка нарисована заново в SVG.
- **ambientCG Paper006** не входит в проект: бумажная текстура была заменена
  собственной процедурной текстурой.

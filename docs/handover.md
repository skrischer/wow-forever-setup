# Übergabe an die Claude-Code-Session auf dem Windows-PC

Stand: 4.11.2026, morgens. **Launch: heute Nacht, 5.11. um 0:00 Uhr (MEZ).** Charaktererstellung und Namensreservierung sind schon offen, ins Spiel kommt man erst zum Launch.

Dieses Repo ist in einer Cloud-Session mit Basti entstanden: Recherche, Entscheidungen und das Addon ForeverSetup bis v0.4. Auf dem PC wurde noch nichts getestet. Alles, was hier über Forever steht, stammt aus Beta-Quellen, Guides und einem nachgebauten Client.

## Zuerst lesen

1. `CLAUDE.md`: Kontext, Ziel-Setup, harte Regeln, Phasen. **Bindend.**
2. `README.md`: Entscheidungen, komplette Tastenbelegung, Testplan.
3. `docs/ui-layout.md`: HUD-Layout, eingebaute Anzeigen, Cooldown-Manager-Belegung.
4. `ForeverSetup/Config.lua`: alles Einstellbare. `Core.lua` ist die Logik.

## Stand

| Bereich | Status |
|---|---|
| Entscheidungen (Rasse, Spec, Berufe, Controller, UI) | fertig, siehe README |
| ForeverSetup v0.4: Makros, Leisten-Slots, Tasten, CVars, Verbrauchsgüter, Prot/Arms-Set | fertig, **nur gegen nachgebauten Client getestet** |
| Addon-Liste (Ziel-Setup) | fertig, Anvilstride braucht noch Code-Review |
| Addons installiert | **nein** (Phase 1) |
| Addon-Review und Abschaltregeln (`Addons.lua`) | **offen** (Phase 2/3) |
| Edit Mode, Cooldown Manager, eingebaute Anzeigen | Anleitung fertig, Basti richtet sie von Hand ein |
| Controller-Belegung | **offen**, erst nach Test der Gamepad UI |

## Nächster Schritt

Phase 0 aus der `CLAUDE.md`: WoW-Installation finden, freien Speicher prüfen, AddOns- und WTF-Ordner auflisten, dann ⏸ Bericht. Danach Phase 1.

ForeverSetup kann schon jetzt per Junction verlinkt werden (Regel 6). Es wird beim ersten Login aktiv.

## Test mit dem nachgebauten Client

```
pip install lupa
python tests/mock_client_test.py
```

Er läuft mit Exit-Code 0, wenn alles passt. Er prüft die Logik: Stance-Seiten, Makro-Längen und -Limits, Tastenbelegung (QWERTZ, A/D, alte Belegungen), Gegenstände in den Slots, Wechsel zwischen Prot und Arms. Er beweist **nicht**, dass der echte Client sich so verhält. Nach jeder Änderung an `Config.lua` oder `Core.lua` laufen lassen und bei neuen Funktionen erweitern.

## Wichtige Erkenntnisse aus der Recherche

- **Umblättern der Leiste pro Haltung** war in der Beta seit dem 16.10. kaputt (forever-bugs #356). ForeverSetup kopiert Leiste 1 zusätzlich in die Haltungs-Seiten (Slots 73–108) und funktioniert in beiden Fällen.
- **Ziel-Debuffs sind im Kampf für Addons unsichtbar** (Midnight-API, „secret values“). Deshalb kommen Kampfanzeigen von Blizzard selbst: Cooldown Manager, Swing-Timer, Personal Resource Display, Nameplates. Plater und Kampf-HUD-Addons wurden bewusst gestrichen.
- **`C_EditMode.SaveLayouts`** ist nur für Blizzards eigenen Code erlaubt. Layouts nicht per Addon schreiben, Basti exportiert sie als Text nach `ui/`.
- **Cooldown Manager:** Im Build vom 24.9. konnte er keine Zauber-Ränge auseinanderhalten. Am echten Client prüfen.
- **Makros:** ForeverSetup legt 24 Makros an. Bei mehr als 18 pro Charakter weicht es auf die accountweiten aus. Das echte Limit in Forever ist unbestätigt.
- **Victory Rush:** Die Spell-ID ist unbestätigt, aktuell wird der Name als Fallback genutzt. `/fsetup status` meldet das.
- **Haltungs-Anforderungen** (Thunder Clap in Battle/Def usw.) und **Lernlevel** sind Classic-Werte, Forever hat einiges verschoben.
- **Installationsordner:** In der Beta hieß er `_classic_beta_`, der Live-Name ist unbestätigt. Nicht raten (Regel 3).
- **Addons von GitHub:** Nur 4 der Ziel-Addons haben Forever-Releases auf GitHub (Questie, MinimapButtonButton, SkillUp Forever, Easy Controller). Der Rest kommt über die CurseForge-App.

## Hinweise zum Code

- `try()` in `Core.lua` muss alle Rückgabewerte durchreichen, deshalb `pack`/`unpack` mit `n`. Eine frühere Version hat nach 7 Werten abgeschnitten, damit wurde das Reittier nie erkannt.
- Aktualisierungen im Hintergrund (Taschen, Lernen, Ausrüstung) laufen still und nie im Kampf (`pending` + `PLAYER_REGEN_ENABLED`).
- Belegte Slots werden bei jeder Aktualisierung auf den Soll-Zustand gesetzt. Eigenes gehört auf Leiste 4 und höher, die ist für die Gamepad UI reserviert.
- `/fsetup reset` und ein neuer Login wenden alles neu an. Mit `ForeverSetupDB.version` laufen Upgrades automatisch.

## Ideen für später (mit Basti besprochen, nicht beauftragt)

- Schild- und Zweihand-Wechsel abhängig von Haltung und Spec. Vorher prüfen, ob Waffenwechsel im Kampf in Forever erlaubt ist.
- Tank-Werkzeuge: Makros für Zielmarkierungen und eine Pull-Ansage, ein Instanz-Check.
- Camp-Helfer (Lodestone/Sharpening Wheel, 1 Stunde Cooldown, Sitz-Countdown).
- Couch-Modus: TV-taugliche Einstellungen, sobald die Gamepad UI aktiv ist.
- Ingenieur-Slots ⇧X/⇧Y für Granaten und Bomben, sobald Basti umsteigt.

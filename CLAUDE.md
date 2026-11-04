# CLAUDE.md – wow-forever-setup

Du richtest Bastis WoW Forever auf seinem privaten Windows-10-PC ein und pflegst das Addon **ForeverSetup**.
Antworte auf Deutsch. Arbeite in Phasen und **stoppe an jedem Haltepunkt (⏸)**, bis Basti entscheidet.

**Zu Beginn jeder Session: `docs/handover.md` lesen** (Stand, nächster Schritt, Erkenntnisse). Am Ende einer Session den Stand dort aktualisieren.
Nach jeder Änderung an ForeverSetup: `python tests/mock_client_test.py` muss mit Exit-Code 0 laufen.

## Kontext

- **Charakter:** Human-Krieger, Allianz, Normal-Server
- **Spielweise:** Prot zum Leveln, Arms für Battlegrounds im Endgame
- **Berufe:** erst Bergbau + Schmieden, später Ingenieur
- **Eingabe:** Maus und Tastatur (**deutsche QWERTZ-Tastatur**, A/D = Seitwärtsschritt, Maus mit 2 Seitentasten) sowie ein 8BitDo-Controller (XInput) per Sunshine-Stream auf den Fernseher. Beides muss funktionieren.
- **UI:** Blizzard-Default (Midnight-UI, Edit Mode). Kampfanzeigen kommen von Blizzard selbst: Personal Resource Display, Swing-Timer, Cooldown Manager (auch Ziel-Debuffs, Sound-Alarme), Nameplates mit Aggro-Farben. Siehe `docs/ui-layout.md`.
- **Addon-Philosophie:** schlank. Keine doppelten Funktionen, **genau ein Pfeil** (TomTom), alle Minimap-Icons in MinimapButtonButton gebündelt.
- **Launch:** 5.11.2026, 0:00 Uhr (MEZ). Addon-Einstellungen entstehen erst beim ersten Login in die Spielwelt.
- **Hardware:** Ryzen 7 1700X, GTX 1070. Die SATA-SSD (~488 GB) ist **chronisch voll**, prüfe vor jeder Installation den freien Speicher.
- **Technik:**
  - Forever nutzt die Midnight-Addon-API mit TOC-Interface 16001.
  - WeakAuras und das Kampflog sind für Addons gesperrt, außerdem gibt es geschützte Werte („secret values“).
  - Die Funktionen zum Anlegen von Makros, Setzen von Tastenbelegungen und CVars (`CreateMacro`, `SetBinding`, `SetCVar`) funktionieren nur außerhalb des Kampfes.

## Ziel-Setup (Flavor „Forever“; Quelle siehe Phase 1)

| Bereich | Addon | Konfigurationsziel |
|---|---|---|
| Quests | Questie (+ Questie Gamepad Fix) | Kartenpins an, kein eigener Pfeil |
| Sanftes Guiding | Anvilstride (**Kandidat, erst Code-Review**) | nur das Journey-Modul nutzen; Kompass und Dungeon-Companion aus. Lässt sich das nicht abschalten → raus |
| Dungeons, Loot, Gear, Klassenquests | Forever Guide | eingebauten Gruppenfinder (LFG) aus, Tooltips nur mit Shift, TomTom als Pfeil, Minimap-Knopf über MBB. Bibliotheksbücher hier **oder** in ForeverSecrets anzeigen, nicht in beiden |
| Elite-Quests | UlDungeonCompanion | doppelte Dungeon-Eingangs-Pins vermeiden, falls möglich |
| Geheimnisse | ForeverSecrets | Minimap-Knopf aus |
| Berufe | SkillUp Forever | |
| Talente | Forever Talents | nur Vorschau-Glühen im Talentfenster, kein Auto-Skillen |
| Pfeil | TomTom | einziger Pfeil |
| Auktionshaus | Auctionator | Auktionspreise im Tooltip; Händlerpreis-Anzeige prüfen (Vendor Price nur, falls Blizzard ihn nicht selbst anzeigt) |
| Taschen | Baganator | |
| Komfort | Leatrix Plus | Auto-Reparieren, Junk verkaufen; keine Auto-Quest-Annahme (Basti will Quests selbst lesen) |
| Post | ForeverMail | |
| Tank | – (Blizzard-Nameplates mit Aggro-Farben) | Plater/ForeverThreat nur nachrüsten, falls die eingebauten Nameplates nicht reichen. Addons sehen Ziel-Debuffs im Kampf nicht, Blizzards eigene Anzeigen schon |
| Minimap | MinimapButtonButton | |
| Controller | Easy Controller – Forever | |

**Bewusst nicht dabei:** WeakAuras, ElvUI, ConsolePort, AtlasLoot, GearQuest, alle Karten-Addons (Leatrix Maps erst bei Bedarf), Offhand, Kampf-HUDs und Swing-Timer-Addons (eingebaut), Plater/ForeverThreat (erst nach Test).

## Harte Regeln

1. **Nichts im WoW-Ordner ändern, solange das Spiel läuft.** Prüfe vorher, ob `Wow*.exe` läuft. Läuft es, abbrechen und Basti Bescheid geben.
2. **Vor jedem Schreibzugriff auf `WTF/` ein Backup anlegen,** mit Zeitstempel unter `backups/` im Repo (in `.gitignore` aufnehmen). Danach den Diff zeigen.
3. **Installationspfade nie raten.** Ermitteln über die Battle.net-Konfiguration oder suchen, dann bestätigen lassen. In der Beta hieß der Ordner `_classic_beta_`, für den Live-Client ist der Name unbestätigt.
4. **Keine fremden EXEs ausführen oder installieren.** Keine Begleit-Apps, Offhand Companion, ForeverDubbed-App oder Ähnliches.
5. **Battle.net-Client und Account nicht anfassen.**
6. **ForeverSetup per Junction verlinken** (`mklink /J`, Repo → `Interface\AddOns\ForeverSetup`), nicht kopieren.
7. **Nicht pushen** ohne Bastis OK. Commits mit Attribution sind ok. Das Remote ist `github.com/skrischer/wow-forever-setup` (privat).
8. **Ehrlichkeit:** Was nur aus Code oder Doku abgeleitet ist und nicht im Spiel getestet wurde, wird als „ungetestet“ markiert.

## Phasen

- **0 · Orientierung:** Repo lesen, WoW-Installation finden, freien Speicher prüfen, vorhandene Addons und den WTF-Ordner auflisten. ⏸ Bericht
- **1 · Installation:** Zwei Wege, je nach Addon.
  - **a) Von GitHub automatisch (4 Addons).** Neueste Release-Assets herunterladen, nach `staging/` (in `.gitignore`). Bei Mehr-Flavor-Zips über das `release.json`-Asset prüfen, dass `forever` / 16001 enthalten ist. Erst nach dem Review aus Phase 2 entpacken.

    | Addon | Repo | Asset |
    |---|---|---|
    | Questie | `Questie/Questie` | Mehr-Flavor-Zip, ~89 MB |
    | MinimapButtonButton | `syndenbock/MinimapButtonButton` | Mehr-Flavor-Zip |
    | SkillUp Forever | `cjber/skillup-forever` | `*-forever.zip` |
    | Easy Controller – Forever | `moust4ki/EasyControllerWowForever` | Forever-only-Zip |

  - **b) Über die CurseForge-App (der Rest).** Für diese Addons gibt es keine GitHub-Releases. Basti installiert sie per Klick nach einer Liste, die du ihm gibst.
  - Danach in der CurseForge-App „Scan for Addons“ ausführen und berichten, welche GitHub-Installationen CurseForge erkannt hat. Ein nicht erkanntes Addon installiert Basti über CurseForge neu, damit Updates funktionieren. ⏸
- **2 · Addon-Review:** Jedes Addon im Quellcode prüfen, entweder aus `staging/` oder aus `Interface\AddOns`. Addons laufen erst beim Spielstart, deshalb gilt ein Review vor dem ersten Start wie ein Review vor der Installation. Pro Addon berichten:
  - was es tut, welche Abschalt-Optionen es gibt (SavedVariables-Schlüssel, Slash-Befehle, Optionsseite)
  - wo es Überschneidungen gibt, wie viel Speicher es grob braucht
  - Risiken: Taint, Hooks auf geschützte Frames, ständige Update-Schleifen
  - Für Anvilstride gibt es eine Go/No-Go-Empfehlung. Ergebnis ist `docs/addon-review.md`, und die Addon-Liste im README wird aktualisiert. ⏸ Entscheidung
- **3 · ForeverSetup erweitern:**
  - Neues Modul `Addons.lua`, das die Abschaltregeln aus Phase 2 beim ersten Login anwendet.
  - Es arbeitet nur über öffentliche Optionen, Slash-Befehle oder SavedVariables-Tabellen, jeweils abgesichert mit `C_AddOns.IsAddOnLoaded` und `pcall`, und nie im Kampf.
  - Dazu ein Lua-Test mit nachgebauter WoW-API (deutscher Client). ⏸ Review
- **4 · Nach dem ersten Login (Launch-Nacht):** Bei geschlossenem Spiel:
  - Prüfen, ob die SavedVariables zu den Annahmen aus Phase 2 passen. Was die Laufzeit-Regeln nicht abdecken, offline setzen, mit Backup und Diff.
  - Basti hat die eingebauten Anzeigen (Cooldown Manager, Swing-Timer, Personal Resource Display, Damage-Meter, Ziel des Ziels) einmal von Hand eingeschaltet. Aus `WTF/Config.wtf` und `WTF/Account/*/config-cache.wtf` die CVar-Namen ablesen (Diff gegen das Backup) und in `FS.CVars` übernehmen, damit Twinks sie automatisch bekommen.
  - Edit-Mode- und Cooldown-Manager-Exporte, die Basti dir gibt, unter `ui/` ablegen. ⏸
- **5 · Testcheckliste** aus dem README gemeinsam abarbeiten und Befunde in `docs/test-log.md` festhalten.

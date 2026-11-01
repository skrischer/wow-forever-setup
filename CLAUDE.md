# CLAUDE.md – wow-forever-setup

Du richtest Bastis WoW Forever auf seinem privaten Windows-10-PC ein und pflegst das Addon **ForeverSetup**.
Antworte auf Deutsch. Arbeite in Phasen und **stoppe an jedem Haltepunkt (⏸)**, bis Basti entscheidet.

## Kontext

- **Charakter:** Human-Krieger, Allianz, Normal-Server
- **Spielweise:** Prot zum Leveln, Arms für Battlegrounds im Endgame
- **Berufe:** erst Bergbau + Schmieden, später Ingenieur
- **Eingabe:** Maus und Tastatur sowie ein 8BitDo-Controller (XInput) per Sunshine-Stream auf den Fernseher. Beides muss funktionieren.
- **UI:** Blizzard-Default (Midnight-UI, Edit Mode)
- **Addon-Philosophie:** schlank. Keine doppelten Funktionen, **genau ein Pfeil** (TomTom), alle Minimap-Icons in MinimapButtonButton gebündelt.
- **Launch:** 5.11.2026, 0:00 Uhr (MEZ). Addon-Einstellungen entstehen erst beim ersten Login in die Spielwelt.
- **Hardware:** Ryzen 7 1700X, GTX 1070. Die SATA-SSD (~488 GB) ist **chronisch voll**, prüfe vor jeder Installation den freien Speicher.
- **Technik:**
  - Forever nutzt die Midnight-Addon-API mit TOC-Interface 16001.
  - WeakAuras und das Kampflog sind für Addons gesperrt, außerdem gibt es geschützte Werte („secret values“).
  - Die Funktionen zum Anlegen von Makros, Setzen von Tastenbelegungen und CVars (`CreateMacro`, `SetBinding`, `SetCVar`) funktionieren nur außerhalb des Kampfes.

## Ziel-Setup (Addons, über die CurseForge-App, Flavor „Forever“)

| Bereich | Addon | Konfigurationsziel |
|---|---|---|
| Quests | Questie (+ Questie Gamepad Fix) | Kartenpins an, kein eigener Pfeil |
| Sanftes Guiding | Anvilstride (**Kandidat, erst Code-Review**) | nur das Journey-Modul nutzen; Kompass und Dungeon-Companion aus. Lässt sich das nicht abschalten → raus |
| Dungeons, Loot, Gear, Klassenquests | Forever Guide | eingebauten Gruppenfinder (LFG) aus, Tooltips nur mit Shift, TomTom als Pfeil, Minimap-Knopf über MBB. Bibliotheksbücher hier **oder** in ForeverSecrets anzeigen, nicht in beiden |
| Elite-Quests | UlDungeonCompanion | doppelte Dungeon-Eingangs-Pins vermeiden, falls möglich |
| Geheimnisse | ForeverSecrets | Minimap-Knopf aus |
| Berufe | SkillUp Forever | |
| Pfeil | TomTom | einziger Pfeil |
| Auktionshaus | Auctionator | Auktionspreise im Tooltip; Händlerpreis-Anzeige prüfen (Vendor Price nur, falls Blizzard ihn nicht selbst anzeigt) |
| Taschen | Baganator | |
| Komfort | Leatrix Plus | Auto-Reparieren, Junk verkaufen; keine Auto-Quest-Annahme (Basti will Quests selbst lesen) |
| Post | ForeverMail | |
| Tank | Plater + ForeverThreat | Threat-Farben an |
| Minimap | MinimapButtonButton | |
| Controller | Easy Controller – Forever | |

**Bewusst nicht dabei:** WeakAuras, ElvUI, ConsolePort, AtlasLoot, GearQuest, alle Karten-Addons (Leatrix Maps erst bei Bedarf), Offhand.

## Harte Regeln

1. **Nichts im WoW-Ordner ändern, solange das Spiel läuft.** Prüfe vorher, ob `Wow*.exe` läuft. Läuft es, abbrechen und Basti Bescheid geben.
2. **Vor jedem Schreibzugriff auf `WTF/` ein Backup anlegen,** mit Zeitstempel unter `backups/` im Repo (in `.gitignore` aufnehmen). Danach den Diff zeigen.
3. **Installationspfade nie raten.** Ermitteln über die Battle.net-Konfiguration oder suchen, dann bestätigen lassen. In der Beta hieß der Ordner `_classic_beta_`, für den Live-Client ist der Name unbestätigt.
4. **Keine fremden EXEs ausführen oder installieren.** Keine Begleit-Apps, Offhand Companion, ForeverDubbed-App oder Ähnliches.
5. **Battle.net-Client und Account nicht anfassen.**
6. **ForeverSetup per Junction verlinken** (`mklink /J`, Repo → `Interface\AddOns\ForeverSetup`), nicht kopieren.
7. **Nicht pushen** ohne Bastis OK. Commits mit Attribution sind ok.
8. **Ehrlichkeit:** Was nur aus Code oder Doku abgeleitet ist und nicht im Spiel getestet wurde, wird als „ungetestet“ markiert.

## Phasen

- **0 · Orientierung:** Repo lesen, WoW-Installation finden, freien Speicher prüfen, vorhandene Addons und den WTF-Ordner auflisten. ⏸ Bericht
- **1 · Addon-Review:** Basti installiert die Addons über die CurseForge-App. Danach jedes Addon im Quellcode prüfen und pro Addon berichten:
  - was es tut, welche Abschalt-Optionen es gibt (SavedVariables-Schlüssel, Slash-Befehle, Optionsseite)
  - wo es Überschneidungen gibt, wie viel Speicher es grob braucht
  - Risiken: Taint, Hooks auf geschützte Frames, ständige Update-Schleifen
  - Für Anvilstride gibt es eine Go/No-Go-Empfehlung. Ergebnis ist `docs/addon-review.md`, und die Addon-Liste im README wird aktualisiert. ⏸ Entscheidung
- **2 · ForeverSetup erweitern:**
  - Neues Modul `Addons.lua`, das die Abschaltregeln aus Phase 1 beim ersten Login anwendet.
  - Es arbeitet nur über öffentliche Optionen, Slash-Befehle oder SavedVariables-Tabellen, jeweils abgesichert mit `C_AddOns.IsAddOnLoaded` und `pcall`, und nie im Kampf.
  - Dazu ein Lua-Test mit nachgebauter WoW-API (deutscher Client). ⏸ Review
- **3 · Nach dem ersten Login (Launch-Nacht):** Bei geschlossenem Spiel prüfen, ob die SavedVariables zu den Annahmen aus Phase 1 passen. Was die Laufzeit-Regeln nicht abdecken, offline setzen, mit Backup und Diff. ⏸
- **4 · Testcheckliste** aus dem README gemeinsam abarbeiten und Befunde in `docs/test-log.md` festhalten.

# wow-forever-setup

Bastis Setup für **WoW Forever**: Human-Krieger (Allianz), Prot zum Leveln, Arms für Battlegrounds im Endgame. Gespielt wird mit Maus/Tastatur und mit 8BitDo-Controller über Sunshine.

## Entscheidungen

| Bereich | Entscheidung |
|---|---|
| Rasse | Human: Ruthless +2 % Crit, Will to Survive, Perception |
| Leveling | Prot, Talentpfad nach Icy Veins (Vanguard Lvl 23–25, Shield Slam 40) |
| Endgame | Arms, PvP in Battlegrounds auf einem Normal-Server. Dual-Spec ist unklar, bis dahin per Trainer umskillen. |
| Berufe | Bergbau + Schmieden zum Leveln, später Ingenieur |
| Controller | Native Gamepad UI (Alpha) + Easy Controller – Forever |
| UI | Blizzard-Default (Midnight-UI mit Edit Mode) |

## Addon: ForeverSetup

Beim ersten Login richtet das Addon den Charakter automatisch ein. Danach lässt es sich jederzeit per `/fsetup` erneut ausführen.

- **Lokalisierungsfest:** Zauber werden per Spell-ID aufgelöst, deutscher Client funktioniert also.
- **Smart:** Hat der Charakter Vanguard geskillt, darf Charge auch aus Defensive Stance kommen. Bei Talent- und Zauberänderungen werden die Makros automatisch aktualisiert.
- **Kampfsicher:** Im Kampf ändert das Addon nichts, anstehende Änderungen laufen nach dem Kampf.
- **Idempotent:** Mehrfaches Ausführen aktualisiert, statt zu duplizieren.
- Die Tastenbelegung wird charakterspezifisch gespeichert. Gamepad-Belegungen bleiben unangetastet.

Befehle: `/fsetup [all|macros|binds|cvars|status|reset]`

### Makros

| Makro | Logik |
|---|---|
| FS Charge | Außerhalb des Kampfes Charge (mit Vanguard auch aus Defensive), im Kampf Berserker Stance → Intercept |
| FS Interrupt | Mit Schild Shield Bash, sonst Berserker Stance → Pummel |
| FS Overpower | Battle Stance → Overpower (Tactical Mastery ist jetzt baseline) |
| FS BRage | Berserker Stance → Berserker Rage (Fear-Break) |
| FS Taunt | Defensive: Taunt, Battle: Mocking Blow, sonst → Defensive Stance |
| FS Strike | /startattack, Heroic Strike, mit Shift Cleave |
| FS VRush | Victory Rush (neu in Forever) |
| FS Spear | Battle Stance → Spearing Strike (Arms) |

### Tastenbelegung (Maus/Tastatur)

| Taste | Belegung | Shift + Taste | Belegung |
|---|---|---|---|
| 1 | FS Strike | Shift-1 | Battle Stance |
| 2 | Revenge | Shift-2 | Defensive Stance |
| 3 | Sunder Armor | Shift-3 | Berserker Stance |
| 4 | Shield Block | | |
| 5 | Thunder Clap | | |
| Q | Shield Slam | Shift-Q | Bloodrage |
| E | FS VRush | Shift-E | FS Overpower |
| R | Demoralizing Shout | Shift-R | FS BRage |
| F | FS Taunt | Shift-F | Shield Wall |
| G | Battle Shout | Shift-G | Last Stand |

Maustasten: Seitentaste 4 = FS Interrupt, Seitentaste 5 = FS Charge.

⚠️ Q und E ersetzen die Standard-Strafe-Tasten. Das lässt sich in `Config.lua` ändern.

## Addon-Liste (über die CurseForge-App installieren, Flavor „Forever“)

| Addon | Zweck | Hinweis |
|---|---|---|
| Questie | Questhilfe | läuft mit den Forever-Zonen |
| Questie Gamepad Fix | Questie mit Controller | |
| Easy Controller – Forever | Controller-Komfort | baut auf der nativen Gamepad UI auf |
| Baganator | Taschen | |
| Auctionator | Auktionshaus | TSM gibt es noch nicht für Forever |
| ForeverMail | Post | Ersatz für Postal |
| Plater | Nameplates mit Threat-Farben | wichtigstes Tank-Werkzeug |
| ForeverThreat | Threat-Meter | Threat-API teilweise eingeschränkt, Lücken möglich |
| Leatrix Plus | Komfortfunktionen (QoL) | alles modular, standardmäßig aus |
| Leatrix Maps | Karte | nur ein Karten-Addon nutzen |
| Vendor Price | Händlerpreise im Tooltip | |
| AtlasLoot Classic Forever | Dungeon- und Raid-Loot, BiS-Listen | Abdeckung der neuen Forever-Dungeons unklar |
| Atlas Forever | Dungeon-Karten | enthält 3 Forever-Dungeons |
| My Forever Recipe Book | Rezept-Datenbank: wo lernen, welche Quelle | noch Beta |
| *optional:* ForeverCodex | Handwerk in der Gilde teilen | |

**Bewusst nicht dabei:**
- WeakAuras: funktioniert in Forever nicht. Ersatz ist der eingebaute Cooldown Manager.
- Details: zeigt nur die Zahlen des eingebauten Damage-Meters.
- ElvUI: würde den Blizzard-Look ersetzen.
- ConsolePort: komplex und störanfällig.

## Testplan ab 27.10. (Charaktererstellung)

1. Client installieren und den echten Ordnernamen prüfen: Battle.net → Zahnrad → „Im Explorer anzeigen“. In der Beta hieß er `_classic_beta_`.
2. `ForeverSetup/` nach `Interface/AddOns/` kopieren und Charakter erstellen.
3. Einloggen, dann `/fsetup status` aufrufen. Prüfen, ob Zauber per Fallback-Namen aufgelöst wurden, vor allem die Victory-Rush-ID.
4. Makros im Makro-Fenster kontrollieren und Tasten am Trainingsdummy testen.
5. Ausloggen und wieder einloggen. Prüfen, ob die Server-Synchronisierung etwas überschreibt.
6. Controller: Gamepad UI aktivieren und Edit-Mode-Layout getrennt anlegen. Prüfen, ob Controller-Leisten dieselben Slots wie Maus/Tastatur belegen.
7. Sunshine-Stream starten und beenden. Danach prüfen, ob das UI im Controller-Modus hängen bleibt.
8. Cooldown Manager und Damage-Meter in den Optionen aktivieren und die CVar-Namen für `Config.lua` notieren.

## Offene Punkte

- **Gamepad-Belegung:** Die Tastenvergabe am Controller wird nach dem Test festgelegt, Grundlage sind die 4 Sets à 8 Tasten der nativen Gamepad UI.
- **Berufe:** Wann der Wechsel von Schmieden zu Ingenieur kommt, ist noch offen.
- **Dual-Spec:** Status beobachten.
- **Arms-PvP-Build:** Bisher gibt es nur einen Theorycraft-Build, er wird nach dem Launch validiert.

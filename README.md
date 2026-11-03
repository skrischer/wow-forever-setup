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
| UI | Blizzard-Default (Midnight-UI mit Edit Mode). Einheitenfenster und Cooldown Manager mittig unter der Figur, siehe [docs/ui-layout.md](docs/ui-layout.md) |

## Addon: ForeverSetup (v0.2)

Beim ersten Login richtet das Addon den Charakter ein: Makros, Aktionsleisten-Slots, Tastenbelegung und Settings. Danach hält es alles automatisch aktuell, sobald du Zauber lernst oder Talente änderst.

- **Tasten gehen auf Leisten-Slots, nicht direkt auf Zauber.** Jede Taste zeigt deshalb auf ihrem Knopf Cooldown, Reichweite und ob die Fähigkeit gerade nutzbar ist.
- **Eine Taste = eine Rolle, in allen Haltungen.** Zauber, die in mehreren Haltungen gehen, liegen überall auf derselben Taste. Zauber, die nur in einer Haltung gehen, teilen sich eine Taste mit ihrem Gegenstück. Beispiel ⇧F: Shield Wall in Def, Retaliation in Battle, Recklessness in Berserker.
- **Falsche Haltung:** Drückst du eine Fähigkeit in der falschen Haltung, wechselt die Taste in die richtige. Tactical Mastery behält dabei 10 Rage, ein zweiter Druck löst die Fähigkeit aus.
- **Tank-Regel:** Keine Taste verlässt die Defensive Stance von selbst. Ausnahmen sind nur die bewusst gedrückten: Charge/Intercept, Berserker Rage und Pummel ohne Schild.
- **Unabhängig vom Umblättern der Leiste:** Blizzards automatisches Umblättern pro Haltung war in der Beta kaputt. Leiste 1 wird zusätzlich in die Haltungs-Seiten kopiert, die Belegung funktioniert also in beiden Fällen.
- **Prot- und Arms-Set:** Sobald du Mortal Strike kennst, ist Arms aktiv. Die Tasten bleiben gleich, nur die Inhalte wechseln. Festlegen lässt sich das per `/fsetup set prot|arms|auto`.
- **Höchster Rang:** Neu gelernte Ränge landen automatisch auf der Leiste.
- **Lokalisierungsfest** (Spell-IDs), **kampfsicher** (nichts im Kampf) und **idempotent** (mehrfaches Ausführen ändert nur Abweichungen).
- **Gamepad bleibt unangetastet:** Leiste 4 und höher und die Controller-Belegungen fasst das Addon nicht an.

Befehle: `/fsetup [all|macros|bars|binds|cvars|status|reset]` · `/fsetup set [prot|arms|auto]`

### Tastenbelegung (Maus/Tastatur). Q/E bleiben Seitwärtsschritte.

**Leiste 1: Rotation**

| Taste | Prot | Arms | Logik über die Haltungen |
|---|---|---|---|
| 1 | Heroic Strike | Heroic Strike | alle Haltungen |
| 2 | Sunder Armor | Sunder Armor | alle Haltungen |
| 3 | Revenge / Overpower | Revenge / Overpower | Def: Revenge · Battle: Overpower · Berserker: wechselt zu Battle |
| 4 | Shield Slam | Mortal Strike | alle Haltungen |
| 5 | Thunder Clap / Whirlwind | Thunder Clap / Whirlwind | Battle/Def: Thunder Clap · Berserker: Whirlwind |
| 6 | Shield Block | Slam | Shield Block nur in Def, sonst wechselt die Taste zu Def |
| R | Demoralizing Shout | Demoralizing Shout | alle Haltungen |
| T | Battle Shout | Battle Shout | alle Haltungen |
| F | Taunt / Mocking Blow | Taunt / Mocking Blow | Def: Taunt · Battle: Mocking Blow · Berserker: wechselt zu Def |
| G | Execute | Execute | Battle/Berserker; in Def nichts |
| V | Victory Rush | Victory Rush | alle Haltungen (neu in Forever) |
| C | Concussion Blow / Hamstring | Hamstring | Prot: Def Concussion Blow, sonst Hamstring · Arms: Hamstring, in Def nichts |

**Leiste 2: Utility, Haltungen, Cooldowns**

| Taste | Prot | Arms | Logik |
|---|---|---|---|
| Maus 4 | Shield Bash / Pummel | Shield Bash / Pummel | Mit Schild außerhalb Berserker: Shield Bash, sonst Pummel (wechselt zu Berserker) |
| Maus 5 | Charge / Intercept | Charge / Intercept | Außerhalb des Kampfes: Charge (mit Vanguard auch aus Def) · Im Kampf: Intercept über Berserker |
| X | Intimidating Shout | Intimidating Shout | alle Haltungen |
| Z | Challenging Shout | Challenging Shout | alle Haltungen |
| ⇧1 / ⇧2 / ⇧3 | Battle / Defensive / Berserker Stance | dto. | |
| ⇧R | Bloodrage | Bloodrage | alle Haltungen |
| ⇧F | Shield Wall / Retaliation / Recklessness | dto. | großer Cooldown der jeweiligen Haltung |
| ⇧G | Last Stand | Sweeping Strikes | Sweeping Strikes in Battle, wechselt nicht aus Def |
| ⇧T | Berserker Rage | Berserker Rage | wechselt zu Berserker (bewusster Fear-Break) |
| ⇧C | Disarm | Piercing Howl | Disarm in Def, sonst wechselt die Taste zu Def |

**Leiste 3: Extras**

| Taste | Prot | Arms |
|---|---|---|
| ⇧5 | Cleave | Cleave |
| ⇧V | Rend (in Berserker wechselt die Taste zu Battle) | Rend |
| ⇧4 | – | Spearing Strike (Battle) |

Alles Einstellbare steht in [`ForeverSetup/Config.lua`](ForeverSetup/Config.lua): Tasten, Slots, Makro-Logik und Settings.

## Addons

Das Ziel-Setup steht in der [CLAUDE.md](CLAUDE.md). Grundsätze: schlank, genau ein Pfeil (TomTom), Minimap-Icons gebündelt (MinimapButtonButton). Fünf Addons kommen von GitHub, der Rest über die CurseForge-App.

## Testplan (ab sofort, Charaktererstellung ist offen)

1. Client installieren und den echten Ordnernamen prüfen: Battle.net → Zahnrad → „Im Explorer anzeigen“. In der Beta hieß er `_classic_beta_`.
2. ForeverSetup per Junction nach `Interface\AddOns\` verlinken und Charakter erstellen.
3. Edit Mode: **Aktionsleisten 2 und 3 einblenden**, Einheitenfenster und Cooldown Manager einrichten, siehe [docs/ui-layout.md](docs/ui-layout.md).
4. `/fsetup status` aufrufen. Prüfen, ob Zauber per Fallback-Namen aufgelöst wurden, vor allem die Victory-Rush-ID.
5. Am Trainingsdummy jede Taste in allen drei Haltungen testen. Prüfen, ob Blizzard die Leiste pro Haltung umblättert (falls ja, ist das egal).
6. Ausloggen und wieder einloggen. Prüfen, ob die Server-Synchronisierung Leisten oder Tasten überschreibt.
7. Controller: Gamepad UI aktivieren und ein eigenes Edit-Mode-Layout anlegen. Prüfen, welche Slots die Controller-Leisten nutzen. Kollisionen mit Leiste 1–3 notieren.
8. Sunshine-Stream starten und beenden. Danach prüfen, ob das UI im Controller-Modus hängen bleibt.

## Offene Punkte

- **Gamepad-Belegung:** Die Tastenvergabe am Controller wird nach dem Test festgelegt, Grundlage sind die 4 Sets à 8 Tasten der nativen Gamepad UI.
- **Haltungs-Anforderungen in Forever:** Ungeprüft ist, ob Thunder Clap und Shield Bash in Battle und Def gehen, Hamstring und Execute in Battle und Berserker, und ob Shield Wall, Retaliation und Recklessness sich einen Cooldown teilen. Die Werte stammen aus Classic beziehungsweise Beta-Guides.
- **Berufe:** Wann der Wechsel von Schmieden zu Ingenieur kommt, ist noch offen.
- **Dual-Spec:** Status beobachten.
- **Arms-PvP-Build:** Bisher gibt es nur einen Theorycraft-Build, er wird nach dem Launch validiert.

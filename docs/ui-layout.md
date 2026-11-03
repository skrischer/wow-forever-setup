# UI-Layout: Einheitenfenster in der Mitte und Cooldown-Anzeige

Das ist einmalig Handarbeit, etwa 10 Minuten. ForeverSetup schreibt die Edit-Mode-Layouts **nicht** selbst: Die zuständige Funktion `C_EditMode.SaveLayouts` ist in Forever nur für Blizzards eigenen Code („untainted“) erlaubt. Wenn ein Addon sie aufruft, drohen „Aktion blockiert“-Fehler.

Danach exportierst du das Layout als Text und legst es im Repo unter `ui/` ab. Für Twinks oder nach einem Reset reicht dann ein Import.

## Zielbild (Maus/Tastatur-Layout)

```
┌─────────────────────────────────────────────────────────────┐
│ Minimap/Buffs oben rechts, Chat unten links (Standard)       │
│                                                             │
│                         [ Spielfigur ]                       │
│                                                             │
│      [ Spieler ]   [Buffs: Block · Ruf · Wut ]   [ Ziel ]    │
│      [ Zauberl. ]  [ CDs: Slam·Rache·TC·Block ]  [ Ziel-    │
│                    [ Utility: Wall·LS·Ruf ]       zauberl. ] │
│                                                             │
│       [ Leiste 2: X Z M4 M5 ⇧1 ⇧2 ⇧3 ⇧R ⇧F ⇧G ⇧T ⇧C ]       │
│       [ Leiste 1: 1 2 3 4 5 6 R T F G V C ]  [ Leiste 3 ]   │
└─────────────────────────────────────────────────────────────┘
```

Die Einheitenfenster liegen also **unter der Spielfigur**, links und rechts. Dazwischen sitzt die Cooldown-Anzeige. Dein Blick bleibt so in der Mitte, und über der Figur bleibt Platz für Nameplates und Boss-Effekte.

## 1 · Edit Mode einrichten

Esc → Edit Mode (deutsch: „Bearbeitungsmodus“):

1. Neues Layout anlegen: **„Basti MKB“**, Typ Maus/Tastatur. Raster an, „An Elementen ausrichten“ an.
2. **Aktionsleiste 2 und 3 einblenden.** Das ist Pflicht, denn ForeverSetup belegt deren Slots:
   - **Leiste 2** (unten links) direkt über Leiste 1, 12 Knöpfe.
   - **Leiste 3** (unten rechts) rechts neben Leiste 1. Davon sind nur 3 Knöpfe belegt (⇧5, ⇧V, ⇧4), du kannst sie auf 3–6 Knöpfe verkleinern.
   - Leiste 4 und höher bleiben aus, die sind für den Controller reserviert.
3. **Spielerfenster:** ziehen nach Mitte, unterhalb der Figur, links. Etwa 6–8 Rasterkästchen links der Bildschirmmitte und 4–5 unter der Figur.
4. **Zielfenster:** spiegelbildlich rechts, auf gleicher Höhe.
   - Option „Zauberleiste unter dem Fenster“ an. Damit siehst du Zauber, die du unterbrechen kannst, direkt am Ziel.
   - „Ziel des Ziels“ an. Als Tank siehst du daran, wen dein Gegner gerade angreift.
5. **Spieler-Zauberleiste** (relevant für Slam als Arms): direkt unter das Spielerfenster.
6. **Fokusfenster** aus oder in eine Ecke, du brauchst es kaum.
7. Speichern, dann **Teilen → Exportieren**. Den Text bitte in `ui/editmode-mkb.txt` ablegen oder an Claude Code geben.

Für den **Controller** legst du ein eigenes Layout **„Basti Gamepad“** an. Edit Mode speichert die Layouts pro Eingabetyp getrennt. Die Fenster dort höher und etwas weiter auseinander platzieren, denn am Fernseher ist der Rand weiter weg.

## 2 · Zusätzliche Cooldown-Anzeige: Blizzards Cooldown Manager

Einstellungen → Gameplay-Verbesserungen → **Cooldown Manager aktivieren**. Ein Addon brauchst du dafür nicht, und WeakAuras läuft in Forever ohnehin nicht.

Der Cooldown Manager hat vier Bereiche. Alle lassen sich im Edit Mode frei verschieben, und welche Zauber wohin kommen, wählst du in den erweiterten Cooldown-Einstellungen per Drag & Drop. Die Bedienung ist aus Retail übernommen und in Forever noch nicht verifiziert.

| Bereich | Position | Prot | Arms |
|---|---|---|---|
| **Essential** (große Icons) | Mitte zwischen den Einheitenfenstern | Shield Slam, Revenge, Shield Block, Thunder Clap, Shield Bash, Taunt, Victory Rush | Mortal Strike, Overpower, Slam, Whirlwind, Pummel, Victory Rush, Spearing Strike |
| **Utility** (kleine Icons) | direkt darunter | Shield Wall, Last Stand, Bloodrage, Berserker Rage, Intimidating Shout, Challenging Shout, Disarm, Concussion Blow, Charge/Intercept | Retaliation, Recklessness, Sweeping Strikes, Bloodrage, Berserker Rage, Intimidating Shout, Charge/Intercept |
| **Tracked Buffs** (Icons) | über der Essential-Reihe | Shield Block, Last Stand, Shield Wall, Bloodrage, Battle Shout | Sweeping Strikes, Recklessness, Retaliation, Enrage, Battle Shout |
| **Tracked Bars** | aus oder neben dem Spielerfenster | – | optional: Recklessness/Retaliation als Leiste |

Nach dem Einrichten **exportieren** und unter `ui/cooldown-manager.txt` ablegen, falls Forever den Export anbietet (in Retail gibt es ihn, in Forever ist er unbestätigt).

## 3 · Debuffs am Ziel: Plater

Sunder-Stapel, Demoralizing Shout, Thunder Clap, Rend und Hamstring auf dem Gegner zeigt **Plater** direkt über dem Kopf des Gegners an, inklusive Threat-Farbe. Das ist für einen Tank übersichtlicher als am Zielfenster. Die Einrichtung folgt in Phase 3 (Addon-Konfiguration).

## Hinweise

- **Haltungen und Leisten:** ForeverSetup verlässt sich nicht auf Blizzards automatisches Umblättern der Leiste pro Haltung, das in der Beta seit dem 16.10. kaputt war. Die Belegung funktioniert in beiden Fällen.
- **Belegte Slots:** Wenn du einen von ForeverSetup belegten Slot von Hand änderst, setzt das nächste Lernen eines Zaubers ihn zurück. Eigenes gehört auf freie Slots.

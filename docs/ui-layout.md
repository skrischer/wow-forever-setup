# UI-Layout: alles Wichtige in der Mitte

Das ist einmalig Handarbeit, etwa 15 Minuten. ForeverSetup schreibt die Edit-Mode-Layouts **nicht** selbst: Die zuständige Funktion `C_EditMode.SaveLayouts` ist in Forever nur für Blizzards eigenen Code („untainted“) erlaubt. Wenn ein Addon sie aufruft, drohen „Aktion blockiert“-Fehler.

Danach exportierst du das Layout als Text und legst es im Repo unter `ui/` ab. Für Twinks oder nach einem Reset reicht dann ein Import.

**Grundsatz:** Kampfanzeigen kommen von Blizzard selbst, nicht von Addons. Seit der Midnight-API sehen Addons im Kampf zum Beispiel keine Debuffs auf deinem Ziel mehr, Blizzards eigene Anzeigen schon. Swing-Timer, Cooldown Manager, Ressourcen-Leiste und Nameplates sind eingebaut.

## Zielbild (Maus/Tastatur-Layout)

```
┌───────────────────────────────────────────────────────────────┐
│                                              Buffs   (Minimap) │
│                     [Nameplate: Aggro, Debuffs]                │
│                [ Du ]         [ Gegner ]                Quests │
│            [ Leben + Rage ]                                    │
│            [ Swing-Timer  ]          [Ziel-Debuffs]            │
│  [ Spieler ]  [ Buffs ]              [ Ziel ] [ZdZ]            │
│  [Zauberl.]   [ CDs: Slam·Rache·TC… ] [Ziel-Zauberl.]           │
│               [ Utility: Wall·LS… ]                            │
│ Chat     [ Leiste 2: X Y M4 M5 ⇧1 ⇧2 ⇧3 ⇧R ⇧F ⇧G ⇧T ⇧C ]         │
│          [ Leiste 1: 1 2 3 4 5 6 Q E R T F G ] [ Leiste 3 ] Menü │
└───────────────────────────────────────────────────────────────┘
```

## 1 · Eingebaute Anzeigen einschalten

Esc → Optionen. Die Namen sind aus Retail und Beta-Berichten übernommen, in Forever können sie leicht anders lauten:

| Option | Wo | Wozu |
|---|---|---|
| **Cooldown Manager** | Gameplay-Verbesserungen | Buffs, Cooldowns, Ziel-Debuffs, Sound-Alarme. Standardmäßig aus |
| **Swing-Timer** | Erweiterte Optionen | Zeigt, wann dein nächster Schlag kommt. Heroic Strike kurz davor drücken |
| **Personal Resource Display** (Ressourcen-Leiste) | Kampf | Leben und Rage direkt unter der Figur |
| **Ziel des Ziels** | Kampf | Wen dein Gegner angreift. Standardmäßig aus |
| **Damage-Meter** | Steuerung bzw. Erweitert | Bei Bedarf |
| **Nameplates: Gegner, Aggro-Farben, Debuffs, Zauberleisten** | Nameplates | Ersetzt Plater |

Danach Claude Code Bescheid geben. Es liest die internen Namen der Einstellungen aus der Konfiguration ab, und ForeverSetup setzt sie künftig für Twinks automatisch.

## 2 · Edit Mode einrichten

Esc → Edit Mode (deutsch: „Bearbeitungsmodus“):

1. Neues Layout **„Basti MKB“** anlegen, Typ Maus/Tastatur. Raster an, „An Elementen ausrichten“ an.
2. **Aktionsleisten 2 und 3 einblenden.** Das ist Pflicht, denn ForeverSetup belegt deren Slots:
   - **Leiste 2** (unten links) direkt über Leiste 1.
   - **Leiste 3** (unten rechts) rechts neben Leiste 1, voll belegt mit 12 Knöpfen für Extras und Verbrauchsgüter.
   - Leiste 4 und höher bleiben aus, die sind für den Controller reserviert.
3. **Ressourcen-Leiste** (Leben + Rage): direkt unter die Figur.
4. **Swing-Timer:** direkt unter die Ressourcen-Leiste.
5. **Spielerfenster:** unter der Figur, links. Etwa 6–8 Rasterkästchen links der Mitte.
6. **Zielfenster:** spiegelbildlich rechts, mit Zauberleiste darunter und Ziel des Ziels daneben.
7. **Spieler-Zauberleiste:** unter das Spielerfenster. Wichtig für Slam als Arms.
8. **Cooldown Manager:** die Reihen zwischen die beiden Fenster, die Ziel-Debuffs über das Zielfenster (siehe unten).
9. Speichern, dann **Teilen → Exportieren**. Den Text in `ui/editmode-mkb.txt` ablegen oder Claude Code geben.

Für den **Controller** legst du ein eigenes Layout **„Basti Gamepad“** an. Edit Mode speichert die Layouts pro Eingabetyp getrennt. Die Fenster dort höher und weiter auseinander, denn am Fernseher ist der Rand weiter weg.

## 3 · Cooldown Manager belegen

Welche Zauber wohin kommen, wählst du in den erweiterten Cooldown-Einstellungen per Drag & Drop. Für jede Spec gibt es ein eigenes Profil.

| Bereich | Position | Prot | Arms |
|---|---|---|---|
| **Buffs** | über der Cooldown-Reihe | Shield Block, Last Stand, Shield Wall, Bloodrage, Battle Shout | Sweeping Strikes, Recklessness, Retaliation, Enrage, Battle Shout |
| **Essential** (große Icons) | Mitte zwischen den Fenstern | Shield Slam, Revenge, Shield Block, Thunder Clap, Shield Bash, Taunt, Victory Rush | Mortal Strike, Overpower, Slam, Whirlwind, Pummel, Victory Rush, Spearing Strike |
| **Utility** (kleine Icons) | darunter | Shield Wall, Last Stand, Bloodrage, Berserker Rage, Intimidating Shout, Challenging Shout, Disarm, Concussion Blow, Charge/Intercept | Retaliation, Recklessness, Sweeping Strikes, Bloodrage, Berserker Rage, Intimidating Shout, Charge/Intercept |
| **Ziel-Debuffs** | über dem Zielfenster | Sunder Armor (Stapel), Demoralizing Shout, Thunder Clap, Rend | Rend, Hamstring, Mortal Strike, Sunder Armor |
| **Sound-Alarme** | – | Shield Wall und Last Stand wieder bereit | Recklessness und Sweeping Strikes wieder bereit |

Nach dem Einrichten **exportieren** und unter `ui/cooldown-manager-prot.txt` bzw. `-arms.txt` ablegen, falls Forever den Export anbietet. In Retail gibt es ihn, in Forever ist er unbestätigt.

⚠️ Im Beta-Build vom 24.9. konnte der Cooldown Manager **keine Zauber-Ränge** auseinanderhalten, das war für später angekündigt. Am Launch-Abend prüfen.

## Hinweise

- **Haltungen und Leisten:** ForeverSetup verlässt sich nicht auf Blizzards automatisches Umblättern der Leiste pro Haltung, das in der Beta seit dem 16.10. kaputt war. Die Belegung funktioniert in beiden Fällen.
- **Belegte Slots:** Wenn du einen von ForeverSetup belegten Slot von Hand änderst, setzt die nächste Aktualisierung ihn zurück, also beim Lernen eines Zaubers oder bei Änderungen in den Taschen. Eigenes gehört auf Leiste 4 und höher.

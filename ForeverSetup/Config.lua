-- ForeverSetup – Config (v0.3)
-- Everything you might want to change lives in this file.
--
-- Design:
--  * Keys are bound to ACTION BAR SLOTS (not directly to spells), so every key
--    shows cooldown, range and usability on its button.
--  * One key = one role. Spells usable in several stances sit on the same key in
--    every stance. Stance-only spells share a key with their counterpart in the
--    other stances (e.g. Shield Wall / Retaliation / Recklessness), via macros.
--  * Does NOT rely on Blizzard's stance bar paging (broken in the Forever beta
--    since Oct 16). Bar-1 contents are additionally copied into the stance pages
--    (slots 73-108), so it also works if Blizzard fixes paging.
--  * Two sets: "prot" (default) and "arms" (auto when Mortal Strike is known).
--    Keys stay identical; only contents change.
--
-- Spell names are resolved at runtime from spell IDs (works on deDE and enUS).

local ADDON, FS = ...

---------------------------------------------------------------------------
-- Spells: key = { spellID, "English fallback", "German fallback" }
-- IDs: Classic / Forever beta data. Victory Rush ID unverified for Forever.
---------------------------------------------------------------------------
FS.Spells = {
  BattleStance      = { 2457,    "Battle Stance" },
  DefensiveStance   = { 71,      "Defensive Stance" },
  BerserkerStance   = { 2458,    "Berserker Stance" },

  HeroicStrike      = { 78,      "Heroic Strike" },
  Cleave            = { 845,     "Cleave" },
  SunderArmor       = { 7386,    "Sunder Armor" },
  Revenge           = { 6572,    "Revenge" },
  Overpower         = { 7384,    "Overpower" },
  ShieldSlam        = { 23922,   "Shield Slam" },
  MortalStrike      = { 12294,   "Mortal Strike" },
  ThunderClap       = { 6343,    "Thunder Clap" },
  Whirlwind         = { 1680,    "Whirlwind" },
  ShieldBlock       = { 2565,    "Shield Block" },
  Slam              = { 1464,    "Slam" },
  Execute           = { 5308,    "Execute" },
  Rend              = { 772,     "Rend" },
  Hamstring         = { 1715,    "Hamstring" },
  ConcussionBlow    = { 12809,   "Concussion Blow" },
  PiercingHowl      = { 12323,   "Piercing Howl" },
  VictoryRush       = { 34428,   "Victory Rush", "Siegesrausch" },
  SpearingStrike    = { 1310222, "Spearing Strike" },
  SweepingStrikes   = { 12292,   "Sweeping Strikes" },

  Charge            = { 100,     "Charge" },
  Intercept         = { 20252,   "Intercept" },
  ShieldBash        = { 72,      "Shield Bash" },
  Pummel            = { 6552,    "Pummel" },
  Taunt             = { 355,     "Taunt" },
  MockingBlow       = { 694,     "Mocking Blow" },
  Disarm            = { 676,     "Disarm" },

  BattleShout       = { 6673,    "Battle Shout" },
  DemoShout         = { 1160,    "Demoralizing Shout" },
  IntimidatingShout = { 5246,    "Intimidating Shout" },
  ChallengingShout  = { 1161,    "Challenging Shout" },

  Bloodrage         = { 2687,    "Bloodrage" },
  BerserkerRage     = { 18499,   "Berserker Rage" },
  ShieldWall        = { 871,     "Shield Wall" },
  Retaliation       = { 20230,   "Retaliation" },
  Recklessness      = { 1719,    "Recklessness" },
  LastStand         = { 12975,   "Last Stand" },
}

-- Talents that change macro logic / set selection (IsPlayerSpell).
FS.Talents = {
  Vanguard     = 1310317, -- Prot: Charge usable in Defensive Stance
  MortalStrike = 12294,   -- known -> "arms" set
}

---------------------------------------------------------------------------
-- Macros. Stances: 1 = Battle, 2 = Defensive, 3 = Berserker.
-- body = string, or function(ctx) -> string. ctx: { set = "prot"|"arms", vanguard = bool }
-- {Token} -> localized spell name; {Shields} -> localized "Shields" item subclass.
-- Pressing a stance-only ability in the wrong stance switches to the right stance
-- (Tactical Mastery keeps 10 rage); press again to use it.
-- Tank rule: keys never leave Defensive Stance by themselves, EXCEPT the deliberate
-- ones: Charge/Intercept (Mouse 5), Berserker Rage (Shift-T), Pummel without shield.
-- Keep the total <= 18 (classic per-character macro limit).
---------------------------------------------------------------------------
FS.Macros = {
  ["FS Strike"]  = "#showtooltip\n/startattack\n/cast {HeroicStrike}",
  ["FS VRush"]   = "#showtooltip {VictoryRush}\n/startattack\n/cast {VictoryRush}",

  -- 3: reactive hit (Revenge in Def, Overpower in Battle; Berserker -> Battle)
  ["FS Reakt"]   = "#showtooltip\n/startattack\n/cast [stance:2] {Revenge}; [stance:1] {Overpower}; {BattleStance}",
  -- 5: AoE (Thunder Clap in Battle/Def, Whirlwind in Berserker)
  ["FS AoE"]     = "#showtooltip\n/startattack\n/cast [stance:3] {Whirlwind}; {ThunderClap}",
  -- 6 (prot): Shield Block, otherwise -> Defensive Stance
  ["FS Block"]   = "#showtooltip {ShieldBlock}\n/cast [stance:2] {ShieldBlock}; {DefensiveStance}",
  -- F: Taunt in Def, Mocking Blow in Battle, Berserker -> Def
  ["FS Taunt"]   = "#showtooltip\n/cast [stance:2] {Taunt}; [stance:1] {MockingBlow}; {DefensiveStance}",
  -- G: Execute in Battle/Berserker. In Def: nothing (never leave Def by accident).
  ["FS Exec"]    = "#showtooltip {Execute}\n/startattack\n/cast [nostance:2] {Execute}",
  -- C: control. Prot: Concussion Blow in Def, Hamstring otherwise. Arms: Hamstring (not in Def)
  ["FS Control"] = function(ctx)
      if ctx.set == "arms" then
        return "#showtooltip {Hamstring}\n/cast [nostance:2] {Hamstring}"
      end
      return "#showtooltip\n/cast [stance:2] {ConcussionBlow}; {Hamstring}"
    end,
  -- Mouse 4: interrupt. Shield Bash (Battle/Def with shield), else Pummel (Berserker)
  ["FS Kick"]    = "#showtooltip\n/cast [equipped:{Shields},nostance:3] {ShieldBash}; [stance:3] {Pummel}; {BerserkerStance}",
  -- Mouse 5: gap closer. Out of combat Charge (Vanguard: also from Def), in combat Intercept
  ["FS Charge"]  = function(ctx)
      local cs = ctx.vanguard and "stance:1/2" or "stance:1"
      return "#showtooltip\n/cast [nocombat," .. cs .. "] {Charge}; [nocombat] {BattleStance}; [stance:3] {Intercept}; {BerserkerStance}"
    end,
  -- Shift-F: the big defensive/offensive cooldown of each stance
  ["FS BigCD"]   = "#showtooltip\n/cast [stance:2] {ShieldWall}; [stance:1] {Retaliation}; {Recklessness}",
  -- Shift-T: Berserker Rage (fear break)
  ["FS BRage"]   = "#showtooltip {BerserkerRage}\n/cast [stance:3] {BerserkerRage}; {BerserkerStance}",
  -- Shift-C: Prot: Disarm (Def). Arms: Piercing Howl is a plain spell, see layout.
  ["FS Disarm"]  = "#showtooltip {Disarm}\n/cast [stance:2] {Disarm}; {DefensiveStance}",
  -- Shift-V: Rend (Battle/Def; Berserker -> Battle)
  ["FS Rend"]    = "#showtooltip {Rend}\n/startattack\n/cast [stance:3] {BattleStance}; {Rend}",
  -- Arms
  ["FS Spear"]   = "#showtooltip {SpearingStrike}\n/startattack\n/cast [stance:1] {SpearingStrike}; [nostance:2] {BattleStance}",
  ["FS Sweep"]   = "#showtooltip {SweepingStrikes}\n/cast [stance:1] {SweepingStrikes}; [nostance:2] {BattleStance}",
}

-- A macro only goes onto the bar once at least one of these spells is known.
-- Until then its slot stays empty (the key binding is already in place) and is
-- filled automatically when you learn the spell.
FS.MacroRequires = {
  ["FS Strike"]  = { "HeroicStrike" },
  ["FS VRush"]   = { "VictoryRush" },
  ["FS Reakt"]   = { "Revenge", "Overpower" },
  ["FS AoE"]     = { "ThunderClap", "Whirlwind" },
  ["FS Block"]   = { "ShieldBlock" },
  ["FS Taunt"]   = { "Taunt", "MockingBlow" },
  ["FS Exec"]    = { "Execute" },
  ["FS Control"] = { "ConcussionBlow", "Hamstring" },
  ["FS Kick"]    = { "ShieldBash", "Pummel" },
  ["FS Charge"]  = { "Charge", "Intercept" },
  ["FS BigCD"]   = { "ShieldWall", "Retaliation", "Recklessness" },
  ["FS BRage"]   = { "BerserkerRage" },
  ["FS Disarm"]  = { "Disarm" },
  ["FS Rend"]    = { "Rend" },
  ["FS Spear"]   = { "SpearingStrike" },
  ["FS Sweep"]   = { "SweepingStrikes" },
}

-- Macros from v0.1 that no longer exist (deleted on upgrade).
FS.ObsoleteMacros = { "FS Interrupt", "FS Overpower" }

---------------------------------------------------------------------------
-- Layout. Each entry: key, bar slot, and content per set ("S:Spell" or "M:Macro").
-- A single "all" applies to both sets. nil = slot left empty in that set.
-- Bar 1 = slots 1-12 (ACTIONBUTTON1-12), Bar 2 = 61-72 (bottom left),
-- Bar 3 = 49-60 (bottom right). Bars 4+ stay free for the gamepad UI.
-- Movement: A/D strafe (see FS.MovementBinds), turning with the right mouse button.
---------------------------------------------------------------------------
FS.Layout = {
  -- Bar 1: rotation, closest keys around WASD (all stances)
  { key = "1", slot = 1,  all = "M:FS Strike" },
  { key = "2", slot = 2,  all = "S:SunderArmor" },
  { key = "3", slot = 3,  all = "M:FS AoE" },
  { key = "4", slot = 4,  prot = "M:FS Block",    arms = "S:Slam" },
  { key = "5", slot = 5,  all = "S:Cleave" },
  { key = "6", slot = 6,  all = "M:FS Rend" },
  { key = "Q", slot = 7,  all = "M:FS Reakt" },
  { key = "E", slot = 8,  prot = "S:ShieldSlam",  arms = "S:MortalStrike" },
  { key = "R", slot = 9,  all = "S:DemoShout" },
  { key = "T", slot = 10, all = "S:BattleShout" },
  { key = "F", slot = 11, all = "M:FS Taunt" },
  { key = "G", slot = 12, all = "M:FS Exec" },

  -- Bar 2: utility, stances, cooldowns
  { key = "X",       slot = 61, all = "S:IntimidatingShout" },
  { key = "Z",       slot = 62, all = "S:ChallengingShout" },
  { key = "BUTTON4", slot = 63, all = "M:FS Kick" },
  { key = "BUTTON5", slot = 64, all = "M:FS Charge" },
  { key = "SHIFT-1", slot = 65, all = "S:BattleStance" },
  { key = "SHIFT-2", slot = 66, all = "S:DefensiveStance" },
  { key = "SHIFT-3", slot = 67, all = "S:BerserkerStance" },
  { key = "SHIFT-R", slot = 68, all = "S:Bloodrage" },
  { key = "SHIFT-F", slot = 69, all = "M:FS BigCD" },
  { key = "SHIFT-G", slot = 70, prot = "S:LastStand",  arms = "M:FS Sweep" },
  { key = "SHIFT-T", slot = 71, all = "M:FS BRage" },
  { key = "SHIFT-C", slot = 72, prot = "M:FS Disarm",  arms = "S:PiercingHowl" },

  -- Bar 3: extras
  { key = "V",       slot = 49, all = "M:FS VRush" },
  { key = "C",       slot = 50, all = "M:FS Control" },
  { key = "SHIFT-Q", slot = 51, prot = nil,            arms = "M:FS Spear" },
}

-- Copy bar-1 slots into the warrior stance pages (Battle 73-84, Def 85-96,
-- Berserker 97-108) so the layout survives whether stance paging works or not.
FS.StancePageOffsets = { 72, 84, 96 }

-- Keys that earlier versions bound directly; cleared if still ours (and not re-used above).
FS.LegacyKeys = { ["SHIFT-E"] = false, ["SHIFT-5"] = false, ["SHIFT-V"] = false, ["SHIFT-4"] = false }

-- Movement: A/D strafe instead of turning.
FS.MovementBinds = { A = "STRAFELEFT", D = "STRAFERIGHT" }

---------------------------------------------------------------------------
-- Settings (CVars). Unknown ones are skipped and reported.
-- Cooldown Manager / damage meter / Edit Mode: see docs/ui-layout.md (manual, once).
---------------------------------------------------------------------------
FS.CVars = {
  { "autoLootDefault",             "1" },
  { "cameraDistanceMaxZoomFactor", "2.6" },
  { "nameplateShowEnemies",        "1" },
  { "nameplateShowAll",            "1" },
  { "lootUnderMouse",              "0" },
  { "showTutorials",               "0" },
}

-- ForeverSetup – Config
-- Everything you might want to change lives in this file.
-- Spell names are resolved at runtime from spell IDs, so macros work on
-- German (deDE) and English clients alike. The English name is only a fallback.

local ADDON, FS = ...

---------------------------------------------------------------------------
-- Spells: key = { spellID, "English fallback name" }
-- IDs taken from Classic / Forever beta data (forever.warcraftdb.com).
-- Victory Rush is new in Forever; its ID is unconfirmed -> name fallback.
---------------------------------------------------------------------------
FS.Spells = {
  BattleStance     = { 2457,    "Battle Stance" },
  DefensiveStance  = { 71,      "Defensive Stance" },
  BerserkerStance  = { 2458,    "Berserker Stance" },

  Charge           = { 100,     "Charge" },
  Intercept        = { 20252,   "Intercept" },
  Overpower        = { 7384,    "Overpower" },
  ShieldBash       = { 72,      "Shield Bash" },
  Pummel           = { 6552,    "Pummel" },
  BerserkerRage    = { 18499,   "Berserker Rage" },
  Taunt            = { 355,     "Taunt" },
  MockingBlow      = { 694,     "Mocking Blow" },
  HeroicStrike     = { 78,      "Heroic Strike" },
  Cleave           = { 845,     "Cleave" },
  VictoryRush      = { 34428,   "Victory Rush", "Siegesrausch" }, -- ID unverified for Forever; 3rd = deDE fallback
  SpearingStrike   = { 1310222, "Spearing Strike" },

  Revenge          = { 6572,    "Revenge" },
  SunderArmor      = { 7386,    "Sunder Armor" },
  ShieldBlock      = { 2565,    "Shield Block" },
  ThunderClap      = { 6343,    "Thunder Clap" },
  ShieldSlam       = { 23922,   "Shield Slam" },
  DemoShout        = { 1160,    "Demoralizing Shout" },
  BattleShout      = { 6673,    "Battle Shout" },
  Bloodrage        = { 2687,    "Bloodrage" },
  ShieldWall       = { 871,     "Shield Wall" },
  LastStand        = { 12975,   "Last Stand" },
  Execute          = { 5308,    "Execute" },
}

-- Talents that change macro logic (detected with IsPlayerSpell).
FS.Talents = {
  Vanguard = 1310317, -- Prot: Charge usable in Defensive Stance
}

---------------------------------------------------------------------------
-- Macros (per character). Bodies are functions so they can react to talents.
-- {Token} is replaced with the localized spell name; {Shields} with the
-- localized item subclass used by [equipped:...].
-- Stances: 1 = Battle, 2 = Defensive, 3 = Berserker.
---------------------------------------------------------------------------
FS.Macros = {
  { name = "FS Charge", body = function(ctx)
      local chargeStances = ctx.vanguard and "stance:1/2" or "stance:1"
      return "#showtooltip\n/cast [nocombat," .. chargeStances .. "] {Charge}; [nocombat] {BattleStance}; [stance:3] {Intercept}; {BerserkerStance}"
    end },
  { name = "FS Interrupt", body = function()
      return "#showtooltip\n/cast [equipped:{Shields},nostance:3] {ShieldBash}; [stance:3] {Pummel}; {BerserkerStance}"
    end },
  { name = "FS Overpower", body = function()
      return "#showtooltip {Overpower}\n/cast [stance:1] {Overpower}; {BattleStance}"
    end },
  { name = "FS BRage", body = function()
      return "#showtooltip {BerserkerRage}\n/cast [stance:3] {BerserkerRage}; {BerserkerStance}"
    end },
  { name = "FS Taunt", body = function()
      return "#showtooltip\n/cast [stance:2] {Taunt}; [stance:1] {MockingBlow}; {DefensiveStance}"
    end },
  { name = "FS Strike", body = function()
      return "#showtooltip\n/startattack\n/cast [mod:shift] {Cleave}; {HeroicStrike}"
    end },
  { name = "FS VRush", body = function()
      return "#showtooltip {VictoryRush}\n/startattack\n/cast {VictoryRush}"
    end },
  { name = "FS Spear", body = function()
      return "#showtooltip {SpearingStrike}\n/cast [stance:1] {SpearingStrike}; {BattleStance}"
    end },
}

---------------------------------------------------------------------------
-- Keyboard + mouse bindings. type = "macro" (macro name) or "spell" (key in FS.Spells).
-- NOTE: Q/E replace the default strafe keys. Change here if you strafe with Q/E.
-- Gamepad bindings are NOT touched (native Gamepad UI + Easy Controller handle those).
---------------------------------------------------------------------------
FS.Keybinds = {
  { key = "1",       type = "macro", ref = "FS Strike" },
  { key = "2",       type = "spell", ref = "Revenge" },
  { key = "3",       type = "spell", ref = "SunderArmor" },
  { key = "4",       type = "spell", ref = "ShieldBlock" },
  { key = "5",       type = "spell", ref = "ThunderClap" },
  { key = "Q",       type = "spell", ref = "ShieldSlam" },
  { key = "E",       type = "macro", ref = "FS VRush" },
  { key = "R",       type = "spell", ref = "DemoShout" },
  { key = "F",       type = "macro", ref = "FS Taunt" },
  { key = "G",       type = "spell", ref = "BattleShout" },
  { key = "SHIFT-1", type = "spell", ref = "BattleStance" },
  { key = "SHIFT-2", type = "spell", ref = "DefensiveStance" },
  { key = "SHIFT-3", type = "spell", ref = "BerserkerStance" },
  { key = "SHIFT-Q", type = "spell", ref = "Bloodrage" },
  { key = "SHIFT-E", type = "macro", ref = "FS Overpower" },
  { key = "SHIFT-R", type = "macro", ref = "FS BRage" },
  { key = "SHIFT-F", type = "spell", ref = "ShieldWall" },
  { key = "SHIFT-G", type = "spell", ref = "LastStand" },
  { key = "BUTTON4", type = "macro", ref = "FS Interrupt" },
  { key = "BUTTON5", type = "macro", ref = "FS Charge" },
}

---------------------------------------------------------------------------
-- Settings (CVars). Only well-known CVars; unknown ones are skipped and reported.
-- Cooldown Manager / damage meter: enable once in Options > Gameplay Enhancements
-- (their CVar names in Forever are unconfirmed).
---------------------------------------------------------------------------
FS.CVars = {
  { "autoLootDefault",             "1" },
  { "cameraDistanceMaxZoomFactor", "2.6" },
  { "nameplateShowEnemies",        "1" },
  { "nameplateShowAll",            "1" },
  { "lootUnderMouse",              "0" },
  { "showTutorials",               "0" },
}

-- ForeverSetup – Core (v0.3)
-- Idempotent: running again only changes what differs. Never acts in combat;
-- queued work runs once combat ends.

local ADDON, FS = ...
local PREFIX = "|cff4fa3ffForeverSetup|r: "
local BIND_SET_CHARACTER = 2

local function Print(msg) print(PREFIX .. msg) end

---------------------------------------------------------------------------
-- Compatibility helpers (Midnight-era API with classic fallbacks)
---------------------------------------------------------------------------
local function try(fn, ...)
  if not fn then return nil end
  local ok, a, b, c, d, e, f, g = pcall(fn, ...)
  if ok then return a, b, c, d, e, f, g end
end

local function SpellNameByID(id)
  return try(C_Spell and C_Spell.GetSpellName, id) or try(GetSpellInfo, id)
end

-- Highest known rank of a spell, looked up by name (ranks share the name).
local function KnownSpellID(name, baseID)
  local id
  local info = try(C_Spell and C_Spell.GetSpellInfo, name)
  if type(info) == "table" then id = info.spellID end
  if not id then id = select(7, try(GetSpellInfo, name)) end
  id = id or baseID
  if id and try(IsPlayerSpell, id) then return id end
  if baseID and try(IsPlayerSpell, baseID) then return baseID end
  return nil
end

local function ShieldsSubclassName()
  return try(C_Item and C_Item.GetItemSubClassInfo, 4, 6)
      or try(GetItemSubClassInfo, 4, 6) or "Shields"
end

local function HasSpell(id) return try(IsPlayerSpell, id) and true or false end

local PickupSpellFn = (C_Spell and C_Spell.PickupSpell) or PickupSpell

---------------------------------------------------------------------------
-- Name resolution
---------------------------------------------------------------------------
local names, missing = {}, {}

local function ResolveNames()
  wipe(names); wipe(missing)
  local locale = (GetLocale and GetLocale()) or "enUS"
  for key, def in pairs(FS.Spells) do
    local name = SpellNameByID(def[1])
    if not name then
      name = (locale == "deDE" and def[3]) or def[2]
      missing[#missing + 1] = key
    end
    names[key] = name
  end
  table.sort(missing)
  names.Shields = ShieldsSubclassName()
end

local function Fill(template)
  return (template:gsub("{(%w+)}", function(token)
    return names[token] or ("{" .. token .. "}")
  end))
end

---------------------------------------------------------------------------
-- Context: which set, which talents
---------------------------------------------------------------------------
local function BuildContext()
  local db = ForeverSetupDB or {}
  local set = db.set
  if set ~= "prot" and set ~= "arms" then
    set = HasSpell(FS.Talents.MortalStrike) and "arms" or "prot"
  end
  return { set = set, vanguard = HasSpell(FS.Talents.Vanguard), forced = (db.set == "prot" or db.set == "arms") }
end

---------------------------------------------------------------------------
-- Macros
---------------------------------------------------------------------------
local function SortedMacroNames()
  local list = {}
  for name in pairs(FS.Macros) do list[#list + 1] = name end
  table.sort(list)
  return list
end

local function ApplyMacros(ctx)
  local created, updated, unchanged, failed = 0, 0, 0, 0
  for _, old in ipairs(FS.ObsoleteMacros or {}) do
    local idx = GetMacroIndexByName(old)
    if idx and idx > 0 then try(DeleteMacro, idx) end
  end
  for _, name in ipairs(SortedMacroNames()) do
    local def = FS.Macros[name]
    local body = Fill(type(def) == "function" and def(ctx) or def)
    if #body > 255 then
      Print(("Makro '%s' ist %d Zeichen lang (max 255) – übersprungen."):format(name, #body))
      failed = failed + 1
    else
      local idx = GetMacroIndexByName(name)
      if idx and idx > 0 then
        local _, _, current = try(GetMacroInfo, idx)
        if current == body then
          unchanged = unchanged + 1
        else
          EditMacro(idx, name, "INV_Misc_QuestionMark", body)
          updated = updated + 1
        end
      else
        -- per-character first, account-wide as fallback (macro limits)
        local ok = pcall(CreateMacro, name, "INV_Misc_QuestionMark", body, true)
        if not ok or (GetMacroIndexByName(name) or 0) == 0 then
          ok = pcall(CreateMacro, name, "INV_Misc_QuestionMark", body, false)
        end
        if ok and (GetMacroIndexByName(name) or 0) > 0 then created = created + 1 else failed = failed + 1 end
      end
    end
  end
  return created, updated, unchanged, failed
end

---------------------------------------------------------------------------
-- Action bars
---------------------------------------------------------------------------
local function Desired(content)
  if not content then return nil end
  local kind, ref = content:match("^(%a):(.+)$")
  if kind == "S" then
    local def = FS.Spells[ref]
    local id = def and KnownSpellID(names[ref], def[1])
    return id and "spell" or nil, id
  elseif kind == "M" then
    local req = FS.MacroRequires and FS.MacroRequires[ref]
    if req then
      local any = false
      for _, key in ipairs(req) do
        local def = FS.Spells[key]
        if def and KnownSpellID(names[key], def[1]) then any = true break end
      end
      if not any then return nil end
    end
    local idx = GetMacroIndexByName(ref)
    return (idx and idx > 0) and "macro" or nil, idx
  end
end

local function PlaceSlot(slot, content)
  local wantType, wantID = Desired(content)
  local curType, curID = try(GetActionInfo, slot)
  if wantType == curType and wantID == curID then return "same" end
  ClearCursor()
  if try(HasAction, slot) then
    PickupAction(slot)
    ClearCursor()
  end
  if not wantType then return "cleared" end
  if wantType == "spell" then PickupSpellFn(wantID) else PickupMacro(wantID) end
  PlaceAction(slot)
  ClearCursor()
  return "placed"
end

local function SlotsFor(entry)
  local slots = { entry.slot }
  if entry.slot <= 12 then
    for _, offset in ipairs(FS.StancePageOffsets or {}) do slots[#slots + 1] = offset + entry.slot end
  end
  return slots
end

local function ContentFor(entry, ctx)
  if entry.all then return entry.all end
  return entry[ctx.set]
end

local function ApplyBars(ctx)
  local placed, cleared, pendingLearn = 0, 0, 0
  for _, entry in ipairs(FS.Layout) do
    local content = ContentFor(entry, ctx)
    for _, slot in ipairs(SlotsFor(entry)) do
      local r = PlaceSlot(slot, content)
      if r == "placed" then placed = placed + 1 end
      if r == "cleared" then
        cleared = cleared + 1
        if content and slot == entry.slot then pendingLearn = pendingLearn + 1 end
      end
    end
  end
  return placed, cleared, pendingLearn
end

---------------------------------------------------------------------------
-- Key bindings (keys -> action bar buttons)
---------------------------------------------------------------------------
local function BindingCommandForSlot(slot)
  if slot >= 1 and slot <= 12 then return "ACTIONBUTTON" .. slot end
  if slot >= 61 and slot <= 72 then return "MULTIACTIONBAR1BUTTON" .. (slot - 60) end -- bottom left
  if slot >= 49 and slot <= 60 then return "MULTIACTIONBAR2BUTTON" .. (slot - 48) end -- bottom right
  if slot >= 25 and slot <= 36 then return "MULTIACTIONBAR3BUTTON" .. (slot - 24) end -- right
  if slot >= 37 and slot <= 48 then return "MULTIACTIONBAR4BUTTON" .. (slot - 36) end -- right 2
end

local function ApplyBinds()
  local ok, fail = 0, {}
  for key, default in pairs(FS.LegacyKeys or {}) do
    local action = try(GetBindingAction, key) or ""
    if action:find("^SPELL ") or action:find("^MACRO FS ")
       or action:find("^ACTIONBUTTON") or action:find("^MULTIACTIONBAR[12]BUTTON") then
      SetBinding(key, default or nil)
    end
  end
  for key, cmd in pairs(FS.MovementBinds or {}) do
    if SetBinding(key, cmd) then ok = ok + 1 else fail[#fail + 1] = key end
  end
  for _, entry in ipairs(FS.Layout) do
    local cmd = BindingCommandForSlot(entry.slot)
    if cmd and SetBinding(entry.key, cmd) then ok = ok + 1 else fail[#fail + 1] = entry.key end
  end
  SaveBindings(BIND_SET_CHARACTER)
  return ok, fail
end

---------------------------------------------------------------------------
-- CVars
---------------------------------------------------------------------------
local function ApplyCVars()
  local count, skipped = 0, {}
  local setter = (C_CVar and C_CVar.SetCVar) or SetCVar
  for _, cv in ipairs(FS.CVars) do
    local ok, result = pcall(setter, cv[1], cv[2])
    if ok and result ~= false then count = count + 1 else skipped[#skipped + 1] = cv[1] end
  end
  return count, skipped
end

---------------------------------------------------------------------------
-- Orchestration with combat safety
---------------------------------------------------------------------------
local pending = {}
local frame = CreateFrame("Frame")
local lastSet

local function Run(steps, quiet)
  if InCombatLockdown() then
    for k in pairs(steps) do pending[k] = true end
    if not quiet then Print("Im Kampf – wird nach dem Kampf ausgeführt.") end
    return
  end
  ResolveNames()
  local ctx = BuildContext()
  local lines = {}

  if steps.macros then
    local c, u, s, f = ApplyMacros(ctx)
    if not quiet or c + u + f > 0 then
      lines[#lines + 1] = ("Makros: %d neu, %d geändert, %d unverändert%s"):format(
        c, u, s, f > 0 and (", " .. f .. " fehlgeschlagen") or "")
    end
  end
  if steps.bars then
    local p, cl, pl = ApplyBars(ctx)
    if not quiet or p > 0 then
      lines[#lines + 1] = ("Leisten: %d Slots gesetzt%s"):format(p,
        pl > 0 and (", " .. pl .. " warten auf noch nicht gelernte Fähigkeiten") or "")
    end
  end
  if steps.binds then
    local ok, fail = ApplyBinds()
    lines[#lines + 1] = ("Tasten: %d gesetzt%s"):format(ok,
      #fail > 0 and (", fehlgeschlagen: " .. table.concat(fail, ", ")) or "")
  end
  if steps.cvars then
    local n, skipped = ApplyCVars()
    lines[#lines + 1] = ("Settings: %d gesetzt%s"):format(n,
      #skipped > 0 and (", übersprungen: " .. table.concat(skipped, ", ")) or "")
  end

  if lastSet and lastSet ~= ctx.set then
    lines[#lines + 1] = ("Set gewechselt: %s → %s"):format(lastSet, ctx.set)
  end
  lastSet = ctx.set

  for _, l in ipairs(lines) do Print(l) end
  if not quiet and #missing > 0 then
    Print("Namen per Fallback (ID unbekannt): " .. table.concat(missing, ", "))
  end
end

local ALL = { macros = true, bars = true, binds = true, cvars = true }
local REFRESH = { macros = true, bars = true }

-- Spells learned / talents changed: refresh macros + bars, debounced, quiet.
local refreshQueued = false
local function QueueRefresh()
  if refreshQueued or not (ForeverSetupDB and ForeverSetupDB.done) then return end
  refreshQueued = true
  C_Timer.After(1.5, function()
    refreshQueued = false
    Run(REFRESH, true)
  end)
end

frame:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_ENTERING_WORLD" then
    frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    ForeverSetupDB = ForeverSetupDB or {}
    C_Timer.After(3, function()
      if (ForeverSetupDB.version or 0) < 3 then
        Run(ALL)
        ForeverSetupDB.done = true
        ForeverSetupDB.version = 3
        Print("Einrichtung v0.3 abgeschlossen. /fsetup für Optionen.")
      else
        Run(REFRESH, true)
      end
    end)
  elseif event == "PLAYER_REGEN_ENABLED" then
    if next(pending) then
      local steps = pending; pending = {}
      Run(steps, true)
    end
  else
    QueueRefresh()
  end
end)

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
for _, ev in ipairs({ "CHARACTER_POINTS_CHANGED", "PLAYER_TALENT_UPDATE", "SPELLS_CHANGED",
                      "LEARNED_SPELL_IN_TAB", "LEARNED_SPELL_IN_SKILL_LINE" }) do
  pcall(frame.RegisterEvent, frame, ev)
end

---------------------------------------------------------------------------
-- Slash command
---------------------------------------------------------------------------
SLASH_FOREVERSETUP1 = "/fsetup"
SlashCmdList.FOREVERSETUP = function(msg)
  local cmd, arg = (msg or ""):lower():match("^%s*(%S*)%s*(%S*)")
  if cmd == "" or cmd == "all" then
    Run(ALL)
  elseif cmd == "macros" or cmd == "bars" or cmd == "binds" or cmd == "cvars" then
    Run({ [cmd] = true })
  elseif cmd == "set" and (arg == "prot" or arg == "arms" or arg == "auto") then
    ForeverSetupDB = ForeverSetupDB or {}
    ForeverSetupDB.set = (arg ~= "auto") and arg or nil
    Run(REFRESH)
  elseif cmd == "status" then
    ResolveNames()
    local ctx = BuildContext()
    Print(("Set: %s%s | Vanguard: %s | Schild-Typ: %s | Version: %s"):format(
      ctx.set, ctx.forced and " (fest)" or " (auto)", ctx.vanguard and "ja" or "nein",
      names.Shields, tostring(ForeverSetupDB and ForeverSetupDB.version or 0)))
    if #missing > 0 then Print("Fallback-Namen: " .. table.concat(missing, ", ")) end
  elseif cmd == "reset" then
    ForeverSetupDB = {}
    Print("Zurückgesetzt – beim nächsten Login wird alles neu angewendet.")
  else
    Print("/fsetup [all|macros|bars|binds|cvars|status|reset] · /fsetup set [prot|arms|auto]")
  end
end

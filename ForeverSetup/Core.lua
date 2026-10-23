-- ForeverSetup – Core
-- Idempotent: running it again updates existing macros/binds instead of duplicating.
-- Never touches anything in combat; queued work runs once combat ends.

local ADDON, FS = ...
local PREFIX = "|cff4fa3ffForeverSetup|r: "
local BIND_SET_CHARACTER = 2

local function Print(msg) print(PREFIX .. msg) end

---------------------------------------------------------------------------
-- Compatibility helpers (Midnight-era API with classic fallbacks)
---------------------------------------------------------------------------
local function SpellNameByID(id)
  if C_Spell and C_Spell.GetSpellName then
    local ok, name = pcall(C_Spell.GetSpellName, id)
    if ok and name then return name end
  end
  if GetSpellInfo then
    local ok, name = pcall(GetSpellInfo, id)
    if ok and name then return name end
  end
end

local function ShieldsSubclassName()
  if C_Item and C_Item.GetItemSubClassInfo then
    local ok, name = pcall(C_Item.GetItemSubClassInfo, 4, 6) -- Armor / Shields
    if ok and name then return name end
  end
  if GetItemSubClassInfo then
    local ok, name = pcall(GetItemSubClassInfo, 4, 6)
    if ok and name then return name end
  end
  return "Shields"
end

local function HasTalent(spellID)
  if IsPlayerSpell then
    local ok, known = pcall(IsPlayerSpell, spellID)
    return ok and known or false
  end
  return false
end

---------------------------------------------------------------------------
-- Name resolution
---------------------------------------------------------------------------
local names, missing = {}, {}

local function ResolveNames()
  wipe(names); wipe(missing)
  for key, def in pairs(FS.Spells) do
    local name = SpellNameByID(def[1])
    if not name then
      local locale = GetLocale and GetLocale() or "enUS"
      name = (locale == "deDE" and def[3]) or def[2]
      missing[#missing + 1] = key
    end
    names[key] = name
  end
  names.Shields = ShieldsSubclassName()
end

local function Fill(template)
  return (template:gsub("{(%w+)}", function(token)
    return names[token] or ("{" .. token .. "}")
  end))
end

---------------------------------------------------------------------------
-- Steps
---------------------------------------------------------------------------
local function ApplyMacros()
  local ctx = { vanguard = HasTalent(FS.Talents.Vanguard) }
  local created, updated, failed = 0, 0, 0
  for _, m in ipairs(FS.Macros) do
    local body = Fill(m.body(ctx))
    if #body > 255 then
      Print(("Makro '%s' ist %d Zeichen lang (max 255) – übersprungen."):format(m.name, #body))
      failed = failed + 1
    else
      local index = GetMacroIndexByName(m.name)
      if index and index > 0 then
        EditMacro(index, m.name, "INV_Misc_QuestionMark", body)
        updated = updated + 1
      else
        local ok = pcall(CreateMacro, m.name, "INV_Misc_QuestionMark", body, true)
        if ok then created = created + 1 else failed = failed + 1 end
      end
    end
  end
  Print(("Makros: %d neu, %d aktualisiert, %d fehlgeschlagen. Vanguard: %s"):format(
    created, updated, failed, ctx.vanguard and "ja" or "nein"))
end

local function ApplyBinds()
  local count = 0
  for _, b in ipairs(FS.Keybinds) do
    local ok
    if b.type == "macro" then
      ok = SetBindingMacro(b.key, b.ref)
    elseif b.type == "spell" then
      ok = SetBindingSpell(b.key, names[b.ref] or b.ref)
    end
    if ok then count = count + 1 else Print("Binding fehlgeschlagen: " .. b.key .. " → " .. b.ref) end
  end
  SaveBindings(BIND_SET_CHARACTER)
  Print(("Tastenbelegung: %d/%d gesetzt (charakterspezifisch)."):format(count, #FS.Keybinds))
end

local function ApplyCVars()
  local count, skipped = 0, {}
  for _, cv in ipairs(FS.CVars) do
    local setter = (C_CVar and C_CVar.SetCVar) or SetCVar
    local ok, result = pcall(setter, cv[1], cv[2])
    if ok and result ~= false then count = count + 1 else skipped[#skipped + 1] = cv[1] end
  end
  Print(("Settings: %d gesetzt%s"):format(count,
    #skipped > 0 and (", übersprungen: " .. table.concat(skipped, ", ")) or "."))
end

---------------------------------------------------------------------------
-- Orchestration with combat safety
---------------------------------------------------------------------------
local pending = {}
local frame = CreateFrame("Frame")

local function Run(steps)
  if InCombatLockdown() then
    for k in pairs(steps) do pending[k] = true end
    Print("Im Kampf – wird nach dem Kampf ausgeführt.")
    return
  end
  ResolveNames()
  if steps.macros then ApplyMacros() end
  if steps.binds then ApplyBinds() end
  if steps.cvars then ApplyCVars() end
  if #missing > 0 then
    Print("Namen per Fallback (ID unbekannt): " .. table.concat(missing, ", "))
  end
end

local ALL = { macros = true, binds = true, cvars = true }

-- Talent/spell changes: refresh macros only, debounced.
local refreshQueued = false
local function QueueMacroRefresh()
  if refreshQueued or not (ForeverSetupDB and ForeverSetupDB.done) then return end
  refreshQueued = true
  C_Timer.After(1.5, function()
    refreshQueued = false
    Run({ macros = true })
  end)
end

local function SafeRegister(event)
  pcall(frame.RegisterEvent, frame, event)
end

frame:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_ENTERING_WORLD" then
    frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    ForeverSetupDB = ForeverSetupDB or {}
    if not ForeverSetupDB.done then
      C_Timer.After(3, function()
        Run(ALL)
        ForeverSetupDB.done = true
        Print("Ersteinrichtung abgeschlossen. /fsetup für Optionen.")
      end)
    end
  elseif event == "PLAYER_REGEN_ENABLED" then
    if next(pending) then
      local steps = pending; pending = {}
      Run(steps)
    end
  else
    QueueMacroRefresh()
  end
end)

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
SafeRegister("CHARACTER_POINTS_CHANGED")
SafeRegister("PLAYER_TALENT_UPDATE")
SafeRegister("LEARNED_SPELL_IN_TAB")

---------------------------------------------------------------------------
-- Slash command
---------------------------------------------------------------------------
SLASH_FOREVERSETUP1 = "/fsetup"
SlashCmdList.FOREVERSETUP = function(msg)
  msg = (msg or ""):lower():match("^%s*(%S*)")
  if msg == "" or msg == "all" then
    Run(ALL)
  elseif msg == "macros" or msg == "binds" or msg == "cvars" then
    Run({ [msg] = true })
  elseif msg == "status" then
    ResolveNames()
    Print(("Vanguard: %s | Schild-Typ: %s | Erstlauf: %s"):format(
      HasTalent(FS.Talents.Vanguard) and "ja" or "nein", names.Shields,
      (ForeverSetupDB and ForeverSetupDB.done) and "erledigt" or "offen"))
    if #missing > 0 then Print("Fallback-Namen: " .. table.concat(missing, ", ")) end
  elseif msg == "reset" then
    ForeverSetupDB = { done = false }
    Print("Erstlauf zurückgesetzt – beim nächsten Login wird alles neu angewendet.")
  else
    Print("/fsetup [all|macros|binds|cvars|status|reset]")
  end
end

"""ForeverSetup against a mocked German (deDE) WoW client.

Scenario: level-12 prot -> learns more spells -> loots consumables, equips trinkets,
gets a mount -> uses up potions -> respecs to arms -> forced back to prot.
Checks: stance pages mirror bar 1, macro length <= 255, per-character macro limit,
key bindings (QWERTZ, A/D strafe, legacy cleanup), item slots fill and empty.

Usage:  pip install lupa   then   python tests/mock_client_test.py [path/to/ForeverSetup]
Exit code 1 if any check fails. This is a mock: it proves the logic, not the real client.
"""
import os
import sys
from lupa import LuaRuntime

ADDON_DIR = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "ForeverSetup")
lua = LuaRuntime(unpack_returned_tuples=True)

lua.execute(r'''
DE = {
 [2457]="Kampfhaltung",[71]="Verteidigungshaltung",[2458]="Berserkerhaltung",
 [78]="Heldenhafter Stoß",[845]="Spalten",[7386]="Rüstung zerreißen",[6572]="Rache",
 [7384]="Überwältigen",[23922]="Schildschlag",[12294]="Tödlicher Stoß",[6343]="Donnerknall",
 [1680]="Wirbelwind",[2565]="Schildblock",[1464]="Zerschmettern",[5308]="Hinrichten",
 [772]="Verwunden",[1715]="Kniesehne",[12809]="Erschütternder Schlag",[12323]="Durchdringendes Heulen",
 [1310222]="Speerstoß",[12292]="Weitreichende Stöße",[100]="Sturmangriff",[20252]="Abfangen",
 [72]="Schildhieb",[6552]="Zuschlagen",[355]="Spott",[694]="Spöttischer Schlag",[676]="Entwaffnen",
 [6673]="Schlachtruf",[1160]="Demoralisierender Ruf",[5246]="Drohruf",[1161]="Herausforderungsruf",
 [2687]="Blutrausch",[18499]="Berserkerwut",[871]="Schildwall",[20230]="Gegenschlag",
 [1719]="Tollkühnheit",[12975]="Letztes Gefecht",
}
BYNAME = {} for id,n in pairs(DE) do BYNAME[n]=id end
KNOWN = {}
function know(...) for _,id in ipairs({...}) do KNOWN[id]=true end end
function GetLocale() return "deDE" end
C_Spell = {
  GetSpellName = function(id) return DE[id] end,
  GetSpellInfo = function(n) local id = BYNAME[n]; if id then return {spellID=id} end end,
  PickupSpell = function(id) CURSOR = {"spell", id} end,
}
C_Item = { GetItemSubClassInfo = function() return "Schilde" end }
function IsPlayerSpell(id) return KNOWN[id] or false end
function wipe(t) for k in pairs(t) do t[k]=nil end return t end
function InCombatLockdown() return false end
C_Timer = { After = function(_, fn) fn() end }
MACROS, SLOTS, BINDS, CVARS, OUT = {}, {}, {}, {}, {}
CURSOR = nil
function GetMacroIndexByName(n) for i,m in ipairs(MACROS) do if m.name==n then return i end end return 0 end
function GetMacroInfo(i) local m=MACROS[i]; if m then return m.name, "icon", m.body end end
function CreateMacro(n,i,b,pc)
  local c = 0 for _,m in ipairs(MACROS) do if m.pc == (pc and true or false) then c = c + 1 end end
  if pc and c >= 18 then error("char limit") end
  if not pc and c >= 120 then error("account limit") end
  MACROS[#MACROS+1]={name=n,body=b,pc=pc and true or false} return #MACROS end
function EditMacro(idx,n,i,b) MACROS[idx].body=b end
function DeleteMacro(idx) table.remove(MACROS, idx) end
function GetActionInfo(s) local a=SLOTS[s]; if a then return a[1], a[2] end end
function HasAction(s) return SLOTS[s] ~= nil end
function PickupAction(s) CURSOR = SLOTS[s]; SLOTS[s] = nil end
function PickupMacro(idx) CURSOR = {"macro", idx} end
function PlaceAction(s) SLOTS[s] = CURSOR; CURSOR = nil end
function ClearCursor() CURSOR = nil end
function SetBinding(k, cmd) BINDS[k]=cmd return true end
function GetBindingAction(k) return BINDS[k] or "" end
function SaveBindings() end
C_CVar = { SetCVar = function(k,v) CVARS[k]=v return true end }
function print(s) OUT[#OUT+1]=s end
SlashCmdList = {}
function CreateFrame()
  local f = {}
  function f:RegisterEvent() end
  function f:UnregisterEvent() end
  function f:SetScript(_, fn) self.handler=fn end
  FRAME = f
  return f
end
-- items / bags / gear / mounts
BAG = {}           -- itemID -> count
FOODLVL = { [4599]=25, [159]=1, [8952]=45 }   -- 159 = water (also Food & Drink)
function UnitLevel() return 30 end
C_Item = {
  GetItemSubClassInfo = function() return "Schilde" end,
  GetItemCount = function(id) return BAG[id] or 0 end,
  GetItemInfoInstant = function(id) if FOODLVL[id] then return id,"","","","",0,5 end return id,"","","","",0,1 end,
  GetItemInfo = function(id) return "x","l",1,1,FOODLVL[id] or 1 end,
  GetItemSpell = function(id) if id == 7777 then return "Use", 1 end end,
  PickupItem = function(id) CURSOR = {"item", id} end,
}
C_Container = {
  GetContainerNumSlots = function(b) return b == 0 and 16 or 0 end,
  GetContainerItemInfo = function(b, s) local i=0 for id in pairs(BAG) do i=i+1 if i==s then return {itemID=id} end end end,
}
EQUIP = { [13] = 7777, [14] = 8888 }   -- trinket 1 on-use, trinket 2 passive
function GetInventoryItemID(_, slot) return EQUIP[slot] end
MOUNTS = false
C_MountJournal = {
  GetMountIDs = function() return {1} end,
  GetMountInfoByID = function() return "Pferd",1,1,false,true,0,false,false,7,false,MOUNTS end,
}
-- leftovers from v0.1 to clean up
MACROS[1] = {name="FS Interrupt", body="old"}
MACROS[2] = {name="FS Overpower", body="old"}
BINDS["Q"] = "STRAFELEFT"; BINDS["E"] = "STRAFERIGHT"; BINDS["A"] = "TURNLEFT"; BINDS["D"] = "TURNRIGHT"
BINDS["Z"] = "MULTIACTIONBAR1BUTTON2"
''')

def load(path):
    with open(path, encoding="utf-8") as fh:
        return fh.read()

ns = lua.table()
loader = lua.eval("function(src, name, ns) local fn = assert(load(src, '@'..name)); return fn('ForeverSetup', ns) end")
for f in ("Config.lua", "Core.lua"):
    loader(load(f"{ADDON_DIR}/{f}"), f, ns)
g = lua.globals()

def slot_label(slot):
    a = g.SLOTS[slot]
    if a is None:
        return "—"
    if a[1] == "spell":
        return g.DE[a[2]]
    if a[1] == "item":
        return f"Item {a[2]}"
    return "M:" + g.MACROS[a[2]].name

def dump_bars(title):
    print(f"\n=== {title}")
    for e in ns.Layout.values():
        print(f"  {e.key:8} slot {e.slot:3}  {slot_label(e.slot)}")

def chat():
    for s in list(g.OUT.values()):
        print("  chat:", s.replace("|cff4fa3ffForeverSetup|r: ", ""))
    lua.execute("OUT = {}")

errors = []

# Level ~12 prot: basics only
lua.execute("know(2457,71,78,7386,6572,6343,772,1715,100,72,6673,1160,2687,355)")
lua.execute("FRAME.handler(FRAME, 'PLAYER_ENTERING_WORLD')")
chat()
dump_bars("Level ~12, prot")

# stance pages mirror bar 1
for s in range(1, 13):
    for off in (72, 84, 96):
        if lua.eval(f"(function() local a,b=SLOTS[{s}],SLOTS[{s+off}]; if a==nil and b==nil then return true end; if a==nil or b==nil then return false end; return a[1]==b[1] and a[2]==b[2] end)()") is False:
            errors.append(f"stance page mismatch slot {s}+{off}")

# learn more (prot 40ish) -> refresh via event
lua.execute("know(23922,2565,5308,12809,1161,5246,871,12975,18499,2458,20252,6552,1680,1719,20230,694,676,845)")
lua.execute("FRAME.handler(FRAME, 'LEARNED_SPELL_IN_TAB')")
chat()
dump_bars("Prot, mehr gelernt")

# loot items, equip, mount
lua.execute("BAG[858]=3; BAG[929]=2; BAG[3530]=5; BAG[4599]=4; BAG[159]=10; BAG[8952]=1; BAG[2863]=2; BAG[6948]=1; MOUNTS=true")
lua.execute("FRAME.handler(FRAME, 'BAG_UPDATE_DELAYED')")
chat()
dump_bars("Mit Gegenständen")
for slot, want in ((52,"FS Potion"),(56,"FS Bandage"),(57,"FS Mount"),(58,"FS Food"),(59,"FS Stone"),(53,"FS Trinket1")):
    if slot_label(slot) != "M:"+want: errors.append(f"slot {slot} expected {want}, got {slot_label(slot)}")
for slot in (54, 55):
    if slot_label(slot) != "—": errors.append(f"slot {slot} should be empty")
if lua.eval("SLOTS[60] and SLOTS[60][2]") != 6948: errors.append("hearthstone missing")
body = lambda n: lua.eval(f"MACROS[GetMacroIndexByName('{n}')].body")
if "item:929" not in body("FS Potion"): errors.append("potion not best rank")
if "item:4599" not in body("FS Food"): errors.append("food not best level-appropriate: "+body("FS Food"))
# use up potions -> slot empties
lua.execute("BAG[929]=nil; BAG[858]=nil")
lua.execute("FRAME.handler(FRAME, 'BAG_UPDATE_DELAYED')")
chat()
if slot_label(52) != "—": errors.append("potion slot should be empty when none left")

# respec arms
lua.execute("KNOWN[23922]=nil; KNOWN[12809]=nil; KNOWN[12975]=nil; know(12294,12292,1464,12323,1310222)")
lua.execute("FRAME.handler(FRAME, 'CHARACTER_POINTS_CHANGED')")
chat()
dump_bars("Arms")

# forced prot override
lua.execute("SlashCmdList.FOREVERSETUP('set prot')")
chat()
print("forced prot slot4:", slot_label(4))

print("\n=== Macros (%d)" % len(g.MACROS))
for m in g.MACROS.values():
    n = len(m.body.encode("utf-8"))
    if n > 255: errors.append(f"{m.name} too long")
    print(f"[{m.name}] {n}B\n{m.body}\n")
pc = sum(1 for m in g.MACROS.values() if m.pc)
print("per-character:", pc, "account:", len(g.MACROS) - pc)
if pc > 18: errors.append("char macro limit")
for old in ("FS Interrupt", "FS Overpower"):
    if lua.eval(f"GetMacroIndexByName('{old}')") > 0: errors.append(f"obsolete {old} kept")

print("=== Bindings")
for k, v in sorted(g.BINDS.items()):
    print(f"  {k:8} {v}")
if g.BINDS["A"] != "STRAFELEFT" or g.BINDS["D"] != "STRAFERIGHT": errors.append("A/D not strafe")
if g.BINDS["Q"] != "ACTIONBUTTON7" or g.BINDS["E"] != "ACTIONBUTTON8": errors.append("Q/E not bound")
if lua.eval("BINDS['Z']") not in (None, ""): errors.append("Z not cleared")
if g.BINDS["Y"] != "MULTIACTIONBAR1BUTTON2": errors.append("Y not challenging shout")
keys = [e.key for e in ns.Layout.values()]
if len(keys) != len(set(keys)): errors.append("duplicate keys")
slots = [e.slot for e in ns.Layout.values()]
if len(slots) != len(set(slots)): errors.append("duplicate slots")

print("\nERRORS:", errors or "none")
sys.exit(1 if errors else 0)

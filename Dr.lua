local TEST_MODE = true;

local RESET = 18.5;
local DURATIONS = { 1.0, 0.5, 0.25 };

local CATEGORY_ROOT = 1;
local CATEGORY_STUN = 2;
local CATEGORY_INCAPACITATE = 3;
local CATEGORY_DISORIENT = 4;
local CATEGORY_SILENCE = 5;

-- iterator support (category ids must be continous)
local MIN_CATEGORY = CATEGORY_ROOT;
local MAX_CATEGORY = CATEGORY_SILENCE;

-- description
local CATEGORY = {};
CATEGORY[CATEGORY_ROOT] = "root";
CATEGORY[CATEGORY_STUN] = "stun";
CATEGORY[CATEGORY_INCAPACITATE] = "incapacitate";
CATEGORY[CATEGORY_DISORIENT] = "disorient";
CATEGORY[CATEGORY_SILENCE] = "silence";

-- DrUnit
local DrUnit;
do
	-- imports
	local kCore = kCore;

	-- private
	local GetInfo = function(self, category, create)
		local info = self.store[category];

		if (info == nil) then
			if (not create) then
				return nil;
			end

			info = {
				category = category,
				index = 1,
				coeff = DURATIONS[1],
				updated = 0,
				expires = 0
			};

			self.store[category] = info;
		else
			if (info.updated + RESET < GetTime()) then
				info.index = 1;
				info.coeff = DURATIONS[1];
				info.updated = 0;
				info.expires = 0;
			end
		end

		return info;
	end

	-- public
	local Activate = function(self, category, icon)
		assert(type(category) == "number", "Category must be a number");

		local info = GetInfo(self, category, true);
		info.index = info.index + 1;
		info.coeff = DURATIONS[info.index] or 0;
		info.updated = GetTime();
		info.expires = info.updated + RESET;
		info.icon = icon;

		return info.coeff, info.expires, RESET, info.icon;
	end

	local Get = function(self, category)
		assert(type(category) == "number", "Category must be a number");

		local info = GetInfo(self, category, false);
		if (info ~= nil and info.coeff ~= DURATIONS[1]) then
			return info.coeff, info.expires, RESET, info.icon;
		else
			return nil;
		end
	end

	-- ctor
	local ctor = function(self, baseCtor, guid)
		assert(type(guid) == "string", "Guid must be a string");

		self.guid = guid;
		self.store = {};
	end

	-- main
	DrUnit = kCore.CreateClass(ctor, {
		Activate = Activate,
		Get = Get
	}, nil);

end

-- kDr
do
	-- imports
	local kCore = kCore;

	local COMBATLOG_OBJECT_TYPE_PLAYER = COMBATLOG_OBJECT_TYPE_PLAYER;
	local COMBATLOG_OBJECT_CONTROL_PLAYER = COMBATLOG_OBJECT_CONTROL_PLAYER;

	-- private
	local auras = {};
	local store = {};

	local GetInfo = function(guid, create)
		
		local info = store[guid];

		if (info == nil) then
			if (not create) then
				return nil;
			end

			info = DrUnit(guid);
			store[guid] = info;
		end

		return info;

	end
	 
	local AuraFaded = function(aura, unitGuid, unitName)
		local info = GetInfo(unitGuid, true);

		local nextCoeff, expires = info:Activate(aura.category, aura.icon);

		if (TEST_MODE) then
			print(unitName .. " " .. CATEGORY[aura.category] .. " coeff=" .. nextCoeff .. " expires=" .. expires);
		end
	end

	local IteratorInternal = function(guid, category)

		for category = category + 1, MAX_CATEGORY, 1 do
			local coeff, expires, duration, icon = kDr.Get(guid, category);

			if (coeff ~= nil) then
				return category, coeff, expires, duration, icon;
			end
		end

		return nil;
	end

	-- events
	kEvents.RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(_, timeStamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)

		if (event ~= "SPELL_AURA_REFRESH" and event ~= "SPELL_AURA_REMOVED") then
			return;
		end

		local isPlayer = bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) == COMBATLOG_OBJECT_TYPE_PLAYER or
			bit.band(destFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) == COMBATLOG_OBJECT_CONTROL_PLAYER;
			
		if (not isPlayer) then
			return;
		end

		local spellId, spellName, spellSchool, auraType, amount = ...;
		
		if (auraType == "DEBUFF") then
			local info = auras[spellId];

			if (info) then
				AuraFaded(info, destGUID, destName);
			end
		end

	end);

	-- public
	local RegisterAura = function(category, id)
		assert(type(category) == "number", "Category must be a number");
		assert(type(id) == "number", "Handler must be a number");

		local name, rank, icon, _, _, _, _ = GetSpellInfo(id);

		auras[id] = {
			id = id,
			name = name,
			icon = icon,
			category = category
		};
	end

	local Get = function(guid, category)
		assert(type(guid) == "string", "Guid must be a string");
		assert(type(category) == "number", "Guid must be a number");

		local info = GetInfo(guid, true);
		if (not info) then
			return nil;
		else
			return info:Get(category);
		end
	end

	local Iterator = function(guid)
		return IteratorInternal, guid, MIN_CATEGORY - 1;
	end

	local Test = function(unit)

		unit = unit or "player";

		local aura;
		for _, v in pairs(auras) do
			aura = v;
			break;
		end

		AuraFaded(aura, UnitGUID(unit), UnitName(unit));

	end

	-- class
	kDr = {
		CATEGORY_ROOT = CATEGORY_ROOT,
		CATEGORY_STUN = CATEGORY_STUN,
		CATEGORY_INCAPACITATE = CATEGORY_INCAPACITATE,
		CATEGORY_DISORIENT = CATEGORY_DISORIENT,
		CATEGORY_SILENCE = CATEGORY_SILENCE,

		RegisterAura = RegisterAura,
		Get = Get,

		Iterator = Iterator,

		Test = Test
	};
end

-- data import
do
	--[[ INCAPACITATES ]]--
	-- Druid
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 99); -- Incapacitating Roar (talent)
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 203126); -- Maim (with blood trauma pvp talent)
	-- Hunter
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 3355); -- Freezing Trap
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 19386); -- Wyvern Sting
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 209790); -- Freezing Arrow
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 213691); -- Scatter Shot
	-- Mage
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 118); -- Polymorph
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 28272); -- Polymorph (pig)
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 28271); -- Polymorph (turtle)
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 61305); -- Polymorph (black cat)
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 61721); -- Polymorph (rabbit)
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 61780); -- Polymorph (turkey)
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 126819); -- Polymorph (procupine)
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 161353); -- Polymorph (bear cub)
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 161354); -- Polymorph (monkey)
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 161355); -- Polymorph (penguin)
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 161372); -- Polymorph (peacock)
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 82691); -- Ring of Frost
	-- Monk
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 115078); -- Paralysis
	-- Paladin
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 20066); -- Repentance
	-- Priest
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 605); -- Mind Control
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 9484); -- Shackle Undead
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 64044); -- Psychic Horror (Horror effect)
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 88625); -- Holy Word: Chastise
	-- Rogue
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 1776); -- Gouge
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 6770); -- Sap
	-- Shaman
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 51514); -- Hex
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 211004); -- Hex (spider)
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 210873); -- Hex (raptor)
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 211015); -- Hex (cockroach)
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 211010); -- Hex (snake)
	-- Warlock
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 710); -- Banish
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 6789); -- Mortal Coil
	-- Pandaren
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 107079); -- Quaking Palm
	
	--[[ SILENCES ]]--
	-- Death Knight
	kDr.RegisterAura(kDr.CATEGORY_SILENCE, 47476); -- Strangulate
	-- Demon Hunter
	kDr.RegisterAura(kDr.CATEGORY_SILENCE, 204490); -- Sigil of Silence
	-- Druid
	-- Hunter
	kDr.RegisterAura(kDr.CATEGORY_SILENCE, 202933); -- Spider Sting (pvp talent)
	-- Mage
	-- Paladin
	kDr.RegisterAura(kDr.CATEGORY_SILENCE, 31935); -- Avenger's Shield
	-- Priest
	kDr.RegisterAura(kDr.CATEGORY_SILENCE, 15487); -- Silence
	kDr.RegisterAura(kDr.CATEGORY_SILENCE, 199683); -- Last Word (SW: Death silence)
	-- Rogue
	kDr.RegisterAura(kDr.CATEGORY_SILENCE, 1330); -- Garrote
	-- Blood Elf
	kDr.RegisterAura(kDr.CATEGORY_SILENCE, 25046); -- Arcane Torrent (Energy version)
	kDr.RegisterAura(kDr.CATEGORY_SILENCE, 28730); -- Arcane Torrent (Priest/Mage/Lock version)
	kDr.RegisterAura(kDr.CATEGORY_SILENCE, 50613); -- Arcane Torrent (Runic power version)
	kDr.RegisterAura(kDr.CATEGORY_SILENCE, 69179); -- Arcane Torrent (Rage version)
	kDr.RegisterAura(kDr.CATEGORY_SILENCE, 80483); -- Arcane Torrent (Focus version)
	kDr.RegisterAura(kDr.CATEGORY_SILENCE, 129597); -- Arcane Torrent (Monk version)
	kDr.RegisterAura(kDr.CATEGORY_SILENCE, 155145); -- Arcane Torrent (Paladin version)
	kDr.RegisterAura(kDr.CATEGORY_SILENCE, 202719); -- Arcane Torrent (DH version)
	
	--[[ DISORIENTS ]]--
	-- Death Knight
	kDr.RegisterAura(kDr.CATEGORY_DISORIENT, 207167); -- Blinding Sleet (talent) -- FIXME: is this the right category?
	-- Demon Hunter
	kDr.RegisterAura(kDr.CATEGORY_DISORIENT, 207685); -- Sigil of Misery
	-- Druid
	kDr.RegisterAura(kDr.CATEGORY_DISORIENT, 33786); -- Cyclone
	-- Hunter
	kDr.RegisterAura(kDr.CATEGORY_DISORIENT, 186387); -- Bursting Shot
	-- Mage
	kDr.RegisterAura(kDr.CATEGORY_DISORIENT, 31661); -- Dragon's Breath
	-- Monk
	kDr.RegisterAura(kDr.CATEGORY_DISORIENT, 198909); -- Song of Chi-ji -- FIXME: is this the right category( tooltip specifically says disorient, so I guessed here)
	kDr.RegisterAura(kDr.CATEGORY_DISORIENT, 202274); -- Incendiary Brew -- FIXME: is this the right category( tooltip specifically says disorient, so I guessed here)
	-- Paladin
	kDr.RegisterAura(kDr.CATEGORY_DISORIENT, 105421); -- Blinding Light -- FIXME: is this the right category? Its missing from blizzard's list
	-- Priest
	kDr.RegisterAura(kDr.CATEGORY_DISORIENT, 8122); -- Psychic Scream
	-- Rogue
	kDr.RegisterAura(kDr.CATEGORY_DISORIENT, 2094); -- Blind
	-- Warlock
	kDr.RegisterAura(kDr.CATEGORY_DISORIENT, 5782); -- Fear -- probably unused
	kDr.RegisterAura(kDr.CATEGORY_DISORIENT, 118699); -- Fear -- new debuff ID since MoP
	kDr.RegisterAura(kDr.CATEGORY_DISORIENT, 130616); -- Fear (with Glyph of Fear)
	kDr.RegisterAura(kDr.CATEGORY_DISORIENT, 5484); -- Howl of Terror (talent)
	kDr.RegisterAura(kDr.CATEGORY_DISORIENT, 115268); -- Mesmerize (Shivarra)
	kDr.RegisterAura(kDr.CATEGORY_DISORIENT, 6358); -- Seduction (Succubus)
	-- Warrior
	kDr.RegisterAura(kDr.CATEGORY_DISORIENT, 5246); -- Intimidating Shout (main target)
	
	--[[ STUNS ]]--
	-- Death Knight
	-- Abomination's Might note: 207165 is the stun, but is never applied to players,
	-- so I haven't included it.
	kDr.RegisterAura(kDr.CATEGORY_STUN, 108194); -- Asphyxiate (talent for unholy)
	kDr.RegisterAura(kDr.CATEGORY_STUN, 221562); -- Asphyxiate (baseline for blood)
	kDr.RegisterAura(kDr.CATEGORY_STUN, 91800); -- Gnaw (Ghoul)
	kDr.RegisterAura(kDr.CATEGORY_STUN, 91797); -- Monstrous Blow (Dark Transformation Ghoul)
	kDr.RegisterAura(kDr.CATEGORY_STUN, 207171); -- Winter is Coming (Remorseless winter stun)
	-- Demon Hunter
	kDr.RegisterAura(kDr.CATEGORY_STUN, 179057); -- Chaos Nova
	kDr.RegisterAura(kDr.CATEGORY_STUN, 200166); -- Metamorphosis
	kDr.RegisterAura(kDr.CATEGORY_STUN, 205630); -- Illidan's Grasp, primary effect
	kDr.RegisterAura(kDr.CATEGORY_STUN, 208618); -- Illidan's Grasp, secondary effect
	kDr.RegisterAura(kDr.CATEGORY_STUN, 211881); -- Fel Eruption
	-- Druid
	kDr.RegisterAura(kDr.CATEGORY_STUN, 203123); -- Maim
	kDr.RegisterAura(kDr.CATEGORY_STUN, 5211); -- Mighty Bash
	kDr.RegisterAura(kDr.CATEGORY_STUN, 163505); -- Rake (Stun from Prowl)
	-- Hunter
	kDr.RegisterAura(kDr.CATEGORY_STUN, 117526); -- Binding Shot
	kDr.RegisterAura(kDr.CATEGORY_STUN, 24394); -- Intimidation
	-- Mage

	-- Monk
	kDr.RegisterAura(kDr.CATEGORY_STUN, 119381); -- Leg Sweep
	-- Paladin
	kDr.RegisterAura(kDr.CATEGORY_STUN, 853); -- Hammer of Justice
	-- Priest
	kDr.RegisterAura(kDr.CATEGORY_STUN, 200200); -- Holy word: Chastise
	kDr.RegisterAura(kDr.CATEGORY_STUN, 226943); -- Mind Bomb
	-- Rogue
	-- Shadowstrike note: 196958 is the stun, but it never applies to players,
	-- so I haven't included it.
	kDr.RegisterAura(kDr.CATEGORY_STUN, 1833); -- Cheap Shot
	kDr.RegisterAura(kDr.CATEGORY_STUN, 408); -- Kidney Shot
	kDr.RegisterAura(kDr.CATEGORY_STUN, 199804); -- Between the Eyes
	-- Shaman
	kDr.RegisterAura(kDr.CATEGORY_STUN, 118345); -- Pulverize (Primal Earth Elemental)
	kDr.RegisterAura(kDr.CATEGORY_STUN, 118905); -- Static Charge (Capacitor Totem)
	kDr.RegisterAura(kDr.CATEGORY_STUN, 204399); -- Earthfury (pvp talent)
	-- Warlock
	kDr.RegisterAura(kDr.CATEGORY_STUN, 89766); -- Axe Toss (Felguard)
	kDr.RegisterAura(kDr.CATEGORY_STUN, 30283); -- Shadowfury
	kDr.RegisterAura(kDr.CATEGORY_STUN, 22703); -- Summon Infernal
	-- Warrior
	kDr.RegisterAura(kDr.CATEGORY_STUN, 132168); -- Shockwave
	kDr.RegisterAura(kDr.CATEGORY_STUN, 132169); -- Storm Bolt
	-- Tauren
	kDr.RegisterAura(kDr.CATEGORY_STUN, 20549); -- War Stomp
	
	--[[ ROOTS ]]--
	-- Death Knight
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 96294); -- Chains of Ice (Chilblains Root)
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 204085); -- Deathchill (pvp talent)
	-- Druid
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 339); -- Entangling Roots
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 102359); -- Mass Entanglement (talent)
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 45334); -- Immobilized (wild charge, bear form)
	-- Hunter
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 53148); -- Charge (Tenacity pet)
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 162480); -- Steel Trap
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 190927); -- Harpoon
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 200108); -- Ranger's Net
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 212638); -- tracker's net
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 201158); -- Super Sticky Tar (Expert Trapper, Hunter talent, Tar Trap effect)
	-- Mage
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 122); -- Frost Nova
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 33395); -- Freeze (Water Elemental)
	-- kDr.RegisterAura(kDr.CATEGORY_ROOT, 157997); -- Ice Nova -- since 6.1, ice nova doesn't DR with anything
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 228600); -- Glacial spike (talent)
	-- Monk
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 116706); -- Disable
	-- Priest
	-- Shaman
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 64695); -- Earthgrab Totem
	
	-- test
	if (TEST_MODE) then
		kDr.RegisterAura(kDr.CATEGORY_STUN, 194384); -- Atonement
	end
end

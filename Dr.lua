local TEST_MODE = false;

local RESET = 18;
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
	--[[ Death Knight ]]
	-- roots
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 96294); -- Chains of Ice (chillblains)
	 
	-- stuns
	kDr.RegisterAura(kDr.CATEGORY_STUN, 108194); -- Asphyxiate
	kDr.RegisterAura(kDr.CATEGORY_STUN, 91800); -- Gnaw (Risen Ally)
	kDr.RegisterAura(kDr.CATEGORY_STUN, 47481); -- Gnaw (Ghoul)
	kDr.RegisterAura(kDr.CATEGORY_STUN, 91797); -- Monstrous Blow (DT Ghoul)
	kDr.RegisterAura(kDr.CATEGORY_STUN, 115001); -- Remorseless Winter
	 
	-- silences
	kDr.RegisterAura(kDr.CATEGORY_SILENCE, 47476); -- Strangulate
	 
	--[[ Druid ]]
	-- roots
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 12747); -- Entangling Roots
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 102359); -- Mass Entanglement
	 
	-- stuns
	kDr.RegisterAura(kDr.CATEGORY_STUN, 22570); -- Maim
	kDr.RegisterAura(kDr.CATEGORY_STUN, 5211); -- Mighty Bash
	kDr.RegisterAura(kDr.CATEGORY_STUN, 163505); -- Rake
	 
	-- incapacitates
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 99); -- Incapacitating Roar
	 
	-- disorients
	kDr.RegisterAura(kDr.CATEGORY_DISORIENT, 33786); -- Cyclone
	 
	-- silences
	--kDr.RegisterAura(kDr.CATEGORY_SILENCE, ???); -- Glyph of Fae Silence
	 
	--[[ Hunter ]]
	-- roots
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 53148); -- Charge (pet)
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 19387); -- Entrapment
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 109298); -- Narrow Escape
	 
	-- stuns
	kDr.RegisterAura(kDr.CATEGORY_STUN, 117526); -- Binding Shot
	kDr.RegisterAura(kDr.CATEGORY_STUN, 19577); -- Intimidation
	 
	-- incapacitates
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 3355); -- Freezing Trap
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 19386); -- Wyvern Sting
	 
	--[[ Mage ]]
	-- roots
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 33395); -- Freeze (water elemental)
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 122); -- Frost Nova
	--kDr.RegisterAura(kDr.CATEGORY_ROOT, ???); -- Ice Ward
	 
	-- stuns
	kDr.RegisterAura(kDr.CATEGORY_STUN, 44572); -- Deep Freeze
	 
	-- incapacitates
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 31661); -- Dragon's Breath
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 118); -- Polymorph (sheep)
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 28272); -- Polymorph (pig)
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 28271); -- Polymorph (turtle)
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 161372); -- Polymorph (peacock)
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 61305); -- Polymorph (cat)
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 61780); -- Polymorph (turkey)
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 61721); -- Polymorph (rabbit)
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 161355); -- Polymorph (penguin)
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 161354); -- Polymorph (monkey)
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 161353); -- Polymorph (polar bear)
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 126819); -- Polymorph (porcupine)
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 82691); -- Ring of Frost
	 
	-- silences
	kDr.RegisterAura(kDr.CATEGORY_SILENCE, 102051); -- Frostjaw
	 
	--[[ Monk ]]
	-- roots
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 116095); -- Disable
	 
	-- stuns
	kDr.RegisterAura(kDr.CATEGORY_STUN, 119392); -- Charging Ox Wave
	kDr.RegisterAura(kDr.CATEGORY_STUN, 120086); -- Fists of Fury
	kDr.RegisterAura(kDr.CATEGORY_STUN, 119381); -- Leg Sweep
	 
	-- incapacitates
	--kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, ???); -- Glyph of Breath of Fire
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 115078); -- Paralysis
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 137460); -- Ring of Peace
	 
	--[[ Paladin ]]
	-- roots
	 
	-- stuns
	kDr.RegisterAura(kDr.CATEGORY_STUN, 105593); -- Fist of Justice
	kDr.RegisterAura(kDr.CATEGORY_STUN, 853); -- Hammer of Justice
	kDr.RegisterAura(kDr.CATEGORY_STUN, 119072); -- Holy Wrath
	 
	-- incapacitates
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 20066); -- Repentance
	 
	-- disorients
	kDr.RegisterAura(kDr.CATEGORY_DISORIENT, 10326); -- Turn Evil
	kDr.RegisterAura(kDr.CATEGORY_DISORIENT, 115750); -- Blinding Light (TODO: verify this is the correct aura id)
	 
	-- silences
	kDr.RegisterAura(kDr.CATEGORY_SILENCE, 31935); -- Avenger's Shield
	 
	--[[ Priest ]]
	-- roots
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 87194); -- Glyph of Mind Blast
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 108920); -- Void Tendrils
	 
	-- incapacitates
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 605); -- Dominate Mind
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 88625); -- Holy Word: Chastise
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 64044); -- Psychic Horror
	 
	-- disorients
	kDr.RegisterAura(kDr.CATEGORY_DISORIENT, 8122); -- Psychic Scream
	 
	-- silences
	kDr.RegisterAura(kDr.CATEGORY_SILENCE, 15487); -- Silence
	 
	--[[ Rogue ]]
	-- stuns
	kDr.RegisterAura(kDr.CATEGORY_STUN, 1833); -- Cheap Shot
	kDr.RegisterAura(kDr.CATEGORY_STUN, 408); -- Kidney Shot
	 
	-- incapacitates
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 1776); -- Gouge
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 6770); -- Sap
	 
	-- disorients
	kDr.RegisterAura(kDr.CATEGORY_DISORIENT, 2094); -- Blind
	 
	-- silences
	kDr.RegisterAura(kDr.CATEGORY_SILENCE, 1330); -- Garrote
	 
	--[[ Shaman ]]
	-- roots
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 64695); -- Earthgrab Totem
	kDr.RegisterAura(kDr.CATEGORY_ROOT, 63685); -- Frost Shock (Frozen Power)
	 
	-- stuns
	kDr.RegisterAura(kDr.CATEGORY_STUN, 118345); -- Pulverize (Primal Earth Elemental)
	kDr.RegisterAura(kDr.CATEGORY_STUN, 118905); -- Static Charge (Capacitor Totem)
	 
	-- incapacitates
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 51514); -- Hex
	 
	--[[ Warlock ]]
	-- stuns
	kDr.RegisterAura(kDr.CATEGORY_STUN, 89766); -- Axe Toss (Felguard)
	kDr.RegisterAura(kDr.CATEGORY_STUN, 30283); -- Shadowfury
	kDr.RegisterAura(kDr.CATEGORY_STUN, 22703); -- Summon Infernal
	 
	-- incapacitates
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 710); -- Banish
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 137143); -- Blood Horror
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 6789); -- Mortal Coil
	 
	-- disorients
	kDr.RegisterAura(kDr.CATEGORY_DISORIENT, 5782); -- Fear
	kDr.RegisterAura(kDr.CATEGORY_DISORIENT, 5484); -- Howl of Terror
	kDr.RegisterAura(kDr.CATEGORY_DISORIENT, 115268); -- Mesmerize (Shivarra)
	kDr.RegisterAura(kDr.CATEGORY_DISORIENT, 6358); -- Seduction (Succubus)
	 
	--[[ Warrior ]]
	-- stuns
	kDr.RegisterAura(kDr.CATEGORY_STUN, 46968); -- Shockwave
	kDr.RegisterAura(kDr.CATEGORY_STUN, 107570); -- Storm Bolt
	 
	-- disorients
	kDr.RegisterAura(kDr.CATEGORY_DISORIENT, 5246); -- Intimidating Shout
	 
	--[[ Racials ]]
	-- stuns
	kDr.RegisterAura(kDr.CATEGORY_STUN, 20549); -- War Stomp
	 
	-- incapacitates
	kDr.RegisterAura(kDr.CATEGORY_INCAPACITATE, 107079); -- Quaking Palm
	 
	-- silences
	kDr.RegisterAura(kDr.CATEGORY_SILENCE, 28730); -- Arcane Torrent (mana)
	kDr.RegisterAura(kDr.CATEGORY_SILENCE, 25046); -- Arcane Torrent (energy)
	kDr.RegisterAura(kDr.CATEGORY_SILENCE, 50613); -- Arcane Torrent (runic power)
	kDr.RegisterAura(kDr.CATEGORY_SILENCE, 69179); -- Arcane Torrent (rage)
	kDr.RegisterAura(kDr.CATEGORY_SILENCE, 80483); -- Arcane Torrent (focus)
	kDr.RegisterAura(kDr.CATEGORY_SILENCE, 155145); -- Arcane Torrent (holy power)
	kDr.RegisterAura(kDr.CATEGORY_SILENCE, 129597); -- Arcane Torrent (chi)

	-- test
	if (TEST_MODE) then
		kDr.RegisterAura(kDr.CATEGORY_STUN, 6788); -- Weakened Soul
	end
end

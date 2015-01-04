-- **** imports ****

-- **** private ****
local MatchesFilter = function(self, filter, unit, index, auraName, auraId, auraCaster)

	-- force check by id
	if (filter.forceId) then
		if (auraId ~= filter.forceId) then
			return false;
		end
	-- check by name
	elseif (filter.name) then
		if (auraName ~= filter.name) then
			return false;
		end
	-- check by id
	elseif (filter.id) then
		if (auraId ~= filter.id) then
			return false;
		end
	end

	-- check type
	if (filter.type) then
		-- UnitAura returns 0-40 auras, internally we mark buffs as 1-40 and debuffs as 41-80
		if (filter.type == "DEBUFF" and (index <= 40 or index > 80)) then
			return false;
		elseif (filter.type == "BUFF" and (index <= 0 or index > 40)) then
			return false;
		end
	end

	-- check notoriety
	if (filter.notoriety) then
		if (filter.notoriety == "FRIEND" and not UnitIsFriend("player", unit)) then
			return false;
		elseif (filter.notoriety == "ENEMY" and not UnitIsEnemy("player", unit)) then
			return false;
		end
	end

	-- check caster
	if (filter.caster and (not auraCaster or not UnitIsUnit(filter.caster, auraCaster))) then
		return false;
	end

	return true;

end

local GetPriority = function( self, unit, index, auraName, auraId, auraCaster )
	local filters = self.filters;
	
	if ( #filters <= 0 ) then
		return 1;
	end
	
	for _, filter in ipairs( filters ) do
		for _, v in ipairs( filter ) do
			--[[
			local caster = v.caster;

			if ( not caster or ( auraCaster and UnitIsUnit( caster, auraCaster ) ) ) then		
				if ( v.forceId ) then
					if ( v.forceId == auraId ) then
						return v.priority or 1;
					end
				elseif ( v.name and v.name == auraName ) then

					--print(v.name .. " => " .. index);

					return v.priority or 1;
				end
			end
			]]

			if (MatchesFilter(self, v, unit, index, auraName, auraId, auraCaster)) then
				return v.priority or 1;
			end
		end
	end
	
	return nil;
end

local NextAura;
NextAura = function( self, unit, index, name, rank, texture, count, auraType, duration, expiration, caster, stealable, consolidate, auraId )
	if ( not name ) then
		return nil;		
	end

	local priority = GetPriority( self, unit, index, name, auraId, caster );
	if ( priority ) then
		return index, name, rank, texture, count, auraType, duration, expiration, caster, stealable, consolidate, auraId, priority;
	end

	return NextAura( self, unit, self.auraIterator( unit, index ) );
end

-- **** public ****
local AddFilter = function( self, filter )
	assert( type( filter ) == "table", "Parameter 'filter' must be a table" );
	
	for _, v in ipairs( filter ) do
		local id = v.id;
	
		if ( id and not v.name ) then
			v.name = GetSpellInfo( id );
		end
	end
	
	tinsert( self.filters, filter );
end

local RemoveFilter = function( self, filter )
	assert( type( filter ) == "table", "Parameter 'filter' must be a table" );
	
	local filters = self.filters;
	
	for index, value in ipairs( filters ) do
		if ( value == filter ) then
			tremove( filters, index );
		end
	end
end

-- **** call, ctor ****
local call = function( self, unit )
	return self.iterator, unit, 0;
end

local ctor = function( self, baseCtor, iterator )
	self.auraIterator = iterator();

	self.filters = { };
	self.iterator = function( unit, index )
		return NextAura( self, unit, self.auraIterator( unit, index ) );
	end
end

-- **** main ****
kCore.AuraFilter, _ = kCore.CreateClass( ctor, {
	AddFilter = AddFilter,
	RemoveFilter = RemoveFilter,
}, nil );
	
kCore.AuraFilter.metatable.__call = call;
 
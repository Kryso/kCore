local CheckAura;
CheckAura = function( index, debuffSwitch, unit, name, ... )
	if ( name ~= nil ) then
		return index, name, ...;
	end
	
	if ( debuffSwitch ) then
		return CheckAura( 41, false, unit, UnitAura( unit, 1, "HARMFUL" ) );
	end
	
	return nil;
end

local AuraIterator = function( unit, index )
	index = index + 1;

	if ( index <= 0 ) then
		return nil;
	elseif ( index <= 40 ) then
		return CheckAura( index, true, unit, UnitAura( unit, index, "HELPFUL" ) );
	elseif ( index <= 80 ) then
		return CheckAura( index, false, unit, UnitAura( unit, index - 40, "HARMFUL" ) );
	end
	
	return nil;
end

local BuffIterator = function( unit, index )
	index = index + 1;

	if ( index > 0 and index <= 40 ) then
		return CheckAura( index, false, unit, UnitAura( unit, index, "HELPFUL" ) );
	end
	
	return nil;
end

local DebuffIterator = function( unit, index )
	index = index + 1;

	if ( index > 0 and index <= 40 ) then
		return CheckAura( index, false, unit, UnitAura( unit, index, "HARMFUL" ) );
	end
	
	return nil;
end

local UnitAuras = function( unit )
	return AuraIterator, unit, 0
end

local UnitBuffs = function( unit )
	return BuffIterator, unit, 0;
end

local UnitDebuffs = function( unit )
	return DebuffIterator, unit, 0;
end

kCore.UnitAuras = UnitAuras;
kCore.UnitBuffs = UnitBuffs;
kCore.UnitDebuffs = UnitDebuffs;

-- imports
local RawCooldown
RawCooldown = kCore.CreateClass( function( self ) end, nil, function( self )
	local result = CreateFrame( "Cooldown", nil, nil, nil );
	
	if ( not RawCooldown.initialized ) then
		setmetatable( RawCooldown.prototype, getmetatable( result ) );
		RawCooldown.initialized = true;
	end
	
	return result;
end );

-- private
local Base = nil;

-- event handlers

-- frame scripts

-- public

-- constructor
local ctor = function( self, baseCtor )
	
end

-- main
kWidgets.Cooldown, Base = kCore.CreateClass( ctor, nil, RawCooldown );
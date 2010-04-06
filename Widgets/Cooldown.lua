-- imports
local kCore = kCore;

local AutoScale = kCore.Import( "AutoScale" );
local RawObject = kCore.Import( "RawObject" );

-- private
local Cooldown, Base;

-- event handlers

-- frame scripts

-- public

-- constructor
local createInstance = function( class )
	local result = CreateFrame( "Cooldown", nil, nil, nil );
	
	if ( not Cooldown.initialized ) then
		local metatable = getmetatable( result );

		setmetatable( Cooldown.prototype, metatable );
		
		Cooldown.globalMetadata.rawMetatable = metatable;
		
		local index = metatable.__index;
		Cooldown.globalMetadata.rawPrototype = index;
		Base = index;
		
		Cooldown.initialized = true;
	end
	
	return result;	
end

local ctor = function( self, baseCtor )
	
end

-- main
Cooldown = kCore.CreateClass( ctor, nil, createInstance, RawObject, AutoScale );

kWidgets.Cooldown = Cooldown;
kCore.Register( "Cooldown", Cooldown );
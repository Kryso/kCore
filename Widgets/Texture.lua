-- imports
local kCore = kCore;

local AutoScale = kCore.Import( "AutoScale" );
local RawObject = kCore.Import( "RawObject" );

-- private
local Texture, Base;

-- event handlers

-- frame scripts

-- public

-- constructor
local instanceFactory = function( class, frame )
	local result = frame:CreateTexture( nil, nil, nil );
	
	if ( not Texture.initialized ) then
		local metatable = getmetatable( result );

		setmetatable( Texture.prototype, metatable );
		
		Texture.globalMetadata.rawMetatable = metatable;
		
		local index = metatable.__index;
		Texture.globalMetadata.rawPrototype = index;
		Base = index;
		
		Texture.initialized = true;
	end
	
	return result;
end

local ctor = function( self, baseCtor, frame )
	
end

-- main
Texture, Base = kCore.CreateClass( ctor, nil, instanceFactory, RawObject, AutoScale );

kWidgets.Texture = Texture;
kCore.Register( "Texture", Texture );
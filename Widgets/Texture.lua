-- imports
local RawTexture
RawTexture = kCore.CreateClass( function( self, frame ) end, nil, function( class, frame )
	local result = frame:CreateTexture( nil, nil, nil );
	
	if ( not RawTexture.initialized ) then
		setmetatable( RawTexture.prototype, getmetatable( result ) );
		RawTexture.initialized = true;
	end
	
	return result;
end );

-- private
local Base = nil;

-- event handlers

-- frame scripts

-- public

-- constructor
local ctor = function( self, baseCtor, frame )
	
end

-- main
kWidgets.Texture, Base = kCore.CreateClass( ctor, nil, RawTexture );
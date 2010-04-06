-- imports
local kCore = kCore;

local AutoScale = kCore.Import( "AutoScale" );
local RawObject = kCore.Import( "RawObject" );

-- private
local FontString, Base;

-- frame scripts

-- public
	
-- constructor
local instanceFactory = function( self, frame )
	local result = frame:CreateFontString( nil, nil, nil );
	
	if ( not FontString.initialized ) then
		local metatable = getmetatable( result );

		setmetatable( FontString.prototype, metatable );
		
		FontString.globalMetadata.rawMetatable = metatable;
		
		local index = metatable.__index;
		FontString.globalMetadata.rawPrototype = index;
		Base = index;
		
		FontString.initialized = true;
	end
	
	return result;
end

local ctor = function( self, baseCtor, frame )

end

-- main
FontString, Base = kCore.CreateClass( ctor, nil, instanceFactory, RawObject, AutoScale );

kWidgets.FontString = FontString;
kCore.Register( "FontString", FontString );
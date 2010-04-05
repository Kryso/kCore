-- imports
local RawFontString
RawFontString = kCore.CreateClass( function( self, frame ) end, nil, function( self, frame )
	local result = frame:CreateFontString( nil, nil, nil );
	
	if ( not RawFontString.initialized ) then
		setmetatable( RawFontString.prototype, getmetatable( result ) );
		RawFontString.initialized = true;
	end
	
	return result;
end );

-- private
local Base = nil;

-- frame scripts

-- public
	
-- constructor
local ctor = function( self, baseCtor, frame )

end

-- main
kWidgets.FontString, Base = kCore.CreateClass( ctor, { 

	}, RawFontString );
-- imports
local kCore = kCore;
local kWidgets = kWidgets;

local GetMetadata = kCore.GetMetadata;

-- private

-- public
local Restore = function( self )
	setmetatable( self, self._mt );
	
	self._mt = nil;
	self.Restore = nil;
end

local MakeRaw = function( self )
	local metadata = GetMetadata( self );
	assert( metadata ~= nil, "Metadata not found" );
	
	local base = metadata.rawMetatable;
	assert( base ~= nil, "RawMetatable not found" );
	
	self._mt = getmetatable( self );
	self.Restore = Restore;
	
	setmetatable( self, base );
end

kCore.Register( "RawObject", kCore.CreateClass( nil, {
	MakeRaw = MakeRaw,		
}, nil ) );
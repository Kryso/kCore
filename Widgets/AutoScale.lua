local kCore = kCore;
local kWidgets = kWidgets;

local Scale = kWidgets.Scale;
local GetMetadata = kCore.GetMetadata;

-- private

-- public
local SetPoint = function( self, point, anchor, anchorPoint, x, y )
	local metadata = GetMetadata( self );
	assert( metadata ~= nil, "Metadata not found" );
	
	local base = metadata.rawPrototype;
	assert( base ~= nil, "RawPrototype not found" );

	local pt, at, apt, xt, yt = type( point ), type( anchor ), type( anchorPoint ), type( x ), type( y );
	
	if ( pt == "string" and at == "table" and apt == "string" and xt == "number" and yt == "number" ) then
		base.SetPoint( self, point, anchor, anchorPoint, Scale( x ), Scale( y ) );
	elseif ( pt == "string" and at == "table" and apt == "string" ) then
		base.SetPoint( self, point, anchor, anchorPoint );
	elseif ( pt == "string" and at == "number" and apt == "number" ) then
		base.SetPoint( self, point, Scale( anchor ), Scale( anchorPoint ) );
	elseif ( pt == "string" ) then
		base.SetPoint( self, point );
	else
		error( "Invalid parameters for SetPoint function" );
	end
end

local SetWidth = function( self, width )
	local metadata = GetMetadata( self );
	assert( metadata ~= nil, "Metadata not found" );
	
	local base = metadata.rawPrototype;
	assert( base ~= nil, "RawPrototype not found" );

	base.SetWidth( self, Scale( width ) );
end

local SetHeight = function( self, height )
	local metadata = GetMetadata( self );
	assert( metadata ~= nil, "Metadata not found" );
	
	local base = metadata.rawPrototype;
	assert( base ~= nil, "RawPrototype not found" );

	base.SetHeight( self, Scale( height ) );
end

kCore.Register( "AutoScale", kCore.CreateClass( nil, {
		SetPoint = SetPoint,
		SetWidth = SetWidth,
		SetHeight = SetHeight,		
	}, nil ) );
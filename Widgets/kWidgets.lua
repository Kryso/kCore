--[[-- private
local uiScale = 0.64; --GetCVar( "uiScale" );
local resolutionX, resolutionY = 1920, 1200; --GetCVar( "gxResolution" ):match( "(%d+)x(%d+)" );
local coeffX = GetScreenWidth() / ( resolutionX * uiScale )
local coeffY = GetScreenHeight() / ( resolutionY * uiScale )

-- public
local SetPoint = function( self, point, anchor, anchorPoint, x, y )
	local base = self._topBase;
	local pt, at, apt, xt, yt = type( point ), type( anchor ), type( anchorPoint ), type( x ), type( y );
	
	if ( pt == "string" and at == "table" and apt == "string" and xt == "number" and yt == "number" ) then
		base.SetPoint( self, point, anchor, anchorPoint, x * coeffX, y * coeffY );
	elseif ( pt == "string" and at == "table" and apt == "string" ) then
		base.SetPoint( self, point, anchor, anchorPoint );
	elseif ( pt == "string" and at == "number" and apt == "number" ) then
		base.SetPoint( self, point, anchor * coeffX, anchorPoint * coeffY );
	elseif ( pt == "string" ) then
		base.SetPoint( self, point );
	else
		error( "Invalid parameters for SetPoint function" );
	end
end

local SetWidth = function( self, width )
	self._topBase.SetWidth( self, width * coeffX );
end

local SetHeight = function( self, height )
	self._topBase.SetHeight( self, height * coeffY );
end]]--

-- main
kWidgets = {
	--[[SetPoint = SetPoint,
	SetWidth = SetWidth,
	SetHeight = SetHeight,]]--
	
	DefaultFont = [[Fonts\FRIZQT__.ttf]],
	DefaultFontSize = 11,
	DefaultFontStyle = "OUTLINE",
};
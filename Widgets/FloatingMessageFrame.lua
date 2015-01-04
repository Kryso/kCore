local _, Internals = ...; 

-- **** imports ****
local kCore = kCore;
local kWidgets = kWidgets;

local Frame = kWidgets.Frame;

local FloatingFontString = Internals.FloatingFontString;

-- **** private ****
local Base;

local GetLine = function( self )
	local lines = self.lines;
	
	for _, line in ipairs( lines ) do
		if ( not line:IsVisible() ) then
			return line;
		end
	end
	
	if ( self.maxLineCount <= #lines ) then
		return nil;
	end
	
	local line = FloatingFontString( self );
	line:SetPoint( "TOP", self, "TOP", 0, 0 );
	line:SetOffset( 0, -self:GetHeight() );
	
	tinsert( lines, line );

	return line;
end

-- **** public ****
local Add = function( self, text, size, color, level )
	local line = GetLine( self );

	if ( not line ) then
		return;
	end

	local speed = self.speed;
	
	line:SetSpeed( self.speed );
	line:SetFont( self.font, size or self.fontSize, self.fontStyle );
	line:SetTextColor( unpack( color or self.defaultColor ) );
	line:SetText( text );
	
	if ( level == 1 ) then
		line:SetDrawLayer( "BACKGROUND" );
	elseif ( level == 2 ) then
		line:SetDrawLayer( "BORDER" );
	elseif ( level == 3 ) then
		line:SetDrawLayer( "ARTWORK" );
	else
		line:SetDrawLayer( "OVERLAY" );
	end
	
	local offsetX, offsetY = 0, 0;
	
	if ( level == 1 or level == 2 or level == 3 ) then
		local num = ( self:GetWidth() - line:GetWidth() ) / 2;
		
		offsetX = random( -num, num );
	end
	
	-- levels 1, 2, 3 are allowed to overlap
	if ( level ~= 1 and level ~= 2 and level ~= 3 ) then
		local lastLine = self.lastLine;
		
		if ( lastLine and lastLine:IsVisible() ) then
			local lineHeight = line:GetHeight();
			local _, lastStartY = lastLine:GetInitialOffset();
			local _, lastCurrentOffsetY = lastLine:GetCurrentOffset();
			
			local distance = abs( lastCurrentOffsetY ) - lastStartY;
			
			if ( distance < lineHeight ) then
				offsetY = lineHeight - distance;
			end
		end
		
		self.lastLine = line;
	end
	
	line:SetInitialOffset( offsetX, offsetY );
	line:Show();
end

local GetMaxLineCount = function( self )
	return self.maxLineCount;
end

local SetMaxLineCount = function( self, value )
	self.maxLineCount = value;
end

local GetSpeed = function( self )
	return self.speed;
end

local SetSpeed = function( self, value )
	self.speed = value;
end

-- **** constructor ****
local ctor = function( self, baseCtor )
	baseCtor( self );
	
	self.defaultColor = { 1, 1, 1, 1 };
	self.maxLineCount = 20;
	self.speed = 23;
	
	self.font = kWidgets.DefaultFont;
	self.fontSize = kWidgets.DefaultFontSize;
	self.fontStyle = kWidgets.DefaultFontStyle;
	
	--[[local a = kWidgets.Texture( self );
	a:SetAllPoints( self );
	a:SetTexture( 0, 0, 0, 1 );
	a:SetDrawLayer( "BACKGROUND" );]]--
	
	self.lines = { };
end

-- **** main ****
kWidgets.FloatingMessageFrame, Base = kCore.CreateClass( ctor, { 
	Add = Add,
	
	GetMaxLineCount = GetMaxLineCount,
	SetMaxLineCount = SetMaxLineCount,
	
	GetSpeed = GetSpeed,
	SetSpeed = SetSpeed,
}, Frame );
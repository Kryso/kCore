-- **** imports ****
local Icon = kWidgets.Icon;
local FontString = kWidgets.FontString;
local Frame = kWidgets.Frame;

-- **** private ****
local Base;

-- **** public ****
local SetType = function( self, type )
	if ( type == "Magic" ) then
		self:SetBorderColor( 70 / 255, 70 / 255, 200 / 255 );
	elseif ( type == "Curse" ) then
		self:SetBorderColor( 200 / 255, 70 / 255, 200 / 255 );
	elseif ( type == "Poison" ) then
		self:SetBorderColor( 70 / 255, 200 / 255, 70 / 255 );
	else
		self:SetBorderColor( 200 / 255, 70 / 255, 70 / 255 );
	end
end

local SetCount = function( self, value )
	local count = self.count;

	if ( value and value > 1 ) then
		count:SetText( tostring( value ) );
		count:Show();
	else
		count:Hide();
	end
end

-- **** ctor ****
local ctor = function( self, baseCtor )
	baseCtor( self, true );
	
	-- preparation for SetFont stuff once I implement multiple inheritance
	self.font = kWidgets.DefaultFont;
	self.fontSize = kWidgets.DefaultFontSize;
	self.fontStyle = kWidgets.DefaultFontStyle;
	
	local overlayFrame = Frame();
	overlayFrame:SetParent( self );
	overlayFrame:SetPoint( "TOPLEFT", self, "TOPLEFT", 0, 0 );
	overlayFrame:SetPoint( "BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0 );
	overlayFrame:SetFrameLevel( self.cooldown:GetFrameLevel() + 1 );
	self.overlayFrame = overlayFrame;
	
	local count = FontString( self );
	count:SetFont( self.font, self.fontSize, self.fontStyle );
	count:SetPoint( "BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 2 );
	count:SetDrawLayer( "OVERLAY" );
	count:SetParent( overlayFrame );
	self.count = count;
	
	-- cooldown text will be added at some point
	self.cooldown.noOCC = true;
end

kWidgets.AuraIcon, Base = kCore.CreateClass( ctor, {
	SetType = SetType,
	SetCount = SetCount,
}, Icon );
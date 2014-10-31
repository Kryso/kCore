-- **** imports ****
local Frame = kWidgets.Frame;
local Texture = kWidgets.Texture;
local Border = kWidgets.Border;
local Cooldown = kWidgets.Cooldown;

-- **** private ****
local Base;

-- **** public ****
local GetTexture = function( self )
	return self.icon:GetTexture();
end

local SetTexture = function( self, ... )
	self.icon:SetTexture( ... );
end

--[[local SetDrawLayer = function( self, layer )
	self.icon:SetDrawLayer( layer );
	Base.SetDrawLayer( self, layer );
end]]--

local SetTexCoord = function( self, ... )
	self.icon:SetTexCoord( ... );
end

local GetTexCoord = function( self )
	return self.icon:GetTexCoord();
end

-- border
local SetBorderSize = function( self, size )
	local border = self.border;
	border:SetInnerSize( size );
	
	local iconOffset = border:GetSize();	
	
	local icon = self.icon;
	icon:SetPoint( "TOPLEFT", self, "TOPLEFT", iconOffset, -iconOffset );
	icon:SetPoint( "BOTTOMRIGHT", self, "BOTTOMRIGHT", -iconOffset, iconOffset );
end

local SetBorderColor = function( self, ... )
	self.border:SetVertexColor( ... );
end

-- cooldown
local ShowCooldown = function( self )
	self.cooldown:Show();
end

local HideCooldown = function( self )
	self.cooldown:Hide();
end

local SetCooldown = function( self, start, duration )
	local cooldown = self.cooldown;

	if ( start and start > 0 and duration and duration > 0 ) then
		cooldown:SetCooldown( start, duration );		
		self:ShowCooldown();
	else
		self:HideCooldown();
	end
end

-- **** constructor ****
local ctor = function( self, baseCtor, createCooldown )
	baseCtor( self );
	
	local border = Border( self );
	border:SetPoint( "TOPLEFT", self, "TOPLEFT", 0, 0 );
	border:SetPoint( "BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0 );
	self.border = border;
	
	local icon = Texture( self );
	icon:SetDrawLayer( "ARTWORK" );
	icon:SetTexCoord( 0.15, 0.85, 0.15, 0.85 );
	self.icon = icon;
	
	if ( createCooldown ) then
		local cooldown = Cooldown();
		cooldown:SetParent( self );
		cooldown:SetReverse( true );
		cooldown:SetPoint( "TOPLEFT", icon, "TOPLEFT", 0, 0 );
		cooldown:SetPoint( "BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0 );
		self.cooldown = cooldown;
	end
	
	self:SetBorderSize( 1 );
end

-- **** main ****
kWidgets.Icon, Base = kCore.CreateClass( ctor, { 
	-- icon
	GetTexture = GetTexture,
	SetTexture = SetTexture,
	
	SetTexCoord = SetTexCoord,
	GetTexCoord = GetTexCoord,
	
	-- border
	SetBorderColor = SetBorderColor,
	SetBorderSize = SetBorderSize,
	
	-- cooldown
	SetCooldown = SetCooldown,
	ShowCooldown = ShowCooldown,
	HideCooldown = HideCooldown,
}, Frame );
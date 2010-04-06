-- imports
local kWidgets = kWidgets;

local Texture = kWidgets.Texture;

-- private
local Base = nil;

local UpdateAnchors = function( self )
	local outerSize = self.outerSize;
	local innerSize = self.innerSize;
	
	local left = self.left;
	left:ClearAllPoints();
	left:SetPoint( "TOPLEFT", self, "TOPLEFT", outerSize, -outerSize );
	left:SetPoint( "BOTTOMRIGHT", self, "BOTTOMLEFT", outerSize + innerSize, outerSize );
	
	local right = self.right;
	right:ClearAllPoints();
	right:SetPoint( "TOPRIGHT", self, "TOPRIGHT", -outerSize, -outerSize );
	right:SetPoint( "BOTTOMLEFT", self, "BOTTOMRIGHT", -( outerSize + innerSize ), outerSize );
	
	local top = self.top;
	top:ClearAllPoints();
	top:SetPoint( "TOPLEFT", left, "TOPRIGHT", 0, 0 );
	top:SetPoint( "BOTTOMRIGHT", right, "TOPLEFT", 0, -innerSize );
	
	local bottom = self.bottom;
	bottom:ClearAllPoints();
	bottom:SetPoint( "TOPLEFT", left, "BOTTOMRIGHT", 0, innerSize );
	bottom:SetPoint( "BOTTOMRIGHT", right, "BOTTOMLEFT", 0, 0 );
end

-- event handlers

-- frame scripts

-- public
local SetVertexColor = function( self, ... )
	self.left:SetVertexColor( ... );
	self.right:SetVertexColor( ... );
	self.top:SetVertexColor( ... );
	self.bottom:SetVertexColor( ... );
end

local GetInnerSize = function( self )
	return self.innerSize;
end

local SetInnerSize = function( self, size )
	self.innerSize = size;
	
	UpdateAnchors( self );
end

local GetOuterSize = function( self )
	return self.outerSize;
end

local SetOuterSize = function( self, size )
	self.outerSize = size;
	
	UpdateAnchors( self );
end

local GetSize = function( self )
	return self.innerSize + self.outerSize * 2;
end

-- constructor
local ctor = function( self, baseCtor, frame )
	self.innerSize = 1;
	self.outerSize = 1;

	self:SetTexture( 1, 1, 1, 1 );
	self:SetDrawLayer( "BACKGROUND" );
	
	local left = Texture( frame );
	left:SetTexture( 1, 1, 1, 1 );
	left:SetDrawLayer( "BORDER" );
	self.left = left;

	local right = Texture( frame );
	right:SetTexture( 1, 1, 1, 1 );
	right:SetDrawLayer( "BORDER" );
	self.right = right;
	
	local top = Texture( frame );
	top:SetTexture( 1, 1, 1, 1 );
	top:SetDrawLayer( "BORDER" );
	self.top = top;
	
	local bottom = Texture( frame );
	bottom:SetTexture( 1, 1, 1, 1 );
	bottom:SetDrawLayer( "BORDER" );
	self.bottom = bottom;
	
	Base.SetVertexColor( self, unpack( kWidgets.DefaultBackgroundColor ) );	
	self:SetVertexColor( unpack( kWidgets.DefaultBorderColor ) );
	
	UpdateAnchors( self );
end

-- main
kWidgets.Border, Base = kCore.CreateClass( ctor, { 
		SetVertexColor = SetVertexColor,
		
		SetInnerSize = SetInnerSize,
		GetInnerSize = GetInnerSize,
		
		SetOuterSize = SetOuterSize,
		GetOuterSize = GetOuterSize,
		
		GetSize = GetSize,
	}, Texture );
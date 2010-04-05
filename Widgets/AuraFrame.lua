-- **** imports ****
local AuraFilter = kCore.AuraFilter;
local UnitAuras = kCore.UnitAuras;
local Frame = kWidgets.Frame;
local AuraIcon = kWidgets.AuraIcon;

-- **** private ****
local Base;

local GetIcon = function( self, index )
	local icons = self.icons;
	local icon = icons[ index ];
	
	local iconSize = self.iconSize;
	local margin = self.margin;
	
	local iconCount = #icons;
	local maxWidth = self:GetMaxWidth();
	
	if ( maxWidth and maxWidth < ( index ) * ( iconSize + margin ) - margin ) then
		return nil;
	end
	
	if ( not icon ) then
		icon = AuraIcon( true );
		icon:SetParent( self );
		icon:SetWidth( iconSize );
		icon:SetHeight( iconSize );

		if ( index == 1 ) then
			icon:SetPoint( "LEFT", self, "LEFT", 0, 0 );
		else
			icon:SetPoint( "LEFT", icons[ index - 1 ], "RIGHT", margin, 0 );
		end
		
		tinsert( icons, icon );
	end
	
	return icon;
end

local SetIcon = function( self, index, texture, count, type, duration, expiration )
	local icon = GetIcon( self, index );
	
	if ( icon ) then	
		icon:SetTexture( texture );
		icon:SetCount( count );
		icon:SetType( type );
		icon:SetCooldown( expiration - duration, duration );
		
		icon:Show();
		
		return true;
	end
	
	return false;
end

-- **** event handlers ****
local OnPlayerEnteringWorld = function( self )
	self:Render();
end

local OnUnitAura = function( self, unit )
	if ( unit ~= self:GetUnit() ) then return; end

	self:Render();
end

local OnPlayerTargetChanged = function( self, method )
	if ( "target" ~= self:GetUnit() ) then return; end

	self:Render();
end

local OnPlayerFocusChanged = function( self )
	if ( "focus" ~= self:GetUnit() ) then return; end

	self:Render();
end

local OnPartyMembersChanged = function( self )
	local unit = self:GetUnit();

	if ( not unit or not unit:match( "^party%d$" ) ) then return; end

	self:Render();
end

-- **** public ****
local GetUnit = function( self )
	return self.unit or self.parent:GetAttribute( "unit" );
end

local Render = function( self )
	local index = 1;
	
	local unit = self:GetUnit();
	
	if ( unit ) then
		for _, name, _, texture, count, auraType, duration, expirationTime, _, _, _, spellId, priority in self.filter( unit ) do
			local result = SetIcon( self, index, texture, count, auraType, duration, expirationTime );

			if ( not result ) then
				break;
			end
			
			index = index + 1;
		end
	end
	
	local icons = self.icons;
	for iconIndex = index, #self.icons do
		icons[ iconIndex ]:Hide();
	end
	
	local iconSize = self.iconSize;
	local margin = self.margin;
	
	self:SetWidth( ( index - 1 ) * ( iconSize + margin ) - margin );
	self:SetHeight( iconSize );
end

-- size and anchoring
local GetMaxWidth = function( self )
	local parent = self.parent;

	return self.maxWidth or ( parent and parent:GetWidth() );
end

local SetMaxWidth = function( self, value )
	assert( type( value ) == "number", "Paremeter 'value' must be a number" );
	
	self.maxWidth = value;
end

-- icon properties
local GetMargin = function( self )
	return self.margin;
end

local SetMargin = function( self, value )
	assert( type( value ) == "number", "Paremeter 'value' must be a number" );

	self.margin = value;
end

local GetIconSize = function( self )
	return self.iconSize;
end

local SetIconSize = function( self, value )
	assert( type( value ) == "number", "Paremeter 'value' must be a number" );

	self.iconSize = value;
end

-- filtering
local AddFilter = function( self, filter )
	self.filter:AddFilter( filter );
	
	self:Render();
end

local RemoveFilter = function( self, filter )
	self.filter:RemoveFilter( filter );
	
	self:Render();
end

-- **** ctor ****
local ctor = function( self, baseCtor, unit, iterator )
	baseCtor( self );
	
	if ( type( unit ) == "string" ) then
		self.unit = unit;
	else 
		self.parent = unit;
		self:SetParent( unit );
	end
	
	self.icons = { };
	
	self.filter = AuraFilter( iterator );

	self:RegisterEvent( "PLAYER_ENTERING_WORLD", OnPlayerEnteringWorld );
	self:RegisterEvent( "UNIT_AURA", OnUnitAura );
	self:RegisterEvent( "PLAYER_TARGET_CHANGED", OnPlayerTargetChanged );
	self:RegisterEvent( "PLAYER_FOCUS_CHANGED", OnPlayerFocusChanged );
	self:RegisterEvent( "PARTY_MEMBERS_CHANGED", OnPartyMembersChanged );
end

-- **** main ****
kWidgets.AuraFrame, Base = kCore.CreateClass( ctor, {
		GetUnit = GetUnit,
		Render = Render,
		
		-- size and anchoring
		GetMaxWidth = GetMaxWidth,
		SetMaxWidth = SetMaxWidth,

		-- icon properties
		SetIconSize = SetIconSize,
		GetIconSize = GetIconSize,
		SetMargin = SetMargin,
		GetMargin = GetMargin,
		
		-- filtering
		AddFilter = AddFilter,
		RemoveFilter = RemoveFilter,
	}, Frame );
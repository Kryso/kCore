local _, Internals = ...; 

-- **** imports ****
local kCore = kCore;
local kWidgets = kWidgets;

local FontString = kWidgets.FontString;

-- **** private ****
local Base;

-- **** frame scripts ****
local OnTranslationFinished = function( animation, requested )
	local group = animation:GetParent();
	local self = group:GetParent();
	
	self:Hide();
end

-- **** event handlers ****

-- **** public ****
local SetOffset = function( self, x, y )
	local scale = UIParent:GetScale();

	self.translationOffsetX = x * scale;
	self.translationOffsetY = y * scale;
end

local GetOffset = function( self, x, y )
	local scale = UIParent:GetScale();
	
	return self.translationOffsetX / scale, self.translationOffsetY / scale;
end

local Show = function( self )
	local offsetX = self.translationOffsetX;
	local offsetY = self.translationOffsetY + self:GetHeight();
	local duration = abs( offsetY / self.speed );
	
	local translation = self.translation;
	translation:SetOffset( offsetX, offsetY );
	translation:SetDuration( duration );
	
	local fadeOut = self.fadeOut;
	fadeOut:SetStartDelay( ( duration / 4 ) * 3 );
	fadeOut:SetDuration( duration / 4 );
	
	self:SetAlpha( 0 );	
	
	local animationGroup = self.animationGroup;
	animationGroup:SetInitialOffset( self.initialOffsetX, self.initialOffsetY );
	animationGroup:Play();
	
	Base.Show( self );
end

local Hide = function( self )
	self.animationGroup:Stop();
	
	Base.Hide( self );
end

local GetSpeed = function( self )
	return self.speed;
end

local SetSpeed = function( self, value )
	self.speed = value;
end

local SetInitialOffset = function( self, x, y )
	local scale = UIParent:GetScale();
	
	self.initialOffsetX = x * scale;
	self.initialOffsetY = y * scale;
end

local GetInitialOffset = function( self )
	local scale = UIParent:GetScale();
	
	return self.initialOffsetX / scale, self.initialOffsetY / scale;
end

local GetCurrentOffset = function( self )
	local scale = UIParent:GetScale();
	
	local translation = self.translation;
	--Smooth
	local progress = translation:GetProgress();
	local offsetX, offsetY = translation:GetOffset();

	return ( offsetX * progress ) / scale, ( offsetY * progress ) / scale;
end

-- **** constructor ****
local ctor = function( self, baseCtor, frame )
	baseCtor( self );

	self.speed = 20;
	
	local animationGroup = self:CreateAnimationGroup( nil, nil );
	self.animationGroup = animationGroup;
	
	local translation = animationGroup:CreateAnimation( "Translation", nil, nil );
	translation:SetScript( "OnFinished", OnTranslationFinished );
	self.translation = translation;
	
	local fadeIn = animationGroup:CreateAnimation( "Alpha", nil, nil );
	fadeIn:SetDuration( 0.2 );
	fadeIn:SetSmoothing( "IN" );
	fadeIn:SetChange( 1 );
	self.fadeIn = fadeIn;
	
	local fadeOut = animationGroup:CreateAnimation( "Alpha", nil, nil );
	fadeOut:SetSmoothing( "OUT" );
	fadeOut:SetChange( -1 );
	self.fadeOut = fadeOut;
end

-- **** main ****
Internals.FloatingFontString, Base = kCore.CreateClass( ctor, { 
	GetOffset = GetOffset,
	SetOffset = SetOffset,
	
	Show = Show,
	Hide = Hide,
	
	GetSpeed = GetSpeed,
	SetSpeed = SetSpeed,
	
	GetInitialOffset = GetInitialOffset,
	SetInitialOffset = SetInitialOffset,
	
	GetCurrentOffset = GetCurrentOffset,
}, FontString );
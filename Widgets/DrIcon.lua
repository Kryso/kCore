-- **** imports ****
local Icon = kWidgets.Icon;
local FontString = kWidgets.FontString;
local Frame = kWidgets.Frame;

-- **** private ****
local Base;

-- **** public ****
local SetCoeff = function(self, value)
	local coeff = self.coeff;

	coeff:SetText(tostring(value * 100) .. "%");
end

-- **** ctor ****
local ctor = function(self, baseCtor)
	baseCtor(self, true);
	
	-- preparation for SetFont stuff once I implement multiple inheritance
	self.font = kWidgets.DefaultFont;
	self.fontSize = kWidgets.DefaultFontSize - 2;
	self.fontStyle = kWidgets.DefaultFontStyle;
	
	--self:SetBorderColor( 200 / 255, 70 / 255, 70 / 255 );

	self:SetBorderColor(unpack(kWidgets.DefaultValueColor));

	local overlayFrame = Frame();
	overlayFrame:SetParent(self);
	overlayFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
	overlayFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0);
	overlayFrame:SetFrameLevel(self.cooldown:GetFrameLevel() + 1);
	self.overlayFrame = overlayFrame;
	
	local coeff = FontString(self);
	coeff:SetFont(self.font, self.fontSize, self.fontStyle);
	coeff:SetPoint("BOTTOM", self, "BOTTOM", 0, 2);
	coeff:SetDrawLayer("OVERLAY");
	coeff:SetParent(overlayFrame);
	self.coeff = coeff;
	
	-- cooldown text will be added at some point
	self.cooldown.noOCC = true;
end

kWidgets.DrIcon, Base = kCore.CreateClass(ctor, {
	SetCoeff = SetCoeff,
}, Icon);
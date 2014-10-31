-- main
local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local Scale = function( value )
	return E and E:Scale( value ) or value;
end

kWidgets = {	
	DefaultFont = E and E["media"]["font"] or [[Fonts\FRIZQT__.ttf]],
	DefaultFontSize = 11,
	DefaultFontStyle = "OUTLINE",
	
	DefaultBorderColor = E and E["media"]["bordercolor"] or { 1, 1, 1, 1 },
	DefaultBackgroundColor = E and E["media"]["backdropcolor"] or { .1, .1, .1, 1 },
	
	Scale = Scale,
};
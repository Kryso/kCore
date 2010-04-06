-- main
local TukuiDB = TukuiDB;

local Scale = function( value )
	return TukuiDB and TukuiDB:Scale( value ) or value;
end

kWidgets = {	
	DefaultFont = TukuiDB and TukuiDB["media"]["font"] or [[Fonts\FRIZQT__.ttf]],
	DefaultFontSize = 11,
	DefaultFontStyle = "OUTLINE",
	
	DefaultBorderColor = TukuiDB and TukuiDB["media"]["bordercolor"] or { 1, 1, 1, 1 },
	DefaultBackgroundColor = TukuiDB and TukuiDB["media"]["backdropcolor"] or { .1, .1, .1, 1 },
	
	Scale = Scale,
};
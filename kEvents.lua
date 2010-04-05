-- imports	
local Frame = kWidgets.Frame;

-- private
local frame = Frame();

-- public
local RegisterEvent = function( event, handler )
	assert( type( event ) == "string", "Event must be string" );
	assert( type( handler ) == "function", "Handler must be function" );

	return frame:RegisterEvent( event, handler );
end

local UnregisterEvent = function( eventObject )
	frame:UnregisterEvent( eventObject );
end
-- main
kEvents = {
	RegisterEvent = RegisterEvent,
	UnregisterEvent = UnregisterEvent
};
-- imports
local kCore = kCore;

local AutoScale = kCore.Import( "AutoScale" );
local RawObject = kCore.Import( "RawObject" );

-- private
local Frame, Base;

-- frame scripts
local OnEvent = function( self, event, ... )
	local handlers = self.handlers;
	local handlerTable = handlers[ event ];
	
	for _, eventObject in ipairs( handlerTable ) do
		eventObject.handler( self, ... );
	end
end

-- public
local RegisterEvent = function( self, event, handler )
	local handlers = self.handlers;

	local eventObject = { event = event, handler = handler };
	local handlerTable = handlers[ event ];
	
	if ( handlerTable ) then
		tinsert( handlerTable, eventObject );
	else
		handlers[ event ] = { eventObject };
		Base.RegisterEvent( self, event );
	end
	
	return eventObject;
end

local UnregisterEvent = function( self, eventObject )
	local handlers = self.handlers;

	local event = eventObject.event;
	local handlerTable = handlers[ event ];
	
	if ( not handlerTable ) then return; end

	for index, value in ipairs( handlerTable ) do
		if ( value == eventObject ) then
			tremove( handlerTable, index );
			break;
		end
	end
	
	if ( #handlerTable <= 0 ) then
		Base.UnregisterEvent( self, event );
		handlers[ event ] = nil;
	end
end
	
-- constructor
local createInstance = function( class )
	local result = CreateFrame( "Frame", nil, UIParent, nil );

	if ( not Frame.initialized ) then
		local metatable = getmetatable( result );

		setmetatable( Frame.prototype, metatable );
		
		Frame.globalMetadata.rawMetatable = metatable;
		
		local index = metatable.__index;
		Frame.globalMetadata.rawPrototype = index;
		Base = index;
		
		Frame.initialized = true;
	end
	
	return result;
end

local ctor = function( self, baseCtor )
	self.handlers = { };
	
	self:SetScript( "OnEvent", OnEvent );
end

-- main
Frame = kCore.CreateClass( ctor, { 
		RegisterEvent = RegisterEvent,
		UnregisterEvent = UnregisterEvent,
	}, createInstance, RawObject, AutoScale );
	
kWidgets.Frame = Frame;
kCore.Register( "Frame", Frame );
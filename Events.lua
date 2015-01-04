-- Event
local Event;
do
	-- imports

	-- private

	-- ctor

	-- main

end

-- kEvents
do
	-- imports	
	local Frame = kWidgets.Frame;

	-- private
	local frame = Frame();

	local timerPool = { };

	-- public
	local RegisterEvent = function( event, handler )
		assert( type( event ) == "string", "Event must be string" );
		assert( type( handler ) == "function", "Handler must be function" );

		return frame:RegisterEvent( event, handler );
	end

	local UnregisterEvent = function( eventObject )
		frame:UnregisterEvent( eventObject );
	end

	local RegisterTimer = function ( time, func )
		
		local count = #timerPool;
		local frame;
		if (count <= 0) then
			frame = CreateFrame("frame");
		else
			frame = timerPool[count];
			timerPool[count] = nil;
		end

		local total = 0
		local function onUpdate(self, elapsed)
		    total = total + elapsed

		    if total >= time then
		    	frame:SetScript("OnUpdate", nil);
		    	tinsert(timerPool, frame);
		        func();
		    end
		end
		frame:SetScript("OnUpdate", onUpdate);

	end

	-- main
	kEvents = {
		Event = Event,

		RegisterEvent = RegisterEvent,
		UnregisterEvent = UnregisterEvent,

		RegisterTimer = RegisterTimer
	};
end
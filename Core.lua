local CreateClass;
do
	local CreateInstance = function( class, ... )
		local result = class.createInstance and class:createInstance( ... ) or { };
		
		setmetatable( result, class.metatable );

		local inherit = class.inherit;
		if ( inherit ) then
			while ( inherit.inherit ) do
				inherit = inherit.inherit;
			end
			result._topBase = inherit.prototype;
		end
		
		class.ctor( result, ... );
		
		return result;
	end

	local classMetatable = { __call = CreateInstance };	
	CreateClass = function( ctor, prototype, inherit )
		local result = { };	
		local createInstance;
		if ( inherit ) then
			if ( type( inherit ) == "function" ) then
				createInstance = inherit;
				inherit = nil;
			elseif ( inherit.createInstance ) then
				createInstance = inherit.createInstance;
			end
		end

		local metatable = { 
			__index = prototype
		};
		
		if ( inherit ) then
			setmetatable( prototype, inherit.metatable );
		end

		result.ctor = function( self, ... )
			if ( inherit ) then
				ctor( self, inherit.ctor, ... );
			else
				ctor( self, ... );
			end
		end;
		result.prototype = prototype;
		result.metatable = metatable;
		if ( createInstance ) then
			result.createInstance = function( self, ... )
				return createInstance( result, ... );
			end
		end
		result.inherit = inherit;
		setmetatable( result, classMetatable );
		
		return result, inherit and inherit.prototype or nil;
	end
end

local Queue;
do
	local Enqueue = function( self, value )
		tinsert( self.table, value );
	end

	local Dequeue = function( self )
		local table = self.table;
	
		local result = table[ 1 ];
		tremove( table, 1 );
		
		return result;
	end
	
	local Count = function( self )
		return #self.table;
	end
	
	local ctor = function( self )
		self.table = { };
	end
	
	Queue = CreateClass( ctor, {
			Enqueue = Enqueue,
			Dequeue = Dequeue,
			
			Count = Count,
		}, nil );
end

kCore = {
	CreateClass = CreateClass,
	Queue = Queue,
};
local _, Internals = ...;

local GetType = function( object )
	local objectType = type( object );
	
	if ( objectType ~= "table" ) then return objectType; end
	
	local metatable = getmetatable( object );
	if ( metatable and metatable.metadata ) then
		local metadata = metatable.metadata;
	
		if ( metadata.isInstance ) then
			return "instance";
		elseif ( metadata.isClass ) then
			return metadata.isAbstract and "abstractclass" or "class";
		else
			error( "Object has metadata but is neither class nor instance" );
		end
	end
	
	return objectType;
end

local CreateClass;
do
	local SetupMetadata = function( class, name )
		local metadata = {
				isInstance = true,
			};
		class.metadata = metadata;
	end

	local SetupInstanceFactory;
	do
		local DefaultInstanceFactory = function( class )
			return { };
		end
	
		SetupInstanceFactory = function( class, instanceFactory )
			local instanceFactoryType = GetType( instanceFactory );
			
			if ( instanceFactoryType == "class" or instanceFactoryType == "abstractclass" ) then
				class.instanceFactory = instanceFactory.instanceFactory;
				return;
			elseif ( instanceFactoryType == "nil" ) then 
				class.instanceFactory = DefaultInstanceFactory;			
				return; 
			end		
			assert( instanceFactoryType == "function", "Parameter 'instanceFactory' must be function or nil" );
			
			class.instanceFactory = instanceFactory;
		end
	end

	local SetupCtor
	do
		local AbstractClass = function( self )
			error( "Cannot instantiate abstract class" );
		end

		local NoClass = function( self )
			error( "Cannot call base constructor of class with no inheritance" );
		end
		
		SetupCtor = function( class, ctor )
			local ctorType = type( ctor );
			assert( ctorType == "nil" or ctorType == "function", "Parameter 'ctor' must be function or nil" );
			
			if ( ctor ) then
				class.ctor = function( self, ... )
					ctor( self, class.inherit and class.inherit.ctor or NoClass, ... );
				end
			else
				class.ctor = AbstractClass;
			end
		end
	end
	
	local SetupPrototype;
	do 
		local ApplyInheritance = function( prototype, inherit )	
			for key, value in pairs( inherit ) do
				if ( not prototype[ key ] ) then
					prototype[ key ] = value;
				end
			end
		end
	
		SetupPrototype = function( class, prototype, inherit, ... )
			local prototypeType = type( prototype );
			assert( prototypeType == "nil" or prototypeType == "table", "Parameter 'prototype' must be table or nil" );
		
			local inheritType = GetType( inherit );
			assert( inheritType == "nil" or inheritType == "function" or inheritType == "class" or inheritType == "abstractclass", "Class can inherit only from another class. Given '" .. tostring( inheritType ) .. "'" );
			
			if ( not prototype ) then
				prototype = { };
			end
			
			if ( inherit and inheritType ~= "function" ) then
				setmetatable( prototype, inherit.metatable );
				
				class.inherit = inherit;
			end
			
			for i = 1, select( "#", ... ) do
				local current = select( i, ... );
				assert( GetType( current ) == "abstractclass", "Class can inherit only from abstract classes" );
			
				ApplyInheritance( prototype, current.prototype );
			end
			
			class.prototype = prototype;
			class.metatable = { __index = prototype };
		end
	end

	local New
	do
		New = function( class, ... )
			local instance = class:instanceFactory( ... );

			setmetatable( instance, class.metatable );
			
			class.ctor( instance, ... );
			
			return instance;
		end
	end
	
	CreateClass = function( ctor, prototype, inherit, ... )
		local class = { };
		setmetatable( class, { 
				__call = New,
				metadata = { isClass = true, isAbstract = not ctor },
			} );
		
		SetupMetadata( class );
		SetupInstanceFactory( class, inherit );
		SetupPrototype( class, prototype, inherit, ... );
		SetupCtor( class, ctor );
		
		return class, class.inherit and class.inherit.prototype or nil;
	end
end

local Register, Import;
do
	local classes = { };
	
	Register = function( name, class )
		local classType = GetType( class );
	
		assert( type( name ) == "string", "Parameter 'name' must be string" );
		assert( classType == "class" or classType == "abstractclass", "Parameter 'class' must be class or abstract class" );
		assert( classes[ name ] == nil, "Class with name '" .. name .. "' is already registered" );		
	
		classes[ name ] = class;
	end
	
	Import = function( name )
		assert( type( name ) == "string", "Parameter 'name' must be string" );
	
		local class = classes[ name ];		
		assert( class ~= nil, "Class '" .. name .. "' wasn't found" );
		
		return class;
	end
end

kCore = {
		CreateClass = CreateClass,
		GetType = GetType,
		
		Register = Register,
		Import = Import,
	};
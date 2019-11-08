local base = "sqladmin/"

if ( SERVER ) then

	-- Server functions
	include( base .. "sv_sqladmin.lua" )

	-- Client functions
	AddCSLuaFile( base .. "cl_sqladmin.lua" )
	
elseif ( CLIENT ) then

	-- Client functions
	include( base .. "cl_sqladmin.lua" )
	
end

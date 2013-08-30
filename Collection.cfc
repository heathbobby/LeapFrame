<cfcomponent extends="object" name="Collection" output="no">

	<cfset variables.collection = "">
	
	<cffunction name="init" access="public">
		<cfset variables.collection = createObject("java", "java.util.Vector")>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="Add" returntype="void" access="public" output="false">
		<cfargument name="object" type="any" required="true" />
		
		<cfset variables.collection.add(arguments.object)>
	</cffunction>
	
	<cffunction name="Remove" returntype="void" access="public" output="false">
		<cfargument name="Index" type="numeric" required="true" />
		
		<cfset variables.collection.remove(arguments.Index)>
	</cffunction>
	
	<cffunction name="Get" returntype="any" access="public" output="false">
		<cfargument name="Index" type="numeric" required="true" />
		
		<cfreturn variables.collection.get(arguments.Index)>
	</cffunction>
	
	<cffunction name="Elements" returntype="any" access="public" output="false">
		<cfreturn variables.collection.elements()>
	</cffunction>
	
	<cffunction name="Capacity" returntype="numeric" access="public" output="false">
		<cfreturn variables.collection.capacity()>
	</cffunction>
	
	<cffunction name="Clear" returntype="numeric" access="public" output="false">
		<cfreturn variables.collection.clear()>
	</cffunction>
	
	<cffunction name="Contains" returntype="numeric" access="public" output="false">
		<cfargument name="object" type="any" required="true" />
		
		<cfreturn variables.collection.contains(arguments.object)>
	</cffunction>
	
</cfcomponent>
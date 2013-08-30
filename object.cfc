<cfcomponent displayname="object" output="no" hint="This is the base class that provides basic reflective methods for extended classes">

	<cffunction name="init" access="public" returntype="any" output="false">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getReflectionData" access="public" returntype="any" output="false" >
		<cfreturn getMetaData() />
	</cffunction>
	
	<cffunction name="getName" access="public" returntype="string" output="false">
		<cfreturn getMetaData().name />
	</cffunction>
	
	<cffunction name="getType" access="public" returntype="string" output="false">
		<cfreturn getMetaData().type />
	</cffunction>
	
	<cffunction name="dumpVals" access="public" returntype="any">
		<cfdump var="#variables#" />
	</cffunction>
	
	<cffunction name="getDTO" access="public" returntype="any" output="false">
		<cfset structDelete(variables,"this") />
		<cfreturn variables />
	</cffunction>
	
	<cffunction name="enforceType" access="public" returntype="void" >
		<cfargument name="var" type="any" required="yes" />
		<cfargument name="type" type="string" required="yes" />
				<cfset var varname = replace(var.getName(),"/",".","ALL") />
				<cfif not varname contains type>
					<cfthrow message="Argument of type: '#type#' expected" />
				</cfif>
	</cffunction>
	
</cfcomponent>

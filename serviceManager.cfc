<cfcomponent extends="object" output="no">

	<cfset variables.services = arrayNew(1) />
	<cfset variables.stServices = structNew() />
	
	<cffunction name="init" access="public" returntype="serviceManager" output="no">
		<cfset variables.services = arrayNew(1) />
		<cfset variables.stServices = structNew() />
		<cfreturn super.init() />
	</cffunction>

	<cffunction name="getService" access="public" returntype="service" output="false" >
		<cfargument name="name" type="string" required="yes" />
		<cfset var i = "" />
		<cfset var service =  "" />

		<cfif hasService(arguments.name) > 
			<cfreturn variables.stServices[ arguments.name ] />
		</cfif>
		<cfthrow message="No service exists by that Name.  #arguments.name# is not a valid service" />
	</cffunction>
	
	<cffunction name="setService" access="public" returntype="void" output="no">
		<cfargument name="service" type="leapframe.service" required="yes" />
		<cfif NOT hasService( arguments.service.getName() )>
			<cfset arrayAppend( variables.services, arguments.service ) />
			<cfset variables.stServices[ arguments.service.getName() ] = arguments.service />
		</cfif>
	</cffunction>

	<cffunction name="getServices" access="public" returntype="any" output="no">
		<cfreturn variables.services />
	</cffunction>
	
	<cffunction name="setServices" access="public" returntype="void" output="no">
		<cfargument name="services" type="array" required="yes" />
		<cfloop from="1" to="#arrayLen(arguments.services)#" index="i">
			<cfset setService( arguments.services ) />
		</cfloop>
	</cffunction>
	
	<cffunction name="hasService" access="public" returntype="boolean" output="false" >
		<cfargument name="name" type="string" required="true" />
		<cfif structKeyExists( variables.stServices, arguments.name ) >
			<cfreturn true />
		</cfif>
		<cfreturn false />
	</cffunction>
	
	<cffunction name="addService" access="public" returntype="void" output="no">
		<cfargument name="service" type="leapframe.service" required="yes" />
		<cfif NOT hasService(arguments.service.getName() )>
			<cfset arrayAppend( variables.services, arguments.service ) />
			<cfset variables.stServices[ arguments.service.getName() ] = arguments.service />
		</cfif>
	</cffunction>

</cfcomponent>
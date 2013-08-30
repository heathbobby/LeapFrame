<cfcomponent displayname="validatorFacade" output="false">

	<cffunction name="getvalidator" access="public" returntype="any" output="false">
		<cfif validatorExists() >
			<cfreturn request.validator />
		</cfif>
		<cfset setValidator(createObject('component','validator').init(argumentCollection:arguments)) />
		<cfreturn request.validator />
	</cffunction>
	
	<cffunction name="setvalidator" access="public" returntype="void" output="false" >
		<cfargument name="validator" type="validator" required="yes" />
		<cfset request.validator = arguments.validator />
	</cffunction>
	
	<cffunction name="validatorExists" access="public" returntype="boolean" output="false">
		<cfif structKeyExists(request,'validator')>
			<cfreturn true />
		</cfif>
		<cfreturn false />
	</cffunction>
	
</cfcomponent>
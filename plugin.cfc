<cfcomponent extends="object">
	<cfset variables.properties = structNew() />
	
	<cffunction name="init" access="public" returntype="plugin" output="false">
		<cfset structAppend(variables.properties,arguments,true) />
		<cfreturn super.init(argumentCollection:arguments) />
	</cffunction>

	<cffunction name="getProperties" access="public" returntype="any" output="false">
			<cfreturn variables.Properties />
	</cffunction>	

	<cffunction name="setProperty" access="public" returntype="void" output="false">
		<cfargument name="key" 		required="yes" type="string"/>
		<cfargument name="value" 	required="yes" type="any" />
			<cfset variables.Properties[arguments.key] = arguments.value />
	</cffunction>
	
	<cffunction name="getProperty" access="public" returntype="any" output="false">
		<cfargument name="key" type="string" required="yes" />
		<cfargument name="defaultVal" required="no" type="any" />
		<cfif structKeyExists(variables.Properties,"#arguments.key#")>
			<cfreturn variables.Properties[arguments.key]  />
		<cfelse>
			<cfif structKeyExists(arguments,"defaultVal")><cfreturn arguments.defaultVal /></cfif>
			<cfreturn "" />
		</cfif>
	</cffunction>
	
	<cffunction name="propertyExists" access="public" returntype="boolean" output="false">
		<cfargument name="property" type="any" required="yes" />
		<cfreturn structKeyExists(variables.properties, arguments.property) />
	</cffunction>
	
	<cffunction name="onApplicationLoad" access="public" returntype="void">
	</cffunction>
	
	<cffunction name="onRequestStart" access="public" returntype="void">
	</cffunction>
	
	<cffunction name="onRequestEnd" access="public" returntype="void">
	</cffunction>

	<cffunction name="onError" access="public" returnType="void">
	</cffunction>

</cfcomponent>
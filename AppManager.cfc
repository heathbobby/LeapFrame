<cfcomponent extends="object" output="no">
	<cfset variables.initialized = false />
	<cfset variables.loaded = false />
	<cfset variables.HandlerManager = "" />
    <cfset variables.pluginManager = "" />
    <cfset variables.serviceManager = "" />
    <cfset variables.properties = "" />
	
	
	<cffunction name="init" returntype="AppManager" access="public" output="no">
		<cfargument name="appConfig" type="struct" required="no" default="#structNew()#" />
		<cfset setProperties(appConfig) />
		<cfset setHandlerManager( createobject( 'component', 'HandlerManager' ) ) />
        <cfset setPluginManager( createobject( 'component','pluginManager' ) ) />
        <cfset setServiceManager( createobject( 'component', 'serviceManager' ) ) />
		<cfset variables.initialized = true />
		<cfreturn super.init() />
	</cffunction>
	
	<cffunction name="getHandlerManager" access="public" returntype="HandlerManager" output="no">
		<cfreturn variables.HandlerManager />
	</cffunction>
	
	<cffunction name="setHandlerManager" access="private" returntype="void" output="no">
		<cfargument name="HandlerManager" type="HandlerManager" required="yes" />
		<cfset variables.HandlerManager = arguments.HandlerManager />
	</cffunction>

	<cffunction name="getPluginManager" access="public" returntype="PluginManager" output="no">
		<cfreturn variables.PluginManager />
	</cffunction>
	
	<cffunction name="setPluginManager" access="private" returntype="void" output="no">
		<cfargument name="PluginManager" type="PluginManager" required="yes" />
		<cfset variables.PluginManager = arguments.PluginManager />
	</cffunction>
    
    <cffunction name="getServiceManager" access="public" returntype="serviceManager" output="no">
		<cfreturn variables.serviceManager />
	</cffunction>
	
	<cffunction name="setServiceManager" access="private" returntype="void" output="no">
		<cfargument name="serviceManager" type="serviceManager" required="yes" />
		<cfset variables.serviceManager = arguments.serviceManager />
	</cffunction>

	<cffunction name="setProperties" access="public" returntype="void" output="false">
		<cfargument name="Properties" required="yes" type="struct" />
			<cfset variables.Properties = arguments.Properties />
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
    
	<cffunction name="setLoaded" access="package" returntype="void" output="false">
		<cfargument name="loaded" type="boolean" required="no" default="false" />
		<cfset variables.loaded = arguments.loaded />
	</cffunction>
	
	<cffunction name="isLoaded" access="public" returntype="boolean" output="false">
		<cfreturn variables.loaded />
	</cffunction>
	
</cfcomponent>
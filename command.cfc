<cfcomponent extends="object" output="no">

	<cfset variables.component = "" />
	<cfset variables.method = "" />

	
	<cffunction name="init" access="public" returntype="command" output="false">
		<cfargument name="component" type="string" required="yes" />
		<cfargument name="method" type="string" required="yes" />
		
		<cfscript>
			setComponent(arguments.component); 
			setMethod(arguments.method);
		</cfscript>
		<cfreturn this />
	</cffunction>
	
	<cffunction name="execute" access="public" returntype="any" output="true">
		<cfargument name="action" required="yes" type="action">
		<cfargument name="params" required="false" type="any" default="#structNew()#" >
			<cfset var component = createObject('component',component) />
			<cfif structKeyExists(component, 'init')>
				<cfset component.init() />
			</cfif>
			<cfreturn evaluate("component." & variables.method & "(arguments.action, arguments.params)") />
	</cffunction> 
	
	<cffunction name="getComponent" access="public" returntype="string" output="false">
		<cfreturn variables.getComponent />
	</cffunction>
	<cffunction name="setComponent" access="public" returntype="void" output="false">
		<cfargument name="component" type="string" required="yes" /> 
		<cfset variables.component = application.appManager.getProperty('siteroot') & arguments.component />
	</cffunction>
		
	<cffunction name="getMethod" access="public" returntype="string" output="false">
		<cfreturn variables.getMethod />
	</cffunction>
	<cffunction name="setMethod" access="public" returntype="void" output="false">
		<cfargument name="Method" type="string" required="yes" /> 
		<cfset variables.Method = arguments.Method />
	</cffunction>
		
</cfcomponent>
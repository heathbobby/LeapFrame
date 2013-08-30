<cfcomponent extends="object" output="no">

	<cfset variables.templateName = "" />
	<cfset variables.resultVar = "" />
	
	<cffunction name="init" access="public" returntype="view" output="false">
		<cfargument name="templateName" type="string" required="yes">
		<cfargument name="resultVar" type="string" required="no" default="" />
		
		<cfscript>
			setTemplateName(arguments.templateName);
			setResultVar(arguments.resultVar);
		</cfscript>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="invokeView" access="public" returntype="any">
		<cfargument name="action" type="action" required="yes" />
		<cfset var tempvar = "" />
		<cfif len(variables.resultVar)>
			<cfsavecontent variable="tempvar">
				<cfinclude template="#application.appManager.getProperty('viewPath')##variables.templateName#" />
			</cfsavecontent>
			<cfset arguments.action.setArg('#variables.resultVar#',tempvar) />
		<cfelse>
			<cfinclude template="#application.appManager.getProperty('viewPath')##variables.templateName#" />
		</cfif>
		
		<cfreturn arguments.action />
	</cffunction>
	
	<cffunction name="getTemplateName" access="public" returntype="string" hint="getter for TemplateName" output="false">
		<cfreturn variables.getTemplateName />
	</cffunction>
	<cffunction name="setTemplateName" access="public" returntype="void" >
		<cfargument name="TemplateName" type="string" required="yes" /> 
		<cfset variables.TemplateName = arguments.TemplateName />
	</cffunction>
	
	<cffunction name="getResultVar" access="public" returntype="string" hint="getter for ResultVariable name" output="false">
		<cfreturn variables.getResultVar />
	</cffunction>
	<cffunction name="setResultVar" access="public" returntype="void" >
		<cfargument name="ResultVar" type="string" required="yes" /> 
		<cfset variables.ResultVar = arguments.ResultVar />
	</cffunction>
	
	<!--- Utility Functions --->
	<cffunction name="truncate" access="public" returntype="string" output="false">
		<cfargument name="stValue" type="string" required="yes" />
		<cfargument name="maxCharacters" type="string" required="no" default="50" />
		<cfset var returnString = "" />
			<cfif len(arguments.stValue) GT arguments.maxCharacters>
				<cfreturn left(arguments.stValue,arguments.maxCharacters) & " ..." />
			<cfelse>
				<cfreturn arguments.stValue />
			</cfif>
	</cffunction>
	
</cfcomponent>
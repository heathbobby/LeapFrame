<cfcomponent extends="object" displayname="ajaxUploadGateway" output="no">
	<cfsetting showdebugoutput="no" />
	<cfscript>
			variables.udf = createObject('component','udf');
	</cfscript>		
	
	<cffunction name="request" access="public" returntype="void">
		<cfargument name="Action" type="action" required="no" default="#createObject('component','action').init()#">
			<cfcontent type="text/html; charset=ISO-8859-1" />  
			<cfheader name="expires" value="#now()#" />   
			<cfheader name="pragma" value="no-cache" />   
			<cfheader name="cache-control" value="no-cache, no-store, must-revalidate" />
			<cfsetting showdebugoutput="no" /> 
			<cfoutput>#getPageContext().getOut().clearBuffer()##variables.udf.toJson(arguments.Action.getArgs())#</cfoutput>
	</cffunction>
	
</cfcomponent>
<cfcomponent extends="object" displayname="xmlGateway" output="no">
	<cfsetting showdebugoutput="no" />
	<cfscript>
			variables.udf = createObject('component','udf');
	</cfscript>		
	
	<cffunction name="request" access="public" returntype="void" output="no">
		<cfargument name="Action" type="action" required="no" default="#createObject('component','action').init()#">
			<!--- cfcontent type="text/plain; charset=ISO-8859-1" / --->  
			<cfheader name="expires" value="#now()#" />   
			<cfheader name="pragma" value="no-cache" />   
			<cfheader name="cache-control" value="no-cache, no-store, must-revalidate" />
            <cfheader name="outputFormat" value="xml" /> 
			<cfoutput>#getPageContext().getOut().clearBuffer()##variables.udf.toXml(arguments.action.getArgs())#</cfoutput>
            
	</cffunction>
	
</cfcomponent>
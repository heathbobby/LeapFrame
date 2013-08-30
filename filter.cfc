<cfcomponent extends="command" output="no">

	<cfset variables.faultAction = "" />
	
	<cffunction name="init" access="public" returntype="filter" output="false">
		<cfargument name="component" type="string" required="yes" />
		<cfargument name="method" type="string" required="yes" />
		<cfargument name="faultAction" type="string" required="no" />
		
		<cfif structKeyExists(arguments,'faultAction') >
			<cfset setFaultAction(arguments.faultAction) />
		</cfif>
		<cfreturn super.init(component:arguments.component,method:arguments.method) />
	</cffunction>
	
	<cffunction name="execute" access="public" returntype="action">
		<cfargument name="action" required="yes" type="action">
			<cfif NOT super.execute(arguments.action) >
				<cfif len(variables.faultAction)>
					<cfset arguments.action.setArg('prevAction',arguments.action.getArg('action')) />
					<cfset arguments.action.setArg('action',variables.faultAction) />
					<cfset createObject('component','requestHandler').init().handleRequest(createObject('component','action').init(arguments.action.getArgs())) />
					<cfabort />
				<cfelse>
					<cfthrow message="Filter returned false and there is no fault action defined" />
				</cfif>
			</cfif>
		<cfreturn arguments.action />
	</cffunction> 
	
	<cffunction name="getFaultAction" access="public" returntype="action" hint="getter for faultAction" output="false">
		<cfreturn variables.faultAction />
	</cffunction>
	<cffunction name="setFaultAction" access="public" returntype="void" >
		<cfargument name="faultAction" type="string" required="yes" /> 
		<cfset variables.faultAction = arguments.faultAction/>
	</cffunction>
</cfcomponent>
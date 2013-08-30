<cfcomponent extends="command" output="no">

	<cfset variables.resultVar = "" />
	
	<cffunction name="init" access="public" returntype="cmdlistener" output="false">
		<cfargument name="component" type="string" required="yes" />
		<cfargument name="method" type="string" required="yes" />
		<cfargument name="resultVar" type="string" required="no" default="" />

		<cfset setResultVar(arguments.resultVar) />
		<cfreturn super.init(component:arguments.component,method=arguments.method) />
	</cffunction>
	
	<cffunction name="execute" access="public" returntype="action" output="false">
		<cfargument name="action" required="yes" type="action">
		<cfargument name="params" required="false" type="any" default="#structnew()#" > 
			<cfif len( variables.resultVar ) >
				<cfset arguments.action.setArg( variables.resultVar, super.execute( arguments.action, arguments.params ) ) />
			<cfelse>
				<cfset super.execute( arguments.action, arguments.params ) />
			</cfif>
		<cfreturn arguments.action />
	</cffunction> 
		
	<cffunction name="getResultVar" access="public" returntype="string" hint="getter for ResultVariable name" output="false">
		<cfreturn variables.getResultVar />
	</cffunction>
	<cffunction name="setResultVar" access="public" returntype="void" >
		<cfargument name="resultVar" type="string" required="yes" /> 
		<cfset variables.resultVar = arguments.resultVar />
	</cffunction>
	
</cfcomponent>
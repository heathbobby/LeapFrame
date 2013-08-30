<cfcomponent extends="object" output="no">
	<cfset variables.handlers = arrayNew(1) />
	
	<cffunction name="init" access="public" returntype="HandlerManager" output="no">
		<cfreturn super.init() />
	</cffunction>
	
	<cffunction name="setHandlers" access="public" returntype="void" output="no">
		<cfargument name="handlers" type="any" required="yes" />
		<cfset variables.handlers = arguments.handlers />
	</cffunction>
	
	<cffunction name="getHandlers" access="public" returntype="any" output="no">
		<cfreturn variables.handlers />
	</cffunction>
	
	
	<cffunction name="getHandler" access="public" returntype="xml" output="false" >
		<cfargument name="action" type="string" required="no" default="#application.appManager.getProperty('defaultAction')#" />
		
		<cfset var i= "" />
		<cfset var handler = "" />
		
		<cfif NOT len(arguments.action) > <cfset arguments.action = application.appManager.getProperty('defaultAction') /></cfif>
		<cftry>
			<cfloop from="1" to="#ArrayLen(variables.handlers)#" index="i">
				<cfif variables.handlers[i].XmlAttributes.action EQ arguments.action>
				<!--- I had to do this because of some cf 7 weirdness with xmlSearch. This should be put back in in cf 8  --->
				<!---cfif xmlSearch(variables.handlers[i], "@action='#arguments.action#'" ) --->
					<cfset handler = duplicate(variables.handlers[i]) />
					<cfbreak />
				</cfif>
			</cfloop>
			<cfif handler EQ "">
				<cfthrow type="request.handler.none" message="No Handlers available for the action '#arguments.action#'" />
			</cfif>
		<cfcatch type="request.handler.none">
			<cfthrow type="request.handler.none" message="No Handlers available for the action '#arguments.action#'" />
		</cfcatch>
		<cfcatch type="any">
			<cfthrow type="request.handler.getHandler" message="An error occured while processing the configuration XML in 'getHandler'" />
		</cfcatch>
		</cftry>
		
		<cfreturn handler />
	</cffunction>
	
</cfcomponent>
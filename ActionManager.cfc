<cfcomponent extends="object" output="no">
	<cfset variables.actions = ""/>
	<cfset variables.currentAction = "" />
	
	<cffunction name="init" returntype="ActionManager" access="public" output="false">
		<cfset variables.actions = createObject('component','collection').init() />
		<cfset variables.currentAction = 0 />
		<cfreturn super.init() />
	</cffunction>
	
	<cffunction name="getCurrentAction" access="public" returntype="action" output="false">
		<cfreturn variables.actions.get(variables.currentAction) />
	</cffunction>
	
	<cffunction name="addAction" access="public" returntype="action" output="false">
		<cfargument name="action" type="action" required="yes" />
			<cfset variables.actions.add(arguments.action) />
	</cffunction>
	
	<cffunction name="getActions" access="public" returntype="collection" output="false">
		<cfreturn variables.actions />
	</cffunction>
	
	<cffunction name="setActions" access="public" returntype="void" output="false">
		<cfargument name="actions" type="array" required="yes" />
			<cfloop from="1" to="#arrayLen(arguments.actions)#" index="i" >
				<cfset addAction(arguments.actions[i]) />
			</cfloop>
	</cffunction>
	
</cfcomponent>
<cfcomponent extends="object" output="no">
	<cfset variables.plugins = arrayNew(1) />
	
	<cffunction name="init" access="public" returntype="PluginManager" output="no">
		<cfreturn super.init() />
	</cffunction>
	
	<cffunction name="setPlugins" access="public" returntype="void" output="no">
		<cfargument name="plugins" type="any" required="yes" />
		<cfset variables.plugins = arguments.plugins />
	</cffunction>
	
	<cffunction name="getPlugins" access="public" returntype="any" output="no">
		<cfreturn variables.plugins />
	</cffunction>
	
	<cffunction name="getPluginByName" access="public" returntype="plugin" output="false" >
		<cfargument name="name" type="string" required="yes" />
		<cfset var i = "" />
		<cfset var plugin =  "" />
		<cfloop from="1" to="#arrayLen(variables.plugins)#" index="i">
			<cfif variables.plugins[i].getProperty('pluginName') EQ arguments.name> 
				<cfreturn variables.plugins[i] />
			</cfif>
		</cfloop>
		<cfthrow message="No Plugin exists by that Name.  #arguments.name# is not a valid plugin" />
	</cffunction>
	
</cfcomponent>
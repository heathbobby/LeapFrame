<!--- include this file for the on error handler --->
<cfset plugins = application.appManager.getPluginManager().getPlugins() />
<cfloop from="1" to="#arrayLen(plugins)#" index="i">
	<cfset plugins[i].onError() />
</cfloop>